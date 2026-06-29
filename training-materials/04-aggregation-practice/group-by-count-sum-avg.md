# GROUP BY / COUNT / SUM / AVG 집계 훈련

이 문서는 B5-1 도서 대여 관리 DB를 기준으로 `GROUP BY`, `COUNT`, `SUM`, `AVG`를 반복 훈련하기 위한 문서이다.

평가에서는 집계 함수를 단순히 쓰는 것보다, **무엇을 기준으로 묶는지**, **각 그룹별로 무엇을 계산하는지**, **JOIN 후 GROUP BY를 왜 사용하는지**, **WHERE와 HAVING의 차이가 무엇인지**를 설명할 수 있어야 한다.

---

## 1. 한 줄 요약

```text
GROUP BY는 같은 기준의 행을 묶고, COUNT/SUM/AVG는 묶인 그룹별 개수·합계·평균을 계산한다.
```

평가 답변:

> `GROUP BY`는 같은 기준의 행을 하나의 그룹으로 묶는 절입니다. 예를 들어 회원별로 대여 기록을 묶으면 회원별 대여 횟수를 `COUNT`로 계산할 수 있고, 카테고리별로 도서를 묶으면 평균 가격을 `AVG`로 계산할 수 있습니다.

---

## 2. 기본 문법

```sql
SELECT 그룹기준컬럼,
       집계함수(계산대상컬럼) AS 별칭
FROM 테이블명
WHERE 행_필터조건
GROUP BY 그룹기준컬럼
HAVING 그룹_필터조건
ORDER BY 정렬기준;
```

실행 흐름:

```text
1. FROM       → 데이터를 가져올 테이블을 정한다.
2. JOIN       → 필요한 테이블을 연결한다.
3. WHERE      → 그룹으로 묶기 전 행을 필터링한다.
4. GROUP BY   → 남은 행을 기준 컬럼으로 묶는다.
5. 집계 함수  → 그룹별 값을 계산한다.
6. HAVING     → 집계 결과를 기준으로 그룹을 필터링한다.
7. ORDER BY   → 최종 결과를 정렬한다.
```

---

## 3. 집계 함수 기본

| 함수 | 의미 | B5-1 예시 |
|---|---|---|
| `COUNT(*)` | 행 개수 | 대여 상태별 건수 |
| `COUNT(r.rental_id)` | NULL이 아닌 대여 ID 개수 | 회원별 대여 횟수 |
| `SUM(rental_fee)` | 합계 | 회원별 수수료 합계 |
| `AVG(price)` | 평균 | 카테고리별 평균 도서 가격 |
| `MIN(due_date)` | 최솟값 | 가장 빠른 반납기한 |
| `MAX(price)` | 최댓값 | 카테고리별 최고가 도서 가격 |

평가 답변:

> `COUNT`는 개수, `SUM`은 합계, `AVG`는 평균을 계산합니다. `GROUP BY`와 함께 쓰면 전체가 아니라 그룹별 계산 결과를 얻을 수 있습니다.

---

## 4. COUNT 기본 예제

### 4.1 전체 대여 기록 수

```sql
SELECT COUNT(*) AS rental_count
FROM rental;
```

설명:

> `rental` 테이블의 전체 행 수를 계산한다.

---

### 4.2 대여 상태별 건수

```sql
SELECT status,
       COUNT(*) AS rental_count
FROM rental
GROUP BY status
ORDER BY rental_count DESC;
```

설명:

> `status` 값이 같은 대여 기록을 묶고, 상태별 대여 건수를 계산한다.

평가 답변:

> 상태별 대여 건수를 보려면 `status`로 `GROUP BY`하고 각 그룹의 행 수를 `COUNT(*)`로 계산합니다.

---

## 5. SUM 기본 예제

### 5.1 전체 수수료 합계

```sql
SELECT SUM(rental_fee) AS total_fee
FROM rental;
```

설명:

> 모든 대여 기록의 수수료 합계를 계산한다.

---

### 5.2 상태별 수수료 합계

