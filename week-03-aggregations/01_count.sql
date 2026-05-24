-- ============================================================
-- WEEK 3 | TOPIC 1: COUNT
-- ============================================================
-- COUNT is the most used aggregate function.
-- It counts the number of rows in a result.
--
-- COUNT(*)       → counts ALL rows including NULLs
-- COUNT(column)  → counts only NON-NULL values in that column
-- ============================================================

USE practice_db;

-- ============================================================
-- BASIC COUNT
-- ============================================================

SELECT COUNT(*) AS total_users    FROM users;
SELECT COUNT(*) AS total_products FROM products;
SELECT COUNT(*) AS total_orders   FROM orders;

-- ============================================================
-- COUNT with WHERE filter
-- ============================================================

-- How many pending orders?
SELECT COUNT(*) AS pending_orders
FROM orders
WHERE status = 'pending';

-- How many users from Mumbai?
SELECT COUNT(*) AS mumbai_users
FROM users
WHERE city = 'mumbai';

-- How many active users?
SELECT COUNT(*) AS active_users
FROM users
WHERE is_active = 1;

-- ============================================================
-- COUNT with GROUP BY (per group)
-- ============================================================

-- How many orders per status?
SELECT
  status,
  COUNT(*) AS total
FROM orders
GROUP BY status;

-- How many users per city?
SELECT
  city,
  COUNT(*) AS total_users
FROM users
GROUP BY city
ORDER BY total_users DESC;

-- ============================================================
-- COUNT DISTINCT — count unique values
-- ============================================================

-- How many unique cities do users come from?
SELECT COUNT(DISTINCT city) AS unique_cities FROM users;

-- How many unique users have placed orders?
SELECT COUNT(DISTINCT user_id) AS unique_customers FROM orders;

-- How many unique products have been ordered?
SELECT COUNT(DISTINCT product_id) AS unique_products FROM order_items;

-- ============================================================
-- COUNT(column) vs COUNT(*) — the NULL difference
-- ============================================================

-- COUNT(*) counts all rows including NULLs → use for total rows
-- COUNT(o.id) skips NULLs → use when counting from a JOINed table

SELECT
  u.name,
  COUNT(*)    AS count_star,     -- includes NULL rows (wrong for 0 orders!)
  COUNT(o.id) AS count_column    -- skips NULLs (correctly shows 0)
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
GROUP BY u.id, u.name;

-- ============================================================
-- PRACTICE CHALLENGES:

-- Challenge 1: How many orders have status = 'delivered'?
-- Challenge 2: How many users are from 'Jaipur' or 'Kochi'? (single count)
-- Challenge 3: How many orders exist per status? (one row per status)
-- ============================================================
