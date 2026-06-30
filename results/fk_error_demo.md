# Foreign Key Error Demo 해설

한 줄 요약: 존재하지 않는 회원을 참조하는 대여 기록 입력이 외래키 규칙에 의해 정상적으로 차단되는지 확인한 실패 성공 테스트입니다.

## 실습 따라하기

1. 전체 실행 스크립트로 결과 파일을 생성합니다.

```bash
bash scripts/run_all.sh
```

2. FK 오류 데모만 직접 실행하려면 아래 명령을 사용합니다.

```bash
sqlite3 -bail book_rental.db ".read docs/fk_error_demo.sql"
```

3. 이 명령은 실패해야 정상입니다. `FOREIGN KEY constraint failed`가 보이면 데이터베이스가 잘못된 참조를 막아 준 것입니다.

## 핵심 키워드

- `FOREIGN KEY`: 다른 테이블의 값을 참조하도록 강제하는 규칙
- `parent table`: 참조되는 원본 테이블, 여기서는 `member`
- `child table`: 참조 값을 들고 있는 테이블, 여기서는 `rental`
- `PRAGMA foreign_keys = ON`: SQLite에서 외래키 검사를 켜는 명령
- `constraint failed`: 제약조건을 위반해서 SQL 실행이 거부되었다는 오류
- `exit code 1`: 명령이 실패로 종료되었다는 의미
- `-bail`: SQLite 실행 중 오류가 발생하면 즉시 중단하는 옵션

## 원본 결과

```text
Command:
sqlite3 -bail book_rental.db ".read docs/fk_error_demo.sql"

Expected:
This command should fail because rental.member_id = 999 does not exist in member.member_id.

Output:
FK Error Demo. 존재하지 않는 member_id=999를 참조하는 대여 기록 입력을 시도한다.
Expected result: member_id=999는 member 테이블에 없으므로 FOREIGN KEY constraint failed가 발생해야 정상이다.
Runtime error near line 14: FOREIGN KEY constraint failed (19)

Exit code:
1
```

## 쉬운 설명

이 데모는 일부러 잘못된 데이터를 넣어 보는 테스트입니다. `rental` 테이블은 대여 기록을 저장하는 테이블이고, 그 안의 `member_id`는 반드시 `member` 테이블에 실제로 존재하는 회원 번호여야 합니다.

그런데 데모 SQL은 `member_id = 999`인 대여 기록을 넣으려고 합니다. 현재 `member` 테이블에는 999번 회원이 없습니다. 그래서 SQLite가 `FOREIGN KEY constraint failed` 오류를 내며 입력을 막습니다.

이 결과는 실패처럼 보이지만 과제 관점에서는 성공입니다. 데이터베이스가 잘못된 대여 기록을 허용하지 않았기 때문입니다.

## 평가 포인트

평가자는 이 파일을 통해 외래키 제약조건이 실제로 동작하는지 확인할 수 있습니다. 단순히 `CREATE TABLE`에 `FOREIGN KEY`를 적은 것만으로 끝나는 것이 아니라, 실행 환경에서 `PRAGMA foreign_keys = ON`이 적용되어 오류가 발생하는지도 검증합니다.

## 단계별 흐름

1. `docs/fk_error_demo.sql`에서 외래키 검사를 켭니다.

```sql
PRAGMA foreign_keys = ON;
```

2. 존재하지 않는 회원 번호를 가진 대여 기록을 입력하려고 합니다.

```sql
INSERT INTO rental (rental_id, member_id, book_id, rented_at, due_date, status, rental_fee)
VALUES (999, 999, 1, '2024-08-01', '2024-08-15', 'RENTED', 0);
```

3. `rental.member_id = 999`가 `member.member_id`에 없으므로 SQLite가 입력을 거부합니다.

## 직접 확인해 보기

아래 쿼리로 999번 회원이 없는지 확인할 수 있습니다.

```sql
SELECT *
FROM member
WHERE member_id = 999;
```

결과가 비어 있다면 999번 회원이 없다는 뜻입니다. 이 상태에서 `rental`에 999번 회원의 대여 기록을 넣으려 하면 외래키 오류가 나는 것이 정상입니다.
