# SQL Learning Journey — Week 5: Indexes & Performance

**Author:** Yash Verma
**Database:** MySQL
**Date:** May 2026
**Status:** 🔄 In Progress (Indexes ✅ | Transactions ⏳)

---

## Topics Covered

| # | Topic | Description |
|---|-------|-------------|
| 1 | What is an Index | How indexes work, SHOW INDEX, BTREE structure |
| 2 | EXPLAIN Query Plan | Reading type, key, rows, Extra columns |
| 3 | CREATE INDEX | Before/after comparison, DROP INDEX |
| 4 | Index Types | Single-column, Composite, Covering, Unique |
| 5 | When NOT to Index | Low cardinality, small tables, function trap |

---

## What is an Index?

An **index** is a separate data structure MySQL maintains alongside a table to speed up lookups.

```
Without index → MySQL reads EVERY row (table scan)
With index    → MySQL jumps directly to matching rows
```

Real-world analogy: a table is like a book. An index is like the index at the back. Without it, you flip every page. With it, you jump straight to page 212.

MySQL uses a **B-Tree (Balanced Tree)** structure by default. Values are sorted in a tree — each lookup narrows by half at every level.

```
1,000,000 rows → ~20 comparisons with index
               → up to 1,000,000 comparisons without
```

### Check existing indexes

```sql
SHOW INDEX FROM orders;
```

Key columns in the output:

| Column | Meaning |
|--------|---------|
| `Non_unique` | 0 = unique index, 1 = allows duplicates |
| `Key_name` | Index name (PRIMARY or custom) |
| `Seq_in_index` | Column position within a composite index |
| `Column_name` | Which column is indexed |
| `Index_type` | BTREE (default), HASH, FULLTEXT |

### Index gaps found in our tables

| Table | Missing Index | Impact |
|-------|--------------|--------|
| `orders` | `user_id` | Every JOIN on user_id = full table scan |
| `order_items` | `order_id` | Full scan on every order lookup |
| `order_items` | `product_id` | Full scan on every product lookup |

---

## 1. EXPLAIN — Reading Query Plans

`EXPLAIN` shows how MySQL executes a query **before running it**. It reveals whether MySQL is doing a full table scan or using an index.

```sql
-- Always use FORMAT=TRADITIONAL for learning
-- DBeaver defaults to FORMAT=TREE which is harder to read
EXPLAIN FORMAT=TRADITIONAL
SELECT u.name, o.total_amount
FROM users u
JOIN orders o ON u.id = o.user_id
WHERE u.id = 8;
```

### The key columns

| Column | What it tells you |
|--------|------------------|
| `id` | Query block number — same number = same JOIN level |
| `table` | Which table this row refers to |
| `type` | **Most important** — how MySQL accesses the table |
| `key` | Which index MySQL chose (`NULL` = no index used) |
| `rows` | Estimated rows MySQL will examine |
| `Extra` | Additional info: Using index, Using where, etc. |

### The `type` column — best to worst

| type | Meaning |
|------|---------|
| `const` | Single row via PRIMARY KEY or UNIQUE — best possible ✅ |
| `eq_ref` | One row per join via unique index |
| `ref` | Rows matched via non-unique index |
| `range` | Index used with a range (BETWEEN, >, <) |
| `index` | Full index scan |
| `ALL` | Full table scan — reads every row ⚠️ worst |

### The `Extra` column

| Extra value | Meaning |
|-------------|---------|
| `Using index` | Covering index — never touched the table ✅ |
| `Using where` | Index used but extra filtering needed |
| `NULL` | Standard table + index access |

### EXPLAIN ANALYZE (MySQL 8.0+)

```sql
-- EXPLAIN shows estimates. EXPLAIN ANALYZE runs the query
-- and shows real execution time.
EXPLAIN ANALYZE
SELECT u.name, o.total_amount
FROM users u
JOIN orders o ON u.id = o.user_id
WHERE u.id = 8;
```

---

## 2. CREATE INDEX — Before & After

```sql
-- Naming convention: idx_<table>_<column>
CREATE INDEX idx_orders_user_id ON orders(user_id);

-- Remove an index
DROP INDEX idx_orders_user_id ON orders;
```

### Before vs After comparison

