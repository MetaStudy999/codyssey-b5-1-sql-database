# EXPLAIN QUERY PLAN 실행 계획 훈련

이 문서는 B5-1 도서 대여 관리 DB를 기준으로 SQLite의 `EXPLAIN QUERY PLAN`을 읽고, 인덱스 사용 여부를 평가 때 설명하기 위한 훈련 문서이다.

평가에서는 `CREATE INDEX`를 작성하는 것만으로는 부족하다. **왜 그 인덱스를 만들었는지**, **실제 조회 쿼리에 어떤 도움이 되는지**, **실행 계획에서 어떤 표현을 확인해야 하는지**까지 설명할 수 있어야 한다.

---

## 1. 한 줄 요약

```text
EXPLAIN QUERY PLAN은 SQLite가 SELECT를 실행할 때 테이블을 어떻게 읽고, 인덱스를 사용하는지 보여주는 확인 도구다.
```

평가 답변:

> `EXPLAIN QUERY PLAN`은 SQLite가 쿼리를 어떻게 실행할지 보여줍니다. 인덱스를 만들었다면 실행 계획에서 `USING INDEX` 같은 표현을 확인해 인덱스 사용 여부를 점검할 수 있습니다.

---

## 2. 기본 문법

```sql
EXPLAIN QUERY PLAN
SELECT 컬럼목록
FROM 테이블명
WHERE 조건
ORDER BY 정렬기준;
```

예시:

```sql
EXPLAIN QUERY PLAN
SELECT rental_id, member_id, book_id, due_date, status
FROM rental
WHERE member_id = 1
ORDER BY due_date ASC;
```

주의:

```text
EXPLAIN QUERY PLAN은 실제 결과 데이터를 보여주는 명령이 아니다.
SQLite가 어떤 방식으로 쿼리를 처리할지 계획을 보여준다.
```

---

## 3. B5-1 Q15의 핵심 구조

B5-1의 핵심 인덱스 쿼리는 다음 흐름이다.

```sql
CREATE INDEX IF NOT EXISTS idx_rental_member_due
ON rental(member_id, due_date);

EXPLAIN QUERY PLAN
SELECT rental_id, member_id, book_id, due_date, status
FROM rental
WHERE member_id = 1
ORDER BY due_date ASC;
```

이 쿼리의 의도:

```text
1. 특정 회원의 대여 기록을 찾는다.
2. 해당 회원의 대여 기록을 반납기한 순으로 본다.
3. member_id 검색과 due_date 정렬에 맞춘 복합 인덱스를 확인한다.
```

평가 답변:

> Q15는 특정 회원의 대여 기록을 반납기한 순으로 조회하는 시나리오입니다. 그래서 `rental(member_id, due_date)` 복합 인덱스를 만들고, `EXPLAIN QUERY PLAN`으로 이 조회에 인덱스가 쓰이는지 확인합니다.

---

## 4. 실행 전 준비

프로젝트 루트에서 DB를 새로 만든다.

```bash
chmod +x scripts/run_all.sh
./scripts/run_all.sh
```

SQLite 접속:

```bash
sqlite3 book_rental.db
```

SQLite 설정:

```sql
.headers on
.mode column
PRAGMA foreign_keys = ON;
```

인덱스 생성:

```sql
CREATE INDEX IF NOT EXISTS idx_rental_member_due
ON rental(member_id, due_date);
```

---

## 5. 실행 계획 확인 순서

아래 순서로 확인한다.

```sql
-- 1. 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_rental_member_due
ON rental(member_id, due_date);

-- 2. 인덱스 목록 확인
PRAGMA index_list('rental');

-- 3. 인덱스 컬럼 확인
PRAGMA index_info('idx_rental_member_due');

-- 4. 실행 계획 확인
EXPLAIN QUERY PLAN
SELECT rental_id, member_id, book_id, due_date, status
FROM rental
WHERE member_id = 1
ORDER BY due_date ASC;
```

평가 답변:

> 인덱스를 만든 뒤 `PRAGMA index_list`로 존재 여부를 확인하고, `PRAGMA index_info`로 어떤 컬럼으로 구성되었는지 확인합니다. 마지막으로 `EXPLAIN QUERY PLAN`으로 실제 조회 계획을 확인합니다.

---

## 6. 실행 계획 결과의 기본 형태

SQLite CLI에서는 보통 다음과 비슷한 형태로 나온다.

