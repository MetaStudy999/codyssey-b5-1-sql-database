# 미니 리포트 - 도서 대여 관리 DB

한 줄 요약: 대여 데이터를 월별, 도서별, 회원별로 묶어 도서관 운영 상태를 빠르게 파악하는 리포트이다.

이 문서는 `docs/bonus.sql`의 Bonus 3 쿼리로 확인하는 핵심 지표 3개를 입문자도 이해하기 쉽게 설명한다. 단순히 SQL 실행 결과를 나열하는 것이 아니라, 각 결과가 어떤 의미인지와 실제 운영에서 어떻게 활용할 수 있는지를 함께 정리한다.

## 실습 따라하기

전체 결과를 다시 생성하려면 프로젝트 루트에서 아래 명령을 실행한다.

```bash
bash scripts/run_all.sh
```

보너스 리포트 쿼리만 직접 실행하려면 스키마와 시드 데이터가 준비된 상태에서 아래 명령을 실행한다.

```bash
sqlite3 book_rental.db < docs/bonus.sql
```

실행 결과는 `results/bonus_results.txt`에 저장되며, 결과 해설은 `results/bonus_results.md`에서도 확인할 수 있다.

## 핵심 키워드

- `GROUP BY`: 같은 기준의 데이터를 하나의 그룹으로 묶는다.
- `COUNT`: 그룹 안에 몇 건의 데이터가 있는지 센다.
- `SUM`: 금액이나 조건별 건수를 합산한다.
- `CASE WHEN`: 조건에 따라 다른 값을 계산한다.
- `JOIN`: 여러 테이블의 정보를 연결한다.
- `HAVING`: 그룹으로 묶은 결과에 조건을 적용한다.
- `ROUND`: 계산 결과의 소수점 자릿수를 정리한다.
- `LIMIT`: 상위 몇 개 결과만 확인한다.

## 1. 월별 대여 건수 추이

### 한 줄 요약

월별로 대여가 몇 건 발생했고, 그중 반납/대여중/연체가 각각 몇 건인지 확인한다.

### 쉬운 설명

대여 기록은 `rented_at` 컬럼에 `2024-06-01`처럼 날짜 형태로 저장되어 있다. 월별 리포트를 만들려면 일자 전체가 아니라 `2024-06`, `2024-07`처럼 연도와 월만 필요하다.

그래서 `substr(rented_at, 1, 7)`을 사용해 날짜 문자열의 앞 7글자만 잘라 월을 만든다. 그다음 `GROUP BY`로 같은 월끼리 묶고, `COUNT(*)`로 전체 대여 건수를 센다.

상태별 건수는 `CASE WHEN`으로 계산한다. 예를 들어 `status = 'OVERDUE'`이면 1, 아니면 0으로 바꾼 뒤 더하면 해당 월의 연체 건수가 된다.

### 결과 해석

```text
rental_month  total_rentals  returned_count  current_rented_count  overdue_count  total_fee
------------  -------------  --------------  --------------------  -------------  ---------
2024-06       13             3               9                     1              6700
2024-07       7              0               6                     1              5000
```

2024년 6월에는 총 13건의 대여가 있었고, 그중 3건은 반납 완료, 9건은 현재 대여 중, 1건은 연체 상태이다. 수수료 합계는 6,700원이다.

2024년 7월에는 총 7건의 대여가 있었고, 반납 완료는 0건, 현재 대여 중은 6건, 연체는 1건이다. 수수료 합계는 5,000원이다.

### 평가 포인트

평가자는 이 항목을 통해 날짜 데이터를 월 단위로 묶을 수 있는지, 그리고 조건부 집계를 사용해 상태별 건수를 만들 수 있는지 확인할 수 있다.

### 실습 SQL

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

`substr`, `GROUP BY`, `COUNT`, `SUM`, `CASE WHEN`, `월별 리포트`

## 2. 가장 많이 대여된 도서 TOP 5

### 한 줄 요약

대여 횟수가 많은 도서를 찾아 인기 도서와 수요가 높은 분야를 확인한다.

### 쉬운 설명

이 리포트는 어떤 책이 많이 빌려졌는지 확인한다. 책 제목은 `book` 테이블에 있고, 카테고리 이름은 `category` 테이블에 있으며, 실제 대여 횟수는 `rental` 테이블을 세어야 알 수 있다.

