-- init.sql
CREATE DATABASE order_food;

\c order_food

-- Create tables and other schema here
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL
);

-- Insert initial data
INSERT INTO users (username, email) VALUES ('admin', 'admin@example.com');
