# 랭킹 쿼리 훈련

이 문서는 B5-1 도서 대여 관리 DB를 기준으로 가격 순위, 인기 도서 순위, 회원별 대여 순위, 카테고리별 통계 순위를 작성하는 훈련 문서이다.

평가에서는 `ORDER BY`와 `LIMIT`만 쓰는 것이 아니라, **무엇을 기준으로 순위를 매겼는지**, **동점이 있을 때 어떻게 정렬했는지**, **GROUP BY 결과를 다시 정렬해 TOP N을 뽑는 흐름**을 설명할 수 있어야 한다.

---

## 1. 한 줄 요약

```text
랭킹 쿼리는 ORDER BY로 순위를 정하고, LIMIT으로 상위 N개만 선택하는 쿼리다.
GROUP BY 결과에도 ORDER BY와 LIMIT을 붙이면 인기 도서, 회원별 대여 순위 같은 지표를 만들 수 있다.
```

평가 답변:

> 랭킹 쿼리는 기준 컬럼이나 집계 결과를 정렬해서 상위 데이터를 찾는 쿼리입니다. 예를 들어 도서별 대여 횟수를 `COUNT`로 계산한 뒤 `ORDER BY rental_count DESC LIMIT 5`를 사용하면 인기 도서 TOP 5를 구할 수 있습니다.

---

## 2. 기본 패턴

### 2.1 단순 TOP N

```sql
SELECT 컬럼목록
FROM 테이블명
ORDER BY 순위기준컬럼 DESC
LIMIT N;
```

예:

```sql
SELECT book_id, title, price
FROM book
ORDER BY price DESC
LIMIT 5;
```

설명:

> 가격이 높은 순으로 정렬하고 상위 5권만 조회한다.

---

### 2.2 GROUP BY 후 TOP N

```sql
SELECT 그룹기준컬럼,
       COUNT(*) AS count_value
FROM 테이블명
GROUP BY 그룹기준컬럼
ORDER BY count_value DESC
LIMIT N;
```

예:

```sql
SELECT book_id,
       COUNT(*) AS rental_count
FROM rental
GROUP BY book_id
ORDER BY rental_count DESC
LIMIT 5;
```

설명:

> 도서별 대여 횟수를 계산한 뒤 대여 횟수가 많은 상위 5개 도서를 조회한다.

---

## 3. ASC와 DESC

| 정렬 | 의미 | 사용 예 |
|---|---|---|
| `ASC` | 오름차순, 작은 값부터 | 낮은 가격순, 빠른 날짜순 |
| `DESC` | 내림차순, 큰 값부터 | 높은 가격순, 많은 대여순 |

예시:

```sql
-- 가격 높은 순
SELECT book_id, title, price
FROM book
ORDER BY price DESC;
```

```sql
-- 가격 낮은 순
SELECT book_id, title, price
FROM book
ORDER BY price ASC;
```

평가 답변:

> 랭킹에서 큰 값이 높은 순위라면 `DESC`를 사용하고, 낮은 가격이나 빠른 날짜처럼 작은 값이 앞에 와야 하면 `ASC`를 사용합니다.

---

## 4. 동점 처리와 보조 정렬

랭킹 쿼리에서는 같은 값이 나올 수 있다.

예:

```text
A 도서 대여 3회
B 도서 대여 3회
```

이때 정렬 결과가 매번 안정적으로 보이게 하려면 보조 정렬을 추가한다.

```sql
ORDER BY rental_count DESC, b.book_id ASC;
```

의미:

```text
1차 기준: 대여 횟수 많은 순
2차 기준: 대여 횟수가 같으면 book_id 작은 순
```

평가 답변:

> 순위 기준 값이 같을 수 있으므로 보조 정렬을 추가했습니다. 예를 들어 대여 횟수가 같으면 `book_id ASC`로 정렬해 결과 순서를 안정적으로 만들었습니다.

---

## 5. 예제 1 - 가격이 가장 높은 도서 TOP 5

### SQL

```sql
SELECT book_id,
       title,
       author,
       price
FROM book
ORDER BY price DESC, book_id ASC
LIMIT 5;
```

### 설명

> 도서를 가격 높은 순으로 정렬하고, 가격이 같으면 `book_id` 작은 순으로 정렬한 뒤 상위 5권만 조회한다.

