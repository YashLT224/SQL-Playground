-- ============================================================
-- WEEK 5 | TOPIC 2: EXPLAIN — Reading Query Plans
-- ============================================================
-- EXPLAIN shows how MySQL executes a query BEFORE running it.
-- It reveals whether MySQL is doing a full table scan or
-- using an index — critical for spotting slow queries.
--
-- Two formats:
--   EXPLAIN SELECT ...                → tree format (DBeaver default)
--   EXPLAIN FORMAT=TRADITIONAL SELECT → classic table with columns
--
-- Always use FORMAT=TRADITIONAL for learning — it shows
-- the type, key, and rows columns clearly.
-- ============================================================

USE practice_db;

-- ============================================================
-- BASIC EXPLAIN — without any index on user_id
-- ============================================================

EXPLAIN FORMAT=TRADITIONAL
SELECT u.name, o.total_amount
FROM users u
JOIN orders o ON u.id = o.user_id
WHERE u.id = 8;

-- Output (before index on orders.user_id):
-- | id | table | type  | key     | rows | Extra       |
-- |----|-------|-------|---------|------|-------------|
-- |  1 | u     | const | PRIMARY |    1 |             |
-- |  1 | o     | ALL   | NULL    |    5 | Using where |
--
-- type=ALL on orders → full table scan (bad!)
-- key=NULL          → no index used
-- rows=5            → scanning all 5 rows

-- ============================================================
-- UNDERSTANDING THE EXPLAIN COLUMNS
-- ============================================================

-- id:     query block number (same number = same JOIN level)
-- table:  which table this row refers to
-- type:   HOW MySQL accesses the table (most important column)
-- key:    which index MySQL chose (NULL = no index)
-- rows:   estimated number of rows MySQL will examine
-- Extra:  additional info (Using where, Using index, etc.)

-- ============================================================
-- THE TYPE COLUMN — from best to worst
-- ============================================================
-- const  → single row via PRIMARY KEY or UNIQUE index (best)
-- eq_ref → one row per join using unique index
-- ref    → rows matched via non-unique index
-- range  → index used with a range (BETWEEN, >, <)
-- index  → full index scan (better than ALL, still slow)
-- ALL    → full table scan — reads every row (worst!) ⚠️

-- ============================================================
-- EXTRA COLUMN — key values to know
-- ============================================================
-- Using index  → covering index, never touched the table ✅
-- Using where  → index used but extra filtering needed
-- NULL         → standard table + index access

-- ============================================================
-- WHY EXPLAIN RETURNS 2 ROWS
-- ============================================================
-- EXPLAIN shows one row per TABLE accessed in the query.
-- A JOIN between users and orders = 2 tables = 2 rows in EXPLAIN.
-- Each row describes how MySQL accesses that specific table.

-- ============================================================
-- EXPLAIN ANALYZE — real execution (MySQL 8.0+)
-- ============================================================
-- EXPLAIN shows estimates. EXPLAIN ANALYZE actually runs
-- the query and shows real timing.

EXPLAIN ANALYZE
SELECT u.name, o.total_amount
FROM users u
JOIN orders o ON u.id = o.user_id
WHERE u.id = 8;

-- Shows: actual time, actual rows, loops
-- Use this to benchmark queries with real data.

-- ============================================================
-- PRACTICE CHALLENGES:
-- Challenge 1: Run EXPLAIN FORMAT=TRADITIONAL on a query
--              that uses WHERE on a non-indexed column.
--              What is the type value?
-- Challenge 2: Run EXPLAIN on a query using the PRIMARY KEY.
--              What type do you see?
-- ============================================================
