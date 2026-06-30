#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# 1. 스크립트 목적과 안전 옵션
# -----------------------------------------------------------------------------

# 전체 SQL 과제를 한 번에 실행하는 스크립트입니다.
# DB를 새로 만들고, 샘플 데이터를 넣은 뒤, 검증/보고서/핵심 쿼리 결과를 파일로 저장합니다.
#
# set -euo pipefail은 초보자가 놓치기 쉬운 오류를 빨리 발견하게 해 줍니다.
# -e: 명령이 실패하면 즉시 중단
# -u: 정의하지 않은 변수를 쓰면 중단
# -o pipefail: 파이프라인 중간 명령 실패도 실패로 처리
set -euo pipefail


# -----------------------------------------------------------------------------
# 2. 기본 설정값
# -----------------------------------------------------------------------------

# 실행 중 사용할 DB 이름, 진행 단계 수, 반드시 있어야 하는 입력 파일 목록입니다.
DB_FILE="book_rental.db"
TOTAL_STEPS=5
REQUIRED_FILES=(
  "sql/01_schema.sql"
  "sql/02_seed.sql"
  "sql/03_queries.sql"
  "sql/04_validation.sql"
  "docs/bonus.sql"
)


# -----------------------------------------------------------------------------
# 3. 실행 위치 보정과 필수 파일 검사
# -----------------------------------------------------------------------------

# 스크립트를 어디서 실행하든 프로젝트 루트 기준으로 경로를 맞춥니다.
cd "$(dirname "$0")/.."

# SQL 파일이나 보너스 보고서 파일이 빠져 있으면 뒤 단계에서 헷갈리지 않도록 바로 중단합니다.
for file in "${REQUIRED_FILES[@]}"; do
  # 현재 검사 중인 파일이 없으면 오류 메시지를 출력하고 스크립트를 종료합니다.
  if [[ ! -f "$file" ]]; then
    echo "[ERROR] Missing required file: $file" >&2
    exit 1
  fi
done

# 실행 결과 파일을 저장할 폴더를 준비합니다.
mkdir -p results


# -----------------------------------------------------------------------------
# 4. SQL 실행 도우미 함수
# -----------------------------------------------------------------------------

# SQL 파일을 DB에 적용합니다. schema/seed처럼 결과 파일이 필요 없는 단계에서 사용합니다.
run_sql() {
  local db_file="$1"
  local sql_file="$2"

  # -bail 옵션은 SQL 오류가 발생했을 때 sqlite3가 즉시 중단되게 합니다.
  sqlite3 -bail "$db_file" < "$sql_file"
}

# SQL 실행 결과를 화면에는 간단히 흘려보내고, 실제 내용은 지정한 결과 파일에 저장합니다.
run_sql_to_file() {
  local db_file="$1"
  local sql_file="$2"
  local output_file="$3"

  # tee는 sqlite3 실행 결과를 파일에 저장합니다. 화면 출력은 /dev/null로 숨깁니다.
  sqlite3 -bail "$db_file" < "$sql_file" | tee "$output_file" > /dev/null
}


# -----------------------------------------------------------------------------
# 5. sqlite3 CLI가 있는 경우의 메인 실행 흐름
# -----------------------------------------------------------------------------

# sqlite3 CLI가 있으면 Bash 흐름으로 실행하고, 없으면 아래 Python 대체 러너로 넘어갑니다.
if command -v sqlite3 >/dev/null 2>&1; then
  # 매번 같은 결과가 나오도록 기존 DB를 지우고 처음부터 다시 만듭니다.
  rm -f "$DB_FILE"

  # Task 1: CREATE TABLE 문을 실행해 데이터베이스의 테이블 구조를 만듭니다.
  echo "[1/$TOTAL_STEPS] Creating schema..."
  run_sql "$DB_FILE" sql/01_schema.sql

  # Task 2: INSERT 문을 실행해 member/book/rental 등에 기본 데이터를 넣습니다.
  echo "[2/$TOTAL_STEPS] Inserting seed data..."
  run_sql "$DB_FILE" sql/02_seed.sql

  # Task 3: DB가 잘 만들어졌는지 확인한 내용을 validation_results.txt에 저장합니다.
  echo "[3/$TOTAL_STEPS] Running validation..."
  run_sql_to_file "$DB_FILE" sql/04_validation.sql results/validation_results.txt

  # Task 4: docs/bonus.sql의 추가 리포트 쿼리를 실행해 bonus_results.txt에 저장합니다.
  echo "[4/$TOTAL_STEPS] Running bonus report queries..."
  run_sql_to_file "$DB_FILE" docs/bonus.sql results/bonus_results.txt

  # 핵심 쿼리 파일에는 INSERT/UPDATE/DELETE가 포함될 수 있으므로 원본 DB가 변하지 않게 복사본에서 실행합니다.
  query_db_file="$(mktemp "${TMPDIR:-/tmp}/book_rental_queries.XXXXXX")"

  # 스크립트가 끝날 때 임시 DB 파일을 자동으로 지우도록 예약합니다.
  trap 'rm -f "$query_db_file"' EXIT

  # 시드 데이터까지 들어간 원본 DB를 임시 DB로 복사합니다.
  cp "$DB_FILE" "$query_db_file"

  # Task 5: sql/03_queries.sql의 필수 쿼리 15개를 실행해 query_results.txt에 저장합니다.
  echo "[5/$TOTAL_STEPS] Running 15 core queries..."
  run_sql_to_file "$query_db_file" sql/03_queries.sql results/query_results.txt

  echo "[DONE] Created $DB_FILE"
  echo "[DONE] Core query mutations were executed on a temporary DB copy."
  echo "[DONE] Check results/validation_results.txt, results/query_results.txt, and results/bonus_results.txt"
else

  # -----------------------------------------------------------------------------
  # 6. sqlite3 CLI가 없는 경우의 Python 대체 실행 흐름
  # -----------------------------------------------------------------------------

  # sqlite3 CLI가 없는 환경에서도 과제를 확인할 수 있도록 Python의 sqlite3 모듈로 같은 흐름을 실행합니다.
  if [[ ! -f scripts/run_all.py ]]; then
    echo "[ERROR] Missing fallback runner: scripts/run_all.py" >&2
    exit 1
  fi

  if ! command -v python3 >/dev/null 2>&1; then
    echo "[ERROR] sqlite3 CLI and python3 are both unavailable." >&2
    exit 1
  fi

  # 대체 러너를 사용한다는 사실을 알려 주고 Python 스크립트에 나머지 작업을 맡깁니다.
  echo "[WARN] sqlite3 CLI was not found. Falling back to Python sqlite3 runner."
  python3 scripts/run_all.py
fi
