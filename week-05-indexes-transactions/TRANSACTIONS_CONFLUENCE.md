# SQL Learning Journey — Concept: Transactions & ACID

**Author:** Yash Verma
**Database:** MySQL
**Date:** May 2026
**Status:** ✅ Completed

---

## Topics Covered

| # | Topic | Description |
|---|-------|-------------|
| 1 | What is a Transaction | Unit of work, why it matters |
| 2 | COMMIT | Save changes permanently |
| 3 | ROLLBACK | Undo all changes |
| 4 | SAVEPOINT | Partial rollback checkpoints |
| 5 | ACID Properties | Atomicity, Consistency, Isolation, Durability |

---

## What is a Transaction?

A transaction is a **group of SQL statements that must all succeed or all fail together**. You treat them as one single unit of work.

### The Problem Without Transactions

```sql
-- Transfer money between two accounts
UPDATE accounts SET balance = balance - 5000 WHERE id = 1;  -- Yash pays
UPDATE accounts SET balance = balance + 5000 WHERE id = 2;  -- Rahul receives
```

What if the first UPDATE succeeds but the server crashes before the second? Yash loses 5000 but Rahul never gets it. That's a disaster.

A transaction wraps both statements — **either both happen or neither happens**.

---

## Transaction Commands

```sql
START TRANSACTION;  -- begin a transaction block
COMMIT;             -- save all changes permanently
ROLLBACK;           -- undo everything back to START TRANSACTION
SAVEPOINT name;     -- mark a checkpoint inside the transaction
ROLLBACK TO name;   -- undo back to the savepoint only
```

---

## 1. COMMIT — Successful Transaction

```sql
START TRANSACTION;

UPDATE accounts SET balance = balance - 2000 WHERE id = 1;  -- Yash pays
UPDATE accounts SET balance = balance + 2000 WHERE id = 2;  -- Rahul receives

SELECT * FROM accounts;  -- changes visible to YOU mid-transaction

COMMIT;  -- save permanently

SELECT * FROM accounts;  -- Yash: 8000 | Rahul: 7000
```

After `COMMIT` — the changes are permanent. Even a server restart won't undo them. That's **Durability**.

---

## 2. ROLLBACK — Undo Everything

```sql
START TRANSACTION;

UPDATE accounts SET balance = balance - 9999 WHERE id = 1;

SELECT * FROM accounts;  -- Yash shows -1999 (visible mid-transaction)

ROLLBACK;  -- something went wrong — undo!

SELECT * FROM accounts;  -- Yash is back to original balance ✅
```

The `SELECT` inside the transaction shows the changed value — but `ROLLBACK` brings everything back. **Nothing was ever permanently saved.**

---

## 3. SAVEPOINT — Partial Rollback

A savepoint lets you roll back to a **specific checkpoint** inside a transaction — not all the way back to the start.

```sql
START TRANSACTION;

UPDATE accounts SET balance = balance - 1000 WHERE id = 1;  -- Step 1
SAVEPOINT after_step1;                                       -- mark here

UPDATE accounts SET balance = balance - 1000 WHERE id = 1;  -- Step 2
SELECT * FROM accounts;  -- Yash: 6000 (down 2000 total)

ROLLBACK TO after_step1;  -- undo Step 2 only, keep Step 1
SELECT * FROM accounts;   -- Yash: 7000 ✅

COMMIT;  -- save Step 1 permanently
```

Each run of this block deducted **1000 once** even though there were two deduct statements — the second was rolled back every time. Final balance after two runs: **6000**.

---

## 4. Real World Example — Order Placement

When a user places an order, multiple things must happen together. If any step fails, everything rolls back.

```sql
START TRANSACTION;

-- Step 1: Create the order
INSERT INTO orders (user_id, total_amount, status)
VALUES (1, 80500, 'pending');

-- Step 2: Add order items
INSERT INTO order_items (order_id, product_id, quantity, unit_price)
VALUES (LAST_INSERT_ID(), 3, 1, 80000);

INSERT INTO order_items (order_id, product_id, quantity, unit_price)
VALUES (LAST_INSERT_ID(), 5, 1, 500);

-- Step 3: Reduce stock
UPDATE products SET stock = stock - 1 WHERE id = 3;
UPDATE products SET stock = stock - 1 WHERE id = 5;

COMMIT;
```

If payment fails or stock goes negative → `ROLLBACK`. No orphan orders, no wrong stock numbers.

---

## 5. ACID Properties

ACID is a set of 4 properties that guarantee transactions are processed reliably.

---

### A — Atomicity

**"All or nothing."**

