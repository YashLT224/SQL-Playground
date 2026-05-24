# SQL Learning Journey — Week 3: Aggregations

**Author:** Yash Verma
**Database:** MySQL
**Date:** May 2026
**Status:** ✅ Completed

---

## Topics Covered

| # | Topic | Description |
|---|-------|-------------|
| 1 | COUNT | Count number of rows |
| 2 | SUM | Add up values |
| 3 | AVG + ROUND | Calculate average, clean up decimals |
| 4 | MIN / MAX | Find smallest / largest value |
| 5 | GROUP BY | Group rows and aggregate per group |
| 6 | HAVING | Filter groups after aggregation |
| 7 | DISTINCT | Remove duplicate values |
| 8 | COALESCE | Handle NULLs with default values |
| 9 | WHERE vs HAVING | When to use which |
| 10 | Real Business Queries | Putting it all together |

---

## What are Aggregations?

Aggregations summarize data — instead of seeing every row, you get calculated results across multiple rows.

```sql
-- Without aggregation — 6 rows
SELECT total_amount FROM orders;

-- With aggregation — 1 summarized result
SELECT SUM(total_amount) FROM orders;
-- 4683.74
```

---

## 1. COUNT

Counts the number of rows in a result.

```sql
-- COUNT all rows
SELECT COUNT(*) AS total_users    FROM users;     -- 8
SELECT COUNT(*) AS total_products FROM products;  -- 5
SELECT COUNT(*) AS total_orders   FROM orders;    -- 6

-- COUNT with WHERE
SELECT COUNT(*) AS pending_orders FROM orders WHERE status = 'pending';
SELECT COUNT(*) AS active_users   FROM users  WHERE is_active = 1;

-- COUNT with GROUP BY
SELECT status, COUNT(*) AS total FROM orders GROUP BY status;
SELECT city,   COUNT(*) AS total FROM users  GROUP BY city ORDER BY total DESC;

-- COUNT DISTINCT — unique values only
SELECT COUNT(DISTINCT city)       AS unique_cities     FROM users;
SELECT COUNT(DISTINCT user_id)    AS unique_customers  FROM orders;
SELECT COUNT(DISTINCT product_id) AS unique_products   FROM order_items;
```

### COUNT(*) vs COUNT(column)

| | Users with no orders |
|--|------|
| `COUNT(*)` | Returns `1` ← wrong! counts the NULL row |
| `COUNT(o.id)` | Returns `0` ← correct! skips NULLs |

> Always use `COUNT(column)` when counting rows from a JOINed table.

---

## 2. SUM, AVG, MIN, MAX

```sql
-- Total revenue
SELECT SUM(total_amount) AS total_revenue FROM orders;  -- 4683.74

-- Average order value (use ROUND to clean up)
SELECT ROUND(AVG(total_amount), 2) AS avg_order_value FROM orders;  -- 780.62

-- Smallest and largest
SELECT MIN(total_amount) AS smallest_order,
       MAX(total_amount) AS largest_order FROM orders;

-- All aggregates together with GROUP BY
SELECT
  status,
  COUNT(*)                        AS total_orders,
  SUM(total_amount)               AS total_revenue,
  ROUND(AVG(total_amount), 2)     AS avg_order_value,
  MIN(total_amount)               AS min_order,
  MAX(total_amount)               AS max_order
FROM orders
GROUP BY status;
```

### ROUND

```sql
ROUND(value, decimal_places)

ROUND(780.623333, 2)  → 780.62
ROUND(780.623333, 0)  → 781
```

> Always use `ROUND` with AVG to avoid messy decimals like `780.623333`.

---

## 3. DISTINCT

Removes duplicate values — returns only unique values.

```sql
-- Without DISTINCT — all rows
SELECT city FROM users;

-- With DISTINCT — unique only
SELECT DISTINCT city FROM users;

-- DISTINCT on multiple columns — unique COMBINATIONS
SELECT DISTINCT city, is_active FROM users ORDER BY city;

-- COUNT DISTINCT
SELECT COUNT(DISTINCT city) AS unique_cities FROM users;
```

### Key Rule

```
DISTINCT on 1 column  → unique values of that column
DISTINCT on 2 columns → unique COMBINATIONS of both columns
```

---

## 4. COALESCE

Returns the **first non-NULL value** from a list. Used to replace NULLs with a default.

```sql
-- Without COALESCE — users with no orders show NULL
SELECT u.name, SUM(o.total_amount) AS total_spent
FROM users u LEFT JOIN orders o ON u.id = o.user_id
GROUP BY u.id, u.name;
-- Yash Verma  | NULL  ← looks broken

-- With COALESCE — NULLs replaced with 0
SELECT u.name, COALESCE(SUM(o.total_amount), 0) AS total_spent
FROM users u LEFT JOIN orders o ON u.id = o.user_id
GROUP BY u.id, u.name;
-- Yash Verma  | 0.00  ← clean!

-- Text fallback
SELECT u.name, COALESCE(u.city, 'City not set') AS city FROM users;

-- Full customer report
SELECT
  u.name,
  COALESCE(u.city, 'City not set')            AS city,
  COALESCE(SUM(o.total_amount), 0)            AS total_spent,
  COUNT(o.id)                                  AS total_orders
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
GROUP BY u.id, u.name, u.city
ORDER BY total_spent DESC;
```

> Always wrap SUM, AVG, MIN, MAX with COALESCE when using LEFT JOIN.

