# SQL Learning Journey — Week 2: JOINs

**Author:** Yash Verma
**Database:** MySQL
**Date:** May 2026
**Status:** ✅ Completed

---

## Topics Covered

| # | Topic | Description |
|---|-------|-------------|
| 1 | INNER JOIN | Returns only rows with a match in both tables |
| 2 | LEFT JOIN | All rows from left table + NULLs for unmatched right rows |
| 3 | RIGHT JOIN | All rows from right table + NULLs for unmatched left rows |
| 4 | CROSS JOIN | Every possible combination of rows from both tables |
| 5 | SELF JOIN | A table joined with itself |
| 6 | Multiple JOINs | Joining 3+ tables in one query |
| 7 | GROUP BY | Group rows and run aggregates per group |
| 8 | HAVING | Filter groups after GROUP BY |

---

## Database Setup for Week 2

A new `order_items` table was added to connect `orders` and `products`:

```sql
CREATE TABLE order_items (
  id         INT AUTO_INCREMENT PRIMARY KEY,
  order_id   INT NOT NULL,
  product_id INT NOT NULL,
  quantity   INT DEFAULT 1,
  unit_price DECIMAL(10, 2) NOT NULL
);
```

**Tables used this week:**

| Table | Role |
|-------|------|
| `users` | Customer information |
| `orders` | Order header — one row per order |
| `order_items` | Order lines — one row per product per order |
| `products` | Product catalogue |
| `employees` | Used for SELF JOIN demo |

---

## 1. INNER JOIN

Returns **only rows with a match in both tables**. No match = excluded from result.

```sql
-- Get all orders WITH customer name
SELECT
  o.id            AS order_id,
  u.name          AS customer_name,
  u.city,
  o.total_amount,
  o.status
FROM orders o
INNER JOIN users u ON o.user_id = u.id;
```

### Add WHERE filter on top of JOIN

```sql
-- Only delivered orders with customer names
SELECT
  u.name        AS customer_name,
  o.total_amount,
  o.status
FROM orders o
INNER JOIN users u ON o.user_id = u.id
WHERE o.status = 'delivered';
```

### Key point
Users with no orders (Karan, Meera, Yash) are **excluded** from INNER JOIN results. Use LEFT JOIN to include them.

---

## 2. LEFT JOIN

Returns **all rows from the left table** + matching rows from the right. If no match on right → `NULL` is shown.

```sql
-- All users including those with no orders
SELECT
  u.name          AS customer_name,
  u.city,
  o.id            AS order_id,
  o.total_amount,
  o.status
FROM users u
LEFT JOIN orders o ON u.id = o.user_id;
```

### Find users who NEVER placed an order

```sql
SELECT
  u.name    AS customer_name,
  u.email
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
WHERE o.id IS NULL;
```

> The trick: after LEFT JOIN, unmatched rows have NULL on the right side. Filter `WHERE right_table.id IS NULL` to find them.

### Count orders per user (including 0)

```sql
SELECT
  u.name              AS customer_name,
  COUNT(o.id)         AS total_orders,
  SUM(o.total_amount) AS total_spent
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
GROUP BY u.id, u.name
ORDER BY total_orders DESC;
```

---

## 3. RIGHT JOIN

Returns **all rows from the right table** + matching rows from the left. Opposite of LEFT JOIN.

```sql
SELECT
  u.name        AS customer_name,
  o.id          AS order_id,
  o.total_amount,
  o.status
FROM users u
RIGHT JOIN orders o ON u.id = o.user_id;
```

### Key point

RIGHT JOIN is rarely used in practice. Any RIGHT JOIN can be rewritten as a LEFT JOIN by swapping the tables:

```sql
-- These two queries give identical results:

-- RIGHT JOIN
FROM users u RIGHT JOIN orders o ON u.id = o.user_id

-- LEFT JOIN (swapped tables) — preferred
FROM orders o LEFT JOIN users u ON o.user_id = u.id
```

---

## 4. CROSS JOIN

Returns **every possible combination** of rows from both tables. No `ON` condition needed.

```sql
SELECT
  u.name    AS customer_name,
  p.name    AS product_name,
  p.price
FROM users u
CROSS JOIN products p
ORDER BY u.name;
```

**Result:** 8 users × 5 products = **40 rows**

### When to use
- Generating test data
- Creating matrix reports (every product × every city)
- Building schedules (every employee × every time slot)

> ⚠️ Warning: If you forget the `ON` condition in a regular JOIN, you accidentally create a CROSS JOIN and get way too many rows!

---

## 5. SELF JOIN

Joins a table **with itself**. Used when rows in a table have a relationship with other rows in the same table.

