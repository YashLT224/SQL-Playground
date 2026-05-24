# SQL Learning Journey — Week 6: Schema Design & Real-World Patterns

**Author:** Yash Verma
**Database:** MySQL
**Date:** May 2026
**Status:** ✅ Completed

---

## Topics Covered

| # | Topic | Description |
|---|-------|-------------|
| 1 | Schema Design Principles | 6 rules before writing any CREATE TABLE |
| 2 | Naming Conventions | Industry standard rules for tables, columns, keys |
| 3 | Building the Blog Schema | CREATE TABLE for 5 real tables |
| 4 | Seed Data | Populating all tables with realistic data |
| 5 | Real Queries | JOINs, GROUP_CONCAT, CTEs, subqueries on blog data |

---

## 1. Schema Design Principles

Before writing a single `CREATE TABLE`, follow these 6 principles.

### Principle 1: Start with Entities and Relationships

Write your system in plain English first, then extract entities and relationships.

```
Blog platform:
  Entities:      blog_users, posts, tags, comments
  Relationships:
    blog_users → posts    (1:N)
    posts → tags          (M:N via post_tags)
    blog_users → comments (1:N)
    posts → comments      (1:N)
```

### Principle 2: Every Table Needs a Surrogate Primary Key

```sql
-- ❌ Bad — business data as PK
CREATE TABLE users (email VARCHAR(255) PRIMARY KEY);

-- ✅ Good — surrogate id
CREATE TABLE users (
  id    INT PRIMARY KEY AUTO_INCREMENT,
  email VARCHAR(255) UNIQUE NOT NULL
);
```

Business data changes. Internal IDs never should.

### Principle 3: One Fact Per Column

```sql
-- ❌ Bad
full_address VARCHAR(500)  -- "123 Main St, Delhi, 110001"

-- ✅ Good
street  VARCHAR(255),
city    VARCHAR(100),
pincode VARCHAR(10)
```

### Principle 4: Use Constraints to Protect Data

Don't rely on application code alone — enforce rules at the database level.

```sql
CHECK (price > 0)
CHECK (stock >= 0)
FOREIGN KEY (category_id) REFERENCES categories(id)
```

### Principle 5: Design for Your Queries

Think about what you'll SELECT most often and plan indexes upfront.

```sql
-- Frequent query: orders by user + status
CREATE INDEX idx_orders_user_status ON orders(user_id, status);
```

### Principle 6: Plan for Growth — Standard Timestamps

Add to every table:

```sql
created_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
updated_at  DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
deleted_at  DATETIME DEFAULT NULL   -- soft delete
```

### Design Checklist

```
✅ What are the entities?
✅ What are the relationships (1:1, 1:N, M:N)?
✅ Does every table have a surrogate id PK?
✅ Is each column storing exactly one fact?
✅ Are business rules enforced with constraints?
✅ What are the most common queries — are indexes planned?
✅ Are created_at, updated_at, deleted_at added?
```

---

## 2. Naming Conventions

| Thing | Convention | Example |
|-------|-----------|---------|
| Tables | Plural, snake_case | `blog_posts` |
| Columns | Singular, snake_case | `first_name` |
| Primary key | Always `id` | `id` |
| Foreign key | `<table>_id` | `user_id` |
| Index | `idx_<table>_<col>` | `idx_posts_user_id` |
| Boolean | `is_` or `has_` prefix | `is_published` |
| Timestamps | `_at` suffix | `created_at`, `deleted_at` |
| Junction table | Both names combined | `post_tags` |

---

## 3. Blog Schema

```sql
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

CREATE TABLE tags (
  id         INT PRIMARY KEY AUTO_INCREMENT,
  name       VARCHAR(100) UNIQUE NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE post_tags (
  post_id INT NOT NULL,
  tag_id  INT NOT NULL,
  PRIMARY KEY (post_id, tag_id),
  FOREIGN KEY (post_id) REFERENCES posts(id),
  FOREIGN KEY (tag_id)  REFERENCES tags(id)
);

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
```

### Relationship Diagram