---

## 5. WHERE vs HAVING

| | WHERE | HAVING |
|--|-------|--------|
| Filters | Individual rows | Groups |
| Runs | Before GROUP BY | After GROUP BY |
| Works with | Any column | Aggregate functions |
| Requires | Nothing | GROUP BY |

### SQL execution order

```
FROM → JOIN → WHERE → GROUP BY → HAVING → SELECT → ORDER BY
```

```sql
-- WHERE: filter rows before grouping
SELECT u.name, COUNT(o.id) AS total_orders
FROM users u LEFT JOIN orders o ON u.id = o.user_id
WHERE u.is_active = 1          -- runs first, removes inactive users
GROUP BY u.id, u.name;

-- HAVING: filter groups after grouping
SELECT u.name, COUNT(o.id) AS total_orders
FROM users u LEFT JOIN orders o ON u.id = o.user_id
GROUP BY u.id, u.name
HAVING COUNT(o.id) > 1;        -- runs after, removes groups with ≤1 order

-- Both together
SELECT u.name, COUNT(o.id) AS total_orders
FROM users u LEFT JOIN orders o ON u.id = o.user_id
WHERE u.is_active = 1           -- step 1: filter rows
GROUP BY u.id, u.name
HAVING COUNT(o.id) > 1;         -- step 2: filter groups
```

### Why can't you use WHERE for aggregates?

```sql
-- ❌ ERROR — COUNT doesn't exist at WHERE stage
WHERE COUNT(o.id) > 1

-- ✅ Correct — use HAVING
HAVING COUNT(o.id) > 1
```

---

## 6. Real Business Queries

### Revenue Dashboard
```sql
SELECT
  COUNT(*)                        AS total_orders,
  SUM(total_amount)               AS total_revenue,
  ROUND(AVG(total_amount), 2)     AS avg_order_value,
  MIN(total_amount)               AS smallest_order,
  MAX(total_amount)               AS largest_order
FROM orders;
```

### Top Customers by Spending
```sql
SELECT
  u.name                           AS customer_name,
  COUNT(o.id)                      AS total_orders,
  COALESCE(SUM(o.total_amount), 0) AS total_spent
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
GROUP BY u.id, u.name
ORDER BY total_spent DESC;
```

### Top Selling Products
```sql
SELECT
  p.name                          AS product_name,
  COALESCE(SUM(oi.quantity), 0)   AS total_qty_sold,
  COALESCE(SUM(oi.quantity * oi.unit_price), 0) AS total_revenue
FROM products p
LEFT JOIN order_items oi ON p.id = oi.product_id
GROUP BY p.id, p.name, p.price
ORDER BY total_qty_sold DESC;
```

### High Value Customers (spent > 500)
```sql
SELECT
  u.name                          AS customer_name,
  COUNT(o.id)                     AS total_orders,
  SUM(o.total_amount)             AS total_spent
FROM users u
INNER JOIN orders o ON u.id = o.user_id
GROUP BY u.id, u.name
HAVING SUM(o.total_amount) > 500
ORDER BY total_spent DESC;
```

---

## Key Rules Learned This Week

| Rule | Explanation |
|------|-------------|
| `COUNT(o.id)` not `COUNT(*)` | Skips NULLs — correctly shows 0 for unmatched LEFT JOIN rows |
| Always `ROUND(AVG(...), 2)` | Avoids messy decimals like 780.623333 |
| `COALESCE(SUM(...), 0)` | Replace NULL with 0 for unmatched LEFT JOIN rows |
| `WHERE` before grouping | Filter raw rows — cannot use aggregate functions |
| `HAVING` after grouping | Filter groups — must use aggregate functions |
| `DISTINCT` on 2 columns | Returns unique combinations, not unique per column |

---

---

## Questions Asked During Week 3 Learning

### Q1: What is the difference between COUNT(*) and COUNT(column)?

After a LEFT JOIN, unmatched rows show NULL in the right table columns:
```
name   | order_id
-------|----------
Yash   | NULL
```
- `COUNT(*)` counts that NULL row → returns `1` (wrong!)
- `COUNT(o.id)` skips NULL values → returns `0` (correct!)

**Rule:** Always use `COUNT(column)` when counting from a JOINed table.

---

### Q2: What is the difference between WHERE and HAVING?

| | WHERE | HAVING |
|--|-------|--------|
| Filters | Individual rows | Groups |
| Runs | Before GROUP BY | After GROUP BY |

You cannot use aggregate functions in WHERE because at that stage, rows haven't been grouped yet — COUNT/SUM don't exist yet. Use HAVING to filter on aggregate results.

---

### Q3: What does DISTINCT on multiple columns do?

`DISTINCT` on multiple columns returns unique **combinations** of those columns — not unique values of each column separately.

```sql
SELECT DISTINCT is_active, city FROM users;
-- Returns one row per unique (is_active + city) combination
-- NOT unique is_active values + unique city values separately
```

---

### Q4: Why do we need COALESCE?

After a LEFT JOIN, users with no orders show NULL for SUM:
```
Yash Verma   | NULL  ← looks broken in a real app
```
COALESCE replaces NULL with a meaningful default:
```sql
COALESCE(SUM(o.total_amount), 0)  → 0.00 ✅
COALESCE(u.city, 'City not set')  → 'City not set' ✅
```

---

*SQL Learning Journey — Yash Verma | Week 3 of 6*
