# B5-1 Training Materials Final Index

이 문서는 B5-1 「SQL로 만드는 나만의 데이터베이스」 훈련 자료의 최종 목차이다.

`training-materials/`에 만든 문서와 SQL 스크립트를 **학습 순서**, **평가 준비 순서**, **실행 순서**, **복습 순서**로 다시 묶어 빠르게 찾을 수 있도록 정리한다.

---

## 1. 이 인덱스의 목적

```text
1. 어떤 자료부터 읽어야 하는지 정리한다.
2. 평가 직전 어떤 파일을 봐야 하는지 정리한다.
3. 실행 가능한 SQL 스크립트를 한곳에 모은다.
4. B5-1 이후 B5-2/B5-3/B6로 확장할 흐름을 연결한다.
```

최종 사용법:

> 처음부터 학습할 때는 00-roadmap부터 읽고, 평가 직전에는 06-evaluation-qa와 07-review만 집중해서 보면 된다.

---

## 2. 전체 폴더 구조

```text
training-materials/
├── 00-roadmap/
├── 01-sql-basics/
├── 02-schema-design/
├── 03-join-practice/
├── 04-aggregation-practice/
├── 05-subquery-index/
├── 06-evaluation-qa/
├── 07-error-notes/
├── 07-review/
└── README-final-index.md
```

---

## 3. 빠른 결론

| 목적 | 먼저 볼 파일 |
|---|---|
| 전체 학습 계획 확인 | `00-roadmap/b5-1-training-plan.md` |
| 매일 할 일 확인 | `00-roadmap/daily-checklist.md` |
| SELECT 기본기 복습 | `01-sql-basics/select-where-order-limit.md` |
| INSERT/UPDATE/DELETE 안전성 | `01-sql-basics/insert-update-delete.md` |
| 테이블 설계 설명 | `02-schema-design/table-design-notes.md` |
| PK/FK/제약조건 설명 | `02-schema-design/pk-fk-constraints.md` |
| ERD 설명 | `02-schema-design/erd-practice.md` |
| JOIN 복습 | `03-join-practice/inner-join.md`, `03-join-practice/left-join.md` |
| GROUP BY 복습 | `04-aggregation-practice/group-by-count-sum-avg.md` |
| 서브쿼리 복습 | `05-subquery-index/subquery-basic.md` |
| 인덱스/실행계획 복습 | `05-subquery-index/index-basic.md`, `05-subquery-index/explain-query-plan.md` |
| 평가 예상 질문 | `06-evaluation-qa/expected-questions.md` |
| 말하기 스크립트 | `06-evaluation-qa/answer-scripts.md` |
| 최종 체크 | `06-evaluation-qa/final-checklist.md` |
| 오류/오답 기록 | `07-error-notes/mistakes-log.md` |
| 제출 파일 점검 | `07-review/project-file-audit.md` |
| 자가 점수 | `07-review/score-self-review.md` |
| 리팩터링 TODO | `07-review/refactor-todo.md` |
| 최종 제출 명령 | `07-review/final-submit-commands.md` |
| 고도화 로드맵 | `07-review/mvp-to-advanced-roadmap.md` |
| 최종 SQL 복습 | `07-review/review-practice.sql` |

---

## 4. 학습 순서 권장안

### 4.1 처음부터 학습하는 순서

```text
1. 00-roadmap/b5-1-training-plan.md
2. 00-roadmap/daily-checklist.md
3. 01-sql-basics/select-where-order-limit.md
4. 01-sql-basics/insert-update-delete.md
5. 02-schema-design/table-design-notes.md
6. 02-schema-design/pk-fk-constraints.md
7. 02-schema-design/normalization-basic.md
8. 02-schema-design/erd-practice.md
9. 03-join-practice/inner-join.md
10. 03-join-practice/left-join.md
11. 03-join-practice/join-vs-subquery.md
12. 04-aggregation-practice/group-by-count-sum-avg.md
13. 04-aggregation-practice/ranking-query-practice.md
14. 05-subquery-index/subquery-basic.md
15. 05-subquery-index/index-basic.md
16. 05-subquery-index/explain-query-plan.md
17. 06-evaluation-qa/expected-questions.md
18. 06-evaluation-qa/answer-scripts.md
19. 06-evaluation-qa/final-checklist.md
20. 07-review/score-self-review.md
21. 07-review/refactor-todo.md
22. 07-review/mvp-to-advanced-roadmap.md
```

