# Query Results 해설

한 줄 요약: 기본 조회부터 JOIN, 집계, 서브쿼리, UPDATE, DELETE, INDEX까지 SQL 핵심 기능 15가지를 실행하고 결과를 확인한 문서입니다.

## 실습 따라하기

1. 전체 결과를 다시 생성하려면 프로젝트 루트에서 아래 명령을 실행합니다.

```bash
bash scripts/run_all.sh
```

2. 핵심 쿼리만 직접 실행하고 싶다면, `sql/03_queries.sql`에는 `UPDATE`와 `DELETE`가 포함되어 있으므로 복사본 DB에서 실행하는 것을 권장합니다.

```bash
cp book_rental.db /tmp/book_rental_queries.db
sqlite3 /tmp/book_rental_queries.db < sql/03_queries.sql
```

3. `scripts/run_all.sh`도 같은 이유로 핵심 쿼리를 임시 DB 복사본에서 실행합니다. 그래서 원본 `book_rental.db`의 기본 데이터는 보호됩니다.

## 핵심 키워드

- `SELECT`: 테이블에서 데이터를 조회
- `WHERE`: 조건에 맞는 행만 필터링
- `ORDER BY`: 결과 정렬
- `LIMIT`: 출력할 행 수 제한
- `LIKE`: 문자열 패턴 검색
- `IN`: 여러 값 중 하나와 일치하는지 확인
- `INNER JOIN`: 연결 조건이 맞는 데이터만 결합
- `LEFT JOIN`: 왼쪽 테이블의 데이터를 모두 유지하며 결합
- `GROUP BY`: 같은 기준으로 데이터를 묶음
- `COUNT`, `SUM`, `AVG`: 행 개수, 합계, 평균 계산
- `Subquery`: 쿼리 안에서 사용하는 또 다른 쿼리
- `UPDATE`: 기존 데이터 수정
- `DELETE`: 기존 데이터 삭제
- `INDEX`: 검색 성능 향상을 위한 자료구조
- `EXPLAIN QUERY PLAN`: SQLite의 실행 계획 확인

## Q01. ACTIVE 회원 중 2024-03-01 이후 가입자

### 원본 결과

```text
Q01. 기본 조회: ACTIVE 회원 중 2024-03-01 이후 가입자를 확인한다.
member_id  name  email                    joined_at   status
---------  ----  -----------------------  ----------  ------
6          강하린   harin.kang@example.com   2024-03-22  ACTIVE
7          조은우   eunwoo.cho@example.com   2024-04-08  ACTIVE
8          윤서준   seojun.yoon@example.com  2024-04-25  ACTIVE
9          임수아   sua.lim@example.com      2024-05-10  ACTIVE
10         한지민   jimin.han@example.com    2024-05-28  ACTIVE
```

### 쉬운 설명

이 쿼리는 회원 중에서 상태가 `ACTIVE`이고, 가입일이 `2024-03-01` 이후인 사람만 조회합니다. `WHERE`에 조건이 두 개 들어가며, `AND`로 연결되어 있으므로 두 조건을 모두 만족해야 결과에 나옵니다.

결과는 `joined_at ASC`로 정렬되어 가입일이 오래된 순서부터 표시됩니다. 즉 2024년 3월 22일에 가입한 강하린 회원이 먼저 나오고, 2024년 5월 28일에 가입한 한지민 회원이 마지막에 나옵니다.

### 평가 포인트

기본적인 `SELECT`, `WHERE`, `AND`, `ORDER BY`를 사용할 수 있는지 확인하는 문항입니다.

### 실습 따라하기

```sql
SELECT member_id, name, email, joined_at, status
FROM member
WHERE status = 'ACTIVE'
  AND joined_at >= '2024-03-01'
ORDER BY joined_at ASC;
```

### 핵심 키워드

`SELECT`, `WHERE`, `AND`, `ORDER BY`, `날짜 조건`

## Q02. 30,000원 이상 도서 TOP 5

