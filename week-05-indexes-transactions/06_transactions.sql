-- ============================================================
-- WEEK 5 | TOPIC 6: Transactions
-- ============================================================
-- A transaction is a group of SQL statements that must all
-- succeed or all fail together — treated as one unit of work.
--
-- Commands:
--   START TRANSACTION → begin a transaction block
--   COMMIT            → save all changes permanently
--   ROLLBACK          → undo everything back to START
--   SAVEPOINT name    → mark a checkpoint inside transaction
--   ROLLBACK TO name  → undo back to savepoint only
-- ============================================================

USE practice_db;

-- ============================================================
-- SETUP — create a demo accounts table
-- ============================================================

CREATE TABLE accounts (
  id      INT PRIMARY KEY AUTO_INCREMENT,
  name    VARCHAR(100),
  balance DECIMAL(10,2) CHECK (balance >= 0)
);

INSERT INTO accounts (name, balance) VALUES
('Yash',  10000.00),
('Rahul',  5000.00);

SELECT * FROM accounts;

-- ============================================================
-- BASIC COMMIT — successful transaction
-- ============================================================

START TRANSACTION;

UPDATE accounts SET balance = balance - 2000 WHERE id = 1;  -- Yash pays
UPDATE accounts SET balance = balance + 2000 WHERE id = 2;  -- Rahul receives

SELECT * FROM accounts;  -- changes visible to you mid-transaction

COMMIT;  -- save permanently

SELECT * FROM accounts;  -- confirm final state
-- Yash: 8000 | Rahul: 7000

-- ============================================================
-- ROLLBACK — undo everything
-- ============================================================

START TRANSACTION;

UPDATE accounts SET balance = balance - 9999 WHERE id = 1;  -- Yash almost broke

SELECT * FROM accounts;  -- Yash shows -1999 (inside transaction only)

ROLLBACK;  -- undo! never permanently saved

SELECT * FROM accounts;  -- Yash is back to 8000 ✅

-- ============================================================
-- SAVEPOINT — partial rollback
-- ============================================================
-- Savepoint lets you roll back to a specific point inside
-- a transaction — not all the way to the start.

START TRANSACTION;

UPDATE accounts SET balance = balance - 1000 WHERE id = 1;  -- Step 1

SAVEPOINT after_step1;  -- mark this point

UPDATE accounts SET balance = balance - 1000 WHERE id = 1;  -- Step 2

SELECT * FROM accounts;  -- Yash: 6000 (down 2000 total)

ROLLBACK TO after_step1;  -- undo Step 2 only, keep Step 1

SELECT * FROM accounts;  -- Yash: 7000 (only 2nd deduct undone) ✅

COMMIT;  -- save Step 1 permanently

-- ============================================================
-- REAL WORLD EXAMPLE — order placement
-- ============================================================
-- Multiple things must happen together when placing an order.
-- If any step fails, everything rolls back.

START TRANSACTION;

-- 1. Create the order
INSERT INTO orders (user_id, total_amount, status)
VALUES (1, 80500, 'pending');

-- 2. Add order items
INSERT INTO order_items (order_id, product_id, quantity, unit_price)
VALUES (LAST_INSERT_ID(), 3, 1, 80000);

INSERT INTO order_items (order_id, product_id, quantity, unit_price)
VALUES (LAST_INSERT_ID(), 5, 1, 500);

COMMIT;  -- all or nothing

-- ============================================================
-- RESET HELPER
-- ============================================================

-- If you need to reset accounts to starting balances:
-- UPDATE accounts SET balance = 10000.00 WHERE id = 1;
-- UPDATE accounts SET balance = 5000.00  WHERE id = 2;

-- ============================================================
-- PRACTICE CHALLENGES:
-- Challenge 1: Start a transaction, deduct 500 from Yash,
--              add 500 to Rahul, then ROLLBACK.
--              Confirm both balances are unchanged.
-- Challenge 2: Use a SAVEPOINT to deduct 200 from Yash (Step 1),
--              then deduct 300 more (Step 2).
--              Roll back only Step 2. Commit Step 1.
-- Challenge 3: Try to deduct more than Yash's balance.
--              What happens with the CHECK constraint?
-- ============================================================
