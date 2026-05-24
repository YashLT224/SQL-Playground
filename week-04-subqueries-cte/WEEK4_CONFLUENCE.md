# SQL Learning Journey — Week 4: Subqueries & CTEs

**Author:** Yash Verma
**Database:** MySQL
**Date:** May 2026
**Status:** ✅ Completed

---

## Topics Covered

| # | Topic | Description |
|---|-------|-------------|
| 1 | Subqueries in WHERE | Filter rows using inner query results |
| 2 | Subqueries in FROM | Use a query result as a temporary table |
| 3 | Subqueries in SELECT | Add computed columns per row (scalar subquery) |
| 4 | EXISTS / NOT EXISTS | Check whether matching rows exist |
| 5 | CTEs (WITH clause) | Named temporary result sets for clean, readable queries |

---

## What are Subqueries?

A **subquery** is a query nested inside another query. The inner query runs first and its result is used by the outer query.

```sql
-- Simple subquery example
SELECT name, price
FROM products
WHERE price = (SELECT MAX(price) FROM products);
```

Subqueries can appear in three places: **WHERE**, **FROM**, and **SELECT**.

---

## 1. Subqueries in WHERE

Used to filter rows based on values computed by an inner query.

```sql
-- Find users who have placed at least one order
SELECT name, email
FROM users
WHERE id IN (
  SELECT DISTINCT user_id FROM orders
);

-- Find orders above the average order value
SELECT id, user_id, total_amount
FROM orders
WHERE total_amount > (SELECT AVG(total_amount) FROM orders)
ORDER BY total_amount DESC;

-- Find products never ordered
SELECT name, price
FROM products
WHERE id NOT IN (
  SELECT DISTINCT product_id FROM order_items
);
```

### Key Rules
- Use `=` when the subquery returns exactly ONE value
- Use `IN` / `NOT IN` when the subquery returns a list of values
- Use `> / < / >=` when comparing to a single aggregate (MAX, MIN, AVG)

---

## 2. Subqueries in FROM

Used to create a temporary table (inline view) to query from.

```sql
-- Product revenue summary
SELECT p.name AS product_name, pr.total_revenue
FROM (
  SELECT product_id, SUM(quantity * unit_price) AS total_revenue
  FROM order_items
  GROUP BY product_id
) AS pr
JOIN products p ON pr.product_id = p.id
ORDER BY pr.total_revenue DESC;

-- High spenders only
SELECT *
FROM (
  SELECT user_id, SUM(total_amount) AS total_spent
  FROM orders
  GROUP BY user_id
) AS spending
WHERE spending.total_spent > 500;
```

### Key Rules
- The subquery in FROM **must have an alias** (MySQL requires it)
- Think of the inner query as a temporary table you're selecting from
- `ORDER BY total_revenue` and `ORDER BY product_revenue.total_revenue` both work in MySQL — the alias is resolved automatically

---

## 3. Subqueries in SELECT

Used to add a computed column per row. The subquery returns exactly one value (scalar subquery).

```sql
-- Each product with overall average price alongside
SELECT
  name,
  price,
  (SELECT ROUND(AVG(price), 2) FROM products) AS avg_price
FROM products;

-- Each user with their personal total spending (correlated)
SELECT
  u.name,
  u.city,
  (
    SELECT COALESCE(SUM(o.total_amount), 0)
    FROM orders o
    WHERE o.user_id = u.id
  ) AS total_spent
FROM users u
ORDER BY total_spent DESC;
```

### Correlated Subquery
A correlated subquery references the outer query's current row. It runs once per row.

```sql
-- o.user_id = u.id  ← references outer row
-- This makes it "correlated" — it adapts per row
```

### Key Rule
The scalar subquery must return **exactly ONE value**. If it returns multiple rows, MySQL throws an error.

---

## 4. EXISTS & NOT EXISTS

`EXISTS` checks whether a subquery returns **any rows at all**. Returns TRUE or FALSE.

```sql
-- Users who have placed at least one order
SELECT u.name, u.email
FROM users u
WHERE EXISTS (
  SELECT 1
  FROM orders o
  WHERE o.user_id = u.id
);

-- Users who have NEVER placed an order
SELECT u.name, u.email
FROM users u
WHERE NOT EXISTS (
  SELECT 1
  FROM orders o
  WHERE o.user_id = u.id
);

-- Users with at least one DELIVERED order
SELECT u.name
FROM users u
WHERE EXISTS (
  SELECT 1
  FROM orders o
  WHERE o.user_id = u.id
    AND o.status = 'delivered'
);
```

### EXISTS vs IN

| | IN | EXISTS |
|--|----|----|
| Returns | List of values | TRUE/FALSE |
| Stops early? | No | Yes — stops at first match |
| Best for | Small lists | Large datasets, correlated checks |
| NULLs | Risky with NOT IN | Safe with NOT EXISTS |

```sql
-- Both return the same result:
WHERE id IN (SELECT DISTINCT user_id FROM orders)
WHERE EXISTS (SELECT 1 FROM orders o WHERE o.user_id = u.id)
```

### What is SELECT 1?
`SELECT 1` is a placeholder inside EXISTS. It returns the number `1` for every matching row — no actual column data is fetched. This makes it more efficient than `SELECT *`.

```sql
EXISTS (SELECT 1 FROM orders WHERE user_id = u.id)
--              ↑
--   "I don't care what's here,
--    just tell me if ANYTHING is here"
```

---

## 5. CTEs (WITH Clause)

A **CTE (Common Table Expression)** is a temporary named result set defined at the top of a query using `WITH`.

