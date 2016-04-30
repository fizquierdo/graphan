require "neography"
require "yaml"
require "csv"

cfg = YAML::load_file("config.yml")
neo = Neography::Rest.new("#{cfg["db"]["url"]}:#{cfg["db"]["port"]}")

# Delete all nodes
query = "MATCH (n)
				 OPTIONAL MATCH (n)-[r]-()
				 DELETE n,r"
neo.execute_query(query)

=begin
# define some word nodes
words = [ 
	{hanzi: "老",		eng: "old",		pinyin: "lǎo", grammar: "Adjective"},
	{hanzi: "新",		eng: "new",		pinyin: "lǎo", grammar: "Adjective"},
	{hanzi: "高兴", eng: "happy", pinyin: "lǎo", grammar: "Adjective"},
	{hanzi: "吃",		eng: "to eat",pinyin: "Chī", grammar: "Verb"}
]

# create a node with word and grammar labels
created_words = {}
words.each do |word|
	node = neo.create_node(hanzi: word[:hanzi], 
												 eng:		word[:eng], 
												 pinyin:word[:pinyin])
	neo.add_label(node, "Word")
	neo.add_label(node, word[:grammar])
	created_words[word[:eng]] = node
end
=end

# create word nodes 
words =  CSV.read("data/hsk1.tsv", headers: true, skip_blanks: true, col_sep: "\t")
words.each do |word|
	w = Hash[words.headers.map{|item| [item.to_sym, word[item]] }]
	node = neo.create_node w
	%w(Word HSK1).each{|label| neo.add_label(node, label)}
end

# create people nodes (example on how to read from an existing csv)
people =  CSV.read("data/people.csv", headers: true, skip_blanks: true)

created_people = {}
people["name"].each do |name|
	node = neo.create_node(name: name)
	neo.add_label(node, "Person")
	created_people[name] = node
end

## create knowledge relationships
#neo.create_relationship("knows", created_people["Fernando"], created_words["happy"])
#neo.create_relationship("knows", created_people["Fernando"], created_words["new"])

