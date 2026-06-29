# B5-1 훈련 계획서

이 문서는 코디세이 B5-1 「SQL로 만드는 나만의 데이터베이스」 미션을 평가 전까지 반복 훈련하기 위한 실행 계획서이다.

제출물 자체를 새로 만드는 문서가 아니라, 이미 구성된 도서 대여 관리 DB를 기준으로 **개념 이해 → SQL 작성 → 실행 결과 확인 → 평가 답변 연습**을 반복하기 위한 계획이다.

---

## 1. 현재 프로젝트 기준

### 1.1 미션

- 미션명: B5-1. SQL로 만드는 나만의 데이터베이스
- 주제: 도서 대여 관리 데이터베이스
- DB: SQLite 3
- 백엔드 프레임워크: 사용하지 않음

### 1.2 핵심 테이블

| 테이블 | 역할 | 평가 때 설명할 핵심 |
|---|---|---|
| `member` | 도서관 회원 | 누가 책을 빌리는지 저장한다. |
| `category` | 도서 분류 | 책을 주제별로 분류한다. |
| `book` | 도서 정보 | 어떤 책이 있는지 저장한다. |
| `rental` | 대여 기록 | 누가 어떤 책을 언제 빌렸는지 기록한다. |

### 1.3 핵심 관계

```text
category 1 : N book
member   1 : N rental
book     1 : N rental
```

### 1.4 평가 제출물 위치

| 제출 항목 | 파일 |
|---|---|
| 스키마 생성 SQL | `sql/01_schema.sql` |
| 샘플 데이터 INSERT SQL | `sql/02_seed.sql` |
| 핵심 쿼리 15개 | `sql/03_queries.sql` |
| 검증 SQL | `sql/04_validation.sql` |
| 실행 결과 | `results/query_results.txt` |
| 검증 결과 | `results/validation_results.txt` |
| ERD | `docs/ERD.md` |
| 평가 답변 | `docs/evaluation_answers.md` |

---

## 2. 훈련 최종 목표

평가 전까지 아래 10개를 보지 않고 설명할 수 있어야 한다.

```text
[ ] 엑셀과 DB의 차이
[ ] 왜 테이블을 4개로 나누었는지
[ ] PK와 FK의 차이
[ ] 1:N 관계 3개
[ ] NOT NULL, UNIQUE, CHECK 제약조건의 의미
[ ] SELECT / INSERT / UPDATE / DELETE의 사용 시점
[ ] INNER JOIN과 LEFT JOIN의 차이
[ ] GROUP BY와 집계 함수의 동작 방식
[ ] 서브쿼리와 JOIN 방식의 차이
[ ] rental(member_id, due_date)에 인덱스를 만든 이유
```

---

## 3. 전체 훈련 흐름

B5-1은 아래 순서로 훈련한다.

```text
1단계: 실행 환경 확인
2단계: DB 생성과 검증
3단계: 스키마 구조 이해
4단계: 기본 조회 훈련
5단계: JOIN 훈련
6단계: GROUP BY 집계 훈련
7단계: 서브쿼리와 인덱스 훈련
8단계: UPDATE / DELETE 안전성 확인
9단계: ERD 기반 설명 훈련
10단계: 평가 예상 질문 답변 훈련
```

---

## 4. 1단계 - 실행 환경 확인

### 목표

SQLite와 프로젝트 실행 스크립트가 정상 동작하는지 확인한다.

### 실행 명령

```bash
sqlite3 --version
pwd
ls -la
```

### 확인할 것

```text
[ ] sqlite3 버전이 출력되는가?
[ ] 현재 위치가 프로젝트 루트인가?
[ ] sql/, docs/, results/, scripts/ 폴더가 보이는가?
```

### 설명 연습

> 이 프로젝트는 SQLite를 사용합니다. SQLite는 파일 기반 DB이기 때문에 별도 서버 실행 없이 `book_rental.db` 파일 하나로 실습할 수 있습니다.

---

## 5. 2단계 - DB 생성과 검증

### 목표

`run_all.sh`로 DB를 생성하고 결과 파일이 갱신되는지 확인한다.

### 실행 명령

```bash
chmod +x scripts/run_all.sh
./scripts/run_all.sh
```

### 결과 확인

```bash
cat results/validation_results.txt
cat results/query_results.txt
cat results/bonus_results.txt
```

### 체크리스트

