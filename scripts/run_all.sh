#!/usr/bin/env bash
set -euo pipefail

DB_FILE="book_rental.db"

cd "$(dirname "$0")/.."
mkdir -p results

if command -v sqlite3 >/dev/null 2>&1; then
  rm -f "$DB_FILE"

  echo "[1/4] Creating schema..."
  sqlite3 "$DB_FILE" < sql/01_schema.sql

  echo "[2/4] Inserting seed data..."
  sqlite3 "$DB_FILE" < sql/02_seed.sql

  echo "[3/5] Running validation..."
  sqlite3 "$DB_FILE" < sql/04_validation.sql | tee results/validation_results.txt > /dev/null

  echo "[4/5] Running bonus report queries..."
  sqlite3 "$DB_FILE" < docs/bonus.sql | tee results/bonus_results.txt > /dev/null

  echo "[5/5] Running 15 core queries..."
  sqlite3 "$DB_FILE" < sql/03_queries.sql | tee results/query_results.txt > /dev/null

  echo "[DONE] Created $DB_FILE"
  echo "[DONE] Check results/validation_results.txt, results/query_results.txt, and results/bonus_results.txt"
else
  echo "[WARN] sqlite3 CLI was not found. Falling back to Python sqlite3 runner."
  python3 scripts/run_all.py
fi