```sql
SELECT status,
       COUNT(*) AS rental_count,
       SUM(rental_fee) AS total_fee
FROM rental
GROUP BY status
ORDER BY total_fee DESC;
```

설명:

> 상태별 대여 건수와 수수료 합계를 함께 계산한다.

평가 답변:

> `SUM`은 숫자 컬럼의 합계를 계산합니다. 이 프로젝트에서는 `rental_fee`를 합산해 상태별 또는 회원별 수수료 합계를 구할 수 있습니다.

---

## 6. AVG 기본 예제

### 6.1 전체 도서 평균 가격

```sql
SELECT AVG(price) AS avg_price
FROM book;
```

설명:

> 전체 도서의 평균 가격을 계산한다.

---

### 6.2 카테고리별 평균 도서 가격

```sql
SELECT c.category_id,
       c.name AS category_name,
       COUNT(b.book_id) AS book_count,
       AVG(b.price) AS avg_price
FROM category c
INNER JOIN book b ON c.category_id = b.category_id
GROUP BY c.category_id, c.name
ORDER BY avg_price DESC;
```

설명:

> 카테고리별로 도서를 묶고, 각 카테고리의 도서 수와 평균 가격을 계산한다.

평가 답변:

> 카테고리별 평균 가격을 구하려면 `category`와 `book`을 JOIN한 뒤 카테고리 기준으로 `GROUP BY`하고 `AVG(book.price)`를 계산합니다.

---

## 7. JOIN + GROUP BY 기본 패턴

정규화된 DB에서는 집계 전에 JOIN이 필요한 경우가 많다.

예를 들어 회원별 대여 횟수를 구하려면:

```text
member 테이블: 회원 이름
rental 테이블: 대여 기록
```

두 테이블을 연결해야 한다.

```sql
SELECT m.member_id,
       m.name AS member_name,
       COUNT(r.rental_id) AS rental_count
FROM member m
INNER JOIN rental r ON m.member_id = r.member_id
GROUP BY m.member_id, m.name
ORDER BY rental_count DESC;
```

평가 답변:

> 회원명은 `member`에 있고 대여 기록은 `rental`에 있으므로 먼저 JOIN합니다. 그 다음 회원별로 `GROUP BY`해서 `COUNT(r.rental_id)`로 대여 횟수를 계산합니다.

---

## 8. 예제 1 - 회원별 대여 횟수와 수수료 합계

### SQL

```sql
SELECT m.member_id,
       m.name AS member_name,
       COUNT(r.rental_id) AS rental_count,
       SUM(r.rental_fee) AS total_fee
FROM member m
INNER JOIN rental r ON m.member_id = r.member_id
GROUP BY m.member_id, m.name
ORDER BY rental_count DESC, total_fee DESC;
```

### 설명

> `member`와 `rental`을 연결한 뒤 회원별로 묶어 대여 횟수와 수수료 합계를 계산한다.

### 평가 답변

> 이 쿼리는 회원별 활동량을 보는 집계 쿼리입니다. 회원별 대여 횟수는 `COUNT`, 수수료 합계는 `SUM`으로 계산했습니다.

---

## 9. 예제 2 - 회원별 대여 횟수, 0건 포함

### SQL

```sql
SELECT m.member_id,
       m.name AS member_name,
       COUNT(r.rental_id) AS rental_count,
       COALESCE(SUM(r.rental_fee), 0) AS total_fee
FROM member m
LEFT JOIN rental r ON m.member_id = r.member_id
GROUP BY m.member_id, m.name
ORDER BY rental_count DESC, m.member_id ASC;
```

### 설명

> `LEFT JOIN`을 사용해 대여 기록이 없는 회원도 결과에 포함한다. `SUM` 결과가 NULL이면 `COALESCE`로 0으로 바꾼다.

### 평가 답변

> 0건인 회원까지 포함하려면 INNER JOIN이 아니라 LEFT JOIN을 사용해야 합니다. 대여 기록이 없으면 수수료 합계가 NULL이 될 수 있으므로 `COALESCE`로 0 처리했습니다.

