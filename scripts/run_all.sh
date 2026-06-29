#!/usr/bin/env bash
set -euo pipefail

DB_FILE="book_rental.db"
TOTAL_STEPS=5
REQUIRED_FILES=(
  "sql/01_schema.sql"
  "sql/02_seed.sql"
  "sql/03_queries.sql"
  "sql/04_validation.sql"
  "docs/bonus.sql"
)

cd "$(dirname "$0")/.."

for file in "${REQUIRED_FILES[@]}"; do
  if [[ ! -f "$file" ]]; then
    echo "[ERROR] Missing required file: $file" >&2
    exit 1
  fi
done

mkdir -p results

run_sql() {
  local db_file="$1"
  local sql_file="$2"

  sqlite3 -bail "$db_file" < "$sql_file"
}

run_sql_to_file() {
  local db_file="$1"
  local sql_file="$2"
  local output_file="$3"

  sqlite3 -bail "$db_file" < "$sql_file" | tee "$output_file" > /dev/null
}

if command -v sqlite3 >/dev/null 2>&1; then
  rm -f "$DB_FILE"

  echo "[1/$TOTAL_STEPS] Creating schema..."
  run_sql "$DB_FILE" sql/01_schema.sql

  echo "[2/$TOTAL_STEPS] Inserting seed data..."
  run_sql "$DB_FILE" sql/02_seed.sql

  echo "[3/$TOTAL_STEPS] Running validation..."
  run_sql_to_file "$DB_FILE" sql/04_validation.sql results/validation_results.txt

  echo "[4/$TOTAL_STEPS] Running bonus report queries..."
  run_sql_to_file "$DB_FILE" docs/bonus.sql results/bonus_results.txt

  query_db_file="$(mktemp "${TMPDIR:-/tmp}/book_rental_queries.XXXXXX")"
  trap 'rm -f "$query_db_file"' EXIT
  cp "$DB_FILE" "$query_db_file"

  echo "[5/$TOTAL_STEPS] Running 15 core queries..."
  run_sql_to_file "$query_db_file" sql/03_queries.sql results/query_results.txt

  echo "[DONE] Created $DB_FILE"
  echo "[DONE] Core query mutations were executed on a temporary DB copy."
  echo "[DONE] Check results/validation_results.txt, results/query_results.txt, and results/bonus_results.txt"
else
  if [[ ! -f scripts/run_all.py ]]; then
    echo "[ERROR] Missing fallback runner: scripts/run_all.py" >&2
    exit 1
  fi

  if ! command -v python3 >/dev/null 2>&1; then
    echo "[ERROR] sqlite3 CLI and python3 are both unavailable." >&2
    exit 1
  fi

  echo "[WARN] sqlite3 CLI was not found. Falling back to Python sqlite3 runner."
  python3 scripts/run_all.py
fi
