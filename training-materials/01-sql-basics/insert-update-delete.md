# INSERT / UPDATE / DELETE 데이터 변경 훈련

이 문서는 B5-1 도서 대여 관리 DB를 기준으로 `INSERT`, `UPDATE`, `DELETE`를 안전하게 사용하는 방법을 훈련하기 위한 문서이다.

조회 SQL은 데이터를 읽기만 하지만, `INSERT`, `UPDATE`, `DELETE`는 데이터를 직접 바꾼다. 따라서 평가에서는 문법뿐 아니라 **어떤 순서로 실행해야 안전한지**, **FK/UNIQUE/CHECK 제약조건이 왜 필요한지**, **WHERE 없이 UPDATE/DELETE를 실행하면 왜 위험한지**를 설명할 수 있어야 한다.

---

## 1. 학습 목표

이 문서를 훈련한 뒤 아래를 설명할 수 있어야 한다.

```text
[ ] INSERT가 새 행을 추가하는 명령임을 설명할 수 있다.
[ ] 부모 테이블을 먼저 INSERT해야 하는 이유를 설명할 수 있다.
[ ] FK 오류가 왜 발생하는지 설명할 수 있다.
[ ] UNIQUE 오류가 왜 발생하는지 설명할 수 있다.
[ ] CHECK 오류가 왜 발생하는지 설명할 수 있다.
[ ] UPDATE 전에 SELECT로 대상 행을 확인해야 하는 이유를 설명할 수 있다.
[ ] DELETE 전에 SELECT로 대상 행을 확인해야 하는 이유를 설명할 수 있다.
[ ] WHERE 없는 UPDATE/DELETE가 왜 위험한지 설명할 수 있다.
[ ] 평가용 변경 쿼리를 임시 DB에서 실행하는 이유를 설명할 수 있다.
```

---

## 2. 데이터 변경 SQL 3종

| 명령 | 역할 | B5-1 예시 |
|---|---|---|
| `INSERT` | 새 행 추가 | 회원, 도서, 대여 기록 추가 |
| `UPDATE` | 기존 행 수정 | 대여 상태를 `OVERDUE`로 변경 |
| `DELETE` | 기존 행 삭제 | 테스트용 대여 기록 삭제 |

평가 답변:

> `SELECT`는 데이터를 조회하지만, `INSERT`, `UPDATE`, `DELETE`는 데이터를 실제로 변경합니다. 그래서 변경 전에 대상 행을 확인하고, FK/UNIQUE/CHECK 같은 제약조건을 통해 잘못된 데이터가 들어가지 않도록 관리해야 합니다.

---

## 3. 실습 전 준비

프로젝트 루트에서 DB를 새로 생성한다.

```bash
chmod +x scripts/run_all.sh
./scripts/run_all.sh
```

SQLite 접속:

```bash
sqlite3 book_rental.db
```

SQLite 안에서 보기 좋게 설정:

```sql
.headers on
.mode column
PRAGMA foreign_keys = ON;
```

주의:

```text
실습 중 UPDATE/DELETE를 직접 실행하면 book_rental.db 내용이 바뀐다.
평가용 원본을 유지하려면 run_all.sh로 다시 생성하거나, 복사본 DB에서 연습한다.
```

연습용 DB 복사:

```bash
cp book_rental.db practice.db
sqlite3 practice.db
```

---

## 4. INSERT - 새 데이터 추가

### 4.1 기본 문법

```sql
INSERT INTO 테이블명 (컬럼1, 컬럼2, 컬럼3)
VALUES (값1, 값2, 값3);
```

설명:

> `INSERT`는 테이블에 새 행을 추가한다. 컬럼 목록과 값 목록의 개수와 순서가 맞아야 한다.

---

### 4.2 회원 추가 예시

```sql
INSERT INTO member (member_id, name, email, phone, joined_at, status)
VALUES (11, '테스트회원', 'test.member@example.com', '010-9999-0001', '2024-08-01', 'ACTIVE');
```

추가 확인:

```sql
SELECT member_id, name, email, joined_at, status
FROM member
WHERE member_id = 11;
```

설명:

> `member_id=11`인 새 회원을 추가한 뒤, `SELECT`로 실제 입력 여부를 확인한다.

---

### 4.3 카테고리 추가 예시

