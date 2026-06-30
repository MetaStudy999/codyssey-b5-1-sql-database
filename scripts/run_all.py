#!/usr/bin/env python3
"""sqlite3 CLI 없이도 전체 SQL 과제를 실행하기 위한 Python 스크립트.

터미널에 sqlite3 명령어가 없어도 Python의 sqlite3 모듈로 DB를 만들고,
검증 결과와 쿼리 실행 결과를 results/ 폴더에 텍스트 파일로 저장한다.
"""
from __future__ import annotations

import pathlib
import re
import shutil
import sqlite3
import tempfile


# -----------------------------------------------------------------------------
# 1. 기본 경로와 실행 파일 설정
# -----------------------------------------------------------------------------

# 이 파일은 scripts/ 폴더 안에 있으므로, parents[1]로 프로젝트 루트로 올라간다.
ROOT = pathlib.Path(__file__).resolve().parents[1]

# 최종적으로 생성할 SQLite 데이터베이스 파일 경로.
DB_FILE = ROOT / "book_rental.db"

# 검증 결과와 쿼리 결과를 저장할 폴더 경로.
RESULTS = ROOT / "results"

# 화면에 [1/6]처럼 진행 상황을 보여주기 위한 전체 단계 수.
TOTAL_STEPS = 6

# 실행에 필요한 입력 파일 목록이다. 하나라도 없으면 정상 실행할 수 없다.
REQUIRED_FILES = [
    "sql/01_schema.sql",
    "sql/02_seed.sql",
    "sql/03_queries.sql",
    "sql/04_validation.sql",
    "docs/bonus.sql",
    "docs/fk_error_demo.sql",
]


# -----------------------------------------------------------------------------
# 2. 파일 확인 및 DB 준비 도우미
# -----------------------------------------------------------------------------

# 프로젝트 안의 파일을 읽는 공통 함수다.
# 어느 위치에서 실행하든 ROOT 기준으로 파일을 찾게 해서 경로 오류를 줄인다.
def read_project_file(relative_path: str) -> str:
    return (ROOT / relative_path).read_text(encoding="utf-8")


# 본격 실행 전에 필요한 파일이 모두 있는지 먼저 검사한다.
# 중간에 실패하는 것보다 시작할 때 빠진 파일을 알려주는 편이 디버깅하기 쉽다.
def validate_required_files() -> None:
    missing = [path for path in REQUIRED_FILES if not (ROOT / path).is_file()]

    # 빠진 파일이 하나라도 있으면 SystemExit으로 프로그램을 즉시 종료한다.
    if missing:
        raise SystemExit(f"[ERROR] Missing required file(s): {', '.join(missing)}")


# 핵심 쿼리를 실행할 임시 데이터베이스 복사본을 만든다.
# 03_queries.sql에 INSERT/UPDATE/DELETE가 있어도 원본 DB는 깨끗하게 보존된다.
def make_query_db_copy() -> pathlib.Path:
    handle = tempfile.NamedTemporaryFile(prefix="book_rental_queries.", delete=False)
    query_db = pathlib.Path(handle.name)
    handle.close()
    shutil.copy2(DB_FILE, query_db)
    return query_db


# sql/ 폴더에 있는 SQL 파일을 이름만 받아서 읽는다.
def read_sql(name: str) -> str:
    return read_project_file(f"sql/{name}")


# schema/seed처럼 여러 SQL문이 들어 있는 파일 전체를 한 번에 실행한다.
def run_script(conn: sqlite3.Connection, name: str) -> None:
    conn.executescript(read_sql(name))


# -----------------------------------------------------------------------------
# 3. 결과 표 변환 도우미
# -----------------------------------------------------------------------------