### 원본 결과

```text
Q02. 기본 조회: 30,000원 이상 도서를 가격 높은 순으로 5권 확인한다. (WHERE + ORDER BY + LIMIT)
book_id  title          author  price
-------  -------------  ------  -----
8        딥러닝과 수학        윤하늘     42000
7        머신러닝 기본기       강태오     36000
4        백엔드 개발 패턴      이도현     35000
11       자료구조와 알고리즘     남태현     34000
2        관계형 데이터베이스 설계  박성훈     32000
```

### 쉬운 설명

이 쿼리는 가격이 30,000원 이상인 도서만 찾습니다. 그다음 `ORDER BY price DESC`로 가격이 높은 순서로 정렬하고, `LIMIT 5`로 상위 5권만 보여 줍니다.

결과를 보면 가장 비싼 책은 42,000원인 `딥러닝과 수학`이고, 다섯 번째는 32,000원인 `관계형 데이터베이스 설계`입니다.

### 평가 포인트

조건 필터링, 내림차순 정렬, 결과 개수 제한을 함께 사용할 수 있는지 확인합니다.

### 실습 따라하기

```sql
SELECT book_id, title, author, price
FROM book
WHERE price >= 30000
ORDER BY price DESC
LIMIT 5;
```

### 핵심 키워드

`WHERE`, `>=`, `ORDER BY DESC`, `LIMIT`

## Q03. 제목에 SQL이 들어간 도서 검색

### 원본 결과

```text
Q03. 기본 조회: 제목에 SQL이 들어간 도서를 검색한다. (LIKE)
book_id  title    author   price
-------  -------  -------  -----
1        SQL 첫걸음  아사이 아츠시  23000
```

### 쉬운 설명

이 쿼리는 책 제목에 `SQL`이라는 글자가 포함된 도서를 찾습니다. `LIKE '%SQL%'`에서 `%`는 앞뒤에 어떤 글자가 와도 된다는 뜻입니다.

결과에는 `SQL 첫걸음` 한 권만 표시되었습니다. 이는 현재 샘플 데이터에서 제목에 `SQL`이 포함된 책이 이 책뿐이라는 의미입니다.

### 평가 포인트

정확히 같은 값이 아니라 문자열 일부가 포함된 데이터를 찾는 패턴 검색을 이해했는지 확인합니다.

### 실습 따라하기

```sql
SELECT book_id, title, author, price
FROM book
WHERE title LIKE '%SQL%'
ORDER BY title ASC;
```

### 핵심 키워드

`LIKE`, `%`, `문자열 검색`, `패턴 매칭`

## Q04. 현재 대여 중 또는 연체 상태의 기록

### 원본 결과

```text
Q04. 기본 조회: 현재 대여 중 또는 연체 상태의 대여 기록을 반납기한 순으로 확인한다.
rental_id  member_id  book_id  rented_at   due_date    status
---------  ---------  -------  ----------  ----------  -------
2          1          3        2024-06-05  2024-06-19  RENTED
4          2          5        2024-06-10  2024-06-24  RENTED
5          3          7        2024-06-12  2024-06-26  OVERDUE
6          3          8        2024-06-15  2024-06-29  RENTED
7          4          9        2024-06-18  2024-07-02  RENTED
8          4          10       2024-06-20  2024-07-04  RENTED
9          5          11       2024-06-21  2024-07-05  RENTED
10         6          12       2024-06-22  2024-07-06  RENTED
12         7          14       2024-06-26  2024-07-10  RENTED
13         7          15       2024-06-28  2024-07-12  RENTED
14         8          4        2024-07-01  2024-07-15  RENTED
15         8          6        2024-07-02  2024-07-16  RENTED
16         9          1        2024-07-03  2024-07-17  RENTED
17         9          2        2024-07-04  2024-07-18  RENTED
18         1          7        2024-07-05  2024-07-19  OVERDUE
19         2          8        2024-07-06  2024-07-20  RENTED
20         3          9        2024-07-07  2024-07-21  RENTED
```

