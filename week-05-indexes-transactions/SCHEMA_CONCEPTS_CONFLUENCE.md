# SQL Learning Journey — Concept: Cardinality, Junction Tables & Normalization

**Author:** Yash Verma
**Database:** MySQL
**Date:** May 2026
**Status:** ✅ Completed

---

## Topics Covered

| # | Topic | Description |
|---|-------|-------------|
| 1 | Cardinality | Column cardinality + relationship types (1:1, 1:N, M:N) |
| 2 | Junction Table | What it is, why it exists, how to build one |
| 3 | Composite Key | Multi-column keys and composite primary keys |
| 4 | Normalization | 1NF, 2NF, 3NF — eliminating redundancy |

---

## 1. Cardinality

Cardinality shows up in two different contexts in databases — both use the same word but mean slightly different things.

---

### Context 1: Column Cardinality (Index context)

How many **distinct values** a column has.

```sql
SELECT COUNT(DISTINCT status)  FROM orders;   -- 3  → low cardinality
SELECT COUNT(DISTINCT user_id) FROM orders;   -- ~5 → medium cardinality
SELECT COUNT(DISTINCT id)      FROM users;    -- 5  → high cardinality (all unique)
```

| Column | Distinct Values | Cardinality |
|--------|----------------|-------------|
| `users.id` | Every row unique | High |
| `users.email` | Every row unique | High |
| `orders.user_id` | Many distinct users | Medium-High |
| `orders.status` | 3 values only | Low |
| `users.city` | A few cities | Low-Medium |

**Why it matters for indexes:** High cardinality columns benefit most from indexing. A low cardinality column like `status` (only 3 values) gives MySQL very little to narrow down — it may scan the whole table anyway.

---

### Context 2: Relationship Cardinality (Schema context)

Describes **how tables relate to each other** — how many rows on one side match how many rows on the other.

---

#### One-to-One (1:1)

One row in table A matches exactly one row in table B.

```
users              user_profiles
------             -------------
id = 1    →        user_id = 1
id = 2    →        user_id = 2
```

Real examples: user → passport, employee → salary record, person → national ID

```sql
CREATE TABLE user_profiles (
  id      INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT UNIQUE,          -- UNIQUE enforces the 1:1 relationship
  bio     TEXT,
  avatar  VARCHAR(255),
  FOREIGN KEY (user_id) REFERENCES users(id)
);
```

The `UNIQUE` constraint on `user_id` ensures no two profiles can point to the same user.

---

#### One-to-Many (1:N) — most common

One row in table A matches **many rows** in table B.

```
users              orders
------             ------
id = 1    →        user_id = 1  (order #10)
                   user_id = 1  (order #11)
                   user_id = 1  (order #12)
id = 2    →        user_id = 2  (order #13)
```

Real examples: user → orders, category → products, author → posts, teacher → students

The foreign key always goes on the **many** side:

```sql
-- orders is the "many" side — it holds the foreign key
ALTER TABLE orders ADD FOREIGN KEY (user_id) REFERENCES users(id);
```

---

#### Many-to-Many (M:N)

Many rows in table A match many rows in table B. Requires a **junction table**.

```
students          courses
--------          -------
Yash      ←→     SQL Basics
Yash      ←→     System Design
Rahul     ←→     SQL Basics
```

You can't store this in just two tables — you need a third table to represent the relationship.

---

### Quick Reference

| Type | Example | How to implement |
|------|---------|-----------------|
| 1:1 | user → profile | `UNIQUE` foreign key on child table |
| 1:N | user → orders | Foreign key on the many side |
| M:N | order ↔ product | Junction table |

---

## 2. Junction Table

A **junction table** (also called a bridge table or associative table) sits between two other tables to handle a Many-to-Many relationship.

---

### Why You Need It

You can't directly link two tables in a M:N relationship.

❌ Can't store it in `orders`:
```
orders
------
id | user_id | product_id
1  | 1       | ???   ← what if the order has 3 products?
```

❌ Can't store it in `products`:
```
products
--------
id | name   | order_id
1  | Laptop | ???   ← what if the laptop appears in 50 orders?
```

✅ Create a third table — the junction table:

```
orders            order_items (junction)       products
------            ----------------------       --------
id = 1    →       order_id=1, product_id=3 →   id=3 (Laptop)
                  order_id=1, product_id=5 →   id=5 (Mouse)
id = 2    →       order_id=2, product_id=3 →   id=3 (Laptop)
```

---

### Creating a Junction Table

```sql
CREATE TABLE order_items (
  order_id   INT,
  product_id INT,
  quantity   INT,
  unit_price DECIMAL(10,2),
  PRIMARY KEY (order_id, product_id),  -- composite PK prevents duplicates
  FOREIGN KEY (order_id)   REFERENCES orders(id),
  FOREIGN KEY (product_id) REFERENCES products(id)
);
```

