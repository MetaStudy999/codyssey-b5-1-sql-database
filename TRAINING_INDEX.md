# B5-1 Training Index

이 문서는 B5-1 「SQL로 만드는 나만의 데이터베이스」 훈련 자료의 진입점이다.

전체 학습 자료, 평가 준비 자료, 실행 가능한 복습 SQL, 최종 체크리스트는
[training-materials/README-final-index.md](training-materials/README-final-index.md)에서 확인한다.

관련 진입점:

| 목적 | 파일 |
|---|---|
| 프로젝트 개요와 실행 방법 | [README.md](README.md) |
| 훈련 자료 전체 안내 | [training-materials/README.md](training-materials/README.md) |
| 훈련 자료 최종 목차 | [training-materials/README-final-index.md](training-materials/README-final-index.md) |

---

## 빠른 사용 순서

### 핵심 압축 순서

전체 22단계 학습 순서는 [training-materials/README-final-index.md](training-materials/README-final-index.md)의 `4.1 처음부터 학습하는 순서`를 따른다.
아래는 루트에서 빠르게 확인하는 핵심 흐름이다.

| 순서 | 파일 | 목적 |
|---:|---|---|
| 1 | [training-materials/00-roadmap/b5-1-training-plan.md](training-materials/00-roadmap/b5-1-training-plan.md) | 전체 훈련 계획 확인 |
| 2 | [training-materials/00-roadmap/daily-checklist.md](training-materials/00-roadmap/daily-checklist.md) | 매일 반복할 점검 항목 확인 |
| 3 | [training-materials/01-sql-basics/select-where-order-limit.md](training-materials/01-sql-basics/select-where-order-limit.md) | SELECT 기본기 복습 |
| 4 | [training-materials/01-sql-basics/insert-update-delete.md](training-materials/01-sql-basics/insert-update-delete.md) | INSERT/UPDATE/DELETE 안전성 복습 |
| 5 | [training-materials/02-schema-design/table-design-notes.md](training-materials/02-schema-design/table-design-notes.md) | 테이블 분리 이유 설명 |
| 6 | [training-materials/02-schema-design/pk-fk-constraints.md](training-materials/02-schema-design/pk-fk-constraints.md) | PK/FK/제약조건 설명 |
| 7 | [training-materials/03-join-practice/inner-join.md](training-materials/03-join-practice/inner-join.md) | INNER JOIN 설명 |
| 8 | [training-materials/03-join-practice/left-join.md](training-materials/03-join-practice/left-join.md) | LEFT JOIN 설명 |
| 9 | [training-materials/04-aggregation-practice/group-by-count-sum-avg.md](training-materials/04-aggregation-practice/group-by-count-sum-avg.md) | GROUP BY와 집계 함수 복습 |
| 10 | [training-materials/05-subquery-index/subquery-basic.md](training-materials/05-subquery-index/subquery-basic.md) | 서브쿼리 복습 |
| 11 | [training-materials/05-subquery-index/index-basic.md](training-materials/05-subquery-index/index-basic.md) | 인덱스 설명 |
| 12 | [training-materials/06-evaluation-qa/expected-questions.md](training-materials/06-evaluation-qa/expected-questions.md) | 평가 예상 질문 확인 |
| 13 | [training-materials/07-review/score-self-review.md](training-materials/07-review/score-self-review.md) | 자가 점수와 감점 위험 확인 |

### 평가 직전

| 순서 | 파일 | 목적 |
|---:|---|---|
| 1 | [training-materials/06-evaluation-qa/final-checklist.md](training-materials/06-evaluation-qa/final-checklist.md) | 제출물과 실행 결과 최종 확인 |
| 2 | [training-materials/07-review/review-practice.sql](training-materials/07-review/review-practice.sql) | 최종 SQL 복습 실행 |
| 3 | [training-materials/06-evaluation-qa/answer-scripts.md](training-materials/06-evaluation-qa/answer-scripts.md) | 30초/1분 말하기 연습 |
| 4 | [training-materials/06-evaluation-qa/expected-questions.md](training-materials/06-evaluation-qa/expected-questions.md) | 약한 예상 질문만 재확인 |
| 5 | [training-materials/07-review/score-self-review.md](training-materials/07-review/score-self-review.md) | 감점 위험 확인 |
| 6 | [training-materials/07-review/refactor-todo.md](training-materials/07-review/refactor-todo.md) | P0/P1 수정 후보 확인 |

### 제출 직전

| 순서 | 파일 또는 명령 | 목적 |
|---:|---|---|
| 1 | [training-materials/07-review/project-file-audit.md](training-materials/07-review/project-file-audit.md) | 제출 파일 누락 여부 점검 |
| 2 | [training-materials/07-review/final-submit-commands.md](training-materials/07-review/final-submit-commands.md) | 최종 제출 명령 확인 |
| 3 | `git status` | 커밋/제출 전 변경 상태 확인 |

---

## DB 준비 및 복습 SQL

복습 SQL은 `book_rental.db`에 `member`, `category`, `book`, `rental` 테이블과 샘플 데이터가 있는 상태를 전제로 한다.
처음 실행하거나 DB를 최신 상태로 맞출 때는 먼저 아래 명령을 실행한다.

```bash
chmod +x scripts/run_all.sh
./scripts/run_all.sh
```

그다음 필요한 복습 SQL을 실행한다.

```bash
sqlite3 book_rental.db < training-materials/01-sql-basics/practice.sql
sqlite3 book_rental.db < training-materials/03-join-practice/join-practice.sql
sqlite3 book_rental.db < training-materials/04-aggregation-practice/aggregation-practice.sql
sqlite3 book_rental.db < training-materials/07-review/review-practice.sql
```

---

## 오류 기록

연습 중 막힌 명령, 오류 메시지, 원인, 해결 방법은
[training-materials/07-error-notes/mistakes-log.md](training-materials/07-error-notes/mistakes-log.md)에 남긴다.

기록 기준:

```text
[ ] 실행한 명령
[ ] 발생한 오류 메시지
[ ] 원인 추정
[ ] 해결 방법
[ ] 다음에 조심할 점
```

---

## 평가 직전 핵심 답변

> 이 프로젝트는 SQLite 기반 도서 대여 관리 데이터베이스입니다. `member`, `category`, `book`, `rental` 네 개의 테이블을 만들고, `category → book`, `member → rental`, `book → rental`의 1:N 관계를 설계했습니다. 각 테이블에는 PK를 두고, FK와 제약조건을 설정했습니다. 이후 SELECT, JOIN, GROUP BY, 서브쿼리, UPDATE, DELETE, 인덱스 쿼리를 작성하고 실행 결과까지 준비했습니다.
