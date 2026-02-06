DROP DATABASE IF EXISTS StudentDB;
CREATE DATABASE StudentDB;
USE StudentDB;

CREATE TABLE STUDENT (
    regno VARCHAR(20) PRIMARY KEY,
    name VARCHAR(50),
    major VARCHAR(50),
    bdate DATE
);

CREATE TABLE COURSE (
    course INT PRIMARY KEY,
    cname VARCHAR(50),
    dept VARCHAR(50)
);

CREATE TABLE ENROLL (
    regno VARCHAR(20),
    course INT,
    sem INT,
    marks INT,
    PRIMARY KEY (regno, course, sem),
    FOREIGN KEY (regno) REFERENCES STUDENT(regno) ON DELETE CASCADE,
    FOREIGN KEY (course) REFERENCES COURSE(course) ON DELETE CASCADE
);

CREATE TABLE TEXT (
    book_isbn INT PRIMARY KEY,
    book_title VARCHAR(100),
    publisher VARCHAR(50),
    author VARCHAR(50)
);

CREATE TABLE BOOK_ADOPTION (
    course INT,
    sem INT,
    book_isbn INT,
    PRIMARY KEY (course, sem, book_isbn),
    FOREIGN KEY (course) REFERENCES COURSE(course) ON DELETE CASCADE,
    FOREIGN KEY (book_isbn) REFERENCES TEXT(book_isbn) ON DELETE CASCADE
);

INSERT INTO STUDENT VALUES
('S1','Amit','CS','2003-05-10'),
('S2','Ravi','CS','2003-08-12'),
('S3','Neha','EC','2003-02-15'),
('S4','Kiran','ME','2002-11-20'),
('S5','Anu','CS','2003-01-30');

INSERT INTO COURSE VALUES
(101,'DBMS','CS'),
(102,'OS','CS'),
(103,'Networks','CS'),
(201,'VLSI','EC'),
(301,'Thermodynamics','ME');

INSERT INTO TEXT VALUES
(1001,'Database System Concepts','McGrawHill','Silberschatz'),
(1002,'Fundamentals of DBMS','Pearson','Elmasri'),
(1003,'Operating Systems','Pearson','Galvin'),
(1004,'Computer Networks','Pearson','Tanenbaum'),
(1005,'Advanced DBMS','McGrawHill','Date');

INSERT INTO BOOK_ADOPTION VALUES
(101,5,1001),
(101,5,1002),
(101,5,1005),
(102,5,1003),
(103,6,1004);

INSERT INTO ENROLL VALUES
('S1',101,5,85),
('S2',101,5,92),
('S3',101,5,78),
('S4',301,5,65),
('S5',101,5,92);

INSERT INTO TEXT VALUES
(1006,'Distributed Databases','Pearson','Ozsu');

INSERT INTO BOOK_ADOPTION VALUES
(103,6,1006);

SELECT course, book_isbn, book_title
FROM BOOK_ADOPTION
JOIN COURSE USING (course)
JOIN TEXT USING (book_isbn)
WHERE dept = 'CS'
  AND course IN (
        SELECT course
        FROM BOOK_ADOPTION
        GROUP BY course
        HAVING COUNT(*) > 2
  )
ORDER BY book_title;


SELECT C.dept
FROM COURSE C
WHERE NOT EXISTS (
    SELECT *
    FROM BOOK_ADOPTION BA
    JOIN TEXT T ON BA.book_isbn = T.book_isbn
    WHERE BA.course = C.course
    AND T.publisher <> 'Pearson'
);

SELECT S.regno, S.name
FROM STUDENT S
JOIN ENROLL E ON S.regno = E.regno
JOIN COURSE C ON E.course = C.course
WHERE C.cname = 'DBMS'
AND E.marks = (
    SELECT MAX(marks)
    FROM ENROLL
    WHERE course = C.course
);

CREATE VIEW Student_Course_Marks AS
SELECT S.regno, S.name, C.cname, E.marks
FROM STUDENT S
JOIN ENROLL E ON S.regno = E.regno
JOIN COURSE C ON E.course = C.course;

DELIMITER //

CREATE TRIGGER prevent_low_marks_enroll
BEFORE INSERT ON ENROLL
FOR EACH ROW
BEGIN
    IF NEW.marks < 40 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Enrollment not allowed: marks less than 40';
    END IF;
END//

DELIMITER ;