```text
[ ] book_rental.db 파일이 생성되었는가?
[ ] member 10행이 확인되는가?
[ ] category 10행이 확인되는가?
[ ] book 15행이 확인되는가?
[ ] rental 20행이 확인되는가?
[ ] foreign_key_check 결과에 오류가 없는가?
```

### 설명 연습

> 검증 결과에서 모든 테이블이 10행 이상이고, FK 무결성 오류가 없으므로 샘플 데이터와 관계 설정이 정상입니다.

---

## 6. 3단계 - 스키마 구조 이해

### 목표

`sql/01_schema.sql`을 보고 테이블과 제약조건을 설명한다.

### 확인 파일

```text
sql/01_schema.sql
```

### 집중해서 볼 부분

```text
member.member_id INTEGER PRIMARY KEY
member.email TEXT NOT NULL UNIQUE
book.category_id INTEGER NOT NULL
book.isbn TEXT NOT NULL UNIQUE
book.price INTEGER NOT NULL CHECK (price >= 0)
rental.member_id INTEGER NOT NULL
rental.book_id INTEGER NOT NULL
FOREIGN KEY (...) REFERENCES ...
```

### 체크리스트

```text
[ ] 모든 테이블의 PK를 찾을 수 있는가?
[ ] FK 3개를 찾을 수 있는가?
[ ] UNIQUE 제약조건을 찾을 수 있는가?
[ ] NOT NULL 제약조건을 찾을 수 있는가?
[ ] CHECK 제약조건을 찾을 수 있는가?
```

### 설명 연습

> `rental.member_id`는 `member.member_id`를 참조하므로 존재하지 않는 회원의 대여 기록을 만들 수 없습니다. 이것이 FK를 통한 데이터 무결성입니다.

---

## 7. 4단계 - 기본 조회 훈련

### 목표

`SELECT`, `WHERE`, `ORDER BY`, `LIMIT`을 직접 작성한다.

### 기준 쿼리

```sql
SELECT member_id, name, email, joined_at, status
FROM member
WHERE status = 'ACTIVE'
ORDER BY joined_at ASC;
```

### 직접 작성할 연습 쿼리

```text
[ ] ACTIVE 회원만 조회한다.
[ ] 가격이 30,000원 이상인 도서를 조회한다.
[ ] 제목에 SQL이 들어간 도서를 조회한다.
[ ] 현재 RENTED 상태인 대여 기록을 조회한다.
[ ] 가격이 높은 도서 TOP 5를 조회한다.
```

### 설명 연습

> `WHERE`는 조건을 거는 절이고, `ORDER BY`는 정렬 기준을 정하며, `LIMIT`은 출력 행 수를 제한합니다.

---

## 8. 5단계 - JOIN 훈련

### 목표

테이블 간 관계를 이용해 사람이 읽기 쉬운 결과를 만든다.

### 기준 쿼리

```sql
SELECT r.rental_id, m.name AS member_name, b.title AS book_title, r.rented_at, r.status
FROM rental r
INNER JOIN member m ON r.member_id = m.member_id
INNER JOIN book b ON r.book_id = b.book_id
ORDER BY r.rented_at DESC;
```

### 직접 작성할 연습 쿼리

```text
[ ] 대여 기록에 회원 이름을 붙여 조회한다.
[ ] 대여 기록에 도서 제목을 붙여 조회한다.
[ ] 도서 목록에 카테고리명을 붙여 조회한다.
[ ] 연체 기록에 회원명, 도서명, 카테고리명을 함께 붙여 조회한다.
[ ] 대여 기록이 없는 회원도 LEFT JOIN으로 조회한다.
```

### 설명 연습

> INNER JOIN은 양쪽 테이블에 매칭되는 데이터만 보여줍니다. LEFT JOIN은 왼쪽 테이블의 행을 모두 유지하고, 오른쪽에 매칭이 없으면 NULL로 표시합니다.

---

## 9. 6단계 - GROUP BY 집계 훈련

### 목표

대여 횟수, 수수료 합계, 평균 가격 같은 지표를 SQL로 계산한다.

### 기준 쿼리

```sql
SELECT m.member_id, m.name, COUNT(r.rental_id) AS rental_count, SUM(r.rental_fee) AS total_fee
FROM member m
INNER JOIN rental r ON m.member_id = r.member_id
GROUP BY m.member_id, m.name
ORDER BY rental_count DESC;
```

### 직접 작성할 연습 쿼리

