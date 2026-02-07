DROP DATABASE IF EXISTS OrderProcessingDB;
CREATE DATABASE OrderProcessingDB;
USE OrderProcessingDB;

CREATE TABLE Customer (
    cust INT PRIMARY KEY,
    cname VARCHAR(50),
    city VARCHAR(50)
);

CREATE TABLE Item (
    item INT PRIMARY KEY,
    unitprice INT
);

CREATE TABLE Order_ (
    order_ INT PRIMARY KEY,
    odate DATE,
    cust INT,
    order_amt INT DEFAULT 0,
    FOREIGN KEY (cust) REFERENCES Customer(cust) ON DELETE CASCADE
);

CREATE TABLE OrderItem (
    order_ INT,
    item INT,
    qty INT,
    PRIMARY KEY (order_, item),
    FOREIGN KEY (order_) REFERENCES Order_(order_) ON DELETE CASCADE,
    FOREIGN KEY (item) REFERENCES Item(item)
);

CREATE TABLE Warehouse (
    warehouse INT PRIMARY KEY,
    city VARCHAR(50)
);

CREATE TABLE Shipment (
    order_ INT,
    warehouse INT,
    ship_date DATE,
    PRIMARY KEY (order_, warehouse),
    FOREIGN KEY (order_) REFERENCES Order_(order_) ON DELETE CASCADE,
    FOREIGN KEY (warehouse) REFERENCES Warehouse(warehouse)
);

INSERT INTO Customer VALUES
(1,'Kumar','Bangalore'),
(2,'Ravi','Chennai'),
(3,'Anil','Hyderabad'),
(4,'Suresh','Pune'),
(5,'Mahesh','Mysore');

INSERT INTO Item VALUES
(101,500),
(102,1200),
(103,800),
(104,1500),
(105,300);

INSERT INTO Order_ VALUES
(1001,'2025-01-10',1,0),
(1002,'2025-01-12',1,0),
(1003,'2025-01-15',2,0),
(1004,'2025-01-18',3,0),
(1005,'2025-01-20',4,0);

INSERT INTO OrderItem VALUES
(1001,101,2),
(1001,102,1),
(1002,103,3),
(1003,104,1),
(1004,105,5);

INSERT INTO Warehouse VALUES
(1,'Bangalore'),
(2,'Chennai'),
(3,'Hyderabad'),
(4,'Pune'),
(5,'Delhi');

INSERT INTO Shipment VALUES
(1001,2,'2025-01-11'),
(1002,1,'2025-01-13'),
(1003,2,'2025-01-16'),
(1004,3,'2025-01-19'),
(1005,5,'2025-01-21');

SELECT order_, ship_date
FROM Shipment
WHERE warehouse = 2;

SELECT O.order_, S.warehouse
FROM Order_ O
JOIN Shipment S ON O.order_ = S.order_
JOIN Customer C ON O.cust = C.cust
WHERE C.cname = 'Kumar';

SELECT C.cname, COUNT(O.order_) AS no_of_orders, AVG(O.order_amt) AS avg_order_amt
FROM Customer C
JOIN Order_ O ON C.cust = O.cust
GROUP BY C.cname;

DELETE FROM Order_
WHERE cust = (SELECT cust FROM Customer WHERE cname='Kumar');

SELECT item
FROM Item
WHERE unitprice = (SELECT MAX(unitprice) FROM Item);

CREATE VIEW Warehouse5_Orders AS
SELECT order_, ship_date
FROM Shipment
WHERE warehouse = 5;

DELIMITER //

CREATE TRIGGER update_order_amount
BEFORE INSERT ON OrderItem
FOR EACH ROW
BEGIN
    UPDATE Order_
    SET order_amt = order_amt +
        (NEW.qty * (SELECT unitprice FROM Item WHERE item = NEW.item))
    WHERE order_ = NEW.order_;
END//

DELIMITER ;
