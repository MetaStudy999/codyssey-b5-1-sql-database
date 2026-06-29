# LEFT JOIN 훈련 노트

이 문서는 B5-1 도서 대여 관리 DB를 기준으로 `LEFT JOIN`을 반복 훈련하기 위한 문서이다.

평가에서는 `LEFT JOIN`을 단순히 쓰는 것보다, **INNER JOIN과 무엇이 다른지**, **왼쪽 테이블의 행이 왜 유지되는지**, **매칭되지 않는 오른쪽 테이블 값이 왜 NULL로 나오는지**, **0건까지 포함한 집계를 왜 LEFT JOIN으로 해야 하는지**를 설명할 수 있어야 한다.

---

## 1. LEFT JOIN 한 줄 요약

```text
LEFT JOIN은 왼쪽 테이블의 모든 행을 유지하고, 오른쪽 테이블에서 매칭되는 값이 있으면 붙이고 없으면 NULL로 보여준다.
```

평가 답변:

> `LEFT JOIN`은 왼쪽 테이블을 기준으로 모든 행을 보여줍니다. 오른쪽 테이블에 연결되는 데이터가 있으면 함께 보여주고, 없으면 오른쪽 컬럼은 NULL로 표시합니다. 그래서 대여 기록이 없는 회원까지 포함해 조회할 때 사용합니다.

---

## 2. 기본 문법

```sql
SELECT 컬럼목록
FROM 왼쪽테이블 별칭
LEFT JOIN 오른쪽테이블 별칭
    ON 왼쪽테이블.컬럼 = 오른쪽테이블.컬럼;
```

예시:

```sql
SELECT m.member_id, m.name, r.rental_id, r.status
FROM member m
LEFT JOIN rental r ON m.member_id = r.member_id;
```

읽는 순서:

```text
1. member 테이블의 모든 회원을 먼저 유지한다.
2. rental 테이블에서 member_id가 같은 대여 기록을 찾는다.
3. 대여 기록이 있으면 rental 컬럼을 붙인다.
4. 대여 기록이 없으면 rental 컬럼은 NULL로 표시한다.
```

---

## 3. LEFT JOIN이 필요한 이유

`INNER JOIN`은 매칭되는 데이터만 보여준다.

따라서 아래 요구사항에는 부족할 수 있다.

```text
대여 기록이 없는 회원도 보고 싶다.
도서가 없는 카테고리도 보고 싶다.
대여 횟수가 0인 회원도 집계하고 싶다.
카테고리별 도서 수를 0건까지 보고 싶다.
```

이런 경우 `LEFT JOIN`을 사용한다.

평가 답변:

> LEFT JOIN은 “없는 데이터까지 확인해야 하는 요구사항”에서 중요합니다. 예를 들어 회원별 대여 횟수를 구할 때 INNER JOIN을 쓰면 대여 기록이 없는 회원은 빠지지만, LEFT JOIN을 쓰면 대여 횟수 0인 회원도 확인할 수 있습니다.

---

## 4. INNER JOIN과 LEFT JOIN 차이

| 구분 | INNER JOIN | LEFT JOIN |
|---|---|---|
| 기준 | 양쪽 모두 매칭되는 행 | 왼쪽 테이블의 모든 행 |
| 매칭 없는 왼쪽 행 | 결과에서 제외 | 결과에 남음 |
| 오른쪽 매칭 없음 | 결과 없음 | 오른쪽 컬럼이 NULL |
| 대표 용도 | 실제 연결된 데이터만 조회 | 0건, 미연결 데이터까지 조회 |

예시 설명:

```text
member INNER JOIN rental
→ 대여 기록이 있는 회원만 나온다.

member LEFT JOIN rental
→ 모든 회원이 나오고, 대여 기록이 없으면 rental 값이 NULL이다.
```

---

## 5. 예제 1 - 모든 회원과 대여 기록 조회

### SQL

```sql
SELECT m.member_id,
       m.name AS member_name,
       r.rental_id,
       r.book_id,
       r.rented_at,
       r.status
FROM member m
LEFT JOIN rental r ON m.member_id = r.member_id
ORDER BY m.member_id, r.rented_at;
```

### 설명

