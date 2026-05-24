-- ============================================================
-- WEEK 1 | TOPIC 4: UPDATE & DELETE
-- ============================================================
-- UPDATE modifies existing rows.
-- DELETE removes rows permanently.
-- ⚠️  ALWAYS use WHERE — without it you affect ALL rows!
-- ============================================================

USE practice_db;

-- ============================================================
-- UPDATE SYNTAX:
-- UPDATE table SET column = value WHERE condition;
-- ============================================================

-- Update a single column for one user
UPDATE users SET age = 27 WHERE id = 1;

-- Update multiple columns at once
UPDATE users SET age = 29, city = 'Pune' WHERE email = 'ananya@example.com';

-- Update based on a condition (not just id)
UPDATE users SET is_active = FALSE WHERE city = 'Chennai';

-- Update a product's price and stock
UPDATE products SET price = 1099.00, stock = 150 WHERE name = 'Wireless Mouse';

-- Update order status
UPDATE orders SET status = 'delivered' WHERE id = 2;

-- Bulk update — change all pending orders older logic (careful!)
UPDATE orders SET status = 'cancelled' WHERE status = 'pending' AND user_id = 3;

-- ============================================================
-- DELETE SYNTAX:
-- DELETE FROM table WHERE condition;
-- ============================================================

-- Delete a specific user
DELETE FROM users WHERE id = 8;

-- Delete orders with a specific status
DELETE FROM orders WHERE status = 'cancelled';

-- ============================================================
-- ⚠️ DANGER ZONE — These affect ALL rows, use with extreme caution
-- ============================================================

-- DELETE FROM users;        -- deletes ALL users (no WHERE!)
-- TRUNCATE TABLE orders;    -- faster way to empty a table, resets AUTO_INCREMENT

-- ============================================================
-- SOFT DELETE PATTERN (industry best practice)
-- Instead of actually deleting, mark rows as deleted.
-- This preserves data for audit trails, recovery, analytics.
-- ============================================================

-- Add a deleted_at column to track soft deletes
ALTER TABLE users ADD COLUMN deleted_at DATETIME DEFAULT NULL;

-- Soft delete a user (mark as deleted instead of removing)
UPDATE users SET deleted_at = CURRENT_TIMESTAMP WHERE id = 7;

-- Fetch only non-deleted users (add this to all your queries)
SELECT * FROM users WHERE deleted_at IS NULL;

-- ============================================================
-- VERIFY changes
-- ============================================================
SELECT * FROM users;
SELECT * FROM products;
SELECT * FROM orders;

-- ============================================================
-- PRACTICE CHALLENGES:

-- Challenge 1: Update Priya Sharma's city to 'Hyderabad'
-- Challenge 2: Mark all products with stock = 0 as out_of_stock
--              (Hint: add a boolean column first using ALTER TABLE)
-- Challenge 3: Delete all orders that have status = 'pending' for user_id = 4
-- Challenge 4: Soft delete user with id = 5 and verify they don't show
--              in a query that filters deleted_at IS NULL
-- ============================================================
