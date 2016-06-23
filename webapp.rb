require 'sinatra'
require 'yaml'
load 'reader_db.rb'

# Sinatra API 
graphan = GraphanServer.new

get '/' do 
	@words = graphan.words
	erb :index
end

get '/people' do 
	"Graphan members: #{graphan.people} members"
end

get '/addword' do 
	erb :addword_form
end

get '/examples' do 
	@examples, @nouns, @pronouns = graphan.generate_examples(5)
	erb :examples_form
end

# When a new word is submitted, store it in Graphene DB
post '/addword' do 
	new_word = {simp: params["simp"],
							eng: params["eng"]}
	graphan.add_word(new_word, params["label"])
	redirect '/'
end
