#encoding: UTF-8

require 'yaml'
require 'neography'
require 'chinese_pinyin' 

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
													 pinyin: Pinyin.t(word[:simp], tonemarks: true))
		@neo.add_label(node, "Word")
		@neo.add_label(node, label) if label
	end
end

# Use grammar property to build random 'Pronoun + shi + Noun' examples
=begin
graphan = GraphanServer.new
words		= graphan.words
pronouns= words.select{|w| w["grammar"] == "pronoun"}
nouns		= words.select{|w| w["grammar"] == "noun"}
5.times do 
  puts "#{pronouns.shuffle.first["simp"]} 是 #{nouns.shuffle.first["simp"]}"
end
=end
