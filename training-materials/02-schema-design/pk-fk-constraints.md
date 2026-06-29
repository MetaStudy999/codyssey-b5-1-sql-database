# PK / FK / 제약조건 훈련 노트

이 문서는 B5-1 도서 대여 관리 DB의 PK, FK, `NOT NULL`, `UNIQUE`, `CHECK`, `FOREIGN KEY` 제약조건을 평가자 앞에서 설명하기 위한 훈련 문서이다.

평가에서는 “PK/FK가 무엇인가요?”라는 정의형 질문뿐 아니라, **내 스키마에서 어디에 적용했는지**, **왜 그 컬럼이어야 하는지**, **없는 값 참조가 실제로 막히는지**를 설명할 수 있어야 한다.

---

## 1. 한 줄 요약

```text
PK는 한 테이블 안에서 각 행을 유일하게 구분하는 값이다.
FK는 다른 테이블의 PK를 참조해 테이블 사이의 관계를 만드는 값이다.
제약조건은 잘못된 데이터가 들어오는 것을 DB 차원에서 막는 규칙이다.
```

평가 답변:

> PK는 각 행을 유일하게 식별하는 값이고, FK는 다른 테이블의 PK를 참조해 관계를 만드는 값입니다. 제약조건은 NULL, 중복, 잘못된 상태값, 없는 부모 참조 같은 오류를 DB가 직접 막게 하는 안전장치입니다.

---

## 2. 이 프로젝트의 PK 목록

| 테이블 | PK | 역할 |
|---|---|---|
| `member` | `member_id` | 회원 한 명을 유일하게 식별 |
| `category` | `category_id` | 카테고리 하나를 유일하게 식별 |
| `book` | `book_id` | 도서 한 권을 유일하게 식별 |
| `rental` | `rental_id` | 대여 기록 하나를 유일하게 식별 |

스키마 예시:

```sql
CREATE TABLE member (
    member_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    phone TEXT,
    joined_at TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'ACTIVE'
        CHECK (status IN ('ACTIVE', 'SUSPENDED', 'WITHDRAWN'))
);
```

평가 답변:

> `member_id`, `category_id`, `book_id`, `rental_id`는 각 테이블의 행을 유일하게 구분하기 위한 PK입니다. 이름이 같은 회원이나 제목이 같은 책이 있을 수 있으므로 사람이 읽는 값 대신 ID를 PK로 사용했습니다.

---

## 3. 이 프로젝트의 FK 목록

| 자식 테이블 | FK 컬럼 | 부모 테이블 | 부모 PK | 의미 |
|---|---|---|---|---|
| `book` | `category_id` | `category` | `category_id` | 이 도서가 속한 카테고리 |
| `rental` | `member_id` | `member` | `member_id` | 이 대여 기록의 회원 |
| `rental` | `book_id` | `book` | `book_id` | 이 대여 기록의 도서 |

스키마 예시:

```sql
FOREIGN KEY (category_id) REFERENCES category(category_id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
```

```sql
FOREIGN KEY (member_id) REFERENCES member(member_id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
FOREIGN KEY (book_id) REFERENCES book(book_id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
```

평가 답변:

> 이 프로젝트에는 FK가 3개 있습니다. `book.category_id`는 카테고리를 참조하고, `rental.member_id`는 회원을 참조하며, `rental.book_id`는 도서를 참조합니다. 이 FK 덕분에 존재하지 않는 회원이나 도서를 대여 기록에 넣을 수 없습니다.

---

## 4. PK가 필요한 이유

### 4.1 같은 이름의 회원이 있을 수 있다

회원 이름은 중복될 수 있다.

```text
김민준
김민준
```

따라서 이름만으로는 회원을 정확히 구분할 수 없다.

해결:

```text
member_id = 1, name = 김민준
member_id = 11, name = 김민준
```

평가 답변:

> 이름, 제목, 카테고리명 같은 값은 사람이 읽기에는 좋지만 항상 유일하다고 보장하기 어렵습니다. 그래서 각 행을 안정적으로 구분하기 위해 숫자 ID를 PK로 사용했습니다.

---

### 4.2 JOIN 기준이 명확해진다

PK가 있으면 다른 테이블에서 참조하기 쉽다.

```sql
SELECT r.rental_id, m.name, b.title
FROM rental r
INNER JOIN member m ON r.member_id = m.member_id
INNER JOIN book b ON r.book_id = b.book_id;
```

설명:

> `rental.member_id`와 `member.member_id`가 같은 행을 연결하고, `rental.book_id`와 `book.book_id`가 같은 행을 연결한다.

---

## 5. FK가 필요한 이유

### 5.1 잘못된 참조를 막는다

잘못된 예:

```sql
-- member_id=999가 member 테이블에 없다면 실패해야 한다.
INSERT INTO rental (rental_id, member_id, book_id, rented_at, due_date, status, rental_fee)
VALUES (999, 999, 1, '2024-08-01', '2024-08-15', 'RENTED', 0);
```

예상 오류:

```text
FOREIGN KEY constraint failed
```

평가 답변:

> FK가 없으면 존재하지 않는 회원 ID로도 대여 기록이 들어갈 수 있습니다. 그러면 누가 빌렸는지 알 수 없는 잘못된 데이터가 생깁니다. FK는 이런 잘못된 참조를 DB가 막아주는 장치입니다.

---

### 5.2 관계를 명확하게 표현한다

FK는 테이블 사이의 실제 관계를 코드로 표현한다.

```text
category 1 : N book
member   1 : N rental
book     1 : N rental
```

평가 답변:

> FK는 단순히 오류를 막는 것뿐 아니라 도메인 관계를 표현합니다. 이 DB에서는 카테고리와 도서, 회원과 대여 기록, 도서와 대여 기록의 1:N 관계가 FK로 표현됩니다.

---

## 6. NOT NULL

`NOT NULL`은 반드시 값이 있어야 하는 컬럼에 적용한다.

이 프로젝트의 예:

| 테이블 | 컬럼 | 이유 |
|---|---|---|
| `member` | `name` | 회원 이름은 필수 |
| `member` | `email` | 회원 연락 식별 정보 |
| `member` | `joined_at` | 가입일은 필수 |
| `book` | `title` | 도서 제목은 필수 |
| `book` | `author` | 저자는 필수 |
| `rental` | `rented_at` | 대여일은 필수 |
| `rental` | `due_date` | 반납기한은 필수 |
| `rental` | `status` | 대여 상태는 필수 |

예시:

```sql
name TEXT NOT NULL,
email TEXT NOT NULL UNIQUE,
rented_at TEXT NOT NULL,
due_date TEXT NOT NULL
```

평가 답변:

> `NOT NULL`은 반드시 있어야 하는 값에 적용합니다. 예를 들어 대여 기록에 대여일이나 반납기한이 없으면 대여 이력으로 의미가 약해지므로 `NOT NULL`로 제한했습니다.

---

## 7. UNIQUE

`UNIQUE`는 중복되면 안 되는 컬럼에 적용한다.

이 프로젝트의 예:

| 테이블 | 컬럼 | 이유 |
|---|---|---|
| `member` | `email` | 같은 이메일을 가진 회원 중복 방지 |
| `category` | `name` | 같은 카테고리명 중복 방지 |
| `book` | `isbn` | 같은 ISBN 도서 중복 방지 |

예시:

```sql
email TEXT NOT NULL UNIQUE,
name TEXT NOT NULL UNIQUE,
isbn TEXT NOT NULL UNIQUE
```

중복 이메일 예시:

```sql
-- 이미 minjun.kim@example.com이 있으면 실패한다.
INSERT INTO member (member_id, name, email, phone, joined_at, status)
VALUES (102, '중복회원', 'minjun.kim@example.com', '010-2222-3333', '2024-08-10', 'ACTIVE');
```

예상 오류:

```text
UNIQUE constraint failed: member.email
```

평가 답변:

> UNIQUE는 중복되면 안 되는 값을 막습니다. 이메일, 카테고리명, ISBN은 같은 값이 중복되면 데이터 품질이 떨어지므로 UNIQUE를 적용했습니다.

---

## 8. CHECK

`CHECK`는 값의 허용 범위나 목록을 제한한다.

이 프로젝트의 예:

| 테이블 | 컬럼 | CHECK 조건 | 이유 |
|---|---|---|---|
| `member` | `status` | `ACTIVE`, `SUSPENDED`, `WITHDRAWN` 중 하나 | 허용 상태 제한 |
| `book` | `published_year` | 1900~2100 | 비현실적인 출판년도 방지 |
| `book` | `price` | 0 이상 | 음수 가격 방지 |
| `book` | `stock` | 0 이상 | 음수 재고 방지 |
| `rental` | `status` | `RENTED`, `RETURNED`, `OVERDUE`, `LOST` 중 하나 | 대여 상태 제한 |
| `rental` | `rental_fee` | 0 이상 | 음수 수수료 방지 |

