# Bonus Results 해설

한 줄 요약: JOIN, 서브쿼리, 외래키 개념, 월별/도서별/회원별 미니 리포트를 통해 SQL 활용력을 추가로 확인한 결과입니다.

## 실습 따라하기

1. 전체 결과를 다시 만들려면 아래 명령을 실행합니다.

```bash
bash scripts/run_all.sh
```

2. 보너스 쿼리만 직접 실행하려면 스키마와 시드 데이터가 준비된 뒤 아래 명령을 실행합니다.

```bash
sqlite3 book_rental.db < docs/bonus.sql
```

3. 결과 파일은 `results/bonus_results.txt`에 저장됩니다.

## 핵심 키워드

- `INNER JOIN`: 여러 테이블에서 조건이 맞는 행을 연결
- `DISTINCT`: 중복 행 제거
- `IN`: 여러 후보 값 중 하나와 일치하는지 확인
- `Subquery`: 쿼리 안에 들어가는 또 다른 쿼리
- `FOREIGN KEY`: 존재하지 않는 부모 데이터를 참조하지 못하게 하는 규칙
- `GROUP BY`: 같은 기준의 행을 묶어 집계
- `CASE WHEN`: 조건별로 값을 다르게 계산
- `HAVING`: 그룹으로 묶은 결과에 조건 적용
- `LIMIT`: 결과 개수 제한

## Bonus 1-A. JOIN 방식

### 원본 결과

```text
Bonus 1-A. JOIN 방식: AI 카테고리 도서를 대여한 회원을 찾는다.
member_id  name
---------  ----
1          김민준
2          이서연
3          박도윤
```

### 쉬운 설명

이 결과는 `AI` 카테고리 도서를 빌린 회원을 찾은 것입니다. 회원 이름은 `member` 테이블에 있고, 대여 기록은 `rental` 테이블에 있으며, 도서 정보는 `book`, 카테고리 이름은 `category`에 있습니다.

따라서 한 테이블만 봐서는 답을 구할 수 없습니다. `member -> rental -> book -> category` 순서로 테이블을 연결해야 "AI 도서를 빌린 회원"이라는 질문에 답할 수 있습니다.

`DISTINCT`를 사용했기 때문에 같은 회원이 AI 도서를 여러 번 빌렸더라도 한 번만 표시됩니다.

### 평가 포인트

여러 테이블의 관계를 정확히 이해하고, 필요한 테이블을 JOIN으로 연결할 수 있는지 확인하는 항목입니다.

### 실습 따라하기

```sql
SELECT DISTINCT m.member_id, m.name
FROM member m
INNER JOIN rental r ON m.member_id = r.member_id
INNER JOIN book b ON r.book_id = b.book_id
INNER JOIN category c ON b.category_id = c.category_id
WHERE c.name = 'AI'
ORDER BY m.member_id;
```

### 핵심 키워드

`INNER JOIN`, `DISTINCT`, `테이블 관계`, `AI 카테고리`

## Bonus 1-B. 서브쿼리 방식

### 원본 결과

```text
Bonus 1-B. 서브쿼리 방식: 같은 요구를 IN 서브쿼리로 해결한다.
member_id  name
---------  ----
1          김민준
2          이서연
3          박도윤
```

### 쉬운 설명

이 결과는 Bonus 1-A와 같은 질문을 다른 방식으로 푼 것입니다. JOIN은 테이블을 옆으로 연결해서 한 번에 보는 방식이고, 서브쿼리는 안쪽 쿼리의 결과를 바깥 쿼리의 조건으로 넘기는 방식입니다.

흐름은 다음과 같습니다.

1. `category`에서 `AI` 카테고리의 번호를 찾습니다.
2. 그 카테고리에 속한 `book_id`를 찾습니다.
3. 그 책들을 빌린 `member_id`를 찾습니다.
4. 마지막으로 해당 회원의 이름을 `member`에서 조회합니다.

결과가 JOIN 방식과 동일하므로, 같은 요구사항을 두 가지 SQL 문법으로 해결할 수 있음을 보여 줍니다.

### 평가 포인트

서브쿼리의 실행 흐름을 이해하고, `IN` 조건을 사용해 여러 결과를 바깥 쿼리에 전달할 수 있는지 확인합니다.

