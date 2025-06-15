
SET search_path TO practice;

CREATE TABLE credit_cards
(
    idx VARCHAR NOT NULL PRIMARY KEY,
    city VARCHAR,
    date DATE,
    card_type VARCHAR,
    exp_type VARCHAR,
    gender VARCHAR,
    amount INT
);

