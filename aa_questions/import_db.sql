PRAGMA foreign_keys = ON;

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL
);

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  body TEXT NOT NULL,
  author_id INTEGER NOT NULL,

  FOREIGN KEY (author_id) REFERENCES users(id)
);

CREATE TABLE question_follows (
  question_id INTEGER NOT NULL,
  author_id INTEGER NOT NULL,

  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (author_id) REFERENCES users(id)
);

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  parent_reply_id INTEGER,
  author_id INTEGER NOT NULL,
  body TEXT NOT NULL,

  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (author_id) REFERENCES users(id),
  FOREIGN KEY (parent_reply_id) REFERENCES replies(id)
);

CREATE TABLE question_likes (
  author_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY (author_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

INSERT INTO
  users (fname, lname)
VALUES
  ("Rick", "Sanchez"),
  ("Birdman", "Birdman"),
  ("Morty", "Sanchez");

INSERT INTO
  questions (title, body, author_id)
VALUES
  ("Question", "Is this is my question?", (SELECT id FROM users WHERE fname = 'Rick')),
  ("Opinion", "Is this is my opinion?", (SELECT id FROM users WHERE fname = 'Morty'));

INSERT INTO
  question_follows (question_id, author_id)
VALUES
  (1, 2);

INSERT INTO
  replies (question_id, parent_reply_id, author_id, body)
VALUES
  (1, NULL, (SELECT id FROM users WHERE fname = 'Birdman'), "STUPID QUESTION!!");

INSERT INTO 
  question_likes (author_id, question_id)
VALUES  
  ((SELECT id FROM users WHERE fname = 'Morty'), 1);
