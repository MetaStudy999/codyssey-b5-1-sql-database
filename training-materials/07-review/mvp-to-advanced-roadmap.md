# B5-1 MVP에서 고도화까지 로드맵

이 문서는 B5-1 「SQL로 만드는 나만의 데이터베이스」 프로젝트를 **평가용 SQLite MVP**에서 **백엔드 API, 인증, 배포, 운영형 서비스**로 확장하기 위한 단계별 로드맵이다.

핵심 원칙은 다음과 같다.

```text
평가 전에는 필수 요구사항과 설명 안정화를 우선한다.
평가 후에는 작은 기능부터 서비스 구조로 확장한다.
고도화는 테이블 추가보다 데이터 흐름, 트랜잭션, API, 테스트, 배포를 함께 설계하는 방향으로 진행한다.
```

---

## 1. 현재 MVP 상태

현재 B5-1 프로젝트의 MVP는 다음 상태로 볼 수 있다.

```text
도메인: 도서 대여 관리
DBMS: SQLite
핵심 테이블: member, category, book, rental
핵심 관계: category 1:N book, member 1:N rental, book 1:N rental
핵심 쿼리: SELECT, JOIN, GROUP BY, 서브쿼리, UPDATE, DELETE, INDEX
산출물: SQL, ERD, 실행 결과, 평가 답변, 훈련 문서
```

평가용 MVP의 목표:

> 관계형 데이터베이스의 기본 구조를 설계하고, 요구사항을 SQL로 해결할 수 있음을 증명하는 것이다.

---

## 2. 고도화 전체 방향

SQLite 파일 기반 프로젝트를 실제 서비스에 가깝게 확장하려면 다음 순서가 적절하다.

```text
1. 평가용 SQL MVP 완성
2. SQL 품질 보강
3. 테스트 가능한 DB 프로젝트로 정리
4. FastAPI CRUD API 연결
5. 인증과 권한 추가
6. PostgreSQL 전환
7. 배포와 운영 환경 구성
8. 관리자/통계 기능 확장
9. 서비스형 MVP로 전환
10. 실무형 포트폴리오화
```

---

## 3. 단계별 로드맵 요약

| 단계 | 목표 | 핵심 산출물 | 연결 미션 |
|---|---|---|---|
| 0단계 | B5-1 평가 안정화 | SQL, ERD, 실행 결과, 답변 스크립트 | B5-1 |
| 1단계 | SQL 품질 개선 | 보완 쿼리, 테스트 쿼리, 리팩터링 문서 | B5-1 심화 |
| 2단계 | API MVP | FastAPI CRUD, SQLite 연동 | B5-2 |
| 3단계 | 인증/연관관계 | 로그인, 권한, 사용자별 대여 | B5-3 |
| 4단계 | PostgreSQL 전환 | 마이그레이션, 운영 DB | B6-1 |
| 5단계 | 배포 | Cloud Run 또는 VM 배포 | B6-1 |
| 6단계 | AI/자동화 연결 | PR 자동화, 리포트 생성 | B6-2 |
| 7단계 | 웹 서비스화 | React 관리자 화면 | B4-2/B7 |

---

## 4. 0단계 - 평가용 MVP 완성

### 목표

B5-1 평가에서 감점 없이 설명 가능한 상태를 만든다.

### 완료 기준

```text
[ ] run_all.sh가 오류 없이 실행된다.
[ ] results/query_results.md가 최신이다.
[ ] ERD와 schema.sql이 일치한다.
[ ] Q01~Q15를 설명할 수 있다.
[ ] 30초/1분 답변을 말할 수 있다.
[ ] idx_rental_member_due 인덱스 목적을 설명할 수 있다.
```

### 하지 말아야 할 것

```text
[ ] 평가 직전에 예약/벌금/감사 로그 같은 새 테이블을 무리하게 추가하지 않는다.
[ ] 기존 통과 가능한 SQL을 대규모로 뜯어고치지 않는다.
[ ] 결과 파일과 SQL이 불일치한 상태로 두지 않는다.
```

평가 전 핵심 문장:

> 지금 단계의 목표는 기능 확장이 아니라 평가 요구사항을 안정적으로 충족하고 말로 설명하는 것이다.

---

## 5. 1단계 - SQL 품질 개선

### 목표

현재 SQL을 더 읽기 쉽고 검증 가능하게 만든다.

### 작업 항목

