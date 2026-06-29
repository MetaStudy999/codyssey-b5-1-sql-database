# SELECT / WHERE / ORDER BY / LIMIT 기본 조회 훈련

이 문서는 B5-1 도서 대여 관리 DB를 기준으로 `SELECT`, `WHERE`, `ORDER BY`, `LIMIT` 기본 조회 문법을 반복 훈련하기 위한 문서이다.

기본 조회는 SQL의 출발점이다. 평가에서는 단순히 쿼리를 실행하는 것보다 **어떤 데이터를, 어떤 조건으로, 어떤 순서로, 몇 개까지 가져오는지**를 말로 설명할 수 있어야 한다.

---

## 1. 학습 목표

이 문서를 훈련한 뒤 아래를 설명할 수 있어야 한다.

```text
[ ] SELECT가 무엇을 선택하는지 설명할 수 있다.
[ ] FROM이 어느 테이블에서 가져오는지 설명할 수 있다.
[ ] WHERE가 어떤 행을 걸러내는지 설명할 수 있다.
[ ] ORDER BY가 결과 순서를 어떻게 정하는지 설명할 수 있다.
[ ] LIMIT이 결과 개수를 어떻게 제한하는지 설명할 수 있다.
[ ] LIKE로 문자열 검색을 할 수 있다.
[ ] IN으로 여러 조건 중 하나를 검색할 수 있다.
[ ] 날짜 문자열을 조건과 정렬에 사용할 수 있다.
```

---

## 2. 기본 문법 구조

```sql
SELECT 컬럼1, 컬럼2, ...
FROM 테이블명
WHERE 조건
ORDER BY 정렬컬럼 ASC 또는 DESC
LIMIT 개수;
```

실행 순서를 이해하면 SQL이 쉬워진다.

```text
1. FROM      → 어느 테이블에서 가져올지 정한다.
2. WHERE     → 조건에 맞는 행만 남긴다.
3. SELECT    → 보여줄 컬럼을 고른다.
4. ORDER BY  → 결과를 정렬한다.
5. LIMIT     → 결과 개수를 제한한다.
```

평가 때 설명:

> SQL 문장은 위에서부터 읽지만, 개념적으로는 `FROM`에서 테이블을 정하고, `WHERE`로 행을 걸러낸 뒤, `SELECT`로 컬럼을 선택하고, `ORDER BY`와 `LIMIT`으로 결과 형태를 정리합니다.

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

---

## 4. SELECT - 필요한 컬럼만 조회하기

### 4.1 전체 컬럼 조회

```sql
SELECT *
FROM member;
```

설명:

> `member` 테이블의 모든 컬럼과 모든 행을 조회한다. `*`는 모든 컬럼을 의미한다.

주의:

- 연습할 때는 `SELECT *`가 편하다.
- 제출용 또는 실무에서는 필요한 컬럼만 명시하는 것이 좋다.

---

### 4.2 필요한 컬럼만 조회

```sql
SELECT member_id, name, email, status
FROM member;
```

설명:

> 회원 테이블에서 회원 ID, 이름, 이메일, 상태 컬럼만 선택해서 보여준다.

평가 답변:

> `SELECT`에는 결과로 보고 싶은 컬럼을 적습니다. 모든 컬럼이 필요하지 않다면 필요한 컬럼만 명시하는 것이 결과를 읽기 쉽고 안전합니다.

---

## 5. WHERE - 조건으로 행 걸러내기

### 5.1 ACTIVE 회원만 조회

```sql
SELECT member_id, name, email, joined_at, status
FROM member
WHERE status = 'ACTIVE';
```

설명:

> `status`가 `ACTIVE`인 회원만 조회한다.

확인 포인트:

```text
[ ] SUSPENDED 회원이 제외되는가?
[ ] WITHDRAWN 회원이 있다면 제외되는가?
```

---

### 5.2 특정 날짜 이후 가입자 조회

```sql
SELECT member_id, name, joined_at, status
FROM member
WHERE joined_at >= '2024-03-01'
ORDER BY joined_at ASC;
```

설명:

> `joined_at`이 2024-03-01 이상인 회원을 가입일 오름차순으로 조회한다.

SQLite 날짜 팁:

- 이 프로젝트에서는 날짜를 `TEXT`로 저장한다.
- 형식이 `YYYY-MM-DD`이면 문자열 정렬과 날짜 정렬 순서가 일치한다.

