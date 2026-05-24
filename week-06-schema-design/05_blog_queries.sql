-- ============================================================
-- WEEK 6 | TOPIC 5: Real Blog Queries
-- ============================================================
-- Applying Weeks 1-5 concepts on the real blog schema:
-- JOINs, aggregations, GROUP_CONCAT, CTEs, subqueries
-- ============================================================

USE blog_db;

-- ============================================================
-- BASIC QUERIES
-- ============================================================

-- Query 1: All published posts with author name
SELECT
  p.id,
  CONCAT(u.first_name, ' ', u.last_name) AS author,
  p.title,
  p.published_at
FROM posts p
JOIN blog_users u ON p.user_id = u.id
WHERE p.is_published = 1
  AND p.deleted_at IS NULL
ORDER BY p.published_at DESC;

-- ============================================================

-- Query 2: How many posts has each user written?
-- LEFT JOIN ensures users with 0 posts still appear
SELECT
  CONCAT(u.first_name, ' ', u.last_name) AS author,
  COUNT(p.id) AS total_posts
FROM blog_users u
LEFT JOIN posts p ON u.id = p.user_id
GROUP BY u.id, u.first_name, u.last_name
ORDER BY total_posts DESC;

-- ============================================================

-- Query 3: Each post with its comment count
SELECT
  p.title,
  COUNT(c.id) AS comment_count
FROM posts p
LEFT JOIN comments c ON p.id = c.post_id
GROUP BY p.id, p.title
ORDER BY comment_count DESC;

-- ============================================================

-- Query 4: All tags on each published post (GROUP_CONCAT)
-- GROUP_CONCAT joins multiple tag names into one string per post
SELECT
  p.title,
  GROUP_CONCAT(t.name ORDER BY t.name SEPARATOR ', ') AS tags
FROM posts p
JOIN post_tags pt ON p.id = pt.post_id
JOIN tags t       ON pt.tag_id = t.id
WHERE p.is_published = 1
GROUP BY p.id, p.title;

-- ============================================================

-- Query 5: Users who have NEVER commented (NOT EXISTS)
SELECT
  CONCAT(u.first_name, ' ', u.last_name) AS user_name,
  u.email
FROM blog_users u
WHERE NOT EXISTS (
  SELECT 1 FROM comments c WHERE c.user_id = u.id
);

-- ============================================================
-- CTE QUERIES
-- ============================================================

-- CTE Query 1: Published posts only per user (excludes drafts)
WITH published_posts AS (
  SELECT user_id, COUNT(*) AS total_posts
  FROM posts
  WHERE is_published = 1
  GROUP BY user_id
)
SELECT
  CONCAT(u.first_name, ' ', u.last_name) AS author,
  COALESCE(pp.total_posts, 0) AS published_posts
FROM blog_users u
LEFT JOIN published_posts pp ON u.id = pp.user_id
ORDER BY published_posts DESC;

-- ============================================================

-- CTE Query 2: Most popular tags by number of posts
WITH tag_usage AS (
  SELECT t.name AS tag_name, COUNT(pt.post_id) AS post_count
  FROM tags t
  LEFT JOIN post_tags pt ON t.id = pt.tag_id
  GROUP BY t.id, t.name
)
SELECT tag_name, post_count
FROM tag_usage
ORDER BY post_count DESC;

-- ============================================================

-- CTE Query 3: Most active commenters
WITH comment_counts AS (
  SELECT user_id, COUNT(*) AS total_comments
  FROM comments
  GROUP BY user_id
)
SELECT
  CONCAT(u.first_name, ' ', u.last_name) AS user_name,
  cc.total_comments
FROM blog_users u
JOIN comment_counts cc ON u.id = cc.user_id
ORDER BY total_comments DESC;

-- ============================================================

-- CTE Query 4: Full blog dashboard
-- Posts with author, tag count, and comment count
-- Uses 2 CTEs + 3 JOINs
WITH post_comment_counts AS (
  SELECT post_id, COUNT(*) AS total_comments
  FROM comments
  GROUP BY post_id
),
post_tag_counts AS (
  SELECT post_id, COUNT(*) AS total_tags
  FROM post_tags
  GROUP BY post_id
)
SELECT
  p.title,
  CONCAT(u.first_name, ' ', u.last_name) AS author,
  COALESCE(ptc.total_tags, 0)     AS tag_count,
  COALESCE(pcc.total_comments, 0) AS comment_count
FROM posts p
JOIN blog_users u              ON p.user_id = u.id       -- ← must be u.id not p.user_id
LEFT JOIN post_tag_counts ptc  ON p.id = ptc.post_id
LEFT JOIN post_comment_counts pcc ON p.id = pcc.post_id
WHERE p.is_published = 1
ORDER BY comment_count DESC;

-- ============================================================
-- COMMON BUG TO AVOID
-- ============================================================
-- ❌ Wrong JOIN condition — references same table on both sides
-- JOIN blog_users u ON p.user_id = p.user_id
-- This is always TRUE → behaves like CROSS JOIN → every post
-- appears once per user (5 posts × 5 users = 25 rows!)

-- ✅ Correct — different tables on each side
-- JOIN blog_users u ON p.user_id = u.id
-- Always double check both sides of ON reference different aliases
-- ============================================================
