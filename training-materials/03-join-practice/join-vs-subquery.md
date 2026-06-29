# JOIN vs 서브쿼리 비교 훈련

이 문서는 B5-1 도서 대여 관리 DB를 기준으로 같은 요구사항을 `JOIN` 방식과 `서브쿼리` 방식으로 각각 풀어보는 훈련 문서이다.

평가에서는 “JOIN을 쓸 수 있는가”뿐 아니라, **어떤 문제는 JOIN이 자연스럽고**, **어떤 문제는 서브쿼리가 간단하며**, **두 방식이 같은 결과를 낼 수 있음을 이해하는지**가 중요하다.

---

## 1. 한 줄 요약

```text
JOIN은 여러 테이블의 컬럼을 옆으로 붙여서 함께 보여줄 때 유리하고,
서브쿼리는 다른 쿼리의 결과를 조건값으로 사용할 때 유리하다.
```

평가 답변:

> JOIN은 관계가 있는 여러 테이블을 연결해 회원명, 도서명, 카테고리명처럼 컬럼을 함께 보여줄 때 사용합니다. 서브쿼리는 평균 가격보다 비싼 도서처럼 다른 SELECT 결과를 조건으로 사용할 때 적합합니다.

---

## 2. JOIN과 서브쿼리의 차이

| 구분 | JOIN | 서브쿼리 |
|---|---|---|
| 기본 개념 | 테이블을 연결한다. | 쿼리 안에 쿼리를 넣는다. |
| 주 용도 | 여러 테이블의 컬럼을 함께 출력 | 다른 쿼리 결과를 조건으로 사용 |
| 읽는 방식 | 관계를 따라 옆으로 붙임 | 안쪽 쿼리 결과를 바깥 쿼리가 사용 |
| B5-1 예시 | 대여 기록 + 회원명 + 도서명 | 평균 가격보다 비싼 도서 |
| 평가 포인트 | PK/FK 연결 조건 설명 | 안쪽 쿼리가 무엇을 반환하는지 설명 |

---

## 3. JOIN이 더 자연스러운 경우

아래처럼 여러 테이블의 컬럼을 함께 보여줘야 할 때는 JOIN이 자연스럽다.

```text
대여 기록에 회원명을 붙이고 싶다.
대여 기록에 도서명을 붙이고 싶다.
도서 목록에 카테고리명을 붙이고 싶다.
연체 기록에 회원명, 도서명, 카테고리명을 모두 붙이고 싶다.
```

예시:

```sql
SELECT r.rental_id, m.name AS member_name, b.title AS book_title, r.rented_at, r.status
FROM rental r
INNER JOIN member m ON r.member_id = m.member_id
INNER JOIN book b ON r.book_id = b.book_id
ORDER BY r.rented_at DESC;
```

평가 답변:

> 대여 기록에 회원명과 도서명을 함께 보여주려면 `rental`, `member`, `book` 세 테이블의 컬럼이 필요합니다. 이런 경우에는 FK와 PK를 기준으로 JOIN하는 방식이 가장 자연스럽습니다.

---

## 4. 서브쿼리가 더 자연스러운 경우

아래처럼 어떤 계산 결과나 조회 결과를 조건으로 써야 할 때는 서브쿼리가 자연스럽다.

```text
평균 가격보다 비싼 도서를 찾고 싶다.
특정 카테고리에 속한 도서만 찾고 싶다.
특정 조건의 대여 기록이 있는 회원을 찾고 싶다.
대여 기록이 존재하는 도서만 찾고 싶다.
```

예시:

```sql
SELECT book_id, title, price
FROM book
WHERE price > (SELECT AVG(price) FROM book)
ORDER BY price DESC;
```

평가 답변:

> 평균 가격은 먼저 계산되어야 하는 값입니다. 그래서 안쪽 쿼리에서 `AVG(price)`를 구하고, 바깥 쿼리에서 그 평균보다 비싼 도서를 조회합니다.

---

## 5. 예제 1 - 특정 카테고리 도서 찾기

요구사항:

```text
Database 카테고리에 속한 도서를 조회한다.
```

---

### 5.1 JOIN 방식

