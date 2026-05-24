-- ============================================================
-- WEEK 2 | TOPIC 1: INNER JOIN
-- ============================================================
-- INNER JOIN returns only the rows where there is a match
-- in BOTH tables. If a row has no match, it is excluded.
--
-- Syntax:
-- SELECT columns
-- FROM table1
-- INNER JOIN table2 ON table1.column = table2.column;
-- ============================================================

USE practice_db;

-- ============================================================
-- EXAMPLE 1: Get all orders WITH the user's name
-- Without JOIN → orders only shows user_id (a number)
-- With JOIN    → we get the actual user name
-- ============================================================

-- Without JOIN (not very useful in real apps)
SELECT * FROM orders;

-- With INNER JOIN (what real APIs return)
SELECT
  orders.id         AS order_id,
  users.name        AS customer_name,
  users.city,
  orders.total_amount,
  orders.status
FROM orders
INNER JOIN users ON orders.user_id = users.id;

-- ============================================================
-- USING ALIASES (cleaner, shorter — always do this)
-- ============================================================
SELECT
  o.id            AS order_id,
  u.name          AS customer_name,
  u.city,
  o.total_amount,
  o.status
FROM orders o
INNER JOIN users u ON o.user_id = u.id;

-- ============================================================
-- EXAMPLE 2: Get order_items WITH product names
-- ============================================================
SELECT
  oi.id           AS item_id,
  oi.order_id,
  p.name          AS product_name,
  p.price         AS unit_price,
  oi.quantity
FROM order_items oi
INNER JOIN products p ON oi.product_id = p.id;

-- ============================================================
-- EXAMPLE 3: Add a WHERE filter on top of a JOIN
-- Get all DELIVERED orders with customer names
-- ============================================================
SELECT
  u.name          AS customer_name,
  o.total_amount,
  o.status,
  o.ordered_at
FROM orders o
INNER JOIN users u ON o.user_id = u.id
WHERE o.status = 'delivered';

-- ============================================================
-- EXAMPLE 4: ORDER BY on a JOIN result
-- Get all orders sorted by total amount descending
-- ============================================================
SELECT
  u.name          AS customer_name,
  o.total_amount,
  o.status
FROM orders o
INNER JOIN users u ON o.user_id = u.id
ORDER BY o.total_amount DESC;

-- ============================================================
-- KEY POINT:
-- Karan and Meera (users with no orders) do NOT appear
-- in INNER JOIN results — because there is no matching
-- row in the orders table for them.
-- To include them, we need LEFT JOIN (next topic).
-- ============================================================
SELECT COUNT(*) AS total_users FROM users;               -- 10 users
SELECT COUNT(DISTINCT user_id) AS users_with_orders FROM orders; -- fewer than 10

-- ============================================================
-- PRACTICE CHALLENGES:

-- Challenge 1: Get all orders (order_id, customer name, total_amount)
--              for users from 'Mumbai' only

-- Challenge 2: Get all order_items (item_id, product name, quantity, unit_price)
--              where quantity > 1

-- Challenge 3: Get a list of all orders with customer name and their city,
--              sorted by ordered_at DESC (most recent first)
-- ============================================================