The composite primary key `(order_id, product_id)` ensures the same product can't appear twice in the same order.

---

### Querying Through a Junction Table

```sql
-- Which products are in order #1?
SELECT p.name, oi.quantity
FROM order_items oi
JOIN products p ON oi.product_id = p.id
WHERE oi.order_id = 1;

-- Which orders contain a Laptop?
SELECT o.id, o.total_amount
FROM order_items oi
JOIN orders o ON oi.order_id = o.id
WHERE oi.product_id = 3;
```

---

### Junction Tables Can Store Relationship Data

The junction table isn't just a bridge — it can hold data **about the relationship itself**.

```
quantity   → belongs to the relationship (not to order alone, not to product alone)
unit_price → the price at the time of purchase (product price may change later)
```

These values make sense only in the context of a specific order + product combination.

---

### Real-World Junction Tables

| Scenario | Table A | Junction Table | Table B |
|----------|---------|----------------|---------|
| E-commerce | orders | order_items | products |
| School | students | student_courses | courses |
| Social media | users | user_follows | users |
| Movies | movies | movie_actors | actors |
| Tags | posts | post_tags | tags |

---

## 3. Composite Key

A **composite key** is a key made up of **two or more columns together** that uniquely identify a row — instead of a single column doing it alone.

---

### Why You Need It

Sometimes no single column is unique enough on its own, but the combination of two columns always is.

```
order_items
-----------
order_id | product_id | quantity
1        | 3          | 2
1        | 5          | 1    ← order_id 1 again, but different product
2        | 3          | 1    ← product_id 3 again, but different order
```

- `order_id` alone → not unique (one order has many products)
- `product_id` alone → not unique (one product in many orders)
- `(order_id + product_id)` together → always unique ✅

---

### Composite Primary Key

```sql
CREATE TABLE order_items (
  order_id   INT,
  product_id INT,
  quantity   INT,
  unit_price DECIMAL(10,2),
  PRIMARY KEY (order_id, product_id)   -- composite primary key
);
```

```sql
INSERT INTO order_items VALUES (1, 3, 2, 80000);  -- ✅
INSERT INTO order_items VALUES (1, 5, 1, 500);    -- ✅ same order, different product
INSERT INTO order_items VALUES (1, 3, 1, 80000);  -- ❌ ERROR — duplicate combination
```

---

### Composite Key vs Composite Primary Key

| | Composite Key | Composite Primary Key |
|--|--------------|----------------------|
| What it is | Any multi-column key | Multi-column key set as PRIMARY KEY |
| NULL allowed | Depends on type | ❌ Never |
| How many per table | Multiple | Only one |
| Example | `UNIQUE(first_name, last_name)` | `PRIMARY KEY(order_id, product_id)` |

---

### Composite PK vs Surrogate ID

```sql
-- Option A: Composite Primary Key
PRIMARY KEY (order_id, product_id)

-- Option B: Surrogate id + Unique constraint
id INT PRIMARY KEY AUTO_INCREMENT,
UNIQUE (order_id, product_id)
```

| | Composite PK | Surrogate id |
|--|-------------|--------------|
| Storage | Slightly less (no extra id column) | Extra id column |
| JOIN syntax | Must join on both columns | Simple `JOIN ON id` |
| Best used for | Junction tables | Most other tables |

**Rule:** Use composite PK for junction tables. Use surrogate `id` for everything else.

---

## 4. Normalization

Normalization is the process of **organizing tables to eliminate redundancy and keep data clean**. The goal: store each piece of data in **exactly one place**.

---

### The Problem Normalization Solves

Imagine storing everything in one flat table:

```
orders_flat
-----------
order_id | user_name | user_email      | user_city | product_name | price | qty
1        | Yash      | yash@gmail.com  | Delhi     | Laptop       | 80000 | 1
2        | Yash      | yash@gmail.com  | Delhi     | Mouse        | 500   | 2
3        | Rahul     | rahul@gmail.com | Mumbai    | Keyboard     | 1500  | 1
```

Problems:
- Yash's email appears twice — if it changes, multiple rows need updating
- Delete all of Yash's orders → lose his city and email entirely
- Same product name/price stored repeatedly

---

### 1NF — First Normal Form

**Rule: Each column must hold a single atomic value. No repeating groups.**

❌ Violates 1NF — multiple values in one cell:
```
order_id | products
1        | "Laptop, Mouse, Keyboard"
```

✅ Follows 1NF — one value per cell:
```
order_id | product
1        | Laptop
1        | Mouse
1        | Keyboard
```

