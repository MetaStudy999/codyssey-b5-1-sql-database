# B5-1 프로젝트 파일 점검 보고서

이 문서는 B5-1 「SQL로 만드는 나만의 데이터베이스」 제출물의 핵심 파일을 점검한 결과이다.

점검 범위는 다음과 같다.

```text
README.md
sql/01_schema.sql
sql/02_seed.sql
sql/03_queries.sql
sql/04_validation.sql
docs/ERD.md
docs/evaluation_answers.md
results/validation_results.txt
results/query_results.txt
scripts/run_all.sh
TRAINING_INDEX.md
training-materials/README-final-index.md
```

주의:

```text
이 문서는 GitHub에 저장된 파일과 결과 파일을 기준으로 한 정적 점검 및 결과 검증 보고서다.
실제 로컬 터미널 재실행은 제출 직전 `./scripts/run_all.sh`로 별도 수행해야 한다.
```

---

## 1. 종합 판정

```text
판정: 제출 가능 상태
위험도: 낮음
최우선 확인: 제출 직전 run_all.sh 실제 재실행
```

종합 의견:

> 현재 저장소는 B5-1 필수 요구사항을 충족한다. 4개 핵심 테이블, 3개의 1:N 관계, PK/FK/제약조건, 샘플 데이터, 15개 핵심 쿼리, ERD, 실행 결과, 평가 답변, 훈련 자료 인덱스가 모두 존재한다. 제출 직전에는 `./scripts/run_all.sh`를 실제 환경에서 한 번 더 실행하고 `git status`를 확인하면 된다.

---

## 2. 요구사항 충족표

| 항목 | 상태 | 근거 파일 | 판정 |
|---|---|---|---|
| README 프로젝트 설명 | 있음 | `README.md` | 통과 |
| 4개 이상 테이블 | 있음 | `sql/01_schema.sql`, `results/validation_results.txt` | 통과 |
| 1:N 관계 2개 이상 | 3개 있음 | `docs/ERD.md` | 통과 |
| PK | 모든 테이블 있음 | `sql/01_schema.sql` | 통과 |
| FK | 3개 있음 | `sql/01_schema.sql`, `docs/ERD.md` | 통과 |
| NOT NULL/UNIQUE/CHECK | 있음 | `sql/01_schema.sql` | 통과 |
| 샘플 데이터 | member 10, category 10, book 15, rental 20 | `sql/02_seed.sql`, `results/validation_results.txt` | 통과 |
| 기본 SELECT | 있음 | `sql/03_queries.sql`, `results/query_results.txt` | 통과 |
| INNER JOIN | 있음 | `sql/03_queries.sql`, `results/query_results.txt` | 통과 |
| LEFT JOIN | 있음 | `sql/03_queries.sql`, `results/query_results.txt` | 통과 |
| GROUP BY/집계 | 있음 | `sql/03_queries.sql`, `results/query_results.txt` | 통과 |
| 서브쿼리 | 있음 | `sql/03_queries.sql`, `results/query_results.txt` | 통과 |
| UPDATE | 있음 | `sql/03_queries.sql`, `results/query_results.txt` | 통과 |
| DELETE | 있음 | `sql/03_queries.sql`, `results/query_results.txt` | 통과 |
| INDEX/실행 계획 | 있음 | `sql/03_queries.sql`, `results/query_results.txt` | 통과 |
| 실행 스크립트 | 있음 | `scripts/run_all.sh` | 통과 |
| 평가 답변 | 있음 | `docs/evaluation_answers.md`, `training-materials/06-evaluation-qa/` | 통과 |
| 훈련 자료 인덱스 | 있음 | `TRAINING_INDEX.md`, `training-materials/README-final-index.md` | 통과 |

---

## 3. README 점검

확인 내용:

```text
[확인] 프로젝트 주제가 명확하다.
[확인] SQLite 3 사용 이유가 적혀 있다.
[확인] 제출물 구조가 있다.
[확인] 빠른 실행 명령이 있다.
[확인] 수동 실행 명령이 있다.
[확인] 테이블 설계표가 있다.
[확인] 1:N 관계가 있다.
[확인] 제약조건 설명이 있다.
[확인] 핵심 쿼리 15개 표가 있다.
[확인] 인덱스 적용 이유가 있다.
```

보완 판단:

```text
README 자체는 평가자가 프로젝트를 이해하기에 충분하다.
루트에는 별도 TRAINING_INDEX.md도 추가되어 훈련 자료 접근성이 보강되었다.
```

---

## 4. 스키마 점검

확인 대상:

```text
sql/01_schema.sql
```

테이블:

```text
member
category
book
rental
```

PK:

```text
member.member_id
category.category_id
book.book_id
rental.rental_id
```

FK:

```text
book.category_id → category.category_id
rental.member_id → member.member_id
rental.book_id → book.book_id
```

제약조건:

```text
NOT NULL
UNIQUE
CHECK
DEFAULT
ON UPDATE CASCADE
ON DELETE RESTRICT
```

판정:

> 스키마는 B5-1 평가 기준을 충족한다. 테이블 역할과 관계가 명확하고, 데이터 무결성을 설명할 수 있는 제약조건도 충분하다.

---

## 5. 샘플 데이터 점검

확인 대상:

```text
sql/02_seed.sql
```

데이터 수:

```text
member: 10
category: 10
book: 15
rental: 20
```

샘플 데이터 특징:

```text
[확인] 부모 테이블 member/category가 먼저 입력된다.
[확인] book은 category_id를 참조한다.
[확인] rental은 member_id, book_id를 참조한다.
[확인] RENTED, RETURNED, OVERDUE 상태가 모두 있다.
[확인] rental_fee가 0과 양수 모두 있다.
[확인] JOIN, GROUP BY, 서브쿼리 실습에 충분한 데이터가 있다.
```

판정:

> 각 테이블 최소 10행 이상 조건을 충족한다. `book`은 15행, `rental`은 20행으로 집계와 JOIN 결과를 만들기에 충분하다.

---

## 6. 핵심 쿼리 점검

확인 대상:

```text
sql/03_queries.sql
results/query_results.txt
```

Q01~Q15 범위:

```text
Q01 기본 조회: ACTIVE 회원 중 특정 날짜 이후 가입자
Q02 기본 조회: 고가 도서 TOP 5
Q03 LIKE: SQL 제목 검색
Q04 상태 조건: RENTED/OVERDUE 조회
Q05 INNER JOIN: 최근 대여 기록 + 회원명 + 도서명
Q06 INNER JOIN: 도서 + 카테고리
Q07 INNER JOIN: 연체 기록 + 회원/도서/카테고리
Q08 LEFT JOIN: 대여 없는 회원 포함 대여 횟수
Q09 GROUP BY: 회원별 대여 횟수/수수료 합계
Q10 GROUP BY: 카테고리별 도서 수/평균 가격
Q11 GROUP BY: 대여 상태별 건수/수수료 합계
Q12 Subquery: 평균 가격보다 비싼 도서
Q13 UPDATE: 대여 상태 변경
Q14 DELETE: 테스트 대여 기록 삭제
Q15 INDEX: rental(member_id, due_date) 인덱스 및 실행 계획
```

판정:

> 핵심 쿼리 범위는 충분하다. 결과 파일에도 Q01~Q15 결과가 남아 있어 실제 실행 근거가 있다.

주의:

> Q13 UPDATE와 Q14 DELETE는 `run_all.sh`에서 임시 DB 복사본에 실행되므로 원본 `book_rental.db`를 훼손하지 않는 구조다.

---

## 7. ERD 점검

확인 대상:

```text
docs/ERD.md
```

ERD 관계:

```text
MEMBER ||--o{ RENTAL
BOOK ||--o{ RENTAL
CATEGORY ||--o{ BOOK
```

설명 관계:

```text
category 1 : N book
member 1 : N rental
book 1 : N rental
```

판정:

> ERD는 실제 스키마의 FK 구조와 일치한다. 평가에서 관계 설명용 근거로 사용하기 적합하다.

---

## 8. 실행 검증 파일 점검

확인 대상:

```text
sql/04_validation.sql
results/validation_results.txt
```

검증 쿼리 구성:

```text
[확인] 테이블 목록 확인
[확인] 테이블별 행 수 확인
[확인] PRAGMA foreign_key_check
[확인] .schema 출력
```

결과 파일 확인:

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

판정:

> 검증 결과 파일이 존재하고, 테이블 수와 행 수가 요구사항을 충족한다. `PRAGMA foreign_key_check` 구간에 위반 행이 표시되지 않아 FK 무결성도 정상으로 볼 수 있다.