### 쉬운 설명

이 쿼리는 아직 반납이 끝나지 않은 기록을 찾습니다. `status IN ('RENTED', 'OVERDUE')`는 상태가 `RENTED`이거나 `OVERDUE`인 행을 모두 가져오라는 뜻입니다.

`ORDER BY due_date ASC`가 있으므로 반납기한이 빠른 순서대로 정렬됩니다. 도서관 운영자 입장에서는 먼저 확인해야 할 대여 건을 위에서부터 볼 수 있습니다.

### 평가 포인트

여러 상태 값을 `IN`으로 한 번에 필터링하고, 업무적으로 의미 있는 날짜 기준 정렬을 할 수 있는지 확인합니다.

### 실습 따라하기

```sql
SELECT rental_id, member_id, book_id, rented_at, due_date, status
FROM rental
WHERE status IN ('RENTED', 'OVERDUE')
ORDER BY due_date ASC;
```

### 핵심 키워드

`IN`, `ORDER BY`, `RENTED`, `OVERDUE`, `반납기한`

## Q05. 최근 대여 기록에서 회원명과 도서명 함께 보기

### 원본 결과

```text
Q05. INNER JOIN: 최근 대여 기록에서 회원명과 도서명을 함께 확인한다.
rental_id  member_name  book_title     rented_at   status
---------  -----------  -------------  ----------  --------
20         박도윤          리눅스 운영 실무      2024-07-07  RENTED
19         이서연          딥러닝과 수학        2024-07-06  RENTED
18         김민준          머신러닝 기본기       2024-07-05  OVERDUE
17         임수아          관계형 데이터베이스 설계  2024-07-04  RENTED
16         임수아          SQL 첫걸음        2024-07-03  RENTED
15         윤서준          HTML CSS 웹 표준  2024-07-02  RENTED
14         윤서준          백엔드 개발 패턴      2024-07-01  RENTED
13         조은우          개발자를 위한 글쓰기    2024-06-28  RENTED
12         조은우          스타트업 지표 읽기     2024-06-26  RENTED
11         강하린          UX 리서치 노트      2024-06-25  RETURNED
```

### 쉬운 설명

`rental` 테이블에는 `member_id`와 `book_id`만 있으므로, 그대로 보면 누가 어떤 책을 빌렸는지 사람이 읽기 어렵습니다. 이 쿼리는 `member` 테이블을 연결해 회원명을 가져오고, `book` 테이블을 연결해 도서명을 가져옵니다.

`ORDER BY r.rented_at DESC`로 최근 대여가 위에 오도록 정렬하고, `LIMIT 10`으로 최근 10건만 확인합니다.

### 평가 포인트

외래키로 연결된 테이블을 `INNER JOIN`으로 묶어, ID가 아닌 사람이 이해하기 쉬운 이름과 제목을 출력할 수 있는지 확인합니다.

### 실습 따라하기

```sql
SELECT r.rental_id, m.name AS member_name, b.title AS book_title, r.rented_at, r.status
FROM rental r
INNER JOIN member m ON r.member_id = m.member_id
INNER JOIN book b ON r.book_id = b.book_id
ORDER BY r.rented_at DESC
LIMIT 10;
```

### 핵심 키워드

`INNER JOIN`, `별칭 AS`, `외래키 연결`, `최근 10건`

## Q06. 도서와 카테고리 연결

### 원본 결과

```text
Q06. INNER JOIN: 도서와 카테고리를 연결하여 도서 분류를 확인한다.
book_id  title          category_name  price
-------  -------------  -------------  -----
8        딥러닝과 수학        AI             42000
7        머신러닝 기본기       AI             36000
11       자료구조와 알고리즘     Algorithm      34000
3        FastAPI 실전 입문  Backend        28000
4        백엔드 개발 패턴      Backend        35000
14       스타트업 지표 읽기     Business       26000
15       개발자를 위한 글쓰기    Communication  21000
1        SQL 첫걸음        Database       23000
2        관계형 데이터베이스 설계  Database       32000
13       UX 리서치 노트      Design         25000
10       AWS 클라우드 기초    DevOps         31000
9        리눅스 운영 실무      DevOps         27000
6        HTML CSS 웹 표준  Frontend       22000
5        모던 JavaScript  Frontend       30000
12       웹 보안 입문        Security       29000
```

