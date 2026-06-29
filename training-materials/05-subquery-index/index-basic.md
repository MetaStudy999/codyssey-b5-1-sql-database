# 인덱스 기본 훈련

이 문서는 B5-1 도서 대여 관리 DB를 기준으로 인덱스의 기본 개념, 적용 위치, `EXPLAIN QUERY PLAN` 확인 방법을 정리한 문서이다.

평가에서는 인덱스 문법만 말하는 것보다, **왜 해당 컬럼에 인덱스를 만들었는지**, **어떤 조회 패턴을 빠르게 하기 위한 것인지**, **인덱스가 항상 좋은 것은 아닌 이유**, **실행 계획으로 어떻게 확인하는지**를 설명할 수 있어야 한다.

---

## 1. 인덱스 한 줄 요약

```text
인덱스는 테이블에서 특정 컬럼 값을 더 빨리 찾기 위한 검색용 자료구조다.
```

평가 답변:

> 인덱스는 책의 목차나 색인처럼 데이터를 빠르게 찾기 위한 구조입니다. 이 프로젝트에서는 특정 회원의 대여 기록을 반납기한 순으로 자주 조회한다고 보고 `rental(member_id, due_date)`에 인덱스를 만들었습니다.

---

## 2. 왜 인덱스가 필요한가?

인덱스가 없으면 DB는 조건에 맞는 행을 찾기 위해 테이블을 처음부터 끝까지 확인할 수 있다.

예:

```sql
SELECT rental_id, member_id, book_id, due_date, status
FROM rental
WHERE member_id = 1
ORDER BY due_date ASC;
```

이 쿼리는 두 가지 작업을 한다.

```text
1. member_id = 1인 대여 기록을 찾는다.
2. 그 결과를 due_date 오름차순으로 정렬한다.
```

따라서 `member_id`와 `due_date`를 함께 고려한 인덱스가 있으면 유리하다.

---

## 3. B5-1에서 만든 명시적 인덱스

현재 핵심 쿼리 Q15에서는 아래 인덱스를 생성한다.

```sql
CREATE INDEX IF NOT EXISTS idx_rental_member_due
ON rental(member_id, due_date);
```

의미:

| 항목 | 설명 |
|---|---|
| `idx_rental_member_due` | 인덱스 이름 |
| `rental` | 인덱스를 만드는 테이블 |
| `member_id` | 첫 번째 정렬/검색 기준 |
| `due_date` | 두 번째 정렬/검색 기준 |

평가 답변:

> `idx_rental_member_due`는 `rental` 테이블의 `member_id`, `due_date`에 만든 복합 인덱스입니다. 특정 회원의 대여 기록을 찾고 반납기한 순으로 정렬하는 조회를 빠르게 하기 위한 인덱스입니다.

---

## 4. 왜 member_id가 먼저인가?

복합 인덱스는 컬럼 순서가 중요하다.

```sql
ON rental(member_id, due_date)
```

이 순서는 다음 조회 패턴에 맞다.

```sql
WHERE member_id = 1
ORDER BY due_date ASC
```

읽는 법:

```text
1. 먼저 member_id = 1인 범위를 빠르게 찾는다.
2. 그 안에서 due_date 순서로 조회한다.
```

평가 답변:

> 이 조회는 먼저 특정 회원을 찾고, 그 회원의 대여 기록을 반납기한 순으로 봅니다. 그래서 복합 인덱스의 첫 컬럼을 `member_id`, 두 번째 컬럼을 `due_date`로 두었습니다.

---

## 5. 인덱스 적용 대상 쿼리

Q15의 실제 조회 쿼리는 아래와 같다.

```sql
EXPLAIN QUERY PLAN
SELECT rental_id, member_id, book_id, due_date, status
FROM rental
WHERE member_id = 1
ORDER BY due_date ASC;
```

이 쿼리에서 인덱스가 기대되는 이유:

```text
WHERE member_id = 1       → member_id 검색에 도움
ORDER BY due_date ASC     → 같은 member_id 안에서 due_date 정렬에 도움
```

평가 답변:

> 이 쿼리는 `member_id` 조건과 `due_date` 정렬을 동시에 사용합니다. 그래서 `rental(member_id, due_date)` 복합 인덱스가 이 조회 패턴에 적합합니다.

---

## 6. EXPLAIN QUERY PLAN

SQLite에서는 `EXPLAIN QUERY PLAN`으로 쿼리 실행 계획을 확인할 수 있다.

```sql
EXPLAIN QUERY PLAN
SELECT rental_id, member_id, book_id, due_date, status
FROM rental
WHERE member_id = 1
ORDER BY due_date ASC;
```

