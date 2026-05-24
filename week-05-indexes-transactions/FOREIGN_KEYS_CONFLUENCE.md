# SQL Learning Journey — Concept: Foreign Keys

**Author:** Yash Verma
**Database:** MySQL
**Date:** May 2026
**Status:** ✅ Completed

---

## What is a Foreign Key?

A **foreign key** is a column in one table that **points to the primary key of another table**. It creates a link between two tables and enforces that the relationship always stays valid.

Without a foreign key, you could insert nonsense data:

```sql
-- user_id 999 doesn't exist in users table
INSERT INTO orders (user_id, total_amount) VALUES (999, 5000);
-- MySQL allows it ← dangerous! Creates an orphan row
```

With a foreign key, MySQL blocks this automatically and throws an error.

---

## Syntax

```sql
CREATE TABLE orders (
  id           INT PRIMARY KEY AUTO_INCREMENT,
  user_id      INT,
  total_amount DECIMAL(10,2),
  FOREIGN KEY (user_id) REFERENCES users(id)
  --           ↑ column in THIS table    ↑ column in OTHER table
);
```

---

## Foreign Keys in Our Schema

```
users (id) ←──── orders (user_id)
                      │
orders (id) ←──── order_items (order_id)
products (id) ←── order_items (product_id)
```

```sql
-- orders references users
FOREIGN KEY (user_id) REFERENCES users(id)

-- order_items references both orders and products
FOREIGN KEY (order_id)   REFERENCES orders(id)
FOREIGN KEY (product_id) REFERENCES products(id)
```

---

## What Foreign Keys Enforce

### 1. Insert Protection

Can't insert a child row with no matching parent.

```sql
INSERT INTO orders (user_id, total_amount) VALUES (999, 500);
-- ERROR 1452: Cannot add or update a child row:
-- a foreign key constraint fails (user_id 999 doesn't exist in users)
```

### 2. Delete Protection

Can't delete a parent row that has children pointing to it.

```sql
DELETE FROM users WHERE id = 1;
-- ERROR 1451: Cannot delete or update a parent row:
-- a foreign key constraint fails (orders still reference this user)
```

---

## ON DELETE Behavior

You can control what happens to child rows when a parent is deleted.

```sql
FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
-- Deleting a user automatically deletes all their orders too

FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
-- Deleting a user sets user_id = NULL on their orders

FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE RESTRICT
-- Default — blocks the delete if children exist
```

| Option | Behavior |
|--------|---------|
| `RESTRICT` | Block the delete — default |
| `CASCADE` | Delete child rows automatically |
| `SET NULL` | Set FK column to NULL in child rows |

---

## ON UPDATE Behavior

Same options apply when a parent's primary key is updated.

```sql
FOREIGN KEY (user_id) REFERENCES users(id)
  ON DELETE RESTRICT
  ON UPDATE CASCADE
```

With `ON UPDATE CASCADE`:

```sql
UPDATE users SET id = 99 WHERE id = 1;
-- ✅ MySQL automatically updates user_id = 99 in ALL orders that had user_id = 1
```

| Option | Behavior |
|--------|---------|
| `RESTRICT` | Block the update — default |
| `CASCADE` | Update child rows automatically |
| `SET NULL` | Set FK column to NULL in child rows |

---

## Foreign Key vs JOIN

These are two different things that work together:

| | Foreign Key | JOIN |
|--|------------|------|
| What it does | Enforces valid relationships | Combines data from tables |
| When it runs | On INSERT / UPDATE / DELETE | On SELECT |
| Purpose | Data integrity | Querying |

Foreign key ensures the data is valid. JOIN uses that valid data to combine tables in queries.

---

## Inspecting Foreign Keys — Useful Queries

### 1. DESC — see columns and key flags

```sql
DESC orders;
```

Output:
```
Field        | Type          | Null | Key | Default | Extra
-------------|---------------|------|-----|---------|---------------
id           | int           | NO   | PRI | NULL    | auto_increment
user_id      | int           | YES  | MUL | NULL    |
total_amount | decimal(10,2) | YES  |     | NULL    |
status       | varchar(50)   | YES  |     | NULL    |
```

