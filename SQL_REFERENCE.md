# SQL Complete Reference Guide

**Author:** Yash Verma
**Database:** MySQL
**Purpose:** Quick reference for every SQL command — from basics to advanced

---

## Table of Contents

1. [Database Commands](#1-database-commands)
2. [Table Commands](#2-table-commands)
3. [Constraints](#3-constraints)
4. [INSERT — Adding Data](#4-insert--adding-data)
5. [SELECT — Reading Data](#5-select--reading-data)
6. [Filtering — WHERE Clause](#6-filtering--where-clause)
7. [Sorting & Pagination](#7-sorting--pagination)
8. [UPDATE — Modifying Data](#8-update--modifying-data)
9. [DELETE — Removing Data](#9-delete--removing-data)
10. [JOINs](#10-joins)
11. [Aggregations](#11-aggregations)
12. [Subqueries](#12-subqueries)
13. [CTEs (WITH clause)](#13-ctes-with-clause)
14. [Indexes](#14-indexes)
15. [EXPLAIN — Query Analysis](#15-explain--query-analysis)
16. [Transactions](#16-transactions)
17. [Inspection Queries](#17-inspection-queries)
18. [ALTER TABLE](#18-alter-table)

---

## 1. Database Commands

```sql
-- Create a database
CREATE DATABASE shop_db;

-- Use a database (switch to it)
USE shop_db;

-- List all databases
SHOW DATABASES;

-- See which database you're currently in
SELECT DATABASE();

-- Delete a database (permanent!)
DROP DATABASE shop_db;
```

---

## 2. Table Commands

```sql
-- Create a table
CREATE TABLE users (
  id         INT PRIMARY KEY AUTO_INCREMENT,
  name       VARCHAR(100) NOT NULL,
  email      VARCHAR(255) UNIQUE NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- List all tables in current database
SHOW TABLES;

-- See column details of a table
DESC users;
-- or
DESCRIBE users;

-- See the full CREATE TABLE statement
SHOW CREATE TABLE users;

-- Delete a table (permanent!)
DROP TABLE users;

-- Delete all rows but keep the table structure
TRUNCATE TABLE users;

-- Check if table exists before dropping
DROP TABLE IF EXISTS users;
```

---

## 3. Constraints

```sql
CREATE TABLE products (
  id          INT PRIMARY KEY AUTO_INCREMENT,  -- unique, never null, auto-generated
  name        VARCHAR(255) NOT NULL,            -- cannot be empty
  price       DECIMAL(10,2) NOT NULL,
  stock       INT DEFAULT 0,                    -- default value if not provided
  email       VARCHAR(255) UNIQUE,              -- no duplicates allowed
  category_id INT,
  CHECK (price > 0),                            -- custom rule
  CHECK (stock >= 0),
  FOREIGN KEY (category_id) REFERENCES categories(id)  -- referential integrity
);
```

| Constraint | Purpose |
|-----------|---------|
| `PRIMARY KEY` | Unique identifier, never null, one per table |
| `NOT NULL` | Column must always have a value |
| `UNIQUE` | No two rows can have the same value (nulls allowed) |
| `DEFAULT` | Value used when column is not provided |
| `CHECK` | Custom rule the value must satisfy |
| `FOREIGN KEY` | Links to another table's primary key |
| `AUTO_INCREMENT` | MySQL auto-generates the next number |

---

## 4. INSERT — Adding Data

```sql
-- Insert one row
INSERT INTO users (name, email) VALUES ('Yash', 'yash@gmail.com');

-- Insert multiple rows at once
INSERT INTO users (name, email) VALUES
  ('Yash',  'yash@gmail.com'),
  ('Rahul', 'rahul@gmail.com'),
  ('Priya', 'priya@gmail.com');

-- Insert with all columns (must match table column order)
INSERT INTO users VALUES (1, 'Yash', 'yash@gmail.com', NOW());

-- Get the id of the last inserted row
SELECT LAST_INSERT_ID();
```

---

## 5. SELECT — Reading Data

```sql
-- Select all columns
SELECT * FROM users;

-- Select specific columns
SELECT name, email FROM users;

-- Select with alias (rename column in output)
SELECT name AS user_name, email AS user_email FROM users;

-- Select distinct values (no duplicates)
SELECT DISTINCT city FROM users;

-- Select with calculation
SELECT name, price, price * 1.18 AS price_with_gst FROM products;

-- Select a fixed value
SELECT 1;           -- returns 1
SELECT NOW();       -- returns current datetime
SELECT DATABASE();  -- returns current db name
```

---

## 6. Filtering — WHERE Clause

```sql
-- Equals
SELECT * FROM users WHERE id = 1;

-- Not equals
SELECT * FROM users WHERE city != 'Delhi';
SELECT * FROM users WHERE city <> 'Delhi';  -- same thing

-- Greater / Less than
SELECT * FROM orders WHERE total_amount > 500;
SELECT * FROM orders WHERE total_amount >= 500;
SELECT * FROM orders WHERE total_amount < 100;

-- Multiple conditions
SELECT * FROM users WHERE city = 'Delhi' AND is_active = 1;
SELECT * FROM users WHERE city = 'Delhi' OR city = 'Mumbai';

-- IN — match any value in a list
SELECT * FROM users WHERE city IN ('Delhi', 'Mumbai', 'Bangalore');

-- NOT IN — exclude values
SELECT * FROM products WHERE id NOT IN (1, 2, 3);

-- BETWEEN — range (inclusive)
SELECT * FROM orders WHERE total_amount BETWEEN 100 AND 500;

-- LIKE — pattern matching
SELECT * FROM users WHERE name LIKE 'Y%';     -- starts with Y
SELECT * FROM users WHERE name LIKE '%ash';   -- ends with ash
SELECT * FROM users WHERE name LIKE '%ash%';  -- contains ash
SELECT * FROM users WHERE name LIKE 'Y_sh';   -- Y + any 1 char + sh

-- IS NULL / IS NOT NULL
SELECT * FROM users WHERE deleted_at IS NULL;      -- active users
SELECT * FROM users WHERE deleted_at IS NOT NULL;  -- deleted users

-- Combining all
SELECT * FROM orders
WHERE user_id = 1
  AND status IN ('pending', 'delivered')
  AND total_amount > 100
  AND deleted_at IS NULL;
```

---

## 7. Sorting & Pagination

```sql
-- Order ascending (default)
SELECT * FROM products ORDER BY price ASC;
SELECT * FROM products ORDER BY price;  -- same

-- Order descending
SELECT * FROM products ORDER BY price DESC;

-- Order by multiple columns
SELECT * FROM users ORDER BY city ASC, name ASC;

-- Limit rows returned
SELECT * FROM products LIMIT 5;  -- first 5 rows

-- Pagination — skip N rows, return next M
SELECT * FROM products LIMIT 10 OFFSET 0;   -- page 1
SELECT * FROM products LIMIT 10 OFFSET 10;  -- page 2
SELECT * FROM products LIMIT 10 OFFSET 20;  -- page 3
```

---

## 8. UPDATE — Modifying Data

```sql
-- Update one column
UPDATE users SET city = 'Mumbai' WHERE id = 1;

-- Update multiple columns
UPDATE users
SET city = 'Mumbai', is_active = 0
WHERE id = 1;

-- Update with calculation
UPDATE products SET price = price * 1.10 WHERE category_id = 2;

-- ⚠️ Without WHERE — updates ALL rows!
UPDATE users SET is_active = 0;  -- dangerous!

-- Soft delete (mark as deleted, keep the row)
UPDATE users SET deleted_at = NOW() WHERE id = 1;
```

---

## 9. DELETE — Removing Data

```sql
-- Delete specific rows
DELETE FROM users WHERE id = 1;

-- Delete with condition
DELETE FROM orders WHERE status = 'cancelled' AND created_at < '2024-01-01';

-- ⚠️ Without WHERE — deletes ALL rows!
DELETE FROM users;  -- dangerous!

-- Truncate (faster, resets AUTO_INCREMENT, can't use WHERE)
TRUNCATE TABLE users;
```

---

## 10. JOINs

```sql
-- INNER JOIN — only matching rows from both tables
SELECT u.name, o.total_amount
FROM users u
INNER JOIN orders o ON u.id = o.user_id;

-- LEFT JOIN — all rows from left table + matches from right
-- Non-matching right rows show NULL
SELECT u.name, o.total_amount
FROM users u
LEFT JOIN orders o ON u.id = o.user_id;

-- RIGHT JOIN — all rows from right table + matches from left
SELECT u.name, o.total_amount
FROM users u
RIGHT JOIN orders o ON u.id = o.user_id;

-- Find users with NO orders (LEFT JOIN + IS NULL trick)
SELECT u.name
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
WHERE o.id IS NULL;

-- CROSS JOIN — every combination (cartesian product)
SELECT u.name, p.name
FROM users u
CROSS JOIN products p;

-- SELF JOIN — join a table with itself
SELECT e.name AS employee, m.name AS manager
FROM employees e
JOIN employees m ON e.manager_id = m.id;

-- Multiple JOINs — 3+ tables
SELECT u.name, o.id AS order_id, p.name AS product
FROM users u
JOIN orders o      ON u.id = o.user_id
JOIN order_items oi ON o.id = oi.order_id
JOIN products p    ON oi.product_id = p.id;
```

---

## 11. Aggregations

```sql
-- COUNT
SELECT COUNT(*) FROM users;                    -- total rows
SELECT COUNT(email) FROM users;                -- non-null emails only
SELECT COUNT(DISTINCT city) FROM users;        -- unique cities

-- SUM, AVG, MIN, MAX
SELECT SUM(total_amount) FROM orders;
SELECT AVG(total_amount) FROM orders;
SELECT MIN(price) FROM products;
SELECT MAX(price) FROM products;

-- ROUND
SELECT ROUND(AVG(price), 2) FROM products;

-- GROUP BY — aggregate per group
SELECT city, COUNT(*) AS user_count
FROM users
GROUP BY city;

SELECT user_id, SUM(total_amount) AS total_spent
FROM orders
GROUP BY user_id;

-- HAVING — filter after GROUP BY (like WHERE but for groups)
SELECT city, COUNT(*) AS user_count
FROM users
GROUP BY city
HAVING user_count > 2;

-- WHERE vs HAVING
SELECT city, COUNT(*) AS user_count
FROM users
WHERE is_active = 1        -- filters rows BEFORE grouping
GROUP BY city
HAVING user_count > 2;     -- filters groups AFTER grouping

-- COALESCE — return first non-null value
SELECT name, COALESCE(phone, 'No phone') AS phone FROM users;

-- IFNULL — return fallback if null
SELECT name, IFNULL(phone, 'No phone') AS phone FROM users;
```

---

## 12. Subqueries

```sql
-- Subquery in WHERE — single value
SELECT name, price FROM products
WHERE price > (SELECT AVG(price) FROM products);

-- Subquery in WHERE — list of values
SELECT name FROM users
WHERE id IN (SELECT DISTINCT user_id FROM orders);

-- NOT IN
SELECT name FROM products
WHERE id NOT IN (SELECT DISTINCT product_id FROM order_items);

-- Subquery in FROM (must have alias)
SELECT * FROM (
  SELECT user_id, SUM(total_amount) AS total_spent
  FROM orders
  GROUP BY user_id
) AS spending
WHERE spending.total_spent > 500;

-- Subquery in SELECT (scalar — returns one value per row)
SELECT
  name,
  price,
  (SELECT ROUND(AVG(price), 2) FROM products) AS avg_price
FROM products;

-- Correlated subquery (references outer row)
SELECT
  u.name,
  (SELECT COALESCE(SUM(o.total_amount), 0)
   FROM orders o WHERE o.user_id = u.id) AS total_spent
FROM users u;

-- EXISTS — check if matching rows exist
SELECT u.name FROM users u
WHERE EXISTS (
  SELECT 1 FROM orders o WHERE o.user_id = u.id
);

-- NOT EXISTS
SELECT u.name FROM users u
WHERE NOT EXISTS (
  SELECT 1 FROM orders o WHERE o.user_id = u.id
);
```

---

## 13. CTEs (WITH clause)

```sql
-- Basic CTE
WITH user_spending AS (
  SELECT user_id, SUM(total_amount) AS total_spent
  FROM orders
  GROUP BY user_id
)
SELECT * FROM user_spending ORDER BY total_spent DESC;

-- CTE + JOIN
WITH user_spending AS (
  SELECT user_id, SUM(total_amount) AS total_spent
  FROM orders
  GROUP BY user_id
)
SELECT u.name, u.city, COALESCE(s.total_spent, 0) AS total_spent
FROM users u
LEFT JOIN user_spending s ON u.id = s.user_id;

-- Multiple chained CTEs
WITH
  order_totals AS (
    SELECT user_id, COUNT(*) AS total_orders, SUM(total_amount) AS total_spent
    FROM orders GROUP BY user_id
  ),
  high_value AS (
    SELECT user_id FROM order_totals WHERE total_spent > 500
  )
SELECT u.name, u.email
FROM users u
WHERE u.id IN (SELECT user_id FROM high_value);
```

---

## 14. Indexes

```sql
-- Create a single-column index
CREATE INDEX idx_orders_user_id ON orders(user_id);

-- Create a composite index (multiple columns)
CREATE INDEX idx_orders_user_status ON orders(user_id, status);

-- Create a unique index (enforces uniqueness + fast lookup)
CREATE UNIQUE INDEX idx_users_email ON users(email);

-- Drop an index
DROP INDEX idx_orders_user_id ON orders;

-- View all indexes on a table
SHOW INDEX FROM orders;

-- Force a specific index (for testing only)
SELECT * FROM orders FORCE INDEX (idx_orders_user_status)
WHERE user_id = 1 AND status = 'delivered';
```

---

## 15. EXPLAIN — Query Analysis

```sql
-- Basic EXPLAIN (DBeaver shows tree format)
EXPLAIN SELECT * FROM orders WHERE user_id = 1;

-- Classic table format (always use this for learning)
EXPLAIN FORMAT=TRADITIONAL
SELECT u.name, o.total_amount
FROM users u
JOIN orders o ON u.id = o.user_id
WHERE u.id = 1;

-- EXPLAIN ANALYZE (runs the query, shows real timing)
EXPLAIN ANALYZE
SELECT * FROM orders WHERE user_id = 1;
```

### Key EXPLAIN columns

| Column | What it means |
|--------|--------------|
| `type` | How MySQL accesses the table — `const` best, `ALL` worst |
| `key` | Which index was used (`NULL` = no index) |
| `rows` | Estimated rows MySQL will scan |
| `Extra` | `Using index` = covering index ✅, `Using where` = extra filter |

### type values — best to worst

```
const → eq_ref → ref → range → index → ALL
```

---

## 16. Transactions

```sql
-- Start a transaction
START TRANSACTION;

-- Make changes
UPDATE accounts SET balance = balance - 1000 WHERE id = 1;
UPDATE accounts SET balance = balance + 1000 WHERE id = 2;

-- Save permanently
COMMIT;

-- Or undo everything
ROLLBACK;

-- Savepoint — checkpoint inside a transaction
START TRANSACTION;
UPDATE accounts SET balance = balance - 500 WHERE id = 1;
SAVEPOINT after_first;
UPDATE accounts SET balance = balance - 500 WHERE id = 1;
ROLLBACK TO after_first;  -- undo second update only
COMMIT;                    -- save first update
```

---

## 17. Inspection Queries

```sql
-- Which database am I in?
SELECT DATABASE();

-- List all databases
SHOW DATABASES;

-- List all tables in current database
SHOW TABLES;

-- Column overview — types, nullability, key flags
DESC users;

-- Full table definition — FKs, indexes, engine, charset
SHOW CREATE TABLE users;

-- All indexes on a table
SHOW INDEX FROM users;

-- Foreign key details — what points where
SELECT
  COLUMN_NAME,
  CONSTRAINT_NAME,
  REFERENCED_TABLE_NAME,
  REFERENCED_COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_NAME = 'orders'
  AND TABLE_SCHEMA = 'practice_db'
  AND REFERENCED_TABLE_NAME IS NOT NULL;

-- All tables in a database with row counts
SELECT table_name, table_rows
FROM information_schema.tables
WHERE table_schema = 'practice_db';

-- Current date and time
SELECT NOW();
SELECT CURDATE();  -- date only
SELECT CURTIME();  -- time only
```

---

## 18. ALTER TABLE

```sql
-- Add a new column
ALTER TABLE users ADD COLUMN phone VARCHAR(20);

-- Add column at a specific position
ALTER TABLE users ADD COLUMN phone VARCHAR(20) AFTER email;

-- Drop a column
ALTER TABLE users DROP COLUMN phone;

-- Rename a column
ALTER TABLE users RENAME COLUMN full_name TO name;

-- Change column type
ALTER TABLE users MODIFY COLUMN name VARCHAR(200) NOT NULL;

-- Rename a table
RENAME TABLE users TO blog_users;
-- or
ALTER TABLE users RENAME TO blog_users;

-- Add a foreign key after table creation
ALTER TABLE orders
ADD FOREIGN KEY (user_id) REFERENCES users(id);

-- Drop a foreign key
ALTER TABLE orders DROP FOREIGN KEY orders_ibfk_1;

-- Add an index
ALTER TABLE orders ADD INDEX idx_orders_user_id (user_id);
```

---

## Quick Lookup Cheat Sheet

| Task | Query |
|------|-------|
| Switch database | `USE db_name` |
| List databases | `SHOW DATABASES` |
| List tables | `SHOW TABLES` |
| Current database | `SELECT DATABASE()` |
| Table columns | `DESC table_name` |
| Full table definition | `SHOW CREATE TABLE table_name` |
| Table indexes | `SHOW INDEX FROM table_name` |
| Current time | `SELECT NOW()` |
| Last inserted id | `SELECT LAST_INSERT_ID()` |
| Count rows | `SELECT COUNT(*) FROM table_name` |
| Analyze query | `EXPLAIN FORMAT=TRADITIONAL SELECT ...` |

---

*SQL Learning Journey — Yash Verma | Complete Reference Guide*
