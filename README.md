# SQL-Playground

A structured, hands-on SQL learning project — built while transitioning from Frontend to Full Stack development. Each week is a self-contained module with theory, working examples, and practice challenges.

**Stack:** MySQL 8+
**Duration:** 6 Weeks
**Author:** [Yash Verma](https://github.com/YashLT224)

---

## Learning Roadmap

| Week | Topic | Status |
|------|-------|--------|
| Week 1 | DDL + Basic DML (CREATE, INSERT, SELECT, UPDATE, DELETE) | Completed |
| Week 2 | JOINs (INNER, LEFT, RIGHT, CROSS, SELF, Multiple JOINs) | Completed |
| Week 3 | Aggregations (COUNT, SUM, AVG, MIN, MAX, DISTINCT, COALESCE) | Completed |
| Week 4 | Subqueries & CTEs | Completed |
| Week 5 | Indexes, EXPLAIN, Transactions & ACID | Completed |
| Week 6 | Schema Design & Real-World Patterns | Completed |

---

## Folder Structure

```
sql-learning-journey/
├── week-01-ddl-basics/
│   ├── 01_create_tables.sql      → CREATE TABLE, data types, constraints
│   ├── 02_insert_data.sql        → INSERT single and bulk rows
│   ├── 03_select_queries.sql     → SELECT, WHERE, LIKE, ORDER BY, LIMIT
│   ├── 04_update_delete.sql      → UPDATE, DELETE, soft deletes
│   └── 05_alter_table.sql        → ALTER TABLE, add/drop/rename columns
│
├── week-02-joins/
│   ├── 01_setup_data.sql         → Seed data for join examples
│   ├── 02_inner_join.sql         → INNER JOIN fundamentals
│   ├── 03_left_right_join.sql    → LEFT / RIGHT outer joins
│   ├── 04_self_join.sql          → Self joins (employee → manager)
│   └── 05_multiple_joins.sql     → Chaining 3+ tables
│
├── week-03-aggregations/
│   ├── 01_count.sql              → COUNT(*) vs COUNT(col) vs COUNT(DISTINCT)
│   ├── 02_sum_avg_min_max.sql    → Numeric aggregations + GROUP BY
│   ├── 03_distinct.sql           → DISTINCT and de-duplication
│   ├── 04_coalesce.sql           → Handling NULLs with COALESCE / IFNULL
│   └── 05_real_business_queries.sql → Realistic reporting queries
│
├── week-04-subqueries-cte/
│   ├── 01_subqueries_where.sql   → Scalar & list subqueries in WHERE
│   ├── 02_subqueries_from.sql    → Derived tables in FROM
│   ├── 03_subqueries_select.sql  → Correlated subqueries in SELECT
│   ├── 04_exists_not_exists.sql  → EXISTS vs IN performance
│   └── 05_ctes.sql               → WITH clauses & recursive CTEs
│
├── week-05-indexes-transactions/
│   ├── 01_what_is_index.sql          → How indexes work (B-Tree intuition)
│   ├── 02_explain_query_plan.sql     → Reading EXPLAIN output
│   ├── 03_create_index.sql           → CREATE INDEX, before/after comparison
│   ├── 04_index_types.sql            → Composite, covering, unique indexes
│   ├── 05_when_not_to_index.sql      → Anti-patterns & write-amplification
│   ├── 06_transactions.sql           → COMMIT, ROLLBACK, SAVEPOINT
│   ├── WEEK5_CONFLUENCE.md           → Indexes week notes + Q&A
│   ├── TRANSACTIONS_CONFLUENCE.md    → Transactions & ACID notes + Q&A
│   ├── FOREIGN_KEYS_CONFLUENCE.md    → Foreign keys deep dive + Q&A
│   └── SCHEMA_CONCEPTS_CONFLUENCE.md → Cardinality, normalization, junction tables
│
└── week-06-schema-design/
    ├── 01_schema_design_principles.sql → 6 principles before writing SQL
    ├── 02_naming_conventions.sql       → Tables, columns, FK, index naming
    ├── 03_create_blog_schema.sql       → Full blog schema CREATE TABLE
    ├── 04_seed_data.sql                → INSERT data for all 5 tables
    ├── 05_blog_queries.sql             → 8 real queries on blog data
    └── WEEK6_CONFLUENCE.md             → Week 6 notes + Q&A
```

Each week also ships a `WEEKx_CONFLUENCE.md` — long-form notes summarizing the week's learnings.

---

## How to Use

1. Install MySQL 8+ locally, or spin up a free cloud DB (e.g. [PlanetScale](https://planetscale.com), [Neon](https://neon.tech), [Railway](https://railway.app)).
2. Open a SQL client — MySQL Workbench, TablePlus, DBeaver, or `mysql` CLI.
3. Create a working database once:
   ```sql
   CREATE DATABASE practice_db;
   USE practice_db;
   ```
4. Run the files **in order** within each week's folder — later files often depend on tables/data from earlier ones.
5. Every file follows the same structure:
   - Theory comments explaining the concept
   - Working SQL examples you can run as-is
   - Practice challenges at the bottom

---

## Concepts Covered

### Week 1 — DDL + Basic DML
- **DDL:** `CREATE TABLE`, `ALTER TABLE`, `DROP TABLE`, `TRUNCATE`
- **DML:** `INSERT`, `SELECT`, `UPDATE`, `DELETE`
- Data types: `INT`, `VARCHAR`, `TEXT`, `DECIMAL`, `BOOLEAN`, `DATETIME`
- Constraints: `NOT NULL`, `UNIQUE`, `DEFAULT`, `PRIMARY KEY`, `AUTO_INCREMENT`
- Filtering: `WHERE`, `AND/OR`, `IN`, `BETWEEN`, `LIKE`, `IS NULL`
- Sorting & pagination: `ORDER BY`, `LIMIT`, `OFFSET`
- Soft delete pattern using `deleted_at`

### Week 2 — JOINs
- `INNER JOIN`, `LEFT JOIN`, `RIGHT JOIN`, `CROSS JOIN`
- Self joins (e.g. employees → managers)
- Joining 3+ tables and reading execution order
- Mental model: which rows survive each join type

### Week 3 — Aggregations
- `COUNT(*)` vs `COUNT(column)` vs `COUNT(DISTINCT column)`
- `SUM`, `AVG`, `MIN`, `MAX` with `GROUP BY`
- `HAVING` vs `WHERE` — when each runs
- `COALESCE` / `IFNULL` for NULL-safe aggregations

### Week 4 — Subqueries & CTEs
- Subqueries in `WHERE`, `FROM`, and `SELECT`
- Correlated vs non-correlated subqueries
- `EXISTS` vs `IN` and when each is faster
- Common Table Expressions (`WITH`) and recursive CTEs

### Week 5 — Indexes, Performance & Transactions
- B-Tree intuition: why indexes make lookups O(log n)
- Reading `EXPLAIN` output: `type`, `key`, `rows`, `Extra` columns
- Single-column, composite, covering, and unique indexes
- Left-prefix rule for composite indexes
- When NOT to index: low cardinality, small tables, function trap
- Transactions: `START TRANSACTION`, `COMMIT`, `ROLLBACK`, `SAVEPOINT`
- ACID Properties: Atomicity, Consistency, Isolation, Durability
- Bonus concepts: Foreign Keys, Cardinality, Normalization (1NF→3NF), Junction Tables

### Week 6 — Schema Design & Real-World Patterns
- 6 schema design principles (entities, constraints, timestamps)
- Industry naming conventions (tables, columns, FKs, indexes, booleans)
- Built a real blog platform schema: `blog_users`, `posts`, `tags`, `post_tags`, `comments`
- M:N relationships via junction tables
- `GROUP_CONCAT` — collapse multiple rows into one string
- Real queries: JOINs, aggregations, CTEs, subqueries on live blog data
- Common bug: `ON p.user_id = p.user_id` vs `ON p.user_id = u.id`

---

## Key Takeaways So Far

- Always use `WHERE` with `UPDATE` / `DELETE` — without it, **every** row is affected.
- Prefer **soft deletes** (`deleted_at`) over hard deletes in production.
- Use `DECIMAL(10,2)` for money — never `FLOAT` (binary rounding errors).
- `AUTO_INCREMENT` handles ID generation — never insert IDs manually.
- `LEFT JOIN` + `WHERE right.col IS NULL` is the canonical "find rows with no match" pattern.
- `EXISTS` is usually faster than `IN` on large subqueries — it short-circuits on first match.
- Every index speeds up reads but slows down writes — index with intent, not by reflex.
- Always wrap multi-step writes in a transaction — partial failures leave data in a broken state.
- `ROLLBACK` is your safety net — use it on any error inside a transaction.
- `NOT NULL`, `UNIQUE`, `CHECK`, and `FOREIGN KEY` constraints enforce data integrity at the DB level.

---

## Resources

- [MySQL 8.0 Reference Manual](https://dev.mysql.com/doc/refman/8.0/en/)
- [LeetCode — Top SQL 50](https://leetcode.com/studyplan/top-sql-50/)
- [SQLZoo Interactive Practice](https://sqlzoo.net/)
- [Use The Index, Luke!](https://use-the-index-luke.com/) — indexing & query performance
- [Markus Winand — Modern SQL](https://modern-sql.com/)

---

## License

MIT — free to fork, learn from, and adapt.
