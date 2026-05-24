-- ============================================================
-- WEEK 6 | TOPIC 4: Seed Data
-- ============================================================
-- Populate all 5 tables with realistic blog data.
-- Run in order — foreign key dependencies must be met first.
-- Order: blog_users → tags → posts → post_tags → comments
-- ============================================================

USE blog_db;

-- ============================================================
-- 1. blog_users
-- ============================================================
INSERT INTO blog_users (first_name, last_name, email, is_active) VALUES
('Yash',  'Verma',  'yash@gmail.com',  1),
('Rahul', 'Sharma', 'rahul@gmail.com', 1),
('Priya', 'Singh',  'priya@gmail.com', 1),
('Aman',  'Gupta',  'aman@gmail.com',  1),
('Sneha', 'Patel',  'sneha@gmail.com', 0);  -- inactive user

-- ============================================================
-- 2. tags
-- ============================================================
INSERT INTO tags (name) VALUES
('MySQL'),
('System Design'),
('Backend'),
('JavaScript'),
('Career');

-- ============================================================
-- 3. posts
-- ============================================================
INSERT INTO posts (user_id, title, body, is_published, published_at) VALUES
(1, 'Getting Started with MySQL',  'MySQL is a relational database...', 1, NOW()),
(1, 'Understanding Indexes',       'Indexes speed up queries by...',    1, NOW()),
(2, 'System Design Basics',        'System design is the process of...', 1, NOW()),
(3, 'My Backend Journey',          'I started learning backend...',     1, NOW()),
(4, 'JavaScript vs SQL',           'Both are essential skills...',      0, NULL),  -- draft
(5, 'Inactive User Draft Post',    'This post is from inactive user.',  0, NULL);  -- draft

-- ============================================================
-- 4. post_tags (junction table)
-- ============================================================
INSERT INTO post_tags (post_id, tag_id) VALUES
(1, 1),  -- Getting Started with MySQL → MySQL
(1, 3),  -- Getting Started with MySQL → Backend
(2, 1),  -- Understanding Indexes → MySQL
(2, 3),  -- Understanding Indexes → Backend
(3, 2),  -- System Design Basics → System Design
(3, 3),  -- System Design Basics → Backend
(4, 5),  -- My Backend Journey → Career
(5, 4),  -- JavaScript vs SQL → JavaScript
(5, 1);  -- JavaScript vs SQL → MySQL

-- ============================================================
-- 5. comments
-- ============================================================
INSERT INTO comments (post_id, user_id, body) VALUES
(1, 2, 'Great intro to MySQL!'),
(1, 3, 'Very helpful, thanks Yash.'),
(2, 4, 'Indexes finally make sense!'),
(2, 2, 'Could you cover covering indexes next?'),
(3, 1, 'Solid system design overview.'),
(3, 5, 'Love this post!'),
(4, 1, 'Great to see your journey Priya!');

-- ============================================================
-- VERIFY ALL DATA
-- ============================================================
SELECT * FROM blog_users;
SELECT * FROM posts;
SELECT * FROM tags;
SELECT * FROM post_tags;
SELECT * FROM comments;