### 4.2 평가 직전 압축 순서

```text
1. 06-evaluation-qa/final-checklist.md
2. 06-evaluation-qa/answer-scripts.md
3. 06-evaluation-qa/expected-questions.md
4. 07-review/review-practice.sql
5. 07-review/score-self-review.md
6. 07-review/refactor-todo.md
```

### 4.3 실습만 빠르게 돌리는 순서

```text
1. 01-sql-basics/practice.sql
2. 03-join-practice/join-practice.sql
3. 04-aggregation-practice/aggregation-practice.sql
4. 07-review/review-practice.sql
```

---

## 5. 실행 가능한 SQL 스크립트

### 5.1 SQL 기본 복습

```bash
sqlite3 book_rental.db < training-materials/01-sql-basics/practice.sql
```

목적:

```text
SELECT, WHERE, ORDER BY, LIMIT, LIKE, IN, BETWEEN, NULL, 안전 DML 흐름 복습
```

---

### 5.2 JOIN 복습

```bash
sqlite3 book_rental.db < training-materials/03-join-practice/join-practice.sql
```

목적:

```text
INNER JOIN, LEFT JOIN, JOIN vs Subquery, EXISTS, NOT EXISTS 복습
```

---

### 5.3 집계 복습

```bash
sqlite3 book_rental.db < training-materials/04-aggregation-practice/aggregation-practice.sql
```

목적:

```text
GROUP BY, COUNT, SUM, AVG, HAVING, TOP N, Window Function 복습
```

---

### 5.4 최종 평가 복습

```bash
sqlite3 book_rental.db < training-materials/07-review/review-practice.sql
```

목적:

```text
테이블, FK, 기본 SELECT, JOIN, GROUP BY, 서브쿼리, UPDATE/DELETE 롤백, 인덱스, 실행계획, 말하기 프롬프트 최종 점검
```

주의:

> `review-practice.sql`은 UPDATE/DELETE 연습을 `SAVEPOINT` 후 `ROLLBACK`하므로 행 데이터 변경은 남기지 않는다. 다만 B5-1 핵심 인덱스인 `idx_rental_member_due`가 없으면 생성될 수 있다.

---

## 6. 폴더별 상세 목차

## 6.1 `00-roadmap/`

| 파일 | 목적 |
|---|---|
| `b5-1-training-plan.md` | B5-1 전체 학습 계획, 목표, 3일 학습 루틴 |
| `daily-checklist.md` | 매일 실행할 명령, 확인 항목, 평가 준비 루틴 |

핵심 질문:

```text
오늘 무엇을 해야 하는가?
평가 전까지 어떤 순서로 준비해야 하는가?
```

---

## 6.2 `01-sql-basics/`

| 파일 | 목적 |
|---|---|
| `select-where-order-limit.md` | SELECT, WHERE, ORDER BY, LIMIT, LIKE, IN, BETWEEN, NULL 복습 |
| `insert-update-delete.md` | INSERT 순서, UPDATE/DELETE 안전성, 트랜잭션 복습 |
| `practice.sql` | SQL 기본기 실행 연습 스크립트 |

핵심 질문:

```text
WHERE는 무엇인가?
ORDER BY와 LIMIT은 왜 쓰는가?
UPDATE/DELETE 전에 왜 SELECT로 확인해야 하는가?
```

---

## 6.3 `02-schema-design/`

| 파일 | 목적 |
|---|---|
| `table-design-notes.md` | 4개 테이블로 나눈 이유와 테이블 역할 설명 |
| `pk-fk-constraints.md` | PK/FK/NOT NULL/UNIQUE/CHECK/ON DELETE 설명 |
| `normalization-basic.md` | 정규화, 중복 제거, 이상 현상 설명 |
| `erd-practice.md` | ERD 읽기, 관계 설명, JOIN 조건 연결 |

핵심 질문:

```text
왜 member, category, book, rental로 나누었는가?
rental 테이블은 왜 필요한가?
1:N 관계는 무엇인가?
PK와 FK는 어디에 있는가?
```

---

## 6.4 `03-join-practice/`

| 파일 | 목적 |
|---|---|
| `inner-join.md` | INNER JOIN 정의와 FK 기반 연결 설명 |
| `left-join.md` | LEFT JOIN과 0건 포함 집계 설명 |
| `join-vs-subquery.md` | JOIN과 서브쿼리 선택 기준 비교 |
| `join-practice.sql` | JOIN 종합 실행 연습 스크립트 |