```sql
-- BEFORE: No index on orders.user_id
-- type = ALL, key = NULL, rows = 5 ← full table scan ⚠️

-- Create the index
CREATE INDEX idx_orders_user_id ON orders(user_id);

-- AFTER: Index exists
-- type = ref, key = idx_orders_user_id, rows = 1 ✅
```

| Column | Before (no index) | After (with index) |
|--------|-------------------|-------------------|
| `type` | `ALL` | `ref` |
| `key` | `NULL` | `idx_orders_user_id` |
| `rows` | `5` | `1` |

On 5 rows the difference is invisible. On 5 million rows, this is the difference between **3 seconds vs 3 milliseconds**.

### Duplicate indexes

MySQL allows creating duplicate indexes without error — it silently creates a redundant structure. Problems:
- Wasted storage (each index stored separately on disk)
- Slower writes — INSERT/UPDATE/DELETE must update ALL indexes
- MySQL picks one at random — the other is never used
- Zero extra read performance

Always run `SHOW INDEX` before creating a new one.

---

## 3. Index Types

### Single-column index

Index on one column. Fast lookup, no uniqueness enforced.

```sql
CREATE INDEX idx_orders_user_id ON orders(user_id);
```

### Composite index

Index on two or more columns together. Helps queries that filter on multiple columns at once.

```sql
CREATE INDEX idx_orders_user_status ON orders(user_id, status);

-- Helps this query:
SELECT * FROM orders WHERE user_id = 8 AND status = 'delivered';
```

#### The Left-Prefix Rule ⚠️

A composite index `(user_id, status)` works for:

```sql
WHERE user_id = 8                           -- ✅ uses index
WHERE user_id = 8 AND status = 'delivered'  -- ✅ uses index
WHERE status = 'delivered'                  -- ❌ skips first column, index ignored
```

Think of a phone book sorted by last name, then first name. You can search by last name alone — but searching by first name alone makes it useless.

### Covering index

A covering index contains **all the columns the query needs** — MySQL never touches the actual table rows at all. Shows as `Using index` in the `Extra` column.

```sql
-- Query only needs user_id and status
SELECT user_id, status FROM orders WHERE user_id = 8 AND status = 'delivered';
-- With idx_orders_user_status → Extra = Using index ✅
```

Mental model:
```
Table row:  [id] [user_id] [total_amount] [status] [created_at]
                                ↑ MySQL skips all of this

Index:      [user_id] [status]
                ↑ Everything the query needs is right here
```

### Unique index

Does two things at once — fast lookups AND enforces no duplicates.

```sql
CREATE UNIQUE INDEX idx_users_email ON users(email);

-- On duplicate insert:
-- ERROR 1062: Duplicate entry 'yash@gmail.com' for key 'email'
```

### Primary Key vs Unique Index

| | Primary Key | Unique Index |
|--|------------|--------------|
| Allows NULL | ❌ Never | ✅ Yes (multiple NULLs allowed) |
| How many per table | Only 1 | As many as you want |
| Auto-creates index | ✅ Yes | ✅ Yes |
| Enforces uniqueness | ✅ Yes | ✅ Yes |
| Purpose | Identifies each row | Prevents duplicate values |

#### Can you insert NULL into a Unique column?

Yes — and you can insert **multiple NULLs**. MySQL does not treat them as duplicates.

```sql
CREATE TABLE users (
  id    INT PRIMARY KEY AUTO_INCREMENT,
  name  VARCHAR(100),
  phone VARCHAR(20) UNIQUE
);

INSERT INTO users (name, phone) VALUES ('Yash', '9876543210');  -- ✅
INSERT INTO users (name, phone) VALUES ('Rahul', NULL);          -- ✅ NULL allowed
INSERT INTO users (name, phone) VALUES ('Priya', NULL);          -- ✅ second NULL also allowed

-- This fails — duplicate non-NULL value
INSERT INTO users (name, phone) VALUES ('Bob', '9876543210');
-- ERROR 1062: Duplicate entry '9876543210' for key 'phone'
```

**Why multiple NULLs are allowed:** `NULL` means "unknown". MySQL follows the logic — "Is unknown = unknown? We can't say yes." So two NULLs are never considered equal.

```sql
-- Primary Key can NEVER be NULL
INSERT INTO users (id, name) VALUES (NULL, 'Yash');
-- ERROR 1048: Column 'id' cannot be null
```

#### When to use which

