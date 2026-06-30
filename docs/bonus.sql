-- ============================================================================
-- B5-1 SQL Mission: bonus queries
--
-- 입문자 메모
-- - 이 파일은 핵심 과제 이후에 풀어보는 추가 연습 문제입니다.
-- - 같은 요구사항을 JOIN과 서브쿼리로 각각 해결해 보며 차이를 비교합니다.
-- - FK 오류 데모는 일부러 실패하는 예제이므로 기본 상태에서는 주석 처리되어 있습니다.
-- - 미니 리포트 쿼리는 GROUP BY, CASE, HAVING을 함께 연습합니다.
-- ============================================================================

-- ============================================================================
-- 1. SQLite CLI 출력 설정
-- ============================================================================
-- bonus.sql도 기존 스키마/seed 데이터 위에서 실행됩니다.
-- 결과를 읽기 쉽게 보기 위해 headers와 column 모드를 켭니다.
PRAGMA foreign_keys = ON;
.headers on
.mode column

-- ============================================================================
-- 2. Bonus 1-A: JOIN으로 AI 카테고리 대여 회원 찾기
-- ============================================================================
-- member -> rental -> book -> category 순서로 테이블을 연결합니다.
-- DISTINCT는 같은 회원이 AI 책을 여러 번 빌려도 한 번만 보이게 합니다.
.print 'Bonus 1-A. JOIN 방식: AI 카테고리 도서를 대여한 회원을 찾는다.'
SELECT DISTINCT m.member_id, m.name
FROM member m
INNER JOIN rental r ON m.member_id = r.member_id
INNER JOIN book b ON r.book_id = b.book_id
INNER JOIN category c ON b.category_id = c.category_id
WHERE c.name = 'AI'
ORDER BY m.member_id;

-- ============================================================================
-- 3. Bonus 1-B: 서브쿼리로 같은 문제 풀기
-- ============================================================================
-- 가장 안쪽 쿼리부터 AI 카테고리 id를 찾고,
-- 그 카테고리의 book_id를 찾은 뒤,
-- 해당 book_id를 빌린 member_id를 찾아 바깥 쿼리에 전달합니다.
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

-- ============================================================================
-- 4. Bonus 2: 외래키 오류 데모
-- ============================================================================
-- 아래 INSERT는 member_id=999를 참조하지만 member 테이블에 그런 회원이 없습니다.
-- 주석을 해제하고 실행하면 FK 규칙이 데이터를 막아 주는 모습을 확인할 수 있습니다.
.print ''
.print 'Bonus 2. FK 오류 데모: 아래 주석을 해제하면 없는 member_id=999를 참조하므로 실패한다.'
SELECT 'member_id=999는 member 테이블에 없으므로 아래 INSERT를 실행하면 FOREIGN KEY constraint failed가 발생한다.' AS fk_demo_note;
-- INSERT INTO rental (rental_id, member_id, book_id, rented_at, due_date, status, rental_fee)
-- VALUES (999, 999, 1, '2024-08-01', '2024-08-15', 'RENTED', 0);

-- ============================================================================
-- 5. Bonus 3-1: 월별 대여 미니 리포트
-- ============================================================================
-- substr(rented_at, 1, 7)은 날짜 문자열에서 YYYY-MM 부분만 잘라 월 단위로 묶습니다.
-- CASE WHEN은 조건에 맞는 행만 1로 세어 상태별 건수를 만들 때 자주 씁니다.
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

-- ============================================================================
-- 6. Bonus 3-2: 많이 대여된 도서 TOP 5
-- ============================================================================
-- 도서별 대여 횟수와 수수료 합계를 구한 뒤, 많이 빌린 순서로 정렬합니다.
-- LIMIT 5는 상위 5개만 확인하기 위한 제한입니다.
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

-- ============================================================================
-- 7. Bonus 3-3: 연체율이 높은 회원 찾기
-- ============================================================================
-- HAVING은 GROUP BY로 묶은 결과에 조건을 거는 문법입니다.
-- 여기서는 연체 건수가 1건 이상인 회원만 남긴 뒤 연체율 순으로 정렬합니다.
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
