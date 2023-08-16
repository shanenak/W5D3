PRAGMA foreign_keys = ON;

CREATE TABLE users (
    id INTEGER PRIMARY KEY,
    fname TEXT NOT NULL,
    lname TEXT NOT NULL
);

CREATE TABLE questions (
    id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    user_id INTEGER NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE question_follows (
    id INTEGER PRIMARY KEY,
    user_id INTEGER NOT NULL,
    question_id INTEGER NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id)
    FOREIGN KEY (question_id) REFERENCES questions(id)
);

CREATE TABLE replies (
    id INTEGER PRIMARY KEY,
    question_id INTEGER NOT NULL,
    reference_id INTEGER, 
    user_id INTEGER NOT NULL,
    body TEXT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id)
    FOREIGN KEY (question_id) REFERENCES questions(id)
    FOREIGN KEY (reference_id) REFERENCES replies(id)
);

CREATE TABLE question_likes (
    id INTEGER PRIMARY KEY,
    user_id INTEGER NOT NULL, --- may not be null ---- 
    question_id INTEGER NOT NULL, ---- ditto ---- 
    FOREIGN KEY (user_id) REFERENCES users(id)
    FOREIGN KEY (question_id) REFERENCES questions(id)
);

INSERT INTO 
    users(fname, lname)
VALUES
    ('Shannon', 'Millar'),
    ('David', 'Pollack');

INSERT INTO
    questions(title, body, user_id)
VALUES
    ('career', 'How do I get a job?', (SELECT id FROM users WHERE fname = 'Shannon')),
    ('cat', 'Should I get a 3rd cat?', (SELECT id FROM users WHERE fname = 'David'));

INSERT INTO
    question_follows(user_id, question_id)
VALUES
    ((SELECT id FROM users WHERE fname = 'Shannon'), (SELECT id FROM questions WHERE title = 'cat')),
    ((SELECT id FROM users WHERE fname = 'David'), (SELECT id FROM questions WHERE title = 'career'));

INSERT INTO 
    replies(question_id, reference_id, user_id, body)
VALUES
    ((SELECT id FROM questions WHERE title = 'career'), NULL,(SELECT id FROM users WHERE fname = 'David'), 'Join App Academy!'),
    ((SELECT id FROM questions WHERE title = 'career'),(SELECT id FROM replies WHERE body = 'Join App Academy!'),(SELECT id FROM users WHERE fname = 'Shannon'), 'Kiss up XD');

INSERT INTO 
    question_likes(user_id, question_id)
VALUES
    ((SELECT id FROM users WHERE fname = 'David'), (SELECT id FROM questions WHERE title = 'career')),
    ((SELECT id FROM users WHERE fname = 'Shannon'), (SELECT id FROM questions WHERE title = 'cat'));
