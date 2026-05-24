-- ============================================================
-- WEEK 2 | SETUP: Extended Data for JOIN Practice
-- ============================================================
-- We need richer data to see JOINs in action.
-- This file adds an order_items table (links orders to products)
-- and inserts more rows so JOIN results are meaningful.
-- ============================================================

USE practice_db;

-- ============================================================
-- NEW TABLE: order_items
-- This is the junction table between orders and products.
-- One order can have many products — that's a Many-to-Many relationship.
-- ============================================================
CREATE TABLE IF NOT EXISTS order_items (
  id         INT AUTO_INCREMENT PRIMARY KEY,
  order_id   INT NOT NULL,       -- references orders.id
  product_id INT NOT NULL,       -- references products.id
  quantity   INT DEFAULT 1,
  unit_price DECIMAL(10, 2) NOT NULL
);

-- ============================================================
-- Insert order_items (connecting orders to products)
-- ============================================================
INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
  (1, 1, 1, 3499.00),   -- order 1 → Mechanical Keyboard
  (2, 2, 1, 1299.00),   -- order 2 → Wireless Mouse
  (3, 1, 1, 3499.00),   -- order 3 → Mechanical Keyboard
  (3, 3, 1, 1899.00),   -- order 3 → USB-C Hub (same order, 2 products!)
  (4, 5, 1, 2499.00),   -- order 4 → Webcam HD
  (5, 4, 1, 2199.00),   -- order 5 → Monitor Stand
  (6, 2, 2, 1299.00),   -- order 6 → 2x Wireless Mouse
  (7, 1, 1, 3499.00),   -- order 7 → Mechanical Keyboard
  (8, 2, 1, 1299.00);   -- order 8 → Wireless Mouse

-- ============================================================
-- Add some extra users with NO orders (important for LEFT JOIN demo)
-- ============================================================
INSERT INTO users (name, email, age, city) VALUES
  ('Karan Malhotra', 'karan@example.com', 29, 'Jaipur'),
  ('Meera Iyer',     'meera@example.com', 33, 'Kochi');

-- ============================================================
-- VERIFY all tables have data
-- ============================================================
SELECT 'users'       AS table_name, COUNT(*) AS row_count FROM users
UNION ALL
SELECT 'products',     COUNT(*) FROM products
UNION ALL
SELECT 'orders',       COUNT(*) FROM orders
UNION ALL
SELECT 'order_items',  COUNT(*) FROM order_items;
