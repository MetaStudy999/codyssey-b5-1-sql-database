-- ============================================================================
-- Validation script for evaluator/self-check
--
-- 입문자 메모
-- - 이 파일은 스키마와 샘플 데이터가 기대대로 만들어졌는지 확인하는 점검표입니다.
-- - 보통 01_schema.sql -> 02_seed.sql 실행 후 이 파일을 실행합니다.
-- - 결과가 비어 있어야 정상인 점검도 있습니다. 특히 PRAGMA foreign_key_check가 그렇습니다.
-- ============================================================================

-- ============================================================================
-- 1. SQLite CLI 출력 설정
-- ============================================================================
-- 외래키 검사를 켜고, 결과를 표 형태로 보기 좋게 출력합니다.
PRAGMA foreign_keys = ON;
.headers on
.mode column

-- ============================================================================
-- 2. 테이블 생성 여부 확인
-- ============================================================================
-- sqlite_master는 SQLite가 내부적으로 관리하는 메타데이터 테이블입니다.
-- 여기서 type='table'인 항목을 조회하면 현재 DB에 생성된 테이블 목록을 볼 수 있습니다.
.print '1) Table list'
SELECT name AS table_name
FROM sqlite_master
WHERE type = 'table'
ORDER BY name;

-- ============================================================================
-- 3. 샘플 데이터 입력 건수 확인
-- ============================================================================
-- UNION ALL은 여러 SELECT 결과를 세로로 이어 붙입니다.
-- 각 테이블에 seed 데이터가 충분히 들어갔는지 한 화면에서 확인합니다.
.print ''
.print '2) Row counts: every table should have at least 10 rows after seeding.'
SELECT 'member' AS table_name, COUNT(*) AS row_count FROM member
UNION ALL
SELECT 'category', COUNT(*) FROM category
UNION ALL
SELECT 'book', COUNT(*) FROM book
UNION ALL
SELECT 'rental', COUNT(*) FROM rental;

-- ============================================================================
-- 4. 외래키 무결성 확인
-- ============================================================================
-- 결과 행이 없으면 외래키 문제가 없다는 뜻입니다.
-- 문제가 있으면 어떤 테이블/행에서 참조 오류가 났는지 표시됩니다.
.print ''
.print '3) Foreign key integrity check: no rows means OK.'
PRAGMA foreign_key_check;

-- ============================================================================
-- 5. 테이블 구조 확인
-- ============================================================================
-- .schema는 CREATE TABLE 문을 다시 보여주는 SQLite CLI 명령입니다.
-- 컬럼, 기본키, 외래키, CHECK 제약조건이 의도대로 들어갔는지 확인합니다.
.print ''
.print '4) Schema overview'
.schema member
.schema category
.schema book
.schema rental