```sql
INSERT INTO category (category_id, name, description)
VALUES (11, 'Data Engineering', 'Data pipeline and engineering');
```

확인:

```sql
SELECT category_id, name, description
FROM category
WHERE category_id = 11;
```

---

### 4.4 도서 추가 예시

도서는 `category_id`를 FK로 가진다. 따라서 참조할 카테고리가 먼저 있어야 한다.

```sql
INSERT INTO book (book_id, category_id, title, author, published_year, isbn, price, stock, created_at)
VALUES (16, 11, '데이터 파이프라인 입문', '테스트저자', 2024, '978-89-001-0016', 33000, 2, '2024-08-01');
```

확인:

```sql
SELECT book_id, category_id, title, isbn, price, stock
FROM book
WHERE book_id = 16;
```

평가 답변:

> `book.category_id`는 `category.category_id`를 참조합니다. 따라서 도서를 추가하기 전에 해당 카테고리가 먼저 존재해야 합니다.

---

### 4.5 대여 기록 추가 예시

대여 기록은 `member_id`, `book_id`를 FK로 가진다. 따라서 회원과 도서가 먼저 있어야 한다.

```sql
INSERT INTO rental (rental_id, member_id, book_id, rented_at, due_date, returned_at, status, rental_fee)
VALUES (21, 11, 16, '2024-08-02', '2024-08-16', NULL, 'RENTED', 0);
```

확인:

```sql
SELECT rental_id, member_id, book_id, rented_at, due_date, status
FROM rental
WHERE rental_id = 21;
```

평가 답변:

> `rental`은 회원과 도서를 연결하는 대여 이력 테이블입니다. 그래서 `rental.member_id`와 `rental.book_id`는 각각 실제 회원과 실제 도서를 참조해야 합니다.

---

## 5. INSERT 순서가 중요한 이유

### 5.1 올바른 입력 순서

이 프로젝트의 샘플 데이터는 아래 순서로 입력된다.

```text
1. member
2. category
3. book
4. rental
```

더 정확히는 FK 기준으로 보면 아래 순서가 중요하다.

```text
category → book
member + book → rental
```

설명:

> 자식 테이블이 부모 테이블의 PK를 참조하기 때문에 부모 데이터가 먼저 존재해야 한다.

---

### 5.2 잘못된 입력 예시 - 없는 카테고리 참조

```sql
INSERT INTO book (book_id, category_id, title, author, published_year, isbn, price, stock, created_at)
VALUES (999, 999, '잘못된 책', '오류저자', 2024, '978-89-999-9999', 10000, 1, '2024-08-01');
```

예상 오류:

```text
FOREIGN KEY constraint failed
```

원인:

> `category_id=999`가 `category` 테이블에 없기 때문에 FK 제약조건이 입력을 막는다.

---

### 5.3 잘못된 입력 예시 - 없는 회원 참조

```sql
INSERT INTO rental (rental_id, member_id, book_id, rented_at, due_date, status, rental_fee)
VALUES (999, 999, 1, '2024-08-01', '2024-08-15', 'RENTED', 0);
```

예상 오류:

```text
FOREIGN KEY constraint failed
```

원인:

> `member_id=999`가 `member` 테이블에 없으므로 대여 기록을 만들 수 없다.

평가 답변:

> FK는 존재하지 않는 부모 데이터를 참조하지 못하게 막습니다. 그래서 잘못된 회원 ID나 도서 ID로 대여 기록을 넣으면 `FOREIGN KEY constraint failed`가 발생합니다.

---

## 6. UNIQUE 제약조건 확인

### 6.1 중복 이메일 입력

```sql
INSERT INTO member (member_id, name, email, phone, joined_at, status)
VALUES (12, '중복회원', 'minjun.kim@example.com', '010-9999-0002', '2024-08-01', 'ACTIVE');
```

예상 오류:

```text
UNIQUE constraint failed: member.email
```

원인:

> `member.email`은 UNIQUE 제약조건이 있으므로 같은 이메일을 가진 회원을 두 명 만들 수 없다.

---

### 6.2 중복 ISBN 입력

```sql
INSERT INTO book (book_id, category_id, title, author, published_year, isbn, price, stock, created_at)
VALUES (17, 1, '중복 ISBN 책', '테스트저자', 2024, '978-89-001-0001', 20000, 1, '2024-08-01');
```