```sql
SELECT b.book_id, b.title, b.author, c.name AS category_name
FROM book b
INNER JOIN category c ON b.category_id = c.category_id
WHERE c.name = 'Database'
ORDER BY b.book_id ASC;
```

설명:

> `book`과 `category`를 JOIN해서 카테고리명을 직접 확인하면서 `Database` 카테고리의 도서를 조회한다.

장점:

```text
카테고리명까지 결과에 함께 보여줄 수 있다.
테이블 관계가 명확히 드러난다.
```

---

### 5.2 서브쿼리 방식

```sql
SELECT book_id, title, author, category_id
FROM book
WHERE category_id = (
    SELECT category_id
    FROM category
    WHERE name = 'Database'
)
ORDER BY book_id ASC;
```

설명:

> 안쪽 쿼리에서 `Database` 카테고리의 `category_id`를 찾고, 바깥 쿼리에서 그 카테고리에 속한 도서를 조회한다.

주의:

```text
이 방식은 안쪽 쿼리가 category_id 하나만 반환한다는 전제가 필요하다.
category.name에 UNIQUE가 있으므로 이 프로젝트에서는 안전하다.
```

---

### 5.3 평가 답변

> 같은 요구사항을 JOIN과 서브쿼리로 모두 풀 수 있습니다. 카테고리명까지 함께 보여주려면 JOIN이 좋고, 카테고리 ID만 조건으로 사용하면 서브쿼리도 가능합니다.

---

## 6. 예제 2 - 평균 가격보다 비싼 도서 찾기

요구사항:

```text
전체 도서 평균 가격보다 비싼 도서를 조회한다.
```

---

### 6.1 서브쿼리 방식

```sql
SELECT book_id, title, price
FROM book
WHERE price > (
    SELECT AVG(price)
    FROM book
)
ORDER BY price DESC;
```

설명:

> 안쪽 쿼리가 전체 도서 평균 가격을 계산하고, 바깥 쿼리가 그 평균보다 비싼 도서를 조회한다.

---

### 6.2 JOIN 없이 서브쿼리가 적절한 이유

이 문제는 다른 테이블의 컬럼을 붙이는 문제가 아니다.

필요한 것은 아래 하나다.

```text
전체 평균 가격이라는 계산 결과
```

따라서 서브쿼리가 더 자연스럽다.

평가 답변:

> 평균 가격보다 비싼 도서를 찾는 문제는 테이블을 연결하는 문제가 아니라 계산 결과를 조건으로 쓰는 문제입니다. 그래서 JOIN보다 서브쿼리가 더 간단합니다.

---

## 7. 예제 3 - 대여 기록이 있는 회원 찾기

요구사항:

```text
대여 기록이 하나 이상 있는 회원을 조회한다.
```

---

### 7.1 JOIN 방식

```sql
SELECT DISTINCT m.member_id, m.name, m.email
FROM member m
INNER JOIN rental r ON m.member_id = r.member_id
ORDER BY m.member_id ASC;
```

설명:

> `member`와 `rental`을 연결해 대여 기록이 있는 회원만 조회한다. 한 회원이 여러 번 대여했을 수 있으므로 `DISTINCT`로 중복 회원을 제거한다.

---

### 7.2 서브쿼리 방식 - IN

```sql
SELECT member_id, name, email
FROM member
WHERE member_id IN (
    SELECT member_id
    FROM rental
)
ORDER BY member_id ASC;
```

설명:

> 안쪽 쿼리에서 대여 기록에 등장한 회원 ID 목록을 구하고, 바깥 쿼리에서 그 회원만 조회한다.

---

### 7.3 서브쿼리 방식 - EXISTS

```sql
SELECT m.member_id, m.name, m.email
FROM member m
WHERE EXISTS (
    SELECT 1
    FROM rental r
    WHERE r.member_id = m.member_id
)
ORDER BY m.member_id ASC;
```

설명:

> 회원별로 연결되는 대여 기록이 하나라도 존재하면 결과에 포함한다.

평가 답변:

> 대여 기록이 있는 회원을 찾는 문제는 JOIN, IN 서브쿼리, EXISTS 서브쿼리로 모두 풀 수 있습니다. JOIN은 연결 관계가 잘 보이고, IN이나 EXISTS는 존재 여부를 조건으로 표현하기 좋습니다.

