require 'sinatra'
require 'yaml'
load 'reader_db.rb'

# Sinatra API 
graphan = GraphanServer.new

get '/' do 
	erb :index
end

get '/vocab' do 
	@words = graphan.words
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