```sql
-- Employee org chart — who reports to whom
SELECT
  e.name   AS employee_name,
  e.role   AS employee_role,
  m.name   AS manager_name,
  m.role   AS manager_role
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.id;
```

We alias the same table twice — `e` for employee, `m` for manager.

### Find direct reports of a specific manager

```sql
SELECT
  e.name  AS employee_name,
  e.role  AS employee_role,
  m.name  AS manager_name
FROM employees e
INNER JOIN employees m ON e.manager_id = m.id
WHERE m.name = 'Priya Nair';
```

### Real world use cases

| Table | Self-referencing column | Use case |
|-------|------------------------|----------|
| `employees` | `manager_id → id` | Org chart |
| `categories` | `parent_id → id` | Category → Subcategory |
| `users` | `referred_by → id` | Referral system |
| `comments` | `parent_id → id` | Reply to a comment |

---

## 6. Multiple JOINs (3+ Tables)

Real backend API queries almost always join 3 or more tables. Chain JOINs one after another.

```sql
-- Full order receipt — connects 4 tables
SELECT
  u.name                          AS customer_name,
  o.id                            AS order_id,
  o.status                        AS order_status,
  p.name                          AS product_name,
  oi.quantity,
  oi.unit_price,
  (oi.quantity * oi.unit_price)   AS line_total
FROM orders o
INNER JOIN users       u  ON o.user_id       = u.id
INNER JOIN order_items oi ON o.id            = oi.order_id
INNER JOIN products    p  ON oi.product_id   = p.id
ORDER BY o.id;
```

### How the chain works

```
orders
  │
  ├──► users        (o.user_id = u.id)      → customer name
  ├──► order_items  (o.id = oi.order_id)    → quantity & price
  └──► products     (oi.product_id = p.id)  → product name
```

### Filter to a specific order

```sql
SELECT
  o.id                          AS order_id,
  o.status                      AS order_status,
  oi.quantity,
  u.name                        AS customer_name,
  oi.unit_price,
  (oi.quantity * oi.unit_price) AS line_total,
  p.name                        AS product_name
FROM orders o
INNER JOIN order_items oi ON o.id          = oi.order_id
INNER JOIN users       u  ON o.user_id     = u.id
INNER JOIN products    p  ON oi.product_id = p.id
WHERE o.id = 3
ORDER BY o.id;
```

### Frontend analogy

```javascript
// Without JOIN — 4 separate API calls:
const order    = await getOrder(3)
const user     = await getUser(order.user_id)
const items    = await getOrderItems(order.id)
const products = await getProducts(items.map(i => i.product_id))

// With JOIN — one single query does all of that!
SELECT ... FROM orders
JOIN users ON ...
JOIN order_items ON ...
JOIN products ON ...
WHERE o.id = 3
```

---

## 7. GROUP BY

Groups rows with the same value into a single summary row so you can run aggregate functions per group.

```sql
-- Count orders per user
SELECT
  u.name          AS customer_name,
  COUNT(o.id)     AS total_orders,
  SUM(o.total_amount) AS total_spent
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
GROUP BY u.id, u.name
ORDER BY total_spent DESC;
```

### COUNT(o.id) vs COUNT(*)

| | Users with no orders |
|--|------|
| `COUNT(*)` | Returns `1` ← wrong! counts NULL row |
| `COUNT(o.id)` | Returns `0` ← correct! skips NULLs |

> Always use `COUNT(column)` when counting rows from a JOINed table.

---

## 8. HAVING

Filters **after** GROUP BY. WHERE filters before grouping, HAVING filters after.

```sql
-- Users who placed at least 1 order AND spent more than 200
SELECT
  u.name              AS customer_name,
  SUM(o.total_amount) AS total_spent
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
GROUP BY u.id, u.name
HAVING COUNT(o.id) >= 1 AND total_spent > 200;
```

### WHERE vs HAVING

| Clause | Filters | Used with |
|--------|---------|-----------|
| `WHERE` | Individual rows before grouping | Always |
| `HAVING` | Groups after grouping | Requires GROUP BY |

---

## JOIN Comparison Summary

| JOIN Type | Returns | Use when |
|-----------|---------|----------|
| INNER JOIN | Only matched rows | You only want rows with data on both sides |
| LEFT JOIN | All left + NULLs for unmatched | You want all left rows even without a match |
| RIGHT JOIN | All right + NULLs for unmatched | Rarely — rewrite as LEFT JOIN instead |
| CROSS JOIN | Every combination | Generating combinations/matrices |
| SELF JOIN | Table joined with itself | Table has self-referencing column |

---

## Key Rules Learned This Week