---

## 8. 예제 4 - 대여 기록이 없는 회원 찾기

요구사항:

```text
아직 대여 기록이 없는 회원을 조회한다.
```

---

### 8.1 LEFT JOIN 방식

```sql
SELECT m.member_id, m.name, m.email
FROM member m
LEFT JOIN rental r ON m.member_id = r.member_id
WHERE r.rental_id IS NULL
ORDER BY m.member_id ASC;
```

설명:

> 회원을 기준으로 대여 기록을 LEFT JOIN한 뒤, 매칭되는 대여 기록이 없는 회원만 찾는다.

---

### 8.2 서브쿼리 방식 - NOT IN

```sql
SELECT member_id, name, email
FROM member
WHERE member_id NOT IN (
    SELECT member_id
    FROM rental
)
ORDER BY member_id ASC;
```

설명:

> 대여 기록에 등장하지 않은 회원만 조회한다.

주의:

```text
NOT IN은 안쪽 결과에 NULL이 섞이면 의도와 다르게 동작할 수 있다.
이 프로젝트에서는 rental.member_id가 NOT NULL이라 비교적 안전하다.
```

---

### 8.3 서브쿼리 방식 - NOT EXISTS

```sql
SELECT m.member_id, m.name, m.email
FROM member m
WHERE NOT EXISTS (
    SELECT 1
    FROM rental r
    WHERE r.member_id = m.member_id
)
ORDER BY m.member_id ASC;
```

설명:

> 각 회원에 대해 연결되는 대여 기록이 없을 때만 결과에 포함한다.

평가 답변:

> 없는 데이터를 찾을 때는 LEFT JOIN 후 NULL을 찾는 방식과 NOT EXISTS 방식이 모두 가능합니다. LEFT JOIN 방식은 결과 구조가 직관적이고, NOT EXISTS는 존재하지 않음을 조건으로 명확히 표현합니다.

---

## 9. 예제 5 - 특정 카테고리 도서를 빌린 회원 찾기

요구사항:

```text
Database 카테고리 도서를 빌린 회원을 조회한다.
```

---

### 9.1 JOIN 방식

```sql
SELECT DISTINCT m.member_id, m.name, m.email
FROM member m
INNER JOIN rental r ON m.member_id = r.member_id
INNER JOIN book b ON r.book_id = b.book_id
INNER JOIN category c ON b.category_id = c.category_id
WHERE c.name = 'Database'
ORDER BY m.member_id ASC;
```

설명:

> 회원, 대여, 도서, 카테고리를 모두 연결해서 Database 카테고리 도서를 빌린 회원을 찾는다.

---

### 9.2 서브쿼리 방식

```sql
SELECT member_id, name, email
FROM member
WHERE member_id IN (
    SELECT r.member_id
    FROM rental r
    WHERE r.book_id IN (
        SELECT b.book_id
        FROM book b
        WHERE b.category_id = (
            SELECT c.category_id
            FROM category c
            WHERE c.name = 'Database'
        )
    )
)
ORDER BY member_id ASC;
```

설명:

> 안쪽에서 Database 카테고리 ID를 찾고, 그 카테고리의 도서 ID를 찾고, 그 도서를 빌린 회원 ID를 찾은 뒤, 최종적으로 회원 정보를 조회한다.

비교:

```text
JOIN 방식은 관계 흐름이 한눈에 보인다.
서브쿼리 방식은 조건을 단계적으로 좁혀 가는 구조다.
이 문제는 여러 테이블의 관계를 설명해야 하므로 JOIN 방식이 평가 때 더 설명하기 좋다.
```

---

## 10. 예제 6 - 카테고리별 도서 수

요구사항:

```text
카테고리별 도서 수를 조회한다.
```

---

### 10.1 JOIN + GROUP BY 방식

```sql
SELECT c.category_id, c.name AS category_name, COUNT(b.book_id) AS book_count
FROM category c
LEFT JOIN book b ON c.category_id = b.category_id
GROUP BY c.category_id, c.name
ORDER BY book_count DESC, c.category_id ASC;
```

설명:

> 카테고리와 도서를 LEFT JOIN한 뒤 카테고리별로 묶어 도서 수를 계산한다. 도서가 없는 카테고리도 0건으로 포함할 수 있다.

---

### 10.2 상관 서브쿼리 방식

```sql
SELECT c.category_id,
       c.name AS category_name,
       (
           SELECT COUNT(*)
           FROM book b
           WHERE b.category_id = c.category_id
       ) AS book_count
FROM category c
ORDER BY book_count DESC, c.category_id ASC;
```

설명:

> 각 카테고리 행마다 안쪽 쿼리가 해당 카테고리의 도서 수를 계산한다.

평가 답변:

> 카테고리별 도서 수는 JOIN + GROUP BY로도 풀 수 있고, 상관 서브쿼리로도 풀 수 있습니다. 집계 관계를 설명하기에는 JOIN + GROUP BY 방식이 더 일반적이고, 상관 서브쿼리는 각 행마다 별도 계산을 붙이는 방식입니다.

---

## 11. 서브쿼리 종류

| 종류 | 설명 | 예시 |
|---|---|---|
| 스칼라 서브쿼리 | 값 하나를 반환 | 평균 가격 |
| IN 서브쿼리 | 여러 값 목록을 반환 | 대여 기록이 있는 회원 목록 |
| EXISTS 서브쿼리 | 존재 여부를 확인 | 대여 기록이 존재하는 회원 |
| 상관 서브쿼리 | 바깥 쿼리의 값을 안쪽 쿼리에서 사용 | 카테고리별 도서 수 |

---

## 12. JOIN을 선택하기 좋은 기준

아래에 해당하면 JOIN을 우선 고려한다.

```text
[ ] 여러 테이블의 컬럼을 함께 출력해야 한다.
[ ] ERD의 관계를 따라 데이터를 붙여야 한다.
[ ] 회원명, 도서명, 카테고리명처럼 사람이 읽을 컬럼이 필요하다.
[ ] GROUP BY로 관계 기반 집계를 해야 한다.
[ ] 평가자에게 PK/FK 연결 흐름을 보여주고 싶다.
```

예:

```text
대여 기록 + 회원명 + 도서명
연체 기록 + 회원명 + 도서명 + 카테고리명
카테고리별 도서 수
회원별 대여 횟수
```

---

## 13. 서브쿼리를 선택하기 좋은 기준

아래에 해당하면 서브쿼리를 고려한다.

```text
[ ] 다른 SELECT 결과를 조건값으로 써야 한다.
[ ] 평균, 최대값, 최소값 같은 계산 결과와 비교해야 한다.
[ ] 특정 값 목록에 포함되는지 확인해야 한다.
[ ] 존재 여부만 판단하면 된다.
[ ] 바깥 쿼리의 각 행마다 별도 계산값을 붙이고 싶다.
```

예:

```text
평균 가격보다 비싼 도서
대여 기록이 있는 회원
대여 기록이 없는 회원
카테고리별 도서 수를 상관 서브쿼리로 계산
```

---

## 14. 직접 연습 문제

아래 요구사항을 각각 JOIN 방식과 서브쿼리 방식으로 풀어본다.

```text
[ ] 1. Database 카테고리 도서 조회
[ ] 2. 대여 기록이 있는 회원 조회
[ ] 3. 대여 기록이 없는 회원 조회
[ ] 4. 평균 가격보다 비싼 도서 조회
[ ] 5. Database 카테고리 도서를 빌린 회원 조회
[ ] 6. 카테고리별 도서 수 조회
[ ] 7. 대여된 적 있는 도서 조회
[ ] 8. 대여된 적 없는 도서 조회
```

---

## 15. 자주 하는 실수

### 15.1 서브쿼리가 여러 행을 반환하는데 `=`를 쓰는 경우

```sql
-- 위험한 예: 안쪽 쿼리가 여러 category_id를 반환하면 오류 가능
SELECT book_id, title
FROM book
WHERE category_id = (
    SELECT category_id
    FROM category
);
```

대안:

```sql
SELECT book_id, title
FROM book
WHERE category_id IN (
    SELECT category_id
    FROM category
);
```

---

### 15.2 JOIN 후 중복 행이 생기는 경우

한 회원이 여러 권을 빌렸다면 JOIN 결과에서 회원이 여러 번 나온다.

