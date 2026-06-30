-- ============================================================================
-- B5-1 SQL Mission: foreign key error demo
--
-- Purpose:
-- - FK가 실제로 동작해서 없는 부모 값을 참조하는 INSERT를 막는지 확인합니다.
-- - 이 파일은 의도적으로 실패하는 데모이며, run_all.sh에서는 이 실패를 정상 결과로 검증합니다.
-- ============================================================================

PRAGMA foreign_keys = ON;

.print 'FK Error Demo. 존재하지 않는 member_id=999를 참조하는 대여 기록 입력을 시도한다.'
.print 'Expected result: member_id=999는 member 테이블에 없으므로 FOREIGN KEY constraint failed가 발생해야 정상이다.'

INSERT INTO rental (rental_id, member_id, book_id, rented_at, due_date, status, rental_fee)
VALUES (999, 999, 1, '2024-08-01', '2024-08-15', 'RENTED', 0);