### 실습 따라하기

```sql
SELECT member_id, name
FROM member
WHERE member_id IN (
    SELECT r.member_id
    FROM rental r
    WHERE r.book_id IN (
        SELECT b.book_id
        FROM book b
        WHERE b.category_id = (
            SELECT category_id
            FROM category
            WHERE name = 'AI'
        )
    )
)
ORDER BY member_id;
```

### 핵심 키워드

`Subquery`, `IN`, `중첩 SELECT`, `JOIN과 비교`

## Bonus 2. FK 오류 데모

### 원본 결과

```text
Bonus 2. FK 오류 데모: 아래 주석을 해제하면 없는 member_id=999를 참조하므로 실패한다.
fk_demo_note
------------------------------------------------------------
member_id=999는 member 테이블에 없으므로 아래 INSERT를 실행하면 FOREIGN KEY
constraint failed가 발생한다.
```

### 쉬운 설명

이 항목은 외래키 오류가 어떤 상황에서 발생하는지 설명하는 안내용 결과입니다. `rental` 테이블의 `member_id`는 반드시 `member` 테이블에 존재해야 합니다.

예를 들어 `member_id=999`인 회원이 없는데 대여 기록에 999번 회원을 넣으면, 대여 기록이 존재하지 않는 회원을 가리키게 됩니다. 이런 잘못된 데이터를 막기 위해 외래키 제약조건이 필요합니다.

이 보너스 파일에서는 실제 INSERT가 주석 처리되어 있어 실행이 실패하지 않습니다. 실제 실패 데모는 `results/fk_error_demo.md`에서 별도로 확인할 수 있습니다.

### 평가 포인트

외래키가 "테이블 사이의 연결 규칙"이라는 점과, 잘못된 참조를 막는 역할을 이해했는지 확인합니다.

### 실습 따라하기

아래 INSERT는 직접 실행하면 실패해야 정상입니다.

```sql
INSERT INTO rental (rental_id, member_id, book_id, rented_at, due_date, status, rental_fee)
VALUES (999, 999, 1, '2024-08-01', '2024-08-15', 'RENTED', 0);
```

### 핵심 키워드

`FOREIGN KEY`, `참조 무결성`, `constraint failed`, `잘못된 INSERT`

## Bonus 3-1. 월별 대여 미니 리포트

### 원본 결과

```text
Bonus 3-1. 미니 리포트: 월별 대여 건수와 상태별 건수를 확인한다.
rental_month  total_rentals  returned_count  current_rented_count  overdue_count  total_fee
------------  -------------  --------------  --------------------  -------------  ---------
2024-06       13             3               9                     1              6700
2024-07       7              0               6                     1              5000
```

### 쉬운 설명

이 리포트는 대여 기록을 월별로 묶어 보여 줍니다. `2024-06`에는 총 13건의 대여가 있었고, 그중 반납 완료는 3건, 현재 대여 중은 9건, 연체는 1건입니다. 수수료 합계는 6,700원입니다.

`2024-07`에는 총 7건의 대여가 있었고, 반납 완료는 아직 0건, 현재 대여 중은 6건, 연체는 1건입니다. 수수료 합계는 5,000원입니다.

`CASE WHEN`은 상태별로 건수를 나누어 세기 위해 사용합니다. 예를 들어 `status = 'OVERDUE'`이면 1, 아니면 0으로 바꾼 뒤 모두 더하면 연체 건수가 됩니다.

### 평가 포인트

날짜 문자열에서 월을 추출하고, `GROUP BY`와 조건부 집계를 사용해 실무형 리포트를 만들 수 있는지 확인합니다.

### 실습 따라하기

```sql
SELECT
    substr(rented_at, 1, 7) AS rental_month,
    COUNT(*) AS total_rentals,
    SUM(CASE WHEN status = 'RETURNED' THEN 1 ELSE 0 END) AS returned_count,
    SUM(CASE WHEN status = 'RENTED' THEN 1 ELSE 0 END) AS current_rented_count,
    SUM(CASE WHEN status = 'OVERDUE' THEN 1 ELSE 0 END) AS overdue_count,
    SUM(rental_fee) AS total_fee
FROM rental
GROUP BY substr(rented_at, 1, 7)
ORDER BY rental_month;
```

