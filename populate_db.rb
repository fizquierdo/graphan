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
words.each do |word|
	w = Hash[words.headers.map{|item| [item.to_sym, word[item]] }]
	w[:pinyin] = Pinyin.t w[:simp], tonemarks: true
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
