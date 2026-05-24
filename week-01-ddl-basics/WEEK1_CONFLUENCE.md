# SQL Learning Journey — Week 1: DDL + Basic DML

**Author:** Yash Verma
**Database:** MySQL
**Date:** May 2026
**Status:** ✅ Completed

---

## Overview

Week 1 covers the foundation of SQL — how to define database structure (DDL) and perform basic data operations (DML) using MySQL.

| Category | Full Form | Commands |
|----------|-----------|----------|
| DDL | Data Definition Language | CREATE, ALTER, DROP, TRUNCATE |
| DML | Data Manipulation Language | INSERT, SELECT, UPDATE, DELETE |
| Filtering | Query Conditions | WHERE, IN, BETWEEN, LIKE, IS NULL |
| Sorting | Result Ordering | ORDER BY, LIMIT, OFFSET |

---

## 1. MySQL Data Types

Choosing the right data type is critical for storage efficiency and data integrity.

| Data Type | Used For | Example |
|-----------|----------|---------|
| `INT` | Whole numbers | id, age, quantity |
| `VARCHAR(n)` | Short text with max length | name VARCHAR(100) |
| `TEXT` | Long text, no limit | description, bio |
| `DECIMAL(p,s)` | Precise decimals | price DECIMAL(10,2) |
| `BOOLEAN` | True/False — stored as TINYINT(1) in MySQL | is_active BOOLEAN DEFAULT TRUE |
| `DATETIME` | Date and time | created_at DATETIME DEFAULT CURRENT_TIMESTAMP |

> ⚠️ **Important:** MySQL stores `BOOLEAN` as `TINYINT(1)` internally. `1 = true`, `0 = false`. This is expected behavior.

---

## 2. DDL — Data Definition Language

DDL commands define the **structure** of your database. Think of it like defining a TypeScript interface — you set up the shape before any data flows in.

### 2.1 CREATE TABLE

```sql
CREATE DATABASE IF NOT EXISTS practice_db;
USE practice_db;

-- Users table
CREATE TABLE users (
  id         INT AUTO_INCREMENT PRIMARY KEY,
  name       VARCHAR(100) NOT NULL,
  email      VARCHAR(255) NOT NULL UNIQUE,
  age        INT,
  city       VARCHAR(100),
  is_active  BOOLEAN DEFAULT TRUE,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Products table
CREATE TABLE products (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  name        VARCHAR(150) NOT NULL,
  description TEXT,
  price       DECIMAL(10, 2) NOT NULL,
  stock       INT DEFAULT 0,
  created_at  DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Orders table
CREATE TABLE orders (
  id           INT AUTO_INCREMENT PRIMARY KEY,
  user_id      INT NOT NULL,
  total_amount DECIMAL(10, 2),
  status       VARCHAR(50) DEFAULT 'pending',
  ordered_at   DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

**Key constraints:**

| Constraint | Meaning |
|------------|---------|
| `AUTO_INCREMENT` | MySQL auto-generates unique IDs (1, 2, 3...) |
| `PRIMARY KEY` | Uniquely identifies every row |
| `NOT NULL` | Field is required, cannot be empty |
| `UNIQUE` | No two rows can have the same value |
| `DEFAULT` | Value used automatically if not provided on insert |

---

### 2.2 ALTER TABLE

Used to modify table structure **after it already has data**:

```sql
-- Add a column
ALTER TABLE users ADD COLUMN phone VARCHAR(15);

-- Add at a specific position
ALTER TABLE users ADD COLUMN city VARCHAR(100) AFTER name;

-- Rename a column
ALTER TABLE users RENAME COLUMN phone TO mobile;

-- Change a column's data type
ALTER TABLE users MODIFY COLUMN age TINYINT;

-- Remove a column
ALTER TABLE users DROP COLUMN mobile;

-- Rename the table
RENAME TABLE users TO app_users;
```

---

### 2.3 DROP & TRUNCATE

```sql
DROP TABLE users;        -- removes the table entirely (irreversible!)
TRUNCATE TABLE orders;   -- empties all rows but keeps the structure
```

> ⚠️ `DROP` and `TRUNCATE` are irreversible. Always double-check before running.

---

## 3. DML — Data Manipulation Language

### 3.1 INSERT

```sql
-- Single row insert
INSERT INTO users (name, email, age, city)
VALUES ('Yash Verma', 'yash@example.com', 26, 'Mumbai');

