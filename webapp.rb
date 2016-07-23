require 'sinatra'
require 'yaml'
load 'reader_db.rb'

# Sinatra API 
graphan = GraphanServer.new

get '/' do 
	# TODO real login, for now we work with a single user
	@username = "Fernando"
	erb :index
end

get '/vocab' do 
	# TODO initialize words as doesnt-know, then tag them as learning or knows via relationship with user?
	@username = "Fernando"
	@learning_words = graphan.words_selection(@username, "LEARNS")
	@known_words = graphan.words_selection(@username, "KNOWS")
	erb :vocab
end

get '/addword' do 
	erb :addword_form
end

# When a new word is submitted, store it in Graphene DB
post '/addword' do 
	new_word = {simp: params["simp"], eng: params["eng"]}
	label    = params["sel"]
	#"new word #{new_word} #{label}"
	graphan.add_word(new_word, label)
	redirect '/'
end

get '/examples' do 
	@examples, @nouns, @pronouns = graphan.generate_examples(5)
	erb :examples
end

get '/people' do 
	"Graphan members: #{graphan.people} members"
end

get '/tonelist' do 
	@triplets = graphan.words_grouped_by_tones
	erb :tonelist
end

get '/grammar' do 
	@grammar_points, @levels, @grammar_types = graphan.grammar_points_and_types
	erb :grammar
end

post '/grammar_filter' do 
	@grammar_points, @levels, @grammar_types = graphan.grammar_points_and_types(params)
	# TODO selection should be done within graphan (passing params)
	@grammar_points = @grammar_points.select{|gp| gp[0] == params["selLevel"] and gp[5] == params["selGrammar"]}
	erb :grammar
end

post '/known_word' do
	graphan.add_known_relationship("Fernando", params["simp"])
	redirect '/vocab'
end
