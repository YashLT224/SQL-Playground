-- ============================================================
-- WEEK 1 | TOPIC 3: SELECT QUERIES
-- ============================================================
-- SELECT is how you READ data from a table.
-- It's the most used SQL command — you'll write this every day.
-- ============================================================

USE practice_db;

-- ============================================================
-- BASIC SELECT
-- ============================================================

-- Get all columns from a table (* means "everything")
SELECT * FROM users;

-- Get only specific columns (always prefer this over * in production)
SELECT name, email FROM users;
SELECT name, city, age FROM users;

-- ============================================================
-- WHERE — Filter rows (like .filter() in JavaScript)
-- ============================================================

-- Users older than 25
SELECT * FROM users WHERE age > 25;

-- Users from Mumbai
SELECT * FROM users WHERE city = 'Mumbai';

-- Users who are active
SELECT * FROM users WHERE is_active = TRUE;

-- Combine conditions with AND / OR
SELECT * FROM users WHERE age > 25 AND city = 'Mumbai';
SELECT * FROM users WHERE city = 'Mumbai' OR city = 'Delhi';

-- NOT — exclude a condition
SELECT * FROM users WHERE NOT city = 'Chennai';

-- ============================================================
-- IN — match against a list of values (cleaner than multiple OR)
-- ============================================================
SELECT * FROM users WHERE city IN ('Mumbai', 'Delhi', 'Pune');

-- ============================================================
-- BETWEEN — range filter (inclusive on both ends)
-- ============================================================
SELECT * FROM users WHERE age BETWEEN 24 AND 30;
SELECT * FROM products WHERE price BETWEEN 1000 AND 2500;

-- ============================================================
-- LIKE — pattern matching (like regex but simpler)
-- % = any number of characters
-- _ = exactly one character
-- ============================================================
SELECT * FROM users WHERE name LIKE 'A%';        -- starts with A
SELECT * FROM users WHERE name LIKE '%a';        -- ends with a
SELECT * FROM users WHERE name LIKE '%ar%';      -- contains "ar"
SELECT * FROM users WHERE name LIKE '_isha%';    -- second char onwards is "isha"

-- ============================================================
-- ORDER BY — sort results
-- ============================================================
SELECT * FROM users ORDER BY age ASC;             -- youngest first
SELECT * FROM users ORDER BY age DESC;            -- oldest first
SELECT * FROM products ORDER BY price DESC;       -- most expensive first

-- Sort by multiple columns
SELECT * FROM users ORDER BY city ASC, age DESC;  -- city A-Z, then age within city

-- ============================================================
-- LIMIT & OFFSET — pagination (very common in APIs!)
-- ============================================================
SELECT * FROM products ORDER BY price DESC LIMIT 3;       -- top 3 expensive
SELECT * FROM products ORDER BY price DESC LIMIT 3 OFFSET 3; -- next 3 (page 2)

-- ============================================================
-- ALIASES — rename columns in output using AS
-- ============================================================
SELECT name AS user_name, email AS user_email FROM users;
SELECT name, price, stock, (price * stock) AS total_value FROM products;

-- ============================================================
-- IS NULL / IS NOT NULL — check for missing values
-- ============================================================
SELECT * FROM users WHERE age IS NULL;
SELECT * FROM users WHERE age IS NOT NULL;

-- ============================================================
-- PRACTICE CHALLENGES:
-- Try writing these queries yourself before looking at answers!

-- Challenge 1: Find all users from Bangalore who are older than 25
-- Challenge 2: Find all products priced between 1500 and 3000
-- Challenge 3: Find the 2 cheapest products
-- Challenge 4: Find all users whose name contains the letter 'n'
-- Challenge 5: Fetch name and email of users from Delhi or Chennai, sorted by name A-Z
-- ============================================================