### 평가 답변

> 가격 랭킹은 `book.price`를 기준으로 `ORDER BY price DESC`를 사용합니다. 동점 가격이 있을 수 있으므로 `book_id ASC`를 보조 정렬로 추가했습니다.

---

## 6. 예제 2 - 가격이 가장 낮은 도서 TOP 5

### SQL

```sql
SELECT book_id,
       title,
       author,
       price
FROM book
ORDER BY price ASC, book_id ASC
LIMIT 5;
```

### 설명

> 도서를 가격 낮은 순으로 정렬하고 상위 5권을 조회한다.

평가 답변:

> 낮은 가격순 랭킹은 작은 값이 먼저 와야 하므로 `ORDER BY price ASC`를 사용합니다.

---

## 7. 예제 3 - 최근 등록 도서 TOP 5

### SQL

```sql
SELECT book_id,
       title,
       created_at
FROM book
ORDER BY created_at DESC, book_id DESC
LIMIT 5;
```

### 설명

> 등록일이 최신인 도서부터 정렬하고 상위 5권을 조회한다.

평가 답변:

> 날짜 랭킹에서 최신순은 날짜 값이 큰 것이 앞에 와야 하므로 `ORDER BY created_at DESC`를 사용합니다.

---

## 8. 예제 4 - 인기 도서 TOP 5

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

> `book`과 `rental`을 JOIN한 뒤 도서별로 묶어 대여 횟수를 계산한다. 이후 대여 횟수가 많은 순으로 TOP 5를 조회한다.

### 평가 답변

> 인기 도서는 도서별 대여 횟수로 판단했습니다. `book`과 `rental`을 JOIN하고 도서별로 `GROUP BY`한 뒤 `COUNT(r.rental_id)`를 계산해 대여 횟수 순으로 정렬했습니다.

---

## 9. 예제 5 - 모든 도서를 포함한 대여 횟수 순위

아직 대여된 적 없는 도서도 포함하려면 `LEFT JOIN`을 사용한다.

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

> 모든 도서를 유지하면서 대여 횟수를 계산한다. 대여 기록이 없는 도서는 `COUNT(r.rental_id)`가 0이 된다.

### 평가 답변

> 대여된 적 없는 도서까지 포함하려면 `INNER JOIN`이 아니라 `LEFT JOIN`을 사용해야 합니다. 그리고 0건 계산을 위해 `COUNT(r.rental_id)`를 사용했습니다.

---

## 10. 예제 6 - 회원별 대여 횟수 TOP 5

### SQL

```sql
SELECT m.member_id,
       m.name AS member_name,
       COUNT(r.rental_id) AS rental_count
FROM member m
INNER JOIN rental r ON m.member_id = r.member_id
GROUP BY m.member_id, m.name
ORDER BY rental_count DESC, m.member_id ASC
LIMIT 5;
```

### 설명

> 회원별 대여 횟수를 계산하고 대여 횟수가 많은 상위 5명을 조회한다.

### 평가 답변

> 회원별 대여 순위는 `member`와 `rental`을 JOIN하고 회원별로 GROUP BY한 뒤 `COUNT(r.rental_id)`를 기준으로 정렬했습니다.

---

## 11. 예제 7 - 회원별 수수료 합계 TOP 5

### SQL

```sql
SELECT m.member_id,
       m.name AS member_name,
       COUNT(r.rental_id) AS rental_count,
       SUM(r.rental_fee) AS total_fee
FROM member m
INNER JOIN rental r ON m.member_id = r.member_id
GROUP BY m.member_id, m.name
ORDER BY total_fee DESC, rental_count DESC, m.member_id ASC
LIMIT 5;
```

### 설명

> 회원별 수수료 합계를 계산하고, 수수료 합계가 큰 순으로 상위 5명을 조회한다.

평가 답변:

> 수수료 순위는 회원별 `SUM(rental_fee)`를 계산한 뒤 `ORDER BY total_fee DESC`로 정렬했습니다. 동점이면 대여 횟수와 회원 ID를 보조 정렬로 사용했습니다.

---

## 12. 예제 8 - 카테고리별 도서 수 순위

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

> 카테고리별 도서 수를 계산하고 도서 수가 많은 순으로 정렬한다.

평가 답변:

> 카테고리별 도서 수 순위는 `category`와 `book`을 LEFT JOIN한 뒤 카테고리별로 GROUP BY하고 `COUNT(b.book_id)`로 계산했습니다.

---

## 13. 예제 9 - 카테고리별 평균 가격 순위

### SQL

```sql
SELECT c.category_id,
       c.name AS category_name,
       COUNT(b.book_id) AS book_count,
       AVG(b.price) AS avg_price
FROM category c
INNER JOIN book b ON c.category_id = b.category_id
GROUP BY c.category_id, c.name
ORDER BY avg_price DESC, c.category_id ASC;
```

### 설명

> 카테고리별 도서 평균 가격을 계산하고 평균 가격이 높은 순으로 정렬한다.

평가 답변:

> 카테고리별 평균 가격 순위는 `AVG(b.price)`를 기준으로 정렬합니다. 카테고리명은 `category`, 가격은 `book`에 있으므로 두 테이블을 JOIN했습니다.

---

## 14. 예제 10 - 월별 대여 건수 순위

### SQL

```sql
SELECT substr(rented_at, 1, 7) AS rental_month,
       COUNT(*) AS rental_count
FROM rental
GROUP BY substr(rented_at, 1, 7)
ORDER BY rental_count DESC, rental_month ASC;
```

### 설명

> 월별 대여 건수를 계산하고 대여 건수가 많은 월부터 조회한다.

평가 답변:

> `rented_at`이 `YYYY-MM-DD` 형식이므로 `substr(rented_at, 1, 7)`로 월을 추출했습니다. 그 값을 기준으로 GROUP BY하고 COUNT로 월별 대여 건수를 계산했습니다.

---

## 15. 예제 11 - 연체 수수료가 높은 대여 기록 TOP 5

### SQL

```sql
SELECT r.rental_id,
       m.name AS member_name,
       b.title AS book_title,
       r.due_date,
       r.status,
       r.rental_fee
FROM rental r
INNER JOIN member m ON r.member_id = m.member_id
INNER JOIN book b ON r.book_id = b.book_id
WHERE r.rental_fee > 0
ORDER BY r.rental_fee DESC, r.due_date ASC, r.rental_id ASC
LIMIT 5;
```

### 설명

> 수수료가 있는 대여 기록만 필터링한 뒤 수수료가 높은 순으로 상위 5건을 조회한다.

평가 답변:

> 수수료 랭킹은 먼저 `WHERE rental_fee > 0`으로 수수료가 있는 행만 남기고, `ORDER BY rental_fee DESC`로 높은 수수료 순으로 정렬했습니다.

---

## 16. 윈도우 함수 기반 순위

`ORDER BY + LIMIT`은 상위 N개를 뽑는 데 충분하다. 하지만 각 행에 순위 번호를 붙이고 싶으면 윈도우 함수를 사용할 수 있다.

대표 함수:

| 함수 | 의미 |
|---|---|
| `ROW_NUMBER()` | 정렬 순서대로 1, 2, 3을 붙인다. 동점도 서로 다른 번호를 준다. |
| `RANK()` | 동점은 같은 순위, 다음 순위는 건너뛴다. |
| `DENSE_RANK()` | 동점은 같은 순위, 다음 순위를 건너뛰지 않는다. |

---

## 17. 예제 12 - 가격 순위 번호 붙이기

### SQL

```sql
SELECT book_id,
       title,
       price,
       ROW_NUMBER() OVER (ORDER BY price DESC, book_id ASC) AS price_row_number,
       RANK() OVER (ORDER BY price DESC) AS price_rank,
       DENSE_RANK() OVER (ORDER BY price DESC) AS price_dense_rank
FROM book
ORDER BY price DESC, book_id ASC;
```

### 설명

> 각 도서에 가격 기준 순위 번호를 붙인다. `ROW_NUMBER`, `RANK`, `DENSE_RANK`의 동점 처리 차이를 비교할 수 있다.

평가 답변:

> 단순 TOP N은 `ORDER BY LIMIT`으로 충분하지만, 각 행에 순위 번호를 붙이려면 윈도우 함수를 사용할 수 있습니다. 동점 처리 방식에 따라 `ROW_NUMBER`, `RANK`, `DENSE_RANK`를 선택합니다.

---

## 18. 예제 13 - 카테고리 안에서 가격 순위 매기기