Think of it as giving a name to a subquery so you can reference it cleanly — like a variable for a query.

```sql
-- Syntax
WITH cte_name AS (
  SELECT ...
)
SELECT * FROM cte_name;
```

### Basic CTE

```sql
WITH user_spending AS (
  SELECT user_id, SUM(total_amount) AS total_spent
  FROM orders
  GROUP BY user_id
)
SELECT * FROM user_spending
ORDER BY total_spent DESC;
```

### CTE + JOIN

```sql
WITH user_spending AS (
  SELECT user_id, SUM(total_amount) AS total_spent
  FROM orders
  GROUP BY user_id
)
SELECT
  u.name,
  u.city,
  COALESCE(s.total_spent, 0) AS total_spent
FROM users u
LEFT JOIN user_spending s ON u.id = s.user_id
ORDER BY total_spent DESC;
```

### Multiple Chained CTEs

```sql
WITH
  order_totals AS (
    SELECT user_id, COUNT(*) AS total_orders, SUM(total_amount) AS total_spent
    FROM orders
    GROUP BY user_id
  ),
  high_value AS (
    SELECT user_id FROM order_totals
    WHERE total_spent > 500
  )
SELECT u.name, u.email
FROM users u
WHERE u.id IN (SELECT user_id FROM high_value);
```

### CTE vs Subquery

| | Subquery | CTE |
|--|----------|-----|
| Use when | Simple, one-time use | Complex, multi-step logic |
| Readability | Gets messy when nested | Stays clean |
| Reusability | Cannot reuse | Can reference multiple times |
| Best for | Quick filters | Dashboards, reports, multi-step queries |

Both produce identical results. CTEs are preferred in real production code for readability.

---

## Key Rules Learned This Week

| Rule | Explanation |
|------|-------------|
| Subquery in WHERE with `=` | Inner query must return exactly one value |
| Subquery in WHERE with `IN` | Inner query returns a list of values |
| Subquery in FROM needs alias | MySQL requires every derived table to have a name |
| Scalar subquery returns one value | If it returns multiple rows → error |
| `EXISTS` stops at first match | More efficient than `IN` for large tables |
| `NOT EXISTS` is safer than `NOT IN` | `NOT IN` breaks with NULLs in the list |
| `SELECT 1` in EXISTS | Placeholder — no column fetching needed |
| CTEs improve readability | Same result as subqueries, but cleaner |
| Multiple CTEs can chain | Later CTEs can reference earlier CTEs |

---

## Questions Asked During Week 4 Learning

### Q1: What is the difference between a subquery in WHERE vs FROM?

**WHERE subquery** filters rows using a computed value:
```sql
WHERE price > (SELECT AVG(price) FROM products)
```

**FROM subquery** creates a temporary table you select from:
```sql
SELECT * FROM (SELECT user_id, SUM(...) AS total FROM orders GROUP BY user_id) AS t
```

Use WHERE subquery when filtering. Use FROM subquery when you need to aggregate first, then query that aggregated result.

---

### Q2: What is the difference between `ORDER BY total_revenue` and `ORDER BY product_revenue.total_revenue`?

Both work in MySQL. The alias `total_revenue` is defined inside the subquery and MySQL resolves it automatically in ORDER BY. The qualified form `product_revenue.total_revenue` explicitly references the subquery alias — more readable when there are multiple tables with similar column names.

---

### Q3: What was the issue with `SELECT p.name, AVG(price) FROM products p GROUP BY p.price`?

Two problems:
1. `GROUP BY p.price` groups by price values — so products with the same price get merged into one row, losing individual product names
2. `AVG(price)` within a group of same-priced items just returns that same price — the aggregation is meaningless

The fix: `GROUP BY p.id, p.name` — group by primary key so each product is its own group.

---

### Q4: What is the issue with `SELECT p.name, AVG(price) FROM products p` (no GROUP BY)?

This mixes a non-aggregate column (`p.name`) with an aggregate (`AVG(price)`) without GROUP BY.

**The Golden Rule:** If you use any aggregate function, every non-aggregated column in SELECT must appear in GROUP BY.

Without GROUP BY, MySQL (in strict mode) throws an error. In lenient mode it returns one row with an arbitrary name — not useful.

Fix: Either add `GROUP BY p.id, p.name`, or remove `p.name` if you only want the overall average.

---

### Q5: What is the difference between EXISTS and IN?

`IN` returns a list and checks membership:
```sql
WHERE id IN (SELECT user_id FROM orders)
-- MySQL fetches the full list first, then checks each id
```

`EXISTS` checks row existence and stops early:
```sql
WHERE EXISTS (SELECT 1 FROM orders WHERE user_id = u.id)
-- MySQL stops as soon as it finds ONE matching row
```

For large datasets, EXISTS is generally faster because it short-circuits. `NOT IN` is also risky when the subquery can return NULLs — `NOT EXISTS` is always safe.

---

### Q6: What is SELECT 1?

`SELECT 1` is a placeholder used inside EXISTS subqueries. It returns the number `1` for every matching row — no actual column data is fetched. Since EXISTS only cares whether a row exists (not what the row contains), `SELECT 1` signals that intent clearly and avoids unnecessary column fetching.

```sql
-- SELECT * fetches all columns — wasteful inside EXISTS
EXISTS (SELECT * FROM orders WHERE user_id = u.id)

-- SELECT 1 returns a dummy value — efficient and conventional ✅
EXISTS (SELECT 1 FROM orders WHERE user_id = u.id)
```

Both work identically. `SELECT 1` is the industry standard convention.

---

*SQL Learning Journey — Yash Verma | Week 4 of 6*
