# SQL — GROUP BY Deep Dive

**Author:** Yash Verma
**Database:** MySQL
**Week:** 2 — JOINs & Aggregations
**Status:** ✅ Completed

---

## What is GROUP BY?

`GROUP BY` groups rows that have the **same value** in a column into a single summary row, so you can run aggregate functions (`COUNT`, `SUM`, `AVG`, `MIN`, `MAX`) on each group separately.

**Without GROUP BY** — aggregate counts ALL rows:
```sql
SELECT COUNT(o.id) FROM orders;
-- returns 5 (total across all orders)
```

**With GROUP BY** — aggregate counts PER group:
```sql
SELECT u.name, COUNT(o.id)
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
GROUP BY u.id, u.name;
-- returns count separately for each user
```

---

## Visual Breakdown

**Raw data after LEFT JOIN (before GROUP BY):**

| user_id | name | order_id | amount |
|---------|------|----------|--------|
| 8 | Tarun | 1 | 250.00 |
| 9 | Priya | 2 | 499.99 |
| 10 | Rahul | 3 | 1299.50 |
| 10 | Rahul | 4 | 75.25 |
| 16 | Karan | NULL | NULL |

**After GROUP BY u.id:**

| name | COUNT(o.id) | SUM(amount) |
|------|-------------|-------------|
| Tarun | 1 | 250.00 |
| Priya | 1 | 499.99 |
| Rahul | 2 | 1374.75 ← both rows merged |
| Karan | 0 | NULL |

---

## JavaScript Analogy

GROUP BY works like `.reduce()` grouped by a key:

```javascript
orders = [
  { user: "Tarun", amount: 250 },
  { user: "Priya", amount: 499 },
  { user: "Rahul", amount: 1299 },
  { user: "Rahul", amount: 75 },  // Rahul appears twice
]

// GROUP BY user is like:
orders.reduce((groups, order) => {
  groups[order.user].push(order)
  return groups
}, {})

// Result:
// Tarun → [250]        → COUNT=1, SUM=250
// Priya → [499]        → COUNT=1, SUM=499
// Rahul → [1299, 75]   → COUNT=2, SUM=1374
```

---

## Aggregate Functions with GROUP BY

```sql
-- COUNT — how many orders per user
SELECT u.name, COUNT(o.id) AS total_orders
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
GROUP BY u.id, u.name;

-- SUM — total amount spent per user
SELECT u.name, SUM(o.total_amount) AS total_spent
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
GROUP BY u.id, u.name;

-- AVG — average order value per user
SELECT u.name, AVG(o.total_amount) AS avg_order_value
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
GROUP BY u.id, u.name;

-- MIN / MAX — smallest and largest order per user
SELECT u.name,
       MIN(o.total_amount) AS smallest_order,
       MAX(o.total_amount) AS largest_order
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
GROUP BY u.id, u.name;

-- All aggregates together
SELECT
  u.name,
  COUNT(o.id)         AS total_orders,
  SUM(o.total_amount) AS total_spent,
  AVG(o.total_amount) AS avg_order_value,
  MAX(o.total_amount) AS biggest_order
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
GROUP BY u.id, u.name
ORDER BY total_spent DESC;
```

---

## Q: Why `COUNT(o.id)` and not `COUNT(*)`?

This was a key question — here is the difference:

| | Result for users with no orders |
|--|------|
| `COUNT(*)` | Returns `1` ← **wrong!** counts the NULL row |
| `COUNT(o.id)` | Returns `0` ← **correct!** skips NULL values |

After a LEFT JOIN, users with no orders get a row like:

```
name   | order_id
-------|----------
Karan  |  NULL
Meera  |  NULL
```

`COUNT(*)` counts that NULL row and returns `1`.
`COUNT(o.id)` skips NULL values and correctly returns `0`.

> **Rule:** Always use `COUNT(column)` when counting rows from a JOINed table. Only use `COUNT(*)` when you genuinely want to count all rows including NULLs.

---

## Q: Why `GROUP BY u.id, u.name` — why two columns?

There are **two separate reasons** to add a column to GROUP BY:

### Reason 1 — SQL Rules
If a column is in `SELECT` and is **not** an aggregate function, it must be in `GROUP BY`.

```sql
SELECT u.name, COUNT(o.id)   -- u.name is in SELECT, not an aggregate
GROUP BY u.id, u.name        -- so u.name must be in GROUP BY too
```

This is enforced strictly in PostgreSQL, Oracle, and SQL Server. MySQL is lenient when grouping by a primary key.

### Reason 2 — Actual Grouping Logic
Sometimes you add a column to GROUP BY because you **genuinely want to group by it** — creating one row per unique combination.

```sql
GROUP BY u.city, o.status
-- one row per city + status combination
-- not just because they're in SELECT, but because you want that breakdown
```

### Which applies to `u.name`?

