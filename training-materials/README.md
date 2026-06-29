# B5-1 Training Materials

이 폴더는 코디세이 B5-1 「SQL로 만드는 나만의 데이터베이스」 미션을 반복 훈련하기 위한 자료 공간이다.

제출용 산출물은 프로젝트 루트의 `sql/`, `docs/`, `results/`, `SUBMISSION.md`에 둔다. `training-materials/`는 **개념 정리, SQL 반복 연습, 오답 기록, 평가 답변 훈련**을 위한 별도 공간으로 사용한다.

---

## 1. 훈련 목표

B5-1 평가 전까지 아래 내용을 스스로 설명하고 실행할 수 있도록 만든다.

1. 엑셀과 관계형 데이터베이스의 차이를 설명할 수 있다.
2. 테이블을 왜 나누는지 도메인 기준으로 설명할 수 있다.
3. PK, FK, UNIQUE, NOT NULL, CHECK 제약조건의 역할을 설명할 수 있다.
4. `member`, `category`, `book`, `rental`의 1:N 관계를 ERD 기준으로 설명할 수 있다.
5. `SELECT`, `WHERE`, `ORDER BY`, `LIMIT`을 사용해 기본 조회를 작성할 수 있다.
6. `INNER JOIN`과 `LEFT JOIN`의 차이를 실행 결과 기준으로 설명할 수 있다.
7. `GROUP BY`, `COUNT`, `SUM`, `AVG`로 집계 쿼리를 작성할 수 있다.
8. 서브쿼리와 JOIN 방식의 차이를 비교할 수 있다.
9. `UPDATE`, `DELETE`의 영향 범위를 확인하고 안전하게 실행할 수 있다.
10. 인덱스를 어느 컬럼에 적용했는지, 왜 필요한지 설명할 수 있다.

---

## 2. 전체 폴더 구조

```text
training-materials/
├── README.md
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
│   ├── answer-script.md
│   └── self-review-checklist.md
├── 07-error-notes/
│   ├── sqlite-errors.md
│   ├── fk-error-practice.md
│   └── mistakes-log.md
└── 08-codex-prompts/
    ├── review-repo-prompt.md
    ├── improve-sql-prompt.md
    └── generate-practice-prompt.md
```

---

## 3. 작성 순서

아래 순서대로 작성한다. 앞 단계가 다음 단계의 기반이 되므로 번호를 유지한다.

| 순서 | 파일 | 목적 |
|---:|---|---|
| 1 | `00-roadmap/b5-1-training-plan.md` | 전체 훈련 계획 수립 |
| 2 | `00-roadmap/daily-checklist.md` | 매일 반복할 점검표 작성 |
| 3 | `01-sql-basics/select-where-order-limit.md` | 기본 조회 개념 정리 |
| 4 | `01-sql-basics/insert-update-delete.md` | 데이터 입력·수정·삭제 정리 |
| 5 | `01-sql-basics/practice.sql` | 기본 SQL 반복 연습 |
| 6 | `02-schema-design/table-design-notes.md` | 테이블 분리 이유 정리 |
| 7 | `02-schema-design/pk-fk-constraints.md` | PK/FK/제약조건 설명 정리 |
| 8 | `02-schema-design/normalization-basic.md` | 중복 제거와 테이블 분리 감각 정리 |
| 9 | `02-schema-design/erd-practice.md` | ERD를 보며 관계 설명 훈련 |
| 10 | `03-join-practice/inner-join.md` | INNER JOIN 설명과 예제 |
| 11 | `03-join-practice/left-join.md` | LEFT JOIN 설명과 예제 |
| 12 | `03-join-practice/join-vs-subquery.md` | JOIN과 서브쿼리 비교 |
| 13 | `03-join-practice/join-practice.sql` | JOIN 반복 연습 쿼리 |
| 14 | `04-aggregation-practice/group-by-count-sum-avg.md` | GROUP BY와 집계 함수 정리 |
| 15 | `04-aggregation-practice/ranking-query-practice.md` | TOP N, 정렬, 랭킹 쿼리 훈련 |
| 16 | `04-aggregation-practice/aggregation-practice.sql` | 집계 쿼리 반복 연습 |
| 17 | `05-subquery-index/subquery-basic.md` | 서브쿼리 기본 정리 |
| 18 | `05-subquery-index/index-basic.md` | 인덱스 기본 개념 정리 |
| 19 | `05-subquery-index/explain-query-plan.md` | 실행 계획 확인 훈련 |
| 20 | `06-evaluation-qa/expected-questions.md` | 예상 질문 목록 정리 |
| 21 | `06-evaluation-qa/answer-script.md` | 평가 답변 스크립트 작성 |
| 22 | `06-evaluation-qa/self-review-checklist.md` | 최종 자가 점검표 작성 |
| 23 | `07-error-notes/sqlite-errors.md` | SQLite 오류 정리 |
| 24 | `07-error-notes/fk-error-practice.md` | FK 오류 재현과 해결 기록 |
| 25 | `07-error-notes/mistakes-log.md` | 실수·오답 누적 기록 |
| 26 | `08-codex-prompts/review-repo-prompt.md` | Codex 저장소 리뷰 프롬프트 |
| 27 | `08-codex-prompts/improve-sql-prompt.md` | Codex SQL 개선 프롬프트 |
| 28 | `08-codex-prompts/generate-practice-prompt.md` | Codex 연습문제 생성 프롬프트 |