### 핵심 키워드

`GROUP BY`, `substr`, `CASE WHEN`, `SUM`, `월별 리포트`

## Bonus 3-2. 가장 많이 대여된 도서 TOP 5

### 원본 결과

```text
Bonus 3-2. 미니 리포트: 가장 많이 대여된 도서 TOP 5를 확인한다.
book_id  title          category_name  rental_count  total_fee
-------  -------------  -------------  ------------  ---------
7        머신러닝 기본기       AI             2             8000
2        관계형 데이터베이스 설계  Database       2             1500
1        SQL 첫걸음        Database       2             1200
8        딥러닝과 수학        AI             2             0
9        리눅스 운영 실무      DevOps         2             0
```

### 쉬운 설명

이 리포트는 어떤 책이 많이 빌려졌는지 상위 5권을 보여 줍니다. 결과에서는 다섯 권 모두 대여 횟수가 2회입니다. 대여 횟수가 같을 때는 수수료 합계가 높은 순서로 정렬되어 `머신러닝 기본기`가 가장 위에 나옵니다.

이 쿼리는 `book`, `category`, `rental`을 연결합니다. 책 제목과 가격 같은 도서 정보는 `book`에 있고, 카테고리 이름은 `category`, 실제 빌린 횟수는 `rental`을 세어야 알 수 있기 때문입니다.

### 평가 포인트

JOIN으로 필요한 정보를 모은 뒤, 도서별로 묶고, `COUNT`와 `SUM`으로 순위를 계산하는 능력을 확인합니다.

### 실습 따라하기

```sql
SELECT
    b.book_id,
    b.title,
    c.name AS category_name,
    COUNT(r.rental_id) AS rental_count,
    SUM(r.rental_fee) AS total_fee
FROM book b
INNER JOIN category c ON b.category_id = c.category_id
INNER JOIN rental r ON b.book_id = r.book_id
GROUP BY b.book_id, b.title, c.name
ORDER BY rental_count DESC, total_fee DESC, b.book_id ASC
LIMIT 5;
```

### 핵심 키워드

`COUNT`, `SUM`, `ORDER BY`, `LIMIT`, `TOP 5`

## Bonus 3-3. 연체율이 높은 회원

### 원본 결과

```text
Bonus 3-3. 미니 리포트: 연체율이 높은 회원을 확인한다.
member_id  name  total_rentals  overdue_count  overdue_rate_percent  total_fee
---------  ----  -------------  -------------  --------------------  ---------
1          김민준   3              1              33.3                  6200
3          박도윤   3              1              33.3                  3000
```

### 쉬운 설명

이 리포트는 연체가 발생한 회원을 보여 줍니다. 김민준 회원과 박도윤 회원은 각각 총 3번 대여했고, 그중 1번이 연체입니다. 그래서 연체율은 `1 / 3 * 100 = 33.3%`입니다.

`HAVING overdue_count > 0` 조건이 있기 때문에 연체가 한 번도 없는 회원은 결과에서 제외됩니다. `WHERE`는 그룹으로 묶기 전의 행에 조건을 걸 때 사용하고, `HAVING`은 그룹 계산이 끝난 뒤의 결과에 조건을 걸 때 사용합니다.

### 평가 포인트

회원별 집계, 조건부 합계, 비율 계산, `HAVING` 필터링을 함께 사용할 수 있는지 확인합니다.

### 실습 따라하기

```sql
SELECT
    m.member_id,
    m.name,
    COUNT(r.rental_id) AS total_rentals,
    SUM(CASE WHEN r.status = 'OVERDUE' THEN 1 ELSE 0 END) AS overdue_count,
    ROUND(
        100.0 * SUM(CASE WHEN r.status = 'OVERDUE' THEN 1 ELSE 0 END)
        / COUNT(r.rental_id),
        1
    ) AS overdue_rate_percent,
    SUM(r.rental_fee) AS total_fee
FROM member m
INNER JOIN rental r ON m.member_id = r.member_id
GROUP BY m.member_id, m.name
HAVING overdue_count > 0
ORDER BY overdue_rate_percent DESC, total_fee DESC, m.member_id ASC;
```

### 핵심 키워드

`HAVING`, `ROUND`, `조건부 집계`, `연체율`, `비율 계산`