```text
[ ] 회원별 대여 횟수를 구한다.
[ ] 회원별 대여 수수료 합계를 구한다.
[ ] 카테고리별 도서 수를 구한다.
[ ] 카테고리별 평균 도서 가격을 구한다.
[ ] 대여 상태별 건수를 구한다.
[ ] 월별 대여 건수를 구한다.
```

### 설명 연습

> `GROUP BY`는 같은 기준의 행을 묶고, `COUNT`, `SUM`, `AVG`는 각 그룹별 개수, 합계, 평균을 계산합니다.

---

## 10. 7단계 - 서브쿼리와 인덱스 훈련

### 목표

서브쿼리와 인덱스의 역할을 이해하고 설명한다.

### 서브쿼리 기준 쿼리

```sql
SELECT book_id, title, price
FROM book
WHERE price > (SELECT AVG(price) FROM book)
ORDER BY price DESC;
```

### 인덱스 기준 쿼리

```sql
CREATE INDEX IF NOT EXISTS idx_rental_member_due
ON rental(member_id, due_date);

EXPLAIN QUERY PLAN
SELECT rental_id, member_id, book_id, due_date, status
FROM rental
WHERE member_id = 1
ORDER BY due_date ASC;
```

### 직접 작성할 연습 쿼리

```text
[ ] 평균 가격보다 비싼 도서를 서브쿼리로 찾는다.
[ ] AI 카테고리 도서를 빌린 회원을 서브쿼리로 찾는다.
[ ] JOIN으로 푼 쿼리를 서브쿼리로 다시 작성한다.
[ ] EXPLAIN QUERY PLAN 결과에서 USING INDEX 문구를 확인한다.
```

### 설명 연습

> 인덱스는 자주 검색하거나 정렬하는 컬럼에 적용합니다. 이 프로젝트에서는 특정 회원의 대여 기록을 반납기한 순으로 조회하는 요구가 있으므로 `rental(member_id, due_date)`에 인덱스를 만들었습니다.

---

## 11. 8단계 - UPDATE / DELETE 안전성 확인

### 목표

수정과 삭제 쿼리를 안전하게 실행하는 습관을 만든다.

### 원칙

```text
1. UPDATE/DELETE 전에 반드시 SELECT로 대상 행을 확인한다.
2. WHERE 없는 UPDATE/DELETE는 실행하지 않는다.
3. 평가용 실행에서는 임시 DB 복사본에서 변경 쿼리를 실행한다.
```

### 기준 쿼리

```sql
SELECT * FROM rental WHERE rental_id = 4;

UPDATE rental
SET status = 'OVERDUE', rental_fee = 2000
WHERE rental_id = 4;

SELECT * FROM rental WHERE rental_id = 4;
```

### 설명 연습

> UPDATE와 DELETE는 데이터를 변경하므로 WHERE 조건이 중요합니다. 이 프로젝트의 자동 실행 스크립트는 핵심 쿼리 15개를 임시 DB 복사본에서 실행해 원본 검증 데이터가 훼손되지 않도록 했습니다.

---

## 12. 9단계 - ERD 기반 설명 훈련

### 목표

`docs/ERD.md`를 보고 테이블 관계를 말로 설명한다.

### 말로 설명할 내용

```text
[ ] member 테이블의 역할
[ ] category 테이블의 역할
[ ] book 테이블의 역할
[ ] rental 테이블의 역할
[ ] category 1:N book 관계
[ ] member 1:N rental 관계
[ ] book 1:N rental 관계
```

### 설명 연습

> `rental`은 회원과 책이 만나는 사건 테이블입니다. 한 회원은 여러 번 책을 빌릴 수 있고, 한 책도 여러 번 대여될 수 있으므로 대여 이력을 별도 테이블로 분리했습니다.

---

## 13. 10단계 - 평가 예상 질문 답변 훈련

### 목표

평가자가 질문했을 때 코드와 결과를 보며 답변한다.

### 예상 질문

```text
[ ] 엑셀과 DB는 무엇이 다른가?
[ ] 왜 테이블을 나누었는가?
[ ] PK와 FK는 무엇인가?
[ ] FK가 실제로 동작한다는 증거는 무엇인가?
[ ] INNER JOIN과 LEFT JOIN은 무엇이 다른가?
[ ] GROUP BY는 언제 쓰는가?
[ ] COUNT, SUM, AVG는 각각 무엇을 계산하는가?
[ ] 서브쿼리는 어떤 상황에서 썼는가?
[ ] 인덱스는 왜 만들었는가?
[ ] 가장 복잡했던 쿼리는 무엇인가?
[ ] 미션 중 어려웠던 점과 해결 방법은 무엇인가?
```