```sql
GROUP BY u.id, u.name
```

- `u.id` → **Real grouping** — each unique user gets their own group
- `u.name` → **SQL rule** — it's in SELECT so must be listed here

`u.id` (primary key) is doing all the real grouping work. `u.name` is just following the SQL rule.

---

## Q: Does MySQL allow `GROUP BY u.id` without `u.name`?

Yes — because of **functional dependency**.

Since `u.id` is the PRIMARY KEY, MySQL knows:

> "If I know the `id`, there can only ever be one `name` for it. Safe to show `name` without grouping by it."

```sql
-- MySQL allows this ✅
SELECT u.name, COUNT(o.id)
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
GROUP BY u.id;
```

**But this is MySQL-only behaviour:**

| Database | `GROUP BY u.id` alone | `GROUP BY u.id, u.name` |
|----------|-----------------------|-------------------------|
| MySQL | ✅ Works | ✅ Works |
| PostgreSQL | ❌ Error | ✅ Works |
| SQL Server | ❌ Error | ✅ Works |
| Oracle | ❌ Error | ✅ Works |

> **Best practice:** Always write `GROUP BY u.id, u.name` so your queries work in any database.

---

## Q: What happens when you GROUP BY multiple columns?

When you GROUP BY two columns, MySQL groups rows where **both values match together**.

```sql
GROUP BY u.city, o.status
-- groups rows where BOTH city AND status are the same
```

**Example data:**

| name | city | status |
|------|------|--------|
| Tarun | hyderabad | pending |
| Priya | delhi | shipped |
| Rahul | pune | delivered |
| Ananya | bangalore | pending |

**After `GROUP BY u.city, o.status`:**

| city | status | total_orders |
|------|--------|-------------|
| hyderabad | pending | 1 |
| delhi | shipped | 1 |
| pune | delivered | 1 |
| bangalore | pending | 1 |

Each unique city + status combination becomes one row.

**Rule of thumb:**
> More columns in GROUP BY → more specific groups → more rows in result
> Fewer columns in GROUP BY → broader groups → fewer rows in result

---

## GROUP BY with Multiple Columns — Practical Example

```sql
-- Sales per city per order status
SELECT
  u.city,
  o.status,
  COUNT(o.id)           AS total_orders,
  SUM(o.total_amount)   AS total_revenue
FROM users u
INNER JOIN orders o ON u.id = o.user_id
GROUP BY u.city, o.status
ORDER BY u.city, o.status;
```

Output:
```
city        | status    | total_orders | total_revenue
------------|-----------|--------------|---------------
bangalore   | pending   |      1       |    75.25
delhi       | shipped   |      1       |   499.99
hyderabad   | pending   |      1       |   250.00
```

---

## HAVING — Filter After GROUP BY

`WHERE` filters rows **before** grouping. `HAVING` filters **after** grouping.

```sql
-- WHERE: filter individual rows before grouping
SELECT u.name, COUNT(o.id) AS total_orders
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
WHERE u.city = 'delhi'           -- only Delhi users included first
GROUP BY u.id, u.name;

-- HAVING: filter groups after grouping
SELECT u.name, COUNT(o.id) AS total_orders
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
GROUP BY u.id, u.name
HAVING COUNT(o.id) > 1;          -- only groups with more than 1 order

-- Both WHERE and HAVING together
SELECT u.name, COUNT(o.id) AS total_orders
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
WHERE u.is_active = 1            -- filter rows first
GROUP BY u.id, u.name
HAVING total_orders > 0;         -- then filter groups
```

---

## The Golden Rule of GROUP BY

> Every column in your `SELECT` must either be:
> 1. Inside an aggregate function → `COUNT()`, `SUM()`, `AVG()`, `MIN()`, `MAX()`
> 2. Inside the `GROUP BY` clause

```sql
-- ✅ Correct
SELECT u.name, u.city, COUNT(o.id)
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
GROUP BY u.id, u.name, u.city;

-- ❌ Wrong — city is in SELECT but not in GROUP BY
SELECT u.name, u.city, COUNT(o.id)
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
GROUP BY u.id, u.name;
-- PostgreSQL throws error. MySQL may silently pick a random city value!
```

---

## Summary

| Concept | Explanation |
|---------|-------------|
| `GROUP BY col` | One row per unique value of col |
| `GROUP BY col1, col2` | One row per unique combination of col1 + col2 |
| `COUNT(o.id)` | Counts non-NULL values — use with LEFT JOIN |
| `COUNT(*)` | Counts all rows including NULLs |
| `HAVING` | Filters after grouping (like WHERE but for groups) |
| `WHERE` | Filters before grouping (on raw rows) |
| MySQL leniency | Allows GROUP BY primary key alone — but don't rely on it |

---

*SQL Learning Journey — Yash Verma | Week 2 of 6*
