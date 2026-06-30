-- B5-1 Final Review Practice Script
-- DB: SQLite 3
-- Purpose: final smoke test for schema, data, relationships, joins, aggregation, subquery, DML safety, and index review.
-- Usage:
--   sqlite3 book_rental.db < training-materials/07-review/review-practice.sql
--
-- Safety note:
--   This script does not persist row data changes.
--   UPDATE/DELETE practice is wrapped in SAVEPOINT and rolled back.
--   It may create idx_rental_member_due if the index is missing, because that index is part of the B5-1 core query requirement.

PRAGMA foreign_keys = ON;
.headers on
.mode column

.print '============================================================'
.print 'B5-1 FINAL REVIEW PRACTICE'
.print 'schema / data / join / aggregation / subquery / dml / index'
.print '============================================================'

.print ''
.print '[Section 1] Submission readiness smoke check'

.print ''
.print '[Q01] 테이블별 행 수를 확인한다.'
SELECT 'member' AS table_name, COUNT(*) AS row_count FROM member
UNION ALL
SELECT 'category', COUNT(*) FROM category
UNION ALL
SELECT 'book', COUNT(*) FROM book
UNION ALL
SELECT 'rental', COUNT(*) FROM rental;

.print ''
.print '[Q02] 핵심 테이블 목록을 확인한다.'
SELECT name AS table_name
FROM sqlite_master
WHERE type = 'table'
  AND name IN ('member', 'category', 'book', 'rental')
ORDER BY name ASC;

.print ''
.print '[Q03] rental 테이블의 FK 목록을 확인한다.'
PRAGMA foreign_key_list('rental');

.print ''
.print '[Q04] book 테이블의 FK 목록을 확인한다.'
PRAGMA foreign_key_list('book');

.print ''
.print '[Q05] FK 무결성 위반 여부를 확인한다. 결과가 비어 있으면 정상이다.'
PRAGMA foreign_key_check;

.print ''
.print '============================================================'
.print '[Section 2] Basic SELECT review'
.print '============================================================'

.print ''
.print '[Q06] ACTIVE 회원 중 2024-03-01 이후 가입자를 조회한다.'
SELECT member_id,
       name,
       email,
       joined_at,
       status
FROM member
WHERE status = 'ACTIVE'
  AND joined_at >= '2024-03-01'
ORDER BY joined_at ASC, member_id ASC;

.print ''
.print '[Q07] 30,000원 이상 도서를 가격 높은 순으로 5권 조회한다.'
SELECT book_id,
       title,
       author,
       price
FROM book
WHERE price >= 30000
ORDER BY price DESC, book_id ASC
LIMIT 5;

.print ''
.print '[Q08] 제목에 SQL이 포함된 도서를 검색한다.'
SELECT book_id,
       title,
       author,
       price
FROM book
WHERE title LIKE '%SQL%'
ORDER BY title ASC;

.print ''
.print '[Q09] 현재 대여 중 또는 연체 상태의 대여 기록을 반납기한 순으로 조회한다.'
SELECT rental_id,
       member_id,
       book_id,
       rented_at,
       due_date,
       status
FROM rental
WHERE status IN ('RENTED', 'OVERDUE')
ORDER BY due_date ASC, rental_id ASC;

.print ''
.print '============================================================'
.print '[Section 3] JOIN review'
.print '============================================================'

.print ''
.print '[Q10] INNER JOIN: 최근 대여 기록에 회원명과 도서명을 붙인다.'
SELECT r.rental_id,
       m.name AS member_name,
       b.title AS book_title,
       r.rented_at,
       r.status
FROM rental r
INNER JOIN member m ON r.member_id = m.member_id
INNER JOIN book b ON r.book_id = b.book_id
ORDER BY r.rented_at DESC, r.rental_id DESC
LIMIT 10;

.print ''
.print '[Q11] INNER JOIN: 도서와 카테고리를 연결한다.'
SELECT b.book_id,
       b.title,
       c.name AS category_name,
       b.price
FROM book b
INNER JOIN category c ON b.category_id = c.category_id
ORDER BY c.name ASC, b.title ASC;

.print ''
.print '[Q12] INNER JOIN: 연체 기록의 회원/도서/카테고리/수수료를 조회한다.'
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
ORDER BY r.due_date ASC, r.rental_id ASC;

.print ''
.print '[Q13] LEFT JOIN: 대여 기록이 없는 회원까지 포함해 회원별 대여 횟수를 조회한다.'
SELECT m.member_id,
       m.name,
       COUNT(r.rental_id) AS rental_count
FROM member m
LEFT JOIN rental r ON m.member_id = r.member_id
GROUP BY m.member_id, m.name
ORDER BY rental_count ASC, m.member_id ASC;

.print ''
.print '============================================================'
.print '[Section 4] GROUP BY and ranking review'
.print '============================================================'

.print ''
.print '[Q14] 회원별 총 대여 횟수와 납부 수수료 합계를 조회한다.'
SELECT m.member_id,
       m.name,
       COUNT(r.rental_id) AS rental_count,
       SUM(r.rental_fee) AS total_fee
FROM member m
INNER JOIN rental r ON m.member_id = r.member_id
GROUP BY m.member_id, m.name
ORDER BY rental_count DESC, total_fee DESC, m.member_id ASC;

.print ''
.print '[Q15] 카테고리별 보유 도서 수와 평균 가격을 조회한다.'
SELECT c.category_id,
       c.name AS category_name,
       COUNT(b.book_id) AS book_count,
       ROUND(AVG(b.price), 1) AS avg_price
FROM category c
LEFT JOIN book b ON c.category_id = b.category_id
GROUP BY c.category_id, c.name
ORDER BY book_count DESC, avg_price DESC, c.category_id ASC;

