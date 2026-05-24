-- ============================================================
-- WEEK 4 | TOPIC 1: SUBQUERIES IN WHERE
-- ============================================================
-- A subquery is a query inside another query.
-- Subqueries in WHERE filter rows based on the result
-- of an inner query.
--
-- Syntax:
--   SELECT ... FROM table
--   WHERE column = (SELECT ... FROM table);
-- ============================================================

USE practice_db;

-- ============================================================
-- BASIC SUBQUERY IN WHERE
-- ============================================================

-- Find the most expensive product
SELECT name, price
FROM products
WHERE price = (SELECT MAX(price) FROM products);

-- Find the cheapest product
SELECT name, price
FROM products
WHERE price = (SELECT MIN(price) FROM products);

-- ============================================================
-- SUBQUERY WITH IN — match against a list
-- ============================================================

-- Find users who have placed at least one order
SELECT name, email
FROM users
WHERE id IN (
  SELECT DISTINCT user_id FROM orders
);

-- Find users who have NEVER placed an order
SELECT name, email
FROM users
WHERE id NOT IN (
  SELECT DISTINCT user_id FROM orders
);

-- ============================================================
-- SUBQUERY WITH COMPARISON OPERATORS
-- ============================================================

-- Find orders above the average order value
SELECT id, user_id, total_amount
FROM orders
WHERE total_amount > (SELECT AVG(total_amount) FROM orders)
ORDER BY total_amount DESC;

-- Find products that have been ordered at least once
SELECT name, price
FROM products
WHERE id IN (
  SELECT DISTINCT product_id FROM order_items
);

-- Find products that have NEVER been ordered
SELECT name, price
FROM products
WHERE id NOT IN (
  SELECT DISTINCT product_id FROM order_items
);

-- ============================================================
-- PRACTICE CHALLENGES:

-- Challenge 1: Find all orders placed by users from 'Mumbai'.
--              (Hint: subquery to get user ids from Mumbai first)

-- Challenge 2: Find users whose total spending is above
--              the average spending across all orders.
--              (Hint: subquery with SUM + AVG)

-- Challenge 3: Find the product with the highest total quantity
--              sold across all orders.
-- ============================================================
