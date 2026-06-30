# B5-1 제출 전 최종 확인 명령 v2

이 문서는 B5-1 「SQL로 만드는 나만의 데이터베이스」 프로젝트 제출 직전에 실행·확인할 명령을 정리한 최종 체크리스트이다.

범위는 **확인 전용**이다. 새 기능 추가, 대규모 수정, 원격 저장소 변경 명령은 포함하지 않는다.

---

## 1. 최종 확인 목표

```text
1. 현재 위치가 프로젝트 루트인지 확인한다.
2. SQLite 실행 환경을 확인한다.
3. 전체 실행 스크립트가 성공하는지 확인한다.
4. validation/query/bonus 결과 파일을 확인한다.
5. 최종 복습 SQL을 실행한다.
6. Git 작업 트리 상태를 확인한다.
7. 평가 직전 30초/1분 답변을 말할 수 있는지 확인한다.
```

최종 원칙:

> 제출 직전에는 새 기능을 추가하지 않는다. 이미 준비된 스키마, 샘플 데이터, 핵심 쿼리, 실행 결과, ERD, 평가 답변이 정상인지 확인하는 데 집중한다.

---

## 2. 전체 확인 명령

프로젝트 루트에서 아래 명령을 순서대로 실행한다.

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

## 3. 빠른 확인 명령

시간이 부족하면 아래 명령만 실행한다.

```bash
pwd
./scripts/run_all.sh
sqlite3 book_rental.db < training-materials/07-review/review-practice.sql
git status
```

주의:

> 빠른 확인은 최소 검증이다. 제출 직전에는 가능하면 2장의 전체 확인 명령을 사용한다.

---

## 4. run_all.sh 정상 기준

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

이 흐름의 의미:

```text
[확인] 스키마 생성 성공
[확인] 샘플 데이터 입력 성공
[확인] 검증 SQL 실행 성공
[확인] 보너스 SQL 실행 성공
[확인] 핵심 쿼리 15개 실행 성공
[확인] UPDATE/DELETE는 임시 DB 복사본에서 실행
```

---

## 5. validation_results.txt 확인 기준

아래 명령으로 확인한다.

```bash
cat results/validation_results.txt
```

확인할 내용:

```text
book
category
member
rental

member      10
category    10
book        15
rental      20
```

추가 확인:

```text
[ ] 테이블 4개가 모두 보인다.
[ ] 각 테이블 행 수가 10개 이상이다.
[ ] PRAGMA foreign_key_check 결과에 위반 행이 없다.
[ ] .schema 출력에 PK/FK/NOT NULL/UNIQUE/CHECK가 보인다.
```

평가 답변:

> 검증 결과에서 4개 테이블과 샘플 데이터 수를 확인했고, FK 무결성 위반이 없는 것을 확인했습니다.

---

## 6. query_results.txt 확인 기준

아래 명령으로 확인한다.

```bash
cat results/query_results.txt
```

확인할 항목:

```text
[ ] Q01 기본 SELECT 결과가 있다.
[ ] Q02 ORDER BY + LIMIT TOP 5 결과가 있다.
[ ] Q03 LIKE 검색 결과가 있다.
[ ] Q04 상태 조건 조회 결과가 있다.
[ ] Q05 INNER JOIN 결과가 있다.
[ ] Q06 도서 + 카테고리 JOIN 결과가 있다.
[ ] Q07 연체 기록 JOIN 결과가 있다.
[ ] Q08 LEFT JOIN 결과에 대여 0건 회원이 포함된다.
[ ] Q09 회원별 COUNT + SUM 결과가 있다.
[ ] Q10 카테고리별 COUNT + AVG 결과가 있다.
[ ] Q11 상태별 COUNT + SUM 결과가 있다.
[ ] Q12 평균 가격보다 비싼 도서 서브쿼리 결과가 있다.
[ ] Q13 UPDATE 결과가 있다.
[ ] Q14 DELETE 결과가 있다.
[ ] Q15 INDEX 실행 계획 결과가 있다.
```

Q15에서 확인할 표현:

```text
SEARCH rental USING INDEX idx_rental_member_due
```

평가 답변:

> 핵심 쿼리 결과에는 기본 조회, JOIN, LEFT JOIN, GROUP BY, 서브쿼리, UPDATE, DELETE, 인덱스 실행 계획까지 포함되어 있습니다.

---

## 7. review-practice.sql 최종 복습

아래 명령으로 실행한다.

```bash
sqlite3 book_rental.db < training-materials/07-review/review-practice.sql
```

확인 범위:

```text
[ ] 테이블 목록
[ ] 테이블별 행 수
[ ] FK 목록
[ ] FK 무결성
[ ] 기본 SELECT
[ ] INNER JOIN
[ ] LEFT JOIN
[ ] GROUP BY
[ ] HAVING
[ ] 서브쿼리
[ ] UPDATE/DELETE 안전 롤백
[ ] 인덱스
[ ] EXPLAIN QUERY PLAN
[ ] 평가 말하기 프롬프트
```

주의:

> `review-practice.sql`의 UPDATE/DELETE 연습은 SAVEPOINT와 ROLLBACK으로 되돌린다. 행 데이터 변경은 남지 않는다. 단, `idx_rental_member_due` 인덱스가 없으면 생성될 수 있다.

---

## 8. Git 상태 확인

아래 명령으로 확인한다.

```bash
git status
git log --oneline -5
```

정상 기준:

```text
working tree clean
```

또는 한국어 출력에서는 아래 의미의 문구가 나오면 된다.

