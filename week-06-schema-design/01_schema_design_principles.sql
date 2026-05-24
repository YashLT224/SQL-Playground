-- ============================================================
-- WEEK 6 | TOPIC 1: Schema Design Principles
-- ============================================================
-- Before writing any CREATE TABLE, follow these 6 principles.
-- A bad schema is expensive to fix later — migrations on
-- 10 million rows are painful. Design carefully upfront.
-- ============================================================

-- ============================================================
-- PRINCIPLE 1: Start with Entities and Relationships
-- ============================================================
-- Write your system in plain English first.
-- Identify the nouns — each noun with its own data = a table.
--
-- Blog platform:
--   Entities:      blog_users, posts, tags, comments
--   Relationships:
--     blog_users → posts     (1:N — one user writes many posts)
--     posts → tags           (M:N — via post_tags junction table)
--     blog_users → comments  (1:N — one user writes many comments)
--     posts → comments       (1:N — one post has many comments)

-- ============================================================
-- PRINCIPLE 2: Every Table Needs a Surrogate Primary Key
-- ============================================================

-- ❌ Bad — using business data as PK
-- CREATE TABLE users (email VARCHAR(255) PRIMARY KEY);
-- What if email changes? All foreign keys break.

-- ✅ Good — surrogate id
-- CREATE TABLE users (
--   id    INT PRIMARY KEY AUTO_INCREMENT,
--   email VARCHAR(255) UNIQUE NOT NULL
-- );
-- Business data changes. Internal ids never should.

-- ============================================================
-- PRINCIPLE 3: One Fact Per Column
-- ============================================================

-- ❌ Bad
-- CREATE TABLE users (full_address VARCHAR(500));
-- "123 Main St, Delhi, 110001" — can't filter by city alone

-- ✅ Good
-- CREATE TABLE users (
--   street  VARCHAR(255),
--   city    VARCHAR(100),
--   pincode VARCHAR(10)
-- );

-- ============================================================
-- PRINCIPLE 4: Use Constraints to Protect Data
-- ============================================================

-- Don't rely on application code alone.
-- Database constraints are the last line of defence.
--
-- NOT NULL    → column must always have a value
-- UNIQUE      → no duplicate values
-- CHECK       → custom business rule
-- FOREIGN KEY → referential integrity
-- DEFAULT     → fallback value

-- ============================================================
-- PRINCIPLE 5: Design for Your Queries
-- ============================================================

-- Think about what you'll SELECT most often.
-- Example: if you frequently run:
--   SELECT * FROM orders WHERE user_id = ? AND status = 'pending'
-- Then plan this index upfront:
--   CREATE INDEX idx_orders_user_status ON orders(user_id, status)

-- ============================================================
-- PRINCIPLE 6: Plan for Growth — Standard Timestamp Columns
-- ============================================================

-- Add these to EVERY table. They cost almost nothing upfront
-- but save painful migrations later.
--
-- created_at  DATETIME DEFAULT CURRENT_TIMESTAMP
-- updated_at  DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
-- deleted_at  DATETIME DEFAULT NULL  ← soft delete support

-- ============================================================
-- THE DESIGN CHECKLIST
-- ============================================================
-- Before writing any CREATE TABLE, answer these:
--
-- ✅ What are the entities?
-- ✅ What are the relationships (1:1, 1:N, M:N)?
-- ✅ Does every table have a surrogate id PK?
-- ✅ Is each column storing exactly one fact?
-- ✅ Are business rules enforced with constraints?
-- ✅ What are the most common queries — are indexes planned?
-- ✅ Are created_at, updated_at, deleted_at added?
-- ============================================================