---

## 10. 예제 3 - 카테고리별 도서 수와 평균 가격

### SQL

```sql
SELECT c.category_id,
       c.name AS category_name,
       COUNT(b.book_id) AS book_count,
       AVG(b.price) AS avg_price,
       MIN(b.price) AS min_price,
       MAX(b.price) AS max_price
FROM category c
LEFT JOIN book b ON c.category_id = b.category_id
GROUP BY c.category_id, c.name
ORDER BY book_count DESC, avg_price DESC;
```

### 설명

> 카테고리별 도서 수, 평균 가격, 최저 가격, 최고 가격을 계산한다.

### 평가 답변

> 카테고리별 도서 통계를 보려면 `category`와 `book`을 연결하고 카테고리 기준으로 묶습니다. `COUNT`로 도서 수, `AVG`로 평균 가격을 계산합니다.

---

## 11. 예제 4 - 대여 상태별 건수와 수수료 합계

### SQL

```sql
SELECT status,
       COUNT(*) AS rental_count,
       SUM(rental_fee) AS total_fee,
       AVG(rental_fee) AS avg_fee
FROM rental
GROUP BY status
ORDER BY rental_count DESC;
```

### 설명

> 대여 상태별로 행을 묶어 건수, 수수료 합계, 평균 수수료를 계산한다.

### 평가 답변

> `rental.status`로 그룹을 만들면 대여 중, 반납 완료, 연체 같은 상태별 현황을 집계할 수 있습니다.

---

## 12. 예제 5 - 월별 대여 건수

SQLite에서 `YYYY-MM-DD` 문자열의 앞 7자리를 자르면 월 단위가 된다.

### SQL

```sql
SELECT substr(rented_at, 1, 7) AS rental_month,
       COUNT(*) AS rental_count
FROM rental
GROUP BY substr(rented_at, 1, 7)
ORDER BY rental_month ASC;
```

### 설명

> `rented_at`의 앞 7자리인 `YYYY-MM`을 기준으로 묶어 월별 대여 건수를 계산한다.

### 평가 답변

> 날짜가 `YYYY-MM-DD` 형식이면 `substr(rented_at, 1, 7)`로 월 정보를 뽑아 월별 대여 건수를 집계할 수 있습니다.

---

## 13. 예제 6 - 인기 도서 TOP 5

### SQL

```sql
SELECT b.book_id,
       b.title,
       COUNT(r.rental_id) AS rental_count
FROM book b
INNER JOIN rental r ON b.book_id = r.book_id
GROUP BY b.book_id, b.title
ORDER BY rental_count DESC, b.book_id ASC
LIMIT 5;
```

### 설명

> 도서별 대여 횟수를 계산한 뒤 대여 횟수가 높은 순으로 상위 5권을 조회한다.

### 평가 답변

> 인기 도서는 도서별 대여 횟수를 기준으로 판단할 수 있습니다. `book`과 `rental`을 JOIN하고 도서별로 GROUP BY한 뒤 COUNT로 대여 횟수를 계산했습니다.

---

## 14. WHERE와 HAVING 차이

| 구분 | WHERE | HAVING |
|---|---|---|
| 적용 시점 | GROUP BY 전 | GROUP BY 후 |
| 필터 대상 | 개별 행 | 집계된 그룹 |
| 예시 | `status = 'RENTED'` | `COUNT(*) >= 2` |

---

### 14.1 WHERE 예시

```sql
SELECT status,
       COUNT(*) AS rental_count
FROM rental
WHERE rental_fee > 0
GROUP BY status;
```

설명:

> 수수료가 0보다 큰 행만 먼저 남긴 뒤 상태별로 묶는다.

---

### 14.2 HAVING 예시

```sql
SELECT m.member_id,
       m.name,
       COUNT(r.rental_id) AS rental_count
FROM member m
INNER JOIN rental r ON m.member_id = r.member_id
GROUP BY m.member_id, m.name
HAVING COUNT(r.rental_id) >= 2
ORDER BY rental_count DESC;
```