### SQL

```sql
SELECT c.name AS category_name,
       b.book_id,
       b.title,
       b.price,
       ROW_NUMBER() OVER (
           PARTITION BY c.category_id
           ORDER BY b.price DESC, b.book_id ASC
       ) AS price_rank_in_category
FROM book b
INNER JOIN category c ON b.category_id = c.category_id
ORDER BY c.name ASC, price_rank_in_category ASC;
```

### 설명

> `PARTITION BY c.category_id`로 카테고리별 그룹을 나눈 뒤, 각 카테고리 안에서 가격 높은 순으로 순위를 매긴다.

평가 답변:

> 전체 순위가 아니라 카테고리 내부 순위를 구하려면 `PARTITION BY`를 사용합니다. 이 쿼리는 카테고리별로 도서를 나누고, 각 카테고리 안에서 가격 순위를 계산합니다.

---

## 19. 예제 14 - 카테고리별 최고가 도서만 조회

윈도우 함수 결과를 바깥 쿼리에서 필터링한다.

### SQL

```sql
SELECT category_name,
       book_id,
       title,
       price
FROM (
    SELECT c.name AS category_name,
           b.book_id,
           b.title,
           b.price,
           ROW_NUMBER() OVER (
               PARTITION BY c.category_id
               ORDER BY b.price DESC, b.book_id ASC
           ) AS rn
    FROM book b
    INNER JOIN category c ON b.category_id = c.category_id
) ranked_books
WHERE rn = 1
ORDER BY category_name ASC;
```

### 설명

> 각 카테고리 안에서 가격 1위인 도서만 조회한다.

평가 답변:

> 카테고리별 TOP 1을 뽑기 위해 먼저 카테고리 내부 가격 순위를 계산하고, 바깥 쿼리에서 `rn = 1`인 행만 남겼습니다.

---

## 20. ORDER BY LIMIT과 윈도우 함수 비교

| 구분 | ORDER BY + LIMIT | 윈도우 함수 |
|---|---|---|
| 목적 | 상위 N개만 빠르게 조회 | 각 행에 순위 번호 부여 |
| 결과 | N개 행만 표시 | 전체 행 또는 그룹별 순위 표시 |
| 동점 처리 | 보조 정렬로 안정화 | RANK/DENSE_RANK로 명시 가능 |
| B5-1 추천 | 기본 랭킹 쿼리에 적합 | 추가 설명/심화 훈련에 적합 |

평가 답변:

> 기본 평가에서는 `ORDER BY`와 `LIMIT`으로 TOP N을 설명하면 충분합니다. 다만 순위 번호를 컬럼으로 보여주거나 그룹별 순위를 계산하려면 윈도우 함수를 사용할 수 있습니다.

---

## 21. 직접 연습 문제

아래 쿼리를 직접 작성해본다.

```text
[ ] 1. 가격이 높은 도서 TOP 5를 조회한다.
[ ] 2. 가격이 낮은 도서 TOP 5를 조회한다.
[ ] 3. 최근 등록 도서 TOP 5를 조회한다.
[ ] 4. 인기 도서 TOP 5를 조회한다.
[ ] 5. 회원별 대여 횟수 TOP 5를 조회한다.
[ ] 6. 회원별 수수료 합계 TOP 5를 조회한다.
[ ] 7. 카테고리별 도서 수 순위를 조회한다.
[ ] 8. 카테고리별 평균 가격 순위를 조회한다.
[ ] 9. 월별 대여 건수 순위를 조회한다.
[ ] 10. 연체 수수료가 높은 대여 기록 TOP 5를 조회한다.
[ ] 11. ROW_NUMBER로 도서 가격 순위를 붙인다.
[ ] 12. 카테고리별 최고가 도서를 조회한다.
```

---

## 22. 자주 하는 실수

### 22.1 ORDER BY 없이 LIMIT만 쓰는 경우

```sql
-- 잘못된 예
SELECT book_id, title, price
FROM book
LIMIT 5;
```

문제:

> 정렬 기준이 없으므로 TOP 5라고 말할 수 없다.

권장:

```sql
SELECT book_id, title, price
FROM book
ORDER BY price DESC, book_id ASC
LIMIT 5;
```

---

### 22.2 GROUP BY 전에 LIMIT을 생각하는 경우

