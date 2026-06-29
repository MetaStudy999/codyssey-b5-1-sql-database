-- B5-1 SQL Basics Practice
-- DB: SQLite 3
-- Purpose: repeat SELECT / WHERE / ORDER BY / LIMIT / INSERT / UPDATE / DELETE safely.
-- Usage:
--   sqlite3 book_rental.db < training-materials/01-sql-basics/practice.sql
--
-- Safety note:
--   Most statements are SELECT-only.
--   The INSERT / UPDATE / DELETE section is wrapped in a transaction and rolled back.
--   Therefore this file does not persistently modify book_rental.db.

PRAGMA foreign_keys = ON;
.headers on
.mode column

.print '============================================================'
.print 'B5-1 SQL BASICS PRACTICE'
.print '============================================================'

.print ''
.print '[Section 1] Table row counts'
SELECT 'member' AS table_name, COUNT(*) AS row_count FROM member
UNION ALL
SELECT 'category', COUNT(*) FROM category
UNION ALL
SELECT 'book', COUNT(*) FROM book
UNION ALL
SELECT 'rental', COUNT(*) FROM rental;

.print ''
.print '[Q01] SELECT: 전체 회원을 회원 ID 순으로 조회한다.'
SELECT member_id, name, email, joined_at, status
FROM member
ORDER BY member_id ASC;

.print ''
.print '[Q02] WHERE: ACTIVE 회원만 조회한다.'
SELECT member_id, name, email, status
FROM member
WHERE status = 'ACTIVE'
ORDER BY member_id ASC;

.print ''
.print '[Q03] WHERE + ORDER BY: 2024-04-01 이후 가입한 회원을 가입일 순으로 조회한다.'
SELECT member_id, name, joined_at, status
FROM member
WHERE joined_at >= '2024-04-01'
ORDER BY joined_at ASC;

.print ''
.print '[Q04] WHERE: 가격이 25,000원 이하인 도서를 조회한다.'
SELECT book_id, title, author, price
FROM book
WHERE price <= 25000
ORDER BY price ASC;

.print ''
.print '[Q05] ORDER BY + LIMIT: 가격이 가장 높은 도서 3권을 조회한다.'
SELECT book_id, title, author, price
FROM book
ORDER BY price DESC
LIMIT 3;

.print ''
.print '[Q06] LIKE: 제목에 SQL이 들어간 도서를 조회한다.'
SELECT book_id, title, author, price
FROM book
WHERE title LIKE '%SQL%'
ORDER BY title ASC;

.print ''
.print '[Q07] LIKE: 제목에 기초가 들어간 도서를 조회한다.'
SELECT book_id, title, author, price
FROM book
WHERE title LIKE '%기초%'
ORDER BY title ASC;

.print ''
.print '[Q08] IN: 대여 중 또는 연체 상태의 대여 기록을 조회한다.'
SELECT rental_id, member_id, book_id, rented_at, due_date, status
FROM rental
WHERE status IN ('RENTED', 'OVERDUE')
ORDER BY due_date ASC;

.print ''
.print '[Q09] WHERE: 연체 상태의 대여 기록만 조회한다.'
SELECT rental_id, member_id, book_id, due_date, status, rental_fee
FROM rental
WHERE status = 'OVERDUE'
ORDER BY due_date ASC;

.print ''
.print '[Q10] BETWEEN: 2024년 6월 대여 기록을 조회한다.'
SELECT rental_id, member_id, book_id, rented_at, due_date, status
FROM rental
WHERE rented_at BETWEEN '2024-06-01' AND '2024-06-30'
ORDER BY rented_at ASC;

.print ''
.print '[Q11] BETWEEN: 2024년 7월 대여 기록을 조회한다.'
SELECT rental_id, member_id, book_id, rented_at, due_date, status
FROM rental
WHERE rented_at BETWEEN '2024-07-01' AND '2024-07-31'
ORDER BY rented_at ASC;

.print ''
.print '[Q12] IS NULL: 아직 반납하지 않은 대여 기록을 조회한다.'
SELECT rental_id, member_id, book_id, due_date, returned_at, status
FROM rental
WHERE returned_at IS NULL
ORDER BY due_date ASC;

.print ''
.print '[Q13] IS NOT NULL: 반납 완료된 대여 기록을 조회한다.'
SELECT rental_id, member_id, book_id, rented_at, returned_at, status
FROM rental
WHERE returned_at IS NOT NULL
ORDER BY returned_at ASC;

.print ''
.print '[Q14] WHERE + ORDER BY: 수수료가 0보다 큰 대여 기록을 수수료 높은 순으로 조회한다.'
SELECT rental_id, member_id, book_id, rental_fee, status
FROM rental
WHERE rental_fee > 0
ORDER BY rental_fee DESC;

.print ''
.print '[Q15] Multiple conditions: ACTIVE 회원 중 2024-03-01 이후 가입자를 조회한다.'
SELECT member_id, name, email, joined_at, status
FROM member
WHERE status = 'ACTIVE'
  AND joined_at >= '2024-03-01'
ORDER BY joined_at ASC;

.print ''
.print '[Q16] Multiple ordering: 반납기한과 대여 ID 순으로 대여 기록을 조회한다.'
SELECT rental_id, member_id, book_id, due_date, status
FROM rental
ORDER BY due_date ASC, rental_id ASC;

.print ''
.print '[Q17] LIMIT: 최근 대여 기록 5건을 조회한다.'
SELECT rental_id, member_id, book_id, rented_at, status
FROM rental
ORDER BY rented_at DESC
LIMIT 5;

.print ''
.print '[Q18] SELECT specific columns: 도서 목록에서 필요한 컬럼만 조회한다.'
SELECT book_id, title, isbn, price, stock
FROM book
ORDER BY book_id ASC;