```
blog_users (id) ←──── posts (user_id)
                          │
              posts (id) ←──── comments (post_id)
blog_users (id) ←──── comments (user_id)
posts (id) ←──── post_tags (post_id) ────► tags (id)
```

---

## 4. Real Queries

---

### Query 1: All published posts with author name

```sql
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
```

**Output:**
```
1 | Yash Verma   | Getting Started with MySQL | 2026-05-23 13:55:53
2 | Yash Verma   | Understanding Indexes       | 2026-05-23 13:55:53
3 | Rahul Sharma | System Design Basics        | 2026-05-23 13:55:53
4 | Priya Singh  | My Backend Journey          | 2026-05-23 13:55:53
```
Only 4 rows — the 2 drafts are correctly excluded by `WHERE is_published = 1`.

---

### Query 2: How many posts has each user written?

```sql
SELECT
  CONCAT(u.first_name, ' ', u.last_name) AS author,
  COUNT(p.id) AS total_posts
FROM blog_users u
LEFT JOIN posts p ON u.id = p.user_id
GROUP BY u.id, u.first_name, u.last_name
ORDER BY total_posts DESC;
```

**Output:**
```
Yash Verma   | 2
Rahul Sharma | 1
Priya Singh  | 1
Aman Gupta   | 1
Sneha Patel  | 1
```
Note: This counts ALL posts including drafts. Use CTE Query 1 to count published only.

---

### Query 3: Each post with its comment count

```sql
SELECT
  p.title,
  COUNT(c.id) AS comment_count
FROM posts p
LEFT JOIN comments c ON p.id = c.post_id
GROUP BY p.id, p.title
ORDER BY comment_count DESC;
```

**Output:**
```
Getting Started with MySQL | 2
Understanding Indexes       | 2
System Design Basics        | 2
My Backend Journey          | 1
JavaScript vs SQL           | 0
Inactive User Draft Post    | 0
```
LEFT JOIN correctly returns 0 instead of excluding posts with no comments.

---

### Query 4: All tags on each published post

```sql
SELECT
  p.title,
  GROUP_CONCAT(t.name ORDER BY t.name SEPARATOR ', ') AS tags
FROM posts p
JOIN post_tags pt ON p.id = pt.post_id
JOIN tags t       ON pt.tag_id = t.id
WHERE p.is_published = 1
GROUP BY p.id, p.title;
```

**Output:**
```
Getting Started with MySQL | Backend, MySQL
Understanding Indexes       | Backend, MySQL
System Design Basics        | Backend, System Design
My Backend Journey          | Career
```
`GROUP_CONCAT` collapses multiple tag rows into one comma-separated string per post.

---

### Query 5: Users who have NEVER commented

```sql
SELECT
  CONCAT(u.first_name, ' ', u.last_name) AS user_name,
  u.email
FROM blog_users u
WHERE NOT EXISTS (
  SELECT 1 FROM comments c WHERE c.user_id = u.id
);
```

**Output:** Empty result — all 5 users commented at least once in our seed data. Empty result does not mean the query is wrong — it means the condition is not met by any row.

---

### CTE Query 1: Published posts only per user

```sql
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
```

**Output:**
```
Yash Verma   | 2
Rahul Sharma | 1
Priya Singh  | 1
Aman Gupta   | 0
Sneha Patel  | 0
```
COALESCE shows 0 instead of NULL for users with no published posts.

---

### CTE Query 2: Most popular tags

```sql
WITH tag_usage AS (
  SELECT t.name AS tag_name, COUNT(pt.post_id) AS post_count
  FROM tags t
  LEFT JOIN post_tags pt ON t.id = pt.tag_id
  GROUP BY t.id, t.name
)
SELECT tag_name, post_count
FROM tag_usage
ORDER BY post_count DESC;
```

**Output:**
```
Backend        | 3
MySQL          | 3
Career         | 1
JavaScript     | 1
System Design  | 1
```
Backend and MySQL are the most used tags across all posts.

---

### CTE Query 3: Most active commenters

```sql
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
```

**Output:**
```
Yash Verma   | 2
Rahul Sharma | 2
Priya Singh  | 1
Aman Gupta   | 1
Sneha Patel  | 1
```

---

### CTE Query 4: Full blog dashboard

