#!/usr/bin/env python3
"""SQLite fallback runner for environments where the sqlite3 CLI is unavailable.
It executes the same SQL files and writes text evidence under results/.
"""
from __future__ import annotations

import pathlib
import sqlite3
import re

ROOT = pathlib.Path(__file__).resolve().parents[1]
DB_FILE = ROOT / "book_rental.db"
RESULTS = ROOT / "results"


def read_sql(name: str) -> str:
    return (ROOT / "sql" / name).read_text(encoding="utf-8")


def run_script(conn: sqlite3.Connection, name: str) -> None:
    conn.executescript(read_sql(name))


def format_table(cursor: sqlite3.Cursor, rows: list[tuple]) -> str:
    if cursor.description is None:
        return "OK\n"
    headers = [col[0] for col in cursor.description]
    data = [["" if v is None else str(v) for v in row] for row in rows]
    widths = [len(h) for h in headers]
    for row in data:
        for i, value in enumerate(row):
            widths[i] = max(widths[i], len(value))
    sep = "  ".join("-" * w for w in widths)
    out = ["  ".join(h.ljust(widths[i]) for i, h in enumerate(headers)), sep]
    for row in data:
        out.append("  ".join(value.ljust(widths[i]) for i, value in enumerate(row)))
    return "\n".join(out) + "\n"


def split_sql_statements(sql: str) -> list[tuple[str, str]]:
    """Return [(label, statement)] pairs. Labels come from .print lines."""
    pairs: list[tuple[str, str]] = []
    current_label = "SQL"
    buffer: list[str] = []

    def flush() -> None:
        nonlocal buffer
        stmt = "\n".join(buffer).strip()
        if stmt:
            pairs.append((current_label, stmt))
        buffer = []

    for raw in sql.splitlines():
        line = raw.rstrip()
        stripped = line.strip()
        if not stripped:
            continue
        if stripped.startswith(".headers") or stripped.startswith(".mode"):
            continue
        if stripped.startswith(".print"):
            flush()
            m = re.match(r"\.print\s+'(.*)'\s*$", stripped)
            text = m.group(1) if m else stripped.replace(".print", "", 1).strip()
            if text:
                current_label = text
            continue
        if stripped.startswith("--"):
            continue
        if stripped.upper().startswith("PRAGMA FOREIGN_KEYS"):
            continue
        buffer.append(line)
        if stripped.endswith(";"):
            flush()
    flush()
    return pairs


def execute_queries(conn: sqlite3.Connection) -> str:
    out: list[str] = []
    for label, stmt in split_sql_statements(read_sql("03_queries.sql")):
        out.append(label)
        try:
            cur = conn.execute(stmt)
            if cur.description is not None:
                rows = cur.fetchall()
                out.append(format_table(cur, rows))
            else:
                conn.commit()
                out.append(f"OK (affected_rows={cur.rowcount})\n")
        except sqlite3.Error as exc:
            out.append(f"ERROR: {exc}\n")
        out.append("")
    return "\n".join(out)


def validation(conn: sqlite3.Connection) -> str:
    out: list[str] = []
    out.append("1) Table list")
    cur = conn.execute("SELECT name AS table_name FROM sqlite_master WHERE type = 'table' ORDER BY name")
    out.append(format_table(cur, cur.fetchall()))

    out.append("2) Row counts: every table should have at least 10 rows after seeding.")
    cur = conn.execute("""
        SELECT 'member' AS table_name, COUNT(*) AS row_count FROM member
        UNION ALL SELECT 'category', COUNT(*) FROM category
        UNION ALL SELECT 'book', COUNT(*) FROM book
        UNION ALL SELECT 'rental', COUNT(*) FROM rental
    """)
    out.append(format_table(cur, cur.fetchall()))

    out.append("3) Foreign key integrity check: no rows means OK.")
    cur = conn.execute("PRAGMA foreign_key_check")
    rows = cur.fetchall()
    out.append("OK - no foreign key violations\n" if not rows else format_table(cur, rows))

    out.append("4) Schema overview")
    for table in ["member", "category", "book", "rental"]:
        ddl = conn.execute("SELECT sql FROM sqlite_master WHERE type='table' AND name=?", (table,)).fetchone()[0]
        out.append(ddl + ";\n")
    return "\n".join(out)


def main() -> None:
    RESULTS.mkdir(exist_ok=True)
    if DB_FILE.exists():
        DB_FILE.unlink()
    conn = sqlite3.connect(DB_FILE)
    conn.execute("PRAGMA foreign_keys = ON")
    run_script(conn, "01_schema.sql")
    run_script(conn, "02_seed.sql")
    (RESULTS / "validation_results.txt").write_text(validation(conn), encoding="utf-8")
    (RESULTS / "query_results.txt").write_text(execute_queries(conn), encoding="utf-8")
    conn.close()
    print(f"[DONE] Created {DB_FILE.name}")
    print("[DONE] Wrote results/validation_results.txt")
    print("[DONE] Wrote results/query_results.txt")


if __name__ == "__main__":
    main()