```text
[ ] sql/03_queries.sql의 각 Q에 목적 주석을 보강한다.
[ ] UPDATE/DELETE 전후 확인 쿼리를 더 명확히 분리한다.
[ ] EXPLAIN QUERY PLAN 결과 해석을 results에 짧게 추가한다.
[ ] JOIN과 GROUP BY 쿼리에 평가용 설명 주석을 붙인다.
[ ] 추가 실습 쿼리를 training-materials에만 유지하고 핵심 제출물과 구분한다.
```

### 추가하면 좋은 SQL

```sql
-- 대여 가능 수량 계산 예시
SELECT b.book_id,
       b.title,
       b.stock - COUNT(r.rental_id) AS available_stock
FROM book b
LEFT JOIN rental r
    ON b.book_id = r.book_id
   AND r.status IN ('RENTED', 'OVERDUE')
GROUP BY b.book_id, b.title, b.stock;
```

주의:

> 이 쿼리는 확장 학습에는 좋지만 B5-1 필수 제출물에 무리하게 넣을 필요는 없다.

---

## 6. 2단계 - FastAPI CRUD API MVP

### 목표

현재 SQLite DB를 FastAPI 백엔드와 연결한다.

### API 후보

| 기능 | Method | Path | 설명 |
|---|---|---|---|
| 회원 목록 | GET | `/members` | 회원 전체 조회 |
| 회원 상세 | GET | `/members/{member_id}` | 특정 회원 조회 |
| 도서 목록 | GET | `/books` | 도서 전체 조회 |
| 도서 상세 | GET | `/books/{book_id}` | 특정 도서 조회 |
| 대여 목록 | GET | `/rentals` | 대여 기록 조회 |
| 대여 생성 | POST | `/rentals` | 회원이 도서를 대여 |
| 반납 처리 | PATCH | `/rentals/{rental_id}/return` | 반납 상태 변경 |
| 연체 처리 | PATCH | `/rentals/{rental_id}/overdue` | 연체 상태 변경 |
| 통계 | GET | `/stats/summary` | 대여/도서/회원 요약 |

### 산출물

```text
[ ] app/main.py
[ ] app/database.py
[ ] app/models.py 또는 schema 정의
[ ] app/routers/members.py
[ ] app/routers/books.py
[ ] app/routers/rentals.py
[ ] requirements.txt 또는 pyproject.toml
[ ] README API 실행 방법
```

### 핵심 원칙

> SQL에서 확인한 관계를 API 리소스로 옮긴다. DB 설계를 바꾸기보다 먼저 CRUD 흐름을 안정화한다.

---

## 7. 3단계 - 인증과 권한 추가

### 목표

회원 또는 관리자 인증을 추가하고, 사용자별 접근 권한을 분리한다.

### 인증 구조 후보

```text
일반 회원: 본인의 대여 기록 조회, 대여 신청, 반납 요청
관리자: 회원 관리, 도서 관리, 연체 처리, 통계 조회
```

### 추가 테이블 후보

```text
user_account
role
```

또는 단순화 버전:

```text
member 테이블에 password_hash, role 컬럼 추가
```

### API 후보

| 기능 | Method | Path |
|---|---|---|
| 회원 가입 | POST | `/auth/register` |
| 로그인 | POST | `/auth/login` |
| 내 정보 | GET | `/me` |
| 내 대여 기록 | GET | `/me/rentals` |
| 관리자 회원 관리 | GET | `/admin/members` |

### 주의

> B5-1에서는 인증이 필요 없지만 B5-3에서는 인증과 연관관계를 설명할 수 있어야 한다. 이때 현재 `member`, `rental` 관계가 기반이 된다.

---

## 8. 4단계 - PostgreSQL 전환

### 목표

SQLite 학습용 DB를 서버형 DBMS로 전환한다.

### 전환 이유

```text
[ ] 동시 접속 처리
[ ] 운영 환경 안정성
[ ] 권한 관리
[ ] 백업/복구
[ ] 마이그레이션 관리
[ ] 배포 환경 연동
```

### 전환 작업

```text
[ ] SQLite 타입을 PostgreSQL 타입으로 검토한다.
[ ] AUTOINCREMENT/SERIAL/IDENTITY 전략을 정한다.
[ ] CHECK, FK, UNIQUE 제약조건을 재확인한다.
[ ] Alembic 같은 마이그레이션 도구를 도입한다.
[ ] 개발/운영 DB 환경변수를 분리한다.
```

### 주의할 차이