Every statement in a transaction either commits fully or rolls back completely. There is no partial state.

```sql
START TRANSACTION;
UPDATE accounts SET balance = balance - 5000 WHERE id = 1;
UPDATE accounts SET balance = balance + 5000 WHERE id = 2;
COMMIT;    -- both succeed → saved
-- or
ROLLBACK;  -- something failed → both undone
```

If the server crashes after the first UPDATE, MySQL rolls back automatically on restart — Yash's balance is restored.

---

### C — Consistency

**"The database must always go from one valid state to another valid state."**

All business rules and constraints must be satisfied before and after every transaction.

```sql
-- CHECK constraint: balance can never go negative
CREATE TABLE accounts (
  balance DECIMAL(10,2) CHECK (balance >= 0)
);

-- This transaction is rejected if it would make balance negative
UPDATE accounts SET balance = balance - 99999 WHERE id = 1;
-- Constraint violated → transaction fails → rolled back
```

`NOT NULL`, `FOREIGN KEY`, `UNIQUE`, and `CHECK` constraints are all part of consistency enforcement.

---

### I — Isolation

**"Concurrent transactions don't interfere with each other."**

If two transactions run at the same time, each sees a consistent view of the data — as if it were running alone.

```
Without isolation — the problem:

Transaction 1:              Transaction 2:
READ balance = 1000
                            READ balance = 1000
DEDUCT 500 → write 500
                            DEDUCT 300 → write 700  ← WRONG! Should be 200
```

Transaction 2 read stale data and overwrote Transaction 1's work. Isolation prevents this.

#### MySQL Isolation Levels

| Level | Behavior |
|-------|---------|
| `READ UNCOMMITTED` | Can read uncommitted changes from other transactions |
| `READ COMMITTED` | Only reads committed data |
| `REPEATABLE READ` | Same read returns same data within a transaction (MySQL default) |
| `SERIALIZABLE` | Transactions run one at a time — strictest |

---

### D — Durability

**"Once committed, data is permanently saved — even if the server crashes immediately after."**

```sql
COMMIT;
-- Power cuts right here ↑
-- Data is still there when server restarts ✅
```

MySQL writes committed transactions to disk before confirming success. The server can crash right after a `COMMIT` and the data will still be there on restart.

---

## ACID Summary

| Property | Guarantee | Example |
|----------|-----------|---------|
| **Atomicity** | All or nothing — no partial state | Money transfer: both debit and credit happen or neither does |
| **Consistency** | Database always in valid state | Balance can never go below 0 |
| **Isolation** | Concurrent transactions don't interfere | Two users booking last seat — only one succeeds |
| **Durability** | Committed = permanent | Server crash after COMMIT → data still saved |

---

## Key Rules

| Rule | Explanation |
|------|-------------|
| Always use transactions for multi-step writes | Any operation that touches multiple tables or rows |
| COMMIT makes changes permanent | Can't undo after COMMIT |
| ROLLBACK undoes everything since START TRANSACTION | Safe to use on any error |
| SAVEPOINT gives fine-grained control | Roll back part of a transaction, keep the rest |
| Mid-transaction changes are visible to you only | Other sessions see the old data until you COMMIT |
| Don't update primary keys | PKs are internal identifiers — they never change |

---

## Questions Asked

### Q1: Why does the balance go negative if there's no CHECK constraint?

Without a `CHECK (balance >= 0)` constraint, MySQL has no rule to enforce. It simply executes whatever you tell it. This is why constraints matter — they enforce business rules at the database level so no application bug or direct SQL can create invalid data.

```sql
-- Add this to prevent negative balances:
CHECK (balance >= 0)
-- Transaction is rejected if this would be violated
```

---

### Q2: Why did running the transaction twice stack up changes?

Because each `COMMIT` is permanent — Durability means committed changes survive forever. Running the same transaction twice simply applied the same deductions twice on top of each other. This is normal and expected behaviour. Always reset test data before re-running demos.

```sql
-- Reset helper
UPDATE accounts SET balance = 10000.00 WHERE id = 1;
UPDATE accounts SET balance = 5000.00  WHERE id = 2;
```

---

### Q3: What is the difference between ROLLBACK and ROLLBACK TO savepoint?

`ROLLBACK` undoes **everything** since `START TRANSACTION` — the entire transaction is cancelled. `ROLLBACK TO savepoint_name` only undoes changes made **after** that savepoint — everything before it is preserved and can still be committed. Savepoints give you fine-grained control inside complex transactions.

---

*SQL Learning Journey — Yash Verma | Concept Doc: Transactions & ACID*
