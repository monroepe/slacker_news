require 'sinatra'
require 'sinatra/reloader'
require 'pry'
require 'csv'


def get_articles
  articles = []
  CSV.foreach("articles.csv") do |row|
    articles << {title: row[0],
    url: row[1],
    description: row[2]}
  end
  articles
end



get '/' do
  articles = get_articles

  erb :index, locals: {articles: articles}
end

get '/submit' do

  erb :submit
end

post '/submit' do
  articles = get_articles
  title = params["title"]
  url = params["url"]
  description = params["description"]
  CSV.open("articles.csv", "a") do |csv|
    csv << [title, url, description]
  end
  redirect '/'
end
