# B5-1 Training Materials

이 폴더는 코디세이 B5-1 「SQL로 만드는 나만의 데이터베이스」 미션을 반복 훈련하기 위한 자료 공간이다.

제출용 산출물은 프로젝트 루트의 `sql/`, `docs/`, `results/`, `SUBMISSION.md`에 둔다. `training-materials/`는 **개념 정리, SQL 반복 연습, 오답 점검, 평가 답변 훈련, 제출 전 리뷰**를 위한 별도 공간으로 사용한다.

최종 목차와 평가 직전 루틴은 `README-final-index.md`에 정리되어 있다. 이 문서는 전체 훈련 자료의 입구 역할을 한다.

---

## 1. 훈련 목표

B5-1 평가 전까지 아래 내용을 스스로 설명하고 실행할 수 있도록 만든다.

1. 엑셀과 관계형 데이터베이스의 차이를 설명할 수 있다.
2. 테이블을 왜 나누는지 도메인 기준으로 설명할 수 있다.
3. PK, FK, UNIQUE, NOT NULL, CHECK 제약조건의 역할을 설명할 수 있다.
4. `member`, `category`, `book`, `rental`의 1:N 관계를 ERD 기준으로 설명할 수 있다.
5. `SELECT`, `WHERE`, `ORDER BY`, `LIMIT`을 사용해 기본 조회를 작성할 수 있다.
6. `INSERT`, `UPDATE`, `DELETE`를 실행 전 확인 절차와 함께 설명할 수 있다.
7. `INNER JOIN`과 `LEFT JOIN`의 차이를 실행 결과 기준으로 설명할 수 있다.
8. `GROUP BY`, `COUNT`, `SUM`, `AVG`, `HAVING`으로 집계 쿼리를 작성할 수 있다.
9. 서브쿼리와 JOIN 방식의 차이를 비교할 수 있다.
10. `rental(member_id, due_date)` 인덱스를 왜 만들었는지 설명할 수 있다.
11. `EXPLAIN QUERY PLAN` 결과에서 `SCAN`, `SEARCH`, `USING INDEX`의 의미를 구분할 수 있다.

---

## 2. 전체 폴더 구조

```text
training-materials/
├── README.md
├── README-final-index.md
├── 00-roadmap/
│   ├── b5-1-training-plan.md
│   └── daily-checklist.md
├── 01-sql-basics/
│   ├── select-where-order-limit.md
│   ├── insert-update-delete.md
│   └── practice.sql
├── 02-schema-design/
│   ├── table-design-notes.md
│   ├── pk-fk-constraints.md
│   ├── normalization-basic.md
│   └── erd-practice.md
├── 03-join-practice/
│   ├── inner-join.md
│   ├── left-join.md
│   ├── join-vs-subquery.md
│   └── join-practice.sql
├── 04-aggregation-practice/
│   ├── group-by-count-sum-avg.md
│   ├── ranking-query-practice.md
│   └── aggregation-practice.sql
├── 05-subquery-index/
│   ├── subquery-basic.md
│   ├── index-basic.md
│   └── explain-query-plan.md
├── 06-evaluation-qa/
│   ├── expected-questions.md
│   ├── answer-scripts.md
│   └── final-checklist.md
└── 07-review/
    ├── project-file-audit.md
    ├── score-self-review.md
    ├── refactor-todo.md
    ├── final-submit-commands.md
    ├── mvp-to-advanced-roadmap.md
    └── review-practice.sql
```

---

## 3. 빠른 사용법

| 상황 | 먼저 볼 파일 |
|---|---|
| 전체 학습 흐름 확인 | `README-final-index.md` |
| 오늘 할 일 확인 | `00-roadmap/daily-checklist.md` |
| SQL 기본기 복습 | `01-sql-basics/practice.sql` |
| 테이블 설계 설명 준비 | `02-schema-design/table-design-notes.md` |
| JOIN 설명 준비 | `03-join-practice/inner-join.md`, `03-join-practice/left-join.md` |
| GROUP BY 설명 준비 | `04-aggregation-practice/group-by-count-sum-avg.md` |
| 서브쿼리/인덱스 설명 준비 | `05-subquery-index/subquery-basic.md`, `05-subquery-index/index-basic.md` |
| 평가 예상 질문 준비 | `06-evaluation-qa/expected-questions.md` |
| 말하기 연습 | `06-evaluation-qa/answer-scripts.md` |
| 제출 전 최종 확인 | `06-evaluation-qa/final-checklist.md`, `07-review/final-submit-commands.md` |
| 감점 위험 점검 | `07-review/project-file-audit.md`, `07-review/score-self-review.md`, `07-review/refactor-todo.md` |