-- Multi-row insert (more efficient)
INSERT INTO users (name, email, age, city) VALUES
  ('Priya Sharma',  'priya@example.com',  24, 'Delhi'),
  ('Rahul Gupta',   'rahul@example.com',  30, 'Bangalore'),
  ('Ananya Singh',  'ananya@example.com', 28, 'Mumbai'),
  ('Vikram Nair',   'vikram@example.com', 35, 'Chennai'),
  ('Sneha Patil',   'sneha@example.com',  22, 'Pune');

-- Insert products
INSERT INTO products (name, description, price, stock) VALUES
  ('Mechanical Keyboard', 'RGB backlit, TKL layout',      3499.00, 50),
  ('Wireless Mouse',      'Ergonomic, 3 months battery',  1299.00, 120),
  ('USB-C Hub',           '7-in-1 multiport adapter',     1899.00, 75),
  ('Monitor Stand',       'Adjustable height, bamboo',    2199.00, 30),
  ('Webcam HD',           '1080p with built-in mic',      2499.00, 45);

-- Insert orders
INSERT INTO orders (user_id, total_amount, status) VALUES
  (1, 3499.00, 'delivered'),
  (2, 1299.00, 'shipped'),
  (3, 4398.00, 'pending'),
  (1, 1899.00, 'delivered'),
  (4, 2499.00, 'pending');
```

> You don't need to pass `id` or `created_at` — MySQL fills those automatically.

---

### 3.2 SELECT

```sql
-- All columns
SELECT * FROM users;

-- Specific columns
SELECT name, email FROM users;

-- With filter
SELECT * FROM users WHERE age > 25;
SELECT * FROM users WHERE city = 'Mumbai';

-- Multiple conditions
SELECT * FROM users WHERE age > 25 AND city = 'Mumbai';
SELECT * FROM users WHERE city = 'Mumbai' OR city = 'Delhi';

-- IN — match against a list
SELECT * FROM users WHERE city IN ('Mumbai', 'Delhi', 'Pune');

-- BETWEEN — range filter (inclusive)
SELECT * FROM products WHERE price BETWEEN 1000 AND 2500;

-- LIKE — pattern matching
SELECT * FROM users WHERE name LIKE 'A%';    -- starts with A
SELECT * FROM users WHERE name LIKE '%ar%';  -- contains "ar"

-- ORDER BY + LIMIT + OFFSET (pagination)
SELECT * FROM products ORDER BY price DESC LIMIT 3;
SELECT * FROM products ORDER BY price DESC LIMIT 3 OFFSET 3;

-- Aliases
SELECT name AS user_name, (price * stock) AS total_value FROM products;
```

---

### 3.3 UPDATE

```sql
-- Update single column
UPDATE users SET age = 27 WHERE id = 1;

-- Update multiple columns
UPDATE users SET age = 29, city = 'Pune' WHERE email = 'ananya@example.com';

-- Conditional bulk update
UPDATE users SET is_active = FALSE WHERE city = 'Chennai';
```

> ⚠️ Always use `WHERE` with UPDATE. Without it, **all rows** are updated.

---

### 3.4 DELETE

```sql
-- Delete a specific row
DELETE FROM users WHERE id = 8;

-- ⚠️ WITHOUT WHERE = deletes ALL rows!
-- DELETE FROM users;  ← never run this accidentally
```

---

### 3.5 Soft Delete Pattern (Best Practice)

In production, instead of hard deleting rows, mark them as deleted. This preserves data for auditing and recovery.

```sql
-- Add a soft delete column
ALTER TABLE users ADD COLUMN deleted_at DATETIME DEFAULT NULL;

-- Soft delete a user
UPDATE users SET deleted_at = CURRENT_TIMESTAMP WHERE id = 5;

