-- B5-1 Aggregation Practice Script
-- DB: SQLite 3
-- Purpose: practice GROUP BY, COUNT, SUM, AVG, HAVING, TOP N, and ranking queries.
-- Usage:
--   sqlite3 book_rental.db < training-materials/04-aggregation-practice/aggregation-practice.sql
--
-- Safety note:
--   This file is SELECT-only. It does not modify book_rental.db.

PRAGMA foreign_keys = ON;
.headers on
.mode column

.print '============================================================'
.print 'B5-1 AGGREGATION PRACTICE'
.print 'GROUP BY / COUNT / SUM / AVG / HAVING / RANKING'
.print '============================================================'

.print ''
.print '[Section 1] Basic aggregation'

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
.print '[Q02] 전체 대여 기록 수를 계산한다.'
SELECT COUNT(*) AS rental_count
FROM rental;

.print ''
.print '[Q03] 대여 상태별 건수를 계산한다.'
SELECT status,
       COUNT(*) AS rental_count
FROM rental
GROUP BY status
ORDER BY rental_count DESC, status ASC;

.print ''
.print '[Q04] 대여 상태별 수수료 합계와 평균 수수료를 계산한다.'
SELECT status,
       COUNT(*) AS rental_count,
       SUM(rental_fee) AS total_fee,
       ROUND(AVG(rental_fee), 2) AS avg_fee
FROM rental
GROUP BY status
ORDER BY total_fee DESC, rental_count DESC;

.print ''
.print '[Q05] 전체 도서 가격 통계를 계산한다.'
SELECT COUNT(*) AS book_count,
       MIN(price) AS min_price,
       MAX(price) AS max_price,
       ROUND(AVG(price), 2) AS avg_price,
       SUM(price) AS total_price
FROM book;

.print ''
.print '[Q06] 회원 상태별 회원 수를 계산한다.'
SELECT status,
       COUNT(*) AS member_count
FROM member
GROUP BY status
ORDER BY member_count DESC, status ASC;

.print ''
.print '[Section 2] JOIN + GROUP BY aggregation'

.print ''
.print '[Q07] 회원별 대여 횟수를 계산한다. INNER JOIN이므로 대여 기록이 있는 회원만 나온다.'
SELECT m.member_id,
       m.name AS member_name,
       COUNT(r.rental_id) AS rental_count
FROM member m
INNER JOIN rental r ON m.member_id = r.member_id
GROUP BY m.member_id, m.name
ORDER BY rental_count DESC, m.member_id ASC;

.print ''
.print '[Q08] 회원별 대여 횟수를 0건 포함해 계산한다. LEFT JOIN을 사용한다.'
SELECT m.member_id,
       m.name AS member_name,
       COUNT(r.rental_id) AS rental_count
FROM member m
LEFT JOIN rental r ON m.member_id = r.member_id
GROUP BY m.member_id, m.name
ORDER BY rental_count DESC, m.member_id ASC;

.print ''
.print '[Q09] 회원별 대여 횟수와 수수료 합계를 0건 포함해 계산한다.'
SELECT m.member_id,
       m.name AS member_name,
       COUNT(r.rental_id) AS rental_count,
       COALESCE(SUM(r.rental_fee), 0) AS total_fee,
       COALESCE(ROUND(AVG(r.rental_fee), 2), 0) AS avg_fee
FROM member m
LEFT JOIN rental r ON m.member_id = r.member_id
GROUP BY m.member_id, m.name
ORDER BY total_fee DESC, rental_count DESC, m.member_id ASC;

.print ''
.print '[Q10] 카테고리별 도서 수와 가격 통계를 계산한다.'
SELECT c.category_id,
       c.name AS category_name,
       COUNT(b.book_id) AS book_count,
       COALESCE(MIN(b.price), 0) AS min_price,
       COALESCE(MAX(b.price), 0) AS max_price,
       COALESCE(ROUND(AVG(b.price), 2), 0) AS avg_price
FROM category c
LEFT JOIN book b ON c.category_id = b.category_id
GROUP BY c.category_id, c.name
ORDER BY book_count DESC, avg_price DESC, c.category_id ASC;

.print ''
.print '[Q11] 도서별 대여 횟수를 0건 포함해 계산한다.'
SELECT b.book_id,
       b.title,
       COUNT(r.rental_id) AS rental_count