### 쉬운 설명

도서 테이블에는 카테고리 이름이 직접 저장되어 있지 않고 `category_id`가 저장되어 있습니다. 이 쿼리는 `book.category_id`와 `category.category_id`를 연결해서 각 책의 카테고리 이름을 보여 줍니다.

결과는 카테고리 이름과 제목 기준으로 정렬되어 있어, 같은 분야의 책을 모아서 보기 쉽습니다.

### 평가 포인트

정규화된 테이블 구조에서 코드나 ID를 실제 이름으로 바꿔 보여 주는 JOIN 능력을 확인합니다.

### 실습 따라하기

```sql
SELECT b.book_id, b.title, c.name AS category_name, b.price
FROM book b
INNER JOIN category c ON b.category_id = c.category_id
ORDER BY c.name, b.title;
```

### 핵심 키워드

`INNER JOIN`, `category_id`, `정규화`, `분류 조회`

## Q07. 연체 기록의 회원/도서/카테고리 확인

### 원본 결과

```text
Q07. INNER JOIN: 연체 기록의 회원/도서/카테고리를 한 번에 확인한다.
rental_id  member_name  book_title  category_name  due_date    rental_fee
---------  -----------  ----------  -------------  ----------  ----------
5          박도윤          머신러닝 기본기    AI             2024-06-26  3000
18         김민준          머신러닝 기본기    AI             2024-07-19  5000
```

### 쉬운 설명

이 쿼리는 `status = 'OVERDUE'`인 연체 기록만 조회합니다. 연체 기록을 볼 때는 단순히 대여 번호만 보는 것보다, 회원 이름, 책 제목, 카테고리, 반납기한, 수수료를 함께 보는 것이 훨씬 유용합니다.

결과를 보면 박도윤 회원과 김민준 회원이 `머신러닝 기본기`를 연체했고, 각각 수수료가 3,000원과 5,000원입니다.

### 평가 포인트

여러 테이블 JOIN과 조건 필터링을 함께 사용해 실무적인 조회 화면을 구성할 수 있는지 확인합니다.

### 실습 따라하기

```sql
SELECT r.rental_id, m.name AS member_name, b.title AS book_title, c.name AS category_name, r.due_date, r.rental_fee
FROM rental r
INNER JOIN member m ON r.member_id = m.member_id
INNER JOIN book b ON r.book_id = b.book_id
INNER JOIN category c ON b.category_id = c.category_id
WHERE r.status = 'OVERDUE'
ORDER BY r.due_date ASC;
```

### 핵심 키워드

`INNER JOIN`, `WHERE`, `OVERDUE`, `rental_fee`, `연체 조회`

## Q08. 대여 기록이 없는 회원까지 포함한 회원별 대여 횟수

### 원본 결과

```text
Q08. LEFT JOIN: 대여 기록이 없는 회원까지 포함하여 회원별 대여 횟수를 확인한다.
member_id  name  rental_count
---------  ----  ------------
10         한지민   0
5          정하준   1
4          최지우   2
6          강하린   2
7          조은우   2
8          윤서준   2
9          임수아   2
1          김민준   3
2          이서연   3
3          박도윤   3
```

### 쉬운 설명

이 쿼리는 회원별 대여 횟수를 셉니다. 중요한 점은 `LEFT JOIN`을 사용했기 때문에 대여 기록이 없는 회원도 결과에 포함된다는 것입니다.

결과에서 한지민 회원은 `rental_count`가 0입니다. 만약 `INNER JOIN`을 사용했다면 대여 기록이 없는 회원은 결과에서 사라졌을 것입니다.