# SELECT 실행 결과를 사람이 읽기 쉬운 텍스트 표로 바꾼다.
# sqlite3 CLI의 표 출력처럼 보이게 만들어 결과 파일을 확인하기 쉽게 한다.
def format_table(cursor: sqlite3.Cursor, rows: list[tuple]) -> str:
    # SELECT가 아닌 SQL은 컬럼 정보(cursor.description)가 없으므로 표를 만들 수 없다.
    if cursor.description is None:
        return "OK\n"

    # cursor.description에는 SELECT 결과의 컬럼 이름이 들어 있다.
    headers = [col[0] for col in cursor.description]

    # None 값은 빈 문자열로 바꾸고, 나머지는 모두 문자열로 바꿔 표에 넣기 쉽게 만든다.
    data = [["" if v is None else str(v) for v in row] for row in rows]

    # 각 열의 최소 너비는 우선 헤더 글자 수로 시작한다.
    widths = [len(h) for h in headers]

    # 모든 데이터를 훑으며 각 열에서 가장 긴 값의 길이를 찾는다.
    for row in data:
        # enumerate는 값과 함께 열 번호(i)를 같이 꺼내기 위해 사용한다.
        for i, value in enumerate(row):
            widths[i] = max(widths[i], len(value))

    # 헤더 아래에 들어갈 구분선을 열 너비에 맞춰 만든다.
    sep = "  ".join("-" * w for w in widths)

    # ljust는 문자열 오른쪽에 공백을 채워 열 너비를 맞춰 준다.
    out = ["  ".join(h.ljust(widths[i]) for i, h in enumerate(headers)), sep]

    # 각 데이터 행도 헤더와 같은 열 너비로 맞춰 추가한다.
    for row in data:
        out.append("  ".join(value.ljust(widths[i]) for i, value in enumerate(row)))
    return "\n".join(out) + "\n"


# -----------------------------------------------------------------------------
# 4. SQL 파일 파싱 및 쿼리 실행
# -----------------------------------------------------------------------------

# SQL 파일을 Python sqlite3가 실행할 수 있는 SQL문 단위로 나눈다.
# .headers, .mode, .print 같은 줄은 sqlite3 CLI 전용 문법이라 따로 처리해야 한다.
def split_sql_statements(sql: str) -> list[tuple[str, str]]:
    pairs: list[tuple[str, str]] = []
    current_label = "SQL"
    buffer: list[str] = []

    def flush() -> None:
        # buffer에 쌓아 둔 여러 줄을 하나의 SQL문 문자열로 합친다.
        nonlocal buffer
        stmt = "\n".join(buffer).strip()

        # 실제 내용이 있을 때만 현재 라벨과 함께 실행 목록에 추가한다.
        if stmt:
            pairs.append((current_label, stmt))
        buffer = []

    # SQL 파일을 한 줄씩 읽으면서 "실행할 SQL"과 "건너뛸 줄"을 구분한다.
    for raw in sql.splitlines():
        line = raw.rstrip()
        stripped = line.strip()

        # 빈 줄은 실행할 내용이 없으므로 건너뛴다.
        if not stripped:
            continue

        # .headers/.mode는 sqlite3 CLI 출력 모양을 정하는 명령이라 Python에서는 실행하지 않는다.
        if stripped.startswith(".headers") or stripped.startswith(".mode"):
            continue

        # .print는 화면에 제목을 찍는 명령이다. 여기서는 결과 파일의 제목으로 재사용한다.
        if stripped.startswith(".print"):
            flush()
            m = re.match(r"\.print\s+'(.*)'\s*$", stripped)
            text = m.group(1) if m else stripped.replace(".print", "", 1).strip()

            # .print에서 뽑은 제목이 비어 있지 않을 때만 다음 쿼리의 라벨로 저장한다.
            if text:
                current_label = text
            continue

        # -- 로 시작하는 SQL 주석은 실행할 문장이 아니므로 건너뛴다.
        if stripped.startswith("--"):
            continue

        # 외래 키 설정은 main()에서 연결마다 직접 켜기 때문에 파일 안의 설정은 건너뛴다.
        if stripped.upper().startswith("PRAGMA FOREIGN_KEYS"):
            continue

        # 여기까지 왔다면 실제 SQL문에 해당하는 줄이므로 buffer에 모은다.
        buffer.append(line)

        # SQL문은 보통 세미콜론(;)으로 끝나므로, 이때 buffer를 실행 목록으로 옮긴다.
        if stripped.endswith(";"):
            flush()
    flush()
    return pairs


# 쿼리 파일을 실행하고, 각 쿼리의 제목과 결과를 하나의 텍스트로 모은다.
# 이 함수가 만든 문자열이 query_results.txt 또는 bonus_results.txt에 저장된다.
def execute_queries(conn: sqlite3.Connection, relative_path: str) -> str:
    out: list[str] = []

    # split_sql_statements()가 만든 (라벨, SQL문) 묶음을 처음부터 끝까지 실행한다.
    for label, stmt in split_sql_statements(read_project_file(relative_path)):
        # 먼저 제목을 넣고, 바로 아래에 해당 SQL의 실행 결과를 붙인다.
        out.append(label)

        # 한 SQL문씩 실행한다. 실패하면 except에서 더 자세한 오류로 바꾼다.
        try:
            cur = conn.execute(stmt)

            # SELECT처럼 결과 행이 있는 SQL은 fetchall()로 모든 행을 가져온다.
            if cur.description is not None:
                rows = cur.fetchall()
                out.append(format_table(cur, rows))

            # INSERT/UPDATE/DELETE처럼 결과 행이 없는 SQL은 변경 건수만 기록한다.
            else:
                conn.commit()
                out.append(f"OK (affected_rows={cur.rowcount})\n")

        # sqlite3 기본 오류만 보면 어느 쿼리에서 실패했는지 알기 어려워 정보를 덧붙인다.
        except sqlite3.Error as exc:
            raise RuntimeError(f"Failed to execute {relative_path} after {label!r}: {exc}") from exc
        out.append("")
    return "\n".join(out)