---

### 5.3 가격 조건 조회

```sql
SELECT book_id, title, author, price
FROM book
WHERE price >= 30000
ORDER BY price DESC;
```

설명:

> 가격이 30,000원 이상인 도서를 가격이 높은 순서로 조회한다.

평가 답변:

> 숫자 조건은 `>=`, `<=`, `>`, `<`, `=` 같은 비교 연산자로 걸 수 있습니다.

---

## 6. ORDER BY - 결과 정렬하기

### 6.1 오름차순 정렬

```sql
SELECT book_id, title, price
FROM book
ORDER BY price ASC;
```

설명:

> 가격이 낮은 도서부터 높은 도서 순서로 조회한다.

---

### 6.2 내림차순 정렬

```sql
SELECT book_id, title, price
FROM book
ORDER BY price DESC;
```

설명:

> 가격이 높은 도서부터 낮은 도서 순서로 조회한다.

---

### 6.3 여러 기준으로 정렬

```sql
SELECT rental_id, member_id, book_id, due_date, status
FROM rental
ORDER BY due_date ASC, rental_id ASC;
```

설명:

> 먼저 반납기한이 빠른 순서로 정렬하고, 같은 반납기한이 있으면 대여 ID 순서로 정렬한다.

평가 답변:

> `ORDER BY`는 하나 이상의 컬럼을 기준으로 정렬할 수 있습니다. 앞에 쓴 컬럼이 1차 정렬 기준이고, 뒤에 쓴 컬럼은 동률일 때의 보조 기준입니다.

---

## 7. LIMIT - 결과 개수 제한하기

### 7.1 가격 높은 도서 TOP 5

```sql
SELECT book_id, title, author, price
FROM book
ORDER BY price DESC
LIMIT 5;
```

설명:

> 전체 도서를 가격 높은 순으로 정렬한 뒤 상위 5개만 보여준다.

평가 답변:

> `LIMIT`은 결과 행 수를 제한합니다. 예를 들어 TOP 5, 최근 10건 같은 요구를 처리할 때 사용합니다.

---

### 7.2 최근 대여 기록 10건

```sql
SELECT rental_id, member_id, book_id, rented_at, status
FROM rental
ORDER BY rented_at DESC
LIMIT 10;
```

설명:

> 대여일이 최근인 기록 10건만 조회한다.

---

## 8. LIKE - 문자열 검색하기

### 8.1 제목에 SQL이 들어간 도서 검색

```sql
SELECT book_id, title, author, price
FROM book
WHERE title LIKE '%SQL%'
ORDER BY title ASC;
```

설명:

> 도서 제목에 `SQL`이라는 문자열이 포함된 도서를 조회한다.

LIKE 패턴:

| 패턴 | 의미 |
|---|---|
| `'SQL%'` | SQL로 시작하는 값 |
| `'%SQL'` | SQL로 끝나는 값 |
| `'%SQL%'` | SQL이 포함된 값 |

평가 답변:

> `LIKE`는 문자열 일부를 검색할 때 사용합니다. `%`는 앞뒤에 어떤 문자열이 와도 된다는 의미입니다.

---

## 9. IN - 여러 값 중 하나 찾기

### 9.1 대여 중 또는 연체 상태 조회

```sql
SELECT rental_id, member_id, book_id, rented_at, due_date, status
FROM rental
WHERE status IN ('RENTED', 'OVERDUE')
ORDER BY due_date ASC;
```

설명:

> 상태가 `RENTED` 또는 `OVERDUE`인 대여 기록을 반납기한이 빠른 순으로 조회한다.

평가 답변:

> `IN`은 여러 값 중 하나에 해당하는 행을 찾을 때 사용합니다. `status = 'RENTED' OR status = 'OVERDUE'`와 비슷한 의미입니다.

---

## 10. BETWEEN - 범위 조건 조회

### 10.1 특정 기간의 대여 기록 조회

```sql
SELECT rental_id, member_id, book_id, rented_at, due_date, status
FROM rental
WHERE rented_at BETWEEN '2024-06-01' AND '2024-06-30'
ORDER BY rented_at ASC;
```

설명:

> 2024년 6월 1일부터 2024년 6월 30일까지의 대여 기록을 조회한다.

주의:

- `BETWEEN A AND B`는 A와 B를 포함한다.
- 날짜가 `YYYY-MM-DD` 형식이면 문자열 비교로도 순서가 유지된다.