핵심 질문:

```text
INNER JOIN과 LEFT JOIN은 어떻게 다른가?
ON과 WHERE는 어떻게 다른가?
대여 기록에 회원명과 도서명을 붙이려면 왜 JOIN이 필요한가?
```

---

## 6.5 `04-aggregation-practice/`

| 파일 | 목적 |
|---|---|
| `group-by-count-sum-avg.md` | GROUP BY, COUNT, SUM, AVG, HAVING 설명 |
| `ranking-query-practice.md` | TOP N, ORDER BY, LIMIT, RANK 계열 설명 |
| `aggregation-practice.sql` | 집계/랭킹 실행 연습 스크립트 |

핵심 질문:

```text
GROUP BY는 무엇인가?
COUNT, SUM, AVG는 각각 무엇인가?
WHERE와 HAVING은 어떻게 다른가?
인기 도서 TOP 5는 어떻게 구하는가?
```

---

## 6.6 `05-subquery-index/`

| 파일 | 목적 |
|---|---|
| `subquery-basic.md` | 스칼라, IN, EXISTS, NOT EXISTS, 상관 서브쿼리 설명 |
| `index-basic.md` | 인덱스 정의, 복합 인덱스, `idx_rental_member_due` 설명 |
| `explain-query-plan.md` | SQLite 실행 계획 읽기와 SCAN/SEARCH/USING INDEX 설명 |

핵심 질문:

```text
서브쿼리는 무엇인가?
평균 가격보다 비싼 도서는 어떻게 찾는가?
왜 rental(member_id, due_date)에 인덱스를 만들었는가?
EXPLAIN QUERY PLAN은 무엇을 확인하는가?
```

---

## 6.7 `06-evaluation-qa/`

| 파일 | 목적 |
|---|---|
| `expected-questions.md` | 예상 평가 질문과 답변 59개 정리 |
| `answer-scripts.md` | 15초, 30초, 1분, 2분 말하기 스크립트 |
| `final-checklist.md` | 제출 전 파일, 실행, 말하기, 감점 방지 최종 체크 |

핵심 질문:

```text
평가자가 무엇을 물어볼 것인가?
30초 안에 프로젝트를 설명할 수 있는가?
JOIN/GROUP BY/서브쿼리/인덱스를 말로 설명할 수 있는가?
```

---

## 6.8 `07-error-notes/`

| 파일 | 목적 |
|---|---|
| `mistakes-log.md` | SQL 실행 오류, 원인, 해결 방법, 다음 주의점을 기록 |

핵심 질문:

```text
어떤 명령에서 막혔는가?
오류 메시지는 무엇이었는가?
다음에는 어떻게 피할 것인가?
```

---

## 6.9 `07-review/`

| 파일 | 목적 |
|---|---|
| `project-file-audit.md` | 제출 파일 누락과 감점 위험 점검 |
| `score-self-review.md` | 100점 기준 자가 채점, 감점 위험 진단 |
| `refactor-todo.md` | P0/P1/P2 리팩터링 TODO와 감점 방지 항목 |
| `final-submit-commands.md` | 최종 실행, 확인, 제출 전 명령 정리 |
| `mvp-to-advanced-roadmap.md` | SQLite MVP에서 FastAPI/인증/배포로 확장하는 로드맵 |
| `review-practice.sql` | 최종 종합 SQL 복습 스크립트 |

핵심 질문:

```text
현재 점수는 어느 정도인가?
제출 전 꼭 고칠 것은 무엇인가?
평가 후 B5-2/B5-3/B6로 어떻게 확장할 것인가?
```

---

## 7. 평가 직전 30분 루틴

```text
[ ] 1. final-checklist.md를 열고 필수 제출물 확인
[ ] 2. review-practice.sql 실행
[ ] 3. answer-scripts.md의 30초/1분 답변 말하기
[ ] 4. expected-questions.md에서 약한 질문 5개만 확인
[ ] 5. score-self-review.md에서 감점 위험 확인
[ ] 6. refactor-todo.md의 P0 항목만 처리
[ ] 7. git status 확인
```

실행 명령:

```bash
chmod +x scripts/run_all.sh
./scripts/run_all.sh
sqlite3 book_rental.db < training-materials/07-review/review-practice.sql
git status
```

---

## 8. 평가 직전 5분 루틴

