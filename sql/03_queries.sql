-- B5-1 SQL Mission: 15 core queries
-- SQLite CLI command included for readable result capture.

PRAGMA foreign_keys = ON;
.headers on
.mode column

.print 'Q01. 기본 조회: ACTIVE 회원 중 2024-03-01 이후 가입자를 확인한다.'
SELECT member_id, name, email, joined_at, status
FROM member
WHERE status = 'ACTIVE'
  AND joined_at >= '2024-03-01'
ORDER BY joined_at ASC;

.print ''
.print 'Q02. 기본 조회: 30,000원 이상 도서를 가격 높은 순으로 5권 확인한다. (WHERE + ORDER BY + LIMIT)'
SELECT book_id, title, author, price
FROM book
WHERE price >= 30000
ORDER BY price DESC
LIMIT 5;

.print ''
.print 'Q03. 기본 조회: 제목에 SQL이 들어간 도서를 검색한다. (LIKE)'
SELECT book_id, title, author, price
FROM book
WHERE title LIKE '%SQL%'
ORDER BY title ASC;

.print ''
.print 'Q04. 기본 조회: 현재 대여 중 또는 연체 상태의 대여 기록을 반납기한 순으로 확인한다.'
SELECT rental_id, member_id, book_id, rented_at, due_date, status
FROM rental
WHERE status IN ('RENTED', 'OVERDUE')
ORDER BY due_date ASC;

.print ''
.print 'Q05. INNER JOIN: 최근 대여 기록에서 회원명과 도서명을 함께 확인한다.'
SELECT r.rental_id, m.name AS member_name, b.title AS book_title, r.rented_at, r.status
FROM rental r
INNER JOIN member m ON r.member_id = m.member_id
INNER JOIN book b ON r.book_id = b.book_id
ORDER BY r.rented_at DESC
LIMIT 10;

.print ''
.print 'Q06. INNER JOIN: 도서와 카테고리를 연결하여 도서 분류를 확인한다.'
SELECT b.book_id, b.title, c.name AS category_name, b.price
FROM book b
INNER JOIN category c ON b.category_id = c.category_id
ORDER BY c.name, b.title;

.print ''
.print 'Q07. INNER JOIN: 연체 기록의 회원/도서/카테고리를 한 번에 확인한다.'
SELECT r.rental_id, m.name AS member_name, b.title AS book_title, c.name AS category_name, r.due_date, r.rental_fee
FROM rental r
INNER JOIN member m ON r.member_id = m.member_id
INNER JOIN book b ON r.book_id = b.book_id
INNER JOIN category c ON b.category_id = c.category_id
WHERE r.status = 'OVERDUE'
ORDER BY r.due_date ASC;

.print ''
.print 'Q08. LEFT JOIN: 대여 기록이 없는 회원까지 포함하여 회원별 대여 횟수를 확인한다.'
SELECT m.member_id, m.name, COUNT(r.rental_id) AS rental_count
FROM member m
LEFT JOIN rental r ON m.member_id = r.member_id
GROUP BY m.member_id, m.name
ORDER BY rental_count ASC, m.member_id ASC;

.print ''
.print 'Q09. 집계: 회원별 총 대여 횟수와 납부 수수료 합계를 확인한다. (COUNT + SUM + GROUP BY)'
SELECT m.member_id, m.name, COUNT(r.rental_id) AS rental_count, SUM(r.rental_fee) AS total_fee
FROM member m
INNER JOIN rental r ON m.member_id = r.member_id
GROUP BY m.member_id, m.name
ORDER BY rental_count DESC, total_fee DESC;

.print ''
.print 'Q10. 집계: 카테고리별 보유 도서 수와 평균 가격을 확인한다. (COUNT + AVG + GROUP BY)'
SELECT c.name AS category_name, COUNT(b.book_id) AS book_count, ROUND(AVG(b.price), 1) AS avg_price
FROM category c
LEFT JOIN book b ON c.category_id = b.category_id
GROUP BY c.category_id, c.name
ORDER BY book_count DESC, avg_price DESC;

.print ''
.print 'Q11. 집계: 대여 상태별 건수와 수수료 합계를 확인한다. (COUNT + SUM + GROUP BY)'
SELECT status, COUNT(*) AS rental_count, SUM(rental_fee) AS total_fee
FROM rental
GROUP BY status
ORDER BY rental_count DESC;

.print ''
.print 'Q12. 서브쿼리: 전체 평균 가격보다 비싼 도서를 확인한다.'
SELECT book_id, title, price
FROM book
WHERE price > (SELECT AVG(price) FROM book)
ORDER BY price DESC;

.print ''
.print 'Q13. UPDATE: rental_id=4의 대여 상태를 OVERDUE로 변경하고 결과를 확인한다.'
UPDATE rental
SET status = 'OVERDUE', rental_fee = 2000
WHERE rental_id = 4;
SELECT rental_id, member_id, book_id, due_date, status, rental_fee
FROM rental
WHERE rental_id = 4;

.print ''
.print 'Q14. DELETE: 테스트용 대여 기록 rental_id=20을 삭제하고 삭제 결과를 확인한다.'
DELETE FROM rental
WHERE rental_id = 20;
SELECT COUNT(*) AS remaining_rentals
FROM rental;

.print ''
.print 'Q15. INDEX: 회원별 반납기한 조회가 자주 발생하므로 rental(member_id, due_date)에 인덱스를 생성한다.'
CREATE INDEX IF NOT EXISTS idx_rental_member_due
ON rental(member_id, due_date);
EXPLAIN QUERY PLAN
SELECT rental_id, member_id, book_id, due_date, status
FROM rental
WHERE member_id = 1
ORDER BY due_date ASC;