> `member`를 왼쪽에 두었으므로 모든 회원이 결과에 남는다. 대여 기록이 있는 회원은 rental 정보가 붙고, 없는 회원은 rental 컬럼이 NULL로 표시된다.

### 평가 답변

> 회원별 대여 여부를 모두 확인하려면 `member`를 기준으로 `rental`을 LEFT JOIN합니다. 이렇게 하면 대여 기록이 없는 회원도 결과에서 빠지지 않습니다.

---

## 6. 예제 2 - 회원별 대여 횟수, 0건 포함

### SQL

```sql
SELECT m.member_id,
       m.name AS member_name,
       COUNT(r.rental_id) AS rental_count
FROM member m
LEFT JOIN rental r ON m.member_id = r.member_id
GROUP BY m.member_id, m.name
ORDER BY rental_count ASC, m.member_id ASC;
```

### 설명

> `COUNT(r.rental_id)`는 실제 대여 기록 ID가 있는 행만 센다. 대여 기록이 없는 회원은 0으로 계산된다.

### 평가 답변

> 회원별 대여 횟수를 구할 때 대여가 없는 회원도 포함하려면 LEFT JOIN을 사용해야 합니다. 그리고 `COUNT(*)`가 아니라 `COUNT(r.rental_id)`를 사용해야 대여 기록이 없는 회원이 1이 아니라 0으로 계산됩니다.

---

## 7. COUNT(*)와 COUNT(컬럼)의 차이

LEFT JOIN에서 매우 중요하다.

```sql
SELECT m.member_id,
       m.name,
       COUNT(*) AS count_star,
       COUNT(r.rental_id) AS count_rental_id
FROM member m
LEFT JOIN rental r ON m.member_id = r.member_id
GROUP BY m.member_id, m.name
ORDER BY m.member_id;
```

차이:

| 표현 | 의미 | 대여 없는 회원 결과 |
|---|---|---|
| `COUNT(*)` | LEFT JOIN 결과 행 자체를 센다 | 1 |
| `COUNT(r.rental_id)` | 실제 rental_id가 NULL이 아닌 행만 센다 | 0 |

평가 답변:

> LEFT JOIN으로 0건 집계를 할 때는 `COUNT(*)`보다 `COUNT(오른쪽테이블.PK)`를 쓰는 것이 안전합니다. 매칭이 없는 경우 오른쪽 PK가 NULL이므로 0으로 계산됩니다.

---

## 8. 예제 3 - 모든 카테고리와 도서 수 조회

### SQL

```sql
SELECT c.category_id,
       c.name AS category_name,
       COUNT(b.book_id) AS book_count
FROM category c
LEFT JOIN book b ON c.category_id = b.category_id
GROUP BY c.category_id, c.name
ORDER BY book_count DESC, c.category_id ASC;
```

### 설명

> 모든 카테고리를 유지하면서 각 카테고리에 속한 도서 수를 계산한다. 도서가 없는 카테고리도 0으로 표시할 수 있다.

### 평가 답변

> 카테고리별 도서 수를 구할 때 도서가 없는 카테고리도 확인하려면 `category`를 왼쪽에 두고 `book`을 LEFT JOIN합니다.

---

## 9. 예제 4 - 모든 도서와 대여 횟수 조회

### SQL

```sql
SELECT b.book_id,
       b.title,
       COUNT(r.rental_id) AS rental_count
FROM book b
LEFT JOIN rental r ON b.book_id = r.book_id
GROUP BY b.book_id, b.title
ORDER BY rental_count DESC, b.book_id ASC;
```

### 설명

> 모든 도서를 기준으로 대여 횟수를 계산한다. 아직 대여된 적 없는 도서도 결과에 남고 대여 횟수는 0으로 표시된다.

### 평가 답변

> 도서별 대여 횟수를 볼 때 대여된 적 없는 도서도 포함하려면 `book`을 왼쪽에 두고 `rental`을 LEFT JOIN해야 합니다.

---

## 10. 예제 5 - 대여 기록이 없는 회원 찾기

### SQL

```sql
SELECT m.member_id,
       m.name,
       m.email,
       m.status
FROM member m
LEFT JOIN rental r ON m.member_id = r.member_id
WHERE r.rental_id IS NULL
ORDER BY m.member_id;
```

### 설명

> LEFT JOIN 후 `r.rental_id IS NULL` 조건을 걸면 오른쪽 rental에 매칭되는 기록이 없는 회원만 찾을 수 있다.

