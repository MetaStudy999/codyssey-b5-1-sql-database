# B5-1 일일 훈련 체크리스트

이 문서는 B5-1 「SQL로 만드는 나만의 데이터베이스」 평가 전까지 매일 반복할 훈련 체크리스트이다.

하루 목표는 많은 양을 보는 것이 아니라, **직접 실행하고, 직접 설명하고, 막힌 점을 기록하는 것**이다.

---

## 1. 사용 방법

매일 훈련 시작 전에 이 파일을 열고, 아래 순서대로 체크한다.

```text
1. 실행 환경 확인
2. DB 재생성
3. 검증 결과 확인
4. 기본 조회 SQL 작성
5. JOIN SQL 작성
6. GROUP BY SQL 작성
7. 서브쿼리 또는 인덱스 확인
8. 평가 질문 답변 연습
9. 오류·실수 기록
10. 오늘의 커밋
```

권장 시간은 하루 **60~90분**이다.

---

## 2. 오늘의 훈련 기록 양식

아래 양식을 복사해서 매일 아래에 추가한다.

```md
## YYYY-MM-DD

### 1) 오늘의 목표

- [ ] 기본 조회 SQL을 직접 작성한다.
- [ ] JOIN SQL을 직접 작성한다.
- [ ] GROUP BY SQL을 직접 작성한다.
- [ ] 평가 예상 질문에 말로 답한다.
- [ ] 오류나 실수를 1개 이상 기록한다.

### 2) 실행 확인

- [ ] `sqlite3 --version` 확인
- [ ] `./scripts/run_all.sh` 실행
- [ ] `book_rental.db` 생성 확인
- [ ] `results/validation_results.txt` 확인
- [ ] `results/query_results.txt` 확인

### 3) 오늘 직접 작성한 SQL 수

- 기본 조회: ___개
- JOIN: ___개
- GROUP BY/집계: ___개
- 서브쿼리: ___개
- UPDATE/DELETE/INDEX: ___개

### 4) 오늘 설명 연습한 질문

1. 
2. 
3. 

### 5) 오늘 막힌 점

- 

### 6) 해결 방법

- 

### 7) 내일 보완할 점

- 
```

---

## 3. 매일 실행할 기본 명령

프로젝트 루트에서 실행한다.

```bash
pwd
ls -la
sqlite3 --version
chmod +x scripts/run_all.sh
./scripts/run_all.sh
```

결과 파일 확인:

```bash
cat results/validation_results.txt
cat results/query_results.txt
cat results/bonus_results.txt
```

SQLite 직접 접속:

```bash
sqlite3 book_rental.db
```

SQLite 안에서 설정:

```sql
.headers on
.mode column
PRAGMA foreign_keys = ON;
```

종료:

```sql
.exit
```

---

## 4. 일일 필수 체크리스트

### 4.1 실행 환경

```text
[ ] 프로젝트 루트에서 작업하고 있다.
[ ] `sqlite3 --version`이 출력된다.
[ ] `scripts/run_all.sh`가 실행된다.
[ ] `book_rental.db`가 생성된다.
[ ] `results/validation_results.txt`가 갱신된다.
[ ] `results/query_results.txt`가 갱신된다.
```

### 4.2 검증 결과

```text
[ ] `member` 테이블이 10행이다.
[ ] `category` 테이블이 10행이다.
[ ] `book` 테이블이 15행이다.
[ ] `rental` 테이블이 20행이다.
[ ] `PRAGMA foreign_key_check` 결과에 오류가 없다.
```

### 4.3 기본 조회

매일 아래 중 최소 3개를 직접 작성한다.

```text
[ ] 전체 회원 조회
[ ] ACTIVE 회원 조회
[ ] 가격이 30,000원 이상인 도서 조회
[ ] 제목에 특정 단어가 들어간 도서 조회
[ ] 대여 중인 기록 조회
[ ] 연체 기록 조회
[ ] 가격 높은 도서 TOP 5 조회
[ ] 최근 대여 기록 조회
```

### 4.4 JOIN

매일 아래 중 최소 2개를 직접 작성한다.

```text
[ ] rental + member JOIN
[ ] rental + book JOIN
[ ] book + category JOIN
[ ] rental + member + book JOIN
[ ] rental + member + book + category JOIN
[ ] member LEFT JOIN rental
[ ] category LEFT JOIN book
```

### 4.5 GROUP BY / 집계

