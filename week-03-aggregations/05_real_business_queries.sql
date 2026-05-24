-- ============================================================
-- WEEK 3 | TOPIC 5: REAL BUSINESS QUERIES
-- ============================================================
-- Putting it all together — the kind of queries you'll write
-- every day as a backend developer.
-- ============================================================

USE practice_db;

-- ============================================================
-- BUSINESS QUERY 1: Revenue Dashboard
-- ============================================================
SELECT
  COUNT(*)                        AS total_orders,
  SUM(total_amount)               AS total_revenue,
  ROUND(AVG(total_amount), 2)     AS avg_order_value,
  MIN(total_amount)               AS smallest_order,
  MAX(total_amount)               AS largest_order
FROM orders;

-- ============================================================
-- BUSINESS QUERY 2: Revenue by Order Status
-- ============================================================
SELECT
  status,
  COUNT(*)                        AS total_orders,
  SUM(total_amount)               AS total_revenue,
  ROUND(AVG(total_amount), 2)     AS avg_order_value
FROM orders
GROUP BY status
ORDER BY total_revenue DESC;

-- ============================================================
-- BUSINESS QUERY 3: Top Customers by Spending
-- ============================================================
SELECT
  u.name                          AS customer_name,
  u.city,
  COUNT(o.id)                     AS total_orders,
  COALESCE(SUM(o.total_amount), 0) AS total_spent,
  ROUND(COALESCE(AVG(o.total_amount), 0), 2) AS avg_order_value
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
GROUP BY u.id, u.name, u.city
ORDER BY total_spent DESC;

-- ============================================================
-- BUSINESS QUERY 4: Top Selling Products
-- ============================================================
SELECT
  p.name                          AS product_name,
  p.price,
  COALESCE(SUM(oi.quantity), 0)   AS total_qty_sold,
  COALESCE(SUM(oi.quantity * oi.unit_price), 0) AS total_revenue
FROM products p
LEFT JOIN order_items oi ON p.id = oi.product_id
GROUP BY p.id, p.name, p.price
ORDER BY total_qty_sold DESC;

-- ============================================================
-- BUSINESS QUERY 5: City-wise Sales Report
-- ============================================================
SELECT
  u.city,
  COUNT(DISTINCT u.id)            AS total_customers,
  COUNT(o.id)                     AS total_orders,
  COALESCE(SUM(o.total_amount), 0) AS total_revenue
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
GROUP BY u.city
ORDER BY total_revenue DESC;

-- ============================================================
-- BUSINESS QUERY 6: Customers with no orders (re-engagement list)
-- ============================================================
SELECT
  u.name    AS customer_name,
  u.email,
  u.city
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
WHERE o.id IS NULL;

-- ============================================================
-- BUSINESS QUERY 7: High value customers (spent > 500)
-- ============================================================
SELECT
  u.name                          AS customer_name,
  COUNT(o.id)                     AS total_orders,
  SUM(o.total_amount)             AS total_spent
FROM users u
INNER JOIN orders o ON u.id = o.user_id
GROUP BY u.id, u.name
HAVING SUM(o.total_amount) > 500
ORDER BY total_spent DESC;
