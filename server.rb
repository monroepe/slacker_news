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
  query = 'SELECT articles.url FROM articles;'
  urls = db_connection do |conn|
    conn.exec(query)
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
  url = url_fixer(url)
  urls = get_urls

  urls.each do |hash|
    if hash['url'] == (url)
      return false
    end
  end
  true
end

def write_article(title, url, description)
  article = 'INSERT INTO articles (title, url, description)
  VALUES ($1, $2, $3)'

  db_connection do |conn|
    conn.exec_params(article, [title, url, description])
  end
end

def valid_input?(title, url, description)
  (valid_title?(title) && valid_url?(url) && valid_description?(description))
end

def get_article(id)
  query = 'SELECT articles.id, articles.title, articles.url, articles.description
  FROM articles
  WHERE articles.id = $1'

  article = db_connection do |conn|
      conn.exec_params(query, [id])
  end
  article
end

def valid_comment?(username, comment)
  (username.length < 50) && (comment.length > 0 && comment.length < 2000)
end

def get_comments(article_id)
  query = 'SELECT comments.username, comments.comment
  FROM comments
  WHERE article_id = $1'

  comments = db_connection do |conn|
      conn.exec_params(query, [article_id])
  end
  comments
end

def write_comment(username, comment, article_id)
  input = 'INSERT INTO comments (username, comment, article_id)
  VALUES ($1, $2, $3)'

  db_connection do |conn|
    conn.exec_params(input, [username, comment, article_id])
  end
end

get '/' do
  redirect '/articles'
end

get '/articles' do
  query = 'SELECT articles.id, articles.title, articles.url, articles.description
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
  if valid_input?(params["title"], params["url"], params["description"])
    title = params["title"]
    url = url_fixer(params["url"])
    description = params["description"]
    write_article(title, url, description)
    redirect '/articles'
  else
      erb :'new/index'
  end
end

get '/articles/:article_id/comments' do
  article_id = params[:article_id].to_i
  @comments = get_comments(article_id)
  @article = {}
  article = (get_article(article_id)).to_a
  @article['url'] = article[0]['url']
  @article['title'] = article[0]['title']
  @article['description'] = article[0]['description']
  @article['id'] = article[0]['id']
  erb :'comments/index'
end

post '/articles/:article_id/comments' do
  id = params[:article_id].to_i
  if valid_comment?(params["username"], params["comment"])
    username = params["username"]
    comment = params["comment"]
    write_comment(username, comment, id)
    redirect "/articles/#{params[:article_id]}/comments"
  else
    erb :'comments/index'
  end
end


