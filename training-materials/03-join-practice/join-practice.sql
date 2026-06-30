-- ============================================================================
-- B5-1 JOIN Practice Script
-- DB: SQLite 3
-- Purpose: practice INNER JOIN, LEFT JOIN, JOIN + GROUP BY, and JOIN vs subquery.
-- Usage:
--   sqlite3 book_rental.db < training-materials/03-join-practice/join-practice.sql
--
-- Safety note:
--   This file is SELECT-only. It does not modify book_rental.db.
--
-- 입문자 메모
-- - JOIN은 여러 테이블에 나뉘어 저장된 데이터를 한 결과표로 연결하는 문법입니다.
-- - 이 프로젝트에서는 rental.member_id -> member.member_id,
--   rental.book_id -> book.book_id, book.category_id -> category.category_id
--   관계를 따라가며 데이터를 붙입니다.
-- - INNER JOIN은 양쪽에 매칭되는 행만 보여주고,
--   LEFT JOIN은 왼쪽 테이블의 행을 최대한 유지합니다.
-- ============================================================================

-- ============================================================================
-- 1. SQLite 기본 설정
-- ============================================================================
-- 외래키 검사를 켜고, SQLite CLI 결과를 표 형태로 보기 좋게 출력합니다.
-- .headers, .mode, .print는 SQLite CLI 전용 보조 명령입니다.
PRAGMA foreign_keys = ON;
.headers on
.mode column

-- ============================================================================
-- 2. 실습 시작 안내 출력
-- ============================================================================
-- 터미널에서 어떤 실습 파일이 실행 중인지 알아보기 쉽도록 제목을 출력합니다.
.print '============================================================'
.print 'B5-1 JOIN PRACTICE'
.print '============================================================'

-- ============================================================================
-- 3. ERD 관계 확인
-- ============================================================================
-- JOIN을 쓰기 전에는 어떤 컬럼끼리 연결되는지 먼저 확인해야 합니다.
-- 아래 관계는 1개의 부모 행이 여러 자식 행과 연결될 수 있는 1:N 관계입니다.
.print ''
.print '[Section 1] ERD relationship check'
.print 'Core relationships: category 1:N book, member 1:N rental, book 1:N rental'

-- ============================================================================
-- 4. INNER JOIN 기본 연습
-- ============================================================================
-- INNER JOIN은 ON 조건이 맞는 행만 결과에 남깁니다.
-- 별칭(alias) b, c, r, m을 사용하면 긴 테이블명을 짧게 쓸 수 있습니다.
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

-- 여러 테이블을 차례로 JOIN하면 member, rental, book, category 정보를 한 번에 볼 수 있습니다.
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

-- ============================================================================
-- 5. INNER JOIN + 조건절 연습
-- ============================================================================
-- JOIN으로 필요한 정보를 붙인 뒤 WHERE로 원하는 행만 필터링합니다.
-- ORDER BY와 LIMIT를 함께 쓰면 업무에서 자주 보는 "최근 N건" 조회를 만들 수 있습니다.
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

-- ============================================================================
-- 6. LEFT JOIN 연습
-- ============================================================================
-- LEFT JOIN은 왼쪽 테이블의 행을 모두 유지합니다.
-- 대여 기록이 없는 회원처럼 "아직 연결된 데이터가 없는 대상"을 찾을 때 중요합니다.
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

-- LEFT JOIN 결과에서 오른쪽 테이블의 PK가 NULL이면 연결된 행이 없다는 뜻입니다.
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

-- ============================================================================
-- 7. LEFT JOIN 심화: ON 조건, COUNT 차이, COALESCE
-- ============================================================================
-- LEFT JOIN에서 조건을 WHERE가 아니라 ON에 두면 왼쪽 행을 유지하면서 오른쪽 행만 제한할 수 있습니다.
-- COUNT(*)는 NULL로 채워진 LEFT JOIN 결과 행도 세지만, COUNT(컬럼)은 NULL을 세지 않습니다.
-- COALESCE는 NULL 대신 보여줄 기본값을 정할 때 사용합니다.
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

-- ============================================================================
-- 8. JOIN vs 서브쿼리 연습
-- ============================================================================
-- 같은 문제를 JOIN과 서브쿼리로 모두 풀 수 있는 경우가 많습니다.
-- JOIN은 여러 테이블의 컬럼을 함께 보여줄 때 자연스럽고,
-- 서브쿼리는 "먼저 조건값을 구한 뒤 바깥 쿼리에서 사용"할 때 읽기 좋습니다.
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

-- ============================================================================
-- 9. 서브쿼리 심화: 스칼라, EXISTS, NOT EXISTS, 상관 서브쿼리
-- ============================================================================
-- 스칼라 서브쿼리는 값 1개를 반환해 비교식에 사용할 수 있습니다.
-- EXISTS는 서브쿼리 결과가 하나라도 있으면 참입니다.
-- 상관 서브쿼리는 바깥 쿼리의 값을 안쪽 쿼리에서 참조합니다.
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

-- ============================================================================
-- 10. 자기 점검 질문
-- ============================================================================
-- 아래 질문은 결과를 외우기보다 JOIN의 동작 원리를 말로 설명하기 위한 연습입니다.
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

-- ============================================================================
-- 11. 실습 종료 안내
-- ============================================================================
-- 이 파일은 SELECT 전용이므로 데이터베이스 내용을 변경하지 않습니다.
.print ''
.print '============================================================'
.print 'JOIN practice completed. No database changes were made.'
.print '============================================================'
