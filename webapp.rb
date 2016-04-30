require 'sinatra'
require 'yaml'
require 'neography'

class GraphanServer
	def initialize
		cfg = YAML::load_file("config.yml")
		@neo = Neography::Rest.new("#{cfg["db"]["url"]}:#{cfg["db"]["port"]}")
	end
	def words
		# Return all nodes with label Word
		cypher = "MATCH (n:Word) RETURN n"
		graph = @neo.execute_query(cypher)
		graph["data"].map{|d| d[0]["data"]}
	end
	def people
		# Return all nodes with label Person
		cypher = "MATCH (n:Person) RETURN n"
		graph = @neo.execute_query(cypher)
		graph["data"].map{|d| d[0]["data"]}
	end

	def add_word(word, label=nil)
		node = @neo.create_node(hanzi: word[:hanzi], 
													 eng:		word[:eng], 
													 pinyin:word[:pinyin])
		@neo.add_label(node, "Word")
		@neo.add_label(node, label) if label
	end
end



# Sinatra API 
graphan = GraphanServer.new

get '/' do 
	@words = graphan.words
	erb :index
end

get '/people' do 
	"Graphan members: #{graphan.people} members"
end

get '/addword' do 
	erb :addword_form
end

# When a new word is submitted, store it in Graphene DB
post '/addword' do 
	new_word = {hanzi: params["hanzi"],
							pinyin: params["pinyin"],
							eng: params["eng"]}
	graphan.add_word(new_word, params["label"])
	redirect '/'
end


# TODO edit word to assign label (adj / noun) ?