.print ''
.print '[Q16] 대여 상태별 건수와 수수료 합계를 조회한다.'
SELECT status,
       COUNT(*) AS rental_count,
       SUM(rental_fee) AS total_fee
FROM rental
GROUP BY status
ORDER BY rental_count DESC, status ASC;

.print ''
.print '[Q17] 인기 도서 TOP 5를 조회한다.'
SELECT b.book_id,
       b.title,
       COUNT(r.rental_id) AS rental_count
FROM book b
INNER JOIN rental r ON b.book_id = r.book_id
GROUP BY b.book_id, b.title
ORDER BY rental_count DESC, b.book_id ASC
LIMIT 5;

.print ''
.print '[Q18] HAVING: 대여 횟수가 2건 이상인 회원만 조회한다.'
SELECT m.member_id,
       m.name,
       COUNT(r.rental_id) AS rental_count
FROM member m
INNER JOIN rental r ON m.member_id = r.member_id
GROUP BY m.member_id, m.name
HAVING COUNT(r.rental_id) >= 2
ORDER BY rental_count DESC, m.member_id ASC;

.print ''
.print '============================================================'
.print '[Section 5] Subquery review'
.print '============================================================'

.print ''
.print '[Q19] 스칼라 서브쿼리: 전체 평균 가격보다 비싼 도서를 조회한다.'
SELECT book_id,
       title,
       price
FROM book
WHERE price > (
    SELECT AVG(price)
    FROM book
)
ORDER BY price DESC, book_id ASC;

.print ''
.print '[Q20] IN 서브쿼리: 대여 기록이 있는 회원을 조회한다.'
SELECT member_id,
       name,
       email
FROM member
WHERE member_id IN (
    SELECT member_id
    FROM rental
)
ORDER BY member_id ASC;

.print ''
.print '[Q21] NOT EXISTS: 대여 기록이 없는 회원을 조회한다.'
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
.print '[Q22] 상관 서브쿼리: 카테고리별 도서 수를 조회한다.'
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
.print '[Section 6] UPDATE/DELETE safety review - rolled back'
.print '============================================================'

.print ''
.print '[Q23] UPDATE 안전 연습: rental_id=4를 수정한 뒤 ROLLBACK한다.'
SELECT rental_id,
       member_id,
       book_id,
       status,
       rental_fee
FROM rental
WHERE rental_id = 4;

SAVEPOINT review_update;
UPDATE rental
SET status = 'OVERDUE',
    rental_fee = 2000
WHERE rental_id = 4;

SELECT rental_id,
       member_id,
       book_id,
       status,
       rental_fee
FROM rental
WHERE rental_id = 4;

ROLLBACK TO review_update;
RELEASE review_update;

.print '[Q23-check] UPDATE ROLLBACK 후 원래 상태를 다시 확인한다.'
SELECT rental_id,
       member_id,
       book_id,
       status,
       rental_fee
FROM rental
WHERE rental_id = 4;

.print ''
.print '[Q24] DELETE 안전 연습: rental_id=20을 삭제한 뒤 ROLLBACK한다.'
SELECT COUNT(*) AS before_delete_count
FROM rental;

SAVEPOINT review_delete;
DELETE FROM rental
WHERE rental_id = 20;

SELECT COUNT(*) AS after_delete_count_inside_savepoint
FROM rental;

ROLLBACK TO review_delete;
RELEASE review_delete;

.print '[Q24-check] DELETE ROLLBACK 후 전체 건수를 다시 확인한다.'
SELECT COUNT(*) AS after_rollback_count
FROM rental;

.print ''
.print '============================================================'
.print '[Section 7] Index and execution plan review'
.print '============================================================'

.print ''
.print '[Q25] 인덱스를 생성하거나 이미 있으면 유지한다.'
CREATE INDEX IF NOT EXISTS idx_rental_member_due
ON rental(member_id, due_date);

.print ''
.print '[Q26] rental 테이블 인덱스 목록을 확인한다.'
PRAGMA index_list('rental');

.print ''
.print '[Q27] idx_rental_member_due 구성 컬럼을 확인한다.'
PRAGMA index_info('idx_rental_member_due');

.print ''
.print '[Q28] EXPLAIN QUERY PLAN으로 회원별 반납기한 조회 계획을 확인한다.'
EXPLAIN QUERY PLAN
SELECT rental_id,
       member_id,
       book_id,
       due_date,
       status
FROM rental
WHERE member_id = 1
ORDER BY due_date ASC;

.print ''
.print '============================================================'
.print '[Section 8] Evaluation speaking prompts'
.print '============================================================'

.print ''
.print '말하기 1: 4개 테이블 역할을 설명하라.'
.print '말하기 2: 1:N 관계 3개를 설명하라.'
.print '말하기 3: rental 테이블이 필요한 이유를 설명하라.'
.print '말하기 4: INNER JOIN과 LEFT JOIN 차이를 설명하라.'
.print '말하기 5: GROUP BY와 COUNT/SUM/AVG를 설명하라.'
.print '말하기 6: WHERE와 HAVING 차이를 설명하라.'
.print '말하기 7: 평균 가격보다 비싼 도서 서브쿼리를 설명하라.'
.print '말하기 8: UPDATE/DELETE 안전 규칙을 설명하라.'
.print '말하기 9: idx_rental_member_due 인덱스 목적을 설명하라.'
.print '말하기 10: EXPLAIN QUERY PLAN의 역할을 설명하라.'

.print ''
.print '============================================================'
.print 'Final review completed. Row data changes were rolled back.'
.print '============================================================'