| 항목 | SQLite | PostgreSQL |
|---|---|---|
| 서버 | 파일 기반 | 서버 기반 |
| 타입 엄격성 | 상대적으로 유연 | 더 엄격 |
| 동시성 | 소규모에 적합 | 서비스 운영에 적합 |
| 마이그레이션 | 단순 SQL 가능 | 도구 사용 권장 |

---

## 9. 5단계 - 배포와 운영 환경

### 목표

API와 DB를 실제 접속 가능한 환경에 배포한다.

### 배포 후보

```text
[ ] 로컬 Docker Compose
[ ] VM + PostgreSQL
[ ] Cloud Run + Cloud SQL
[ ] Render/Railway/Fly.io 같은 PaaS
```

### 운영 체크

```text
[ ] 환경변수로 DB 접속 정보 관리
[ ] 로그 확인
[ ] 헬스 체크 엔드포인트 추가
[ ] DB 백업 정책 수립
[ ] 관리자 계정 초기화 방법 문서화
```

### API 헬스 체크 예시

```text
GET /health
```

응답 예시:

```json
{"status":"ok","database":"connected"}
```

---

## 10. 6단계 - 관리자 통계 기능

### 목표

B5-1에서 만든 GROUP BY, JOIN, 랭킹 쿼리를 관리자 통계 API로 확장한다.

### 통계 API 후보

| 기능 | Path | 기반 SQL |
|---|---|---|
| 회원별 대여 횟수 | `/stats/members/rentals` | JOIN + GROUP BY + COUNT |
| 인기 도서 TOP 5 | `/stats/books/top` | JOIN + GROUP BY + ORDER BY + LIMIT |
| 카테고리별 평균 가격 | `/stats/categories/avg-price` | JOIN + GROUP BY + AVG |
| 연체 현황 | `/stats/rentals/overdue` | WHERE + JOIN |
| 월별 대여 건수 | `/stats/rentals/monthly` | substr/date + GROUP BY |

핵심 문장:

> B5-1에서 작성한 집계 쿼리는 이후 관리자 통계 API의 기반이 된다.

---

## 11. 7단계 - 프론트엔드 관리자 화면

### 목표

React 또는 간단한 템플릿으로 관리자 화면을 만든다.

### 화면 후보

```text
[ ] 회원 목록 화면
[ ] 도서 목록 화면
[ ] 대여 기록 화면
[ ] 연체 관리 화면
[ ] 인기 도서 통계 화면
[ ] 카테고리별 통계 화면
```

### 데이터 흐름

```text
React 화면 → FastAPI API → DB 조회 → JSON 응답 → 테이블/차트 표시
```

### MVP 우선순위

```text
1. 도서 목록
2. 대여 기록 목록
3. 대여 생성/반납 처리
4. 통계 화면
5. 관리자 권한
```

---

## 12. 8단계 - 테스트 자동화

### 목표

수동 실행에서 자동 검증으로 발전한다.

### 테스트 범위

```text
[ ] DB 스키마 생성 테스트
[ ] 샘플 데이터 수 테스트
[ ] FK 무결성 테스트
[ ] 주요 SELECT 쿼리 실행 테스트
[ ] API 응답 테스트
[ ] 인증 권한 테스트
[ ] 대여/반납 트랜잭션 테스트
```

### 테스트 파일 후보

```text
tests/
├── test_schema.py
├── test_seed.py
├── test_members_api.py
├── test_books_api.py
├── test_rentals_api.py
└── test_stats_api.py
```

---

## 13. 9단계 - 도메인 확장

### 추가 테이블 후보

| 테이블 | 목적 |
|---|---|
| `reservation` | 도서 예약 대기열 |
| `fee_policy` | 연체료 정책 이력 |
| `audit_log` | 변경 이력 추적 |
| `admin_user` | 관리자 계정 |
| `notification` | 반납 예정/연체 알림 |
| `book_copy` | 동일 도서의 개별 소장본 관리 |

### 확장 우선순위

```text
1. reservation
2. book_copy
3. fee_policy
4. audit_log
5. notification
```

주의:

> 도메인 확장은 ERD와 FK 관계가 함께 늘어난다. 테이블만 추가하지 말고 어떤 요구사항을 해결하는지 먼저 정의해야 한다.

---

## 14. 고도화 시 주의할 점

