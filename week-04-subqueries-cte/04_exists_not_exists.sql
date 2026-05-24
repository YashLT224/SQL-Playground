-- ============================================================
-- WEEK 4 | TOPIC 4: EXISTS & NOT EXISTS
-- ============================================================
-- EXISTS checks whether a subquery returns ANY rows.
-- It returns TRUE (row included) or FALSE (row excluded).
--
-- EXISTS stops as soon as it finds ONE matching row — fast!
-- SELECT 1 is used as a placeholder: we don't need data,
-- just confirmation that a row exists.
--
-- Syntax:
--   SELECT ... FROM table
--   WHERE EXISTS (SELECT 1 FROM other_table WHERE condition);
-- ============================================================

USE practice_db;

-- ============================================================
-- EXISTS — users who have placed at least one order
-- ============================================================

SELECT u.name, u.email
FROM users u
WHERE EXISTS (
  SELECT 1
  FROM orders o
  WHERE o.user_id = u.id   -- correlated: references outer row
);

-- ============================================================
-- NOT EXISTS — users who have NEVER placed an order
-- ============================================================

SELECT u.name, u.email
FROM users u
WHERE NOT EXISTS (
  SELECT 1
  FROM orders o
  WHERE o.user_id = u.id
);

-- ============================================================
-- EXISTS vs IN — same result, different approach
-- ============================================================

-- Using IN
SELECT name, email FROM users
WHERE id IN (SELECT DISTINCT user_id FROM orders);

-- Using EXISTS (preferred for large datasets — stops early)
SELECT name, email FROM users u
WHERE EXISTS (SELECT 1 FROM orders o WHERE o.user_id = u.id);

-- ============================================================
-- EXISTS with additional conditions
-- ============================================================

-- Users who have at least one DELIVERED order
SELECT u.name, u.email
FROM users u
WHERE EXISTS (
  SELECT 1
  FROM orders o
  WHERE o.user_id = u.id
    AND o.status = 'delivered'
);

-- Users who have at least one order above 500
SELECT u.name
FROM users u
WHERE EXISTS (
  SELECT 1
  FROM orders o
  WHERE o.user_id = u.id
    AND o.total_amount > 500
);

-- ============================================================
-- Products that HAVE been ordered (appear in order_items)
-- ============================================================

SELECT p.name, p.price
FROM products p
WHERE EXISTS (
  SELECT 1
  FROM order_items oi
  WHERE oi.product_id = p.id
);

-- Products that have NEVER been ordered
SELECT p.name, p.price
FROM products p
WHERE NOT EXISTS (
  SELECT 1
  FROM order_items oi
  WHERE oi.product_id = p.id
);

-- ============================================================
-- WHAT IS SELECT 1?
-- EXISTS only needs to know: does a row exist?
-- It does NOT need actual column values.
-- SELECT 1 returns a dummy value (the number 1) per row —
-- no column fetching needed → more efficient.
--
-- SELECT *   → fetches all columns (wasteful in EXISTS)
-- SELECT 1   → returns dummy 1, no column data needed ✅
-- Both work, but SELECT 1 is the convention.
-- ============================================================

-- ============================================================
-- PRACTICE CHALLENGES:

-- Challenge 1: Find all products that appear in at least
--              one order (use EXISTS).

-- Challenge 2: Find all users who have placed an order
--              with status = 'pending' (use EXISTS).

-- Challenge 3: Find products that have NEVER been ordered
--              (use NOT EXISTS). Compare result with NOT IN version.
-- ============================================================