```sql
WITH post_comment_counts AS (
  SELECT post_id, COUNT(*) AS total_comments
  FROM comments GROUP BY post_id
),
post_tag_counts AS (
  SELECT post_id, COUNT(*) AS total_tags
  FROM post_tags GROUP BY post_id
)
SELECT
  p.title,
  CONCAT(u.first_name, ' ', u.last_name) AS author,
  COALESCE(ptc.total_tags, 0)     AS tag_count,
  COALESCE(pcc.total_comments, 0) AS comment_count
FROM posts p
JOIN blog_users u              ON p.user_id = u.id
LEFT JOIN post_tag_counts ptc  ON p.id = ptc.post_id
LEFT JOIN post_comment_counts pcc ON p.id = pcc.post_id
WHERE p.is_published = 1
ORDER BY comment_count DESC;
```

**Output:**
```
Getting Started with MySQL | Yash Verma   | 2 | 2
Understanding Indexes       | Yash Verma   | 2 | 2
System Design Basics        | Rahul Sharma | 2 | 2
My Backend Journey          | Priya Singh  | 1 | 1
```
Each post shows exactly one author — fixed after catching the `ON p.user_id = p.user_id` CROSS JOIN bug.

---

## Key Rules Learned This Week

| Rule | Explanation |
|------|-------------|
| Surrogate PK always | Never use business data as primary key |
| One fact per column | Enables filtering, sorting, updating cleanly |
| Constraints at DB level | App bugs can't create invalid data |
| `is_` prefix for booleans | Reads like a question, avoids ambiguity |
| `deleted_at` soft delete | Never hard delete in production |
| LEFT JOIN + COALESCE | Shows zero counts instead of excluding rows |
| GROUP BY driving table PK | Always group by `u.id` not `p.user_id` in LEFT JOINs |
| GROUP_CONCAT | Collapses multiple rows into one comma-separated string |
| Both sides of ON must differ | `ON p.user_id = u.id` ✅ not `ON p.user_id = p.user_id` ❌ |

---

## Questions Asked

### Q1: What is an entity in SQL?

An entity is any real-world "thing" that you want to store data about. Each entity becomes a table. You identify entities by asking "what are the nouns in my system?" — users, products, orders, posts are all entities. Not every noun becomes a table — only nouns that have multiple attributes of their own. A value like `status` or `price` is just a column, not an entity.

---

### Q2: What is the difference between `JOIN` and `INNER JOIN`?

They are identical. `JOIN` alone in MySQL always means `INNER JOIN`. The word `INNER` is optional — most developers write `JOIN` because it's shorter. Use `LEFT JOIN` when you want all rows from the left table even if there's no match on the right.

---

### Q3: Why is GROUP BY on `u.id` instead of `p.user_id`?

Because the driving table is `blog_users` and with a LEFT JOIN, `p.user_id` can be NULL for users with no posts. Grouping by `u.id` always works correctly — it's never NULL. Grouping by `p.user_id` would merge all users with no posts into a single NULL group, losing individual rows.

---

### Q4: What does GROUP_CONCAT do?

`GROUP_CONCAT` is an aggregate function that joins multiple row values into a single comma-separated string within a group.

```sql
GROUP_CONCAT(t.name ORDER BY t.name SEPARATOR ', ')
-- [MySQL, Backend] → "Backend, MySQL"
```

Without it, each post would appear multiple times (once per tag). With it, all tags for a post collapse into one row.

---

### Q5: Why did the blog dashboard show every post for every user?

A typo in the JOIN condition — `ON p.user_id = p.user_id` instead of `ON p.user_id = u.id`. When both sides of the `ON` clause reference the same table, the condition is always `TRUE`, which causes a CROSS JOIN — every post matched every user. Always verify that both sides of `ON` use different table aliases.

---

### Q6: Why use a separate `blog_db` instead of adding to `practice_db`?

The `practice_db` already had a `users` table from Week 1. Creating a second `users` table would cause a conflict. A separate database keeps Week 6 isolated and clean. In real projects, different apps or modules often use different databases for the same reason.

---

*SQL Learning Journey — Yash Verma | Week 6 of 6 ✅*
