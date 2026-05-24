-- ============================================================
-- WEEK 3 | TOPIC 2: SUM, AVG, MIN, MAX
-- ============================================================
-- These aggregate functions summarize numeric data.
--
-- SUM  → total of all values
-- AVG  → average of all values
-- MIN  → smallest value
-- MAX  → largest value
-- ROUND → clean up decimal output
-- ============================================================

USE practice_db;

-- ============================================================
-- BASIC SUM & AVG
-- ============================================================

-- Total revenue
SELECT SUM(total_amount) AS total_revenue FROM orders;

-- Average order value (messy decimals)
SELECT AVG(total_amount) AS avg_order_value FROM orders;

-- Use ROUND to clean up output
SELECT ROUND(AVG(total_amount), 2) AS avg_order_value FROM orders;
SELECT ROUND(SUM(total_amount), 0) AS total_revenue   FROM orders;

-- ============================================================
-- MIN & MAX
-- ============================================================

-- Cheapest and most expensive product
SELECT
  MIN(price) AS cheapest_product,
  MAX(price) AS most_expensive_product
FROM products;

-- Smallest and largest order
SELECT
  MIN(total_amount) AS smallest_order,
  MAX(total_amount) AS largest_order
FROM orders;

-- ============================================================
-- ALL AGGREGATES TOGETHER with GROUP BY
-- ============================================================

-- Revenue stats per order status
SELECT
  status,
  COUNT(*)                        AS total_orders,
  SUM(total_amount)               AS total_revenue,
  ROUND(AVG(total_amount), 2)     AS avg_order_value,
  MIN(total_amount)               AS min_order,
  MAX(total_amount)               AS max_order
FROM orders
GROUP BY status;

-- ============================================================
-- AGGREGATES with JOIN
-- ============================================================

-- Per customer stats — only users with orders
SELECT
  u.name                        AS customer_name,
  COUNT(o.id)                   AS total_orders,
  SUM(o.total_amount)           AS total_spent,
  ROUND(AVG(o.total_amount), 2) AS avg_order_value,
  MAX(o.total_amount)           AS biggest_order
FROM users u
INNER JOIN orders o ON u.id = o.user_id
GROUP BY u.id, u.name
HAVING COUNT(o.id) >= 1
ORDER BY total_spent DESC;

-- ============================================================
-- PRACTICE CHALLENGES:

-- Challenge 1: What is the total stock value of all products?
--              (price * stock for each product, then SUM)

-- Challenge 2: Find the average price of all products. Round to 2 decimals.

-- Challenge 3: Write a query showing per city:
--              city, total_orders, total_revenue, avg_order_value
--              Only include cities that have at least 1 order.
-- ============================================================
