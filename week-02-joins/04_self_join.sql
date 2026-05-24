-- ============================================================
-- WEEK 2 | TOPIC 3: SELF JOIN
-- ============================================================
-- A SELF JOIN joins a table WITH ITSELF.
-- Used when a table has a relationship to its own rows.
-- Classic example: employees table where each employee
-- has a manager_id that references another employee's id.
-- ============================================================

USE practice_db;

-- ============================================================
-- SETUP: Create an employees table for self join demo
-- ============================================================
CREATE TABLE IF NOT EXISTS employees (
  id         INT AUTO_INCREMENT PRIMARY KEY,
  name       VARCHAR(100) NOT NULL,
  role       VARCHAR(100),
  manager_id INT DEFAULT NULL   -- NULL means this person is the top-level manager
);

INSERT INTO employees (name, role, manager_id) VALUES
  ('Arjun Shah',   'CEO',              NULL),   -- id=1, no manager
  ('Priya Nair',   'CTO',              1),      -- id=2, reports to CEO
  ('Rahul Verma',  'Engineering Lead', 2),      -- id=3, reports to CTO
  ('Sneha Gupta',  'Frontend Dev',     3),      -- id=4, reports to Eng Lead
  ('Vikram Joshi', 'Backend Dev',      3),      -- id=5, reports to Eng Lead
  ('Ananya Roy',   'Product Manager',  1),      -- id=6, reports to CEO
  ('Karan Mehta',  'Designer',         6);      -- id=7, reports to PM

-- ============================================================
-- SELF JOIN: Get each employee with their manager's name
-- We alias the SAME table twice — e = employee, m = manager
-- ============================================================
SELECT
  e.name   AS employee_name,
  e.role   AS employee_role,
  m.name   AS manager_name,
  m.role   AS manager_role
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.id;

-- Using LEFT JOIN so the CEO (no manager) also appears with NULL manager

-- ============================================================
-- SELF JOIN: Find all direct reports for a specific manager
-- "Who reports to the CTO?"
-- ============================================================
SELECT
  e.name  AS employee,
  e.role
FROM employees e
INNER JOIN employees m ON e.manager_id = m.id
WHERE m.name = 'Priya Nair';

-- ============================================================
-- SELF JOIN: Full org chart — employee + manager + manager's manager
-- ============================================================
SELECT
  e.name   AS employee,
  m.name   AS manager,
  gm.name  AS grand_manager
FROM employees e
LEFT JOIN employees m  ON e.manager_id  = m.id
LEFT JOIN employees gm ON m.manager_id  = gm.id;

-- ============================================================
-- REAL WORLD USE CASES FOR SELF JOIN:
-- 1. Org charts (employees → managers)
-- 2. Category → subcategory (same categories table)
-- 3. Referral systems (user referred another user)
-- 4. Friend/follower relationships
-- ============================================================

-- ============================================================
-- PRACTICE CHALLENGES:

-- Challenge 1: List all employees who have at least one direct report.
--              Show their name and role.

-- Challenge 2: Find all employees who report directly to the CEO.

-- Challenge 3: Count how many direct reports each manager has.
--              Show manager name and count, sorted by count DESC.
-- ============================================================
