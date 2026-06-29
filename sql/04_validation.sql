-- Validation script for evaluator/self-check
PRAGMA foreign_keys = ON;
.headers on
.mode column

.print '1) Table list'
SELECT name AS table_name
FROM sqlite_master
WHERE type = 'table'
ORDER BY name;

.print ''
.print '2) Row counts: every table should have at least 10 rows after seeding.'
SELECT 'member' AS table_name, COUNT(*) AS row_count FROM member
UNION ALL
SELECT 'category', COUNT(*) FROM category
UNION ALL
SELECT 'book', COUNT(*) FROM book
UNION ALL
SELECT 'rental', COUNT(*) FROM rental;

.print ''
.print '3) Foreign key integrity check: no rows means OK.'
PRAGMA foreign_key_check;

.print ''
.print '4) Schema overview'
.schema member
.schema category
.schema book
.schema rental