매일 아래 중 최소 1개를 직접 작성한다.

```text
[ ] 회원별 대여 횟수
[ ] 회원별 수수료 합계
[ ] 카테고리별 도서 수
[ ] 카테고리별 평균 가격
[ ] 상태별 대여 건수
[ ] 월별 대여 건수
[ ] 인기 도서 TOP 5
```

### 4.6 서브쿼리 / 인덱스

매일 아래 중 최소 1개를 확인한다.

```text
[ ] 평균 가격보다 비싼 도서 서브쿼리
[ ] 특정 카테고리 도서를 빌린 회원 서브쿼리
[ ] JOIN 쿼리를 서브쿼리로 다시 작성
[ ] `CREATE INDEX` 문장 설명
[ ] `EXPLAIN QUERY PLAN` 실행 결과 확인
```

### 4.7 UPDATE / DELETE 안전성

```text
[ ] UPDATE 전에 SELECT로 대상 행을 확인했다.
[ ] DELETE 전에 SELECT로 대상 행을 확인했다.
[ ] WHERE 없는 UPDATE/DELETE를 실행하지 않았다.
[ ] 변경 쿼리가 임시 DB 또는 연습용 DB에서 실행되는지 확인했다.
```

---

## 5. 매일 직접 작성할 SQL 템플릿

### 5.1 기본 조회 템플릿

```sql
-- 목적: ACTIVE 회원만 조회한다.
SELECT member_id, name, email, joined_at, status
FROM member
WHERE status = 'ACTIVE'
ORDER BY joined_at ASC;
```

### 5.2 JOIN 템플릿

```sql
-- 목적: 대여 기록에 회원명과 도서명을 붙여 조회한다.
SELECT r.rental_id, m.name AS member_name, b.title AS book_title, r.rented_at, r.status
FROM rental r
INNER JOIN member m ON r.member_id = m.member_id
INNER JOIN book b ON r.book_id = b.book_id
ORDER BY r.rented_at DESC;
```

### 5.3 LEFT JOIN 템플릿

```sql
-- 목적: 대여 기록이 없는 회원까지 포함해 회원별 대여 횟수를 조회한다.
SELECT m.member_id, m.name, COUNT(r.rental_id) AS rental_count
FROM member m
LEFT JOIN rental r ON m.member_id = r.member_id
GROUP BY m.member_id, m.name
ORDER BY rental_count ASC, m.member_id ASC;
```

### 5.4 GROUP BY 템플릿

```sql
-- 목적: 대여 상태별 건수와 수수료 합계를 조회한다.
SELECT status, COUNT(*) AS rental_count, SUM(rental_fee) AS total_fee
FROM rental
GROUP BY status
ORDER BY rental_count DESC;
```

### 5.5 서브쿼리 템플릿

```sql
-- 목적: 전체 평균 가격보다 비싼 도서를 조회한다.
SELECT book_id, title, price
FROM book
WHERE price > (SELECT AVG(price) FROM book)
ORDER BY price DESC;
```

### 5.6 인덱스 확인 템플릿

```sql
-- 목적: 회원별 반납기한 조회에 사용할 인덱스를 생성하고 실행 계획을 확인한다.
CREATE INDEX IF NOT EXISTS idx_rental_member_due
ON rental(member_id, due_date);

EXPLAIN QUERY PLAN
SELECT rental_id, member_id, book_id, due_date, status
FROM rental
WHERE member_id = 1
ORDER BY due_date ASC;
```

---

## 6. 매일 말로 답변할 평가 질문

아래 질문 중 매일 최소 3개를 골라 말로 답한다.

```text
[ ] 엑셀과 DB는 무엇이 다른가?
[ ] 왜 `member`, `category`, `book`, `rental`로 테이블을 나누었는가?
[ ] PK는 무엇인가?
[ ] FK는 무엇인가?
[ ] `member 1:N rental`은 무슨 뜻인가?
[ ] `category 1:N book`은 무슨 뜻인가?
[ ] INNER JOIN은 언제 쓰는가?
[ ] LEFT JOIN은 언제 쓰는가?
[ ] GROUP BY는 왜 필요한가?
[ ] COUNT, SUM, AVG는 각각 무엇을 계산하는가?
[ ] 서브쿼리는 어디에 사용했는가?
[ ] 인덱스를 왜 `rental(member_id, due_date)`에 만들었는가?
[ ] UPDATE/DELETE를 실행할 때 왜 WHERE가 중요한가?
[ ] 가장 복잡했던 쿼리는 무엇이고 어떻게 풀었는가?
```

