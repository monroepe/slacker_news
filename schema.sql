CREATE TABLE articles (
  id serial PRIMARY KEY,
  title varchar(255) NOT NULL,
  url varchar(255) NOT NULL,
  description varchar(10000) NOT NULL
);

CREATE TABLE comments (
  id serial PRIMARY KEY,
  user varchar(50),
  comment varchar(10000) NOT NULL,
  article_id INT references articles(id)
);