FROM book b
LEFT JOIN rental r ON b.book_id = r.book_id
GROUP BY b.book_id, b.title
ORDER BY rental_count DESC, b.book_id ASC;

.print ''
.print '[Q12] 카테고리별 대여 횟수를 계산한다.'
SELECT c.category_id,
       c.name AS category_name,
       COUNT(r.rental_id) AS rental_count
FROM category c
INNER JOIN book b ON c.category_id = b.category_id
INNER JOIN rental r ON b.book_id = r.book_id
GROUP BY c.category_id, c.name
ORDER BY rental_count DESC, c.category_id ASC;

.print ''
.print '[Q13] 월별 대여 건수를 계산한다.'
SELECT substr(rented_at, 1, 7) AS rental_month,
       COUNT(*) AS rental_count
FROM rental
GROUP BY substr(rented_at, 1, 7)
ORDER BY rental_month ASC;

.print ''
.print '[Q14] 월별·상태별 대여 건수를 계산한다.'
SELECT substr(rented_at, 1, 7) AS rental_month,
       status,
       COUNT(*) AS rental_count
FROM rental
GROUP BY substr(rented_at, 1, 7), status
ORDER BY rental_month ASC, status ASC;

.print ''
.print '[Q15] 회원별 연체 기록 수와 연체 수수료 합계를 계산한다.'
SELECT m.member_id,
       m.name AS member_name,
       COUNT(r.rental_id) AS overdue_count,
       SUM(r.rental_fee) AS overdue_fee
FROM member m
INNER JOIN rental r ON m.member_id = r.member_id
WHERE r.status = 'OVERDUE'
GROUP BY m.member_id, m.name
ORDER BY overdue_fee DESC, overdue_count DESC, m.member_id ASC;

.print ''
.print '[Section 3] HAVING practice'

.print ''
.print '[Q16] 대여 횟수가 2건 이상인 회원만 조회한다.'
SELECT m.member_id,
       m.name AS member_name,
       COUNT(r.rental_id) AS rental_count
FROM member m
INNER JOIN rental r ON m.member_id = r.member_id
GROUP BY m.member_id, m.name
HAVING COUNT(r.rental_id) >= 2
ORDER BY rental_count DESC, m.member_id ASC;

.print ''
.print '[Q17] 도서 수가 2권 이상인 카테고리만 조회한다.'
SELECT c.category_id,
       c.name AS category_name,
       COUNT(b.book_id) AS book_count
FROM category c
INNER JOIN book b ON c.category_id = b.category_id
GROUP BY c.category_id, c.name
HAVING COUNT(b.book_id) >= 2
ORDER BY book_count DESC, c.category_id ASC;

.print ''
.print '[Q18] 대여 횟수가 2건 이상인 도서만 조회한다.'
SELECT b.book_id,
       b.title,
       COUNT(r.rental_id) AS rental_count
FROM book b
INNER JOIN rental r ON b.book_id = r.book_id
GROUP BY b.book_id, b.title
HAVING COUNT(r.rental_id) >= 2
ORDER BY rental_count DESC, b.book_id ASC;

.print ''
.print '[Q19] 평균 가격이 30,000원 이상인 카테고리만 조회한다.'
SELECT c.category_id,
       c.name AS category_name,
       COUNT(b.book_id) AS book_count,
       ROUND(AVG(b.price), 2) AS avg_price
FROM category c
INNER JOIN book b ON c.category_id = b.category_id
GROUP BY c.category_id, c.name
HAVING AVG(b.price) >= 30000
ORDER BY avg_price DESC, c.category_id ASC;

.print ''
.print '[Q20] 수수료 합계가 0보다 큰 대여 상태만 조회한다.'
SELECT status,
       COUNT(*) AS rental_count,
       SUM(rental_fee) AS total_fee
FROM rental
GROUP BY status
HAVING SUM(rental_fee) > 0
ORDER BY total_fee DESC;

.print ''
.print '[Section 4] Ranking aggregation'

.print ''
.print '[Q21] 가격이 높은 도서 TOP 5를 조회한다.'
SELECT book_id,
       title,
       author,
       price
FROM book
ORDER BY price DESC, book_id ASC
LIMIT 5;

.print ''
.print '[Q22] 인기 도서 TOP 5를 조회한다.'
SELECT b.book_id,
       b.title,
       COUNT(r.rental_id) AS rental_count