-- Always filter deleted rows in SELECT queries
SELECT * FROM users WHERE deleted_at IS NULL;
```

---

## 4. Key Concepts & Notes

| Concept | Explanation |
|---------|-------------|
| BOOLEAN in MySQL | Stored as `TINYINT(1)`. `1 = true`, `0 = false` |
| WHERE is mandatory | Always use WHERE with UPDATE/DELETE. Without it, all rows are affected |
| DECIMAL for money | Never use `FLOAT` for currency — use `DECIMAL(10,2)` for precision |
| AUTO_INCREMENT | MySQL handles ID generation automatically. Never insert IDs manually |
| Soft Delete | Prefer `deleted_at` over hard DELETE for data recovery and audit trails |
| LIKE patterns | `%` = any characters, `_` = exactly one. `'A%'` starts with A |
| LIMIT + OFFSET | Used for API pagination. `LIMIT 10 OFFSET 20` = page 3 of 10 results |

---

## 5. Assignment — Questions & Answers

### Question 1 — Create the orders table

**Task:** Create an orders table with id, user_id, total_amount, status (with validation), and ordered_at columns.

**Submitted Answer:**
```sql
CREATE TABLE orders (
  id           INT AUTO_INCREMENT PRIMARY KEY,
  user_id      INT NOT NULL,
  total_amount DECIMAL(10,2),
  status       VARCHAR(50) CHECK (status IN ('pending', 'shipped', 'delivered')),
  ordered_at   DATETIME DEFAULT __CURRENT_TIMESTAMP__
);
```

**Score: 90/100**

**Review:** Excellent structure. Used `CHECK` constraint proactively — great thinking! One fix needed: `__CURRENT_TIMESTAMP__` should be `CURRENT_TIMESTAMP` (no underscores).

**Correct Answer:**
```sql
CREATE TABLE orders (
  id           INT AUTO_INCREMENT PRIMARY KEY,
  user_id      INT NOT NULL,
  total_amount DECIMAL(10,2),
  status       VARCHAR(50) CHECK (status IN ('pending', 'shipped', 'delivered')),
  ordered_at   DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

> 📌 Note: CHECK constraints were silently ignored in MySQL before version 8.0.16. Run `SELECT VERSION();` to check your version.

---

### Question 2 — Insert 5 orders

**Task:** Insert 5 orders for different users with varied statuses.

**Submitted Answer:**
```sql
INSERT INTO orders (user_id, total_amount, status) VALUES
  (1, 250.00,   'pending'),
  (2, 499.99,   'shipped'),
  (3, 1299.50,  'delivered'),
  (4, 75.25,    'pending'),
  (5, 999.00,   'shipped');
```

**Score: 100/100**

**Review:** Perfect. Correct syntax, multiple rows in one query, covers all three status values.

---

### Question 3 — Fetch all pending orders

**Submitted Answer:**
```sql
SELECT * FROM orders WHERE status = 'pending';
```

**Score: 100/100**

**Review:** Correct. Clean and precise filter using WHERE.

---

### Question 4 — Products priced between 1000 and 2500

**Submitted Answer:**
```sql
SELECT * FROM products WHERE price BETWEEN 1000 AND 2500;
```

**Score: 100/100**

**Review:** Correct. BETWEEN is inclusive on both ends — a clean, readable approach.

---

### Question 5 — Top 3 most expensive products

**Submitted Answer:**
```sql
SELECT * FROM products ORDER BY price DESC LIMIT 3;
```

**Score: 100/100**

**Review:** Perfect. Correct use of ORDER BY DESC and LIMIT together.

---

### Question 6 — Users whose name starts with 'R'

**Submitted Answer:**
```sql
SELECT * FROM users WHERE name LIKE 'P%';
```

**Score: 85/100**

**Review:** Valid SQL syntax, but the challenge asked for `'R%'` not `'P%'`. Small copy-paste slip. The LIKE pattern logic is correctly understood.

**Correct Answer:**
```sql
SELECT * FROM users WHERE name LIKE 'R%';
```

---

## 6. Final Score

| Question | Topic | Score |
|----------|-------|-------|
| Q1 | CREATE TABLE orders | 90/100 |
| Q2 | INSERT 5 orders | 100/100 |
| Q3 | SELECT pending orders | 100/100 |
| Q4 | BETWEEN filter on price | 100/100 |
| Q5 | ORDER BY + LIMIT | 100/100 |
| Q6 | LIKE pattern matching | 85/100 |
| **TOTAL** | | **575/600 — 95.8% 🏆** |

> ✅ Outstanding performance for Week 1! Core SQL concepts are well understood. Two minor issues — a typo in CURRENT_TIMESTAMP and a wrong letter in the LIKE pattern. Ready to move to Week 2: JOINs.

---

## 7. Coming Up — Week 2: JOINs

Week 2 covers connecting multiple tables together — one of the most important SQL skills.

| JOIN Type | What it returns |
|-----------|----------------|
| INNER JOIN | Only rows that have a match in both tables |
| LEFT JOIN | All rows from left table, NULLs where no match on right |
| RIGHT JOIN | All rows from right table, NULLs where no match on left |
| FULL OUTER JOIN | All rows from both tables, NULLs on either side |
| SELF JOIN | Joins a table with itself (e.g. employee → manager) |

> 💡 **Frontend analogy:** JOINs are like doing a `.map()` over two arrays and merging objects by a shared key (like `userId`).

---

*SQL Learning Journey — Yash Verma | Week 1 of 6*