잘못된 사고:

```text
먼저 5개만 자르고 그 안에서 대여 횟수를 세자.
```

올바른 사고:

```text
1. 전체 대여 기록을 도서별로 묶는다.
2. 도서별 대여 횟수를 계산한다.
3. 대여 횟수 높은 순으로 정렬한다.
4. 상위 5개만 자른다.
```

---

### 22.3 집계 별칭을 잘못 사용하는 경우

SQLite에서는 다음처럼 별칭 정렬이 가능하다.

```sql
SELECT b.book_id,
       b.title,
       COUNT(r.rental_id) AS rental_count
FROM book b
INNER JOIN rental r ON b.book_id = r.book_id
GROUP BY b.book_id, b.title
ORDER BY rental_count DESC;
```

주의:

> 별칭을 사용할 때는 오타가 없도록 한다. `rental_count`를 `rent_count`처럼 다르게 쓰면 오류가 난다.

---

### 22.4 동점 보조 정렬이 없는 경우

```sql
ORDER BY rental_count DESC
```

문제:

> 대여 횟수가 같은 도서들의 순서가 명확하지 않을 수 있다.

권장:

```sql
ORDER BY rental_count DESC, b.book_id ASC
```

---

## 23. 평가 예상 질문과 답변

### 질문 1. TOP N 쿼리는 어떻게 작성하나요?

> 먼저 `ORDER BY`로 순위 기준을 정하고, `LIMIT N`으로 상위 N개만 가져옵니다. 예를 들어 가격 TOP 5는 `ORDER BY price DESC LIMIT 5`로 작성합니다.

### 질문 2. 인기 도서 TOP 5는 어떻게 구했나요?

> `book`과 `rental`을 JOIN한 뒤 도서별로 GROUP BY하고 `COUNT(r.rental_id)`로 대여 횟수를 계산했습니다. 이후 `ORDER BY rental_count DESC LIMIT 5`로 상위 5권을 조회했습니다.

### 질문 3. 회원별 대여 순위는 어떻게 구했나요?

> `member`와 `rental`을 JOIN하고 회원별로 GROUP BY한 뒤 `COUNT(r.rental_id)`로 대여 횟수를 계산해 많은 순으로 정렬했습니다.

### 질문 4. ORDER BY에 보조 정렬을 넣은 이유는 무엇인가요?

> 순위 기준 값이 같은 경우 결과 순서가 불안정할 수 있으므로 `book_id ASC`나 `member_id ASC` 같은 보조 정렬을 넣어 결과를 안정적으로 만들었습니다.

### 질문 5. ROW_NUMBER와 RANK는 무엇이 다른가요?

> `ROW_NUMBER`는 동점이어도 서로 다른 번호를 부여하고, `RANK`는 동점에 같은 순위를 부여하되 다음 순위를 건너뜁니다. `DENSE_RANK`는 동점 후 다음 순위를 건너뛰지 않습니다.

---

## 24. 30초 답변 연습

> 랭킹 쿼리는 정렬 기준을 정한 뒤 `ORDER BY`로 순서를 만들고 `LIMIT`으로 상위 N개를 선택하는 쿼리입니다. 이 프로젝트에서는 인기 도서 TOP 5를 구할 때 `book`과 `rental`을 JOIN하고 도서별로 GROUP BY한 뒤 `COUNT(r.rental_id)`를 대여 횟수로 계산했습니다. 그 다음 `ORDER BY rental_count DESC, book_id ASC LIMIT 5`로 대여 횟수가 많은 도서 5개를 조회했습니다.

---

## 25. 오늘의 완료 기준

```text
[ ] TOP N 쿼리를 한 문장으로 설명했다.
[ ] 가격 높은 도서 TOP 5를 작성했다.
[ ] 인기 도서 TOP 5를 작성했다.
[ ] 회원별 대여 횟수 TOP 5를 작성했다.
[ ] 카테고리별 평균 가격 순위를 작성했다.
[ ] 월별 대여 건수 순위를 작성했다.
[ ] ORDER BY의 ASC/DESC 차이를 설명했다.
[ ] 동점 보조 정렬이 필요한 이유를 설명했다.
[ ] ROW_NUMBER/RANK/DENSE_RANK 차이를 설명했다.
[ ] 30초 답변을 소리 내어 연습했다.
```