Our tables already follow 1NF.

---

### 2NF — Second Normal Form

**Rule: Must be in 1NF + every non-key column must depend on the ENTIRE primary key.**

This only matters when you have a composite primary key.

❌ Violates 2NF — `product_name` depends only on `product_id`, not on the full key `(order_id, product_id)`:
```
order_items
-----------
order_id | product_id | product_name | quantity
```

This is called a **partial dependency** — `product_name` only needs `product_id` to be known.

✅ Fix — split it out:
```
order_items                    products
-----------                    --------
order_id | product_id | qty    product_id | product_name | price
              ↑                     ↑
              └────────────────────┘
              product_name moved to products table
```

This is exactly how our schema is built — `order_items` stores no product name, just a `product_id` that JOINs to `products`.

---

### 3NF — Third Normal Form

**Rule: Must be in 2NF + no column should depend on another non-key column.**

This is called a **transitive dependency**.

❌ Violates 3NF — `city_zip_code` depends on `city`, not on `id`:
```
users
-----
id | name | city   | city_zip_code
1  | Yash | Delhi  | 110001
2  | Bob  | Mumbai | 400001
```

If Delhi's zip code changes, you update every single user from Delhi.

✅ Fix — move zip to its own table:
```
users                      cities
-----                      ------
id | name | city_id        city_id | city_name | zip_code
              ↑                ↑
              └───────────────┘
              zip lives here now — changed in one place
```

---

### Our Schema is Already Normalized

```
users         → stores only user data
products      → stores only product data
orders        → stores order + user_id FK (no user details repeated)
order_items   → junction: order_id + product_id + quantity + unit_price
```

Each piece of data lives in exactly one place. You JOIN to combine — not duplicate.

---

### When to Denormalize

Normalization is the rule — but sometimes you **intentionally break it** for performance.

```sql
-- total_amount could be computed from SUM(order_items)
-- but stored directly on orders for fast reads
orders.total_amount  ← intentionally denormalized
```

Trade-off: slightly redundant data in exchange for avoiding expensive JOINs on every request. Common in analytics and reporting tables.

---

### Normal Forms Summary

| Normal Form | Rule | What It Fixes |
|-------------|------|---------------|
| 1NF | Atomic values, no repeating groups | Multiple values in one cell |
| 2NF | No partial dependencies on composite key | Column depending on part of composite PK |
| 3NF | No transitive dependencies | Column depending on another non-key column |

---

## Key Rules Learned

| Rule | Explanation |
|------|-------------|
| High cardinality = good index candidate | More distinct values = more useful the index |
| Low cardinality alone = bad index | `status` with 3 values gives MySQL little to narrow down |
| M:N relationship needs a junction table | Can't store it in either of the two main tables |
| Junction table holds relationship data | `quantity`, `unit_price` belong to the relationship itself |
| 1NF | One value per cell — no comma-separated lists |
| 2NF | Non-key columns must depend on full composite key |
| 3NF | No column should depend on another non-key column |
| Denormalize only for performance | Always normalize first, denormalize only when needed |

---

## Questions Asked

### Q1: What is cardinality?

Cardinality has two meanings in databases. In the **index context**, it means the number of distinct values in a column — high cardinality (like `id`, `email`) makes a column a good index candidate, low cardinality (like `status` with 3 values) makes it a poor one. In the **schema context**, it describes the relationship type between tables — One-to-One (1:1), One-to-Many (1:N), or Many-to-Many (M:N).

---

### Q2: What is a junction table?

A junction table is a third table created specifically to handle a Many-to-Many relationship between two tables. Neither of the two main tables can store the relationship directly — for example, `orders` can't hold multiple product IDs in one row, and `products` can't hold multiple order IDs. The junction table (`order_items`) sits between them and stores one row per combination. It can also store data about the relationship itself, like `quantity` and `unit_price`.

---

### Q3: What is a composite key and composite primary key?

A **composite key** is any key made up of two or more columns. A **composite primary key** is when that multi-column combination is designated as the PRIMARY KEY of the table. Neither column alone is unique — but together they always are. Used most commonly on junction tables where `(order_id, product_id)` together uniquely identifies each row.

---

### Q4: What is normalization?

Normalization is the process of organizing tables to eliminate data redundancy. The goal is to store each fact in exactly one place — so if something changes, you update it in one place only. It's done progressively through Normal Forms: 1NF (atomic values), 2NF (no partial dependencies), 3NF (no transitive dependencies). Most production databases target 3NF. Intentional denormalization happens only when performance requires it.

---

*SQL Learning Journey — Yash Verma | Concept Doc: Cardinality, Junction Tables & Normalization*
