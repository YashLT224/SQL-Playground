-- ============================================================
-- WEEK 5 | TOPIC 4: Index Types
-- ============================================================
-- Types covered:
--   1. Single-column index  → one column, fast lookup
--   2. Composite index      → two+ columns together
--   3. Covering index       → all SELECT columns in index
--   4. Unique index         → lookup + uniqueness enforced
-- ============================================================

USE practice_db;

-- ============================================================
-- 1. SINGLE-COLUMN INDEX
-- ============================================================
-- Index on one column. Fast lookup on that column.
-- No uniqueness enforced.

CREATE INDEX idx_orders_user_id ON orders(user_id);

-- Helps queries like:
SELECT * FROM orders WHERE user_id = 8;
SELECT * FROM orders WHERE user_id = 3;

-- ============================================================
-- 2. COMPOSITE INDEX
-- ============================================================
-- Index on two or more columns together.
-- Helps queries that filter on multiple columns at once.

CREATE INDEX idx_orders_user_status ON orders(user_id, status);

-- Helps queries filtering on BOTH user_id AND status:
SELECT * FROM orders WHERE user_id = 8 AND status = 'delivered';

-- ============================================================
-- THE LEFT-PREFIX RULE ⚠️
-- ============================================================
-- Composite index (user_id, status) works for:
--   WHERE user_id = 8                            ✅
--   WHERE user_id = 8 AND status = 'delivered'   ✅
--   WHERE status = 'delivered'                   ❌ (skips first column)
--
-- Think of a phone book sorted by last name, then first name.
-- Searching by last name alone → works ✅
-- Searching by first name alone → useless ❌

-- Verify with EXPLAIN:
EXPLAIN FORMAT=TRADITIONAL
SELECT * FROM orders WHERE user_id = 8 AND status = 'delivered';
-- key = idx_orders_user_status ← composite index used ✅

EXPLAIN FORMAT=TRADITIONAL
SELECT * FROM orders WHERE status = 'delivered';
-- key = NULL ← index ignored, full scan ⚠️

-- ============================================================
-- 3. COVERING INDEX
-- ============================================================
-- A covering index contains ALL the columns a query needs.
-- MySQL never has to touch the actual table rows.
-- Shows as "Using index" in EXPLAIN Extra column.

-- This query only needs user_id and status:
EXPLAIN FORMAT=TRADITIONAL
SELECT user_id, status
FROM orders FORCE INDEX (idx_orders_user_status)
WHERE user_id = 8 AND status = 'delivered';

-- Extra = Using index ← covering index ✅
-- MySQL got both columns directly from the index.
-- Zero table access needed.

-- Without covering index (single-column only):
-- Extra = Using where ← had to go back to table for status column

-- ============================================================
-- COVERING INDEX MENTAL MODEL
-- ============================================================
-- Table row:  [id] [user_id] [total_amount] [status] [created_at]
--                                ↑ MySQL skips all of this
--
-- Index:      [user_id] [status]
--                 ↑ Everything the query needs is right here

-- ============================================================
-- 4. UNIQUE INDEX
-- ============================================================
-- Does two things at once:
--   → Speeds up lookups (like a regular index)
--   → Enforces no duplicate values in that column

CREATE UNIQUE INDEX idx_users_email ON users(email);
-- Already exists on users table from Week 1 UNIQUE constraint

-- On duplicate insert:
-- INSERT INTO users (name, email) VALUES ('Bob', 'yash@gmail.com');
-- ERROR 1062: Duplicate entry 'yash@gmail.com' for key 'email'
-- MySQL rejects it at database level — no application code needed.

-- ============================================================
-- ALL INDEX TYPES COMPARISON
-- ============================================================
-- Type          | Syntax                        | Unique | Use When
-- --------------|-------------------------------|--------|---------------------------
-- Single-column | CREATE INDEX ON (col)         | No     | Filter/join on one column
-- Composite     | CREATE INDEX ON (col1, col2)  | No     | Filter on multiple columns
-- Covering      | composite covering SELECT cols| No     | Read-heavy, max speed
-- Unique        | CREATE UNIQUE INDEX ON (col)  | Yes    | No duplicates (email, username)
-- Primary Key   | AUTO on id column             | Yes    | Always exists

-- ============================================================
-- USE INDEX vs FORCE INDEX
-- ============================================================
-- USE INDEX   → suggest to MySQL (can still be ignored)
-- FORCE INDEX → override MySQL's optimizer (for testing only)
-- In production: never force indexes — let optimizer decide.

-- ============================================================
-- PRACTICE CHALLENGES:
-- Challenge 1: Create a composite index on order_items
--              (order_id, product_id). Run EXPLAIN on a query
--              using both columns in WHERE.
-- Challenge 2: Try a query that violates the left-prefix rule.
--              Confirm with EXPLAIN that key = NULL.
-- Challenge 3: Write a query where the composite index acts
--              as a covering index. Look for "Using index" in Extra.
-- ============================================================
