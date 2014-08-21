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

def valid_title?(title)
  title != nil
end

def valid_url?(url)
  url.include?("http://")
end

def valid_description?(description)
  description.length > 20
end

def write_article(title, url, description)
  CSV.open("articles.csv", "a") do |csv|
    csv << [title, url, description]
  end
end

def valid_input?(title, url, description)
  (valid_title?(title) && valid_url?(url) && valid_description?(description))
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
  if valid_input?(params["title"], params["url"], params["description"])
        title = params["title"]
        url = params["url"]
        description = params["description"]
        write_article(title, url, description)
        redirect '/'
    else
      erb :submit
    end

end