### 답변 훈련 방식

```text
1. 질문 하나를 고른다.
2. 관련 SQL 파일을 연다.
3. 관련 결과 파일을 연다.
4. 30초 안에 말로 설명한다.
5. 막힌 부분은 training-materials/07-error-notes/mistakes-log.md에 기록한다.
```

---

## 14. 3일 집중 훈련 계획

### Day 1 - 구조 이해와 기본 SQL

```text
[ ] README.md 읽기
[ ] SUBMISSION.md 읽기
[ ] sql/01_schema.sql 읽기
[ ] sql/02_seed.sql 읽기
[ ] results/validation_results.txt 확인
[ ] SELECT 기본 조회 5개 직접 작성
[ ] 테이블을 나눈 이유 3문장으로 설명
```

### Day 2 - JOIN과 집계

```text
[ ] INNER JOIN 3개 직접 작성
[ ] LEFT JOIN 2개 직접 작성
[ ] GROUP BY 5개 직접 작성
[ ] results/query_results.txt에서 Q05~Q11 설명
[ ] INNER JOIN / LEFT JOIN 차이 말로 설명
[ ] GROUP BY / COUNT / SUM / AVG 말로 설명
```

### Day 3 - 평가 답변과 보너스

```text
[ ] 서브쿼리 3개 직접 작성
[ ] EXPLAIN QUERY PLAN 실행
[ ] docs/ERD.md 보며 관계 설명
[ ] docs/bonus.sql 보며 보너스 설명
[ ] docs/evaluation_answers.md 보지 않고 답변 연습
[ ] 10개 예상 질문에 답변 녹음 또는 소리 내어 설명
```

---

## 15. 하루 90분 루틴

```text
00~10분: 어제 막힌 오류 복습
10~25분: 기본 조회 SQL 작성
25~45분: JOIN SQL 작성
45~60분: GROUP BY 또는 서브쿼리 작성
60~75분: 실행 결과 확인 및 설명 작성
75~90분: 평가 질문 3개 말로 답변
```

---

## 16. 훈련 기록 양식

매일 아래 양식으로 기록한다.

```md
## YYYY-MM-DD 훈련 기록

### 오늘 실행한 명령

```bash
./scripts/run_all.sh
sqlite3 book_rental.db
```

### 오늘 작성한 SQL

```sql
-- 여기에 직접 작성한 쿼리 기록
```

### 오늘 설명 연습한 질문

1. 
2. 
3. 

### 오늘 막힌 점

- 

### 해결 방법

- 

### 내일 할 일

- 
```

---

## 17. 평가 직전 10분 점검

평가 직전에는 아래 순서로만 확인한다.

```text
1. SUBMISSION.md 열기
2. docs/ERD.md 열기
3. sql/01_schema.sql 열기
4. sql/03_queries.sql 열기
5. results/validation_results.txt 열기
6. results/query_results.txt 열기
7. docs/evaluation_answers.md 열기
```

말로 외울 핵심 문장:

> 이 프로젝트는 도서 대여 도메인을 `member`, `category`, `book`, `rental` 네 테이블로 나누어 설계했습니다. `rental`이 회원과 도서를 연결하는 대여 이력 테이블이고, FK를 통해 존재하지 않는 회원이나 도서를 참조하지 못하게 했습니다. JOIN과 GROUP BY를 사용해 대여 현황, 연체 현황, 회원별 대여 횟수 같은 실무형 요구를 SQL로 해결했습니다.

---

## 18. 완료 기준

아래를 모두 만족하면 B5-1 평가 대비 훈련을 완료한 것으로 본다.

```text
[ ] DB를 직접 생성할 수 있다.
[ ] 4개 테이블 역할을 설명할 수 있다.
[ ] PK/FK/제약조건을 스키마에서 찾을 수 있다.
[ ] 기본 조회 4개를 직접 작성할 수 있다.
[ ] JOIN 4개를 직접 작성할 수 있다.
[ ] GROUP BY 집계 3개를 직접 작성할 수 있다.
[ ] 서브쿼리 1개를 직접 작성할 수 있다.
[ ] UPDATE/DELETE를 안전하게 설명할 수 있다.
[ ] 인덱스 선택 이유를 설명할 수 있다.
[ ] ERD를 보며 1:N 관계를 설명할 수 있다.
[ ] 예상 질문 10개에 답할 수 있다.
```