예상 오류:

```text
UNIQUE constraint failed: book.isbn
```

평가 답변:

> UNIQUE는 중복되면 안 되는 값을 막기 위해 사용합니다. 이메일이나 ISBN처럼 현실에서도 유일해야 하는 값에 적합합니다.

---

## 7. CHECK 제약조건 확인

### 7.1 잘못된 회원 상태

```sql
INSERT INTO member (member_id, name, email, phone, joined_at, status)
VALUES (13, '상태오류회원', 'bad.status@example.com', '010-9999-0003', '2024-08-01', 'WAITING');
```

예상 오류:

```text
CHECK constraint failed
```

원인:

> `member.status`는 `ACTIVE`, `SUSPENDED`, `WITHDRAWN` 중 하나만 허용한다.

---

### 7.2 음수 가격 입력

```sql
INSERT INTO book (book_id, category_id, title, author, published_year, isbn, price, stock, created_at)
VALUES (18, 1, '음수 가격 책', '테스트저자', 2024, '978-89-001-0018', -1000, 1, '2024-08-01');
```

예상 오류:

```text
CHECK constraint failed
```

원인:

> `book.price`는 `price >= 0` 조건을 만족해야 한다.

평가 답변:

> CHECK는 컬럼에 들어올 수 있는 값의 범위나 목록을 제한합니다. 가격이 음수이거나 상태값이 허용 목록 밖이면 DB가 저장을 거부합니다.

---

## 8. UPDATE - 기존 데이터 수정

### 8.1 기본 문법

```sql
UPDATE 테이블명
SET 컬럼1 = 값1,
    컬럼2 = 값2
WHERE 조건;
```

핵심:

```text
UPDATE에는 WHERE가 매우 중요하다.
WHERE가 없으면 테이블 전체 행이 수정될 수 있다.
```

---

### 8.2 대여 상태를 OVERDUE로 변경

수정 전 확인:

```sql
SELECT rental_id, member_id, book_id, due_date, status, rental_fee
FROM rental
WHERE rental_id = 4;
```

수정:

```sql
UPDATE rental
SET status = 'OVERDUE', rental_fee = 2000
WHERE rental_id = 4;
```

수정 후 확인:

```sql
SELECT rental_id, member_id, book_id, due_date, status, rental_fee
FROM rental
WHERE rental_id = 4;
```

설명:

> `rental_id=4`인 대여 기록만 골라 상태를 `OVERDUE`로 바꾸고, 연체 수수료를 2000으로 설정한다.

---

### 8.3 회원 상태 변경

수정 전 확인:

```sql
SELECT member_id, name, status
FROM member
WHERE member_id = 5;
```

수정:

```sql
UPDATE member
SET status = 'ACTIVE'
WHERE member_id = 5;
```

수정 후 확인:

```sql
SELECT member_id, name, status
FROM member
WHERE member_id = 5;
```

---

### 8.4 도서 재고 변경

수정 전 확인:

```sql
SELECT book_id, title, stock
FROM book
WHERE book_id = 8;
```

수정:

```sql
UPDATE book
SET stock = stock + 1
WHERE book_id = 8;
```

수정 후 확인:

```sql
SELECT book_id, title, stock
FROM book
WHERE book_id = 8;
```

설명:

> 기존 재고 값에 1을 더해 도서 재고를 증가시킨다.

---

## 9. UPDATE 실수 방지

### 9.1 위험한 UPDATE

```sql
-- 절대 실습 DB 원본에서 실행하지 말 것
UPDATE rental
SET status = 'OVERDUE';
```

문제:

> `WHERE`가 없으므로 `rental` 테이블의 모든 행이 `OVERDUE`로 바뀐다.

---

### 9.2 안전한 UPDATE 순서

```text
1. SELECT로 대상 확인
2. UPDATE에 같은 WHERE 조건 사용
3. SELECT로 수정 결과 확인
```

예시:

```sql
SELECT *
FROM rental
WHERE rental_id = 4;

UPDATE rental
SET status = 'OVERDUE', rental_fee = 2000
WHERE rental_id = 4;

SELECT *
FROM rental
WHERE rental_id = 4;
```

평가 답변:

