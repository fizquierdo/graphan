#encoding: UTF-8

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
		# seems to pass the right format but the view does not
	end
	def people
		# Return all nodes with label Person
		cypher = "MATCH (n:Person) RETURN n"
		graph = @neo.execute_query(cypher)
		graph["data"].map{|d| d[0]["data"]}
	end

	def add_word(word, label=nil)
		node = @neo.create_node(simp: word[:simp], 
													 eng:		word[:eng], 
													 pinyin:word[:pinyin])
		@neo.add_label(node, "Word")
		@neo.add_label(node, label) if label
	end
end

# This bit works and shows the encoding correctly
graphan = GraphanServer.new
puts graphan.words.last["trad"]