확인 포인트:

```text
SEARCH rental USING INDEX idx_rental_member_due
USING INDEX
USING COVERING INDEX
SCAN rental
USE TEMP B-TREE FOR ORDER BY
```

해석:

| 표현 | 대략적 의미 |
|---|---|
| `SEARCH ... USING INDEX` | 인덱스를 사용해 조건 검색 |
| `SCAN` | 테이블 또는 인덱스를 넓게 훑음 |
| `USE TEMP B-TREE FOR ORDER BY` | 정렬을 위해 임시 구조 사용 가능 |
| `COVERING INDEX` | 필요한 컬럼을 인덱스만으로 처리 가능 |

평가 답변:

> `EXPLAIN QUERY PLAN`은 SQLite가 쿼리를 어떻게 실행할지 보여줍니다. 인덱스가 사용되면 `USING INDEX` 같은 표현을 확인할 수 있습니다.

---

## 7. 단일 인덱스와 복합 인덱스

### 7.1 단일 인덱스

한 컬럼에만 만든 인덱스다.

```sql
CREATE INDEX idx_rental_member
ON rental(member_id);
```

적합한 조회:

```sql
SELECT *
FROM rental
WHERE member_id = 1;
```

---

### 7.2 복합 인덱스

여러 컬럼을 함께 묶은 인덱스다.

```sql
CREATE INDEX idx_rental_member_due
ON rental(member_id, due_date);
```

적합한 조회:

```sql
SELECT *
FROM rental
WHERE member_id = 1
ORDER BY due_date ASC;
```

평가 답변:

> 단일 인덱스는 한 컬럼 검색에 적합하고, 복합 인덱스는 여러 컬럼이 함께 사용되는 조회 패턴에 적합합니다. 이 프로젝트에서는 회원별 반납기한 조회를 고려해 복합 인덱스를 사용했습니다.

---

## 8. 복합 인덱스의 왼쪽 우선 원칙

복합 인덱스는 보통 앞쪽 컬럼부터 잘 활용된다.

```sql
CREATE INDEX idx_rental_member_due
ON rental(member_id, due_date);
```

잘 맞는 조건:

```sql
WHERE member_id = 1
```

```sql
WHERE member_id = 1
ORDER BY due_date ASC
```

상대적으로 덜 맞는 조건:

```sql
WHERE due_date <= '2024-07-01'
```

이유:

> 인덱스의 첫 번째 컬럼이 `member_id`이므로, `member_id` 없이 `due_date`만 조건으로 쓰는 조회에는 기대만큼 유리하지 않을 수 있다.

평가 답변:

> 복합 인덱스는 컬럼 순서가 중요합니다. `member_id, due_date` 순서로 만들었기 때문에 `member_id` 조건이 포함된 조회에 특히 적합합니다.

---

## 9. 인덱스와 PK/UNIQUE

스키마에는 다음 제약조건이 있다.

```sql
member_id INTEGER PRIMARY KEY
email TEXT NOT NULL UNIQUE
category_id INTEGER PRIMARY KEY
name TEXT NOT NULL UNIQUE
book_id INTEGER PRIMARY KEY
isbn TEXT NOT NULL UNIQUE
rental_id INTEGER PRIMARY KEY
```

의미:

| 제약조건 | 인덱스 관점 |
|---|---|
| `PRIMARY KEY` | 행을 빠르게 식별하는 기준 |
| `UNIQUE` | 중복 검사를 위해 DB가 빠른 조회 구조를 활용 |
| 명시적 `CREATE INDEX` | 개발자가 특정 조회 패턴을 위해 직접 생성 |

주의:

> PK/UNIQUE는 무결성 제약조건이고, 명시적 인덱스는 조회 성능 개선 목적이 더 강하다. 실제 DB 내부 구현은 DBMS마다 다를 수 있다.

평가 답변:

> PK와 UNIQUE는 데이터 무결성을 보장하면서 빠른 식별과 중복 검사에도 도움을 줍니다. 다만 Q15의 `idx_rental_member_due`는 특정 조회 패턴을 빠르게 하기 위해 직접 만든 명시적 인덱스입니다.

---

## 10. 인덱스가 항상 좋은 것은 아닌 이유

인덱스는 조회를 빠르게 할 수 있지만 비용도 있다.

```text
인덱스 저장 공간이 추가로 필요하다.
INSERT/UPDATE/DELETE 때 인덱스도 함께 갱신해야 한다.
너무 많은 인덱스는 오히려 쓰기 성능과 관리성을 떨어뜨릴 수 있다.
작은 테이블에서는 체감 효과가 작을 수 있다.
```