```text
커밋할 사항 없음
작업 폴더 깨끗함
```

확인할 것:

```text
[ ] 작업 트리가 깨끗하다.
[ ] 최근 커밋에 최종 훈련 자료 또는 점검 문서가 보인다.
[ ] GitHub에서 README.md, TRAINING_INDEX.md, sql/, docs/, results/, training-materials/를 볼 수 있다.
```

---

## 9. 제출 직전 GitHub에서 열어볼 파일

```text
README.md
TRAINING_INDEX.md
sql/01_schema.sql
sql/02_seed.sql
sql/03_queries.sql
sql/04_validation.sql
docs/ERD.md
docs/evaluation_answers.md
results/validation_results.txt
results/query_results.txt
training-materials/README-final-index.md
training-materials/07-review/project-file-audit.md
training-materials/07-review/final-submit-commands.md
```

평가자에게 설명할 순서:

> README에서 프로젝트 개요와 실행 방법을 확인할 수 있고, ERD에서 테이블 관계를 볼 수 있습니다. SQL 폴더에는 스키마, 샘플 데이터, 검증 SQL, 핵심 쿼리가 있으며, results 폴더에는 실행 결과가 있습니다. TRAINING_INDEX와 training-materials에는 평가 준비 자료를 정리했습니다.

---

## 10. 제출 직전 30초 답변

아래 문장을 한 번 말한다.

> 저는 도서 대여 관리 도메인으로 SQLite 데이터베이스를 설계했습니다. 테이블은 `member`, `category`, `book`, `rental` 네 개이고, `category → book`, `member → rental`, `book → rental`의 1:N 관계를 만들었습니다. 각 테이블에는 PK를 두고, FK와 제약조건을 설정했습니다. 이후 기본 조회, JOIN, GROUP BY, 서브쿼리, UPDATE, DELETE, 인덱스 쿼리를 작성하고 실행 결과까지 남겼습니다.

---

## 11. 제출 직전 1분 답변

아래 문장을 한 번 말한다.

> 이번 프로젝트는 SQLite 기반 도서 대여 관리 데이터베이스입니다. `member`, `category`, `book`, `rental` 네 개의 테이블을 만들고, 회원과 대여, 도서와 대여, 카테고리와 도서 사이에 1:N 관계를 설계했습니다. PK는 각 테이블의 ID 컬럼으로 두었고, FK는 `book.category_id`, `rental.member_id`, `rental.book_id`에 설정했습니다. 쿼리는 기본 조회, INNER JOIN, LEFT JOIN, GROUP BY 집계, 서브쿼리, UPDATE, DELETE, 인덱스까지 작성했습니다. 회원별 대여 횟수는 `member`와 `rental`을 JOIN한 뒤 GROUP BY와 COUNT로 계산했고, 평균 가격보다 비싼 도서는 서브쿼리로 평균 가격을 구한 뒤 비교했습니다. 마지막으로 특정 회원의 대여 기록을 반납기한 순으로 조회하는 패턴을 위해 `rental(member_id, due_date)` 복합 인덱스를 만들고 `EXPLAIN QUERY PLAN`으로 확인했습니다.

---

## 12. 제출 전 금지 사항

```text
[ ] 평가 직전에 새 테이블을 추가하지 않는다.
[ ] 평가 직전에 sql/01_schema.sql을 대규모 수정하지 않는다.
[ ] 결과 파일을 갱신하지 않은 채 쿼리만 수정하지 않는다.
[ ] UPDATE/DELETE를 원본 DB에 직접 테스트하지 않는다.
[ ] git status가 더러운 상태로 제출하지 않는다.
[ ] 인덱스를 “빠르니까 만들었다”고 설명하지 않는다.
[ ] “그냥 만들었습니다”라고 답변하지 않는다.
```

---

## 13. 제출 가능 최종 판정 기준

아래가 모두 참이면 제출 가능하다.

```text
[ ] ./scripts/run_all.sh가 성공했다.
[ ] results/validation_results.txt가 생성되었다.
[ ] results/query_results.txt가 생성되었다.
[ ] results/bonus_results.txt가 생성되었다.
[ ] Q15 실행 계획이 확인된다.
[ ] review-practice.sql이 실행된다.
[ ] git status가 깨끗하다.
[ ] GitHub에서 최신 파일을 볼 수 있다.
[ ] 30초 답변을 말할 수 있다.
[ ] 1분 답변을 말할 수 있다.
```

---

## 14. 최종 제출 문장

> 현재 B5-1 프로젝트는 제출 가능한 상태입니다. 스키마, 샘플 데이터, 핵심 쿼리, 실행 결과, ERD, 평가 답변이 준비되어 있으며, 제출 직전 전체 실행과 Git 상태를 확인하면 됩니다.

---

## 15. 문제 발생 시 우선순위

```text
1. ./scripts/run_all.sh 오류 해결
2. results/validation_results.txt 확인
3. results/query_results.txt 확인
4. ERD와 schema 관계 일치 확인
5. git status 확인
6. 30초/1분 답변 연습
```

---

## 16. 완료 기준

```text
[ ] 전체 확인 명령을 읽었다.
[ ] run_all.sh 성공 기준을 확인했다.
[ ] validation_results.txt 확인 기준을 확인했다.
[ ] query_results.txt 확인 기준을 확인했다.
[ ] review-practice.sql 실행 기준을 확인했다.
[ ] git status 기준을 확인했다.
[ ] 30초 답변을 말했다.
[ ] 1분 답변을 말했다.
```
