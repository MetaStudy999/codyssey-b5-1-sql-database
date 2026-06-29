# B5-1. SQL로 만드는 나만의 데이터베이스

## 프로젝트 주제

**도서 대여 관리 데이터베이스**

회원, 카테고리, 도서, 대여 기록을 분리하여 관계형 데이터베이스의 PK/FK, 1:N 관계, JOIN, GROUP BY, 서브쿼리, UPDATE/DELETE, INDEX를 실습한다.

## 사용 DB

- SQLite 3
- 선택 이유: 파일 기반 DB라 서버 실행이 필요 없고, 입문자가 로컬에서 재현하기 쉽다.
- 백엔드 프레임워크: 사용하지 않음

## 제출물 구성

```text
b5-1-book-rental-db/
├── README.md
├── SUBMISSION.md
├── sql/
│   ├── 01_schema.sql
│   ├── 02_seed.sql
│   ├── 03_queries.sql
│   └── 04_validation.sql
├── docs/
│   ├── ERD.md
│   ├── bonus.sql
│   ├── mini_report.md
│   └── evaluation_answers.md
├── results/
│   ├── validation_results.txt
│   ├── query_results.txt
│   └── bonus_results.txt
└── scripts/
    ├── run_all.sh
    └── run_all.py
```

## 빠른 실행

```bash
chmod +x scripts/run_all.sh
./scripts/run_all.sh
```

실행 후 다음 파일을 확인한다.

```bash
cat results/validation_results.txt
cat results/query_results.txt
cat results/bonus_results.txt
```

## 수동 실행

```bash
rm -f book_rental.db
sqlite3 book_rental.db < sql/01_schema.sql
sqlite3 book_rental.db < sql/02_seed.sql
sqlite3 book_rental.db < sql/04_validation.sql | tee results/validation_results.txt
sqlite3 book_rental.db < docs/bonus.sql | tee results/bonus_results.txt
sqlite3 book_rental.db < sql/03_queries.sql | tee results/query_results.txt
```

## 테이블 설계

| 테이블 | 역할 | PK | 주요 FK |
|---|---|---|---|
| `member` | 도서관 회원 | `member_id` | 없음 |
| `category` | 도서 카테고리 | `category_id` | 없음 |
| `book` | 도서 정보 | `book_id` | `category_id → category.category_id` |
| `rental` | 대여 이력 | `rental_id` | `member_id → member.member_id`, `book_id → book.book_id` |

## 1:N 관계

1. `category 1 : N book`
2. `member 1 : N rental`
3. `book 1 : N rental`

## 제약조건

- PK: 모든 테이블에 존재
- FK: `book.category_id`, `rental.member_id`, `rental.book_id`
- NOT NULL: `name`, `email`, `title`, `rented_at` 등
- UNIQUE: `member.email`, `category.name`, `book.isbn`
- CHECK: `status`, `price`, `stock`, `published_year`, `rental_fee`

## 핵심 쿼리 15개

| 번호 | 범주 | 내용 |
|---|---|---|
| Q01 | 기본 조회 | ACTIVE 회원 중 특정 날짜 이후 가입자 조회 |
| Q02 | 기본 조회 | 고가 도서 가격순 TOP 5 |
| Q03 | 기본 조회 | SQL 제목 검색 |
| Q04 | 기본 조회 | 대여 중/연체 기록 조회 |
| Q05 | INNER JOIN | 최근 대여 기록 + 회원명 + 도서명 |
| Q06 | INNER JOIN | 도서 + 카테고리 연결 조회 |
| Q07 | INNER JOIN | 연체 기록 + 회원/도서/카테고리 조회 |
| Q08 | LEFT JOIN | 대여 없는 회원 포함 대여 횟수 조회 |
| Q09 | 집계 | 회원별 대여 횟수/수수료 합계 |
| Q10 | 집계 | 카테고리별 도서 수/평균 가격 |
| Q11 | 집계 | 대여 상태별 건수/수수료 합계 |
| Q12 | 서브쿼리 | 평균 가격보다 비싼 도서 |
| Q13 | UPDATE | 대여 상태를 OVERDUE로 변경 |
| Q14 | DELETE | 테스트 대여 기록 삭제 |
| Q15 | INDEX | `rental(member_id, due_date)` 인덱스 생성 |

## 인덱스 적용 이유

`rental(member_id, due_date)` 인덱스는 특정 회원의 대여 기록을 반납기한 순으로 확인하는 조회에 적합하다.

```sql
CREATE INDEX IF NOT EXISTS idx_rental_member_due
ON rental(member_id, due_date);
```

## 평가 대비 설명

`docs/evaluation_answers.md`를 보고 평가자 앞에서 설명을 연습한다.

## 보너스

- `docs/bonus.sql`: JOIN과 서브쿼리로 같은 요구 해결, FK 오류 데모, 핵심 지표 3개 쿼리
- `docs/mini_report.md`: 미니 리포트 지표 정의와 활용 설명
- `results/bonus_results.txt`: 보너스 쿼리 실행 결과

## ERD

`docs/ERD.md`에 Mermaid ERD가 있다. GitHub에서 열면 다이어그램으로 표시된다.