평가 답변:

> 인덱스는 조회에는 유리하지만 저장 공간과 갱신 비용이 있습니다. 그래서 모든 컬럼에 만드는 것이 아니라 자주 검색하거나 정렬하는 컬럼에 선택적으로 만드는 것이 좋습니다.

---

## 11. 어떤 컬럼에 인덱스를 만들면 좋은가?

인덱스 후보가 되는 컬럼:

```text
WHERE 조건에 자주 등장하는 컬럼
JOIN 조건에 자주 쓰이는 FK 컬럼
ORDER BY에 자주 쓰이는 컬럼
GROUP BY에 자주 쓰이는 컬럼
선택도가 높은 컬럼
```

B5-1 예시:

| 조회 패턴 | 인덱스 후보 | 이유 |
|---|---|---|
| 특정 회원의 대여 기록 조회 | `rental(member_id)` | WHERE 조건 |
| 특정 회원의 대여 기록을 반납기한 순 조회 | `rental(member_id, due_date)` | WHERE + ORDER BY |
| 특정 도서의 대여 이력 조회 | `rental(book_id)` | FK 기반 검색 |
| 카테고리별 도서 조회 | `book(category_id)` | FK 기반 검색 |

주의:

> 후보라고 해서 모두 만드는 것이 아니라, 실제 조회 빈도와 데이터 규모를 고려해야 한다.

---

## 12. 현재 프로젝트에서 Q15가 좋은 이유

Q15는 B5-1 평가 요구사항 중 인덱스를 설명하기 좋은 예다.

```sql
CREATE INDEX IF NOT EXISTS idx_rental_member_due
ON rental(member_id, due_date);
```

이후 실행 계획 확인:

```sql
EXPLAIN QUERY PLAN
SELECT rental_id, member_id, book_id, due_date, status
FROM rental
WHERE member_id = 1
ORDER BY due_date ASC;
```

좋은 점:

```text
명확한 조회 시나리오가 있다.
WHERE와 ORDER BY가 함께 있다.
복합 인덱스의 컬럼 순서를 설명할 수 있다.
EXPLAIN QUERY PLAN으로 확인할 수 있다.
```

평가 답변:

> Q15는 단순히 인덱스를 만들기 위한 쿼리가 아니라, 회원별 반납기한 조회라는 시나리오에 맞춘 인덱스입니다. `member_id`로 회원을 찾고 `due_date`로 정렬하므로 `rental(member_id, due_date)`가 적절합니다.

---

## 13. 인덱스 생성 문법

```sql
CREATE INDEX 인덱스명
ON 테이블명(컬럼명);
```

복합 인덱스:

```sql
CREATE INDEX 인덱스명
ON 테이블명(컬럼1, 컬럼2);
```

중복 생성 방지:

```sql
CREATE INDEX IF NOT EXISTS idx_rental_member_due
ON rental(member_id, due_date);
```

평가 답변:

> `IF NOT EXISTS`를 사용하면 같은 이름의 인덱스가 이미 있을 때 오류 없이 넘어갈 수 있습니다. 자동 실행 스크립트에서 반복 실행할 때 안전합니다.

---

## 14. 인덱스 목록 확인

SQLite에서 특정 테이블의 인덱스 목록을 확인할 수 있다.

```sql
PRAGMA index_list('rental');
```

특정 인덱스의 컬럼 확인:

```sql
PRAGMA index_info('idx_rental_member_due');
```

평가 답변:

> `PRAGMA index_list`로 테이블의 인덱스 목록을 확인하고, `PRAGMA index_info`로 특정 인덱스가 어떤 컬럼으로 구성되었는지 확인할 수 있습니다.

---

## 15. 인덱스 실습 순서

SQLite에서 다음 순서로 확인한다.

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

---

## 16. 직접 연습 문제

```text
[ ] 1. 인덱스를 한 문장으로 설명한다.
[ ] 2. idx_rental_member_due가 어떤 테이블에 생성되는지 말한다.
[ ] 3. idx_rental_member_due의 컬럼 2개를 말한다.
[ ] 4. 왜 member_id가 첫 번째 컬럼인지 설명한다.
[ ] 5. 왜 due_date가 두 번째 컬럼인지 설명한다.
[ ] 6. Q15 조회 쿼리를 직접 실행한다.
[ ] 7. EXPLAIN QUERY PLAN 결과를 확인한다.
[ ] 8. PRAGMA index_list('rental')을 실행한다.
[ ] 9. PRAGMA index_info('idx_rental_member_due')를 실행한다.
[ ] 10. 인덱스가 항상 좋은 것은 아닌 이유를 설명한다.
```

