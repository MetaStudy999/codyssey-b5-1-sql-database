# B5-1 평가 최종 체크리스트

이 문서는 B5-1 「SQL로 만드는 나만의 데이터베이스」 평가 직전 최종 점검을 위한 체크리스트이다.

목표는 단순히 파일을 제출하는 것이 아니라, **프로젝트가 재현 가능하고**, **SQL이 실행되며**, **설계 의도를 말로 설명할 수 있고**, **평가자가 요구사항 충족 여부를 빠르게 확인할 수 있는 상태**를 만드는 것이다.

---

## 1. 최종 합격 기준 한 줄 요약

```text
4개 이상 테이블, 1:N 관계 2개 이상, PK/FK/제약조건, 샘플 데이터, SELECT/JOIN/GROUP BY/서브쿼리/UPDATE/DELETE/인덱스 쿼리, 실행 결과, ERD, 평가 답변을 모두 설명 가능해야 한다.
```

---

## 2. 제출물 최종 확인

아래 파일이 저장소에 있어야 한다.

```text
[ ] README.md
[ ] sql/01_schema.sql
[ ] sql/02_seed.sql
[ ] sql/03_queries.sql
[ ] docs/ERD.md
[ ] docs/evaluation_answers.md
[ ] results/query_results.md
[ ] scripts/run_all.sh
[ ] book_rental.db 또는 실행으로 재생성 가능한 DB 생성 흐름
```

평가용 핵심 설명:

> 이 프로젝트는 스키마, 샘플 데이터, 핵심 쿼리, 실행 결과, ERD, 평가 답변이 분리되어 있어 평가자가 구조와 실행 결과를 쉽게 확인할 수 있도록 구성했습니다.

---

## 3. 저장소 구조 확인

프로젝트 루트에서 확인한다.

```bash
pwd
tree -L 3
```

확인할 구조:

```text
.
├── README.md
├── docs/
│   ├── ERD.md
│   └── evaluation_answers.md
├── results/
│   └── query_results.md
├── scripts/
│   └── run_all.sh
├── sql/
│   ├── 01_schema.sql
│   ├── 02_seed.sql
│   └── 03_queries.sql
└── training-materials/
```

체크:

```text
[ ] 핵심 SQL 파일이 sql/ 폴더에 있다.
[ ] 문서 파일이 docs/ 폴더에 있다.
[ ] 실행 결과가 results/ 폴더에 있다.
[ ] 자동 실행 스크립트가 scripts/ 폴더에 있다.
[ ] 훈련 자료는 training-materials/에 따로 정리되어 있다.
```

---

## 4. 실행 검증 체크리스트

프로젝트 루트에서 실행한다.

```bash
chmod +x scripts/run_all.sh
./scripts/run_all.sh
```

확인할 것:

```text
[ ] 오류 없이 스키마가 생성된다.
[ ] 샘플 데이터가 INSERT된다.
[ ] 핵심 쿼리가 실행된다.
[ ] UPDATE/DELETE 테스트가 의도대로 실행된다.
[ ] 인덱스 생성 및 EXPLAIN QUERY PLAN이 실행된다.
[ ] results/query_results.md 또는 실행 결과 파일이 최신 상태다.
```

문제가 생기면 확인할 것:

```text
[ ] sqlite3가 설치되어 있는가?
[ ] scripts/run_all.sh 실행 권한이 있는가?
[ ] sql 파일 경로가 맞는가?
[ ] 현재 위치가 프로젝트 루트인가?
[ ] 이전 DB 파일 때문에 결과가 꼬이지 않았는가?
```

---

## 5. SQLite 기본 확인

```bash
sqlite3 --version
sqlite3 book_rental.db
```

SQLite 안에서 확인:

```sql
.tables
.schema member
.schema category
.schema book
.schema rental
```

체크:

```text
[ ] member 테이블이 있다.
[ ] category 테이블이 있다.
[ ] book 테이블이 있다.
[ ] rental 테이블이 있다.
[ ] 각 테이블의 PK가 보인다.
[ ] FK 제약조건이 보인다.
[ ] NOT NULL, UNIQUE, CHECK 제약조건이 보인다.
```

---

## 6. 데이터 수 확인

SQLite 안에서 실행한다.

```sql
SELECT 'member' AS table_name, COUNT(*) AS row_count FROM member
UNION ALL
SELECT 'category', COUNT(*) FROM category
UNION ALL
SELECT 'book', COUNT(*) FROM book
UNION ALL
SELECT 'rental', COUNT(*) FROM rental;
```

체크:

```text
[ ] 각 테이블에 샘플 데이터가 들어 있다.
[ ] 각 테이블 최소 10행 이상 조건을 충족한다.
[ ] FK 오류 없이 데이터가 들어간다.
```

평가 답변:

> 샘플 데이터는 각 테이블에 충분히 넣어 JOIN, GROUP BY, 서브쿼리, UPDATE, DELETE, 인덱스 쿼리를 실제로 실행해볼 수 있도록 구성했습니다.

---

## 7. 스키마 설계 최종 체크

### 7.1 테이블 역할

```text
[ ] member: 회원 정보
[ ] category: 도서 분류
[ ] book: 도서 정보
[ ] rental: 대여 이력
```

### 7.2 PK

```text
[ ] member.member_id
[ ] category.category_id
[ ] book.book_id
[ ] rental.rental_id
```

### 7.3 FK

```text
[ ] book.category_id → category.category_id
[ ] rental.member_id → member.member_id
[ ] rental.book_id → book.book_id
```

### 7.4 제약조건

```text
[ ] NOT NULL: 필수값 제한
[ ] UNIQUE: email, category.name, isbn 중복 방지
[ ] CHECK: status, price, stock, rental_fee 값 제한
[ ] ON UPDATE CASCADE: 부모 키 변경 시 자식 참조 갱신
[ ] ON DELETE RESTRICT: 참조 중인 부모 삭제 제한
```

평가 답변:

> 테이블은 역할별로 분리했고, 각 테이블에는 PK를 두었습니다. 관계는 FK로 연결했으며, 필수값·중복값·상태값·숫자 범위를 제약조건으로 제한해 데이터 무결성을 높였습니다.

---

## 8. 관계/ERD 최종 체크

반드시 말할 수 있어야 하는 관계:

```text
[ ] category 1:N book
[ ] member 1:N rental
[ ] book 1:N rental
```

말하기 스크립트:

> `category`는 여러 도서를 가질 수 있으므로 `category → book`은 1:N입니다. `member`는 여러 대여 기록을 가질 수 있으므로 `member → rental`도 1:N입니다. `book`도 여러 대여 기록에 등장할 수 있으므로 `book → rental`도 1:N입니다.

---

## 9. 핵심 쿼리 요구사항 체크

```text
[ ] 기본 SELECT / WHERE / ORDER BY / LIMIT 쿼리가 있다.
[ ] LIKE 검색 쿼리가 있다.
[ ] INNER JOIN 쿼리가 있다.
[ ] LEFT JOIN 쿼리가 있다.
[ ] GROUP BY + COUNT 쿼리가 있다.
[ ] GROUP BY + SUM 쿼리가 있다.
[ ] GROUP BY + AVG 쿼리가 있다.
[ ] 서브쿼리 쿼리가 있다.
[ ] UPDATE 쿼리가 있다.
[ ] DELETE 쿼리가 있다.
[ ] CREATE INDEX 쿼리가 있다.
[ ] EXPLAIN QUERY PLAN 쿼리가 있다.
```

평가 답변:

> 핵심 쿼리는 기본 조회부터 JOIN, 집계, 서브쿼리, 수정, 삭제, 인덱스까지 포함했습니다. 따라서 데이터 모델링 후 실제 요구사항을 SQL로 해결하는 흐름을 보여줄 수 있습니다.

---

## 10. JOIN 최종 점검

### 반드시 설명할 JOIN 조건

```sql
rental.member_id = member.member_id
rental.book_id = book.book_id
book.category_id = category.category_id
```

### INNER JOIN 답변

> INNER JOIN은 양쪽 테이블에서 연결 조건이 맞는 행만 보여줍니다. `rental`에 회원명과 도서명이 없기 때문에 `member`, `book`과 JOIN해서 사람이 읽기 쉬운 대여 기록을 만들었습니다.

### LEFT JOIN 답변

> LEFT JOIN은 왼쪽 테이블의 모든 행을 유지합니다. 그래서 대여 기록이 없는 회원까지 포함해 회원별 대여 횟수를 0건으로 계산할 수 있습니다.

체크:

```text
[ ] INNER JOIN과 LEFT JOIN 차이를 말할 수 있다.
[ ] ON과 WHERE 차이를 말할 수 있다.
[ ] FK 기준으로 JOIN 조건을 설명할 수 있다.
[ ] LEFT JOIN에서 NULL이 나오는 이유를 설명할 수 있다.
```

---

## 11. GROUP BY 최종 점검

### 핵심 답변

> GROUP BY는 같은 기준의 행을 묶고, COUNT, SUM, AVG는 그룹별 개수, 합계, 평균을 계산합니다.

### 예시 답변

> 회원별 대여 횟수는 `member`와 `rental`을 JOIN하고, `member_id`, `name`으로 GROUP BY한 뒤 `COUNT(r.rental_id)`로 계산했습니다.

체크:

