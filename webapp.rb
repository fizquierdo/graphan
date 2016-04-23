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
end


# Sinatra API 
graphan = GraphanServer.new

get '/' do 
	"Graphan words: #{graphan.words} "
end

get '/people' do 
	"Graphan members: #{graphan.people} members"
end
