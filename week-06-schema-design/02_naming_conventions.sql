-- ============================================================
-- WEEK 6 | TOPIC 2: Naming Conventions
-- ============================================================
-- Industry standard naming rules so every team member can
-- read and understand the schema instantly.
-- ============================================================

-- ============================================================
-- TABLES — plural, lowercase, snake_case
-- ============================================================
-- ✅ users, blog_posts, order_items, product_categories
-- ❌ User, BlogPosts, ORDERS, tblUsers

-- ============================================================
-- COLUMNS — singular, lowercase, snake_case
-- ============================================================
-- ✅ id, user_id, first_name, total_amount, created_at
-- ❌ ID, userId, FirstName

-- ============================================================
-- PRIMARY KEYS — always just "id"
-- ============================================================
-- ✅ id
-- ❌ user_id (inside users table), userId, usersId

-- ============================================================
-- FOREIGN KEYS — referenced_table_singular + _id
-- ============================================================
-- ✅ user_id, order_id, product_id, author_id
-- ❌ users_id, orderID, fk_user

-- ============================================================
-- INDEXES — idx_<table>_<column(s)>
-- ============================================================
-- ✅ idx_orders_user_id, idx_posts_author_id
-- ❌ index1, userIndex

-- ============================================================
-- BOOLEAN COLUMNS — is_ or has_ prefix
-- ============================================================
-- ✅ is_active, is_published, is_verified, has_discount
-- ❌ active, published, status (too vague for boolean)

-- ============================================================
-- TIMESTAMP COLUMNS — standard set for every table
-- ============================================================
-- created_at   → when the row was created
-- updated_at   → when the row was last modified
-- deleted_at   → NULL = active, timestamp = soft deleted
-- published_at → domain-specific (follows same _at pattern)

-- ============================================================
-- JUNCTION TABLES — both table names combined
-- ============================================================
-- ✅ post_tags, student_courses, user_roles
-- ❌ posts_and_tags, tag_post_mapping

-- ============================================================
-- CHEAT SHEET
-- ============================================================
-- Thing           | Convention           | Example
-- ----------------|----------------------|-------------------
-- Tables          | Plural, snake_case   | blog_posts
-- Columns         | Singular, snake_case | first_name
-- Primary key     | Always id            | id
-- Foreign key     | <table>_id           | user_id
-- Index           | idx_<table>_<col>    | idx_posts_user_id
-- Boolean         | is_ or has_ prefix   | is_published
-- Timestamps      | _at suffix           | created_at
-- Junction table  | Both names combined  | post_tags
-- ============================================================
