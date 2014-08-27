require 'sinatra'
require 'sinatra/reloader'
require 'pry'
require 'pg'

def db_connection
  begin
    connection = PG.connect(dbname: 'slacker_news')

    yield(connection)

  ensure
    connection.close
  end
end

def get_urls
  urls = []
  articles = get_articles
  articles.each do |article|
    urls << article[:url]
  end
  urls
end

def valid_title?(title)
  title != nil
end

def url_fixer(url)
  if url[0..6] != "http://"
    url = "http://" + url
  end
  url
end

def valid_description?(description)
  description.length > 20
end

def valid_url?(url)

end

def write_article(title, url, description)
  article = 'INSERT INTO articles (title, url, description)
  VALUES ($1, $2, $3)'

  db_connection do |conn|
    conn.exec_params(article, [title, url, description])
  end
end

def valid_input?(title, description)
  (valid_title?(title) && valid_description?(description))
end

get '/' do
  redirect '/articles'
end

get '/articles' do
  query = 'SELECT articles.title, articles.url, articles.description
  FROM articles'

  @articles = db_connection do |conn|
      conn.exec(query)
    end
  erb :'articles/index'
end

get '/new' do
  erb :'new/index'
end

post '/new' do
  articles = get_articles
  if valid_input?(params["title"], params["description"])
    title = params["title"]
    url = url_fixer(params["url"])
    description = params["description"]
    write_article(title, url, description)
    redirect '/articles'
  else
      erb :'new/index'
  end
end
