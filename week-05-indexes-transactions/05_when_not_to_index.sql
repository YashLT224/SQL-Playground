-- ============================================================
-- WEEK 5 | TOPIC 5: When NOT to Use Indexes
-- ============================================================
-- Indexes speed up reads but slow down writes.
-- Every INSERT, UPDATE, DELETE must update ALL indexes too.
-- Knowing when to skip an index is as important as adding one.
-- ============================================================

USE practice_db;

-- ============================================================
-- RULE 1: LOW-CARDINALITY COLUMNS
-- ============================================================
-- Cardinality = number of distinct values in a column.
-- Low cardinality = very few distinct values.

-- BAD: status column only has 3 values ('pending', 'delivered', 'cancelled')
-- CREATE INDEX idx_orders_status ON orders(status);  ← avoid this alone

-- If 40% of rows are 'delivered', MySQL still fetches 40% of table.
-- The index gives almost no benefit — MySQL may do a full scan anyway.

-- GOOD: use status as part of a COMPOSITE index instead
CREATE INDEX idx_orders_user_status ON orders(user_id, status);
-- user_id has high cardinality → narrows results quickly
-- status then filters the smaller result set

-- ============================================================
-- RULE 2: SMALL TABLES
-- ============================================================
-- Full table scan on 10 rows is basically instant.
-- Index overhead costs more than it saves.

-- AVOID on small tables:
-- CREATE INDEX idx_products_price ON products(price);
-- Our products table has ~5 rows — pointless.

-- Rule of thumb: don't bother indexing tables under a few thousand rows.

-- ============================================================
-- RULE 3: COLUMNS RARELY USED IN WHERE / JOIN / ORDER BY
-- ============================================================
-- Every index adds write overhead. If a column is never
-- queried, you're paying the cost for zero benefit.

-- Example: if nobody ever filters by created_at in your app:
-- CREATE INDEX idx_orders_created ON orders(created_at);  ← wasteful

-- Always ask: "Is this column actually used in WHERE, JOIN ON, or ORDER BY
--              in real application queries?"

-- ============================================================
-- RULE 4: FREQUENTLY UPDATED COLUMNS
-- ============================================================
-- Every UPDATE to an indexed column = MySQL must update the index too.
-- High-frequency updates + index = serious write overhead.

-- Example: last_seen updates every time user opens the app
-- CREATE INDEX idx_users_last_seen ON users(last_seen);  ← avoid

-- The write cost of maintaining this index far outweighs
-- any occasional read benefit.

-- ============================================================
-- RULE 5: FUNCTIONS ON INDEXED COLUMNS IN WHERE ⚠️
-- ============================================================
-- This is a common mistake. Using a function on an indexed column
-- in WHERE breaks the index entirely.

-- Index exists on users.email — but this query WON'T use it:
EXPLAIN FORMAT=TRADITIONAL
SELECT * FROM users WHERE UPPER(email) = 'YASH@GMAIL.COM';
-- type = ALL ← full table scan, index bypassed ⚠️

-- Why? MySQL stores 'yash@gmail.com' in the index.
-- UPPER() transforms it at query time — index can't match.

-- CORRECT — index will be used:
EXPLAIN FORMAT=TRADITIONAL
SELECT * FROM users WHERE email = 'yash@gmail.com';
-- type = const ← index used perfectly ✅

-- Same problem with other functions:
-- WHERE YEAR(created_at) = 2024        ← index bypassed ⚠️
-- WHERE DATE(created_at) = '2024-01-01'← index bypassed ⚠️
-- WHERE LOWER(name) = 'yash'           ← index bypassed ⚠️

-- FIX for date ranges (use range instead of function):
-- WHERE created_at >= '2024-01-01' AND created_at < '2025-01-01'  ✅

-- ============================================================
-- DECISION CHART: Should I add an index?
-- ============================================================
-- Is the column used in WHERE / JOIN / ORDER BY?
--   → No  → Don't index
--   → Yes ↓
-- Does it have high cardinality (many distinct values)?
--   → No  → Don't index (status, boolean flags)
--   → Yes ↓
-- Is the table large enough to matter (thousands+ rows)?
--   → No  → Don't index
--   → Yes → Index it ✅

-- ============================================================
-- THE WRITE TAX SUMMARY
-- ============================================================
-- Every index you create:
--   INSERT → MySQL writes to table + updates every index
--   UPDATE → MySQL updates table row + updates affected indexes
--   DELETE → MySQL removes from table + updates every index
--
-- Fewer indexes = faster writes
-- Right indexes = fast reads without hurting writes

-- ============================================================
-- PRACTICE CHALLENGES:
-- Challenge 1: Write a query with UPPER() on an indexed column.
--              Run EXPLAIN and confirm type=ALL.
--              Fix the query and confirm the index is used.
-- Challenge 2: Look at your orders table. Which columns would
--              you NOT index and why?
-- Challenge 3: Check if idx_orders_status alone would be useful.
--              What is the cardinality? Would you add it?
-- ============================================================