아래 10문장을 말한다.

```text
1. 이 프로젝트는 SQLite 기반 도서 대여 관리 데이터베이스입니다.
2. 테이블은 member, category, book, rental 네 개입니다.
3. category-book, member-rental, book-rental은 1:N 관계입니다.
4. rental은 회원과 도서의 대여 이력을 기록하는 테이블입니다.
5. PK는 각 행을 식별하고 FK는 테이블 관계를 만듭니다.
6. INNER JOIN은 매칭되는 행만, LEFT JOIN은 왼쪽 행을 유지합니다.
7. GROUP BY는 같은 기준의 행을 묶고 COUNT/SUM/AVG로 집계합니다.
8. 서브쿼리는 안쪽 SELECT 결과를 바깥 쿼리 조건으로 사용합니다.
9. UPDATE/DELETE는 SELECT로 대상 확인 후 WHERE 조건을 명확히 써야 합니다.
10. idx_rental_member_due는 회원별 반납기한 조회를 위한 rental(member_id, due_date) 복합 인덱스입니다.
```

---

## 9. 최종 평가 답변 30초 버전

> 저는 도서 대여 관리 도메인으로 SQLite 데이터베이스를 설계했습니다. 테이블은 `member`, `category`, `book`, `rental` 네 개이고, `category → book`, `member → rental`, `book → rental`의 1:N 관계를 만들었습니다. 각 테이블에는 PK를 두고, `book.category_id`, `rental.member_id`, `rental.book_id`에 FK를 설정했습니다. 이후 기본 조회, JOIN, GROUP BY, 서브쿼리, UPDATE, DELETE, 인덱스 쿼리를 작성하고 실행 결과까지 남겼습니다.

---

## 10. 최종 평가 답변 1분 버전

> 이번 프로젝트는 SQLite 기반 도서 대여 관리 데이터베이스입니다. `member`, `category`, `book`, `rental` 네 개의 테이블을 만들고, 회원과 대여, 도서와 대여, 카테고리와 도서 사이에 1:N 관계를 설계했습니다. PK는 각 테이블의 ID 컬럼으로 두었고, FK는 `book.category_id`, `rental.member_id`, `rental.book_id`에 설정했습니다. 쿼리는 기본 조회, INNER JOIN, LEFT JOIN, GROUP BY 집계, 서브쿼리, UPDATE, DELETE, 인덱스까지 작성했습니다. 회원별 대여 횟수는 `member`와 `rental`을 JOIN한 뒤 GROUP BY와 COUNT로 계산했고, 평균 가격보다 비싼 도서는 서브쿼리로 평균 가격을 구한 뒤 비교했습니다. 마지막으로 특정 회원의 대여 기록을 반납기한 순으로 조회하는 패턴을 위해 `rental(member_id, due_date)` 복합 인덱스를 만들고 `EXPLAIN QUERY PLAN`으로 확인했습니다.

---

## 11. 제출 전 최종 명령

```bash
# 1. 프로젝트 루트 확인
pwd

# 2. 구조 확인
tree -L 3

# 3. 전체 실행
chmod +x scripts/run_all.sh
./scripts/run_all.sh

# 4. 최종 복습 SQL 실행
sqlite3 book_rental.db < training-materials/07-review/review-practice.sql

# 5. Git 상태 확인
git status
git log --oneline -5
```

---

## 12. 다음 단계

평가 전:

```text
1. 06-evaluation-qa/final-checklist.md
2. 07-review/review-practice.sql
3. 06-evaluation-qa/answer-scripts.md
4. 07-review/score-self-review.md
5. 07-review/refactor-todo.md
```

평가 후:

```text
1. 07-review/mvp-to-advanced-roadmap.md
2. B5-2 FastAPI CRUD 웹 서비스 구축
3. B5-3 인증과 연관관계 적용
4. B6-1 클라우드 인프라 배포
5. B6-2 자동화 도구 개발
```

---

## 13. 완료 기준

```text
[ ] 이 최종 인덱스에서 필요한 파일을 찾을 수 있다.
[ ] 실행 가능한 SQL 스크립트 4개를 알고 있다.
[ ] 평가 직전 30분 루틴을 수행할 수 있다.
[ ] 평가 직전 5분 암기 문장을 말할 수 있다.
[ ] 30초/1분 답변을 말할 수 있다.
[ ] 평가 후 고도화 로드맵을 설명할 수 있다.
```