> UPDATE는 데이터를 변경하므로 먼저 SELECT로 대상 행을 확인해야 합니다. 그리고 UPDATE에도 같은 WHERE 조건을 넣어 의도한 행만 바뀌게 해야 합니다.

---

## 10. DELETE - 기존 데이터 삭제

### 10.1 기본 문법

```sql
DELETE FROM 테이블명
WHERE 조건;
```

핵심:

```text
DELETE도 WHERE가 매우 중요하다.
WHERE가 없으면 테이블 전체 행이 삭제될 수 있다.
```

---

### 10.2 테스트 대여 기록 삭제

삭제 전 확인:

```sql
SELECT rental_id, member_id, book_id, rented_at, status
FROM rental
WHERE rental_id = 20;
```

삭제:

```sql
DELETE FROM rental
WHERE rental_id = 20;
```

삭제 후 확인:

```sql
SELECT rental_id, member_id, book_id, rented_at, status
FROM rental
WHERE rental_id = 20;
```

전체 개수 확인:

```sql
SELECT COUNT(*) AS remaining_rentals
FROM rental;
```

설명:

> `rental_id=20`인 대여 기록만 삭제한다. 삭제 후 같은 ID를 조회하면 결과가 나오지 않고, 전체 대여 기록 수는 1개 줄어든다.

---

## 11. DELETE 실수 방지

### 11.1 위험한 DELETE

```sql
-- 절대 실습 DB 원본에서 실행하지 말 것
DELETE FROM rental;
```

문제:

> `WHERE`가 없으므로 `rental` 테이블의 모든 행이 삭제된다.

---

### 11.2 안전한 DELETE 순서

```text
1. SELECT로 삭제 대상 확인
2. DELETE에 같은 WHERE 조건 사용
3. SELECT 또는 COUNT로 삭제 결과 확인
```

예시:

```sql
SELECT *
FROM rental
WHERE rental_id = 20;

DELETE FROM rental
WHERE rental_id = 20;

SELECT COUNT(*) AS remaining_rentals
FROM rental;
```

평가 답변:

> DELETE는 데이터를 제거하므로 UPDATE보다 더 위험할 수 있습니다. 삭제 전 SELECT로 대상 행을 확인하고, WHERE 조건을 명확히 넣어야 합니다.

---

## 12. FK 때문에 삭제가 막히는 경우

### 12.1 대여 기록이 있는 회원 삭제 시도

```sql
DELETE FROM member
WHERE member_id = 1;
```

예상 오류:

```text
FOREIGN KEY constraint failed
```

원인:

> `rental` 테이블에서 `member_id=1`을 참조하는 대여 기록이 있으므로, 부모 회원을 바로 삭제할 수 없다.

---

### 12.2 대여 기록이 있는 도서 삭제 시도

```sql
DELETE FROM book
WHERE book_id = 1;
```

예상 오류:

```text
FOREIGN KEY constraint failed
```

원인:

> `rental` 테이블에서 `book_id=1`을 참조하고 있으므로, 참조 중인 도서를 바로 삭제할 수 없다.

평가 답변:

> 이 프로젝트는 `ON DELETE RESTRICT`를 사용합니다. 그래서 자식 테이블에서 참조 중인 부모 데이터를 삭제하지 못하게 막습니다. 이것은 대여 기록이 고아 데이터가 되는 것을 방지합니다.

---

## 13. 트랜잭션 기초

여러 변경을 하나의 묶음으로 실행하고 싶을 때 트랜잭션을 사용할 수 있다.

```sql
BEGIN TRANSACTION;

UPDATE rental
SET status = 'OVERDUE', rental_fee = 2000
WHERE rental_id = 4;

SELECT rental_id, status, rental_fee
FROM rental
WHERE rental_id = 4;

ROLLBACK;
```

설명:

> `ROLLBACK`을 사용하면 트랜잭션 안에서 실행한 변경을 취소할 수 있다. 연습할 때 안전하게 변경 쿼리를 확인하는 방법이다.

실제 반영하려면:

```sql
COMMIT;
```

주의:

```text
트랜잭션은 중요한 개념이지만 B5-1 필수 요구사항은 아니다.
다만 UPDATE/DELETE 안전성을 설명할 때 도움이 된다.
```

---

## 14. B5-1 평가용 변경 쿼리