---

## 4. 학습 순서

처음부터 학습할 때는 아래 순서로 읽고 실행한다.

| 순서 | 파일 | 목적 |
|---:|---|---|
| 1 | `00-roadmap/b5-1-training-plan.md` | 전체 훈련 계획 확인 |
| 2 | `00-roadmap/daily-checklist.md` | 매일 반복할 점검표 확인 |
| 3 | `01-sql-basics/select-where-order-limit.md` | 기본 조회 개념 정리 |
| 4 | `01-sql-basics/insert-update-delete.md` | 데이터 입력, 수정, 삭제 안전성 정리 |
| 5 | `01-sql-basics/practice.sql` | 기본 SQL 반복 실행 |
| 6 | `02-schema-design/table-design-notes.md` | 테이블 분리 이유 정리 |
| 7 | `02-schema-design/pk-fk-constraints.md` | PK/FK/제약조건 설명 정리 |
| 8 | `02-schema-design/normalization-basic.md` | 중복 제거와 정규화 감각 정리 |
| 9 | `02-schema-design/erd-practice.md` | ERD를 보며 관계 설명 훈련 |
| 10 | `03-join-practice/inner-join.md` | INNER JOIN 설명과 예제 |
| 11 | `03-join-practice/left-join.md` | LEFT JOIN 설명과 예제 |
| 12 | `03-join-practice/join-vs-subquery.md` | JOIN과 서브쿼리 비교 |
| 13 | `03-join-practice/join-practice.sql` | JOIN 반복 연습 쿼리 |
| 14 | `04-aggregation-practice/group-by-count-sum-avg.md` | GROUP BY와 집계 함수 정리 |
| 15 | `04-aggregation-practice/ranking-query-practice.md` | TOP N, 정렬, 랭킹 쿼리 훈련 |
| 16 | `04-aggregation-practice/aggregation-practice.sql` | 집계 쿼리 반복 실행 |
| 17 | `05-subquery-index/subquery-basic.md` | 서브쿼리 기본 정리 |
| 18 | `05-subquery-index/index-basic.md` | 인덱스 기본 개념 정리 |
| 19 | `05-subquery-index/explain-query-plan.md` | 실행 계획 확인 훈련 |
| 20 | `06-evaluation-qa/expected-questions.md` | 예상 질문과 답변 확인 |
| 21 | `06-evaluation-qa/answer-scripts.md` | 15초, 30초, 1분, 2분 답변 연습 |
| 22 | `06-evaluation-qa/final-checklist.md` | 제출 전 최종 점검 |
| 23 | `07-review/project-file-audit.md` | 제출 파일 누락과 감점 위험 점검 |
| 24 | `07-review/review-practice.sql` | 최종 종합 SQL 복습 |
| 25 | `07-review/score-self-review.md` | 100점 기준 자가 채점 |
| 26 | `07-review/refactor-todo.md` | 제출 전 수정할 TODO 정리 |
| 27 | `07-review/final-submit-commands.md` | 최종 제출 명령 확인 |
| 28 | `07-review/mvp-to-advanced-roadmap.md` | 평가 후 고도화 방향 확인 |

---

## 5. 폴더별 작성 기준

### 5.1 `00-roadmap/`

훈련 전체 계획을 관리한다.

- 오늘 무엇을 할지 명확히 쓴다.
- 완료 여부를 체크박스로 남긴다.
- 평가 전까지 어떤 순서로 반복할지 기록한다.

핵심 질문:

- 오늘 설명 연습할 개념은 무엇인가?
- 오늘 직접 작성할 SQL은 몇 개인가?
- 오늘 막힌 오류나 약한 개념은 무엇인가?

### 5.2 `01-sql-basics/`

SQL 기본 문법과 안전한 DML 실행을 반복한다.

훈련 범위:

- `SELECT`, `WHERE`, `ORDER BY`, `LIMIT`
- `LIKE`, `IN`, `BETWEEN`, `IS NULL`
- `INSERT`, `UPDATE`, `DELETE`
- 실행 전 `SELECT` 확인과 트랜잭션 사용

원칙:

- 쿼리를 눈으로만 보지 않는다.
- 반드시 `book_rental.db`에 직접 실행한다.
- 실행 결과를 보고 쿼리 의미를 한 문장으로 설명한다.