```sql
CREATE TABLE users (
  id       INT PRIMARY KEY AUTO_INCREMENT,  -- primary key
  email    VARCHAR(255) UNIQUE NOT NULL,    -- unique, no nulls (required)
  phone    VARCHAR(20) UNIQUE,              -- unique, nulls allowed (optional)
  username VARCHAR(50) UNIQUE NOT NULL      -- unique, no nulls (required)
);
```

> **One line summary:** Primary Key = unique + never null + only one per table. Unique Index = unique + nulls allowed + many per table.

### All types at a glance

| Type | Syntax | Enforces Uniqueness | Allows NULL | Use When |
|------|--------|---------------------|-------------|----------|
| Single-column | `CREATE INDEX ON (col)` | ❌ | ✅ | Filter/join on one column |
| Composite | `CREATE INDEX ON (col1, col2)` | ❌ | ✅ | Filter on multiple columns together |
| Covering | Composite covering SELECT columns | ❌ | ✅ | Read-heavy queries, max speed |
| Unique | `CREATE UNIQUE INDEX ON (col)` | ✅ | ✅ (multiple NULLs ok) | No duplicates (email, username) |
| Primary Key | Auto-created on `id` | ✅ | ❌ | Always exists, identifies each row |

---

## 4. When NOT to Use Indexes

Indexes speed up reads but **slow down writes**. Every INSERT, UPDATE, DELETE must update all indexes on that table.

### Rule 1: Low-cardinality columns

**Cardinality** = number of distinct values. If a column only has 3–5 distinct values (status, boolean), the index barely helps.

```sql
-- BAD: status has only 3 values
CREATE INDEX idx_orders_status ON orders(status);

-- GOOD: use as second column in a composite index instead
CREATE INDEX idx_orders_user_status ON orders(user_id, status);
```

**Rule:** If a column has very few distinct values (boolean, status, gender), skip the index.

### Rule 2: Small tables

Full table scan on 10 rows is instant. Index overhead costs more than it saves.

**Rule:** Don't index tables with fewer than a few thousand rows — the scan is already instant and the index maintenance cost is not worth it.

### Rule 3: Columns rarely used in WHERE / JOIN / ORDER BY

If a column is never queried in real application code, you're paying the write cost for zero benefit.

**Rule:** Only index columns that actually appear in `WHERE`, `JOIN ON`, or `ORDER BY` in real application queries — not columns that just exist in the table.

### Rule 4: Frequently updated columns

Every update to an indexed column forces MySQL to update the index too. High-frequency updates + index = serious write overhead.

```sql
-- last_seen updates on every user request — avoid indexing
-- CREATE INDEX idx_users_last_seen ON users(last_seen);
```

**Rule:** Avoid indexing columns that change constantly (e.g. `last_seen`, `updated_at`, counters) — the write overhead outweighs any read benefit.

### Rule 5: Functions on indexed columns in WHERE ⚠️

Using a function on an indexed column in WHERE **breaks the index entirely**.

```sql
-- Index on email exists — but this bypasses it:
WHERE UPPER(email) = 'YASH@GMAIL.COM'   -- type = ALL ⚠️

-- This uses the index correctly:
WHERE email = 'yash@gmail.com'           -- type = const ✅

-- Same trap with dates:
WHERE YEAR(created_at) = 2024            -- index bypassed ⚠️
-- Fix:
WHERE created_at >= '2024-01-01' AND created_at < '2025-01-01'  -- ✅
```

**Rule:** Never wrap an indexed column in a function inside `WHERE`. Always search the raw stored value — the index only knows the value as it was inserted.

### Decision chart

```
Is the column used in WHERE / JOIN / ORDER BY?
        ↓ No  → Don't index
        ↓ Yes
Does it have high cardinality (many distinct values)?
        ↓ No  → Don't index
        ↓ Yes
Is the table large enough to matter?
        ↓ No  → Don't index
        ↓ Yes → Index it ✅
```

---

## Key Rules Learned This Week

| Rule | Explanation |
|------|-------------|
| `type = ALL` in EXPLAIN | Full table scan — index missing or not used |
| `type = ref` | Non-unique index lookup — good |
| `type = const` | PRIMARY KEY or UNIQUE match — best possible |
| `key = NULL` | No index used |
| `Extra = Using index` | Covering index — zero table access |
| `Extra = Using where` | Index used but table access still needed |
| Left-prefix rule | Composite index (a,b) — can't skip column a |
| Duplicate indexes | MySQL allows them but they waste storage + slow writes |
| Function trap | `WHERE UPPER(col)` breaks index — always search raw value |
| Write tax | Every extra index slows down INSERT/UPDATE/DELETE |

