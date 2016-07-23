#encoding: UTF-8
load 'reader_db.rb'

graphan = GraphanServer.new
#examples, nouns, pronouns = graphan.generate_examples(5)
#p examples
#p nouns
#p pronouns

graphan.words_grouped_by_tones.each do |triplet|
	num, words, tone = triplet
	puts "#{num}\t#{tone}\t#{words.join(' ')}"
end

graphan.grammar_points.each do |gp|
	p gp
	# n.level, n.pattern, n.link, n.eng, n.example, g.name, c.name
end
