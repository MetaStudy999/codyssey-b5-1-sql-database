-- B5-1 JOIN Practice Script
-- DB: SQLite 3
-- Purpose: practice INNER JOIN, LEFT JOIN, JOIN + GROUP BY, and JOIN vs subquery.
-- Usage:
--   sqlite3 book_rental.db < training-materials/03-join-practice/join-practice.sql
--
-- Safety note:
--   This file is SELECT-only. It does not modify book_rental.db.

PRAGMA foreign_keys = ON;
.headers on
.mode column

.print '============================================================'
.print 'B5-1 JOIN PRACTICE'
.print '============================================================'

.print ''
.print '[Section 1] ERD relationship check'
.print 'Core relationships: category 1:N book, member 1:N rental, book 1:N rental'

.print ''
.print '[Q01] INNER JOIN: 도서 목록에 카테고리명을 붙여 조회한다.'
SELECT b.book_id,
       b.title,
       b.author,
       c.name AS category_name,
       b.price
FROM book b
INNER JOIN category c ON b.category_id = c.category_id
ORDER BY c.name ASC, b.title ASC;

.print ''
.print '[Q02] INNER JOIN: 대여 기록에 회원명을 붙여 조회한다.'
SELECT r.rental_id,
       m.name AS member_name,
       r.rented_at,
       r.due_date,
       r.status
FROM rental r
INNER JOIN member m ON r.member_id = m.member_id
ORDER BY r.rented_at DESC;

.print ''
.print '[Q03] INNER JOIN: 대여 기록에 도서명을 붙여 조회한다.'
SELECT r.rental_id,
       b.title AS book_title,
       r.rented_at,
       r.due_date,
       r.status
FROM rental r
INNER JOIN book b ON r.book_id = b.book_id
ORDER BY r.rented_at DESC;

.print ''
.print '[Q04] INNER JOIN: 대여 기록에 회원명과 도서명을 함께 붙여 조회한다.'
SELECT r.rental_id,
       m.name AS member_name,
       b.title AS book_title,
       r.rented_at,
       r.due_date,
       r.status
FROM rental r
INNER JOIN member m ON r.member_id = m.member_id
INNER JOIN book b ON r.book_id = b.book_id
ORDER BY r.rented_at DESC;

.print ''
.print '[Q05] INNER JOIN: 대여 기록에 회원명, 도서명, 카테고리명을 함께 붙여 조회한다.'
SELECT r.rental_id,
       m.name AS member_name,
       b.title AS book_title,
       c.name AS category_name,
       r.rented_at,
       r.due_date,
       r.status
FROM rental r
INNER JOIN member m ON r.member_id = m.member_id
INNER JOIN book b ON r.book_id = b.book_id
INNER JOIN category c ON b.category_id = c.category_id
ORDER BY r.rented_at DESC;

.print ''
.print '[Q06] INNER JOIN + WHERE: 연체 기록에 회원명, 도서명, 카테고리명, 수수료를 붙여 조회한다.'
SELECT r.rental_id,
       m.name AS member_name,
       b.title AS book_title,
       c.name AS category_name,
       r.due_date,
       r.status,
       r.rental_fee
FROM rental r
INNER JOIN member m ON r.member_id = m.member_id
INNER JOIN book b ON r.book_id = b.book_id
INNER JOIN category c ON b.category_id = c.category_id
WHERE r.status = 'OVERDUE'
ORDER BY r.due_date ASC;

.print ''
.print '[Q07] INNER JOIN + WHERE: RETURNED 상태 대여 기록에 회원명과 도서명을 붙여 조회한다.'
SELECT r.rental_id,
       m.name AS member_name,
       b.title AS book_title,
       r.rented_at,
       r.returned_at,
       r.status
FROM rental r
INNER JOIN member m ON r.member_id = m.member_id
INNER JOIN book b ON r.book_id = b.book_id
WHERE r.status = 'RETURNED'
ORDER BY r.returned_at ASC;

.print ''
.print '[Q08] INNER JOIN + WHERE: 30,000원 이상 도서의 카테고리명을 함께 조회한다.'
SELECT b.book_id,
       b.title,
       c.name AS category_name,
       b.price
