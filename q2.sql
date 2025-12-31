CREATE DATABASE InsuranceDB;
USE InsuranceDB;

CREATE TABLE PERSON (
    driver_id VARCHAR(20) PRIMARY KEY,
    name VARCHAR(50),
    address VARCHAR(100)
);

CREATE TABLE CAR (
    regno VARCHAR(20) PRIMARY KEY,
    model VARCHAR(50),
    year INT
);

CREATE TABLE ACCIDENT (
    report_number INT PRIMARY KEY,
    acc_date DATE,
    location VARCHAR(100)
);

CREATE TABLE OWNS (
    driver_id VARCHAR(20),
    regno VARCHAR(20),
    PRIMARY KEY (driver_id, regno),
    FOREIGN KEY (driver_id) REFERENCES PERSON(driver_id),
    FOREIGN KEY (regno) REFERENCES CAR(regno)
);

CREATE TABLE PARTICIPATED (
    driver_id VARCHAR(20),
    regno VARCHAR(20),
    report_number INT,
    damage_amount INT,
    PRIMARY KEY (driver_id, regno, report_number),
    FOREIGN KEY (driver_id) REFERENCES PERSON(driver_id),
    FOREIGN KEY (regno) REFERENCES CAR(regno),
    FOREIGN KEY (report_number) REFERENCES ACCIDENT(report_number)
);

INSERT INTO PERSON VALUES
('D1','Smith','Bangalore'),
('D2','John','Mysore'),
('D3','Alice','Chennai'),
('D4','Bob','Hyderabad'),
('D5','David','Pune');

INSERT INTO CAR VALUES
('KA09MA1234','Mazda',2019),
('KA01AB1111','Honda',2018),
('KA02CD2222','Toyota',2020),
('KA03EF3333','Hyundai',2021),
('KA04GH4444','Ford',2017);

INSERT INTO ACCIDENT VALUES
(1001,'2021-03-15','Bangalore'),
(1002,'2021-07-10','Mysore'),
(1003,'2020-11-05','Chennai'),
(1004,'2021-12-20','Hyderabad'),
(1005,'2022-01-08','Pune');

INSERT INTO OWNS VALUES
('D1','KA09MA1234'),
('D1','KA01AB1111'),
('D2','KA02CD2222'),
('D3','KA03EF3333'),
('D4','KA04GH4444');

INSERT INTO PARTICIPATED VALUES
('D1','KA09MA1234',1001,5000),
('D1','KA01AB1111',1002,3000),
('D2','KA02CD2222',1002,4000),
('D3','KA03EF3333',1003,2500),
('D4','KA04GH4444',1004,6000);

SELECT COUNT(DISTINCT O.driver_id)
FROM OWNS O
JOIN PARTICIPATED P ON O.regno = P.regno
JOIN ACCIDENT A ON P.report_number = A.report_number
WHERE YEAR(A.acc_date) = 2021;

SELECT COUNT(*)
FROM PARTICIPATED P
JOIN OWNS O ON P.regno = O.regno
JOIN PERSON S ON O.driver_id = S.driver_id
WHERE S.name = 'Smith';

INSERT INTO ACCIDENT VALUES
(1006,'2021-08-18','Tumkur');

DELETE FROM CAR
WHERE regno IN (
    SELECT regno FROM OWNS
    WHERE driver_id = (SELECT driver_id FROM PERSON WHERE name='Smith')
) AND model='Mazda';

UPDATE PARTICIPATED
SET damage_amount = 8000
WHERE regno='KA09MA1234' AND report_number=1001;

CREATE VIEW Accident_Car_Details AS
SELECT DISTINCT C.model, C.year
FROM CAR C
JOIN PARTICIPATED P ON C.regno = P.regno;

DELIMITER $$

CREATE TRIGGER limit_accidents_per_year
BEFORE INSERT ON PARTICIPATED
FOR EACH ROW
BEGIN
    IF (
        SELECT COUNT(*)
        FROM PARTICIPATED P
        JOIN ACCIDENT A ON P.report_number = A.report_number
        WHERE P.driver_id = NEW.driver_id
        AND YEAR(A.acc_date) = (
            SELECT YEAR(acc_date)
            FROM ACCIDENT
            WHERE report_number = NEW.report_number
        )
    ) >= 3 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Driver cannot participate in more than 3 accidents in a year';
    END IF;
END$$

DELIMITER ;