# -----------------------------------------------------------------------------
# 5. 검증 리포트 생성
# -----------------------------------------------------------------------------

# 생성된 DB가 과제 조건을 만족하는지 확인하는 검증 리포트를 만든다.
# 테이블 목록, 행 개수, 외래 키 오류 여부, CREATE TABLE 문을 차례로 확인한다.
def validation(conn: sqlite3.Connection) -> str:
    out: list[str] = []

    # 1번 검증: 현재 DB에 어떤 테이블이 만들어졌는지 확인한다.
    out.append("1) Table list")
    cur = conn.execute("SELECT name AS table_name FROM sqlite_master WHERE type = 'table' ORDER BY name")
    out.append(format_table(cur, cur.fetchall()))

    # 2번 검증: 주요 테이블마다 시드 데이터가 충분히 들어갔는지 행 개수를 센다.
    out.append("2) Row counts: every table should have at least 10 rows after seeding.")
    cur = conn.execute("""
        SELECT 'member' AS table_name, COUNT(*) AS row_count FROM member
        UNION ALL SELECT 'category', COUNT(*) FROM category
        UNION ALL SELECT 'book', COUNT(*) FROM book
        UNION ALL SELECT 'rental', COUNT(*) FROM rental
    """)
    out.append(format_table(cur, cur.fetchall()))

    # 3번 검증: rental.member_id처럼 다른 테이블을 참조하는 값이 깨졌는지 확인한다.
    out.append("3) Foreign key integrity check: no rows means OK.")
    cur = conn.execute("PRAGMA foreign_key_check")
    rows = cur.fetchall()
    out.append("OK - no foreign key violations\n" if not rows else format_table(cur, rows))

    # 4번 검증: 실제로 생성된 테이블 정의문을 결과 파일에 남긴다.
    out.append("4) Schema overview")

    # sqlite_master는 SQLite가 스키마 정보를 저장해 두는 내부 테이블이다.
    for table in ["member", "category", "book", "rental"]:
        ddl = conn.execute("SELECT sql FROM sqlite_master WHERE type='table' AND name=?", (table,)).fetchone()[0]
        out.append(ddl + ";\n")
    return "\n".join(out)


# -----------------------------------------------------------------------------
# 6. FK 오류 데모 생성
# -----------------------------------------------------------------------------

# 존재하지 않는 부모 값을 참조하는 INSERT가 실제로 막히는지 확인하고,
# 그 실패 결과를 텍스트 증빙으로 만든다.
def fk_error_demo(conn: sqlite3.Connection) -> str:
    out = [
        "Command:",
        'sqlite3 -bail book_rental.db ".read docs/fk_error_demo.sql"',
        "",
        "Expected:",
        "This command should fail because rental.member_id = 999 does not exist in member.member_id.",
        "",
        "Output:",
        "FK Error Demo. 존재하지 않는 member_id=999를 참조하는 대여 기록 입력을 시도한다.",
        "Expected result: member_id=999는 member 테이블에 없으므로 FOREIGN KEY constraint failed가 발생해야 정상이다.",
    ]

    try:
        conn.execute(
            """
            INSERT INTO rental (rental_id, member_id, book_id, rented_at, due_date, status, rental_fee)
            VALUES (999, 999, 1, '2024-08-01', '2024-08-15', 'RENTED', 0)
            """
        )
        conn.commit()
    except sqlite3.IntegrityError as exc:
        conn.rollback()
        if "FOREIGN KEY constraint failed" not in str(exc):
            raise RuntimeError(f"FK error demo failed with an unexpected error: {exc}") from exc
        out.extend([
            f"Runtime error near line 14: {exc} (19)",
            "",
            "Exit code:",
            "1",
        ])
        return "\n".join(out) + "\n"

    raise RuntimeError("FK error demo unexpectedly succeeded.")


