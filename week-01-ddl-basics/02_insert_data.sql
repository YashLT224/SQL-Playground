-- ============================================================
-- WEEK 1 | TOPIC 2: INSERT DATA (DML)
-- ============================================================
-- DML = Data Manipulation Language
-- These commands work with the actual DATA inside your tables.
-- INSERT puts data in. SELECT reads it. UPDATE changes it. DELETE removes it.
-- ============================================================

USE practice_db;

-- ============================================================
-- INSERT SYNTAX:
-- INSERT INTO table_name (col1, col2) VALUES (val1, val2);
-- You don't need to pass id or created_at — MySQL fills those.
-- ============================================================

-- Insert a single user
INSERT INTO users (name, email, age, city)
VALUES ('Yash Verma', 'yash@example.com', 26, 'Mumbai');

-- Insert multiple users at once (more efficient than one by one)
INSERT INTO users (name, email, age, city) VALUES
  ('Priya Sharma',  'priya@example.com',  24, 'Delhi'),
  ('Rahul Gupta',   'rahul@example.com',  30, 'Bangalore'),
  ('Ananya Singh',  'ananya@example.com', 28, 'Mumbai'),
  ('Vikram Nair',   'vikram@example.com', 35, 'Chennai'),
  ('Sneha Patil',   'sneha@example.com',  22, 'Pune'),
  ('Arjun Mehta',   'arjun@example.com',  31, 'Delhi'),
  ('Nisha Reddy',   'nisha@example.com',  27, 'Bangalore');

-- Insert products
INSERT INTO products (name, description, price, stock) VALUES
  ('Mechanical Keyboard', 'RGB backlit, TKL layout',     3499.00, 50),
  ('Wireless Mouse',      'Ergonomic, 3 months battery', 1299.00, 120),
  ('USB-C Hub',           '7-in-1 multiport adapter',    1899.00, 75),
  ('Monitor Stand',       'Adjustable height, bamboo',   2199.00, 30),
  ('Webcam HD',           '1080p with built-in mic',     2499.00, 45);

-- Insert orders (user_id references users.id)
INSERT INTO orders (user_id, total_amount, status) VALUES
  (1, 3499.00, 'delivered'),
  (2, 1299.00, 'shipped'),
  (3, 4398.00, 'pending'),
  (1, 1899.00, 'delivered'),
  (4, 2499.00, 'pending'),
  (5, 2199.00, 'shipped'),
  (2, 3499.00, 'delivered'),
  (3, 1299.00, 'pending');

-- ============================================================
-- VERIFY: Check if data was inserted
-- ============================================================
SELECT * FROM users;
SELECT * FROM products;
SELECT * FROM orders;

-- ============================================================
-- PRACTICE CHALLENGE 1:
-- Insert 2 more users of your own choice with city = 'Hyderabad'
-- Then verify by running: SELECT * FROM users WHERE city = 'Hyderabad';
-- ============================================================
