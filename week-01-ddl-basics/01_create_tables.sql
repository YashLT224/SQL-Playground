-- ============================================================
-- WEEK 1 | TOPIC 1: CREATE TABLES (DDL)
-- ============================================================
-- DDL = Data Definition Language
-- These commands define the STRUCTURE of your database.
-- Think of it like defining a TypeScript interface — you're
-- setting up the shape before any data flows in.
-- ============================================================

-- Step 1: Create and select the database
CREATE DATABASE IF NOT EXISTS practice_db;
USE practice_db;

-- ============================================================
-- DATA TYPES CHEATSHEET (MySQL)
-- INT            → whole numbers (id, age, quantity)
-- VARCHAR(n)     → short text with max length (name, email)
-- TEXT           → long text, no limit (description, bio)
-- DECIMAL(p,s)   → precise decimals, p=total digits, s=after decimal (price)
-- BOOLEAN        → true / false (is_active)
-- DATETIME       → date + time (created_at)
-- ============================================================

-- Step 2: Create the users table
CREATE TABLE users (
  id         INT AUTO_INCREMENT PRIMARY KEY,  -- auto-generates 1, 2, 3...
  name       VARCHAR(100) NOT NULL,           -- required field
  email      VARCHAR(255) NOT NULL UNIQUE,    -- required + no duplicates
  age        INT,
  city       VARCHAR(100),
  is_active  BOOLEAN DEFAULT TRUE,            -- defaults to true if not provided
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP  -- auto-fills current time
);

-- Step 3: Create the products table
CREATE TABLE products (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  name        VARCHAR(150) NOT NULL,
  description TEXT,
  price       DECIMAL(10, 2) NOT NULL,  -- e.g. 1299.99
  stock       INT DEFAULT 0,
  created_at  DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Step 4: Create the orders table
CREATE TABLE orders (
  id           INT AUTO_INCREMENT PRIMARY KEY,
  user_id      INT NOT NULL,           -- which user placed this order
  total_amount DECIMAL(10, 2),
  status       VARCHAR(50) DEFAULT 'pending',  -- pending, shipped, delivered
  ordered_at   DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- VERIFY: Check all tables were created
-- ============================================================
SHOW TABLES;

-- See the structure of a table
DESCRIBE users;
DESCRIBE products;
DESCRIBE orders;