```text
[ ] GROUP BY 정의를 말할 수 있다.
[ ] COUNT, SUM, AVG 차이를 말할 수 있다.
[ ] WHERE와 HAVING 차이를 말할 수 있다.
[ ] COUNT(*)와 COUNT(r.rental_id)의 차이를 말할 수 있다.
[ ] 회원별 대여 횟수 쿼리를 설명할 수 있다.
[ ] 카테고리별 평균 가격 쿼리를 설명할 수 있다.
```

---

## 12. 서브쿼리 최종 점검

### 핵심 답변

> 서브쿼리는 SELECT 안에 들어가는 또 다른 SELECT이며, 안쪽 쿼리 결과를 바깥 쿼리의 조건으로 사용합니다.

### 대표 예시

```sql
SELECT book_id, title, price
FROM book
WHERE price > (SELECT AVG(price) FROM book)
ORDER BY price DESC;
```

말하기 스크립트:

> 안쪽 쿼리에서 전체 도서 평균 가격을 계산하고, 바깥 쿼리에서 그 평균보다 비싼 도서만 조회합니다.

체크:

```text
[ ] 스칼라 서브쿼리를 설명할 수 있다.
[ ] IN 서브쿼리를 설명할 수 있다.
[ ] EXISTS를 설명할 수 있다.
[ ] NOT EXISTS를 설명할 수 있다.
[ ] 상관 서브쿼리를 설명할 수 있다.
[ ] JOIN과 서브쿼리 선택 기준을 말할 수 있다.
```

---

## 13. UPDATE / DELETE 최종 점검

### UPDATE 답변

> 특정 대여 기록의 상태를 `OVERDUE`로 바꾸고 연체 수수료를 설정했습니다. UPDATE 전에는 SELECT로 대상 행을 확인하고, WHERE 조건을 명확히 사용해야 합니다.

### DELETE 답변

> 테스트용 대여 기록을 삭제했습니다. DELETE도 WHERE 조건 없이 실행하면 전체 행이 삭제될 수 있으므로, 삭제 전 SELECT로 대상 행을 확인하는 것이 안전합니다.

체크:

```text
[ ] UPDATE 대상 조건을 설명할 수 있다.
[ ] DELETE 대상 조건을 설명할 수 있다.
[ ] WHERE 없는 UPDATE/DELETE 위험을 말할 수 있다.
[ ] 임시 DB 또는 트랜잭션 사용 이유를 말할 수 있다.
```

---

## 14. 인덱스 / 실행 계획 최종 점검

### 인덱스 생성 쿼리

```sql
CREATE INDEX IF NOT EXISTS idx_rental_member_due
ON rental(member_id, due_date);
```

### 실행 계획 확인 쿼리

```sql
EXPLAIN QUERY PLAN
SELECT rental_id, member_id, book_id, due_date, status
FROM rental
WHERE member_id = 1
ORDER BY due_date ASC;
```

### 핵심 답변

> 특정 회원의 대여 기록을 반납기한 순으로 조회하기 위해 `rental(member_id, due_date)`에 복합 인덱스를 만들었습니다. `member_id`는 WHERE 조건에 쓰이고, `due_date`는 ORDER BY 조건에 쓰입니다. `EXPLAIN QUERY PLAN`으로 인덱스 사용 여부를 확인할 수 있습니다.

체크:

```text
[ ] 인덱스 정의를 말할 수 있다.
[ ] idx_rental_member_due 이름을 말할 수 있다.
[ ] member_id가 첫 번째 컬럼인 이유를 말할 수 있다.
[ ] due_date가 두 번째 컬럼인 이유를 말할 수 있다.
[ ] EXPLAIN QUERY PLAN의 역할을 말할 수 있다.
[ ] SCAN, SEARCH, USING INDEX의 의미를 말할 수 있다.
[ ] 인덱스의 비용을 말할 수 있다.
```

---

## 15. Git 상태 최종 확인

```bash
git status
git log --oneline -5
```

체크:

```text
[ ] 변경 사항이 모두 커밋되어 있다.
[ ] 원격 저장소에 push되어 있다.
[ ] 평가자가 GitHub에서 최신 파일을 볼 수 있다.
[ ] README에서 실행 방법을 찾을 수 있다.
[ ] 핵심 파일 경로가 명확하다.
```

문제가 있으면:

```bash
git add .
git commit -m "docs: finalize B5-1 evaluation materials"
git push
```

---

## 16. 평가자에게 보여줄 파일 순서

평가자가 저장소를 볼 때 아래 순서로 안내한다.

```text
1. README.md
2. docs/ERD.md
3. sql/01_schema.sql
4. sql/02_seed.sql
5. sql/03_queries.sql
6. results/query_results.md
7. docs/evaluation_answers.md
8. training-materials/06-evaluation-qa/expected-questions.md
9. training-materials/06-evaluation-qa/answer-scripts.md
10. training-materials/06-evaluation-qa/final-checklist.md
```

말하기 스크립트:

> README에서 프로젝트 개요와 실행 방법을 볼 수 있고, ERD에서 테이블 관계를 확인할 수 있습니다. SQL 폴더에는 스키마, 샘플 데이터, 핵심 쿼리가 있으며, results 폴더에는 실행 결과를 남겼습니다. 평가 답변과 훈련 자료도 문서화했습니다.

---

## 17. 평가 직전 30분 루틴

```text
[ ] README를 3분 안에 훑는다.
[ ] ERD를 보고 1:N 관계 3개를 말한다.
[ ] schema.sql에서 PK/FK/제약조건을 확인한다.
[ ] queries.sql에서 JOIN/GROUP BY/서브쿼리/인덱스 쿼리를 확인한다.
[ ] query_results.md에서 실행 결과가 있는지 확인한다.
[ ] 30초 자기소개형 답변을 2회 말한다.
[ ] 1분 종합 답변을 1회 말한다.
[ ] 인덱스 답변을 1회 말한다.
[ ] UPDATE/DELETE 안전 답변을 1회 말한다.
```

---

## 18. 평가 직전 5분 루틴

```text
[ ] 테이블 4개: member, category, book, rental
[ ] 관계 3개: category-book, member-rental, book-rental
[ ] FK 3개: book.category_id, rental.member_id, rental.book_id
[ ] JOIN 조건 3개를 말한다.
[ ] GROUP BY 대표 예시 1개를 말한다.
[ ] 서브쿼리 대표 예시 1개를 말한다.
[ ] 인덱스 이름 idx_rental_member_due를 말한다.
[ ] 15초 프로젝트 답변을 말한다.
```

---

## 19. 감점 방지 체크리스트

```text
[ ] “그냥 만들었습니다”라고 말하지 않는다.
[ ] 모든 설계에는 이유를 붙인다.
[ ] JOIN 조건을 FK 기준으로 설명한다.
[ ] UPDATE/DELETE는 WHERE 안전성을 반드시 언급한다.
[ ] 인덱스는 무조건 빠르다고 말하지 않는다.
[ ] SQLite 실행 계획 문구는 버전에 따라 다를 수 있다고 말할 수 있다.
[ ] 백엔드가 없는 이유를 미션 목적과 연결해 설명한다.
[ ] 모르는 질문은 프로젝트 범위와 확장 방향으로 답한다.
```

---

## 20. 실수했을 때 복구 문장

```text
방금 표현을 정정하겠습니다.
정확히는 WHERE는 행 필터이고 HAVING은 집계 결과 필터입니다.
```

```text
정정하겠습니다.
rental.member_id는 member.member_id와 연결되고,
rental.book_id는 book.book_id와 연결됩니다.
```

```text
제가 구현한 범위에서는 여기까지 처리했고,
실제 서비스에서는 별도 테이블이나 트랜잭션으로 확장할 수 있습니다.
```

---

## 21. 최종 15초 답변

> 도서 대여 관리 DB를 설계해 `member`, `category`, `book`, `rental` 네 개 테이블과 1:N 관계를 만들었습니다. PK/FK/제약조건, 샘플 데이터, SELECT/JOIN/GROUP BY/서브쿼리/UPDATE/DELETE/인덱스 쿼리와 실행 결과까지 준비했습니다.

---

## 22. 최종 1분 답변

> 이번 프로젝트는 SQLite 기반 도서 대여 관리 데이터베이스입니다. `member`, `category`, `book`, `rental` 네 개의 테이블을 만들고, `category → book`, `member → rental`, `book → rental`의 1:N 관계를 설계했습니다. 각 테이블에는 PK를 두고, `book.category_id`, `rental.member_id`, `rental.book_id`에 FK를 설정했습니다. 쿼리는 기본 조회, INNER JOIN, LEFT JOIN, GROUP BY 집계, 서브쿼리, UPDATE, DELETE, 인덱스를 작성했습니다. 회원별 대여 횟수는 JOIN 후 GROUP BY와 COUNT로 계산했고, 평균 가격보다 비싼 도서는 서브쿼리로 처리했습니다. 마지막으로 회원별 반납기한 조회를 위해 `rental(member_id, due_date)` 복합 인덱스를 만들고 `EXPLAIN QUERY PLAN`으로 확인했습니다.

---

## 23. 최종 제출 전 완료 기준

```text
[ ] 필수 파일이 모두 있다.
[ ] run_all.sh가 실행된다.
[ ] SQL 쿼리 결과가 남아 있다.
[ ] ERD가 있다.
[ ] 평가 답변 문서가 있다.
[ ] 30초 답변을 말할 수 있다.
[ ] 1분 답변을 말할 수 있다.
[ ] JOIN/GROUP BY/서브쿼리/인덱스를 각각 설명할 수 있다.
[ ] GitHub에 최신 상태가 push되어 있다.
```
