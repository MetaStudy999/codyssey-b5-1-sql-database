PRAGMA foreign_keys = ON;
.headers on
.mode column

.print 'Bonus 1-A. JOIN 방식: AI 카테고리 도서를 대여한 회원을 찾는다.'
SELECT DISTINCT m.member_id, m.name
FROM member m
INNER JOIN rental r ON m.member_id = r.member_id
INNER JOIN book b ON r.book_id = b.book_id
INNER JOIN category c ON b.category_id = c.category_id
WHERE c.name = 'AI'
ORDER BY m.member_id;

.print ''
.print 'Bonus 1-B. 서브쿼리 방식: 같은 요구를 IN 서브쿼리로 해결한다.'
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

.print ''
.print 'Bonus 2. FK 오류 데모: 아래 주석을 해제하면 없는 member_id=999를 참조하므로 실패한다.'
SELECT 'member_id=999는 member 테이블에 없으므로 아래 INSERT를 실행하면 FOREIGN KEY constraint failed가 발생한다.' AS fk_demo_note;
-- INSERT INTO rental (rental_id, member_id, book_id, rented_at, due_date, status, rental_fee)
-- VALUES (999, 999, 1, '2024-08-01', '2024-08-15', 'RENTED', 0);

.print ''
.print 'Bonus 3-1. 미니 리포트: 월별 대여 건수와 상태별 건수를 확인한다.'
SELECT
    substr(rented_at, 1, 7) AS rental_month,
    COUNT(*) AS total_rentals,
    SUM(CASE WHEN status = 'RETURNED' THEN 1 ELSE 0 END) AS returned_count,
    SUM(CASE WHEN status = 'RENTED' THEN 1 ELSE 0 END) AS current_rented_count,
    SUM(CASE WHEN status = 'OVERDUE' THEN 1 ELSE 0 END) AS overdue_count,
    SUM(rental_fee) AS total_fee
FROM rental
GROUP BY substr(rented_at, 1, 7)
ORDER BY rental_month;

.print ''
.print 'Bonus 3-2. 미니 리포트: 가장 많이 대여된 도서 TOP 5를 확인한다.'
SELECT
    b.book_id,
    b.title,
    c.name AS category_name,
    COUNT(r.rental_id) AS rental_count,
    SUM(r.rental_fee) AS total_fee
FROM book b
INNER JOIN category c ON b.category_id = c.category_id
INNER JOIN rental r ON b.book_id = r.book_id
GROUP BY b.book_id, b.title, c.name
ORDER BY rental_count DESC, total_fee DESC, b.book_id ASC
LIMIT 5;

.print ''
.print 'Bonus 3-3. 미니 리포트: 연체율이 높은 회원을 확인한다.'
SELECT
    m.member_id,
    m.name,
    COUNT(r.rental_id) AS total_rentals,
    SUM(CASE WHEN r.status = 'OVERDUE' THEN 1 ELSE 0 END) AS overdue_count,
    ROUND(
        100.0 * SUM(CASE WHEN r.status = 'OVERDUE' THEN 1 ELSE 0 END)
        / COUNT(r.rental_id),
        1
    ) AS overdue_rate_percent,
    SUM(r.rental_fee) AS total_fee
FROM member m
INNER JOIN rental r ON m.member_id = r.member_id
GROUP BY m.member_id, m.name
HAVING overdue_count > 0
ORDER BY overdue_rate_percent DESC, total_fee DESC, m.member_id ASC;
