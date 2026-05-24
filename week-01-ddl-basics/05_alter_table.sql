-- ============================================================
-- WEEK 1 | TOPIC 5: ALTER TABLE
-- ============================================================
-- ALTER TABLE lets you modify the STRUCTURE of an existing table
-- without dropping and recreating it.
-- Use this when requirements change after a table already has data.
-- ============================================================

USE practice_db;

-- ============================================================
-- ADD a new column
-- ============================================================
ALTER TABLE users ADD COLUMN phone VARCHAR(15);

-- Add at a specific position (AFTER a column)
ALTER TABLE users ADD COLUMN profile_pic TEXT AFTER email;

-- Add at the beginning
ALTER TABLE users ADD COLUMN country VARCHAR(100) FIRST;

-- ============================================================
-- MODIFY a column (change data type or constraints)
-- ============================================================
ALTER TABLE users MODIFY COLUMN phone VARCHAR(20);

-- Make a nullable column required
ALTER TABLE users MODIFY COLUMN city VARCHAR(100) NOT NULL;

-- ============================================================
-- RENAME a column
-- ============================================================
ALTER TABLE users RENAME COLUMN phone TO mobile;

-- ============================================================
-- DROP a column (removes it permanently with all data in it)
-- ============================================================
ALTER TABLE users DROP COLUMN profile_pic;
ALTER TABLE users DROP COLUMN country;

-- ============================================================
-- RENAME the table itself
-- ============================================================
RENAME TABLE users TO app_users;
RENAME TABLE app_users TO users;  -- rename back

-- ============================================================
-- ADD CONSTRAINTS after table creation
-- ============================================================

-- Add a unique constraint
ALTER TABLE users ADD CONSTRAINT unique_mobile UNIQUE (mobile);

-- Drop a constraint
ALTER TABLE users DROP INDEX unique_mobile;

-- ============================================================
-- VERIFY the structure after changes
-- ============================================================
DESCRIBE users;

-- ============================================================
-- PRACTICE CHALLENGES:

-- Challenge 1: Add a column 'bio' of type TEXT to the users table
-- Challenge 2: Add a column 'category' VARCHAR(50) to the products table
--              with a default value of 'general'
-- Challenge 3: Rename the 'status' column in orders to 'order_status'
-- Challenge 4: Run DESCRIBE on each table to verify your changes
-- ============================================================
