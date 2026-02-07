CREATE DATABASE SailorsDB;
USE SailorsDB;

CREATE TABLE SAILORS (
    sid INT PRIMARY KEY,
    sname VARCHAR(50),
    rating INT,
    age INT
);

CREATE TABLE BOAT (
    bid INT PRIMARY KEY,
    bname VARCHAR(50),
    color VARCHAR(30)
);

CREATE TABLE RSERVERS (
    sid INT,
    bid INT,
    date DATE,
    PRIMARY KEY (sid, bid, date),
    FOREIGN KEY (sid) REFERENCES SAILORS(sid),
    FOREIGN KEY (bid) REFERENCES BOAT(bid)
);

INSERT INTO SAILORS VALUES
(1,'Albert',9,45),
(2,'Bob',7,38),
(3,'Charlie',8,50),
(4,'David',6,42),
(5,'Evan',10,60);

INSERT INTO BOAT VALUES
(101,'StormBreaker','Red'),
(102,'SeaQueen','Blue'),
(103,'WaveRider','Green'),
(104,'ThunderStorm','Black'),
(105,'OceanKing','White');

INSERT INTO RSERVERS VALUES
(1,101,'2025-01-10'),
(1,103,'2025-01-12'),
(2,102,'2025-01-11'),
(3,103,'2025-01-15'),
(4,104,'2025-01-18'),
(5,101,'2025-01-20'),
(5,102,'2025-01-22'),
(5,103,'2025-01-25'),
(5,104,'2025-01-27'),
(5,105,'2025-01-30');

SELECT DISTINCT B.color
FROM BOAT B
JOIN RSERVERS R ON B.bid = R.bid
JOIN SAILORS S ON S.sid = R.sid
WHERE S.sname = 'Albert';

SELECT sid FROM SAILORS WHERE rating >= 8
UNION
SELECT sid FROM RSERVERS WHERE bid = 103;

SELECT sname
FROM SAILORS
WHERE sid NOT IN (
    SELECT R.sid
    FROM RSERVERS R
    JOIN BOAT B ON R.bid = B.bid
    WHERE B.bname LIKE '%storm%'
)
ORDER BY sname;

SELECT S.sname
FROM SAILORS S
WHERE NOT EXISTS (
    SELECT B.bid
    FROM BOAT B
    WHERE NOT EXISTS (
        SELECT 1
        FROM RSERVERS R
        WHERE R.sid = S.sid AND R.bid = B.bid
    )
);

SELECT sname, age
FROM SAILORS
WHERE age = (SELECT MAX(age) FROM SAILORS);

SELECT R.bid, AVG(S.age) AS avg_age
FROM RSERVERS R
JOIN SAILORS S ON R.sid = S.sid
WHERE S.age >= 40
GROUP BY R.bid
HAVING COUNT(DISTINCT R.sid) >= 5;

CREATE VIEW Boat_By_Rating AS
SELECT DISTINCT B.bname, B.color
FROM BOAT B
JOIN RSERVERS R ON B.bid = R.bid
JOIN SAILORS S ON S.sid = R.sid
WHERE S.rating = 8;

DELIMITER //

CREATE TRIGGER prevent_boat_delete
BEFORE DELETE ON BOAT
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM RSERVERS WHERE bid = OLD.bid) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Boat has active reservations';
    END IF;
END //

DELIMITER ;