---

## 9. 실행 스크립트 점검

확인 대상:

```text
scripts/run_all.sh
```

동작 흐름:

```text
1. 필수 파일 존재 확인
2. results 폴더 생성
3. 기존 book_rental.db 삭제
4. schema 실행
5. seed 실행
6. validation 실행 후 results/validation_results.txt 저장
7. bonus 실행 후 results/bonus_results.txt 저장
8. 임시 DB 복사본 생성
9. 15개 핵심 쿼리 실행 후 results/query_results.txt 저장
```

안전성:

```text
[확인] set -euo pipefail 사용
[확인] sqlite3 -bail 사용
[확인] Q13/Q14 변형 쿼리는 임시 DB 복사본에서 실행
[확인] sqlite3 CLI가 없으면 Python fallback 사용
```

판정:

> 실행 스크립트 구조가 안정적이다. 특히 UPDATE/DELETE가 원본 DB가 아니라 임시 DB에서 실행되는 점이 좋다.

---

## 10. 평가 답변 문서 점검

확인 대상:

```text
docs/evaluation_answers.md
training-materials/06-evaluation-qa/expected-questions.md
training-materials/06-evaluation-qa/answer-scripts.md
training-materials/06-evaluation-qa/final-checklist.md
```

확인 내용:

```text
[확인] 테이블을 나눈 이유 설명
[확인] PK/FK와 1:N 관계 설명
[확인] SQLite 타입 선택 이유 설명
[확인] INNER JOIN/LEFT JOIN 차이 설명
[확인] GROUP BY/집계 함수 설명
[확인] 인덱스 선택 이유 설명
[확인] 복잡한 JOIN 쿼리 설명 예시
```

판정:

> 평가 말하기 대비 자료가 충분하다. `docs/evaluation_answers.md`는 짧은 제출용 답변이고, `training-materials/06-evaluation-qa/`는 실제 말하기 훈련용 자료로 구분된다.

---

## 11. 발견된 보완 후보

필수 보완은 아니다. 고득점 안정화를 위한 후보이다.

```text
[권장] README.md 본문에서 TRAINING_INDEX.md 또는 training-materials/README-final-index.md를 직접 링크하면 더 좋다.
[권장] results/query_results.txt의 Q15 실행 계획 아래에 한 줄 해석을 추가하면 더 좋다.
[권장] docs/evaluation_answers.md에서 Q 번호와 답변을 조금 더 직접 연결하면 더 좋다.
[선택] results 파일이 .txt이므로 README에서 정확히 .txt 경로를 유지한다.
```

주의:

> README 직접 수정은 이전 시도에서 도구 안전 검사로 차단되었으므로, 현재는 루트의 `TRAINING_INDEX.md`로 보완했다.

---

## 12. 제출 전 최종 명령

실제 제출 전 로컬에서 아래 명령을 수행한다.

```bash
# 프로젝트 루트 확인
pwd

# 구조 확인
tree -L 3

# 전체 실행
chmod +x scripts/run_all.sh
./scripts/run_all.sh

# 최종 복습 SQL 실행
sqlite3 book_rental.db < training-materials/07-review/review-practice.sql

# Git 상태 확인
git status
git log --oneline -5
```

---

## 13. 최종 판정 문장

> 현재 저장소는 B5-1 필수 평가 요건을 충족한다. 스키마, 샘플 데이터, 핵심 쿼리, 실행 결과, ERD, 평가 답변, 훈련 자료가 모두 준비되어 있다. 제출 전에는 `./scripts/run_all.sh`를 실제 로컬 환경에서 한 번 더 실행하고, 30초/1분 답변을 말로 연습하면 된다.

---

## 14. 오늘의 완료 기준

```text
[ ] README 구조를 확인했다.
[ ] schema.sql의 테이블/PK/FK/제약조건을 확인했다.
[ ] seed.sql의 샘플 데이터 수와 다양성을 확인했다.
[ ] queries.sql와 query_results.txt의 Q01~Q15 실행 결과를 확인했다.
[ ] ERD와 schema의 관계 일치를 확인했다.
[ ] validation 결과를 확인했다.
[ ] run_all.sh의 실행 흐름과 안전성을 확인했다.
[ ] evaluation_answers.md의 평가 답변 범위를 확인했다.
[ ] 제출 전 로컬 실행 명령을 정리했다.
```
