-- Bonus 1: Same requirement solved by JOIN and subquery.
-- Requirement: find members who rented books in the AI category.

PRAGMA foreign_keys = ON;

-- JOIN version
SELECT DISTINCT m.member_id, m.name
FROM member m
INNER JOIN rental r ON m.member_id = r.member_id
INNER JOIN book b ON r.book_id = b.book_id
INNER JOIN category c ON b.category_id = c.category_id
WHERE c.name = 'AI'
ORDER BY m.member_id;

-- Subquery version
SELECT member_id, name
FROM member
WHERE member_id IN (
    SELECT r.member_id
    FROM rental r
    WHERE r.book_id IN (
        SELECT b.book_id
        FROM book b
        WHERE b.category_id = (
            SELECT category_id
            FROM category
            WHERE name = 'AI'
        )
    )
)
ORDER BY member_id;

-- Bonus 2: FK error demo.
-- This should fail because member_id=999 does not exist.
-- Run separately: sqlite3 book_rental.db < docs/bonus.sql
-- Uncomment the statement below only when you want to demonstrate FK failure.
-- INSERT INTO rental (rental_id, member_id, book_id, rented_at, due_date, status, rental_fee)
-- VALUES (999, 999, 1, '2024-08-01', '2024-08-15', 'RENTED', 0);
