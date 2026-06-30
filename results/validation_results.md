# Validation Results 해설

한 줄 요약: 데이터베이스에 필요한 테이블 4개가 만들어졌고, 샘플 데이터와 제약조건이 정상적으로 준비되었는지 확인한 결과입니다.

## 실습 따라하기

1. 프로젝트 루트에서 전체 실행 스크립트를 실행합니다.

```bash
bash scripts/run_all.sh
```

2. 검증 결과만 직접 보고 싶다면 아래 명령을 실행합니다.

```bash
sqlite3 book_rental.db < sql/04_validation.sql
```

3. 결과 파일은 `results/validation_results.txt`에 저장되고, 이 문서는 그 결과를 입문자도 읽기 쉽게 풀어 쓴 해설입니다.

## 핵심 키워드

- `sqlite_master`: SQLite가 테이블 정보를 저장하는 내부 목록
- `COUNT(*)`: 행 개수를 세는 집계 함수
- `UNION ALL`: 여러 조회 결과를 세로로 이어 붙이는 문법
- `PRAGMA foreign_key_check`: 외래키 참조가 깨진 데이터가 있는지 확인하는 명령
- `.schema`: 테이블 생성 SQL을 다시 확인하는 SQLite CLI 명령
- `PRIMARY KEY`: 각 행을 구분하는 대표 식별자
- `FOREIGN KEY`: 다른 테이블의 기본키를 참조하는 연결 규칙
- `CHECK`: 컬럼 값이 정해진 조건을 만족하도록 제한하는 제약조건

## 1. Table list

### 원본 결과

```text
1) Table list
table_name
----------
book
category
member
rental
```

### 쉬운 설명

이 부분은 데이터베이스 안에 과제에서 요구한 테이블이 실제로 생성되었는지 확인합니다. 결과에 `book`, `category`, `member`, `rental` 네 개가 모두 보이므로 기본 구조가 정상적으로 만들어졌다고 볼 수 있습니다.

테이블 역할은 다음과 같습니다.

- `member`: 도서관 회원 정보
- `category`: 도서 분류 정보
- `book`: 도서 정보
- `rental`: 어떤 회원이 어떤 책을 빌렸는지 기록하는 대여 정보

### 평가 포인트

평가자는 이 결과를 보고 "스키마 생성이 성공했는가?"를 빠르게 확인할 수 있습니다. 네 테이블 중 하나라도 없으면 이후 JOIN, 집계, 외래키 검증이 제대로 동작하기 어렵습니다.

### 실습 따라하기

SQLite에서 직접 테이블 목록을 확인하려면 아래처럼 실행합니다.

```sql
SELECT name AS table_name
FROM sqlite_master
WHERE type = 'table'
ORDER BY name;
```

### 핵심 키워드

`sqlite_master`, `table`, `스키마 생성 확인`, `테이블 목록`

## 2. Row counts

### 원본 결과

```text
2) Row counts: every table should have at least 10 rows after seeding.
table_name  row_count
----------  ---------
member      10
category    10
book        15
rental      20
```

### 쉬운 설명

이 부분은 샘플 데이터가 충분히 들어갔는지 확인합니다. `member`는 10명, `category`는 10개, `book`은 15권, `rental`은 20건이 들어 있습니다.

데이터가 충분해야 기본 조회, JOIN, GROUP BY, 서브쿼리 같은 SQL 기능을 실제 상황처럼 테스트할 수 있습니다. 예를 들어 대여 기록이 1건뿐이면 "회원별 대여 횟수"나 "가장 많이 대여된 책" 같은 결과가 의미 있게 나오기 어렵습니다.

### 평가 포인트

모든 테이블에 샘플 데이터가 들어갔고, 특히 `rental`에 20건이 있어 대여 상태별 집계와 연체 리포트를 검증할 수 있습니다.

### 실습 따라하기

각 테이블의 행 개수를 직접 세어 보려면 아래 쿼리를 실행합니다.

```sql
SELECT 'member' AS table_name, COUNT(*) AS row_count FROM member
UNION ALL
SELECT 'category', COUNT(*) FROM category
UNION ALL
SELECT 'book', COUNT(*) FROM book
UNION ALL
SELECT 'rental', COUNT(*) FROM rental;
```

### 핵심 키워드

`COUNT(*)`, `UNION ALL`, `seed data`, `행 개수 검증`

## 3. Foreign key integrity check

### 원본 결과

```text
3) Foreign key integrity check: no rows means OK.
```

### 쉬운 설명