# -----------------------------------------------------------------------------
# 7. 전체 작업 실행 흐름
# -----------------------------------------------------------------------------

# 전체 실행 순서를 관리하는 메인 함수다.
# 파일 검사부터 DB 생성, 결과 파일 저장, 임시 DB 정리까지 여기서 순서대로 진행한다.
def main() -> None:
    # 필요한 파일이 있는지 확인하고, 결과 폴더가 없으면 새로 만든다.
    validate_required_files()
    RESULTS.mkdir(exist_ok=True)

    # 기존 DB 파일이 남아 있으면 삭제한다. 그래야 매번 같은 초기 상태에서 시작한다.
    if DB_FILE.exists():
        DB_FILE.unlink()

    # 새 SQLite DB 파일에 연결한다. 파일이 없으면 sqlite3가 자동으로 생성한다.
    conn = sqlite3.connect(DB_FILE)

    # 메인 DB 생성부터 보너스 리포트까지는 원본 DB 연결에서 처리한다.
    try:
        # SQLite는 연결마다 외래 키 검사를 켜야 하므로 새 연결을 열 때마다 설정한다.
        conn.execute("PRAGMA foreign_keys = ON")

        # Task 1: CREATE TABLE 문을 실행해 데이터베이스의 테이블 구조를 만든다.
        print(f"[1/{TOTAL_STEPS}] Creating schema...")
        run_script(conn, "01_schema.sql")

        # Task 2: INSERT 문을 실행해 member/book/rental 등에 기본 데이터를 넣는다.
        print(f"[2/{TOTAL_STEPS}] Inserting seed data...")
        run_script(conn, "02_seed.sql")
        conn.commit()

        # Task 3: DB가 잘 만들어졌는지 확인한 내용을 validation_results.txt에 저장한다.
        print(f"[3/{TOTAL_STEPS}] Running validation...")
        (RESULTS / "validation_results.txt").write_text(validation(conn), encoding="utf-8")

        # Task 4: docs/bonus.sql의 추가 리포트 쿼리를 실행해 bonus_results.txt에 저장한다.
        print(f"[4/{TOTAL_STEPS}] Running bonus report queries...")
        (RESULTS / "bonus_results.txt").write_text(execute_queries(conn, "docs/bonus.sql"), encoding="utf-8")
        conn.commit()

    # 중간에 오류가 나더라도 DB 연결은 반드시 닫아 파일 잠금을 풀어 준다.
    finally:
        conn.close()

    # 여기서부터는 원본 DB가 아니라 복사본 DB를 사용한다.
    # 핵심 쿼리가 데이터를 바꿔도 book_rental.db는 시드 직후 상태로 남는다.
    query_db = make_query_db_copy()
    query_conn = sqlite3.connect(query_db)

    # 핵심 쿼리 실행 전용 연결에서도 외래 키 검사를 켠다.
    try:
        query_conn.execute("PRAGMA foreign_keys = ON")

        # Task 5: sql/03_queries.sql의 필수 쿼리 15개를 실행해 query_results.txt에 저장한다.
        print(f"[5/{TOTAL_STEPS}] Running 15 core queries...")
        (RESULTS / "query_results.txt").write_text(execute_queries(query_conn, "sql/03_queries.sql"), encoding="utf-8")

    # 임시 DB는 결과 파일을 만든 뒤 더 필요 없으므로 연결을 닫고 파일을 삭제한다.
    finally:
        query_conn.close()
        query_db.unlink(missing_ok=True)

    # 원본 DB에 대해 FK 오류 데모를 실행한다. 실패해야 정상인 데모이므로 별도 함수에서 검증한다.
    fk_conn = sqlite3.connect(DB_FILE)
    try:
        fk_conn.execute("PRAGMA foreign_keys = ON")
        print(f"[6/{TOTAL_STEPS}] Running expected FK error demo...")
        (RESULTS / "fk_error_demo.txt").write_text(fk_error_demo(fk_conn), encoding="utf-8")
    finally:
        fk_conn.close()

    print(f"[DONE] Created {DB_FILE.name}")
    print("[DONE] Core query mutations were executed on a temporary DB copy.")
    print("[DONE] Check results/validation_results.txt, results/query_results.txt, results/bonus_results.txt, and results/fk_error_demo.txt")


# -----------------------------------------------------------------------------
# 8. 스크립트 직접 실행 진입점
# -----------------------------------------------------------------------------

# 이 파일을 직접 실행할 때만 main()을 호출한다.
if __name__ == "__main__":
    main()