### 평가 포인트

누락된 데이터까지 보고 싶을 때 `LEFT JOIN`을 선택할 수 있는지 확인합니다. 회원 목록처럼 "기준이 되는 테이블"을 왼쪽에 두는 것이 핵심입니다.

### 실습 따라하기

```sql
SELECT m.member_id, m.name, COUNT(r.rental_id) AS rental_count
FROM member m
LEFT JOIN rental r ON m.member_id = r.member_id
GROUP BY m.member_id, m.name
ORDER BY rental_count ASC, m.member_id ASC;
```

### 핵심 키워드

`LEFT JOIN`, `COUNT`, `GROUP BY`, `0건 포함`

## Q09. 회원별 총 대여 횟수와 수수료 합계

### 원본 결과

```text
Q09. 집계: 회원별 총 대여 횟수와 납부 수수료 합계를 확인한다. (COUNT + SUM + GROUP BY)
member_id  name  rental_count  total_fee
---------  ----  ------------  ---------
1          김민준   3             6200
3          박도윤   3             3000
2          이서연   3             1500
6          강하린   2             1000
9          임수아   2             0
8          윤서준   2             0
7          조은우   2             0
4          최지우   2             0
5          정하준   1             0
```

### 쉬운 설명

이 쿼리는 회원별로 대여 횟수와 수수료 합계를 계산합니다. `COUNT(r.rental_id)`는 대여 건수를 세고, `SUM(r.rental_fee)`는 해당 회원의 수수료를 모두 더합니다.

결과를 보면 김민준 회원은 대여 3건, 수수료 합계 6,200원으로 가장 높은 수수료를 냈습니다. 이 쿼리는 도서관에서 회원별 이용 내역이나 수수료 현황을 확인할 때 유용합니다.

### 평가 포인트

`GROUP BY`로 회원별 그룹을 만들고, 그룹마다 `COUNT`와 `SUM`을 계산할 수 있는지 확인합니다.

### 실습 따라하기

```sql
SELECT m.member_id, m.name, COUNT(r.rental_id) AS rental_count, SUM(r.rental_fee) AS total_fee
FROM member m
INNER JOIN rental r ON m.member_id = r.member_id
GROUP BY m.member_id, m.name
ORDER BY rental_count DESC, total_fee DESC;
```

### 핵심 키워드

`GROUP BY`, `COUNT`, `SUM`, `회원별 집계`

## Q10. 카테고리별 보유 도서 수와 평균 가격

### 원본 결과

```text
Q10. 집계: 카테고리별 보유 도서 수와 평균 가격을 확인한다. (COUNT + AVG + GROUP BY)
category_name  book_count  avg_price
-------------  ----------  ---------
AI             2           39000.0
Backend        2           31500.0
DevOps         2           29000.0
Database       2           27500.0
Frontend       2           26000.0
Algorithm      1           34000.0
Security       1           29000.0
Business       1           26000.0
Design         1           25000.0
Communication  1           21000.0
```

### 쉬운 설명

이 쿼리는 카테고리별로 책이 몇 권 있는지와 평균 가격이 얼마인지 계산합니다. `COUNT(b.book_id)`는 카테고리 안의 책 수를 세고, `AVG(b.price)`는 평균 가격을 구합니다.

예를 들어 AI 카테고리는 책이 2권이고 평균 가격이 39,000원입니다. `ROUND(AVG(b.price), 1)`을 사용했기 때문에 평균 가격은 소수점 한 자리로 표시됩니다.

### 평가 포인트

카테고리 기준 집계와 평균 계산을 수행하고, 결과를 도서 수와 평균 가격 기준으로 정렬할 수 있는지 확인합니다.

### 실습 따라하기

```sql
SELECT c.name AS category_name, COUNT(b.book_id) AS book_count, ROUND(AVG(b.price), 1) AS avg_price
FROM category c
LEFT JOIN book b ON c.category_id = b.category_id
GROUP BY c.category_id, c.name
ORDER BY book_count DESC, avg_price DESC;
```

