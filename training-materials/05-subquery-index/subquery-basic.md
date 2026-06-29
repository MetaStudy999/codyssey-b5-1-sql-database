# 서브쿼리 기본 훈련

이 문서는 B5-1 도서 대여 관리 DB를 기준으로 서브쿼리의 기본 개념과 실습 쿼리를 정리한 문서이다.

평가에서는 서브쿼리 문법만 쓰는 것보다, **안쪽 쿼리가 무엇을 반환하는지**, **바깥 쿼리가 그 결과를 어떻게 사용하는지**, **JOIN보다 서브쿼리가 자연스러운 상황이 무엇인지**를 설명할 수 있어야 한다.

---

## 1. 서브쿼리 한 줄 요약

```text
서브쿼리는 SELECT 안에 들어가는 또 다른 SELECT이며, 안쪽 쿼리의 결과를 바깥 쿼리의 조건이나 계산에 사용하는 방식이다.
```

평가 답변:

> 서브쿼리는 쿼리 안에 들어가는 쿼리입니다. 예를 들어 전체 도서 평균 가격을 안쪽 쿼리에서 계산하고, 바깥 쿼리에서 그 평균보다 비싼 도서를 찾을 수 있습니다.

---

## 2. 기본 구조

```sql
SELECT 컬럼목록
FROM 테이블명
WHERE 컬럼 연산자 (
    SELECT 컬럼또는집계값
    FROM 다른테이블또는같은테이블
    WHERE 조건
);
```

읽는 순서:

```text
1. 안쪽 SELECT가 먼저 어떤 값을 반환하는지 확인한다.
2. 바깥 SELECT가 그 값을 조건으로 사용한다.
3. 최종 결과가 만들어진다.
```

예시:

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

> 안쪽 쿼리가 전체 평균 가격을 반환하고, 바깥 쿼리가 평균보다 비싼 도서만 조회한다.

---

## 3. 서브쿼리 종류

| 종류 | 반환 결과 | 대표 사용처 | B5-1 예시 |
|---|---|---|---|
| 스칼라 서브쿼리 | 값 1개 | 평균, 최대값, 특정 ID | 평균 가격보다 비싼 도서 |
| IN 서브쿼리 | 값 여러 개 | 목록 포함 여부 | 대여 기록이 있는 회원 |
| EXISTS 서브쿼리 | 존재 여부 | 관련 행 존재 확인 | 대여 기록이 있는 회원 |
| NOT EXISTS 서브쿼리 | 부재 여부 | 관련 행이 없는 대상 찾기 | 대여 기록이 없는 회원 |
| 상관 서브쿼리 | 바깥 행마다 계산 | 행별 집계값 계산 | 카테고리별 도서 수 |
| FROM 서브쿼리 | 임시 결과 테이블 | 집계 결과 재가공 | 인기 도서 집계 후 필터링 |

---

## 4. 예제 1 - 평균 가격보다 비싼 도서

### SQL

```sql
SELECT book_id,
       title,
       price
FROM book
WHERE price > (
    SELECT AVG(price)
    FROM book
)
ORDER BY price DESC;
```

### 안쪽 쿼리

```sql
SELECT AVG(price)
FROM book;
```

반환값:

```text
전체 도서 평균 가격 1개
```

### 평가 답변

> 안쪽 쿼리에서 전체 도서의 평균 가격을 계산합니다. 바깥 쿼리는 그 평균값보다 가격이 높은 도서만 조회합니다. 값 하나를 반환하므로 스칼라 서브쿼리입니다.

---

## 5. 예제 2 - 가장 비싼 도서 찾기

### SQL

```sql
SELECT book_id,
       title,
       price
FROM book
WHERE price = (
    SELECT MAX(price)
    FROM book
);
```

### 설명

> 안쪽 쿼리에서 전체 도서 중 최고 가격을 구하고, 바깥 쿼리에서 그 가격과 같은 도서를 찾는다.

주의:

```text
최고 가격이 같은 도서가 여러 권이면 결과도 여러 행이 나올 수 있다.
하지만 안쪽 쿼리는 MAX(price) 값 하나만 반환하므로 = 사용이 가능하다.
```

평가 답변:

> 최고가 도서를 찾을 때는 안쪽 쿼리에서 `MAX(price)`를 구하고, 바깥 쿼리에서 그 값과 같은 도서를 조회합니다.

---

## 6. 예제 3 - 특정 카테고리 도서 찾기

요구사항:

```text
Database 카테고리에 속한 도서를 조회한다.
```

### 서브쿼리 방식

```sql
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
```

### 안쪽 쿼리

```sql
SELECT category_id
FROM category
WHERE name = 'Database';
```

반환값:

```text
Database 카테고리의 category_id 1개
```

