-- ============================================================================
-- B5-1 SQL Mission: Book Rental Database
-- DB: SQLite 3
-- Purpose: create schema with PK/FK/constraints
--
-- 입문자 메모
-- - 스키마(schema)는 데이터베이스의 "설계도"입니다.
-- - CREATE TABLE은 표를 만들고, 각 컬럼의 자료형과 규칙을 정합니다.
-- - PRIMARY KEY(PK)는 행을 구분하는 고유한 값입니다.
-- - FOREIGN KEY(FK)는 다른 테이블의 PK를 참조해 데이터 관계를 만듭니다.
-- - NOT NULL, UNIQUE, CHECK, DEFAULT는 잘못된 데이터 입력을 막는 안전장치입니다.
-- ============================================================================

-- ============================================================================
-- 1. SQLite 기본 설정
-- ============================================================================
-- SQLite는 기본적으로 외래키 검사를 꺼둘 수 있습니다.
-- 이 옵션을 켜야 FOREIGN KEY 규칙이 실제로 동작합니다.
PRAGMA foreign_keys = ON;

-- ============================================================================
-- 2. 기존 테이블 삭제
-- ============================================================================
-- 스크립트를 여러 번 실행해도 다시 만들 수 있도록 기존 테이블을 삭제합니다.
-- rental처럼 다른 테이블을 참조하는 "자식 테이블"을 먼저 삭제해야
-- 외래키 관계 때문에 삭제가 막히는 상황을 피할 수 있습니다.
DROP TABLE IF EXISTS rental;
DROP TABLE IF EXISTS book;
DROP TABLE IF EXISTS category;
DROP TABLE IF EXISTS member;

-- ============================================================================
-- 3. 회원 테이블: member
-- ============================================================================
-- 도서관 회원 정보를 저장합니다.
-- member_id는 각 회원을 구분하는 기본키입니다.
-- email은 로그인/연락처처럼 중복되면 안 되는 값이므로 UNIQUE를 사용합니다.
-- status는 CHECK로 허용된 상태값만 저장되도록 제한합니다.
CREATE TABLE member (
    member_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    phone TEXT,
    joined_at TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'ACTIVE'
        CHECK (status IN ('ACTIVE', 'SUSPENDED', 'WITHDRAWN'))
);

-- ============================================================================
-- 4. 카테고리 테이블: category
-- ============================================================================
-- 책을 분야별로 묶기 위한 분류 정보를 저장합니다.
-- 예: 소설, 과학, 역사, 컴퓨터 등
-- name은 같은 카테고리명이 중복되지 않도록 UNIQUE를 사용합니다.
CREATE TABLE category (
    category_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    description TEXT
);

-- ============================================================================
-- 5. 도서 테이블: book
-- ============================================================================
-- 실제 대여 대상인 책 정보를 저장합니다.
-- category_id는 category 테이블의 category_id를 참조하는 외래키입니다.
-- published_year, price, stock은 CHECK로 값의 범위를 제한합니다.
-- ON UPDATE CASCADE는 참조 대상 PK가 바뀌면 이 테이블의 FK도 함께 바꿉니다.
-- ON DELETE RESTRICT는 연결된 책이 있는 카테고리를 함부로 삭제하지 못하게 막습니다.
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

-- ============================================================================
-- 6. 대여 테이블: rental
-- ============================================================================
-- 어떤 회원이 어떤 책을 언제 빌렸고 언제 반납했는지 저장합니다.
-- member_id는 member 테이블을, book_id는 book 테이블을 참조합니다.
-- returned_at은 아직 반납하지 않은 경우 비어 있을 수 있으므로 NOT NULL을 붙이지 않습니다.
-- status는 대여 상태를 제한해 오타나 엉뚱한 값이 들어가는 것을 막습니다.
-- rental_fee는 음수가 될 수 없도록 CHECK를 사용합니다.
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