---

## 11. NULL 조건 조회

### 11.1 아직 반납하지 않은 대여 기록

```sql
SELECT rental_id, member_id, book_id, rented_at, due_date, returned_at, status
FROM rental
WHERE returned_at IS NULL
ORDER BY due_date ASC;
```

설명:

> `returned_at`이 비어 있는, 즉 아직 반납일이 기록되지 않은 대여 기록을 조회한다.

주의:

```sql
-- 잘못된 예
WHERE returned_at = NULL;
```

`NULL`은 `=`로 비교하지 않고 `IS NULL` 또는 `IS NOT NULL`을 사용한다.

---

### 11.2 반납 완료된 대여 기록

```sql
SELECT rental_id, member_id, book_id, rented_at, returned_at, status
FROM rental
WHERE returned_at IS NOT NULL
ORDER BY returned_at ASC;
```

설명:

> 반납일이 존재하는 대여 기록을 조회한다.

---

## 12. 평가용 핵심 쿼리 4개

B5-1 필수 조건 중 기본 조회는 4개 이상이다. 이 프로젝트에서는 아래 4개가 핵심이다.

### Q01. ACTIVE 회원 중 특정 날짜 이후 가입자

```sql
SELECT member_id, name, email, joined_at, status
FROM member
WHERE status = 'ACTIVE'
  AND joined_at >= '2024-03-01'
ORDER BY joined_at ASC;
```

확인 내용:

> `WHERE`에 회원 상태와 가입일 조건을 함께 사용했다.

---

### Q02. 30,000원 이상 도서 가격순 TOP 5

```sql
SELECT book_id, title, author, price
FROM book
WHERE price >= 30000
ORDER BY price DESC
LIMIT 5;
```

확인 내용:

> `WHERE`, `ORDER BY`, `LIMIT`을 모두 사용했다.

---

### Q03. 제목에 SQL이 들어간 도서 검색

```sql
SELECT book_id, title, author, price
FROM book
WHERE title LIKE '%SQL%'
ORDER BY title ASC;
```

확인 내용:

> `LIKE`로 문자열 포함 검색을 했다.

---

### Q04. 대여 중 또는 연체 상태의 대여 기록

```sql
SELECT rental_id, member_id, book_id, rented_at, due_date, status
FROM rental
WHERE status IN ('RENTED', 'OVERDUE')
ORDER BY due_date ASC;
```

확인 내용:

> `IN`으로 여러 상태 조건을 처리했고, 반납기한 순으로 정렬했다.

---

## 13. 직접 연습 문제

아래 문제를 SQLite에서 직접 작성한다.

```text
[ ] 1. 전체 회원을 회원 ID 순으로 조회한다.
[ ] 2. ACTIVE 회원만 이름순으로 조회한다.
[ ] 3. 2024-04-01 이후 가입한 회원을 조회한다.
[ ] 4. 가격이 25,000원 이하인 도서를 조회한다.
[ ] 5. 가격이 가장 높은 도서 3권을 조회한다.
[ ] 6. 제목에 '기초'가 들어간 도서를 조회한다.
[ ] 7. 상태가 OVERDUE인 대여 기록만 조회한다.
[ ] 8. 아직 반납하지 않은 대여 기록을 조회한다.
[ ] 9. 2024년 7월 대여 기록을 조회한다.
[ ] 10. 수수료가 0보다 큰 대여 기록을 수수료 높은 순으로 조회한다.
```

---

## 14. 정답 예시

### 14.1 전체 회원을 회원 ID 순으로 조회

```sql
SELECT member_id, name, email, status
FROM member
ORDER BY member_id ASC;
```

### 14.2 ACTIVE 회원만 이름순으로 조회

```sql
SELECT member_id, name, email, status
FROM member
WHERE status = 'ACTIVE'
ORDER BY name ASC;
```

### 14.3 2024-04-01 이후 가입한 회원

```sql
SELECT member_id, name, joined_at
FROM member
WHERE joined_at >= '2024-04-01'
ORDER BY joined_at ASC;
```

### 14.4 가격이 25,000원 이하인 도서

```sql
SELECT book_id, title, price
FROM book
WHERE price <= 25000
ORDER BY price ASC;
```

### 14.5 가격이 가장 높은 도서 3권