```text
QUERY PLAN
`--SEARCH rental USING INDEX idx_rental_member_due (member_id=?)
```

또는 SQLite 버전과 상황에 따라 다음처럼 보일 수 있다.

```text
id  parent  notused  detail
--  ------  -------  -----------------------------------------------
4   0       0        SEARCH rental USING INDEX idx_rental_member_due
```

주의:

```text
SQLite 버전, 데이터 양, 쿼리 형태에 따라 detail 문구는 조금 다를 수 있다.
따라서 정확한 문자열을 외우기보다 SCAN, SEARCH, USING INDEX의 의미를 이해하는 것이 중요하다.
```

---

## 7. 핵심 표현 읽기

| 표현 | 의미 | 평가 해석 |
|---|---|---|
| `SCAN rental` | rental 테이블을 넓게 훑음 | 조건에 맞는 행을 찾기 위해 많이 읽을 수 있음 |
| `SEARCH rental` | 조건을 이용해 필요한 행을 찾음 | 조건 검색이 적용됨 |
| `USING INDEX idx_rental_member_due` | 해당 인덱스를 사용 | 인덱스가 조회에 활용됨 |
| `USING COVERING INDEX` | 인덱스만으로 필요한 컬럼 처리 가능 | 테이블 접근이 줄어들 수 있음 |
| `USE TEMP B-TREE FOR ORDER BY` | 정렬을 위해 임시 구조 사용 | ORDER BY 최적화가 충분하지 않을 수 있음 |

평가 답변:

> `SEARCH`와 `USING INDEX`가 보이면 조건 검색에 인덱스가 활용된 것으로 볼 수 있습니다. 반대로 `SCAN`은 테이블을 넓게 읽는다는 의미라서, 조건 검색에서는 인덱스 사용 여부를 확인해야 합니다.

---

## 8. SCAN과 SEARCH의 차이

### 8.1 SCAN

```text
테이블 또는 인덱스를 넓게 훑는 방식
```

예상되는 상황:

```sql
EXPLAIN QUERY PLAN
SELECT rental_id, member_id, book_id, due_date, status
FROM rental
ORDER BY due_date ASC;
```

설명:

> `member_id` 조건 없이 전체 rental을 due_date 순으로 보려는 쿼리다. `idx_rental_member_due`의 첫 컬럼이 `member_id`이므로 이 인덱스가 기대만큼 맞지 않을 수 있다.

---

### 8.2 SEARCH

```text
조건을 이용해 필요한 범위를 찾는 방식
```

예상되는 상황:

```sql
EXPLAIN QUERY PLAN
SELECT rental_id, member_id, book_id, due_date, status
FROM rental
WHERE member_id = 1
ORDER BY due_date ASC;
```

설명:

> `member_id = 1` 조건이 있으므로 `idx_rental_member_due`의 첫 컬럼을 활용하기 좋은 형태다.

평가 답변:

> `SCAN`은 넓게 훑는 느낌이고, `SEARCH`는 조건을 이용해 필요한 범위를 찾는 느낌입니다. Q15는 `member_id` 조건이 있으므로 인덱스를 사용한 `SEARCH`가 기대됩니다.

---

## 9. 복합 인덱스와 실행 계획

현재 인덱스:

```sql
CREATE INDEX IF NOT EXISTS idx_rental_member_due
ON rental(member_id, due_date);
```

이 인덱스에 잘 맞는 쿼리:

```sql
SELECT rental_id, member_id, book_id, due_date, status
FROM rental
WHERE member_id = 1
ORDER BY due_date ASC;
```

이유:

```text
member_id → WHERE 조건
 due_date → ORDER BY 조건