### 5.3 `02-schema-design/`

테이블 설계와 관계를 설명하는 훈련 공간이다.

훈련 범위:

- 테이블을 나눈 이유
- PK와 FK의 차이
- 1:N 관계
- 제약조건
- 정규화와 ERD 설명

평가 핵심:

> “왜 `rental` 테이블을 따로 만들었나요?”라는 질문에 답할 수 있어야 한다.

### 5.4 `03-join-practice/`

JOIN 쿼리를 집중 훈련한다.

훈련 범위:

- `INNER JOIN`
- `LEFT JOIN`
- 2개 테이블 JOIN
- 3개 이상 테이블 JOIN
- JOIN과 서브쿼리 비교

평가 핵심:

> INNER JOIN은 매칭되는 행만 보여주고, LEFT JOIN은 왼쪽 테이블의 행을 유지한다.

### 5.5 `04-aggregation-practice/`

집계 쿼리를 반복한다.

훈련 범위:

- `COUNT`
- `SUM`
- `AVG`
- `GROUP BY`
- `HAVING`
- `ORDER BY`와 `LIMIT`을 활용한 TOP N 쿼리

평가 핵심:

> `GROUP BY`는 같은 기준의 행을 묶고, 집계 함수는 묶인 그룹별 계산을 수행한다.

### 5.6 `05-subquery-index/`

서브쿼리, 인덱스, 실행 계획을 설명하는 훈련 공간이다.

훈련 범위:

- 평균보다 비싼 도서 찾기
- 특정 조건에 해당하는 회원 찾기
- `IN`, `EXISTS`, `NOT EXISTS`, 상관 서브쿼리
- `CREATE INDEX`
- `EXPLAIN QUERY PLAN`

평가 핵심:

> `rental(member_id, due_date)` 인덱스는 특정 회원의 대여 기록을 반납기한 순으로 조회할 때 유리하다.

### 5.7 `06-evaluation-qa/`

평가 대비용 핵심 폴더다.

반드시 정리할 질문:

1. 엑셀과 DB는 무엇이 다른가?
2. 왜 테이블을 나누었는가?
3. PK와 FK는 무엇인가?
4. 1:N 관계는 어디에 있는가?
5. INNER JOIN과 LEFT JOIN은 무엇이 다른가?
6. GROUP BY와 집계 함수는 어떻게 동작하는가?
7. 서브쿼리는 언제 사용하는가?
8. 인덱스는 왜 필요한가?
9. 가장 복잡했던 쿼리는 무엇이고 어떻게 풀었는가?
10. 미션 중 어려웠던 점은 무엇이고 어떻게 해결했는가?

### 5.8 `07-review/`

제출 전 파일 누락, 감점 위험, 최종 실행 명령, 평가 후 고도화 방향을 점검한다.

확인 범위:

- 제출 파일이 모두 있는가?
- 실행 결과 파일이 최신인가?
- 감점 위험이 큰 P0 항목이 남아 있는가?
- `review-practice.sql`로 핵심 SQL을 다시 실행했는가?
- 평가 후 FastAPI, 인증, 배포로 확장할 방향이 정리되어 있는가?

---

## 6. 실습 실행 방법

프로젝트 루트에서 DB를 새로 생성한다.

```bash
chmod +x scripts/run_all.sh
./scripts/run_all.sh
```

DB 접속:

```bash
sqlite3 book_rental.db
```

SQLite 안에서 기본 설정:

```sql
.headers on
.mode column
PRAGMA foreign_keys = ON;
```

예시 쿼리:

```sql
SELECT * FROM member LIMIT 5;
SELECT * FROM book ORDER BY price DESC LIMIT 5;
SELECT * FROM rental WHERE status = 'OVERDUE';
```

종료:

```sql
.exit
```

---

## 7. 실행 가능한 연습 SQL

| 파일 | 실행 명령 | 목적 |
|---|---|---|
| `01-sql-basics/practice.sql` | `sqlite3 book_rental.db < training-materials/01-sql-basics/practice.sql` | 기본 조회와 안전 DML 복습 |
| `03-join-practice/join-practice.sql` | `sqlite3 book_rental.db < training-materials/03-join-practice/join-practice.sql` | JOIN, EXISTS, JOIN vs Subquery 복습 |
| `04-aggregation-practice/aggregation-practice.sql` | `sqlite3 book_rental.db < training-materials/04-aggregation-practice/aggregation-practice.sql` | GROUP BY, HAVING, TOP N 복습 |
| `07-review/review-practice.sql` | `sqlite3 book_rental.db < training-materials/07-review/review-practice.sql` | 평가 직전 종합 복습 |

