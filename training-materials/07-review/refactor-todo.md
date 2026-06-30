# B5-1 리팩터링 TODO

이 문서는 B5-1 「SQL로 만드는 나만의 데이터베이스」 프로젝트를 제출 전 또는 평가 후 개선하기 위한 리팩터링 TODO 목록이다.

리팩터링의 목적은 기능을 무리하게 추가하는 것이 아니라, **평가자가 더 쉽게 이해하고**, **실행 재현성이 높고**, **설계 의도가 더 명확하며**, **감점 위험이 적은 저장소**로 정리하는 것이다.

---

## 1. 리팩터링 우선순위 요약

```text
P0: 제출 전 반드시 확인해야 하는 감점 방지 항목
P1: 고득점과 설명 안정성을 위한 권장 보완
P2: 평가 후 확장 학습용 개선
```

| 우선순위 | 목표 | 예시 |
|---|---|---|
| P0 | 실행 오류와 필수 누락 방지 | `run_all.sh` 실행, 결과 파일 최신화, FK/ERD 일치 확인 |
| P1 | 평가 설명 품질 강화 | README 정리, 쿼리 주석 보강, 답변 문서와 SQL 연결 |
| P2 | 실무형 확장 | 재고 계산, 예약 테이블, 감사 로그, 테스트 자동화 |

---

## 2. P0 - 제출 전 필수 TODO

### 2.1 전체 실행 검증

```bash
chmod +x scripts/run_all.sh
./scripts/run_all.sh
```

체크:

```text
[ ] 오류 없이 실행된다.
[ ] 스키마가 새로 생성된다.
[ ] 샘플 데이터가 입력된다.
[ ] 핵심 쿼리가 실행된다.
[ ] UPDATE/DELETE 결과가 확인된다.
[ ] 인덱스와 EXPLAIN QUERY PLAN 결과가 확인된다.
```

보완 이유:

> 실행 검증이 안 되면 SQL 내용이 좋아도 재현성에서 감점될 수 있다.

---

### 2.2 결과 파일 최신화

확인 파일:

```text
results/query_results.md
```

체크:

```text
[ ] 현재 `sql/03_queries.sql` 실행 결과와 일치한다.
[ ] Q01~Q15 결과가 구분되어 있다.
[ ] UPDATE 결과가 보인다.
[ ] DELETE 결과가 보인다.
[ ] EXPLAIN QUERY PLAN 결과가 보인다.
```

보완 이유:

> 결과 파일은 “실제로 실행했다”는 증거다. 쿼리와 결과가 불일치하면 신뢰도가 떨어진다.

---

### 2.3 ERD와 스키마 일치 확인

비교 대상:

```text
docs/ERD.md
sql/01_schema.sql
```

체크:

```text
[ ] ERD에 `member`, `category`, `book`, `rental` 4개 테이블이 모두 있다.
[ ] `book.category_id → category.category_id`가 일치한다.
[ ] `rental.member_id → member.member_id`가 일치한다.
[ ] `rental.book_id → book.book_id`가 일치한다.
[ ] ERD의 컬럼명이 schema.sql과 다르지 않다.
```

보완 이유:

> ERD와 실제 SQL이 다르면 설계 문서 신뢰도가 낮아진다.

---

### 2.4 README 실행 방법 확인

확인 파일:

```text
README.md
```

체크:

```text
[ ] 프로젝트 목적이 한눈에 보인다.
[ ] 실행 명령이 있다.
[ ] 핵심 파일 경로가 있다.
[ ] 평가 요구사항 충족 항목이 보인다.
[ ] `scripts/run_all.sh` 실행 방법이 맞다.
```

보완 이유:

> 평가자는 README를 먼저 본다. README에서 실행 흐름을 바로 이해할 수 있어야 한다.

---

### 2.5 Git 상태 확인

```bash
git status
git log --oneline -5
```

체크:

```text
[ ] 작업 트리가 깨끗하다.
[ ] 변경 사항이 모두 커밋되어 있다.
[ ] 원격 저장소에 push되어 있다.
[ ] 평가자가 GitHub에서 최신 파일을 볼 수 있다.
```

보완 이유:

> 로컬에는 있는데 GitHub에는 없는 파일이 있으면 제출물에서 누락된다.

---

## 3. P1 - 고득점 권장 TODO

