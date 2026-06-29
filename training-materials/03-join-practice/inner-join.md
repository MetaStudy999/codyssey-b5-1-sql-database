# INNER JOIN 훈련 노트

이 문서는 B5-1 도서 대여 관리 DB를 기준으로 `INNER JOIN`을 반복 훈련하기 위한 문서이다.

평가에서는 `INNER JOIN` 문법만 쓰는 것보다, **어떤 테이블을 왜 연결하는지**, **PK/FK 중 어떤 컬럼이 연결 기준인지**, **INNER JOIN 결과에서 빠지는 데이터가 무엇인지**를 설명할 수 있어야 한다.

---

## 1. INNER JOIN 한 줄 요약

```text
INNER JOIN은 두 테이블에서 연결 조건이 서로 맞는 행만 결과로 보여준다.
```

평가 답변:

> `INNER JOIN`은 두 테이블의 연결 조건이 일치하는 행만 가져옵니다. 예를 들어 `rental.member_id = member.member_id`로 JOIN하면 실제 회원과 연결된 대여 기록만 회원명과 함께 조회할 수 있습니다.

---

## 2. 기본 문법

```sql
SELECT 컬럼목록
FROM 기준테이블 별칭
INNER JOIN 연결테이블 별칭
    ON 기준테이블.컬럼 = 연결테이블.컬럼;
```

예시:

```sql
SELECT r.rental_id, m.name, r.rented_at, r.status
FROM rental r
INNER JOIN member m ON r.member_id = m.member_id;
```

읽는 순서:

```text
1. rental 테이블을 기준으로 본다.
2. rental.member_id와 member.member_id가 같은 행을 찾는다.
3. 조건이 맞는 행만 결과로 보여준다.
4. rental_id, 회원명, 대여일, 상태를 출력한다.
```

---

## 3. INNER JOIN이 필요한 이유

`rental` 테이블에는 회원 이름과 도서 제목이 직접 저장되어 있지 않다.

`rental`에 있는 값:

```text
member_id
book_id
rented_at
due_date
status
```

사람이 읽고 싶은 값:

```text
회원명
도서명
카테고리명
```

따라서 아래처럼 JOIN해야 한다.

```text
rental.member_id → member.member_id
rental.book_id   → book.book_id
book.category_id → category.category_id
```

평가 답변:

> 정규화 때문에 `rental`에는 회원명과 도서명을 반복 저장하지 않고 ID만 저장했습니다. 사람이 읽기 쉬운 결과를 만들기 위해 FK를 기준으로 `member`, `book`, `category`를 INNER JOIN합니다.

---

## 4. ERD 기준 INNER JOIN 연결선

이 프로젝트에서 INNER JOIN에 자주 쓰는 연결은 3개다.

| 관계 | JOIN 조건 | 의미 |
|---|---|---|
| `member 1:N rental` | `rental.member_id = member.member_id` | 대여 기록의 회원 찾기 |
| `book 1:N rental` | `rental.book_id = book.book_id` | 대여 기록의 도서 찾기 |
| `category 1:N book` | `book.category_id = category.category_id` | 도서의 카테고리 찾기 |

---

## 5. 예제 1 - 대여 기록 + 회원명

### SQL

```sql
SELECT r.rental_id, m.name AS member_name, r.rented_at, r.due_date, r.status
FROM rental r
INNER JOIN member m ON r.member_id = m.member_id
ORDER BY r.rented_at DESC;
```

### 설명

> `rental.member_id`와 `member.member_id`가 같은 행을 연결해서 대여 기록에 회원명을 붙인다.

### 평가 답변

> `rental`에는 회원 ID만 있고 회원명은 없습니다. 그래서 `rental.member_id`와 `member.member_id`를 INNER JOIN해 회원명을 가져왔습니다.

---

## 6. 예제 2 - 대여 기록 + 도서명

### SQL

```sql
SELECT r.rental_id, b.title AS book_title, r.rented_at, r.due_date, r.status
FROM rental r
INNER JOIN book b ON r.book_id = b.book_id
ORDER BY r.rented_at DESC;
```

### 설명