현재 제출용 핵심 쿼리에서는 다음 두 개가 데이터 변경 쿼리다.

### Q13. UPDATE

```sql
UPDATE rental
SET status = 'OVERDUE', rental_fee = 2000
WHERE rental_id = 4;

SELECT rental_id, member_id, book_id, due_date, status, rental_fee
FROM rental
WHERE rental_id = 4;
```

설명:

> `rental_id=4`인 특정 대여 기록만 연체 상태로 바꾸고, 결과를 즉시 조회한다.

---

### Q14. DELETE

```sql
DELETE FROM rental
WHERE rental_id = 20;

SELECT COUNT(*) AS remaining_rentals
FROM rental;
```

설명:

> `rental_id=20`인 테스트 대여 기록을 삭제한 뒤 남은 대여 기록 수를 확인한다.

---

## 15. 왜 임시 DB 복사본에서 Q13/Q14를 실행하는가?

`run_all.sh`는 Q13/Q14가 포함된 `sql/03_queries.sql`을 원본 DB가 아니라 임시 DB 복사본에서 실행한다.

이유:

```text
1. validation_results.txt에서는 원본 데이터 20개를 유지해야 한다.
2. query_results.txt에서는 UPDATE/DELETE 실행 결과를 보여줘야 한다.
3. 원본 DB를 훼손하지 않으면서 변경 쿼리 증빙을 남기기 위해 임시 복사본을 사용한다.
```

평가 답변:

> Q13과 Q14는 실제 데이터를 변경하는 쿼리입니다. 그래서 자동 실행 스크립트에서는 원본 DB를 복사한 임시 DB에서 변경 쿼리를 실행합니다. 이렇게 하면 변경 쿼리 결과는 증빙으로 남기면서도 검증용 원본 데이터는 유지할 수 있습니다.

---

## 16. 직접 연습 문제

아래는 반드시 연습용 DB 또는 트랜잭션 안에서 실행한다.

```text
[ ] 1. 테스트 회원 1명을 INSERT한다.
[ ] 2. 테스트 카테고리 1개를 INSERT한다.
[ ] 3. 테스트 도서 1권을 INSERT한다.
[ ] 4. 테스트 대여 기록 1개를 INSERT한다.
[ ] 5. 테스트 대여 기록의 status를 OVERDUE로 UPDATE한다.
[ ] 6. 테스트 도서의 stock을 1 증가시킨다.
[ ] 7. 테스트 대여 기록을 DELETE한다.
[ ] 8. 없는 member_id를 참조하는 rental INSERT를 시도해 FK 오류를 확인한다.
[ ] 9. 중복 email INSERT를 시도해 UNIQUE 오류를 확인한다.
[ ] 10. 음수 price INSERT를 시도해 CHECK 오류를 확인한다.
```

---

## 17. 정답 예시

### 17.1 테스트 회원 추가

```sql
INSERT INTO member (member_id, name, email, phone, joined_at, status)
VALUES (101, '연습회원', 'practice.member@example.com', '010-1111-2222', '2024-08-10', 'ACTIVE');
```

### 17.2 테스트 카테고리 추가

```sql
INSERT INTO category (category_id, name, description)
VALUES (101, 'Practice', 'Practice category');
```

### 17.3 테스트 도서 추가

```sql
INSERT INTO book (book_id, category_id, title, author, published_year, isbn, price, stock, created_at)
VALUES (101, 101, 'SQL 연습 도서', '연습저자', 2024, '978-89-101-0101', 15000, 1, '2024-08-10');
```

### 17.4 테스트 대여 기록 추가

```sql
INSERT INTO rental (rental_id, member_id, book_id, rented_at, due_date, returned_at, status, rental_fee)
VALUES (101, 101, 101, '2024-08-10', '2024-08-24', NULL, 'RENTED', 0);
```

### 17.5 대여 상태 수정

```sql
UPDATE rental
SET status = 'OVERDUE', rental_fee = 3000
WHERE rental_id = 101;
```

### 17.6 도서 재고 증가

```sql
UPDATE book
SET stock = stock + 1
WHERE book_id = 101;
```

### 17.7 대여 기록 삭제

```sql
DELETE FROM rental
WHERE rental_id = 101;
```

---

## 18. 자주 하는 실수