FROM book b
INNER JOIN category c ON b.category_id = c.category_id
WHERE b.price >= 30000
ORDER BY b.price DESC;

.print ''
.print '[Q09] INNER JOIN + LIMIT: 최근 대여 기록 5건의 상세 정보를 조회한다.'
SELECT r.rental_id,
       m.name AS member_name,
       b.title AS book_title,
       c.name AS category_name,
       r.rented_at,
       r.status
FROM rental r
INNER JOIN member m ON r.member_id = m.member_id
INNER JOIN book b ON r.book_id = b.book_id
INNER JOIN category c ON b.category_id = c.category_id
ORDER BY r.rented_at DESC
LIMIT 5;

.print ''
.print '[Q10] INNER JOIN + DISTINCT: 대여 기록이 있는 회원만 중복 없이 조회한다.'
SELECT DISTINCT m.member_id,
       m.name,
       m.email
FROM member m
INNER JOIN rental r ON m.member_id = r.member_id
ORDER BY m.member_id ASC;

.print ''
.print '============================================================'
.print '[Section 2] LEFT JOIN practice'
.print '============================================================'

.print ''
.print '[Q11] LEFT JOIN: 모든 회원과 대여 기록을 조회한다.'
SELECT m.member_id,
       m.name AS member_name,
       r.rental_id,
       r.rented_at,
       r.status
FROM member m
LEFT JOIN rental r ON m.member_id = r.member_id
ORDER BY m.member_id ASC, r.rental_id ASC;

.print ''
.print '[Q12] LEFT JOIN + GROUP BY: 회원별 대여 횟수를 0건 포함해 조회한다.'
SELECT m.member_id,
       m.name AS member_name,
       COUNT(r.rental_id) AS rental_count
FROM member m
LEFT JOIN rental r ON m.member_id = r.member_id
GROUP BY m.member_id, m.name
ORDER BY rental_count DESC, m.member_id ASC;

.print ''
.print '[Q13] LEFT JOIN + GROUP BY: 카테고리별 도서 수를 0건 포함해 조회한다.'
SELECT c.category_id,
       c.name AS category_name,
       COUNT(b.book_id) AS book_count
FROM category c
LEFT JOIN book b ON c.category_id = b.category_id
GROUP BY c.category_id, c.name
ORDER BY book_count DESC, c.category_id ASC;

.print ''
.print '[Q14] LEFT JOIN + GROUP BY: 도서별 대여 횟수를 0건 포함해 조회한다.'
SELECT b.book_id,
       b.title,
       COUNT(r.rental_id) AS rental_count
FROM book b
LEFT JOIN rental r ON b.book_id = r.book_id
GROUP BY b.book_id, b.title
ORDER BY rental_count DESC, b.book_id ASC;

.print ''
.print '[Q15] LEFT JOIN + IS NULL: 대여 기록이 없는 회원을 조회한다.'
SELECT m.member_id,
       m.name,
       m.email,
       m.status
FROM member m
LEFT JOIN rental r ON m.member_id = r.member_id
WHERE r.rental_id IS NULL
ORDER BY m.member_id ASC;

.print ''
.print '[Q16] LEFT JOIN + IS NULL: 도서가 없는 카테고리를 조회한다.'
SELECT c.category_id,
       c.name AS category_name
FROM category c
LEFT JOIN book b ON c.category_id = b.category_id
WHERE b.book_id IS NULL
ORDER BY c.category_id ASC;

.print ''
.print '[Q17] LEFT JOIN + ON condition: 모든 회원을 유지하고 RENTED 상태 대여 기록만 붙인다.'
SELECT m.member_id,
       m.name,
       r.rental_id,
       r.status
FROM member m
LEFT JOIN rental r
    ON m.member_id = r.member_id
   AND r.status = 'RENTED'
ORDER BY m.member_id ASC, r.rental_id ASC;

.print ''
.print '[Q18] LEFT JOIN count check: COUNT(*)와 COUNT(r.rental_id)의 차이를 확인한다.'
SELECT m.member_id,
       m.name,
       COUNT(*) AS count_star,
       COUNT(r.rental_id) AS count_rental_id