예시:

```sql
status TEXT NOT NULL DEFAULT 'ACTIVE'
    CHECK (status IN ('ACTIVE', 'SUSPENDED', 'WITHDRAWN'))
```

```sql
price INTEGER NOT NULL CHECK (price >= 0),
stock INTEGER NOT NULL DEFAULT 1 CHECK (stock >= 0)
```

잘못된 상태 예시:

```sql
-- WAITING은 허용 목록에 없으므로 실패한다.
INSERT INTO member (member_id, name, email, phone, joined_at, status)
VALUES (103, '상태오류회원', 'bad.status@example.com', '010-3333-4444', '2024-08-10', 'WAITING');
```

예상 오류:

```text
CHECK constraint failed
```

평가 답변:

> CHECK는 컬럼에 들어올 수 있는 값을 제한합니다. 예를 들어 회원 상태는 정해진 값만 허용하고, 가격과 재고는 음수가 되지 않게 막았습니다.

---

## 9. ON UPDATE CASCADE

`ON UPDATE CASCADE`는 부모 테이블의 PK가 변경될 때 자식 테이블의 FK도 함께 변경되도록 하는 설정이다.

이 프로젝트에서는 아래처럼 설정했다.

```sql
FOREIGN KEY (member_id) REFERENCES member(member_id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
```

평가 답변:

> `ON UPDATE CASCADE`는 부모 키가 변경될 때 자식 테이블의 참조값도 함께 바뀌도록 하는 설정입니다. 실제 운영에서는 PK를 자주 바꾸지 않지만, 관계 무결성을 유지하기 위한 설정입니다.

---

## 10. ON DELETE RESTRICT

`ON DELETE RESTRICT`는 자식 테이블에서 참조 중인 부모 데이터를 삭제하지 못하게 막는다.

예시:

```sql
-- member_id=1을 참조하는 rental 기록이 있으면 삭제가 막힌다.
DELETE FROM member
WHERE member_id = 1;
```

예상 오류:

```text
FOREIGN KEY constraint failed
```

평가 답변:

> `ON DELETE RESTRICT`는 참조 중인 부모 데이터 삭제를 막습니다. 예를 들어 대여 기록이 있는 회원을 바로 삭제하면 대여 기록이 고아 데이터가 되므로 이를 막기 위해 사용했습니다.

---

## 11. FK 동작 확인 방법

SQLite에서는 FK 검사를 켜야 한다.

```sql
PRAGMA foreign_keys = ON;
```

전체 FK 무결성 확인:

```sql
PRAGMA foreign_key_check;
```

결과 해석:

```text
아무 행도 나오지 않으면 FK 위반이 없다는 뜻이다.
```

평가 답변:

> SQLite에서는 `PRAGMA foreign_keys = ON`으로 FK 검사를 활성화합니다. 그리고 `PRAGMA foreign_key_check`를 실행했을 때 결과가 없으면 FK 위반이 없다는 뜻입니다.

---

## 12. 실제 스키마에서 찾기

평가 전에는 아래 파일을 열고 직접 찾는다.

```text
sql/01_schema.sql
```

찾을 항목:

```text
[ ] member_id INTEGER PRIMARY KEY
[ ] category_id INTEGER PRIMARY KEY
[ ] book_id INTEGER PRIMARY KEY
[ ] rental_id INTEGER PRIMARY KEY
[ ] email TEXT NOT NULL UNIQUE
[ ] name TEXT NOT NULL UNIQUE
[ ] isbn TEXT NOT NULL UNIQUE
[ ] CHECK (status IN (...))
[ ] CHECK (price >= 0)
[ ] CHECK (stock >= 0)
[ ] FOREIGN KEY (category_id) REFERENCES category(category_id)
[ ] FOREIGN KEY (member_id) REFERENCES member(member_id)
[ ] FOREIGN KEY (book_id) REFERENCES book(book_id)
```

---

## 13. 제약조건별 오류 예시 정리

| 오류 상황 | 발생 제약조건 | 의미 |
|---|---|---|
| 없는 `member_id`로 `rental` 추가 | FK | 존재하지 않는 회원 참조 차단 |
| 중복 이메일 추가 | UNIQUE | 같은 이메일 회원 중복 차단 |
| 상태값 `WAITING` 입력 | CHECK | 허용되지 않은 상태값 차단 |
| 가격 `-1000` 입력 | CHECK | 음수 가격 차단 |
| `name` 없이 회원 추가 | NOT NULL | 필수값 누락 차단 |