### 평가 답변

> LEFT JOIN은 없는 데이터를 찾을 때도 유용합니다. 회원을 기준으로 대여 기록을 LEFT JOIN한 뒤 `r.rental_id IS NULL`을 조건으로 걸면 대여 기록이 없는 회원만 찾을 수 있습니다.

---

## 11. 예제 6 - 도서가 없는 카테고리 찾기

### SQL

```sql
SELECT c.category_id,
       c.name AS category_name
FROM category c
LEFT JOIN book b ON c.category_id = b.category_id
WHERE b.book_id IS NULL
ORDER BY c.category_id;
```

### 설명

> 모든 카테고리를 기준으로 도서를 붙인 뒤, 매칭되는 도서가 없는 카테고리만 찾는다.

### 평가 답변

> 카테고리는 존재하지만 그 카테고리에 등록된 도서가 없는 경우를 찾으려면 `category LEFT JOIN book` 후 `b.book_id IS NULL`을 사용합니다.

---

## 12. LEFT JOIN에서 WHERE 조건 주의

LEFT JOIN을 쓰고도 WHERE 조건을 잘못 쓰면 INNER JOIN처럼 동작할 수 있다.

### 12.1 위험한 예

```sql
SELECT m.member_id, m.name, r.rental_id, r.status
FROM member m
LEFT JOIN rental r ON m.member_id = r.member_id
WHERE r.status = 'RENTED';
```

문제:

> `r.status = 'RENTED'` 조건 때문에 `r.status`가 NULL인 회원은 결과에서 빠진다. 즉 대여 기록이 없는 회원을 포함하려던 LEFT JOIN의 장점이 사라진다.

---

### 12.2 조건을 ON에 넣는 방법

```sql
SELECT m.member_id, m.name, r.rental_id, r.status
FROM member m
LEFT JOIN rental r
    ON m.member_id = r.member_id
   AND r.status = 'RENTED'
ORDER BY m.member_id;
```

설명:

> 왼쪽의 모든 회원은 유지하고, 오른쪽 rental에서는 RENTED 상태인 기록만 붙인다. RENTED 기록이 없는 회원은 rental 컬럼이 NULL로 나온다.

평가 답변:

> LEFT JOIN에서 오른쪽 테이블 조건을 WHERE에 쓰면 NULL 행이 빠질 수 있습니다. 왼쪽 테이블을 유지해야 한다면 오른쪽 테이블 조건을 ON 절에 넣는 방식도 고려해야 합니다.

---

## 13. NULL 처리와 COALESCE

LEFT JOIN에서는 오른쪽 테이블에 매칭이 없으면 NULL이 나온다.

사용자에게 보여줄 때 NULL 대신 다른 값을 표시할 수 있다.

```sql
SELECT m.member_id,
       m.name,
       COALESCE(CAST(COUNT(r.rental_id) AS TEXT), '0') AS rental_count
FROM member m
LEFT JOIN rental r ON m.member_id = r.member_id
GROUP BY m.member_id, m.name
ORDER BY m.member_id;
```

문자열 값 예시:

```sql
SELECT m.member_id,
       m.name,
       COALESCE(r.status, 'NO_RENTAL') AS rental_status
FROM member m
LEFT JOIN rental r ON m.member_id = r.member_id
ORDER BY m.member_id, r.rental_id;
```

평가 답변:

> LEFT JOIN에서 매칭되는 오른쪽 데이터가 없으면 NULL이 나옵니다. 사용자에게 더 명확히 보여주고 싶으면 `COALESCE`로 NULL을 `NO_RENTAL` 같은 값으로 바꿀 수 있습니다.

---

## 14. LEFT JOIN과 GROUP BY 조합

LEFT JOIN은 집계에서 자주 사용한다.

### 14.1 회원별 대여 횟수

```sql
SELECT m.member_id, m.name, COUNT(r.rental_id) AS rental_count
FROM member m
LEFT JOIN rental r ON m.member_id = r.member_id
GROUP BY m.member_id, m.name
ORDER BY rental_count DESC;
```

### 14.2 카테고리별 도서 수