---

## 4. 폴더별 작성 기준

### 4.1 `00-roadmap/`

훈련 전체 계획을 관리한다.

- 오늘 무엇을 할지 명확히 쓴다.
- 완료 여부를 체크박스로 남긴다.
- 평가 전까지 어떤 순서로 반복할지 기록한다.

핵심 질문:

- 오늘 설명 연습할 개념은 무엇인가?
- 오늘 직접 작성할 SQL은 몇 개인가?
- 오늘 막힌 오류는 무엇인가?

### 4.2 `01-sql-basics/`

SQL 기본 문법을 반복한다.

훈련 범위:

- `SELECT`
- `WHERE`
- `ORDER BY`
- `LIMIT`
- `INSERT`
- `UPDATE`
- `DELETE`

원칙:

- 쿼리를 눈으로만 보지 않는다.
- 반드시 `book_rental.db`에 직접 실행한다.
- 실행 결과를 보고 쿼리 의미를 한 문장으로 설명한다.

### 4.3 `02-schema-design/`

테이블 설계와 관계를 설명하는 훈련 공간이다.

훈련 범위:

- 테이블을 나눈 이유
- PK와 FK의 차이
- 1:N 관계
- 제약조건
- ERD 설명

평가 핵심:

> “왜 `rental` 테이블을 따로 만들었나요?”라는 질문에 답할 수 있어야 한다.

### 4.4 `03-join-practice/`

JOIN 쿼리를 집중 훈련한다.

훈련 범위:

- `INNER JOIN`
- `LEFT JOIN`
- 2개 테이블 JOIN
- 3개 이상 테이블 JOIN
- JOIN과 서브쿼리 비교

평가 핵심:

> INNER JOIN은 매칭되는 행만 보여주고, LEFT JOIN은 왼쪽 테이블의 행을 유지한다.

### 4.5 `04-aggregation-practice/`

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

### 4.6 `05-subquery-index/`

서브쿼리와 인덱스를 설명하는 훈련 공간이다.

훈련 범위:

- 평균보다 비싼 도서 찾기
- 특정 조건에 해당하는 회원 찾기
- `CREATE INDEX`
- `EXPLAIN QUERY PLAN`

평가 핵심:

> `rental(member_id, due_date)` 인덱스는 특정 회원의 대여 기록을 반납기한 순으로 조회할 때 유리하다.

### 4.7 `06-evaluation-qa/`

평가 대비용 핵심 폴더다.

반드시 정리할 질문:

1. 엑셀과 DB는 무엇이 다른가?
2. 왜 테이블을 나누었는가?
3. PK와 FK는 무엇인가?
4. 1:N 관계는 어디에 있는가?
5. INNER JOIN과 LEFT JOIN은 무엇이 다른가?
6. GROUP BY와 집계 함수는 어떻게 동작하는가?
7. 인덱스는 왜 필요한가?
8. 가장 복잡했던 쿼리는 무엇이고 어떻게 풀었는가?
9. 미션 중 어려웠던 점은 무엇이고 어떻게 해결했는가?