.print ''
.print '[Q19] CHECK target: 재고가 2권 이하인 도서를 조회한다.'
SELECT book_id, title, stock
FROM book
WHERE stock <= 2
ORDER BY stock ASC, book_id ASC;

.print ''
.print '[Q20] Business-style lookup: 현재 대여 중인 기록을 반납기한 빠른 순으로 조회한다.'
SELECT rental_id, member_id, book_id, rented_at, due_date, status
FROM rental
WHERE status = 'RENTED'
ORDER BY due_date ASC;

.print ''
.print '============================================================'
.print '[Section 2] Safe INSERT / UPDATE / DELETE practice with ROLLBACK'
.print '============================================================'

BEGIN TRANSACTION;

.print ''
.print '[DML-01] INSERT: 테스트 회원을 추가한다. 이 변경은 마지막에 ROLLBACK된다.'
INSERT INTO member (member_id, name, email, phone, joined_at, status)
VALUES (101, '연습회원', 'practice.member@example.com', '010-1111-2222', '2024-08-10', 'ACTIVE');

SELECT member_id, name, email, joined_at, status
FROM member
WHERE member_id = 101;

.print ''
.print '[DML-02] INSERT: 테스트 카테고리를 추가한다.'
INSERT INTO category (category_id, name, description)
VALUES (101, 'Practice', 'Practice category');

SELECT category_id, name, description
FROM category
WHERE category_id = 101;

.print ''
.print '[DML-03] INSERT: 테스트 도서를 추가한다. category_id=101을 참조한다.'
INSERT INTO book (book_id, category_id, title, author, published_year, isbn, price, stock, created_at)
VALUES (101, 101, 'SQL 연습 도서', '연습저자', 2024, '978-89-101-0101', 15000, 1, '2024-08-10');

SELECT book_id, category_id, title, isbn, price, stock
FROM book
WHERE book_id = 101;

.print ''
.print '[DML-04] INSERT: 테스트 대여 기록을 추가한다. member_id=101, book_id=101을 참조한다.'
INSERT INTO rental (rental_id, member_id, book_id, rented_at, due_date, returned_at, status, rental_fee)
VALUES (101, 101, 101, '2024-08-10', '2024-08-24', NULL, 'RENTED', 0);

SELECT rental_id, member_id, book_id, rented_at, due_date, status
FROM rental
WHERE rental_id = 101;

.print ''
.print '[DML-05] UPDATE: 테스트 대여 기록을 OVERDUE로 변경한다.'
UPDATE rental
SET status = 'OVERDUE', rental_fee = 3000
WHERE rental_id = 101;

SELECT rental_id, member_id, book_id, due_date, status, rental_fee
FROM rental
WHERE rental_id = 101;

.print ''
.print '[DML-06] UPDATE: 테스트 도서 재고를 1 증가시킨다.'
UPDATE book
SET stock = stock + 1
WHERE book_id = 101;

SELECT book_id, title, stock
FROM book
WHERE book_id = 101;

.print ''
.print '[DML-07] DELETE: 테스트 대여 기록을 삭제한다.'
DELETE FROM rental
WHERE rental_id = 101;

SELECT COUNT(*) AS test_rental_remaining_count
FROM rental
WHERE rental_id = 101;

.print ''
.print '[DML-08] ROLLBACK: 위 INSERT/UPDATE/DELETE 연습 변경을 모두 취소한다.'
ROLLBACK;

.print ''
.print '[DML-09] ROLLBACK 확인: 테스트 회원/카테고리/도서/대여 기록이 남아 있지 않아야 한다.'
SELECT 'member_101' AS object_name, COUNT(*) AS remaining_count FROM member WHERE member_id = 101
UNION ALL
SELECT 'category_101', COUNT(*) FROM category WHERE category_id = 101
UNION ALL
SELECT 'book_101', COUNT(*) FROM book WHERE book_id = 101
UNION ALL
SELECT 'rental_101', COUNT(*) FROM rental WHERE rental_id = 101;

.print ''
.print '============================================================'
.print '[Section 3] Error practice notes'
.print '============================================================'

.print ''
.print '아래 오류 재현 쿼리는 의도적으로 실패하므로 주석 처리되어 있다.'
.print '연습용 DB에서 한 줄씩 주석을 해제하여 FK / UNIQUE / CHECK 오류를 확인한다.'

-- FK 오류 예시: 없는 회원을 참조하는 rental INSERT
-- INSERT INTO rental (rental_id, member_id, book_id, rented_at, due_date, status, rental_fee)
-- VALUES (999, 999, 1, '2024-08-01', '2024-08-15', 'RENTED', 0);

-- UNIQUE 오류 예시: 이미 존재하는 이메일 입력
-- INSERT INTO member (member_id, name, email, phone, joined_at, status)
-- VALUES (102, '중복회원', 'minjun.kim@example.com', '010-2222-3333', '2024-08-10', 'ACTIVE');

-- CHECK 오류 예시: 허용되지 않는 회원 상태 입력
-- INSERT INTO member (member_id, name, email, phone, joined_at, status)
-- VALUES (103, '상태오류회원', 'bad.status@example.com', '010-3333-4444', '2024-08-10', 'WAITING');

-- CHECK 오류 예시: 음수 가격 입력
-- INSERT INTO book (book_id, category_id, title, author, published_year, isbn, price, stock, created_at)
-- VALUES (104, 1, '음수 가격 책', '오류저자', 2024, '978-89-104-0104', -1000, 1, '2024-08-10');

.print ''
.print '============================================================'
.print 'Practice completed. Persistent database changes should be zero.'
.print '============================================================'