```sql
SELECT book_id, title, price
FROM book
ORDER BY price DESC
LIMIT 3;
```

### 14.6 제목에 '기초'가 들어간 도서

```sql
SELECT book_id, title, author
FROM book
WHERE title LIKE '%기초%'
ORDER BY title ASC;
```

### 14.7 상태가 OVERDUE인 대여 기록

```sql
SELECT rental_id, member_id, book_id, due_date, status
FROM rental
WHERE status = 'OVERDUE'
ORDER BY due_date ASC;
```

### 14.8 아직 반납하지 않은 대여 기록

```sql
SELECT rental_id, member_id, book_id, due_date, returned_at, status
FROM rental
WHERE returned_at IS NULL
ORDER BY due_date ASC;
```

### 14.9 2024년 7월 대여 기록

```sql
SELECT rental_id, member_id, book_id, rented_at, status
FROM rental
WHERE rented_at BETWEEN '2024-07-01' AND '2024-07-31'
ORDER BY rented_at ASC;
```

### 14.10 수수료가 0보다 큰 대여 기록

```sql
SELECT rental_id, member_id, book_id, rental_fee, status
FROM rental
WHERE rental_fee > 0
ORDER BY rental_fee DESC;
```

---

## 15. 자주 하는 실수

### 15.1 문자열에 따옴표를 빼먹는 경우

```sql
-- 잘못된 예
SELECT * FROM member WHERE status = ACTIVE;
```

```sql
-- 올바른 예
SELECT * FROM member WHERE status = 'ACTIVE';
```

문자열은 작은따옴표로 감싼다.

---

### 15.2 ORDER BY 방향을 헷갈리는 경우

```text
ASC  = 오름차순 = 작은 값 → 큰 값
DESC = 내림차순 = 큰 값 → 작은 값
```

---

### 15.3 NULL을 `=`로 비교하는 경우

```sql
-- 잘못된 예
WHERE returned_at = NULL;
```

```sql
-- 올바른 예
WHERE returned_at IS NULL;
```

---

### 15.4 세미콜론을 빠뜨리는 경우

```sql
SELECT * FROM member
```

SQLite CLI에서는 세미콜론이 나올 때까지 입력이 계속 이어질 수 있다.

```sql
SELECT * FROM member;
```

---

## 16. 평가 답변 스크립트

### 질문 1. WHERE는 무엇인가요?

> `WHERE`는 테이블의 모든 행 중 조건에 맞는 행만 남기는 절입니다. 예를 들어 `status = 'ACTIVE'`를 쓰면 ACTIVE 상태인 회원만 조회됩니다.

### 질문 2. ORDER BY는 왜 쓰나요?

> `ORDER BY`는 결과의 순서를 정하기 위해 사용합니다. 예를 들어 도서 가격을 높은 순으로 보고 싶으면 `ORDER BY price DESC`를 사용합니다.

### 질문 3. LIMIT은 언제 쓰나요?

> `LIMIT`은 결과 개수를 제한할 때 사용합니다. 가격이 높은 도서 TOP 5나 최근 대여 기록 10건처럼 일부 결과만 보고 싶을 때 사용합니다.

### 질문 4. LIKE는 언제 쓰나요?

> `LIKE`는 문자열 일부를 검색할 때 사용합니다. `%SQL%`처럼 쓰면 제목 안에 SQL이 포함된 도서를 찾을 수 있습니다.

### 질문 5. 기본 조회 쿼리 중 가장 설명하기 좋은 것은 무엇인가요?

> Q02가 가장 좋습니다. `WHERE price >= 30000`으로 조건을 걸고, `ORDER BY price DESC`로 가격이 높은 순서로 정렬한 뒤, `LIMIT 5`로 상위 5개만 보여주기 때문입니다. 기본 조회의 핵심 요소가 모두 들어 있습니다.

---

## 17. 오늘의 완료 기준

```text
[ ] 기본 조회 쿼리 4개를 직접 작성했다.
[ ] WHERE 조건을 3가지 이상 사용했다.
[ ] ORDER BY ASC와 DESC를 모두 사용했다.
[ ] LIMIT을 사용한 TOP N 조회를 작성했다.
[ ] LIKE 검색을 작성했다.
[ ] IN 조건을 작성했다.
[ ] NULL 조건을 IS NULL로 작성했다.
[ ] Q01~Q04를 말로 설명할 수 있다.
```