### 핵심 키워드

`AVG`, `ROUND`, `GROUP BY`, `카테고리별 집계`

## Q11. 대여 상태별 건수와 수수료 합계

### 원본 결과

```text
Q11. 집계: 대여 상태별 건수와 수수료 합계를 확인한다. (COUNT + SUM + GROUP BY)
status    rental_count  total_fee
--------  ------------  ---------
RENTED    15            0
RETURNED  3             3700
OVERDUE   2             8000
```

### 쉬운 설명

이 쿼리는 대여 상태별로 몇 건이 있는지와 수수료 합계가 얼마인지 보여 줍니다. `RENTED`는 현재 대여 중, `RETURNED`는 반납 완료, `OVERDUE`는 연체 상태입니다.

결과를 보면 현재 대여 중인 건은 15건이고 수수료는 0원입니다. 연체는 2건뿐이지만 수수료 합계가 8,000원으로 가장 큽니다.

### 평가 포인트

상태값처럼 범주가 정해진 컬럼을 기준으로 그룹화하고, 업무적으로 의미 있는 요약 통계를 만들 수 있는지 확인합니다.

### 실습 따라하기

```sql
SELECT status, COUNT(*) AS rental_count, SUM(rental_fee) AS total_fee
FROM rental
GROUP BY status
ORDER BY rental_count DESC;
```

### 핵심 키워드

`COUNT(*)`, `SUM`, `GROUP BY`, `상태별 통계`

## Q12. 전체 평균 가격보다 비싼 도서

### 원본 결과

```text
Q12. 서브쿼리: 전체 평균 가격보다 비싼 도서를 확인한다.
book_id  title          price
-------  -------------  -----
8        딥러닝과 수학        42000
7        머신러닝 기본기       36000
4        백엔드 개발 패턴      35000
11       자료구조와 알고리즘     34000
2        관계형 데이터베이스 설계  32000
10       AWS 클라우드 기초    31000
5        모던 JavaScript  30000
```

### 쉬운 설명

이 쿼리는 전체 도서의 평균 가격을 먼저 계산한 뒤, 그 평균보다 비싼 책만 조회합니다. 괄호 안의 `SELECT AVG(price) FROM book`이 먼저 실행되고, 바깥 쿼리가 그 값을 기준으로 필터링합니다.

평균 가격을 숫자로 직접 적지 않고 서브쿼리로 계산했기 때문에, 도서 데이터가 바뀌어도 쿼리를 수정할 필요가 없습니다.

### 평가 포인트

서브쿼리를 사용해 동적으로 계산된 기준값을 `WHERE` 조건에 사용할 수 있는지 확인합니다.

### 실습 따라하기

```sql
SELECT book_id, title, price
FROM book
WHERE price > (SELECT AVG(price) FROM book)
ORDER BY price DESC;
```

평균 가격이 실제로 얼마인지 따로 확인하려면 아래도 실행해 볼 수 있습니다.

```sql
SELECT AVG(price) AS avg_price
FROM book;
```

### 핵심 키워드

`Subquery`, `AVG`, `WHERE`, `동적 기준값`

## Q13. UPDATE로 대여 상태 변경

### 원본 결과

```text
Q13. UPDATE: rental_id=4의 대여 상태를 OVERDUE로 변경하고 결과를 확인한다.
rental_id  member_id  book_id  due_date    status   rental_fee
---------  ---------  -------  ----------  -------  ----------
4          2          5        2024-06-24  OVERDUE  2000
```

### 쉬운 설명

이 쿼리는 `rental_id = 4`인 대여 기록의 상태를 `OVERDUE`로 바꾸고, 수수료를 2,000원으로 설정합니다. 그 뒤 바로 `SELECT`로 해당 행을 다시 조회해 변경이 반영되었는지 확인합니다.