평가 답변:

> 안쪽 쿼리에서 `Database` 카테고리의 ID를 찾고, 바깥 쿼리에서 그 `category_id`를 가진 도서를 조회했습니다. `category.name`이 UNIQUE라서 안쪽 쿼리는 값 하나만 반환합니다.

---

## 7. 예제 4 - 여러 카테고리 도서 찾기, IN

요구사항:

```text
Database 또는 Backend 카테고리에 속한 도서를 조회한다.
```

### SQL

```sql
SELECT book_id,
       title,
       author,
       category_id
FROM book
WHERE category_id IN (
    SELECT category_id
    FROM category
    WHERE name IN ('Database', 'Backend')
)
ORDER BY category_id ASC, book_id ASC;
```

### 설명

> 안쪽 쿼리는 Database와 Backend의 category_id 목록을 반환한다. 바깥 쿼리는 그 목록에 포함되는 category_id를 가진 도서를 조회한다.

평가 답변:

> 안쪽 쿼리가 여러 개의 값을 반환할 수 있으면 `=`가 아니라 `IN`을 사용해야 합니다. 이 예제에서는 여러 카테고리 ID 목록을 조건으로 사용했습니다.

---

## 8. 예제 5 - 대여 기록이 있는 회원, IN

### SQL

```sql
SELECT member_id,
       name,
       email
FROM member
WHERE member_id IN (
    SELECT member_id
    FROM rental
)
ORDER BY member_id ASC;
```

### 설명

> 안쪽 쿼리가 대여 기록에 등장한 회원 ID 목록을 반환하고, 바깥 쿼리가 그 회원만 조회한다.

주의:

```text
rental에 같은 member_id가 여러 번 나와도 IN 조건은 포함 여부만 본다.
```

평가 답변:

> 대여 기록이 있는 회원을 찾기 위해 안쪽 쿼리에서 `rental.member_id` 목록을 구하고, 바깥 쿼리에서 그 목록에 포함된 회원만 조회했습니다.

---

## 9. 예제 6 - 대여 기록이 있는 회원, EXISTS

### SQL

```sql
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
```

### 설명

> 각 회원에 대해 연결되는 대여 기록이 하나라도 있으면 결과에 포함한다.

읽는 법:

```text
member의 한 행을 본다.
rental에서 같은 member_id를 가진 행이 있는지 확인한다.
있으면 EXISTS가 참이 되어 해당 회원을 출력한다.
```

평가 답변:

> `EXISTS`는 안쪽 쿼리 결과가 실제로 존재하는지 확인합니다. 이 쿼리는 각 회원마다 대여 기록이 하나라도 있는지 검사합니다.

---

## 10. 예제 7 - 대여 기록이 없는 회원, NOT EXISTS

### SQL

```sql
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
```

### 설명

> 각 회원에 대해 연결되는 대여 기록이 하나도 없을 때 결과에 포함한다.

평가 답변:

> 대여 기록이 없는 회원을 찾으려면 `NOT EXISTS`를 사용할 수 있습니다. 회원별로 rental에 연결 행이 없는 경우만 결과에 남깁니다.

---

## 11. 예제 8 - 대여된 적 있는 도서, EXISTS

### SQL

```sql
SELECT b.book_id,
       b.title,
       b.author
FROM book b
WHERE EXISTS (
    SELECT 1
    FROM rental r
    WHERE r.book_id = b.book_id
)
ORDER BY b.book_id ASC;
```

### 설명

> 각 도서에 대해 rental 테이블에 해당 book_id가 하나라도 있으면 대여된 적 있는 도서로 판단한다.

---

## 12. 예제 9 - 대여된 적 없는 도서, NOT EXISTS

### SQL

```sql
SELECT b.book_id,
       b.title,
       b.author
FROM book b
WHERE NOT EXISTS (
    SELECT 1
    FROM rental r
    WHERE r.book_id = b.book_id
)
ORDER BY b.book_id ASC;
```

### 설명

> 각 도서에 대해 rental 테이블에 해당 book_id가 없으면 대여된 적 없는 도서로 판단한다.

평가 답변:

> `NOT EXISTS`는 관련 데이터가 없는 대상을 찾을 때 유용합니다. 이 예제에서는 rental에 등장하지 않는 도서를 찾습니다.

---

## 13. 예제 10 - 카테고리별 도서 수, 상관 서브쿼리

### SQL

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

### 설명

> 바깥 쿼리의 카테고리 한 행마다 안쪽 쿼리가 해당 카테고리의 도서 수를 계산한다.

상관 서브쿼리인 이유:

```text
안쪽 쿼리에서 바깥 쿼리의 c.category_id를 사용한다.
```

평가 답변:

> 상관 서브쿼리는 바깥 쿼리의 값을 안쪽 쿼리에서 사용하는 방식입니다. 이 예제에서는 각 카테고리 행마다 해당 카테고리에 속한 도서 수를 계산합니다.

---

## 14. 예제 11 - 카테고리 평균보다 비싼 도서

요구사항:

```text
각 도서가 속한 카테고리의 평균 가격보다 비싼 도서를 조회한다.
```

### SQL

```sql
SELECT b.book_id,
       b.title,
       b.category_id,
       b.price
FROM book b
WHERE b.price > (
    SELECT AVG(b2.price)
    FROM book b2
    WHERE b2.category_id = b.category_id
)
ORDER BY b.category_id ASC, b.price DESC;
```

### 설명

> 각 도서마다 같은 카테고리에 속한 도서들의 평균 가격을 안쪽 쿼리에서 계산하고, 바깥 도서의 가격과 비교한다.

평가 답변:

> 이 쿼리는 상관 서브쿼리입니다. 안쪽 쿼리가 바깥 쿼리의 `b.category_id`를 사용해 같은 카테고리 평균 가격을 계산하기 때문입니다.

---

## 15. 예제 12 - FROM 서브쿼리로 인기 도서 집계 재사용

### SQL

```sql
SELECT ranked.book_id,
       ranked.title,
       ranked.rental_count
FROM (
    SELECT b.book_id,
           b.title,
           COUNT(r.rental_id) AS rental_count
    FROM book b
    LEFT JOIN rental r ON b.book_id = r.book_id
    GROUP BY b.book_id, b.title
) ranked
WHERE ranked.rental_count >= 2
ORDER BY ranked.rental_count DESC, ranked.book_id ASC;
```

### 설명

> 안쪽 FROM 서브쿼리에서 도서별 대여 횟수를 먼저 계산하고, 바깥 쿼리에서 대여 횟수 2건 이상인 도서만 필터링한다.

평가 답변:

> FROM 서브쿼리는 안쪽 쿼리 결과를 임시 테이블처럼 사용합니다. 이 예제에서는 도서별 대여 횟수를 먼저 만든 뒤, 바깥 쿼리에서 그 집계 결과를 다시 필터링했습니다.

---

## 16. JOIN과 서브쿼리 선택 기준

| 상황 | 추천 방식 | 이유 |
|---|---|---|
| 회원명, 도서명, 카테고리명 같이 여러 테이블 컬럼을 함께 출력 | JOIN | 관계를 따라 컬럼을 붙이는 문제 |
| 평균 가격보다 비싼 도서 | 서브쿼리 | 평균값을 조건으로 사용 |
| 특정 카테고리 ID를 먼저 찾아 도서 조회 | 서브쿼리 가능 | ID 하나를 조건으로 사용 |
| 대여 기록이 있는 회원 | JOIN, IN, EXISTS 모두 가능 | 관계 조회 또는 존재 여부 문제 |
| 대여 기록이 없는 회원 | LEFT JOIN, NOT EXISTS | 없는 관계를 찾는 문제 |
| 카테고리별 도서 수 | JOIN + GROUP BY 또는 상관 서브쿼리 | 집계 문제 |

평가 답변:

> 여러 테이블의 컬럼을 함께 보여줘야 하면 JOIN이 자연스럽고, 어떤 계산 결과나 존재 여부를 조건으로 사용하면 서브쿼리가 자연스럽습니다.

---

## 17. 자주 하는 실수

### 17.1 여러 행을 반환하는 서브쿼리에 = 사용

```sql
-- 잘못된 예
SELECT book_id, title
FROM book
WHERE category_id = (
    SELECT category_id
    FROM category
);
```

문제:

> 안쪽 쿼리가 여러 category_id를 반환할 수 있는데 `=`는 값 하나와 비교할 때 사용한다.

권장:

```sql
SELECT book_id, title
FROM book
WHERE category_id IN (
    SELECT category_id
    FROM category
);
```

---

### 17.2 NOT IN과 NULL 문제

```sql
SELECT member_id, name
FROM member
WHERE member_id NOT IN (
    SELECT member_id
    FROM rental
);
```

주의:

> `NOT IN`은 안쪽 결과에 NULL이 섞이면 의도와 다르게 동작할 수 있다. 이 프로젝트에서는 `rental.member_id`가 NOT NULL이지만, 일반적으로는 `NOT EXISTS`가 더 안전하다.

권장:

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

### 17.3 안쪽 쿼리 결과를 설명하지 못하는 경우

서브쿼리 평가는 다음 두 문장을 말할 수 있어야 한다.

```text
안쪽 쿼리는 무엇을 반환하는가?
바깥 쿼리는 그 결과를 어떻게 사용하는가?
```