따라서 `book`, `category`, `rental` 세 테이블을 `JOIN`으로 연결한다. 그다음 책별로 `GROUP BY`를 하고, `COUNT(r.rental_id)`로 각 책이 몇 번 대여되었는지 계산한다.

`ORDER BY rental_count DESC, total_fee DESC`는 먼저 대여 횟수가 많은 순서로 정렬하고, 대여 횟수가 같으면 수수료 합계가 높은 책을 더 위에 보여 준다는 뜻이다. 마지막의 `LIMIT 5`는 상위 5권만 보기 위한 제한이다.

### 결과 해석

```text
book_id  title          category_name  rental_count  total_fee
-------  -------------  -------------  ------------  ---------
7        머신러닝 기본기       AI             2             8000
2        관계형 데이터베이스 설계  Database       2             1500
1        SQL 첫걸음        Database       2             1200
8        딥러닝과 수학        AI             2             0
9        리눅스 운영 실무      DevOps         2             0
```

상위 5권은 모두 2번씩 대여되었다. 그중 `머신러닝 기본기`는 수수료 합계가 8,000원으로 가장 높아 첫 번째에 표시된다.

이 결과는 인기 도서를 추가 구매하거나 추천 목록을 만들 때 활용할 수 있다. 예를 들어 AI와 Database 분야 도서가 상위권에 많이 보이므로, 해당 분야의 수요가 높다고 해석할 수 있다.

### 평가 포인트

여러 테이블을 연결한 뒤 도서별로 묶고, 대여 횟수와 수수료 합계를 함께 계산할 수 있는지 확인하는 항목이다.

### 실습 SQL

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

`INNER JOIN`, `GROUP BY`, `COUNT`, `SUM`, `ORDER BY`, `LIMIT`, `TOP 5`

## 3. 연체율이 높은 회원

### 한 줄 요약

회원별 대여 건수 중 연체가 차지하는 비율을 계산해 연체 관리 대상자를 찾는다.

### 쉬운 설명

이 리포트는 "누가 연체를 많이 했는가?"를 확인한다. 단순히 연체 건수만 보는 것보다 전체 대여 건수 대비 연체 비율을 함께 보는 것이 더 공정하다.

예를 들어 어떤 회원이 총 10번 빌려서 1번 연체한 경우와, 총 3번 빌려서 1번 연체한 경우는 연체 건수는 같지만 연체율은 다르다. 이 쿼리는 이런 차이를 `overdue_rate_percent`로 계산한다.

`HAVING overdue_count > 0`은 연체가 한 번 이상 있는 회원만 결과에 남긴다. `WHERE`가 개별 행에 조건을 거는 문법이라면, `HAVING`은 `GROUP BY`로 묶은 뒤 계산된 결과에 조건을 거는 문법이다.

### 결과 해석

```text
member_id  name  total_rentals  overdue_count  overdue_rate_percent  total_fee
---------  ----  -------------  -------------  --------------------  ---------
1          김민준   3              1              33.3                  6200
3          박도윤   3              1              33.3                  3000
```

김민준 회원과 박도윤 회원은 각각 총 3번 대여했고, 그중 1번이 연체이다. 따라서 연체율은 `1 / 3 * 100 = 33.3%`이다.

두 회원의 연체율은 같지만, 김민준 회원의 총 수수료가 6,200원으로 더 높기 때문에 정렬 결과에서 먼저 표시된다.

### 평가 포인트

회원별 집계, 조건부 연체 건수 계산, 비율 계산, `HAVING` 필터링을 함께 사용할 수 있는지 확인하는 항목이다.

### 실습 SQL

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

`HAVING`, `ROUND`, `CASE WHEN`, `연체율`, `비율 계산`, `회원별 집계`

## 실행 결과

자동 실행 시 원본 결과는 `results/bonus_results.txt`에 저장된다. 입문자용 상세 해설은 `results/bonus_results.md`에 정리되어 있으므로, 실제 출력값과 설명을 함께 확인하면 된다.

## 제출 시 확인할 점

- 월별 리포트는 `2024-06`, `2024-07`처럼 월 단위로 묶여 있어야 한다.
- 도서 TOP 5 리포트는 대여 횟수가 많은 순서로 정렬되어야 한다.
- 연체율 리포트는 연체가 있는 회원만 보여야 한다.
- 각 리포트는 단순 조회가 아니라 `GROUP BY`, `JOIN`, `CASE WHEN`, `HAVING` 같은 SQL 활용 능력을 보여 주는 근거가 된다.
