-- ============================================================
-- WEEK 3 | TOPIC 3: DISTINCT
-- ============================================================
-- DISTINCT removes duplicate values from your result.
-- You get only UNIQUE values.
-- ============================================================

USE practice_db;

-- ============================================================
-- BASIC DISTINCT
-- ============================================================

-- Without DISTINCT — shows all rows including duplicates
SELECT city FROM users;

-- With DISTINCT — unique values only
SELECT DISTINCT city FROM users;

-- ============================================================
-- COUNT DISTINCT — very common in real apps
-- ============================================================

-- How many unique cities do users come from?
SELECT COUNT(DISTINCT city) AS unique_cities FROM users;

-- How many unique users have placed orders?
SELECT COUNT(DISTINCT user_id) AS unique_customers FROM orders;

-- How many unique products have been ordered?
SELECT COUNT(DISTINCT product_id) AS unique_products FROM order_items;

-- ============================================================
-- DISTINCT on multiple columns
-- Returns unique COMBINATIONS of both columns (not unique per column)
-- ============================================================

-- Unique combinations of city + is_active
SELECT DISTINCT city, is_active
FROM users
ORDER BY city;

-- Unique status + city combinations from orders
SELECT DISTINCT u.city, o.status
FROM orders o
INNER JOIN users u ON o.user_id = u.id
ORDER BY u.city;

-- ============================================================
-- KEY RULE:
-- DISTINCT on 1 column  → unique values of that column
-- DISTINCT on 2 columns → unique COMBINATIONS of both columns
-- ============================================================

-- ============================================================
-- PRACTICE CHALLENGES:

-- Challenge 1: How many unique statuses exist in the orders table?
-- Challenge 2: List all unique cities where orders have been placed
--              (users who actually placed orders, not all users)
-- Challenge 3: How many unique products appear in order_items?
-- ============================================================