---

## 7. 30초 답변 연습 템플릿

### 질문

```text
왜 rental 테이블을 따로 만들었나요?
```

### 답변 구조

```text
1. 한 줄 결론
2. 도메인 예시
3. 테이블 관계 설명
4. FK로 무결성 보장 설명
```

### 예시 답변

> `rental`은 회원과 도서가 만나는 대여 이력 테이블입니다. 회원 정보와 도서 정보를 한 테이블에 모두 넣으면 같은 회원과 책 정보가 반복됩니다. 그래서 회원은 `member`, 책은 `book`, 실제 대여 사건은 `rental`로 분리했습니다. `rental.member_id`와 `rental.book_id`는 각각 회원과 책을 참조하므로 존재하지 않는 회원이나 책의 대여 기록을 만들 수 없습니다.

---

## 8. 오류 기록 체크리스트

오류가 나면 그냥 지나가지 말고 `training-materials/07-error-notes/mistakes-log.md`에 남긴다.

반드시 기록할 항목:

```text
[ ] 실행한 명령
[ ] 발생한 오류 메시지
[ ] 원인 추정
[ ] 해결 방법
[ ] 다음에 조심할 점
```

자주 나오는 오류:

```text
[ ] FOREIGN KEY constraint failed
[ ] UNIQUE constraint failed
[ ] no such table
[ ] near "...": syntax error
[ ] database is locked
[ ] no such column
```

---

## 9. 오늘의 완료 기준

하루 훈련은 아래를 만족하면 완료한다.

```text
[ ] DB를 새로 생성했다.
[ ] 검증 결과를 확인했다.
[ ] 기본 조회 SQL 3개 이상 직접 작성했다.
[ ] JOIN SQL 2개 이상 직접 작성했다.
[ ] GROUP BY 또는 서브쿼리 1개 이상 직접 작성했다.
[ ] 평가 질문 3개 이상 말로 답했다.
[ ] 막힌 점 또는 배운 점을 기록했다.
[ ] 필요하면 커밋했다.
```

---

## 10. 커밋 기준

훈련 자료를 수정했다면 아래 형식으로 커밋한다.

```bash
git status
git add training-materials/
git commit -m "docs: update B5-1 daily training notes"
git push
```

커밋 전 확인:

```text
[ ] 제출용 SQL 파일을 실수로 망가뜨리지 않았는가?
[ ] `book_rental.db` 같은 생성 파일을 커밋하지 않는가?
[ ] 훈련 기록에 개인정보나 토큰이 없는가?
```

---

## 11. 주간 복습 체크리스트

3일 이상 훈련한 뒤 아래를 점검한다.

```text
[ ] SQL 기본 조회를 보지 않고 작성할 수 있다.
[ ] INNER JOIN과 LEFT JOIN을 말로 구분할 수 있다.
[ ] GROUP BY 결과가 왜 그렇게 나오는지 설명할 수 있다.
[ ] FK 오류가 왜 발생하는지 설명할 수 있다.
[ ] 인덱스 사용 이유를 설명할 수 있다.
[ ] ERD를 보며 1:N 관계를 설명할 수 있다.
[ ] 평가 예상 질문 10개에 답할 수 있다.
```

---

## 12. 평가 직전 당일 체크

평가 당일에는 새 내용을 많이 보지 말고 아래만 확인한다.

```text
[ ] SUBMISSION.md를 열어 제출물 위치를 확인한다.
[ ] docs/ERD.md를 열어 관계를 설명한다.
[ ] sql/01_schema.sql에서 PK/FK/제약조건을 찾는다.
[ ] sql/03_queries.sql에서 Q01~Q15를 범주별로 설명한다.
[ ] results/validation_results.txt에서 테이블별 행 수를 보여준다.
[ ] results/query_results.txt에서 Q05, Q08, Q09, Q12, Q15 결과를 보여준다.
[ ] docs/evaluation_answers.md 없이 5개 이상 질문에 답한다.
```

---

## 13. 오늘 기록

아래부터 매일 추가한다.

```md
## 2026-__-__

### 오늘의 목표

- [ ] 

### 실행한 명령

```bash

```

### 작성한 SQL

```sql

```

### 설명 연습 질문

1. 
2. 
3. 

### 막힌 점

- 

### 해결 방법

- 

### 다음 훈련

- 
```
