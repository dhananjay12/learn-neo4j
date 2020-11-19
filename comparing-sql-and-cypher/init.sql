CREATE TABLE movie (
  id INTEGER,
  title VARCHAR(100),
  released INTEGER,
  tagline VARCHAR(100)
);
CREATE TABLE person (
  id INTEGER,
  name VARCHAR(100),
  born INTEGER
);
CREATE TABLE acted_in (
  role varchar(100),
  person_id INTEGER,
  movie_id INTEGER
);
CREATE TABLE directed (
  person_id INTEGER,
  movie_id INTEGER
);
CREATE TABLE produced (
  person_id INTEGER,
  movie_id INTEGER
);


INSERT INTO movie (id, title, released, tagline)
VALUES
  (1, 'The Matrix', 1999, 'Welcome to the Real World'),
  (2, 'The Devil''s Advocate', 1997, 'Evil has its winning ways'),
  (3, 'Monster', 2003, 'The first female serial killer of America');

INSERT INTO person (id, name, born)
VALUES
  (1, 'Keanu Reeves', 1964),
  (2, 'Carrie-Anne Moss', 1967),
  (3, 'Laurence Fishburne', 1961),
  (4, 'Hugo Weaving', 1960),
  (5, 'Andy Wachowski', 1967),
  (6, 'Lana Wachowski', 1965),
  (7, 'Joel Silver', 1952),
  (8, 'Charlize Theron', 1975),
  (9, 'Al Pacino', 1940),
  (10, 'Taylor Hackford', 1944);

INSERT INTO acted_in (role, person_id, movie_id)
VALUES
  ('Neo', 1, 1),
  ('Trinity', 2, 1),
  ('Morpheus', 3, 1),
  ('Agent Smith', 4, 1),
  ('Kevin Lomax', 1, 2),
  ('Mary Ann Lomax', 8, 2),
  ('John Milton', 9, 2),
  ('Aileen', 8, 3);

INSERT INTO directed (person_id, movie_id)
VALUES
  (5, 1),
  (6, 1),
  (10, 2);

INSERT INTO produced (person_id, movie_id)
VALUES
  (7, 1),
  (8, 3);