---

## Questions Asked During Week 5 Learning

### Q1: What does `cost` mean in EXPLAIN output?

The `cost` shown in `EXPLAIN ANALYZE` is MySQL's **internal relative estimate**, not milliseconds. It's calculated as `rows × cost constants` (each operation type has a fixed cost weight). It's used by the optimizer to compare execution plans and pick the cheapest one.

You cannot use cost directly to benchmark production performance — it's just a relative number on dev data. For real performance evaluation: use `EXPLAIN ANALYZE` for actual timing, benchmark with 100k+ rows, and watch the `type` and `rows` columns.

---

### Q2: How do I know if a query is good enough for production?

Dev data is always too small to measure real performance. For production evaluation:

1. Look at `type` in EXPLAIN — `ALL` on large tables is a red flag
2. Look at `rows` — how many rows will MySQL examine?
3. Use `EXPLAIN ANALYZE` to get real execution time
4. Benchmark with realistic data volume (100k+ rows minimum)
5. Watch slow query logs in production — MySQL can log queries over a threshold

A query that takes 2ms on 5 rows might take 4 seconds on 5 million rows if `type = ALL`.

---

### Q3: Why does EXPLAIN return 2 rows for a JOIN query?

EXPLAIN shows **one row per table accessed** in the query. A JOIN between `users` and `orders` touches 2 tables → 2 rows in EXPLAIN output. Each row describes how MySQL accesses that specific table — type, key, and rows are per-table metrics.

---

### Q4: What is "Table scan" and how can I identify it?

`Table scan` appears in `EXPLAIN ANALYZE` output. It means MySQL is reading every single row in the table sequentially. You identify it by:

- `EXPLAIN FORMAT=TRADITIONAL` → `type = ALL`
- `EXPLAIN ANALYZE` → `-> Table scan on <table>`
- `key = NULL` (no index used)

The `cost` value (e.g., `0.75`) is MySQL's estimate based on `rows × cost_constant`. A full scan on 5 rows costs ~0.75. The same scan on 5 million rows costs proportionally more.

---

### Q5: What happens if I create a duplicate index?

MySQL **allows it without error**. It silently creates a second identical index structure. This wastes storage, slows down all writes (every INSERT/UPDATE/DELETE must update both), and the optimizer picks one randomly — the other is never used. Always run `SHOW INDEX FROM table` before creating a new index to avoid duplicates.

---

### Q6: What is the difference between a unique index and a regular index?

A regular index only speeds up lookups. A **unique index** does both — it speeds up lookups AND enforces that no two rows can have the same value in that column. Same read performance. The difference is the uniqueness constraint enforced at the database level (throws `ERROR 1062` on duplicate insert). Use unique indexes for columns like `email`, `username`, `phone` — anything that must never repeat.

---

### Q7: What is the difference between a Primary Key index and a Unique index? Can you insert NULL into a unique column?

A Primary Key and a Unique Index both enforce uniqueness and both auto-create an index — but they differ in three ways:

- **NULL:** Primary Key never allows NULL. Unique Index allows NULL, and you can insert multiple NULLs because MySQL treats each NULL as "unknown" — two unknowns are never considered equal.
- **Count per table:** Only one Primary Key per table. Multiple Unique Indexes allowed.
- **Purpose:** Primary Key identifies the row. Unique Index just prevents duplicate values.

```sql
-- phone is UNIQUE but nullable
INSERT INTO users (name, phone) VALUES ('Rahul', NULL);  -- ✅
INSERT INTO users (name, phone) VALUES ('Priya', NULL);  -- ✅ second NULL allowed

-- Primary Key cannot be NULL
INSERT INTO users (id, name) VALUES (NULL, 'Yash');
-- ERROR 1048: Column 'id' cannot be null
```

Use `UNIQUE NOT NULL` for required fields (email, username). Use `UNIQUE` alone for optional fields (phone) where the value may not always be provided.

---

*SQL Learning Journey — Yash Verma | Week 5 of 6 (Indexes ✅ | Transactions ⏳)*
