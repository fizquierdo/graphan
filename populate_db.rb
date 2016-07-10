require "neography"
require "yaml"
require "csv"
require 'chinese_pinyin' 

cfg = YAML::load_file("config.yml")
neo = Neography::Rest.new("#{cfg["db"]["url"]}:#{cfg["db"]["port"]}")

# Delete all nodes
query = "MATCH (n)
				 OPTIONAL MATCH (n)-[r]-()
				 DELETE n,r"
neo.execute_query(query)

# create word nodes 
words =  CSV.read("data/hsk1_graphan.csv", headers: true, skip_blanks: true)

created_words = {}
words.each do |word|
	w = Hash[words.headers.map{|item| [item.to_sym, word[item]] }]
	w[:pinyin] = Pinyin.t w[:simp], tonemarks: true
	node = neo.create_node w
	# All these nodes are words, and belong to the HSK1 subset of words
	%w(Word HSK1).each{|label| neo.add_label(node, label)}
	created_words[w[:simp]] = node
end

# create people nodes (example on how to read from an existing csv)
people =  CSV.read("data/people.csv", headers: true, skip_blanks: true)

created_people = {}
people["name"].each do |name|
	node = neo.create_node(name: name)
	neo.add_label(node, "Person")
	# All these nodes are people, usually would be generated via signup
	created_people[name] = node
end

# load grammar patterns
created_patterns = {}
patterns = [{name: "Shi", grammar_point: "Pronoun + 是 + Noun"}]
patterns.each do |pattern| 
	node = neo.create_node(pattern)
	neo.add_label(node, "Pattern")
	created_patterns["Shi"] = node
end

# create vocab-to-pattern relationship
["我", "你", "他", "我们", "她"].each do |simp|
	neo.create_relationship("valid_pronoun", created_words[simp], created_patterns["Shi"])
end

## create default knowledge relationships (might be different for each user/learning-mode)
created_words.each_pair do |word_simp, word_node| 
	neo.create_relationship("learning", created_people["Fernando"], word_node)
end
