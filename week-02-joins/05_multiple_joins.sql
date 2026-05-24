-- ============================================================
-- WEEK 2 | TOPIC 4: JOINING 3+ TABLES
-- ============================================================
-- Real API queries almost always join 3 or more tables.
-- You just chain JOIN statements one after another.
--
-- Syntax:
-- SELECT ...
-- FROM table1
-- JOIN table2 ON ...
-- JOIN table3 ON ...
-- JOIN table4 ON ...
-- ============================================================

USE practice_db;

-- ============================================================
-- EXAMPLE 1: The "full order details" query
-- Connect users → orders → order_items → products
-- This is a very common real-world API query
-- ============================================================
SELECT
  u.name          AS customer_name,
  u.city,
  o.id            AS order_id,
  o.status        AS order_status,
  p.name          AS product_name,
  oi.quantity,
  oi.unit_price,
  (oi.quantity * oi.unit_price) AS line_total
FROM orders o
INNER JOIN users       u  ON o.user_id       = u.id
INNER JOIN order_items oi ON o.id            = oi.order_id
INNER JOIN products    p  ON oi.product_id   = p.id
ORDER BY o.id, p.name;

-- ============================================================
-- EXAMPLE 2: Sales summary per customer
-- Total amount spent and number of products ordered per user
-- ============================================================
SELECT
  u.name                            AS customer_name,
  u.city,
  COUNT(DISTINCT o.id)              AS total_orders,
  COUNT(oi.id)                      AS total_items,
  SUM(oi.quantity * oi.unit_price)  AS total_spent
FROM users u
LEFT JOIN orders       o  ON u.id  = o.user_id
LEFT JOIN order_items  oi ON o.id  = oi.order_id
GROUP BY u.id, u.name, u.city
ORDER BY total_spent DESC;

-- ============================================================
-- EXAMPLE 3: Most popular products (by quantity ordered)
-- ============================================================
SELECT
  p.name                  AS product_name,
  p.price,
  COUNT(oi.id)            AS times_ordered,
  SUM(oi.quantity)        AS total_qty_sold,
  SUM(oi.quantity * oi.unit_price) AS total_revenue
FROM products p
LEFT JOIN order_items oi ON p.id = oi.product_id
GROUP BY p.id, p.name, p.price
ORDER BY total_qty_sold DESC;

-- ============================================================
-- EXAMPLE 4: Orders with full details filtered by city
-- "Show all orders placed by users from Mumbai"
-- ============================================================
SELECT
  u.name          AS customer_name,
  o.id            AS order_id,
  p.name          AS product_name,
  oi.quantity,
  o.status
FROM orders o
INNER JOIN users       u  ON o.user_id     = u.id
INNER JOIN order_items oi ON o.id          = oi.order_id
INNER JOIN products    p  ON oi.product_id = p.id
WHERE u.city = 'Mumbai'
ORDER BY o.id;

-- ============================================================
-- EXAMPLE 5: Mix LEFT JOIN and INNER JOIN in the same query
-- All users + their orders + product details if available
-- ============================================================
SELECT
  u.name          AS customer_name,
  o.id            AS order_id,
  o.status,
  p.name          AS product_name
FROM users u
LEFT JOIN orders       o  ON u.id          = o.user_id
LEFT JOIN order_items  oi ON o.id          = oi.order_id
LEFT JOIN products     p  ON oi.product_id = p.id
ORDER BY u.name;

-- ============================================================
-- TIPS FOR MULTI-TABLE JOINS:
-- 1. Always alias your tables (u, o, p, oi) — keeps it readable
-- 2. Build it step by step — start with 2 tables, add one at a time
-- 3. Always check row counts — unexpected duplicates = missing GROUP BY
-- 4. Use LEFT JOIN when any table might not have matching rows
-- ============================================================

-- ============================================================
-- PRACTICE CHALLENGES:

-- Challenge 1: Get a full receipt for order_id = 3.
--              Show: customer name, product name, quantity, unit_price, line_total

-- Challenge 2: Find the top 3 customers by total amount spent.
--              Show: customer name, city, total_spent

-- Challenge 3: Find all products that have been ordered by users from 'Delhi'.
--              Show: product name, customer name, quantity, order status
-- ============================================================
