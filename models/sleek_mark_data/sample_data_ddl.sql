CREATE DATABASE SLEEKMART_OMS;

CREATE SCHEMA L1_LANDING;

CREATE SCHEMA L2_PROCESSING;

CREATE SCHEMA L3_CONSUMPTION;

USE database SLEEKMART_OMS;

USE SCHEMA L1_LANDING;

CREATE TABLE IF NOT EXISTS Dates (
Date DATE NOT NULL,
Day VARCHAR(3) NULL,
Month VARCHAR(10) NULL,
Year VARCHAR(4) NULL,
Quarter INT NULL,
DayOfWeek VARCHAR(10) NULL,
WeekOfYear INT NULL,
Updated_at TIMESTAMP NULL,
PRIMARY KEY (Date));

-- Sample data for Dates table
INSERT INTO Dates (Date, Day, Month, Year, Quarter, DayOfWeek, WeekOfYear, Updated_at) VALUES
('2024-01-01', 'Mon', 'January', '2024', 1, 'Monday', 1, '2024-08-01 10:00:00'),
('2024-01-02', 'Tue', 'January', '2024', 1, 'Tuesday', 1, '2024-08-01 10:00:00'),
('2024-01-03', 'Wed', 'January', '2024', 1, 'Wednesday', 1, '2024-08-01 10:00:00'),
('2024-01-04', 'Thu', 'January', '2024', 1, 'Thursday', 1, '2024-08-01 10:00:00'),
('2024-01-05', 'Fri', 'January', '2024', 1, 'Friday', 1, '2024-08-01 10:00:00');



CREATE TABLE IF NOT EXISTS customers (
CustomerID VARCHAR(10),
FirstName VARCHAR(50),
LastName VARCHAR(50),
Email VARCHAR(100),
Phone VARCHAR(100),
Address VARCHAR(100),
City VARCHAR(50),
State VARCHAR(2),
ZipCode VARCHAR(10),
Updated_at TIMESTAMP);

-- Sample data for customers table
INSERT INTO customers (CustomerID, FirstName, LastName, Email, Phone, Address, City, State, ZipCode, Updated_at) VALUES
('C001', 'John', 'Doe', 'john.doe@example.com', '555-0100', '123 Main St', 'Springfield', 'IL', '62701', '2024-08-01 10:00:00'),
('C002', 'Jane', 'Smith', 'jane.smith@example.com', '555-0101', '456 Oak St', 'Springfield', 'IL', '62702', '2024-08-01 10:00:00'),
('C003', 'Alice', 'Johnson', 'alice.johnson@example.com', '555-0102', '789 Pine St', 'Springfield', 'IL', '62703', '2024-08-01 10:00:00'),
('C004', 'Bob', 'Brown', 'bob.brown@example.com', '555-0103', '101 Maple St', 'Springfield', 'IL', '62704', '2024-08-01 10:00:00'),
('C005', 'Charlie', 'Davis', 'charlie.davis@example.com', '555-0104', '202 Birch St', 'Springfield', 'IL', '62705', '2024-08-01 10:00:00');



CREATE TABLE IF NOT EXISTS Employees (
EmployeeID INT NOT NULL,
FirstName VARCHAR(100) NULL,
LastName VARCHAR(100) NULL,
Email VARCHAR(200) NULL,
JobTitle VARCHAR(100) NULL,
HireDate DATE NULL,
ManagerID INT NULL,
Address VARCHAR(200) NULL,
City VARCHAR(50) NULL,
State VARCHAR(50) NULL,
ZipCode VARCHAR(10) NULL,
Updated_at TIMESTAMP NULL,
PRIMARY KEY (EmployeeID));