FROM member m
LEFT JOIN rental r ON m.member_id = r.member_id
GROUP BY m.member_id, m.name
ORDER BY m.member_id ASC;

.print ''
.print '[Q19] LEFT JOIN + COALESCE: 대여 기록이 없으면 NO_RENTAL로 표시한다.'
SELECT m.member_id,
       m.name,
       COALESCE(CAST(r.rental_id AS TEXT), 'NO_RENTAL') AS rental_id_or_status,
       COALESCE(r.status, 'NO_RENTAL') AS rental_status
FROM member m
LEFT JOIN rental r ON m.member_id = r.member_id
ORDER BY m.member_id ASC, r.rental_id ASC;

.print ''
.print '============================================================'
.print '[Section 3] JOIN vs subquery practice'
.print '============================================================'

.print ''
.print '[Q20] JOIN 방식: Database 카테고리 도서를 조회한다.'
SELECT b.book_id,
       b.title,
       b.author,
       c.name AS category_name
FROM book b
INNER JOIN category c ON b.category_id = c.category_id
WHERE c.name = 'Database'
ORDER BY b.book_id ASC;

.print ''
.print '[Q21] 서브쿼리 방식: Database 카테고리 도서를 조회한다.'
SELECT book_id,
       title,
       author,
       category_id
FROM book
WHERE category_id = (
    SELECT category_id
    FROM category
    WHERE name = 'Database'
)
ORDER BY book_id ASC;

.print ''
.print '[Q22] 서브쿼리 방식: 평균 가격보다 비싼 도서를 조회한다.'
SELECT book_id,
       title,
       price
FROM book
WHERE price > (
    SELECT AVG(price)
    FROM book
)
ORDER BY price DESC;

.print ''
.print '[Q23] JOIN 방식: Database 카테고리 도서를 빌린 회원을 조회한다.'
SELECT DISTINCT m.member_id,
       m.name,
       m.email
FROM member m
INNER JOIN rental r ON m.member_id = r.member_id
INNER JOIN book b ON r.book_id = b.book_id
INNER JOIN category c ON b.category_id = c.category_id
WHERE c.name = 'Database'
ORDER BY m.member_id ASC;

.print ''
.print '[Q24] EXISTS 방식: 대여 기록이 있는 회원을 조회한다.'
SELECT m.member_id,
       m.name,
       m.email
FROM member m
WHERE EXISTS (
    SELECT 1
    FROM rental r
    WHERE r.member_id = m.member_id
)
ORDER BY m.member_id ASC;

.print ''
.print '[Q25] NOT EXISTS 방식: 대여 기록이 없는 회원을 조회한다.'
SELECT m.member_id,
       m.name,
       m.email
FROM member m
WHERE NOT EXISTS (
    SELECT 1
    FROM rental r
    WHERE r.member_id = m.member_id
)
ORDER BY m.member_id ASC;

.print ''
.print '[Q26] 상관 서브쿼리 방식: 카테고리별 도서 수를 조회한다.'
SELECT c.category_id,
       c.name AS category_name,
       (
           SELECT COUNT(*)
           FROM book b
           WHERE b.category_id = c.category_id
       ) AS book_count
FROM category c
ORDER BY book_count DESC, c.category_id ASC;

.print ''
.print '============================================================'
.print '[Section 4] Self-check prompts'
.print '============================================================'

.print ''
.print '설명 연습 1: INNER JOIN은 왜 매칭되는 행만 보여주는가?'
.print '설명 연습 2: LEFT JOIN은 왜 대여 기록이 없는 회원까지 보여주는가?'
.print '설명 연습 3: COUNT(*)와 COUNT(r.rental_id)는 왜 다른가?'
.print '설명 연습 4: Database 카테고리 도서 조회를 JOIN과 서브쿼리로 각각 설명하라.'
.print '설명 연습 5: 평균 가격보다 비싼 도서는 왜 서브쿼리가 자연스러운가?'

.print ''
.print '============================================================'
.print 'JOIN practice completed. No database changes were made.'
.print '============================================================'