```text
[ ] 평가 전에는 기능 추가보다 실행 검증을 우선한다.
[ ] 새 테이블 추가 시 기존 쿼리가 깨지지 않게 한다.
[ ] API를 만들 때 DB 제약조건과 비즈니스 규칙을 구분한다.
[ ] 인증 도입 시 비밀번호 평문 저장을 금지한다.
[ ] 배포 시 DB 접속 정보는 환경변수로 관리한다.
[ ] 인덱스는 실제 조회 패턴을 기준으로 추가한다.
[ ] 테스트 없이 대규모 리팩터링을 하지 않는다.
```

---

## 15. 학습 연결 로드맵

| 현재 학습 | 다음 학습 | 연결 포인트 |
|---|---|---|
| B5-1 SQL | B5-2 FastAPI CRUD | SQL 요구사항을 API로 연결 |
| B5-2 CRUD | B5-3 인증/관계 | 사용자별 데이터 접근 제어 |
| B5-3 인증 | B6-1 인프라 | API/DB 배포 |
| B6-1 인프라 | B6-2 자동화 | 커밋/PR/문서 자동화 |
| B4-2 React | B7 챗봇/서비스 | 관리자 화면과 AI 기능 연결 |

---

## 16. 30일 고도화 계획

### 1주차 - 평가 안정화

```text
[ ] run_all.sh 검증
[ ] README 보강
[ ] ERD/스키마 일치 확인
[ ] 평가 답변 말하기 연습
```

### 2주차 - FastAPI CRUD

```text
[ ] FastAPI 프로젝트 생성
[ ] DB 연결
[ ] 회원/도서/대여 목록 API
[ ] 대여 생성/반납 API
```

### 3주차 - 인증/권한

```text
[ ] 로그인 API
[ ] 비밀번호 해시
[ ] JWT 또는 세션 구조
[ ] 내 대여 기록 조회
[ ] 관리자 권한 분리
```

### 4주차 - 배포/통계

```text
[ ] Dockerfile 작성
[ ] PostgreSQL 또는 운영 DB 연결
[ ] 통계 API 추가
[ ] 배포 문서 작성
[ ] 포트폴리오 README 정리
```

---

## 17. 포트폴리오화 기준

포트폴리오로 보여주려면 다음이 필요하다.

```text
[ ] 문제 정의가 명확하다.
[ ] ERD가 있다.
[ ] API 문서가 있다.
[ ] 실행 방법이 있다.
[ ] 테스트가 있다.
[ ] 배포 주소 또는 시연 영상이 있다.
[ ] 기술 선택 이유가 있다.
[ ] 한계와 개선 계획이 있다.
```

포트폴리오 설명 문장:

> 이 프로젝트는 SQL 학습용 도서 대여 DB에서 출발해 FastAPI CRUD, 인증, PostgreSQL, 배포, 관리자 통계로 확장할 수 있는 백엔드 포트폴리오 프로젝트입니다.

---

## 18. 고도화 우선순위 판단

| 질문 | 예이면 | 아니면 |
|---|---|---|
| 평가가 임박했는가? | 새 기능 추가 금지, 실행 검증 | 다음 단계 진행 가능 |
| run_all.sh가 통과하는가? | README/답변 보강 | SQL 오류 수정 우선 |
| JOIN/GROUP BY 설명 가능한가? | API 확장 가능 | 평가 답변 연습 우선 |
| README가 명확한가? | FastAPI 작업 가능 | 문서 보강 우선 |
| 결과 파일이 최신인가? | 제출 가능성 높음 | 재실행 후 갱신 |

---

## 19. 다음 작업 추천 순서

평가 전:

```text
1. final-checklist.md 수행
2. score-self-review.md로 자가 점수 기록
3. refactor-todo.md의 P0만 처리
4. answer-scripts.md 30초/1분 답변 연습
```

평가 후:

```text
1. FastAPI CRUD 프로젝트 시작
2. SQLite DB 연결
3. 회원/도서/대여 API 구현
4. 인증 추가
5. PostgreSQL 전환
6. 배포
```

---

## 20. 오늘의 완료 기준

```text
[ ] 현재 B5-1 MVP 상태를 설명했다.
[ ] 평가 전에는 기능 추가보다 안정화가 우선임을 확인했다.
[ ] FastAPI CRUD 확장 단계를 이해했다.
[ ] 인증/권한 확장 방향을 확인했다.
[ ] PostgreSQL 전환 이유를 설명했다.
[ ] 배포와 운영 체크 항목을 확인했다.
[ ] 관리자 통계 API가 기존 GROUP BY 쿼리와 연결됨을 이해했다.
[ ] 평가 후 확장할 테이블 후보를 확인했다.
[ ] 30일 고도화 계획을 읽었다.
```