-- Sample data for Employees table
INSERT INTO Employees (EmployeeID, FirstName, LastName, Email, JobTitle, HireDate, ManagerID, Address, City, State, ZipCode, Updated_at) VALUES
(1, 'Tom', 'Hanks', 'tom.hanks@example.com', 'Manager', '2022-01-15', NULL, '101 Maple St', 'Springfield', 'IL', '62701', '2024-08-01 10:00:00'),
(2, 'Emma', 'Watson', 'emma.watson@example.com', 'Sales Associate', '2023-02-20', 1, '202 Birch St', 'Springfield', 'IL', '62702', '2024-08-01 10:00:00'),
(3, 'Mark', 'Smith', 'mark.smith@example.com', 'Developer', '2021-03-10', 1, '303 Cedar St', 'Springfield', 'IL', '62703', '2024-08-01 10:00:00'),
(4, 'Lucy', 'Williams', 'lucy.williams@example.com', 'HR', '2020-04-25', 1, '404 Oak St', 'Springfield', 'IL', '62704', '2024-08-01 10:00:00'),
(5, 'David', 'Jones', 'david.jones@example.com', 'Support', '2019-05-30', 2, '505 Pine St', 'Springfield', 'IL', '62705', '2024-08-01 10:00:00');


CREATE TABLE IF NOT EXISTS Stores (
StoreID INT NOT NULL,
StoreName VARCHAR(100) NULL,
Address VARCHAR(200) NULL,
City VARCHAR(50) NULL,
State VARCHAR(50) NULL,
ZipCode VARCHAR(10) NULL,
Email VARCHAR(200) NULL,
Phone VARCHAR(50) NULL,
Updated_at TIMESTAMP NULL,
PRIMARY KEY (StoreID));

-- Sample data for Stores table
INSERT INTO Stores (StoreID, StoreName, Address, City, State, ZipCode, Email, Phone, Updated_at) VALUES
(1, 'Main Street Store', '111 Main St', 'Springfield', 'IL', '62701', 'mainstore@example.com', '555-0120', '2024-08-01 10:00:00'),
(2, 'Downtown Store', '222 Elm St', 'Springfield', 'IL', '62702', 'downtownstore@example.com', '555-0121', '2024-08-01 10:00:00'),
(3, 'Eastside Store', '333 Oak St', 'Springfield', 'IL', '62703', 'eastsidestore@example.com', '555-0122', '2024-08-01 10:00:00'),
(4, 'Westside Store', '444 Birch St', 'Springfield', 'IL', '62704', 'westsidestore@example.com', '555-0123', '2024-08-01 10:00:00'),
(5, 'Southside Store', '555 Cedar St', 'Springfield', 'IL', '62705', 'southsidestore@example.com', '555-0124', '2024-08-01 10:00:00');


CREATE TABLE IF NOT EXISTS Suppliers (
SupplierID INT NOT NULL,
SupplierName VARCHAR(100) NULL,
ContactPerson VARCHAR(100) NULL,
Email VARCHAR(200) NULL,
Phone VARCHAR(50) NULL,
Address VARCHAR(50) NULL,
City VARCHAR(50) NULL,
State VARCHAR(10) NULL,
ZipCode VARCHAR(10) NULL,
Updated_at TIMESTAMP NULL,
PRIMARY KEY (SupplierID));

-- Sample data for Suppliers table
INSERT INTO Suppliers (SupplierID, SupplierName, ContactPerson, Email, Phone, Address, City, State, ZipCode, Updated_at) VALUES
(1, 'ABC Supplies', 'Robert Brown', 'robert.brown@abc.com', '555-0130', '123 Supply St', 'Springfield', 'IL', '62701', '2024-08-01 10:00:00'),
(2, 'XYZ Corp', 'Susan Green', 'susan.green@xyz.com', '555-0131', '456 Warehouse St', 'Springfield', 'IL', '62702', '2024-08-01 10:00:00'),
(3, '123 Distributors', 'Nancy White', 'nancy.white@123.com', '555-0132', '789 Distribution St', 'Springfield', 'IL', '62703', '2024-08-01 10:00:00'),
(4, 'Tech Supplies', 'James Black', 'james.black@tech.com', '555-0133', '101 Tech St', 'Springfield', 'IL', '62704', '2024-08-01 10:00:00'),
(5, 'Home Supplies', 'Michael Blue', 'michael.blue@home.com', '555-0134', '202 Home St', 'Springfield', 'IL', '62705', '2024-08-01 10:00:00');