| Rule | Explanation |
|------|-------------|
| Always alias tables | `FROM orders o` — keeps queries readable |
| Use `m.name` in WHERE not alias | Aliases in SELECT not available in WHERE clause |
| `WHERE` before `HAVING` | Filter rows first, then filter groups |
| `COUNT(o.id)` not `COUNT(*)` | Avoids counting NULL rows from LEFT JOIN |
| RIGHT JOIN = LEFT JOIN swapped | Prefer LEFT JOIN for readability |
| CROSS JOIN = no ON condition | Multiplies all rows — use carefully |

---

---

## Questions Asked During Week 2 Learning

### Q1: Why do we get 2 rows for order 3 in a multiple JOIN query?

Because order 3 has **2 products** in the `order_items` table. When JOIN connects `orders → order_items`, order 3 matches 2 rows in `order_items` — so the result has 2 rows. One order → many items → many rows.

---

### Q2: What is the relationship between orders and order_items?

They have a **One-to-Many** relationship:
- 1 order can have **many** items
- Each item belongs to **1** order

`order_items.order_id` is a **Foreign Key** pointing to `orders.id`. This is why we write `JOIN order_items oi ON o.id = oi.order_id` — it's the bridge between the two tables.

---

### Q3: Why split orders and order_items into two tables?

Bad design — everything in one table:
```
orders
id | user | product1 | price1 | product2 | price2 | product3 | price3
```
Problems: wasted columns, hard to query, breaks when order has many products.

Good design — two tables:
```
orders      → one row per order (header info)
order_items → one row per product line (detail info)
```
This is called **normalization** — covered properly in Week 6.

---

### Q4: What is the difference between COUNT(o.id) and COUNT(*)?

After a LEFT JOIN, users with no orders get a NULL row:
```
name   | order_id
-------|----------
Karan  |  NULL
```
- `COUNT(*)` counts that NULL row → returns `1` (wrong!)
- `COUNT(o.id)` skips NULL values → returns `0` (correct!)

---

### Q5: Why write GROUP BY u.id, u.name — why two columns?

Two separate reasons:
1. **SQL Rules** — `u.name` is in SELECT and not an aggregate, so it must be in GROUP BY
2. **Actual Grouping** — `u.id` does the real grouping work (unique per user); `u.name` just follows the rule

MySQL allows `GROUP BY u.id` alone (because id is PRIMARY KEY), but PostgreSQL/Oracle/SQL Server will throw an error. Always write both for portability.

---

### Q6: Does MySQL allow GROUP BY u.id without u.name?

Yes — MySQL uses **functional dependency**. Since `u.id` is PRIMARY KEY, MySQL knows only one `name` exists per `id`, so it's safe to show `name` without grouping by it.

But PostgreSQL, SQL Server, and Oracle are strict and will throw an error. Always include all SELECT columns in GROUP BY for portable queries.

---

### Q7: What happens when you GROUP BY multiple columns?

MySQL groups rows where **both values match together**:
```sql
GROUP BY u.city, o.status
-- one row per unique city + status combination
```

Rule: More columns in GROUP BY → more specific groups → more rows in result.

---

### Q8: Does SELF JOIN only work on the same table?

Yes! SELF JOIN is always on the same table — that's what makes it "self". You alias the same table twice to distinguish the two roles:
```sql
FROM employees e          -- e = the employee
LEFT JOIN employees m     -- m = the manager (same table!)
ON e.manager_id = m.id
```

---

### Q9: I used HAVING instead of WHERE without GROUP BY — what's wrong?

`HAVING` requires `GROUP BY`. Without it, using `HAVING` is incorrect even if MySQL runs it:

```sql
-- ❌ Wrong — no GROUP BY but using HAVING
WHERE m.name = "Priya Nair"   -- should be WHERE, not HAVING

-- ✅ Correct
WHERE m.name = "Priya Nair"
```

Also — aliases defined in SELECT are **not available** in WHERE. Use the actual column with table prefix:
```sql
WHERE m.name = "Priya Nair"   -- ✅ real column
WHERE manager_name = "Priya Nair"  -- ❌ alias, not available in WHERE
```

---

### Q10: Why is RIGHT JOIN rarely used?

Any RIGHT JOIN can be rewritten as a LEFT JOIN by swapping the tables — same result, more readable:
```sql
-- RIGHT JOIN
FROM users u RIGHT JOIN orders o ON u.id = o.user_id

-- Equivalent LEFT JOIN (preferred)
FROM orders o LEFT JOIN users u ON o.user_id = u.id
```
LEFT JOIN reads more naturally left-to-right, so it's the standard in real codebases.

---

*SQL Learning Journey — Yash Verma | Week 2 of 6*
