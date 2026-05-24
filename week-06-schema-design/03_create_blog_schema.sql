-- ============================================================
-- WEEK 6 | TOPIC 3: Blog Schema — CREATE TABLE
-- ============================================================
-- A real-world blog platform schema applying all principles:
--   - Surrogate PKs on every table
--   - Proper foreign keys + constraints
--   - Naming conventions followed throughout
--   - created_at, updated_at, deleted_at on all tables
--   - Soft delete pattern (deleted_at)
-- ============================================================

CREATE DATABASE blog_db;
USE blog_db;

-- ============================================================
-- 1. blog_users — renamed from users to avoid conflict
-- ============================================================
CREATE TABLE blog_users (
  id         INT PRIMARY KEY AUTO_INCREMENT,
  first_name VARCHAR(100) NOT NULL,
  last_name  VARCHAR(100) NOT NULL,
  email      VARCHAR(255) UNIQUE NOT NULL,
  is_active  BOOLEAN DEFAULT TRUE,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at DATETIME DEFAULT NULL
);

-- ============================================================
-- 2. posts
-- ============================================================
CREATE TABLE posts (
  id           INT PRIMARY KEY AUTO_INCREMENT,
  user_id      INT NOT NULL,
  title        VARCHAR(255) NOT NULL,
  body         TEXT NOT NULL,
  is_published BOOLEAN DEFAULT FALSE,
  published_at DATETIME DEFAULT NULL,
  created_at   DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at   DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at   DATETIME DEFAULT NULL,
  FOREIGN KEY (user_id) REFERENCES blog_users(id)
);

-- ============================================================
-- 3. tags
-- ============================================================
CREATE TABLE tags (
  id         INT PRIMARY KEY AUTO_INCREMENT,
  name       VARCHAR(100) UNIQUE NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- 4. post_tags — junction table (posts ↔ tags M:N)
-- ============================================================
CREATE TABLE post_tags (
  post_id INT NOT NULL,
  tag_id  INT NOT NULL,
  PRIMARY KEY (post_id, tag_id),           -- composite PK prevents duplicates
  FOREIGN KEY (post_id) REFERENCES posts(id),
  FOREIGN KEY (tag_id)  REFERENCES tags(id)
);

-- ============================================================
-- 5. comments
-- ============================================================
CREATE TABLE comments (
  id         INT PRIMARY KEY AUTO_INCREMENT,
  post_id    INT NOT NULL,
  user_id    INT NOT NULL,
  body       TEXT NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at DATETIME DEFAULT NULL,
  FOREIGN KEY (post_id) REFERENCES posts(id),
  FOREIGN KEY (user_id) REFERENCES blog_users(id)
);

-- ============================================================
-- VERIFY — check all tables created
-- ============================================================
SHOW TABLES;

-- Check foreign keys on posts
SHOW CREATE TABLE posts;

-- Check composite PK on post_tags
SHOW CREATE TABLE post_tags;

-- ============================================================
-- RELATIONSHIP DIAGRAM
-- ============================================================
-- blog_users (id) ←──── posts (user_id)
--                           │
--                 posts (id) ←──── comments (post_id)
-- blog_users (id) ←──── comments (user_id)
-- posts (id) ←──── post_tags (post_id) ────► tags (id)
-- ============================================================