설명:

> 회원별로 먼저 대여 횟수를 계산한 뒤, 대여 횟수가 2건 이상인 회원만 남긴다.

평가 답변:

> `WHERE`는 그룹을 만들기 전 개별 행을 필터링하고, `HAVING`은 GROUP BY 이후 집계 결과를 기준으로 그룹을 필터링합니다.

---

## 15. GROUP BY에서 컬럼을 함께 적는 이유

다음 쿼리에서 `GROUP BY m.member_id, m.name`을 사용한다.

```sql
SELECT m.member_id,
       m.name,
       COUNT(r.rental_id) AS rental_count
FROM member m
INNER JOIN rental r ON m.member_id = r.member_id
GROUP BY m.member_id, m.name;
```

이유:

```text
member_id별로 묶으면서 결과에 name도 함께 보여주기 위해서다.
같은 member_id는 하나의 name을 갖기 때문에 같이 묶어도 의미가 유지된다.
```

평가 답변:

> SELECT에 집계 함수가 아닌 컬럼을 함께 출력하려면 그 컬럼을 GROUP BY에 포함해야 합니다. 그래서 회원 ID와 회원명을 함께 출력할 때 `GROUP BY m.member_id, m.name`을 사용했습니다.

---

## 16. COUNT(*)와 COUNT(컬럼)의 차이

| 표현 | 의미 | LEFT JOIN에서의 차이 |
|---|---|---|
| `COUNT(*)` | 결과 행 전체 개수 | 매칭이 없어도 왼쪽 행을 1로 셀 수 있음 |
| `COUNT(r.rental_id)` | `rental_id`가 NULL이 아닌 행 개수 | 대여 기록이 없으면 0으로 셈 |

예시:

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

평가 답변:

> LEFT JOIN에서 0건을 정확히 계산하려면 `COUNT(*)`보다 오른쪽 테이블의 PK인 `COUNT(r.rental_id)`를 사용하는 것이 안전합니다.

---

## 17. 직접 연습 문제

아래 쿼리를 직접 작성해본다.

```text
[ ] 1. 전체 대여 기록 수를 계산한다.
[ ] 2. 대여 상태별 건수를 계산한다.
[ ] 3. 대여 상태별 수수료 합계를 계산한다.
[ ] 4. 회원별 대여 횟수를 계산한다.
[ ] 5. 회원별 수수료 합계를 계산한다.
[ ] 6. 대여 기록이 없는 회원도 포함해 회원별 대여 횟수를 계산한다.
[ ] 7. 카테고리별 도서 수를 계산한다.
[ ] 8. 카테고리별 평균 도서 가격을 계산한다.
[ ] 9. 월별 대여 건수를 계산한다.
[ ] 10. 대여 횟수 2건 이상인 회원만 HAVING으로 조회한다.
```

---

## 18. 정답 예시

### 18.1 전체 대여 기록 수

```sql
SELECT COUNT(*) AS rental_count
FROM rental;
```

### 18.2 대여 상태별 건수

```sql
SELECT status, COUNT(*) AS rental_count
FROM rental
GROUP BY status
ORDER BY rental_count DESC;
```

### 18.3 회원별 대여 횟수

```sql
SELECT m.member_id, m.name, COUNT(r.rental_id) AS rental_count
FROM member m
INNER JOIN rental r ON m.member_id = r.member_id
GROUP BY m.member_id, m.name
ORDER BY rental_count DESC;
```

### 18.4 카테고리별 평균 도서 가격

```sql
SELECT c.category_id, c.name AS category_name, AVG(b.price) AS avg_price
FROM category c
INNER JOIN book b ON c.category_id = b.category_id
GROUP BY c.category_id, c.name
ORDER BY avg_price DESC;
```

### 18.5 월별 대여 건수

```sql
SELECT substr(rented_at, 1, 7) AS rental_month, COUNT(*) AS rental_count
FROM rental
GROUP BY substr(rented_at, 1, 7)
ORDER BY rental_month ASC;
```