### 3.1 SQL 파일 주석 보강

대상:

```text
sql/01_schema.sql
sql/02_seed.sql
sql/03_queries.sql
```

보강 방향:

```text
[ ] 각 테이블 생성 이유를 한 줄 주석으로 설명한다.
[ ] FK 관계 옆에 부모/자식 관계를 주석으로 남긴다.
[ ] Q01~Q15 각 쿼리의 평가 목적을 주석으로 적는다.
[ ] UPDATE/DELETE는 안전 주의 주석을 붙인다.
[ ] 인덱스 Q15는 조회 시나리오를 주석으로 적는다.
```

예:

```sql
-- 특정 회원의 대여 기록을 반납기한 순으로 조회하기 위한 복합 인덱스
CREATE INDEX IF NOT EXISTS idx_rental_member_due
ON rental(member_id, due_date);
```

---

### 3.2 평가 답변과 쿼리 번호 연결

대상:

```text
docs/evaluation_answers.md
training-materials/06-evaluation-qa/expected-questions.md
```

보강 방향:

```text
[ ] “회원별 대여 횟수” 답변에 Q08 또는 Q09를 연결한다.
[ ] “평균 가격보다 비싼 도서” 답변에 Q12를 연결한다.
[ ] “인덱스” 답변에 Q15를 연결한다.
[ ] “UPDATE” 답변에 Q13을 연결한다.
[ ] “DELETE” 답변에 Q14를 연결한다.
```

보완 이유:

> 답변과 실제 SQL 파일 번호가 연결되면 평가자가 빠르게 근거를 확인할 수 있다.

---

### 3.3 실행 결과 가독성 개선

대상:

```text
results/query_results.md
```

보강 방향:

```text
[ ] Q01~Q15 제목이 명확하다.
[ ] 결과 테이블이 너무 길면 핵심만 보이게 한다.
[ ] UPDATE/DELETE는 전후 변화가 보이게 한다.
[ ] EXPLAIN QUERY PLAN 결과에는 짧은 해석을 붙인다.
```

예:

```text
Q15 해석: member_id 조건과 due_date 정렬을 위해 idx_rental_member_due 인덱스 사용 여부를 확인한다.
```

---

### 3.4 ERD 설명 문장 보강

대상:

```text
docs/ERD.md
```

보강 방향:

```text
[ ] 테이블별 역할 설명 추가
[ ] 1:N 관계 설명 추가
[ ] rental이 관계 이력 테이블인 이유 추가
[ ] FK 연결선과 JOIN 조건 연결 설명 추가
```

핵심 문장:

> ERD의 FK 연결선은 실제 JOIN 조건과 같다. `rental.member_id = member.member_id`, `rental.book_id = book.book_id`, `book.category_id = category.category_id`가 핵심 JOIN 조건이다.

---

### 3.5 README에 평가자용 빠른 안내 추가

추가하면 좋은 섹션:

```text
## 평가자용 빠른 확인
1. ERD: docs/ERD.md
2. 스키마: sql/01_schema.sql
3. 샘플 데이터: sql/02_seed.sql
4. 핵심 쿼리: sql/03_queries.sql
5. 실행 결과: results/query_results.md
6. 평가 답변: docs/evaluation_answers.md
```

보완 이유:

> 평가자가 저장소를 탐색하는 시간을 줄여준다.

---

## 4. P2 - 평가 후 확장 TODO

### 4.1 재고 계산 로직 확장

현재는 `book.stock`이 있지만 실제 대여/반납에 따른 자동 재고 계산까지는 학습 범위 밖이다.

확장 아이디어:

```text
[ ] 대여 가능 수량 계산 쿼리 추가
[ ] RENTED/OVERDUE 상태인 대여 수를 stock에서 차감하는 조회 작성
[ ] 반납 처리 시 재고 복구 트랜잭션 설계
```

예상 쿼리 방향:

```sql
SELECT b.book_id,
       b.title,
       b.stock - COUNT(r.rental_id) AS available_stock
FROM book b
LEFT JOIN rental r
    ON b.book_id = r.book_id
   AND r.status IN ('RENTED', 'OVERDUE')
GROUP BY b.book_id, b.title, b.stock;
```

---

### 4.2 예약 기능 추가

신규 테이블 후보:

```text
reservation
```

컬럼 후보:

```text
reservation_id
member_id
book_id
reserved_at
status
cancelled_at
```

관계:

```text
member 1:N reservation
book 1:N reservation
```

평가 후 확장 답변:

> 실제 서비스로 확장한다면 대여 중인 도서에 대해 예약 대기열을 관리하는 `reservation` 테이블을 추가할 수 있습니다.

---

### 4.3 벌금 정책 테이블 추가

현재 `rental_fee`는 rental에 직접 저장된다.

확장 테이블 후보:

```text
fee_policy
```

컬럼 후보:

```text
policy_id
daily_fee
max_fee
effective_from
effective_to
```

확장 이유:

> 벌금 정책이 바뀌면 이력 관리가 필요하므로 별도 정책 테이블로 분리할 수 있다.

---

### 4.4 감사 로그 테이블 추가

신규 테이블 후보:

```text
audit_log
```

컬럼 후보:

```text
log_id
table_name
action
record_id
changed_at
changed_by
memo
```

확장 이유:

> UPDATE/DELETE가 언제, 누구에 의해 발생했는지 추적할 수 있다.

---

### 4.5 테스트 자동화 추가

추가 후보:

```text
tests/
├── test_schema.sql
├── test_seed_counts.sql
└── test_queries.sql
```

검증 항목:

```text
[ ] 테이블 존재 여부
[ ] 샘플 데이터 수
[ ] FK 무결성
[ ] 핵심 쿼리 실행 가능 여부
[ ] 인덱스 존재 여부
```

---

## 5. 감점 방지 리팩터링 TOP 10

```text
[ ] 1. run_all.sh가 오류 없이 실행되도록 한다.
[ ] 2. results/query_results.md를 최신화한다.
[ ] 3. README에 실행 방법과 핵심 파일 경로를 명확히 적는다.
[ ] 4. ERD와 schema.sql의 FK 관계를 일치시킨다.
[ ] 5. sql/03_queries.sql의 Q01~Q15 목적을 주석으로 명확히 한다.
[ ] 6. UPDATE/DELETE 안전 설명을 문서에 포함한다.
[ ] 7. idx_rental_member_due의 목적을 쿼리와 문서에서 일관되게 설명한다.
[ ] 8. evaluation_answers.md와 실제 SQL 번호를 연결한다.
[ ] 9. 최종 30초/1분 답변을 연습한다.
[ ] 10. git status가 깨끗한 상태로 push한다.
```

---

## 6. 리팩터링 우선순위 판단표

| TODO | 지금 해야 함 | 평가 후 가능 | 이유 |
|---|---|---|---|
| 실행 오류 수정 | 예 | 아니오 | 실행 불가 시 큰 감점 |
| 결과 파일 최신화 | 예 | 아니오 | 재현성 근거 |
| README 빠른 안내 | 예 | 가능 | 평가자 탐색 시간 감소 |
| SQL 주석 보강 | 예 | 가능 | 설명력 강화 |
| 예약 테이블 추가 | 아니오 | 예 | 미션 범위 초과 가능 |
| 벌금 정책 테이블 | 아니오 | 예 | 실무 확장 항목 |
| 감사 로그 | 아니오 | 예 | 운영 확장 항목 |
| 테스트 자동화 | 가능 | 예 | 있으면 좋지만 필수는 아님 |
| ERD 수정 | 예 | 아니오 | 실제 스키마와 불일치하면 감점 |
| 발표 스크립트 연습 | 예 | 아니오 | 말하기 평가 방어 |

---

## 7. README 리팩터링 TODO

README에 아래 항목이 있는지 확인한다.

```text
[ ] 프로젝트 제목
[ ] 도메인 설명
[ ] 테이블 요약
[ ] 관계 요약
[ ] 실행 방법
[ ] 핵심 쿼리 목록
[ ] 결과 파일 경로
[ ] ERD 경로
[ ] 평가 답변 경로
```

추천 문장:

> 이 프로젝트는 도서 대여 관리 도메인을 기준으로 관계형 데이터베이스의 테이블 설계, PK/FK/제약조건, 샘플 데이터 입력, 핵심 SQL 쿼리 작성을 실습한 SQLite 프로젝트입니다.

---

## 8. SQL 리팩터링 TODO

### 8.1 스키마 SQL

