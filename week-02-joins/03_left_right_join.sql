-- ============================================================
-- WEEK 2 | TOPIC 2: LEFT JOIN & RIGHT JOIN
-- ============================================================
-- LEFT JOIN  → All rows from LEFT table + matching rows from right.
--              If no match on right side → NULL is shown.
--
-- RIGHT JOIN → All rows from RIGHT table + matching rows from left.
--              If no match on left side → NULL is shown.
--
-- Rule of thumb: LEFT JOIN is used 90% of the time in real apps.
-- RIGHT JOIN can always be rewritten as a LEFT JOIN by swapping tables.
-- ============================================================

USE practice_db;

-- ============================================================
-- LEFT JOIN EXAMPLE 1:
-- Get ALL users, even those who have never placed an order
-- ============================================================
SELECT
  u.name          AS customer_name,
  u.city,
  o.id            AS order_id,
  o.total_amount,
  o.status
FROM users u
LEFT JOIN orders o ON u.id = o.user_id;

-- Notice: Karan and Meera show up with NULL in order columns
-- because they have no orders. INNER JOIN would have excluded them.

-- ============================================================
-- LEFT JOIN EXAMPLE 2:
-- Find users who have NEVER placed an order
-- (Filter where the right side is NULL)
-- ============================================================
SELECT
  u.name    AS customer_name,
  u.city,
  u.email
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
WHERE o.id IS NULL;

-- This is a very common real-world query!
-- "Show me users who haven't purchased yet" → marketing re-engagement

-- ============================================================
-- LEFT JOIN EXAMPLE 3:
-- Count how many orders each user has placed (including 0)
-- ============================================================
SELECT
  u.name              AS customer_name,
  COUNT(o.id)         AS total_orders,
  SUM(o.total_amount) AS total_spent
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
GROUP BY u.id, u.name
ORDER BY total_orders DESC;

-- ============================================================
-- LEFT JOIN EXAMPLE 4:
-- Get all products and show if they have been ordered or not
-- ============================================================
SELECT
  p.name          AS product_name,
  p.price,
  oi.order_id,
  oi.quantity
FROM products p
LEFT JOIN order_items oi ON p.id = oi.product_id;

-- ============================================================
-- Find products that have NEVER been ordered
-- ============================================================
SELECT
  p.name    AS product_name,
  p.price
FROM products p
LEFT JOIN order_items oi ON p.id = oi.product_id
WHERE oi.id IS NULL;

-- ============================================================
-- RIGHT JOIN EXAMPLE:
-- Same as LEFT JOIN but tables are flipped
-- Get all orders and their users (even if user somehow missing)
-- ============================================================
SELECT
  u.name          AS customer_name,
  o.id            AS order_id,
  o.total_amount,
  o.status
FROM users u
RIGHT JOIN orders o ON u.id = o.user_id;

-- This is equivalent to:
SELECT
  u.name          AS customer_name,
  o.id            AS order_id,
  o.total_amount,
  o.status
FROM orders o
LEFT JOIN users u ON o.user_id = u.id;

-- ============================================================
-- INNER vs LEFT — side by side comparison
-- ============================================================

-- INNER JOIN: only users WHO HAVE orders
SELECT u.name, o.total_amount
FROM users u
INNER JOIN orders o ON u.id = o.user_id;

-- LEFT JOIN: ALL users, NULL if no orders
SELECT u.name, o.total_amount
FROM users u
LEFT JOIN orders o ON u.id = o.user_id;

-- ============================================================
-- PRACTICE CHALLENGES:

-- Challenge 1: Find all users who have NOT placed any orders.
--              Show their name, email and city.

-- Challenge 2: Get ALL products with their total quantity ordered.
--              Products never ordered should show 0, not NULL.
--              (Hint: Use COALESCE(SUM(oi.quantity), 0))

-- Challenge 3: List all users with their total number of orders.
--              Show 0 for users with no orders.
--              Sort by total orders DESC.
-- ============================================================
