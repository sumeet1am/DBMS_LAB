CREATE DATABASE IF NOT EXISTS Order_Processing;
USE Order_Processing;

DROP TABLE IF EXISTS OrderItem;
DROP TABLE IF EXISTS Shipment;
DROP TABLE IF EXISTS OrderTable;
DROP TABLE IF EXISTS Item;
DROP TABLE IF EXISTS Warehouse;
DROP TABLE IF EXISTS Customer;

CREATE TABLE Customer (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    city VARCHAR(100)
);

CREATE TABLE OrderTable (
    order_id INT PRIMARY KEY,
    order_date DATE,
    customer_id INT,
    order_amount INT,
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id) ON DELETE CASCADE
);

CREATE TABLE Item (
    item_id INT PRIMARY KEY,
    unit_price INT
);

CREATE TABLE OrderItem (
    order_id INT,
    item_id INT,
    quantity INT,
    FOREIGN KEY (order_id) REFERENCES OrderTable(order_id) ON DELETE CASCADE,
    FOREIGN KEY (item_id) REFERENCES Item(item_id) ON DELETE CASCADE
);

CREATE TABLE Warehouse (
    warehouse_id INT PRIMARY KEY,
    city VARCHAR(100)
);

CREATE TABLE Shipment (
    order_id INT,
    warehouse_id INT,
    ship_date DATE,
    FOREIGN KEY (order_id) REFERENCES OrderTable(order_id) ON DELETE CASCADE,
    FOREIGN KEY (warehouse_id) REFERENCES Warehouse(warehouse_id) ON DELETE CASCADE
);

INSERT INTO Customer VALUES
(101, 'Kumar', 'City1'),
(102, 'Peter', 'City2'),
(103, 'James', 'City3'),
(104, 'Kevin', 'City4'),
(105, 'Harry', 'City5');

INSERT INTO OrderTable VALUES
(201, '2025-01-11', 101, 1567),
(202, '2025-02-12', 102, 2567),
(203, '2025-03-13', 103, 3567),
(204, '2025-04-14', 104, 4567),
(205, '2025-05-15', 105, 5567);

INSERT INTO Item VALUES
(1001, 100),
(1002, 200),
(1003, 300),
(1004, 400),
(1005, 500);

INSERT INTO OrderItem VALUES
(201, 1001, 10),
(202, 1002, 11),
(203, 1003, 12),
(204, 1004, 13),
(205, 1005, 14);

INSERT INTO Warehouse VALUES
(1, 'Wcity1'),
(2, 'Wcity2'),
(3, 'Wcity3'),
(4, 'Wcity4'),
(5, 'Wcity5');

INSERT INTO Shipment VALUES
(201, 1, '2025-01-20'),
(202, 2, '2025-02-21'),
(203, 3, '2025-03-22'),
(204, 4, '2025-04-23'),
(205, 5, '2025-05-24');

SELECT order_id, ship_date
FROM Shipment
WHERE warehouse_id = 2;

SELECT o.order_id, s.warehouse_id
FROM OrderTable o
JOIN Shipment s ON o.order_id = s.order_id
JOIN Customer c ON o.customer_id = c.customer_id
WHERE c.customer_name = 'Kumar';

SELECT customer_name,
COUNT(order_id) AS number_of_orders,
AVG(order_amount) AS average_order_amount
FROM Customer c
JOIN OrderTable o ON c.customer_id = o.customer_id
GROUP BY customer_name;

DELETE FROM OrderTable
WHERE customer_id = (
    SELECT customer_id FROM Customer WHERE customer_name = 'Kumar'
);

SELECT item_id, unit_price
FROM Item
WHERE unit_price = (SELECT MAX(unit_price) FROM Item);

DELIMITER //

CREATE TRIGGER UpdateOrderAmount
BEFORE INSERT ON OrderItem
FOR EACH ROW
BEGIN
    UPDATE OrderTable
    SET order_amount = NEW.quantity * (
        SELECT unit_price FROM Item WHERE item_id = NEW.item_id
    )
    WHERE order_id = NEW.order_id;
END//

DELIMITER ;

INSERT INTO Item VALUES (1006, 600);
INSERT INTO OrderTable VALUES (206, '2025-06-16', 102, NULL);
INSERT INTO OrderItem VALUES (206, 1006, 5);

SELECT * FROM OrderTable;

CREATE OR REPLACE VIEW OrdersFromWarehouse5 AS
SELECT order_id, ship_date
FROM Shipment
WHERE warehouse_id = 5;

SELECT * FROM OrdersFromWarehouse5;
