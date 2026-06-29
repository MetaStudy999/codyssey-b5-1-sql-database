-- B5-1 SQL Mission: sample data
-- Rule: insert parent tables first, then child table.

PRAGMA foreign_keys = ON;

INSERT INTO member (member_id, name, email, phone, joined_at, status) VALUES
(1, '김민준', 'minjun.kim@example.com', '010-1000-0001', '2024-01-03', 'ACTIVE'),
(2, '이서연', 'seoyeon.lee@example.com', '010-1000-0002', '2024-01-15', 'ACTIVE'),
(3, '박도윤', 'doyun.park@example.com', '010-1000-0003', '2024-02-02', 'ACTIVE'),
(4, '최지우', 'jiwoo.choi@example.com', '010-1000-0004', '2024-02-20', 'ACTIVE'),
(5, '정하준', 'hajun.jung@example.com', '010-1000-0005', '2024-03-05', 'SUSPENDED'),
(6, '강하린', 'harin.kang@example.com', '010-1000-0006', '2024-03-22', 'ACTIVE'),
(7, '조은우', 'eunwoo.cho@example.com', '010-1000-0007', '2024-04-08', 'ACTIVE'),
(8, '윤서준', 'seojun.yoon@example.com', '010-1000-0008', '2024-04-25', 'ACTIVE'),
(9, '임수아', 'sua.lim@example.com', '010-1000-0009', '2024-05-10', 'ACTIVE'),
(10, '한지민', 'jimin.han@example.com', '010-1000-0010', '2024-05-28', 'ACTIVE');

INSERT INTO category (category_id, name, description) VALUES
(1, 'Database', 'SQL and database design'),
(2, 'Backend', 'Server-side development'),
(3, 'Frontend', 'HTML, CSS, JavaScript'),
(4, 'AI', 'Artificial intelligence and machine learning'),
(5, 'DevOps', 'Linux, cloud, and infrastructure'),
(6, 'Algorithm', 'Data structures and algorithms'),
(7, 'Security', 'Information security and secure coding'),
(8, 'Design', 'UX/UI and product design'),
(9, 'Business', 'Startup and business strategy'),
(10, 'Communication', 'Writing and collaboration');

INSERT INTO book (book_id, category_id, title, author, published_year, isbn, price, stock, created_at) VALUES
(1, 1, 'SQL 첫걸음', '아사이 아츠시', 2020, '978-89-001-0001', 23000, 3, '2024-01-01'),
(2, 1, '관계형 데이터베이스 설계', '박성훈', 2022, '978-89-001-0002', 32000, 2, '2024-01-03'),
(3, 2, 'FastAPI 실전 입문', '김지훈', 2023, '978-89-001-0003', 28000, 4, '2024-01-05'),
(4, 2, '백엔드 개발 패턴', '이도현', 2021, '978-89-001-0004', 35000, 2, '2024-01-10'),
(5, 3, '모던 JavaScript', '최유진', 2022, '978-89-001-0005', 30000, 5, '2024-01-12'),
(6, 3, 'HTML CSS 웹 표준', '정민서', 2019, '978-89-001-0006', 22000, 6, '2024-01-15'),
(7, 4, '머신러닝 기본기', '강태오', 2023, '978-89-001-0007', 36000, 2, '2024-01-20'),
(8, 4, '딥러닝과 수학', '윤하늘', 2024, '978-89-001-0008', 42000, 1, '2024-01-22'),
(9, 5, '리눅스 운영 실무', '문서준', 2021, '978-89-001-0009', 27000, 3, '2024-02-01'),
(10, 5, 'AWS 클라우드 기초', '오지호', 2022, '978-89-001-0010', 31000, 2, '2024-02-03'),
(11, 6, '자료구조와 알고리즘', '남태현', 2020, '978-89-001-0011', 34000, 4, '2024-02-08'),
(12, 7, '웹 보안 입문', '권도영', 2023, '978-89-001-0012', 29000, 2, '2024-02-10'),
(13, 8, 'UX 리서치 노트', '홍세라', 2021, '978-89-001-0013', 25000, 2, '2024-02-15'),
(14, 9, '스타트업 지표 읽기', '신유나', 2024, '978-89-001-0014', 26000, 3, '2024-02-18'),
(15, 10, '개발자를 위한 글쓰기', '백은지', 2020, '978-89-001-0015', 21000, 5, '2024-02-20');

INSERT INTO rental (rental_id, member_id, book_id, rented_at, due_date, returned_at, status, rental_fee) VALUES
(1, 1, 1, '2024-06-01', '2024-06-15', '2024-06-12', 'RETURNED', 1200),
(2, 1, 3, '2024-06-05', '2024-06-19', NULL, 'RENTED', 0),
(3, 2, 2, '2024-06-07', '2024-06-21', '2024-06-20', 'RETURNED', 1500),
(4, 2, 5, '2024-06-10', '2024-06-24', NULL, 'RENTED', 0),
(5, 3, 7, '2024-06-12', '2024-06-26', NULL, 'OVERDUE', 3000),
(6, 3, 8, '2024-06-15', '2024-06-29', NULL, 'RENTED', 0),
(7, 4, 9, '2024-06-18', '2024-07-02', NULL, 'RENTED', 0),
(8, 4, 10, '2024-06-20', '2024-07-04', NULL, 'RENTED', 0),
(9, 5, 11, '2024-06-21', '2024-07-05', NULL, 'RENTED', 0),
(10, 6, 12, '2024-06-22', '2024-07-06', NULL, 'RENTED', 0),
(11, 6, 13, '2024-06-25', '2024-07-09', '2024-07-08', 'RETURNED', 1000),
(12, 7, 14, '2024-06-26', '2024-07-10', NULL, 'RENTED', 0),
(13, 7, 15, '2024-06-28', '2024-07-12', NULL, 'RENTED', 0),
(14, 8, 4, '2024-07-01', '2024-07-15', NULL, 'RENTED', 0),
(15, 8, 6, '2024-07-02', '2024-07-16', NULL, 'RENTED', 0),
(16, 9, 1, '2024-07-03', '2024-07-17', NULL, 'RENTED', 0),
(17, 9, 2, '2024-07-04', '2024-07-18', NULL, 'RENTED', 0),
(18, 1, 7, '2024-07-05', '2024-07-19', NULL, 'OVERDUE', 5000),
(19, 2, 8, '2024-07-06', '2024-07-20', NULL, 'RENTED', 0),
(20, 3, 9, '2024-07-07', '2024-07-21', NULL, 'RENTED', 0);
