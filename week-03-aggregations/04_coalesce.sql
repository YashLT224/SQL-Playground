-- ============================================================
-- WEEK 3 | TOPIC 4: COALESCE
-- ============================================================
-- COALESCE returns the FIRST non-NULL value from a list.
-- Used to replace NULLs with a meaningful default value.
--
-- COALESCE(value, fallback)
-- → if value is NULL    → return fallback
-- → if value is NOT NULL → return value as-is
-- ============================================================

USE practice_db;

-- ============================================================
-- THE NULL PROBLEM (without COALESCE)
-- ============================================================

-- Users with no orders show NULL for SUM — looks broken
SELECT
  u.name,
  SUM(o.total_amount) AS total_spent
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
GROUP BY u.id, u.name;

-- ============================================================
-- FIX WITH COALESCE
-- ============================================================

-- Replace NULL with 0
SELECT
  u.name,
  COALESCE(SUM(o.total_amount), 0) AS total_spent
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
GROUP BY u.id, u.name;

-- ============================================================
-- COALESCE with text fallback
-- ============================================================

-- Replace NULL city with 'City not set'
SELECT
  u.name,
  COALESCE(u.city, 'City not set') AS city
FROM users u;

-- ============================================================
-- FULL CUSTOMER REPORT using COALESCE
-- ============================================================

SELECT
  u.name,
  COALESCE(u.city, 'City not set')   AS city,
  COALESCE(SUM(o.total_amount), 0)   AS total_spent,
  COUNT(o.id)                        AS total_orders
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
GROUP BY u.id, u.name, u.city
ORDER BY total_spent DESC;

-- ============================================================
-- COALESCE with multiple fallbacks
-- Returns first non-NULL value in the list
-- ============================================================

-- Try mobile first, then phone, then 'No contact'
-- SELECT COALESCE(mobile, phone, 'No contact') AS contact FROM users;

-- ============================================================
-- RULE: Always wrap SUM, AVG, MIN, MAX with COALESCE
-- when using LEFT JOIN — NULLs will appear for unmatched rows
-- ============================================================

-- ============================================================
-- PRACTICE CHALLENGES:

-- Challenge 1: Show all users with their total_spent.
--              Users with no orders should show 0, not NULL.
--              Sort by total_spent DESC.

-- Challenge 2: Show all products with total quantity ordered.
--              Products never ordered should show 0.
--              (Hint: LEFT JOIN order_items, COALESCE SUM)

-- Challenge 3: Show customer report with:
--              name, city, total_orders, total_spent, avg_order_value
--              All NULLs replaced with 0 or 'N/A'
-- ============================================================
