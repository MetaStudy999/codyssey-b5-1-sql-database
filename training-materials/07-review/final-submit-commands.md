# B5-1 제출 전 최종 확인 명령

이 문서는 B5-1 「SQL로 만드는 나만의 데이터베이스」 프로젝트 제출 직전에 확인할 명령만 모은 체크리스트이다.

목표는 다음 네 가지다.

```text
1. 프로젝트 루트 위치 확인
2. 전체 SQL 실행 검증
3. 결과 파일 확인
4. Git 상태 확인
```

---

## 1. 최종 확인 순서

아래 순서대로 확인한다.

```bash
pwd
tree -L 3
sqlite3 --version
chmod +x scripts/run_all.sh
./scripts/run_all.sh
cat results/validation_results.txt
cat results/query_results.txt
cat results/bonus_results.txt
sqlite3 book_rental.db < training-materials/07-review/review-practice.sql
git status
git log --oneline -5
```

---

## 2. run_all.sh 성공 기준

`./scripts/run_all.sh` 실행 후 아래 흐름이 나오면 정상이다.

```text
[1/5] Creating schema...
[2/5] Inserting seed data...
[3/5] Running validation...
[4/5] Running bonus report queries...
[5/5] Running 15 core queries...
[DONE] Created book_rental.db
[DONE] Core query mutations were executed on a temporary DB copy.
[DONE] Check results/validation_results.txt, results/query_results.txt, and results/bonus_results.txt
```

---

## 3. validation_results.txt 확인 기준

확인할 내용:

```text
book
category
member
rental

member: 10
category: 10
book: 15
rental: 20
```

`PRAGMA foreign_key_check` 영역에 위반 행이 없으면 정상이다.

---

## 4. query_results.txt 확인 기준

확인할 항목:

```text
[ ] Q01 기본 조회 결과
[ ] Q02 가격순 TOP 5 결과
[ ] Q03 LIKE 검색 결과
[ ] Q05 INNER JOIN 결과
[ ] Q08 LEFT JOIN 결과
[ ] Q09 GROUP BY + COUNT + SUM 결과
[ ] Q10 GROUP BY + AVG 결과
[ ] Q12 서브쿼리 결과
[ ] Q13 UPDATE 결과
[ ] Q14 DELETE 결과
[ ] Q15 INDEX 실행 계획 결과
```

Q15에서 보면 좋은 표현:

```text
SEARCH rental USING INDEX idx_rental_member_due
```

---

## 5. 최종 복습 SQL

아래 명령은 최종 복습용이다.

```bash
sqlite3 book_rental.db < training-materials/07-review/review-practice.sql
```

확인 범위:

```text
테이블 목록
테이블별 행 수
FK 목록
FK 무결성
기본 SELECT
INNER JOIN
LEFT JOIN
GROUP BY
HAVING
서브쿼리
UPDATE/DELETE 안전 롤백
인덱스
EXPLAIN QUERY PLAN
평가 말하기 프롬프트
```

주의:

> `review-practice.sql`의 UPDATE/DELETE 연습은 SAVEPOINT와 ROLLBACK으로 되돌린다. 행 데이터 변경은 남지 않는다. 단, `idx_rental_member_due` 인덱스가 없으면 생성될 수 있다.

---

## 6. Git 상태 확인 기준

```bash
git status
git log --oneline -5
```

정상 기준:

```text
working tree clean
```

또는 한국어 출력에서는 다음 의미의 문구가 나오면 된다.

```text
커밋할 사항 없음
작업 폴더 깨끗함
```

---

## 7. 제출 직전 열어볼 파일

GitHub에서 아래 파일을 확인한다.

```text
README.md
TRAINING_INDEX.md
docs/ERD.md
sql/01_schema.sql
sql/02_seed.sql
sql/03_queries.sql
results/validation_results.txt
results/query_results.txt
docs/evaluation_answers.md
training-materials/README-final-index.md
```

---

## 8. 제출 직전 30초 답변

> 저는 도서 대여 관리 도메인으로 SQLite 데이터베이스를 설계했습니다. 테이블은 `member`, `category`, `book`, `rental` 네 개이고, `category → book`, `member → rental`, `book → rental`의 1:N 관계를 만들었습니다. 각 테이블에는 PK를 두고, FK와 제약조건을 설정했습니다. 이후 기본 조회, JOIN, GROUP BY, 서브쿼리, UPDATE, DELETE, 인덱스 쿼리를 작성하고 실행 결과까지 남겼습니다.

---

## 9. 제출 가능 최종 판정 기준

```text
[ ] ./scripts/run_all.sh가 성공했다.
[ ] results/validation_results.txt가 생성되었다.
[ ] results/query_results.txt가 생성되었다.
[ ] Q15 실행 계획이 확인된다.
[ ] review-practice.sql이 실행된다.
[ ] git status가 깨끗하다.
[ ] GitHub에서 최신 파일을 볼 수 있다.
[ ] 30초 답변을 말할 수 있다.
[ ] 1분 답변을 말할 수 있다.
```

---

## 10. 최종 제출 문장

> 현재 B5-1 프로젝트는 제출 가능한 상태입니다. 스키마, 샘플 데이터, 핵심 쿼리, 실행 결과, ERD, 평가 답변이 준비되어 있으며, 제출 직전 전체 실행과 Git 상태를 확인하면 됩니다.
