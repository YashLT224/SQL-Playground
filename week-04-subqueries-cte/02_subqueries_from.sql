-- ============================================================
-- WEEK 4 | TOPIC 2: SUBQUERIES IN FROM
-- ============================================================
-- A subquery in FROM creates a temporary table (inline view).
-- You MUST give it an alias — MySQL requires it.
--
-- Syntax:
--   SELECT ... FROM (SELECT ... FROM table) AS alias
--   WHERE alias.column ...
-- ============================================================

USE practice_db;

-- ============================================================
-- BASIC SUBQUERY IN FROM
-- ============================================================

-- Step 1 inner: calculate total revenue per product
SELECT product_id, SUM(quantity * unit_price) AS total_revenue
FROM order_items
GROUP BY product_id;

-- Step 2 outer: use that result as a table, sort it
SELECT *
FROM (
  SELECT product_id, SUM(quantity * unit_price) AS total_revenue
  FROM order_items
  GROUP BY product_id
) AS product_revenue
ORDER BY total_revenue DESC;

-- ============================================================
-- SUBQUERY IN FROM + JOIN
-- ============================================================

-- Join with products table to get product name
SELECT p.name AS product_name, pr.total_revenue
FROM (
  SELECT product_id, SUM(quantity * unit_price) AS total_revenue
  FROM order_items
  GROUP BY product_id
) AS pr
JOIN products p ON pr.product_id = p.id
ORDER BY pr.total_revenue DESC;

-- ============================================================
-- USER SPENDING SUMMARY
-- ============================================================

-- Get total spent per user, then show only high spenders
SELECT *
FROM (
  SELECT user_id, SUM(total_amount) AS total_spent
  FROM orders
  GROUP BY user_id
) AS spending
WHERE spending.total_spent > 500
ORDER BY total_spent DESC;

-- ============================================================
-- ORDER BY total_revenue vs ORDER BY product_revenue.total_revenue
-- ============================================================
-- Both work in MySQL for subquery aliases — MySQL resolves
-- the alias name in ORDER BY automatically.
-- But qualifying with the alias (product_revenue.total_revenue)
-- is more explicit and readable.

-- Short form — works in MySQL
SELECT *
FROM (
  SELECT product_id, SUM(quantity * unit_price) AS total_revenue
  FROM order_items
  GROUP BY product_id
) AS product_revenue
ORDER BY total_revenue ASC;

-- Explicit form — same result, clearer intent
SELECT *
FROM (
  SELECT product_id, SUM(quantity * unit_price) AS total_revenue
  FROM order_items
  GROUP BY product_id
) AS product_revenue
ORDER BY product_revenue.total_revenue ASC;

-- ============================================================
-- PRACTICE CHALLENGES:

-- Challenge 1: Write a subquery in FROM that calculates
--              total orders per user (user_id, total_orders).
--              Then SELECT only users with more than 1 order.

-- Challenge 2: Write a subquery in FROM that calculates
--              average order value per city.
--              Join with users to get city name.

-- Challenge 3: Find the top 3 products by revenue using
--              a subquery in FROM. LIMIT 3.
-- ============================================================
