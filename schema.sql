CREATE TABLE articles (
  id serial PRIMARY KEY,
  title varchar(255) NOT NULL,
  url varchar(2038) NOT NULL,
  description varchar(5000) NOT NULL
);

CREATE TABLE comments (
  id serial PRIMARY KEY,
  username varchar(50),
  comment varchar(5000) NOT NULL,
  article_id INT references articles(id)
);