```

컬럼 순서 관점:

```text
member_id로 먼저 좁힌다.
그 안에서 due_date 순으로 읽는다.
```

평가 답변:

> 복합 인덱스는 컬럼 순서가 중요합니다. `member_id, due_date` 순서로 만들었기 때문에 `WHERE member_id = 1 ORDER BY due_date` 형태에 잘 맞습니다.

---

## 10. 인덱스가 덜 맞는 쿼리 예시

### 10.1 member_id 없이 due_date만 조회

```sql
EXPLAIN QUERY PLAN
SELECT rental_id, member_id, book_id, due_date, status
FROM rental
WHERE due_date <= '2024-07-01'
ORDER BY due_date ASC;
```

설명:

> 인덱스가 `member_id, due_date` 순서이므로 `member_id` 없이 `due_date`만 사용하는 조건에는 기대만큼 적합하지 않을 수 있다.

---

### 10.2 ORDER BY 방향이 다르거나 조건이 복잡한 경우

```sql
EXPLAIN QUERY PLAN
SELECT rental_id, member_id, book_id, due_date, status
FROM rental
WHERE member_id = 1
ORDER BY status ASC;
```

설명:

> 인덱스의 두 번째 컬럼은 `due_date`인데, 정렬 기준이 `status`라서 정렬 최적화에는 직접 맞지 않을 수 있다.

평가 답변:

> 인덱스는 만든 컬럼 순서와 실제 쿼리의 WHERE, ORDER BY 패턴이 맞을 때 효과가 큽니다. 아무 조건이나 정렬에 항상 같은 효과를 내는 것은 아닙니다.

---

## 11. 인덱스 생성 전후 비교 실습

주의:

```text
이미 run_all.sh나 Q15를 실행했다면 인덱스가 이미 존재할 수 있다.
정확한 전후 비교를 하려면 연습용 DB를 복사해서 테스트한다.
```

연습용 DB:

```bash
cp book_rental.db explain_practice.db
sqlite3 explain_practice.db
```

인덱스 삭제:

```sql
DROP INDEX IF EXISTS idx_rental_member_due;
```

인덱스 없는 상태 실행 계획:

```sql
EXPLAIN QUERY PLAN
SELECT rental_id, member_id, book_id, due_date, status
FROM rental
WHERE member_id = 1
ORDER BY due_date ASC;
```

인덱스 생성:

```sql
CREATE INDEX IF NOT EXISTS idx_rental_member_due
ON rental(member_id, due_date);
```

인덱스 있는 상태 실행 계획:

```sql
EXPLAIN QUERY PLAN
SELECT rental_id, member_id, book_id, due_date, status
FROM rental
WHERE member_id = 1
ORDER BY due_date ASC;
```

비교할 것:

```text
인덱스 없을 때: SCAN 또는 임시 정렬 가능성 확인
인덱스 있을 때: USING INDEX idx_rental_member_due 확인
```

---

## 12. 실행 계획을 읽을 때 주의할 점

```text
실행 계획 문구는 SQLite 버전에 따라 조금 달라질 수 있다.
작은 데이터에서는 인덱스 효과가 체감되지 않을 수 있다.
DB 옵티마이저가 항상 내가 예상한 인덱스를 선택하는 것은 아니다.
인덱스는 성능을 보장하는 마법이 아니라 조회 패턴을 돕는 구조다.
```

평가 답변:

> 실행 계획은 DB가 선택한 실행 방식을 보여주는 참고 자료입니다. 데이터가 작으면 차이가 크지 않을 수 있고, SQLite 버전에 따라 표현도 조금 다를 수 있습니다. 그래서 핵심은 인덱스가 어떤 조회 패턴에 맞는지 설명하는 것입니다.

---

## 13. Q15를 평가에서 설명하는 순서

```text
1. 조회 시나리오를 먼저 말한다.
2. 특정 회원의 대여 기록을 반납기한 순으로 조회한다고 설명한다.
3. 그래서 rental(member_id, due_date)에 복합 인덱스를 만들었다고 말한다.
4. member_id는 WHERE 조건, due_date는 ORDER BY 조건에 대응한다고 설명한다.
5. EXPLAIN QUERY PLAN으로 인덱스 사용 여부를 확인한다고 말한다.
6. 인덱스는 조회에는 좋지만 쓰기 비용이 있어서 필요한 컬럼에만 만든다고 덧붙인다.
```

---

## 14. 1분 설명 스크립트

> 이 프로젝트에서는 회원별 대여 기록을 반납기한 순으로 조회하는 상황을 고려해 `rental(member_id, due_date)`에 `idx_rental_member_due`라는 복합 인덱스를 만들었습니다. `member_id`는 `WHERE member_id = 1` 조건으로 특정 회원을 찾는 데 사용되고, `due_date`는 그 회원의 대여 기록을 반납기한 순으로 정렬하는 데 사용됩니다. 인덱스 생성 후 `EXPLAIN QUERY PLAN`을 실행하면 SQLite가 이 쿼리를 어떤 방식으로 처리하는지 확인할 수 있습니다. 실행 계획에서 `USING INDEX idx_rental_member_due` 같은 표현이 보이면 해당 인덱스가 활용된 것으로 설명할 수 있습니다. 다만 인덱스는 저장 공간과 갱신 비용이 있으므로 모든 컬럼에 만드는 것이 아니라 자주 조회되는 패턴에 맞춰 선택적으로 만들어야 합니다.

---

## 15. 30초 설명 스크립트

> `EXPLAIN QUERY PLAN`은 SQLite가 쿼리를 어떻게 실행할지 보여주는 명령입니다. 이 프로젝트에서는 `rental(member_id, due_date)` 인덱스를 만들고, 특정 회원의 대여 기록을 반납기한 순으로 조회하는 쿼리에 인덱스가 쓰이는지 확인합니다. `member_id`는 WHERE 조건, `due_date`는 ORDER BY 조건에 대응합니다.

---

## 16. 직접 연습 문제

```text
[ ] 1. EXPLAIN QUERY PLAN을 한 문장으로 설명한다.
[ ] 2. idx_rental_member_due를 생성한다.
[ ] 3. PRAGMA index_list('rental')로 인덱스 목록을 확인한다.
[ ] 4. PRAGMA index_info('idx_rental_member_due')로 컬럼을 확인한다.
[ ] 5. Q15 조회 쿼리의 실행 계획을 확인한다.
[ ] 6. 실행 계획에서 SCAN, SEARCH, USING INDEX를 찾아본다.
[ ] 7. member_id 없이 due_date만 쓰는 쿼리의 실행 계획을 비교한다.
[ ] 8. 왜 복합 인덱스 컬럼 순서가 중요한지 설명한다.
[ ] 9. 인덱스 생성 전후 실행 계획을 비교한다.
[ ] 10. 1분 설명 스크립트를 소리 내어 읽는다.
```

---

## 17. 자주 하는 실수

### 17.1 EXPLAIN QUERY PLAN이 결과 데이터를 보여준다고 착각

틀린 설명:

> EXPLAIN QUERY PLAN은 SELECT 결과를 보여줍니다.

올바른 설명:

> EXPLAIN QUERY PLAN은 SELECT 결과가 아니라 실행 계획을 보여줍니다.

---

### 17.2 USING INDEX만 외우고 왜 쓰는지 설명하지 못함

외워야 할 표현보다 중요한 것:

```text
어떤 조회 패턴 때문에 이 인덱스가 필요한가?
```

좋은 답변:

> 특정 회원의 대여 기록을 반납기한 순으로 조회하기 때문에 `member_id`, `due_date` 순서의 복합 인덱스를 만들었습니다.

---

### 17.3 인덱스를 만들면 무조건 빠르다고 설명

정확한 설명:

> 인덱스는 조회에 도움을 줄 수 있지만 데이터 양, 쿼리 조건, 인덱스 컬럼 순서에 따라 효과가 달라집니다. 또한 쓰기 작업 때 갱신 비용이 있습니다.

---

### 17.4 복합 인덱스 순서 무시

```sql
ON rental(member_id, due_date)
```

설명 포인트:

```text
WHERE member_id = 1
ORDER BY due_date ASC
```

이 두 조건에 맞춰 순서를 잡았다고 설명한다.

---

## 18. 평가 예상 질문과 답변

### 질문 1. EXPLAIN QUERY PLAN은 무엇인가요?

> SQLite가 쿼리를 어떤 방식으로 실행할지 보여주는 명령입니다. 테이블을 스캔하는지, 인덱스를 사용하는지 확인할 수 있습니다.

### 질문 2. 실행 계획에서 무엇을 봐야 하나요?

> `SCAN`, `SEARCH`, `USING INDEX`, `USE TEMP B-TREE` 같은 표현을 봅니다. 특히 인덱스를 확인할 때는 `USING INDEX idx_rental_member_due` 같은 표현을 확인합니다.

### 질문 3. Q15 인덱스는 어떤 쿼리를 위한 것인가요?

> 특정 회원의 대여 기록을 반납기한 순으로 조회하는 쿼리를 위한 것입니다. `member_id`는 WHERE 조건이고, `due_date`는 ORDER BY 조건입니다.

### 질문 4. 왜 복합 인덱스 순서가 중요한가요?

> 복합 인덱스는 앞쪽 컬럼부터 활용되는 경우가 많습니다. `member_id, due_date` 순서로 만들었기 때문에 `member_id`로 먼저 좁히고 그 안에서 `due_date` 순으로 조회하는 쿼리에 적합합니다.

### 질문 5. 실행 계획에 SCAN이 나오면 무조건 나쁜가요?

> 항상 나쁜 것은 아닙니다. 작은 테이블에서는 SCAN이 충분할 수 있고, 전체 데이터를 읽어야 하는 쿼리에서는 자연스러울 수 있습니다. 다만 조건 검색에서 인덱스를 기대했다면 왜 SCAN이 나왔는지 확인해야 합니다.

---

## 19. 오늘의 완료 기준

```text
[ ] EXPLAIN QUERY PLAN의 역할을 설명했다.
[ ] Q15 인덱스 생성 쿼리를 직접 실행했다.
[ ] Q15 SELECT 실행 계획을 확인했다.
[ ] SCAN과 SEARCH 차이를 설명했다.
[ ] USING INDEX의 의미를 설명했다.
[ ] 복합 인덱스 컬럼 순서를 설명했다.
[ ] 인덱스가 덜 맞는 쿼리 예시를 설명했다.
[ ] 1분 설명 스크립트를 소리 내어 읽었다.
```
