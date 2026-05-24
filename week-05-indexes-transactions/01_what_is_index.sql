-- ============================================================
-- WEEK 5 | TOPIC 1: What is an Index?
-- ============================================================
-- An index is a separate data structure MySQL maintains
-- alongside a table to speed up lookups.
--
-- Without an index: MySQL reads EVERY row (table scan)
-- With an index:    MySQL jumps directly to matching rows
--
-- Real-world analogy:
--   Table = a book
--   Index = the index at the back of the book
--   Without index: flip every page to find "transactions"
--   With index: jump straight to page 212
-- ============================================================

USE practice_db;

-- ============================================================
-- CHECK EXISTING INDEXES ON ALL TABLES
-- ============================================================

SHOW INDEX FROM users;
-- Result: PRIMARY on id, UNIQUE on email

SHOW INDEX FROM products;
-- Result: PRIMARY on id only

SHOW INDEX FROM orders;
-- Result: PRIMARY on id only ← missing index on user_id!

SHOW INDEX FROM order_items;
-- Result: PRIMARY on id only ← missing indexes on order_id and product_id!

-- ============================================================
-- WHAT SHOW INDEX COLUMNS MEAN
-- ============================================================
-- Table       → which table
-- Non_unique  → 0 = unique index, 1 = allows duplicates
-- Key_name    → index name (PRIMARY, or custom name)
-- Seq_in_index→ column position within the index (1, 2, 3...)
-- Column_name → which column is indexed
-- Index_type  → BTREE (default), HASH, FULLTEXT
--
-- Key observations from our tables:
--   orders.user_id     → no index ← every JOIN on user_id = full scan
--   order_items.order_id   → no index
--   order_items.product_id → no index
-- ============================================================

-- ============================================================
-- HOW BTREE INDEX WORKS INTERNALLY
-- ============================================================
-- MySQL uses a B-Tree (Balanced Tree) structure.
-- Values are sorted and stored in a tree — each lookup
-- narrows down by half at each level.
--
-- 1,000,000 rows → ~20 comparisons to find any value
-- Without index  → up to 1,000,000 comparisons
-- ============================================================

-- ============================================================
-- PRACTICE CHALLENGES:
-- Challenge 1: Run SHOW INDEX on all 4 tables.
--              Which columns are missing indexes?
-- Challenge 2: Which table would benefit most from an index?
--              Why?
-- ============================================================
