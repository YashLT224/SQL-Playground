-- ============================================================
-- WEEK 5 | TOPIC 3: CREATE INDEX — Before & After
-- ============================================================
-- Syntax:
--   CREATE INDEX index_name ON table_name(column_name);
--   DROP INDEX index_name ON table_name;
--
-- Index naming convention:
--   idx_<table>_<column>
--   e.g. idx_orders_user_id
-- ============================================================

USE practice_db;

-- ============================================================
-- STEP 1: EXPLAIN BEFORE — full table scan
-- ============================================================

EXPLAIN FORMAT=TRADITIONAL
SELECT u.name, o.total_amount
FROM users u
JOIN orders o ON u.id = o.user_id
WHERE u.id = 8;

-- orders row shows:
-- type = ALL          ← full table scan ⚠️
-- key  = NULL         ← no index used
-- rows = 5            ← scanning all rows

-- ============================================================
-- STEP 2: CREATE INDEX on orders.user_id
-- ============================================================

CREATE INDEX idx_orders_user_id ON orders(user_id);

-- ============================================================
-- STEP 3: VERIFY THE INDEX WAS CREATED
-- ============================================================

SHOW INDEX FROM orders;
-- Now shows: PRIMARY on id + idx_orders_user_id on user_id

-- ============================================================
-- STEP 4: EXPLAIN AFTER — index lookup
-- ============================================================

EXPLAIN FORMAT=TRADITIONAL
SELECT u.name, o.total_amount
FROM users u
JOIN orders o ON u.id = o.user_id
WHERE u.id = 8;

-- orders row now shows:
-- type = ref                 ← index lookup ✅
-- key  = idx_orders_user_id  ← our index was picked up
-- rows = 1                   ← only 1 row examined (down from 5)

-- ============================================================
-- BEFORE vs AFTER SUMMARY
-- ============================================================
-- Column | Before (no index) | After (with index)
-- -------|-------------------|-------------------
-- type   | ALL               | ref
-- key    | NULL              | idx_orders_user_id
-- rows   | 5                 | 1
--
-- On 5 rows: negligible difference
-- On 5,000,000 rows: difference between 3s and 3ms

-- ============================================================
-- DROP AN INDEX
-- ============================================================

-- DROP INDEX idx_orders_user_id ON orders;
-- Run SHOW INDEX again to confirm removal

-- ============================================================
-- DUPLICATE INDEXES — what happens?
-- ============================================================
-- MySQL ALLOWS creating duplicate indexes without error.
-- It will silently maintain two identical structures.
-- Problems:
--   → Wasted storage (each index stored separately on disk)
--   → Slower writes (INSERT/UPDATE/DELETE updates ALL indexes)
--   → MySQL picks one randomly — the other is never used
--   → Zero extra read performance benefit
-- Always run SHOW INDEX before creating a new one.

-- ============================================================
-- CREATE INDEXES ON OTHER TABLES
-- ============================================================

CREATE INDEX idx_order_items_order_id   ON order_items(order_id);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);

SHOW INDEX FROM order_items;

-- ============================================================
-- PRACTICE CHALLENGES:
-- Challenge 1: Run EXPLAIN before and after adding an index
--              on order_items.product_id. Compare type and rows.
-- Challenge 2: Create a duplicate index and run SHOW INDEX.
--              Then DROP the duplicate.
-- ============================================================