`UPDATE`를 사용할 때 가장 중요한 것은 `WHERE` 조건입니다. `WHERE rental_id = 4`가 없으면 여러 행이 한꺼번에 바뀔 수 있습니다.

### 평가 포인트

데이터를 수정하는 SQL을 안전하게 작성하고, 수정 후 검증 조회까지 수행할 수 있는지 확인합니다.

### 실습 따라하기

```sql
UPDATE rental
SET status = 'OVERDUE', rental_fee = 2000
WHERE rental_id = 4;

SELECT rental_id, member_id, book_id, due_date, status, rental_fee
FROM rental
WHERE rental_id = 4;
```

### 핵심 키워드

`UPDATE`, `SET`, `WHERE`, `수정 후 검증`

## Q14. DELETE로 테스트 대여 기록 삭제

### 원본 결과

```text
Q14. DELETE: 테스트용 대여 기록 rental_id=20을 삭제하고 삭제 결과를 확인한다.
remaining_rentals
-----------------
19
```

### 쉬운 설명

이 쿼리는 `rental_id = 20`인 대여 기록을 삭제합니다. 삭제 후 `COUNT(*)`로 `rental` 테이블에 남은 행 수를 세어 19건이 남았음을 확인합니다.

원래 대여 기록은 20건이었고, 1건을 삭제했으므로 19건이 남는 것이 맞습니다. 이 문항 역시 원본 DB가 아니라 임시 DB 복사본에서 실행되도록 스크립트가 구성되어 있습니다.

### 평가 포인트

`DELETE`를 조건과 함께 안전하게 사용하고, 삭제 결과를 숫자로 검증할 수 있는지 확인합니다.

### 실습 따라하기

```sql
DELETE FROM rental
WHERE rental_id = 20;

SELECT COUNT(*) AS remaining_rentals
FROM rental;
```

### 핵심 키워드

`DELETE`, `WHERE`, `COUNT(*)`, `삭제 검증`

## Q15. INDEX 생성과 실행 계획 확인

### 원본 결과

```text
Q15. INDEX: 회원별 반납기한 조회가 자주 발생하므로 rental(member_id, due_date)에 인덱스를 생성한다.
QUERY PLAN
`--SEARCH rental USING INDEX idx_rental_member_due (member_id=?)
Q15 해석: SEARCH rental USING INDEX idx_rental_member_due가 보이면 member_id 조건 검색에 복합 인덱스가 사용된 것이다.
```

### 쉬운 설명

이 쿼리는 `rental(member_id, due_date)`에 복합 인덱스를 만듭니다. 인덱스는 책 뒤쪽의 찾아보기와 비슷합니다. 모든 행을 처음부터 끝까지 훑지 않고, 자주 검색하는 기준으로 더 빠르게 찾을 수 있게 도와줍니다.

여기서는 회원별 대여 기록을 반납기한 순서로 보는 상황을 가정합니다. 그래서 `member_id`로 먼저 찾고, 같은 회원 안에서 `due_date` 순서로 보기 좋게 `member_id, due_date` 순서의 인덱스를 만들었습니다.

`EXPLAIN QUERY PLAN` 결과에 `SEARCH rental USING INDEX idx_rental_member_due`가 보입니다. 이는 SQLite가 실제 조회에 해당 인덱스를 사용하겠다고 판단했다는 뜻입니다.

### 평가 포인트

인덱스를 생성하는 것뿐 아니라, 실행 계획을 확인해 인덱스가 실제로 사용되는지 검증할 수 있는지 확인합니다.

### 실습 따라하기

```sql
CREATE INDEX IF NOT EXISTS idx_rental_member_due
ON rental(member_id, due_date);

EXPLAIN QUERY PLAN
SELECT rental_id, member_id, book_id, due_date, status
FROM rental
WHERE member_id = 1
ORDER BY due_date ASC;
```

### 핵심 키워드

`CREATE INDEX`, `복합 인덱스`, `EXPLAIN QUERY PLAN`, `검색 성능`
