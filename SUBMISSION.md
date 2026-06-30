# B5-1 제출 인덱스

## 1. 프로젝트 정보

- 미션: B5-1. SQL로 만드는 나만의 데이터베이스
- 주제: 도서 대여 관리 데이터베이스
- DB: SQLite 3
- 백엔드 프레임워크: 사용하지 않음

## 2. 제출 파일

| 제출 요구 | 파일 |
|---|---|
| 스키마 생성 SQL | `sql/01_schema.sql` |
| 샘플 데이터 INSERT SQL | `sql/02_seed.sql` |
| 핵심 쿼리 15개 SQL | `sql/03_queries.sql` |
| 검증 SQL | `sql/04_validation.sql` |
| 실행 자동화 스크립트 | `scripts/run_all.sh`, `scripts/run_all.py` |
| 실행 결과 텍스트 | `results/query_results.txt` |
| 검증 결과 텍스트 | `results/validation_results.txt` |
| 보너스 SQL/리포트 | `docs/bonus.sql`, `docs/mini_report.md` |
| 보너스 실행 결과 | `results/bonus_results.txt` |
| FK 오류 재현 SQL | `docs/fk_error_demo.sql` |
| FK 오류 실행 결과 | `results/fk_error_demo.txt` |
| ERD 선택 제출 | `docs/ERD.md` |
| 평가문항 상세 답변 | `b5-1-evaluation.md` |
| 평가 말하기 요약 답안 | `docs/evaluation_answers.md` |

## 3. 자체 검증 체크리스트

- [x] 최소 4개 테이블 존재
- [x] 각 테이블 PK 존재
- [x] FK 기반 1:N 관계 2개 이상 존재
- [x] 각 테이블 10행 이상 샘플 데이터 존재
- [x] 기본 조회 4개 이상
- [x] 조인 4개 이상
- [x] 집계 3개 이상
- [x] 서브쿼리 1개 이상
- [x] UPDATE/DELETE 2개 이상
- [x] CREATE INDEX 1개 이상
- [x] 쿼리별 설명 포함
- [x] 실행 결과 텍스트 포함
- [x] FK 오류 재현 SQL 및 실패 로그 포함
- [x] 보너스: JOIN 방식과 서브쿼리 방식 비교
- [x] 보너스: FK 오류 데모 기록
- [x] 보너스: 핵심 지표 3개 미니 리포트