CREATE TABLE IF NOT EXISTS Products (
ProductID INT NOT NULL,
Name VARCHAR(100) NULL,
Category VARCHAR(100) NULL,
RetailPrice DECIMAL(10,2) NULL,
SupplierPrice DECIMAL(10,2) NULL,
SupplierID INT NULL,
Updated_at TIMESTAMP NULL,
PRIMARY KEY (ProductID));

-- Sample data for Products table
INSERT INTO Products (ProductID, Name, Category, RetailPrice, SupplierPrice, SupplierID, Updated_at) VALUES
(1, 'Laptop', 'Electronics', 999.99, 800.00, 1, '2024-08-01 10:00:00'),
(2, 'Smartphone', 'Electronics', 699.99, 500.00, 2, '2024-08-01 10:00:00'),
(3, 'Tablet', 'Electronics', 499.99, 350.00, 3, '2024-08-01 10:00:00'),
(4, 'Monitor', 'Electronics', 199.99, 150.00, 4, '2024-08-01 10:00:00'),
(5, 'Keyboard', 'Electronics', 49.99, 30.00, 5, '2024-08-01 10:00:00');


CREATE TABLE IF NOT EXISTS OrderItems (
OrderItemID INT NOT NULL,
OrderID INT NULL,
ProductID INT NULL,
Quantity INT NULL,
UnitPrice DECIMAL(10,2) NULL,
Updated_at TIMESTAMP NULL,
PRIMARY KEY (OrderItemID));

-- Sample data for OrderItems table
INSERT INTO OrderItems (OrderItemID, OrderID, ProductID, Quantity, UnitPrice, Updated_at) VALUES
(1, 1, 1, 1, 999.99, '2024-08-01 10:00:00'),
(2, 2, 2, 1, 699.99, '2024-08-01 10:00:00'),
(3, 3, 3, 2, 499.99, '2024-08-01 10:00:00'),
(4, 4, 4, 1, 199.99, '2024-08-01 10:00:00'),
(5, 5, 5, 3, 49.99, '2024-08-01 10:00:00');


CREATE OR REPLACE TABLE Orders (
OrderID INT NOT NULL,
OrderDate DATE NULL,
CustomerID VARCHAR NULL,
EmployeeID INT NULL,
StoreID INT NULL,
Status VARCHAR(10) NULL,
Updated_at TIMESTAMP NULL,
PRIMARY KEY (OrderID));

-- Sample data for Orders table
INSERT INTO Orders (OrderID, OrderDate, CustomerID, EmployeeID, StoreID, Status, Updated_at) VALUES
(1, '2024-07-15', 'C001', 1, 1, 'Shipped', '2024-08-01 10:00:00'),
(2, '2024-07-16', 'C002', 2, 2, 'Pending', '2024-08-01 10:00:00'),
(3, '2024-07-17', 'C003', 3, 3, 'Delivered', '2024-08-01 10:00:00'),
(4, '2024-07-18', 'C004', 4, 4, 'Processing', '2024-08-01 10:00:00'),
(5, '2024-07-19', 'C005', 5, 5, 'Cancelled', '2024-08-01 10:00:00');

select * from sleekmart_oms.l1_landing.Dates;
select * from sleekmart_oms.l1_landing.customers;
select * from sleekmart_oms.l1_landing.Employees;
select * from sleekmart_oms.l1_landing.Stores;
select * from sleekmart_oms.l1_landing.Suppliers;
select * from sleekmart_oms.l1_landing.Products;
select * from sleekmart_oms.l1_landing.Orders;
select * from sleekmart_oms.l1_landing.OrderItems; 

truncate table sleekmart_oms.l1_landing.Dates;
truncate table sleekmart_oms.l1_landing.customers;
truncate table sleekmart_oms.l1_landing.Employees;
truncate table sleekmart_oms.l1_landing.Stores;
truncate table sleekmart_oms.l1_landing.Suppliers;
truncate table sleekmart_oms.l1_landing.Products;
truncate table sleekmart_oms.l1_landing.Orders;
truncate table sleekmart_oms.l1_landing.OrderItems; 

select * from PUGAZH_DB.dbt_pv.customer_order_data;
select * from PUGAZH_DB.dbt_pv.customer_stg;
