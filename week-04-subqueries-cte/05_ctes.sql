-- ============================================================
-- WEEK 4 | TOPIC 5: CTEs (Common Table Expressions)
-- ============================================================
-- A CTE is a temporary named result set defined at the top
-- of a query using the WITH keyword.
--
-- Think of it as giving a name to a subquery so you can
-- reference it cleanly — like a variable for a query.
--
-- Syntax:
--   WITH cte_name AS (
--     SELECT ...
--   )
--   SELECT * FROM cte_name;
-- ============================================================

USE practice_db;

-- ============================================================
-- BASIC CTE
-- ============================================================

-- Total spent per user
WITH user_spending AS (
  SELECT user_id, SUM(total_amount) AS total_spent
  FROM orders
  GROUP BY user_id
)
SELECT * FROM user_spending
ORDER BY total_spent DESC;

-- ============================================================
-- CTE + JOIN — enrich with user details
-- ============================================================

WITH user_spending AS (
  SELECT user_id, SUM(total_amount) AS total_spent
  FROM orders
  GROUP BY user_id
)
SELECT
  u.name,
  u.city,
  COALESCE(s.total_spent, 0) AS total_spent
FROM users u
LEFT JOIN user_spending s ON u.id = s.user_id
ORDER BY total_spent DESC;

-- ============================================================
-- CTE WITH FILTER
-- ============================================================

-- High value customers (spent > 500)
WITH user_spending AS (
  SELECT user_id, SUM(total_amount) AS total_spent
  FROM orders
  GROUP BY user_id
)
SELECT *
FROM user_spending
WHERE total_spent > 500
ORDER BY total_spent DESC;

-- ============================================================
-- MULTIPLE CHAINED CTEs
-- ============================================================

-- Step 1: order_totals — orders + counts per user
-- Step 2: high_value — filter to high spenders
-- Final: get their name + email

WITH
  order_totals AS (
    SELECT user_id, COUNT(*) AS total_orders, SUM(total_amount) AS total_spent
    FROM orders
    GROUP BY user_id
  ),
  high_value AS (
    SELECT user_id FROM order_totals
    WHERE total_spent > 500
  )
SELECT u.name, u.email
FROM users u
WHERE u.id IN (SELECT user_id FROM high_value);

-- ============================================================
-- CHALLENGE 1: city_revenue
-- ============================================================

WITH city_revenue AS (
  SELECT
    u.city,
    SUM(o.total_amount) AS total_revenue
  FROM users u
  INNER JOIN orders o ON u.id = o.user_id
  GROUP BY u.city
)
SELECT city, total_revenue
FROM city_revenue
WHERE total_revenue > 1000;

-- ============================================================
-- CHALLENGE 2: product_sales + top_products
-- ============================================================

WITH
  product_sales AS (
    SELECT oi.product_id, SUM(oi.quantity) AS total_qty_sold
    FROM order_items oi
    GROUP BY oi.product_id
  ),
  top_products AS (
    SELECT product_id, total_qty_sold
    FROM product_sales
    WHERE total_qty_sold > 2
  )
SELECT
  p.name AS product_name,
  tp.total_qty_sold
FROM top_products tp
INNER JOIN products p ON tp.product_id = p.id;

-- ============================================================
-- CHALLENGE 3: Rewrite subquery as CTE
-- ============================================================

-- Original subquery version
SELECT u.name, sub.total_orders
FROM users u
JOIN (
  SELECT user_id, COUNT(*) AS total_orders
  FROM orders
  GROUP BY user_id
) AS sub ON u.id = sub.user_id;

-- CTE version (same result, cleaner)
WITH user_order_counts AS (
  SELECT user_id, COUNT(*) AS total_orders
  FROM orders
  GROUP BY user_id
)
SELECT u.name, uoc.total_orders
FROM users u
INNER JOIN user_order_counts uoc ON u.id = uoc.user_id;

-- ============================================================
-- CTE vs SUBQUERY — when to use which
-- ============================================================
-- Subquery → simple, one-time use
-- CTE      → complex, multi-step, or reused logic
--
-- Both produce identical results.
-- CTEs are preferred for readability in real production code.
-- ============================================================