```sql
SELECT c.category_id, c.name, COUNT(b.book_id) AS book_count
FROM category c
LEFT JOIN book b ON c.category_id = b.category_id
GROUP BY c.category_id, c.name
ORDER BY book_count DESC;
```

### 14.3 도서별 대여 횟수

```sql
SELECT b.book_id, b.title, COUNT(r.rental_id) AS rental_count
FROM book b
LEFT JOIN rental r ON b.book_id = r.book_id
GROUP BY b.book_id, b.title
ORDER BY rental_count DESC;
```

평가 답변:

> LEFT JOIN과 GROUP BY를 함께 쓰면 0건까지 포함한 집계를 만들 수 있습니다. 이 프로젝트에서는 회원별 대여 횟수, 카테고리별 도서 수, 도서별 대여 횟수에 활용할 수 있습니다.

---

## 15. 직접 연습 문제

아래 쿼리를 직접 작성해본다.

```text
[ ] 1. 모든 회원과 대여 기록을 LEFT JOIN으로 조회한다.
[ ] 2. 회원별 대여 횟수를 0건 포함해 조회한다.
[ ] 3. 모든 카테고리와 도서 수를 조회한다.
[ ] 4. 모든 도서와 대여 횟수를 조회한다.
[ ] 5. 대여 기록이 없는 회원을 찾는다.
[ ] 6. 도서가 없는 카테고리를 찾는다.
[ ] 7. RENTED 상태 대여 기록만 붙이되 모든 회원을 유지한다.
[ ] 8. LEFT JOIN에서 COUNT(*)와 COUNT(r.rental_id)의 차이를 확인한다.
[ ] 9. NULL 상태를 COALESCE로 NO_RENTAL로 표시한다.
[ ] 10. 회원별 대여 횟수를 많은 순으로 정렬한다.
```

---

## 16. 정답 예시

### 16.1 모든 회원과 대여 기록

```sql
SELECT m.member_id, m.name, r.rental_id, r.rented_at, r.status
FROM member m
LEFT JOIN rental r ON m.member_id = r.member_id
ORDER BY m.member_id, r.rental_id;
```

### 16.2 회원별 대여 횟수

```sql
SELECT m.member_id, m.name, COUNT(r.rental_id) AS rental_count
FROM member m
LEFT JOIN rental r ON m.member_id = r.member_id
GROUP BY m.member_id, m.name
ORDER BY rental_count DESC, m.member_id ASC;
```

### 16.3 카테고리별 도서 수

```sql
SELECT c.category_id, c.name AS category_name, COUNT(b.book_id) AS book_count
FROM category c
LEFT JOIN book b ON c.category_id = b.category_id
GROUP BY c.category_id, c.name
ORDER BY book_count DESC, c.category_id ASC;
```

### 16.4 도서별 대여 횟수

```sql
SELECT b.book_id, b.title, COUNT(r.rental_id) AS rental_count
FROM book b
LEFT JOIN rental r ON b.book_id = r.book_id
GROUP BY b.book_id, b.title
ORDER BY rental_count DESC, b.book_id ASC;
```

### 16.5 대여 기록이 없는 회원

```sql
SELECT m.member_id, m.name, m.email
FROM member m
LEFT JOIN rental r ON m.member_id = r.member_id
WHERE r.rental_id IS NULL
ORDER BY m.member_id;
```

### 16.6 RENTED 기록만 붙이되 모든 회원 유지

```sql
SELECT m.member_id, m.name, r.rental_id, r.status
FROM member m
LEFT JOIN rental r
    ON m.member_id = r.member_id
   AND r.status = 'RENTED'
ORDER BY m.member_id, r.rental_id;
```

---

## 17. 자주 하는 실수

### 17.1 왼쪽 테이블을 반대로 두는 경우

```sql
-- 의도: 모든 회원을 보고 싶다.
-- 잘못된 방향
SELECT m.member_id, m.name, r.rental_id
FROM rental r
LEFT JOIN member m ON r.member_id = m.member_id;
```

문제:

> 왼쪽 테이블이 `rental`이므로 모든 대여 기록은 유지되지만, 대여 기록이 없는 회원은 나오지 않는다.

올바른 방향:

```sql
SELECT m.member_id, m.name, r.rental_id
FROM member m
LEFT JOIN rental r ON m.member_id = r.member_id;
```

---

### 17.2 COUNT(*)를 사용해 0건이 1로 나오는 경우

