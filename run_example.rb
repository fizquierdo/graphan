#encoding: UTF-8

load 'reader_db.rb'

graphan = GraphanServer.new
examples, nouns, pronouns = graphan.generate_examples(5)
p examples
p nouns
p pronouns