---

## 14. 평가 예상 질문과 답변

### 질문 1. PK는 무엇인가요?

> PK는 Primary Key로, 테이블 안에서 각 행을 유일하게 식별하는 값입니다. 이 프로젝트에서는 `member_id`, `category_id`, `book_id`, `rental_id`가 각 테이블의 PK입니다.

### 질문 2. FK는 무엇인가요?

> FK는 Foreign Key로, 다른 테이블의 PK를 참조해 관계를 만드는 값입니다. 예를 들어 `rental.member_id`는 `member.member_id`를 참조해서 대여 기록이 실제 회원과 연결되도록 합니다.

### 질문 3. FK가 실제로 동작한다는 증거는 무엇인가요?

> 없는 회원 ID로 대여 기록을 INSERT하면 `FOREIGN KEY constraint failed`가 발생합니다. 또한 `PRAGMA foreign_key_check` 결과에 아무 행도 없으면 현재 데이터에 FK 위반이 없다는 뜻입니다.

### 질문 4. UNIQUE는 왜 사용했나요?

> 이메일, 카테고리명, ISBN처럼 중복되면 안 되는 값에 UNIQUE를 적용했습니다. 같은 이메일을 가진 회원이나 같은 ISBN을 가진 책이 중복 저장되는 것을 막기 위해서입니다.

### 질문 5. CHECK는 왜 사용했나요?

> CHECK는 허용되는 값의 범위나 목록을 제한하기 위해 사용했습니다. 예를 들어 회원 상태는 `ACTIVE`, `SUSPENDED`, `WITHDRAWN`만 허용하고, 가격과 재고는 0 이상이어야 합니다.

### 질문 6. ON DELETE RESTRICT는 왜 사용했나요?

> 대여 기록에서 참조 중인 회원이나 도서를 삭제하면 대여 기록이 누구 또는 어떤 책에 대한 기록인지 알 수 없게 됩니다. 그래서 참조 중인 부모 데이터를 삭제하지 못하도록 `ON DELETE RESTRICT`를 사용했습니다.

---

## 15. 30초 답변 연습

### 주제: PK/FK 설명

> PK는 테이블 안에서 행을 유일하게 구분하는 값이고, FK는 다른 테이블의 PK를 참조해 관계를 만드는 값입니다. 이 프로젝트에서는 `member_id`, `book_id`, `category_id`, `rental_id`가 PK이고, `rental.member_id`, `rental.book_id`, `book.category_id`가 FK입니다. FK 덕분에 존재하지 않는 회원이나 책을 대여 기록에 넣을 수 없어서 데이터 무결성이 유지됩니다.

### 주제: 제약조건 설명

> 제약조건은 잘못된 데이터가 들어오는 것을 DB가 막는 규칙입니다. `NOT NULL`은 필수값 누락을 막고, `UNIQUE`는 이메일이나 ISBN 중복을 막고, `CHECK`는 상태값이나 가격 범위를 제한합니다. FK는 다른 테이블에 실제로 존재하는 값만 참조하게 만들어 관계 무결성을 보장합니다.

---

## 16. 직접 설명 연습 체크리스트

```text
[ ] PK 4개를 말할 수 있다.
[ ] FK 3개를 말할 수 있다.
[ ] FK 3개가 각각 어떤 관계를 뜻하는지 설명할 수 있다.
[ ] NOT NULL 적용 이유를 예시로 설명할 수 있다.
[ ] UNIQUE 적용 이유를 예시로 설명할 수 있다.
[ ] CHECK 적용 이유를 예시로 설명할 수 있다.
[ ] FK 오류가 왜 발생하는지 설명할 수 있다.
[ ] PRAGMA foreign_key_check 결과를 해석할 수 있다.
[ ] ON DELETE RESTRICT의 의미를 설명할 수 있다.
```

---

## 17. 오늘의 완료 기준

```text
[ ] sql/01_schema.sql에서 PK 4개를 직접 찾았다.
[ ] sql/01_schema.sql에서 FK 3개를 직접 찾았다.
[ ] UNIQUE 제약조건 3개를 직접 찾았다.
[ ] CHECK 제약조건을 3개 이상 직접 찾았다.
[ ] PRAGMA foreign_key_check를 설명할 수 있다.
[ ] FK 오류 예시를 말로 설명할 수 있다.
[ ] PK/FK 30초 답변을 소리 내어 연습했다.
```