```sql
-- 주의
SELECT m.member_id, m.name, COUNT(*) AS rental_count
FROM member m
LEFT JOIN rental r ON m.member_id = r.member_id
GROUP BY m.member_id, m.name;
```

권장:

```sql
SELECT m.member_id, m.name, COUNT(r.rental_id) AS rental_count
FROM member m
LEFT JOIN rental r ON m.member_id = r.member_id
GROUP BY m.member_id, m.name;
```

---

### 17.3 오른쪽 테이블 조건을 WHERE에 넣어 NULL 행을 제거하는 경우

```sql
-- 대여 없는 회원이 빠질 수 있다.
SELECT m.member_id, m.name, r.status
FROM member m
LEFT JOIN rental r ON m.member_id = r.member_id
WHERE r.status = 'RENTED';
```

대안:

```sql
SELECT m.member_id, m.name, r.status
FROM member m
LEFT JOIN rental r
    ON m.member_id = r.member_id
   AND r.status = 'RENTED';
```

---

## 18. 평가 예상 질문과 답변

### 질문 1. LEFT JOIN은 무엇인가요?

> LEFT JOIN은 왼쪽 테이블의 모든 행을 유지하고, 오른쪽 테이블에서 매칭되는 행이 있으면 붙이고 없으면 NULL로 보여주는 JOIN입니다.

### 질문 2. INNER JOIN과 LEFT JOIN은 무엇이 다른가요?

> INNER JOIN은 양쪽에 매칭되는 행만 보여주지만, LEFT JOIN은 왼쪽 테이블의 모든 행을 유지합니다. 그래서 대여 기록이 없는 회원까지 보고 싶을 때는 LEFT JOIN을 사용합니다.

### 질문 3. 회원별 대여 횟수에서 왜 LEFT JOIN을 사용하나요?

> 대여 기록이 없는 회원도 0건으로 포함해야 하기 때문입니다. INNER JOIN을 사용하면 대여 기록이 없는 회원은 결과에서 빠집니다.

### 질문 4. LEFT JOIN에서 오른쪽 컬럼이 NULL인 것은 무엇을 뜻하나요?

> 왼쪽 테이블의 행은 존재하지만, 오른쪽 테이블에 연결되는 행이 없다는 뜻입니다. 예를 들어 `r.rental_id`가 NULL이면 해당 회원에게 대여 기록이 없다는 의미입니다.

### 질문 5. COUNT(*)와 COUNT(r.rental_id)는 왜 다른가요?

> LEFT JOIN 결과에서는 매칭이 없어도 왼쪽 행은 남기 때문에 `COUNT(*)`는 1로 셀 수 있습니다. 하지만 `COUNT(r.rental_id)`는 실제 대여 기록 ID가 있는 경우만 세므로 대여 기록이 없는 회원은 0으로 계산됩니다.

---

## 19. 30초 답변 연습

> LEFT JOIN은 왼쪽 테이블의 모든 행을 유지하고 오른쪽 테이블의 매칭 데이터를 붙이는 JOIN입니다. 매칭되는 오른쪽 데이터가 없으면 NULL로 표시됩니다. 이 프로젝트에서는 모든 회원을 기준으로 대여 기록을 붙여 회원별 대여 횟수를 구할 때 사용합니다. INNER JOIN을 쓰면 대여 기록이 없는 회원은 빠지지만, LEFT JOIN을 쓰면 대여 기록이 없는 회원도 0건으로 확인할 수 있습니다.

---

## 20. 오늘의 완료 기준

```text
[ ] LEFT JOIN을 한 문장으로 설명했다.
[ ] INNER JOIN과 LEFT JOIN의 차이를 설명했다.
[ ] member LEFT JOIN rental 쿼리를 직접 작성했다.
[ ] category LEFT JOIN book 쿼리를 직접 작성했다.
[ ] book LEFT JOIN rental 쿼리를 직접 작성했다.
[ ] 대여 기록이 없는 회원 찾기 쿼리를 작성했다.
[ ] COUNT(*)와 COUNT(r.rental_id)의 차이를 설명했다.
[ ] 오른쪽 테이블 조건을 WHERE에 넣을 때의 위험을 설명했다.
[ ] 30초 답변을 소리 내어 연습했다.
```