### 4.8 `07-error-notes/`

오류와 실수를 기록한다.

기록 형식:

```md
## 오류명 또는 상황

- 발생 명령:
- 오류 메시지:
- 원인:
- 해결 방법:
- 다음에 조심할 점:
```

반드시 기록할 오류:

- `FOREIGN KEY constraint failed`
- `no such table`
- `UNIQUE constraint failed`
- `near "...": syntax error`
- `database is locked`

### 4.9 `08-codex-prompts/`

Codex에게 반복 점검과 개선을 맡기기 위한 프롬프트를 보관한다.

사용 목적:

- 저장소 평가
- SQL 오류 검토
- 쿼리 추가 연습문제 생성
- 평가 예상 질문 생성
- README와 제출물 점검

---

## 5. 매일 반복 루틴

하루 60~90분 기준으로 반복한다.

```text
1. 기본 조회 SQL 3개 작성
2. JOIN SQL 2개 작성
3. GROUP BY SQL 1개 작성
4. 평가 질문 3개 말로 답변
5. 오류 또는 실수 1개 기록
6. Codex에게 오늘 작성한 SQL 리뷰 요청
```

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

## 7. SQL 연습 원칙

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

---

## 8. 평가 직전 최종 점검

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
```

---

## 9. 커밋 규칙

훈련 자료도 의미 있는 단위로 커밋한다.

권장 커밋 메시지:

```text
docs: add B5-1 training roadmap
docs: add B5-1 daily training checklist
docs: add SQL basics notes
docs: add schema design notes
docs: add join practice guide
docs: add aggregation practice queries
docs: add evaluation answer script
docs: add SQLite error notes
docs: add Codex review prompts
```

---

## 10. 작성 진행 상태

| 순서 | 파일 | 상태 |
|---:|---|---|
| 0 | `training-materials/README.md` | 완료 |
| 1 | `00-roadmap/b5-1-training-plan.md` | 완료 |
| 2 | `00-roadmap/daily-checklist.md` | 완료 |
| 3 | `01-sql-basics/select-where-order-limit.md` | 완료 |
| 4 | `01-sql-basics/insert-update-delete.md` | 예정 |
| 5 | `01-sql-basics/practice.sql` | 예정 |
| 6 | `02-schema-design/table-design-notes.md` | 예정 |
| 7 | `02-schema-design/pk-fk-constraints.md` | 예정 |
| 8 | `02-schema-design/normalization-basic.md` | 예정 |
| 9 | `02-schema-design/erd-practice.md` | 예정 |
| 10 | `03-join-practice/inner-join.md` | 예정 |
| 11 | `03-join-practice/left-join.md` | 예정 |
| 12 | `03-join-practice/join-vs-subquery.md` | 예정 |
| 13 | `03-join-practice/join-practice.sql` | 예정 |
| 14 | `04-aggregation-practice/group-by-count-sum-avg.md` | 예정 |
| 15 | `04-aggregation-practice/ranking-query-practice.md` | 예정 |
| 16 | `04-aggregation-practice/aggregation-practice.sql` | 예정 |
| 17 | `05-subquery-index/subquery-basic.md` | 예정 |
| 18 | `05-subquery-index/index-basic.md` | 예정 |
| 19 | `05-subquery-index/explain-query-plan.md` | 예정 |
| 20 | `06-evaluation-qa/expected-questions.md` | 예정 |
| 21 | `06-evaluation-qa/answer-script.md` | 예정 |
| 22 | `06-evaluation-qa/self-review-checklist.md` | 예정 |
| 23 | `07-error-notes/sqlite-errors.md` | 예정 |
| 24 | `07-error-notes/fk-error-practice.md` | 예정 |
| 25 | `07-error-notes/mistakes-log.md` | 예정 |
| 26 | `08-codex-prompts/review-repo-prompt.md` | 예정 |
| 27 | `08-codex-prompts/improve-sql-prompt.md` | 예정 |
| 28 | `08-codex-prompts/generate-practice-prompt.md` | 예정 |