The **Key column** tells you:

| Key value | Meaning |
|-----------|---------|
| `PRI` | Primary key |
| `UNI` | Unique index |
| `MUL` | Foreign key or non-unique index |

`DESC` does not show which table a FK points to — use the queries below for that.

---

### 2. information_schema — see FK details

```sql
SELECT
  COLUMN_NAME,
  CONSTRAINT_NAME,
  REFERENCED_TABLE_NAME,
  REFERENCED_COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_NAME = 'orders'
  AND TABLE_SCHEMA = 'practice_db'
  AND REFERENCED_TABLE_NAME IS NOT NULL;
```

Output:
```
COLUMN_NAME | CONSTRAINT_NAME | REFERENCED_TABLE_NAME | REFERENCED_COLUMN_NAME
------------|-----------------|-----------------------|----------------------
user_id     | orders_ibfk_1   | users                 | id
```

This clearly tells you — `orders.user_id` points to `users.id`.

---

### 3. SHOW CREATE TABLE — full definition

```sql
SHOW CREATE TABLE orders;
```

Output:
```sql
CREATE TABLE `orders` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `total_amount` decimal(10,2) DEFAULT NULL,
  `status` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_orders_user_id` (`user_id`),
  CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
)
```

Most complete view — shows primary key, all indexes, and all foreign keys in one shot.

---

### Quick Reference

| Query | Shows |
|-------|-------|
| `DESC orders` | Columns, types, PRI/UNI/MUL key flags |
| `SHOW INDEX FROM orders` | All indexes with details |
| `SHOW CREATE TABLE orders` | Full table definition including all FKs |
| `information_schema` query | FK details — which column → which table |

---

## Key Rules

| Rule | Explanation |
|------|-------------|
| FK enforces insert integrity | Can't insert a child row with no matching parent |
| FK enforces delete integrity | Can't delete a parent row with existing children (by default) |
| `ON DELETE CASCADE` | Deleting parent deletes all children automatically |
| `ON UPDATE CASCADE` | Updating parent PK updates all child FKs automatically |
| `MUL` in DESC | Means FK or non-unique index — use `SHOW CREATE TABLE` to know which |
| Never update primary keys | PKs are internal identifiers — they should never change |

---

## Questions Asked

### Q1: What is a foreign key?

A foreign key is a column in one table that points to the primary key of another table. It enforces referential integrity — you can't insert a row that references a non-existent parent, and you can't delete a parent row that has children pointing to it. It's the database-level enforcement of table relationships.

---

### Q2: What if I want to update a user_id (primary key)?

By default MySQL blocks it with `RESTRICT`. You can change this with `ON UPDATE CASCADE` — when the parent's PK changes, MySQL automatically updates all child FK columns to match.

However, in practice **you should never update a primary key**. The `id` column is an internal identifier with no business meaning — users don't care what their id number is. Business data columns like `email`, `name`, `city` can change. The `id` never should. If your design requires updating a PK, that's a sign of a schema design problem.

```sql
-- Correct: update business data
UPDATE users SET email = 'newyash@gmail.com' WHERE id = 1;  -- ✅

-- Wrong pattern: updating the identifier itself
UPDATE users SET id = 99 WHERE id = 1;  -- ❌ bad design
```

---

### Q3: How can I know on what column a primary key and foreign key are applied?

Three queries, each showing different levels of detail:

```sql
-- Quick overview — Key column shows PRI, UNI, MUL
DESC orders;

-- Full definition — shows exact FK constraints and referenced tables
SHOW CREATE TABLE orders;

-- Detailed FK info — column name, referenced table, referenced column
SELECT COLUMN_NAME, REFERENCED_TABLE_NAME, REFERENCED_COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_NAME = 'orders'
  AND TABLE_SCHEMA = 'practice_db'
  AND REFERENCED_TABLE_NAME IS NOT NULL;
```

Use `SHOW CREATE TABLE` when you want the most complete picture in one query.

---

*SQL Learning Journey — Yash Verma | Concept Doc: Foreign Keys*