FROM book b
INNER JOIN rental r ON b.book_id = r.book_id
GROUP BY b.book_id, b.title
ORDER BY rental_count DESC, b.book_id ASC
LIMIT 5;

.print ''
.print '[Q23] 회원별 대여 횟수 TOP 5를 조회한다.'
SELECT m.member_id,
       m.name AS member_name,
       COUNT(r.rental_id) AS rental_count
FROM member m
INNER JOIN rental r ON m.member_id = r.member_id
GROUP BY m.member_id, m.name
ORDER BY rental_count DESC, m.member_id ASC
LIMIT 5;

.print ''
.print '[Q24] 회원별 수수료 합계 TOP 5를 조회한다.'
SELECT m.member_id,
       m.name AS member_name,
       COUNT(r.rental_id) AS rental_count,
       SUM(r.rental_fee) AS total_fee
FROM member m
INNER JOIN rental r ON m.member_id = r.member_id
GROUP BY m.member_id, m.name
ORDER BY total_fee DESC, rental_count DESC, m.member_id ASC
LIMIT 5;

.print ''
.print '[Q25] 카테고리별 평균 가격 순위를 조회한다.'
SELECT c.category_id,
       c.name AS category_name,
       COUNT(b.book_id) AS book_count,
       ROUND(AVG(b.price), 2) AS avg_price
FROM category c
INNER JOIN book b ON c.category_id = b.category_id
GROUP BY c.category_id, c.name
ORDER BY avg_price DESC, c.category_id ASC;

.print ''
.print '[Q26] 월별 대여 건수 순위를 조회한다.'
SELECT substr(rented_at, 1, 7) AS rental_month,
       COUNT(*) AS rental_count
FROM rental
GROUP BY substr(rented_at, 1, 7)
ORDER BY rental_count DESC, rental_month ASC;

.print ''
.print '[Section 5] Window function ranking practice'

.print ''
.print '[Q27] 도서 가격 순위 번호를 붙인다.'
SELECT book_id,
       title,
       price,
       ROW_NUMBER() OVER (ORDER BY price DESC, book_id ASC) AS price_row_number,
       RANK() OVER (ORDER BY price DESC) AS price_rank,
       DENSE_RANK() OVER (ORDER BY price DESC) AS price_dense_rank
FROM book
ORDER BY price DESC, book_id ASC;

.print ''
.print '[Q28] 카테고리 안에서 도서 가격 순위를 매긴다.'
SELECT c.name AS category_name,
       b.book_id,
       b.title,
       b.price,
       ROW_NUMBER() OVER (
           PARTITION BY c.category_id
           ORDER BY b.price DESC, b.book_id ASC
       ) AS price_rank_in_category
FROM book b
INNER JOIN category c ON b.category_id = c.category_id
ORDER BY c.name ASC, price_rank_in_category ASC;

.print ''
.print '[Q29] 카테고리별 최고가 도서만 조회한다.'
SELECT category_name,
       book_id,
       title,
       price
FROM (
    SELECT c.name AS category_name,
           b.book_id,
           b.title,
           b.price,
           ROW_NUMBER() OVER (
               PARTITION BY c.category_id
               ORDER BY b.price DESC, b.book_id ASC
           ) AS rn
    FROM book b
    INNER JOIN category c ON b.category_id = c.category_id
) ranked_books
WHERE rn = 1
ORDER BY category_name ASC;

.print ''
.print '[Section 6] Self-check prompts'

.print ''
.print '설명 연습 1: GROUP BY는 무엇을 기준으로 행을 묶는가?'
.print '설명 연습 2: COUNT, SUM, AVG는 각각 무엇을 계산하는가?'
.print '설명 연습 3: WHERE와 HAVING은 적용 시점이 어떻게 다른가?'
.print '설명 연습 4: 회원별 대여 횟수는 왜 JOIN 후 GROUP BY를 사용하는가?'
.print '설명 연습 5: 인기 도서 TOP 5는 어떤 순서로 계산되는가?'
.print '설명 연습 6: ROW_NUMBER, RANK, DENSE_RANK의 차이는 무엇인가?'

.print ''
.print '============================================================'
.print 'Aggregation practice completed. No database changes were made.'
.print '============================================================'