> `rental.book_id`와 `book.book_id`가 같은 행을 연결해서 대여 기록에 도서명을 붙인다.

### 평가 답변

> `rental`에는 도서 ID만 저장되어 있으므로 사람이 읽기 쉬운 도서명을 보려면 `book` 테이블과 JOIN해야 합니다.

---

## 7. 예제 3 - 도서 + 카테고리명

### SQL

```sql
SELECT b.book_id, b.title, b.author, c.name AS category_name, b.price
FROM book b
INNER JOIN category c ON b.category_id = c.category_id
ORDER BY c.name ASC, b.title ASC;
```

### 설명

> `book.category_id`와 `category.category_id`를 연결해 각 도서가 어떤 카테고리에 속하는지 보여준다.

### 평가 답변

> 카테고리명을 `book`에 문자열로 반복 저장하지 않았기 때문에 `category` 테이블과 JOIN해서 카테고리명을 가져옵니다.

---

## 8. 예제 4 - 대여 기록 + 회원명 + 도서명

### SQL

```sql
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
```

### 설명

> `rental`을 기준으로 `member`와 `book`을 동시에 연결해 대여 기록을 사람이 읽기 쉬운 형태로 만든다.

### 평가 답변

> 이 쿼리는 대여 이력 테이블을 중심으로 회원명과 도서명을 붙인 쿼리입니다. FK인 `member_id`, `book_id`를 각각 부모 테이블의 PK와 연결했습니다.

---

## 9. 예제 5 - 연체 기록 + 회원명 + 도서명 + 카테고리명

### SQL

```sql
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
```

### 설명

> `rental → member`, `rental → book`, `book → category` 순서로 연결한 뒤, 연체 상태만 조회한다.

### 평가 답변

> 여러 테이블 INNER JOIN을 사용하면 대여 기록에 회원명, 도서명, 카테고리명을 함께 붙일 수 있습니다. 이 쿼리는 연체 상태인 기록만 필터링하므로 평가 때 설명하기 좋은 복합 JOIN 예시입니다.

---

## 10. INNER JOIN 결과에서 빠지는 데이터

`INNER JOIN`은 연결 조건이 맞는 행만 보여준다.

예를 들어 아래 쿼리는 대여 기록이 있는 회원만 나온다.

```sql
SELECT m.member_id, m.name, r.rental_id
FROM member m
INNER JOIN rental r ON m.member_id = r.member_id
ORDER BY m.member_id;
```

만약 어떤 회원이 아직 한 번도 책을 빌리지 않았다면, 그 회원은 결과에 나오지 않는다.

평가 답변:

> INNER JOIN은 양쪽에 매칭되는 행만 보여줍니다. 그래서 대여 기록이 없는 회원처럼 오른쪽 테이블에 연결 데이터가 없는 경우에는 결과에서 빠집니다.

---

## 11. INNER JOIN과 WHERE의 차이

| 구분 | 역할 |
|---|---|
| `INNER JOIN ... ON` | 테이블 사이의 연결 조건을 정한다. |
| `WHERE` | 연결된 결과 중 필요한 행만 필터링한다. |

예시:

```sql
SELECT r.rental_id, m.name, b.title, r.status
FROM rental r
INNER JOIN member m ON r.member_id = m.member_id
INNER JOIN book b ON r.book_id = b.book_id
WHERE r.status = 'OVERDUE';
```

설명:

```text
ON    → rental과 member/book을 어떤 키로 연결할지 정한다.
WHERE → 연결된 결과 중 status가 OVERDUE인 행만 남긴다.
```

평가 답변:

> `ON`은 테이블을 연결하는 조건이고, `WHERE`는 연결된 결과를 다시 필터링하는 조건입니다. JOIN 조건과 필터 조건을 구분해서 쓰는 것이 좋습니다.

---

## 12. 별칭(alias)을 쓰는 이유

JOIN에서는 테이블 이름이 길어지기 쉽다.

```sql
FROM rental r
INNER JOIN member m ON r.member_id = m.member_id
```

여기서:

```text
r = rental
m = member
b = book
c = category
```

장점:

```text
쿼리가 짧아진다.
어느 테이블의 컬럼인지 명확해진다.
같은 이름의 컬럼이 있을 때 충돌을 피할 수 있다.
```

예시:

```sql
SELECT r.rental_id, m.name, b.title
FROM rental r
INNER JOIN member m ON r.member_id = m.member_id
INNER JOIN book b ON r.book_id = b.book_id;
```

---

## 13. 컬럼 이름 충돌 주의

여러 테이블에 같은 이름의 컬럼이 있을 수 있다.

예:

```text
member.name
category.name
```

따라서 JOIN할 때는 테이블 별칭을 붙이는 것이 안전하다.

```sql
SELECT m.name AS member_name,
       c.name AS category_name
FROM rental r
INNER JOIN member m ON r.member_id = m.member_id
INNER JOIN book b ON r.book_id = b.book_id
INNER JOIN category c ON b.category_id = c.category_id;
```

평가 답변:

> JOIN에서는 여러 테이블에 같은 컬럼명이 있을 수 있으므로 `m.name`, `c.name`처럼 테이블 별칭을 붙입니다. 출력 컬럼도 `AS member_name`, `AS category_name`처럼 이름을 명확히 바꿉니다.

---

## 14. 직접 연습 문제

아래 쿼리를 직접 작성해본다.

```text
[ ] 1. 대여 기록에 회원명을 붙여 조회한다.
[ ] 2. 대여 기록에 도서명을 붙여 조회한다.
[ ] 3. 도서 목록에 카테고리명을 붙여 조회한다.
[ ] 4. 대여 기록에 회원명과 도서명을 함께 붙여 조회한다.
[ ] 5. 연체 기록에 회원명, 도서명, 카테고리명을 함께 붙여 조회한다.
[ ] 6. RETURNED 상태 대여 기록에 회원명과 도서명을 붙여 조회한다.
[ ] 7. 특정 카테고리의 도서와 카테고리명을 조회한다.
[ ] 8. 가격이 30,000원 이상인 도서의 카테고리명을 함께 조회한다.
[ ] 9. 대여 수수료가 있는 기록에 회원명과 도서명을 붙여 조회한다.
[ ] 10. 최근 대여 기록 5건에 회원명, 도서명, 카테고리명을 붙여 조회한다.
```

---

## 15. 정답 예시

### 15.1 대여 기록에 회원명 붙이기

```sql
SELECT r.rental_id, m.name AS member_name, r.rented_at, r.status
FROM rental r
INNER JOIN member m ON r.member_id = m.member_id
ORDER BY r.rented_at DESC;
```

### 15.2 대여 기록에 도서명 붙이기

```sql
SELECT r.rental_id, b.title AS book_title, r.rented_at, r.status
FROM rental r
INNER JOIN book b ON r.book_id = b.book_id
ORDER BY r.rented_at DESC;
```

### 15.3 도서 목록에 카테고리명 붙이기

```sql
SELECT b.book_id, b.title, c.name AS category_name
FROM book b
INNER JOIN category c ON b.category_id = c.category_id
ORDER BY c.name, b.title;
```

### 15.4 대여 기록에 회원명과 도서명 붙이기

```sql
SELECT r.rental_id, m.name AS member_name, b.title AS book_title, r.rented_at, r.status
FROM rental r
INNER JOIN member m ON r.member_id = m.member_id
INNER JOIN book b ON r.book_id = b.book_id
ORDER BY r.rented_at DESC;
```

### 15.5 연체 기록 상세 조회

```sql
SELECT r.rental_id, m.name AS member_name, b.title AS book_title, c.name AS category_name, r.due_date, r.rental_fee
FROM rental r
INNER JOIN member m ON r.member_id = m.member_id
INNER JOIN book b ON r.book_id = b.book_id
INNER JOIN category c ON b.category_id = c.category_id
WHERE r.status = 'OVERDUE'
ORDER BY r.due_date ASC;
```

### 15.6 최근 대여 기록 5건 상세 조회

```sql
SELECT r.rental_id, m.name AS member_name, b.title AS book_title, c.name AS category_name, r.rented_at, r.status
FROM rental r
INNER JOIN member m ON r.member_id = m.member_id
INNER JOIN book b ON r.book_id = b.book_id
INNER JOIN category c ON b.category_id = c.category_id
ORDER BY r.rented_at DESC
LIMIT 5;
```