```sql
SELECT m.member_id, m.name
FROM member m
INNER JOIN rental r ON m.member_id = r.member_id;
```

회원 목록만 필요하면 `DISTINCT`를 사용한다.

```sql
SELECT DISTINCT m.member_id, m.name
FROM member m
INNER JOIN rental r ON m.member_id = r.member_id;
```

---

### 15.3 NOT IN과 NULL 문제

`NOT IN`의 안쪽 결과에 NULL이 섞이면 의도와 다르게 동작할 수 있다.

안전한 대안:

```sql
SELECT m.member_id, m.name
FROM member m
WHERE NOT EXISTS (
    SELECT 1
    FROM rental r
    WHERE r.member_id = m.member_id
);
```

---

## 16. 평가 예상 질문과 답변

### 질문 1. JOIN과 서브쿼리의 차이는 무엇인가요?

> JOIN은 여러 테이블을 연결해서 컬럼을 함께 보여주는 방식이고, 서브쿼리는 쿼리 안의 쿼리 결과를 조건이나 계산값으로 사용하는 방식입니다.

### 질문 2. 언제 JOIN을 쓰는 것이 좋나요?

> 여러 테이블의 컬럼을 함께 출력해야 할 때 JOIN이 좋습니다. 예를 들어 대여 기록에 회원명과 도서명을 붙이는 경우에는 `rental`, `member`, `book`을 JOIN해야 합니다.

### 질문 3. 언제 서브쿼리를 쓰는 것이 좋나요?

> 다른 SELECT 결과를 조건으로 써야 할 때 서브쿼리가 좋습니다. 예를 들어 평균 가격보다 비싼 도서를 찾을 때는 안쪽 쿼리에서 평균 가격을 구하고 바깥 쿼리에서 비교합니다.

### 질문 4. 같은 요구사항을 JOIN과 서브쿼리로 모두 풀 수 있나요?

> 가능합니다. 예를 들어 Database 카테고리 도서를 찾는 문제는 `book`과 `category`를 JOIN해서 풀 수도 있고, 서브쿼리로 Database 카테고리 ID를 먼저 찾은 뒤 `book`을 조회할 수도 있습니다.

### 질문 5. 평가 때 어떤 방식을 우선 설명하면 좋나요?

> 테이블 관계를 보여줘야 하는 문제는 JOIN을 우선 설명하고, 평균값이나 존재 여부처럼 다른 쿼리 결과를 조건으로 쓰는 문제는 서브쿼리를 설명하는 것이 좋습니다.

---

## 17. 30초 답변 연습

> JOIN은 여러 테이블의 컬럼을 함께 보여주기 위해 테이블을 연결하는 방식이고, 서브쿼리는 쿼리 안의 쿼리 결과를 조건으로 사용하는 방식입니다. 이 프로젝트에서는 대여 기록에 회원명과 도서명을 붙일 때 JOIN을 사용하고, 평균 가격보다 비싼 도서를 찾을 때 서브쿼리를 사용합니다. 같은 문제를 두 방식으로 풀 수도 있지만, 관계를 보여줄 때는 JOIN이, 계산 결과나 존재 여부를 조건으로 쓸 때는 서브쿼리가 더 자연스럽습니다.

---

## 18. 오늘의 완료 기준

```text
[ ] JOIN과 서브쿼리 차이를 한 문장으로 설명했다.
[ ] Database 카테고리 도서 조회를 JOIN 방식으로 작성했다.
[ ] Database 카테고리 도서 조회를 서브쿼리 방식으로 작성했다.
[ ] 평균 가격보다 비싼 도서 쿼리를 작성했다.
[ ] 대여 기록이 있는 회원을 JOIN/IN/EXISTS 중 2가지 방식으로 작성했다.
[ ] 대여 기록이 없는 회원을 LEFT JOIN/NOT EXISTS 중 2가지 방식으로 작성했다.
[ ] 카테고리별 도서 수를 JOIN + GROUP BY와 상관 서브쿼리로 비교했다.
[ ] JOIN을 선택할 기준과 서브쿼리를 선택할 기준을 설명했다.
[ ] 30초 답변을 소리 내어 연습했다.
```
