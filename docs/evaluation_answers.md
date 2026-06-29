# B5-1 평가 대비 설명 답안

## 1. 테이블을 왜 나눴는가?

엑셀처럼 한 표에 회원명, 이메일, 도서명, 카테고리명, 대여일을 모두 넣으면 같은 회원 정보와 도서 정보가 반복 저장된다. 그래서 `member`, `category`, `book`, `rental`로 나누었다. `rental`은 회원과 도서가 만나는 사건 테이블이다.

## 2. PK/FK와 1:N 관계

- PK는 각 행을 유일하게 식별하는 값이다. 예: `member.member_id`, `book.book_id`.
- FK는 다른 테이블의 PK를 참조하여 관계를 만든다.
- `member 1 : N rental`: 한 회원은 여러 번 대여할 수 있다.
- `book 1 : N rental`: 한 권의 책은 여러 번 대여될 수 있다.
- `category 1 : N book`: 한 카테고리는 여러 권의 책을 포함할 수 있다.

## 3. 컬럼 타입 선택 이유

SQLite 기준으로 문자열은 `TEXT`, 금액/수량/ID는 `INTEGER`, 날짜는 ISO 형식 문자열(`YYYY-MM-DD`)을 저장하기 위해 `TEXT`를 사용했다. SQLite는 별도 DATE 타입이 강하지 않으므로, 정렬 가능한 날짜 문자열을 사용했다.

## 4. INNER JOIN과 LEFT JOIN 차이

- INNER JOIN은 양쪽 테이블에 모두 매칭되는 행만 보여준다.
- LEFT JOIN은 왼쪽 테이블의 행을 모두 유지하고, 오른쪽에 매칭이 없으면 NULL로 보여준다.
- 이 프로젝트에서는 대여 기록이 없는 회원도 확인하기 위해 `member LEFT JOIN rental`을 사용했다.

## 5. GROUP BY와 집계 함수

`GROUP BY`는 같은 기준의 행을 묶는다. `COUNT`는 개수, `SUM`은 합계, `AVG`는 평균을 계산한다. 예를 들어 회원별 대여 횟수는 `member_id`로 묶고 `COUNT(rental_id)`를 계산한다.

## 6. 인덱스 선택 이유

`rental(member_id, due_date)`에 인덱스를 만들었다. 이유는 특정 회원의 대여 기록을 반납기한 순으로 조회하는 요구가 자주 발생하기 때문이다. 이 인덱스는 `WHERE member_id = ? ORDER BY due_date` 형태의 조회에 유리하다.

## 7. 가장 복잡했던 쿼리 설명 예시

Q07은 `rental`, `member`, `book`, `category` 네 테이블을 연결한다. 먼저 대여 기록에서 `status = 'OVERDUE'`인 행만 고른다. 그 다음 회원 이름은 `member`, 도서명은 `book`, 카테고리명은 `category`에서 가져온다. 이 쿼리로 연체 기록을 사람이 읽기 쉬운 형태로 확인할 수 있다.