---

## 16. 자주 하는 실수

### 16.1 ON 조건을 잘못 쓰는 경우

```sql
-- 잘못된 예
INNER JOIN member m ON r.book_id = m.member_id
```

문제:

> 대여의 도서 ID와 회원 ID를 비교하고 있으므로 관계가 맞지 않는다.

올바른 예:

```sql
INNER JOIN member m ON r.member_id = m.member_id
```

---

### 16.2 FK와 PK 방향을 헷갈리는 경우

JOIN 조건은 보통 아래처럼 쓴다.

```text
자식테이블.FK = 부모테이블.PK
```

예:

```sql
rental.member_id = member.member_id
rental.book_id = book.book_id
book.category_id = category.category_id
```

---

### 16.3 WHERE에 JOIN 조건을 섞는 경우

아래처럼 써도 동작할 수 있지만, 읽기 어렵다.

```sql
SELECT r.rental_id, m.name
FROM rental r, member m
WHERE r.member_id = m.member_id;
```

권장 방식:

```sql
SELECT r.rental_id, m.name
FROM rental r
INNER JOIN member m ON r.member_id = m.member_id;
```

평가 답변:

> 명시적인 `INNER JOIN ... ON` 문법을 쓰면 테이블 연결 조건과 필터 조건을 분리해서 읽기 쉽습니다.

---

## 17. 평가 예상 질문과 답변

### 질문 1. INNER JOIN은 무엇인가요?

> INNER JOIN은 두 테이블의 연결 조건이 맞는 행만 결과로 보여주는 JOIN입니다. 이 프로젝트에서는 FK와 PK를 기준으로 대여 기록에 회원명, 도서명, 카테고리명을 붙일 때 사용했습니다.

### 질문 2. 왜 rental과 member를 JOIN하나요?

> `rental`에는 `member_id`만 있고 회원명은 없습니다. 회원명을 보려면 `rental.member_id = member.member_id` 조건으로 `member` 테이블을 JOIN해야 합니다.

### 질문 3. 왜 rental과 book을 JOIN하나요?

> `rental`에는 `book_id`만 있고 도서 제목은 없습니다. 도서명을 보려면 `rental.book_id = book.book_id` 조건으로 `book` 테이블을 JOIN해야 합니다.

### 질문 4. INNER JOIN 결과에서 빠지는 데이터는 무엇인가요?

> 연결 조건이 맞지 않는 행은 결과에서 빠집니다. 예를 들어 대여 기록이 없는 회원은 `member INNER JOIN rental` 결과에 나오지 않습니다.

### 질문 5. ON과 WHERE는 어떻게 다른가요?

> `ON`은 테이블 사이의 연결 조건이고, `WHERE`는 연결된 결과를 필터링하는 조건입니다.

---

## 18. 30초 답변 연습

> INNER JOIN은 두 테이블에서 연결 조건이 맞는 행만 보여주는 JOIN입니다. 이 프로젝트에서는 정규화 때문에 `rental`에 회원명이나 도서명을 직접 저장하지 않고 `member_id`, `book_id`만 저장했습니다. 그래서 `rental.member_id = member.member_id`, `rental.book_id = book.book_id` 조건으로 INNER JOIN해 대여 기록에 회원명과 도서명을 붙입니다. 연결되는 데이터가 없는 행은 결과에서 제외됩니다.

---

## 19. 오늘의 완료 기준

```text
[ ] INNER JOIN을 한 문장으로 설명했다.
[ ] rental + member JOIN을 직접 작성했다.
[ ] rental + book JOIN을 직접 작성했다.
[ ] book + category JOIN을 직접 작성했다.
[ ] rental + member + book JOIN을 직접 작성했다.
[ ] rental + member + book + category JOIN을 직접 작성했다.
[ ] ON과 WHERE의 차이를 설명했다.
[ ] INNER JOIN 결과에서 빠지는 데이터를 설명했다.
[ ] 30초 답변을 소리 내어 연습했다.
```
