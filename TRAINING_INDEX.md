# B5-1 Training Index

이 문서는 B5-1 「SQL로 만드는 나만의 데이터베이스」 훈련 자료의 진입점이다.

전체 학습 자료, 평가 준비 자료, 실행 가능한 복습 SQL, 최종 체크리스트는 아래 파일에서 확인한다.

```text
training-materials/README-final-index.md
```

---

## 빠른 사용 순서

### 처음부터 학습할 때

```text
1. training-materials/00-roadmap/b5-1-training-plan.md
2. training-materials/00-roadmap/daily-checklist.md
3. training-materials/01-sql-basics/select-where-order-limit.md
4. training-materials/02-schema-design/table-design-notes.md
5. training-materials/03-join-practice/inner-join.md
6. training-materials/04-aggregation-practice/group-by-count-sum-avg.md
7. training-materials/05-subquery-index/subquery-basic.md
8. training-materials/06-evaluation-qa/expected-questions.md
9. training-materials/07-review/score-self-review.md
```

### 평가 직전

```text
1. training-materials/06-evaluation-qa/final-checklist.md
2. training-materials/07-review/review-practice.sql
3. training-materials/06-evaluation-qa/answer-scripts.md
4. training-materials/07-review/score-self-review.md
5. training-materials/07-review/refactor-todo.md
```

---

## 실행 가능한 복습 SQL

```bash
sqlite3 book_rental.db < training-materials/01-sql-basics/practice.sql
sqlite3 book_rental.db < training-materials/03-join-practice/join-practice.sql
sqlite3 book_rental.db < training-materials/04-aggregation-practice/aggregation-practice.sql
sqlite3 book_rental.db < training-materials/07-review/review-practice.sql
```

---

## 평가 직전 핵심 답변

> 이 프로젝트는 SQLite 기반 도서 대여 관리 데이터베이스입니다. `member`, `category`, `book`, `rental` 네 개의 테이블을 만들고, `category → book`, `member → rental`, `book → rental`의 1:N 관계를 설계했습니다. 각 테이블에는 PK를 두고, FK와 제약조건을 설정했습니다. 이후 SELECT, JOIN, GROUP BY, 서브쿼리, UPDATE, DELETE, 인덱스 쿼리를 작성하고 실행 결과까지 준비했습니다.