예:

> 안쪽 쿼리는 전체 평균 가격 하나를 반환합니다. 바깥 쿼리는 그 평균값보다 가격이 큰 도서를 조회합니다.

---

### 17.4 상관 서브쿼리 별칭을 헷갈리는 경우

```sql
SELECT b.book_id, b.title, b.price
FROM book b
WHERE b.price > (
    SELECT AVG(b2.price)
    FROM book b2
    WHERE b2.category_id = b.category_id
);
```

구분:

```text
b  → 바깥 쿼리의 book
b2 → 안쪽 쿼리의 book
```

---

## 18. 직접 연습 문제

```text
[ ] 1. 전체 평균 가격보다 비싼 도서를 조회한다.
[ ] 2. 최고 가격 도서를 조회한다.
[ ] 3. Database 카테고리 도서를 서브쿼리로 조회한다.
[ ] 4. Database 또는 Backend 카테고리 도서를 IN 서브쿼리로 조회한다.
[ ] 5. 대여 기록이 있는 회원을 IN 서브쿼리로 조회한다.
[ ] 6. 대여 기록이 있는 회원을 EXISTS로 조회한다.
[ ] 7. 대여 기록이 없는 회원을 NOT EXISTS로 조회한다.
[ ] 8. 대여된 적 없는 도서를 NOT EXISTS로 조회한다.
[ ] 9. 카테고리별 도서 수를 상관 서브쿼리로 조회한다.
[ ] 10. 카테고리 평균보다 비싼 도서를 상관 서브쿼리로 조회한다.
[ ] 11. 도서별 대여 횟수를 FROM 서브쿼리로 만든 뒤 2건 이상만 조회한다.
```

---

## 19. 평가 예상 질문과 답변

### 질문 1. 서브쿼리는 무엇인가요?

> 서브쿼리는 쿼리 안에 들어가는 또 다른 SELECT입니다. 안쪽 쿼리의 결과를 바깥 쿼리의 조건이나 계산에 사용합니다.

### 질문 2. 평균 가격보다 비싼 도서는 어떻게 찾나요?

> 안쪽 쿼리에서 `AVG(price)`로 전체 평균 가격을 계산하고, 바깥 쿼리에서 `price > 평균값` 조건으로 도서를 조회합니다.

### 질문 3. IN과 EXISTS는 어떻게 다른가요?

> `IN`은 안쪽 쿼리가 반환한 값 목록에 포함되는지 확인하고, `EXISTS`는 안쪽 쿼리 결과가 존재하는지만 확인합니다.

### 질문 4. NOT EXISTS는 언제 사용하나요?

> 연결되는 데이터가 없는 대상을 찾을 때 사용합니다. 예를 들어 대여 기록이 없는 회원이나 대여된 적 없는 도서를 찾을 때 사용할 수 있습니다.

### 질문 5. 상관 서브쿼리는 무엇인가요?

> 상관 서브쿼리는 안쪽 쿼리가 바깥 쿼리의 컬럼을 참조하는 서브쿼리입니다. 예를 들어 각 도서의 카테고리 평균 가격을 계산할 때 안쪽 쿼리가 바깥 도서의 `category_id`를 사용합니다.

---

## 20. 30초 답변 연습

> 서브쿼리는 SELECT 안에 들어가는 또 다른 SELECT입니다. 이 프로젝트에서는 평균 가격보다 비싼 도서를 찾을 때 안쪽 쿼리에서 `AVG(price)`를 구하고, 바깥 쿼리에서 그 값보다 비싼 도서를 조회합니다. 또한 대여 기록이 있는 회원은 `IN`이나 `EXISTS`로 찾을 수 있고, 대여 기록이 없는 회원은 `NOT EXISTS`로 찾을 수 있습니다. 여러 테이블의 컬럼을 함께 보여줄 때는 JOIN이 자연스럽고, 계산 결과나 존재 여부를 조건으로 쓸 때는 서브쿼리가 자연스럽습니다.

---

## 21. 오늘의 완료 기준

```text
[ ] 서브쿼리를 한 문장으로 설명했다.
[ ] 안쪽 쿼리와 바깥 쿼리의 역할을 설명했다.
[ ] 스칼라 서브쿼리 예제를 작성했다.
[ ] IN 서브쿼리 예제를 작성했다.
[ ] EXISTS 서브쿼리 예제를 작성했다.
[ ] NOT EXISTS 서브쿼리 예제를 작성했다.
[ ] 상관 서브쿼리 예제를 작성했다.
[ ] FROM 서브쿼리 예제를 작성했다.
[ ] JOIN과 서브쿼리 선택 기준을 설명했다.
[ ] 30초 답변을 소리 내어 연습했다.
```