### 18.6 HAVING으로 대여 2건 이상 회원 조회

```sql
SELECT m.member_id, m.name, COUNT(r.rental_id) AS rental_count
FROM member m
INNER JOIN rental r ON m.member_id = r.member_id
GROUP BY m.member_id, m.name
HAVING COUNT(r.rental_id) >= 2
ORDER BY rental_count DESC;
```

---

## 19. 자주 하는 실수

### 19.1 GROUP BY 없이 일반 컬럼과 집계 함수를 함께 쓰는 경우

```sql
-- 잘못된 예
SELECT status, COUNT(*)
FROM rental;
```

권장:

```sql
SELECT status, COUNT(*) AS rental_count
FROM rental
GROUP BY status;
```

---

### 19.2 WHERE에 집계 조건을 쓰는 경우

```sql
-- 잘못된 예
SELECT member_id, COUNT(*) AS rental_count
FROM rental
WHERE COUNT(*) >= 2
GROUP BY member_id;
```

권장:

```sql
SELECT member_id, COUNT(*) AS rental_count
FROM rental
GROUP BY member_id
HAVING COUNT(*) >= 2;
```

---

### 19.3 LEFT JOIN에서 COUNT(*)로 0건을 잘못 계산하는 경우

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

## 20. 평가 예상 질문과 답변

### 질문 1. GROUP BY는 무엇인가요?

> GROUP BY는 같은 기준의 행을 묶는 절입니다. 예를 들어 회원별로 대여 기록을 묶으면 회원별 대여 횟수를 계산할 수 있습니다.

### 질문 2. COUNT, SUM, AVG는 각각 무엇인가요?

> COUNT는 개수, SUM은 합계, AVG는 평균을 계산합니다. GROUP BY와 함께 쓰면 그룹별 개수, 합계, 평균을 구할 수 있습니다.

### 질문 3. WHERE와 HAVING은 무엇이 다른가요?

> WHERE는 GROUP BY 전에 개별 행을 필터링하고, HAVING은 GROUP BY 후 집계 결과를 기준으로 그룹을 필터링합니다.

### 질문 4. 회원별 대여 횟수는 어떻게 구했나요?

> `member`와 `rental`을 JOIN한 뒤 `member_id`, `name`으로 GROUP BY하고 `COUNT(r.rental_id)`로 회원별 대여 횟수를 계산했습니다.

### 질문 5. 카테고리별 평균 가격은 어떻게 구했나요?

> `category`와 `book`을 JOIN한 뒤 카테고리 기준으로 GROUP BY하고 `AVG(book.price)`로 카테고리별 평균 가격을 계산했습니다.

---

## 21. 30초 답변 연습

> GROUP BY는 같은 기준의 행을 묶고, COUNT, SUM, AVG는 묶인 그룹별 개수, 합계, 평균을 계산합니다. 이 프로젝트에서는 회원별 대여 횟수를 구할 때 `member`와 `rental`을 JOIN하고 회원별로 GROUP BY한 뒤 `COUNT(r.rental_id)`를 사용했습니다. 카테고리별 평균 가격은 `category`와 `book`을 JOIN하고 카테고리별로 GROUP BY한 뒤 `AVG(b.price)`로 계산했습니다.

---

## 22. 오늘의 완료 기준

```text
[ ] GROUP BY를 한 문장으로 설명했다.
[ ] COUNT, SUM, AVG 차이를 설명했다.
[ ] 상태별 대여 건수를 작성했다.
[ ] 회원별 대여 횟수를 작성했다.
[ ] 회원별 수수료 합계를 작성했다.
[ ] 카테고리별 도서 수를 작성했다.
[ ] 카테고리별 평균 가격을 작성했다.
[ ] 월별 대여 건수를 작성했다.
[ ] WHERE와 HAVING 차이를 설명했다.
[ ] COUNT(*)와 COUNT(r.rental_id) 차이를 설명했다.
[ ] 30초 답변을 소리 내어 연습했다.
```