주의:

> `07-review/review-practice.sql`은 UPDATE/DELETE 연습을 `SAVEPOINT` 후 `ROLLBACK`한다. 행 데이터 변경은 남기지 않지만, 핵심 인덱스가 없으면 `idx_rental_member_due`를 생성할 수 있다.

---

## 8. SQL 연습 원칙

연습 쿼리는 아래 형식으로 작성한다.

```sql
-- 목적: 30,000원 이상 도서를 가격 높은 순으로 조회한다.
SELECT book_id, title, price
FROM book
WHERE price >= 30000
ORDER BY price DESC;
```

각 쿼리 아래에는 반드시 한 줄 설명을 적는다.

```md
설명: `WHERE`로 가격 조건을 걸고, `ORDER BY`로 가격이 높은 순서로 정렬했다.
```

UPDATE/DELETE 연습은 아래 순서를 지킨다.

```text
1. SELECT로 대상 행을 먼저 확인한다.
2. WHERE 조건을 명확히 쓴다.
3. 가능하면 SAVEPOINT 또는 트랜잭션 안에서 실행한다.
4. 변경 결과를 SELECT로 다시 확인한다.
5. 연습 목적이면 ROLLBACK으로 원복한다.
```

---

## 9. 매일 반복 루틴

하루 60~90분 기준으로 반복한다.

```text
1. 기본 조회 SQL 3개 작성
2. JOIN SQL 2개 작성
3. GROUP BY SQL 1개 작성
4. 서브쿼리 또는 인덱스 관련 SQL 1개 작성
5. 평가 질문 3개를 말로 답변
6. 오류, 실수, 헷갈린 개념 1개 기록
7. Codex에게 오늘 작성한 SQL 리뷰 요청
```

---

## 10. 평가 직전 최종 점검

평가 전에 아래 항목을 모두 확인한다.

```text
[ ] README.md에서 프로젝트 주제를 설명할 수 있다.
[ ] SUBMISSION.md에서 제출 파일 위치를 바로 보여줄 수 있다.
[ ] sql/01_schema.sql에서 PK/FK/제약조건을 설명할 수 있다.
[ ] sql/02_seed.sql에서 부모 테이블을 먼저 INSERT한 이유를 설명할 수 있다.
[ ] sql/03_queries.sql에서 Q01~Q15를 범주별로 설명할 수 있다.
[ ] results/validation_results.txt에서 테이블별 10행 이상을 보여줄 수 있다.
[ ] results/query_results.txt에서 쿼리 실행 결과를 보여줄 수 있다.
[ ] docs/ERD.md에서 1:N 관계 3개를 설명할 수 있다.
[ ] docs/evaluation_answers.md를 보지 않고 핵심 질문에 답할 수 있다.
[ ] training-materials/06-evaluation-qa/final-checklist.md를 확인했다.
[ ] training-materials/07-review/review-practice.sql을 실행했다.
[ ] training-materials/07-review/refactor-todo.md의 P0 항목을 확인했다.
```

평가 직전에는 `README-final-index.md`의 30분 루틴과 5분 루틴을 우선 따른다.

---

## 11. 작성 진행 상태

현재 `training-materials/`의 문서와 SQL 스크립트는 모두 작성되어 있다. 앞으로는 “예정/완료” 상태표를 따로 유지하기보다 아래 기준으로 최신성을 점검한다.

```text
[ ] 실제 파일 구조와 README의 폴더 구조가 일치한다.
[ ] README-final-index.md의 학습 순서와 이 README의 안내가 충돌하지 않는다.
[ ] 실행 가능한 SQL 4개가 현재 스키마에서 정상 실행된다.
[ ] 06-evaluation-qa의 파일명은 answer-scripts.md, final-checklist.md로 유지된다.
[ ] 07-review의 제출 전 점검 문서가 최신 제출물과 일치한다.
```

---

## 12. 커밋 규칙

훈련 자료도 의미 있는 단위로 커밋한다.

권장 커밋 메시지:

```text
docs: update B5-1 training materials index
docs: add SQL basics practice notes
docs: add schema design training notes
docs: add join and aggregation practice
docs: add evaluation answer scripts
docs: add final review checklist
docs: update B5-1 review practice SQL
```