### 18.1 INSERT 컬럼 수와 값 수가 다른 경우

```sql
-- 잘못된 예
INSERT INTO member (member_id, name, email)
VALUES (20, '오류회원');
```

예상 오류:

```text
2 values for 3 columns
```

---

### 18.2 문자열에 따옴표를 빼먹는 경우

```sql
-- 잘못된 예
UPDATE member
SET status = ACTIVE
WHERE member_id = 1;
```

```sql
-- 올바른 예
UPDATE member
SET status = 'ACTIVE'
WHERE member_id = 1;
```

---

### 18.3 WHERE 없는 UPDATE

```sql
-- 위험
UPDATE member
SET status = 'SUSPENDED';
```

문제:

> 모든 회원 상태가 `SUSPENDED`로 바뀐다.

---

### 18.4 WHERE 없는 DELETE

```sql
-- 위험
DELETE FROM rental;
```

문제:

> 모든 대여 기록이 삭제된다.

---

### 18.5 부모보다 자식을 먼저 INSERT

```sql
-- category_id=500이 없으면 실패
INSERT INTO book (book_id, category_id, title, author, published_year, isbn, price, stock, created_at)
VALUES (500, 500, '순서 오류 책', '오류저자', 2024, '978-89-500-0500', 10000, 1, '2024-08-10');
```

문제:

> `book`은 `category`를 참조하므로 카테고리 데이터가 먼저 있어야 한다.

---

## 19. 평가 답변 스크립트

### 질문 1. INSERT할 때 왜 부모 테이블을 먼저 넣어야 하나요?

> FK 때문입니다. `book.category_id`는 `category.category_id`를 참조하고, `rental.member_id`와 `rental.book_id`는 각각 `member`, `book`을 참조합니다. 따라서 자식 테이블에 데이터를 넣기 전에 참조 대상인 부모 데이터가 먼저 존재해야 합니다.

### 질문 2. UPDATE 전에 왜 SELECT를 하나요?

> UPDATE는 데이터를 실제로 바꾸기 때문에 대상 행을 먼저 확인해야 합니다. SELECT로 같은 WHERE 조건을 사용해 어떤 행이 바뀔지 확인한 뒤 UPDATE를 실행하면 실수로 여러 행을 바꾸는 위험을 줄일 수 있습니다.

### 질문 3. DELETE 전에 왜 SELECT를 하나요?

> DELETE는 데이터를 제거하기 때문에 더 조심해야 합니다. 삭제 대상이 맞는지 SELECT로 먼저 확인하고, DELETE에도 같은 WHERE 조건을 넣어야 의도한 행만 삭제됩니다.

### 질문 4. WHERE 없는 UPDATE/DELETE가 왜 위험한가요?

> WHERE가 없으면 조건 없이 테이블 전체에 적용됩니다. UPDATE는 모든 행을 같은 값으로 바꿀 수 있고, DELETE는 모든 행을 삭제할 수 있습니다.

### 질문 5. FK 오류는 왜 좋은 오류인가요?

> FK 오류는 잘못된 참조를 막아주는 안전장치입니다. 존재하지 않는 회원이나 도서로 대여 기록을 만들면 데이터가 깨지는데, FK가 이를 막아 데이터 무결성을 지켜줍니다.

### 질문 6. Q13/Q14는 왜 임시 DB에서 실행하나요?

> Q13과 Q14는 UPDATE/DELETE라서 데이터를 변경합니다. 평가 증빙에는 변경 결과가 필요하지만, 검증용 원본 데이터는 유지해야 합니다. 그래서 자동 실행 스크립트에서 임시 DB 복사본을 만들어 변경 쿼리를 실행합니다.

---

## 20. 오늘의 완료 기준

```text
[ ] INSERT 예제 4개를 직접 실행했다.
[ ] FK 오류를 1번 재현했다.
[ ] UNIQUE 오류를 1번 재현했다.
[ ] CHECK 오류를 1번 재현했다.
[ ] UPDATE 전후 SELECT 확인을 했다.
[ ] DELETE 전후 SELECT 또는 COUNT 확인을 했다.
[ ] WHERE 없는 UPDATE/DELETE의 위험성을 말로 설명할 수 있다.
[ ] Q13/Q14가 왜 임시 DB 복사본에서 실행되는지 설명할 수 있다.
```