---

## 17. 자주 하는 실수

### 17.1 조회 시나리오 없이 인덱스를 만드는 경우

나쁜 설명:

> 빠르니까 그냥 만들었습니다.

좋은 설명:

> 특정 회원의 대여 기록을 반납기한 순으로 조회하는 쿼리가 있으므로 `member_id`, `due_date`에 복합 인덱스를 만들었습니다.

---

### 17.2 복합 인덱스 컬럼 순서를 설명하지 못하는 경우

```sql
ON rental(member_id, due_date)
```

설명해야 할 것:

```text
member_id로 먼저 특정 회원을 좁힌다.
그 회원의 기록을 due_date 순으로 정렬한다.
```

---

### 17.3 인덱스를 모든 컬럼에 만들면 좋다고 말하는 경우

틀린 설명:

> 모든 컬럼에 인덱스를 만들면 가장 빠릅니다.

좋은 설명:

> 인덱스는 조회에는 도움이 되지만 저장 공간과 쓰기 비용이 있으므로 자주 검색·정렬하는 컬럼에 선택적으로 만들어야 합니다.

---

### 17.4 EXPLAIN QUERY PLAN을 실행하지 않는 경우

인덱스 설명은 실행 계획 확인까지 연결하면 좋다.

```sql
EXPLAIN QUERY PLAN
SELECT rental_id, member_id, book_id, due_date, status
FROM rental
WHERE member_id = 1
ORDER BY due_date ASC;
```

---

## 18. 평가 예상 질문과 답변

### 질문 1. 인덱스는 무엇인가요?

> 인덱스는 테이블에서 특정 값을 더 빠르게 찾기 위한 검색용 자료구조입니다. 책의 색인처럼 조건에 맞는 행을 빠르게 찾도록 도와줍니다.

### 질문 2. 이 프로젝트에서는 어떤 인덱스를 만들었나요?

> `idx_rental_member_due`라는 인덱스를 `rental(member_id, due_date)`에 만들었습니다.

### 질문 3. 왜 `rental(member_id, due_date)`에 인덱스를 만들었나요?

> 특정 회원의 대여 기록을 찾고 그 결과를 반납기한 순으로 정렬하는 조회가 있기 때문입니다. `member_id`는 WHERE 조건에 쓰이고, `due_date`는 ORDER BY에 쓰입니다.

### 질문 4. EXPLAIN QUERY PLAN은 왜 사용하나요?

> SQLite가 쿼리를 어떻게 실행할지 확인하기 위해 사용합니다. 인덱스를 사용하는지, 테이블을 스캔하는지 같은 실행 계획을 볼 수 있습니다.

### 질문 5. 인덱스는 항상 많이 만들수록 좋은가요?

> 아닙니다. 인덱스는 조회에는 도움이 되지만 저장 공간과 INSERT/UPDATE/DELETE 시 갱신 비용이 있습니다. 그래서 자주 조회되는 컬럼에 선택적으로 만드는 것이 좋습니다.

---

## 19. 30초 답변 연습

> 인덱스는 데이터를 빠르게 찾기 위한 검색용 자료구조입니다. 이 프로젝트에서는 특정 회원의 대여 기록을 반납기한 순으로 조회하는 쿼리를 고려해 `rental(member_id, due_date)`에 `idx_rental_member_due` 인덱스를 만들었습니다. `member_id`는 WHERE 조건에서 특정 회원을 찾는 데 쓰이고, `due_date`는 ORDER BY 정렬에 쓰입니다. 인덱스가 실제로 사용되는지는 `EXPLAIN QUERY PLAN`으로 확인할 수 있습니다. 다만 인덱스는 저장 공간과 갱신 비용이 있으므로 필요한 컬럼에만 선택적으로 만드는 것이 좋습니다.

---

## 20. 오늘의 완료 기준

```text
[ ] 인덱스를 한 문장으로 설명했다.
[ ] idx_rental_member_due 이름을 말할 수 있다.
[ ] rental(member_id, due_date)의 의미를 설명했다.
[ ] member_id가 WHERE 조건에 쓰임을 설명했다.
[ ] due_date가 ORDER BY에 쓰임을 설명했다.
[ ] EXPLAIN QUERY PLAN을 설명했다.
[ ] PRAGMA index_list와 PRAGMA index_info를 설명했다.
[ ] 인덱스의 장점과 비용을 함께 설명했다.
[ ] 30초 답변을 소리 내어 연습했다.
```
