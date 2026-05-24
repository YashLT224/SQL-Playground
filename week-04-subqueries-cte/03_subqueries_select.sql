-- ============================================================
-- WEEK 4 | TOPIC 3: SUBQUERIES IN SELECT
-- ============================================================
-- A subquery in SELECT runs once per row and returns a
-- single value — called a SCALAR subquery.
--
-- Use case: add a calculated column without GROUP BY.
--
-- Syntax:
--   SELECT column, (SELECT aggregate FROM table WHERE condition) AS alias
--   FROM main_table;
-- ============================================================

USE practice_db;

-- ============================================================
-- SCALAR SUBQUERY — single value per row
-- ============================================================

-- Show each product with the overall average price alongside
SELECT
  name,
  price,
  (SELECT ROUND(AVG(price), 2) FROM products) AS avg_price
FROM products;

-- ============================================================
-- COMPARE EACH ROW TO THE AVERAGE
-- ============================================================

-- Show each order with average order value for reference
SELECT
  id AS order_id,
  user_id,
  total_amount,
  (SELECT ROUND(AVG(total_amount), 2) FROM orders) AS avg_order_value
FROM orders
ORDER BY total_amount DESC;

-- ============================================================
-- CORRELATED SCALAR SUBQUERY
-- ============================================================
-- A correlated subquery references the outer query's row.
-- It runs once per row in the outer query.

-- Show each user with their personal total spending
SELECT
  u.name,
  u.city,
  (
    SELECT COALESCE(SUM(o.total_amount), 0)
    FROM orders o
    WHERE o.user_id = u.id   -- references outer row
  ) AS total_spent
FROM users u
ORDER BY total_spent DESC;

-- ============================================================
-- SUBQUERY IN SELECT + IN WHERE together
-- ============================================================

-- Products with price above average — two approaches:

-- Approach 1: Subquery in WHERE
SELECT name, price
FROM products
WHERE price > (SELECT AVG(price) FROM products);

-- Approach 2: Subquery in SELECT (shows avg for reference)
SELECT
  name,
  price,
  (SELECT ROUND(AVG(price), 2) FROM products) AS avg_price,
  price - (SELECT AVG(price) FROM products) AS diff_from_avg
FROM products
WHERE price > (SELECT AVG(price) FROM products);

-- ============================================================
-- KEY RULE: Scalar subquery must return exactly ONE value.
-- If it returns multiple rows → MySQL throws an error.
-- ============================================================

-- ============================================================
-- PRACTICE CHALLENGES:

-- Challenge 1: Show each order with:
--              order id, total_amount, and the MAX order amount
--              as a reference column.

-- Challenge 2: Show each user with their name, city,
--              and count of their total orders as a column.
--              (Correlated subquery in SELECT)

-- Challenge 3: Show each product with its name, price,
--              and a column showing how much above/below
--              average its price is.
-- ============================================================