이 검사는 외래키가 깨진 데이터가 있는지 확인합니다. 외래키가 깨졌다는 것은 예를 들어 `rental.member_id`에는 999번 회원이 적혀 있는데, 정작 `member` 테이블에는 999번 회원이 없는 상황을 말합니다.

원본 결과에서 이 제목 아래에 추가 행이 나오지 않았습니다. `PRAGMA foreign_key_check`는 문제가 없으면 아무 행도 출력하지 않습니다. 따라서 현재 데이터는 회원, 도서, 카테고리 간 참조 관계가 정상입니다.

### 평가 포인트

"결과가 비어 있음"이 실패가 아니라 성공입니다. 입문자는 빈 결과를 보고 당황할 수 있지만, 이 검사에서는 빈 결과가 외래키 문제가 없다는 뜻입니다.

### 실습 따라하기

외래키 검사를 직접 실행하려면 아래 명령을 사용합니다.

```sql
PRAGMA foreign_key_check;
```

결과가 아무것도 나오지 않으면 정상입니다.

### 핵심 키워드

`PRAGMA foreign_key_check`, `외래키`, `참조 무결성`, `빈 결과는 정상`

## 4. Schema overview

### 원본 결과

```text
4) Schema overview
CREATE TABLE member (
    member_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    phone TEXT,
    joined_at TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'ACTIVE'
        CHECK (status IN ('ACTIVE', 'SUSPENDED', 'WITHDRAWN'))
);
CREATE TABLE category (
    category_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    description TEXT
);
CREATE TABLE book (
    book_id INTEGER PRIMARY KEY,
    category_id INTEGER NOT NULL,
    title TEXT NOT NULL,
    author TEXT NOT NULL,
    published_year INTEGER CHECK (published_year BETWEEN 1900 AND 2100),
    isbn TEXT NOT NULL UNIQUE,
    price INTEGER NOT NULL CHECK (price >= 0),
    stock INTEGER NOT NULL DEFAULT 1 CHECK (stock >= 0),
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES category(category_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);
CREATE TABLE rental (
    rental_id INTEGER PRIMARY KEY,
    member_id INTEGER NOT NULL,
    book_id INTEGER NOT NULL,
    rented_at TEXT NOT NULL,
    due_date TEXT NOT NULL,
    returned_at TEXT,
    status TEXT NOT NULL DEFAULT 'RENTED'
        CHECK (status IN ('RENTED', 'RETURNED', 'OVERDUE', 'LOST')),
    rental_fee INTEGER NOT NULL DEFAULT 0 CHECK (rental_fee >= 0),
    FOREIGN KEY (member_id) REFERENCES member(member_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    FOREIGN KEY (book_id) REFERENCES book(book_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);
```

### 쉬운 설명

이 부분은 각 테이블이 어떤 컬럼과 규칙으로 만들어졌는지 보여 줍니다. 단순히 데이터만 넣은 것이 아니라, 잘못된 데이터가 들어오지 않도록 여러 제약조건을 함께 설정했습니다.

`member` 테이블에서는 `email`에 `UNIQUE`가 있으므로 같은 이메일을 가진 회원을 중복 등록할 수 없습니다. `status`는 `ACTIVE`, `SUSPENDED`, `WITHDRAWN` 중 하나만 허용됩니다.

`category` 테이블에서는 카테고리 이름이 중복되지 않도록 `UNIQUE`가 설정되어 있습니다.

`book` 테이블은 `category_id`로 `category`를 참조합니다. 가격은 0 이상이어야 하고, 출판 연도는 1900년부터 2100년 사이로 제한됩니다.

`rental` 테이블은 `member_id`로 회원을, `book_id`로 도서를 참조합니다. 즉 대여 기록은 반드시 존재하는 회원과 존재하는 책에 연결되어야 합니다.

### 평가 포인트

이 스키마는 단순한 테이블 생성뿐 아니라 데이터 품질을 지키는 규칙까지 포함합니다. 특히 `FOREIGN KEY`, `CHECK`, `UNIQUE`, `NOT NULL`이 함께 사용되어 과제의 데이터베이스 설계 요구를 충족합니다.

### 실습 따라하기

SQLite CLI에서 스키마를 직접 확인하려면 아래 명령을 실행합니다.

```sql
.schema member
.schema category
.schema book
.schema rental
```

또는 전체 스키마를 한 번에 보고 싶다면 다음 명령도 사용할 수 있습니다.

```bash
sqlite3 book_rental.db ".schema"
```

### 핵심 키워드

`CREATE TABLE`, `PRIMARY KEY`, `FOREIGN KEY`, `CHECK`, `UNIQUE`, `NOT NULL`