```text
[ ] DROP TABLE 순서가 안전하다.
[ ] CREATE TABLE 순서가 부모 → 자식이다.
[ ] FK 제약조건이 모두 있다.
[ ] CHECK 제약조건이 명확하다.
[ ] DEFAULT 값이 필요한 컬럼에 있다.
```

### 8.2 샘플 데이터 SQL

```text
[ ] INSERT 순서가 부모 → 자식이다.
[ ] 각 테이블 데이터가 충분하다.
[ ] JOIN 결과가 나오도록 FK가 다양하다.
[ ] OVERDUE, RETURNED, RENTED 등 상태값이 다양하다.
[ ] rental_fee가 0과 양수 모두 있다.
```

### 8.3 쿼리 SQL

```text
[ ] Q01~Q15가 번호순으로 정리되어 있다.
[ ] 각 쿼리 위에 목적 주석이 있다.
[ ] JOIN 조건이 명확하다.
[ ] GROUP BY 컬럼이 명확하다.
[ ] 서브쿼리의 안쪽 쿼리 목적이 보인다.
[ ] UPDATE/DELETE에는 WHERE가 있다.
[ ] 인덱스에는 조회 시나리오가 있다.
```

---

## 9. 문서 리팩터링 TODO

```text
[ ] ERD에 테이블 역할 설명이 있다.
[ ] evaluation_answers.md에 평가 질문 답변이 있다.
[ ] expected-questions.md와 answer-scripts.md를 평가 전 읽는다.
[ ] final-checklist.md로 제출 전 검증한다.
[ ] score-self-review.md로 보수적 점수를 기록한다.
```

---

## 10. 발표 리팩터링 TODO

말하기 답변을 줄이는 연습이 필요하다.

```text
[ ] 15초 답변: 프로젝트 한 문장
[ ] 30초 답변: 테이블/관계/쿼리 요약
[ ] 1분 답변: 설계/쿼리/인덱스 포함
[ ] 2분 답변: 전체 발표
```

금지 표현:

```text
그냥 만들었습니다.
잘 모르겠습니다.
빠르니까 인덱스를 만들었습니다.
JOIN은 그냥 테이블 붙이는 겁니다.
DELETE는 그냥 지우는 겁니다.
```

대체 표현:

```text
이 조회 시나리오를 위해 설계했습니다.
이 프로젝트 범위에서는 이렇게 처리했고, 실제 서비스에서는 이렇게 확장할 수 있습니다.
FK 관계를 기준으로 JOIN 조건을 정했습니다.
인덱스는 특정 회원의 대여 기록을 반납기한 순으로 조회하기 위해 만들었습니다.
```

---

## 11. 리팩터링 완료 기준

```text
[ ] P0 항목을 모두 완료했다.
[ ] P1 항목 중 README, 결과 파일, 평가 답변 연결을 완료했다.
[ ] P2 항목은 평가 후 확장으로 분리했다.
[ ] GitHub에 최신 상태가 push되어 있다.
[ ] 평가자가 README에서 실행 방법을 찾을 수 있다.
[ ] 평가자가 SQL과 결과 파일을 비교할 수 있다.
[ ] 본인이 30초/1분 답변을 말할 수 있다.
```

---

## 12. 최종 판단

평가 전에는 새로운 기능을 무리하게 추가하기보다 아래 세 가지를 우선한다.

```text
1. 실행 검증
2. 문서-코드 일치
3. 말하기 답변 안정화
```

최종 문장:

> 제출 전 리팩터링은 기능 확장이 아니라 감점 방지와 설명력 강화를 목표로 해야 합니다. B5-1에서는 이미 요구사항을 충족하는 구조를 갖춘 뒤, 실행 가능성과 설계 설명을 안정화하는 것이 가장 중요합니다.

---

## 13. 오늘의 완료 기준

```text
[ ] P0 필수 리팩터링 항목을 확인했다.
[ ] P1 권장 리팩터링 항목을 확인했다.
[ ] P2 확장 항목을 평가 후 작업으로 분리했다.
[ ] README 보완 필요 여부를 판단했다.
[ ] 결과 파일 최신화 필요 여부를 판단했다.
[ ] ERD와 schema 일치 여부를 확인했다.
[ ] SQL 주석 보강 필요 여부를 판단했다.
[ ] 발표 스크립트 연습 항목을 확인했다.
```
