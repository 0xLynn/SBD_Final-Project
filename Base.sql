CREATE DATABASE stockflow;

USE stockflow;

CREATE TABLE Supplier (
    supplierID INT PRIMARY KEY NOT NULL ,
    supplierName VARCHAR(80) NOT NULL,
    supplierAddress VARCHAR(255) NOT NULL,
    supplierContactNum VARCHAR(20) NOT NULL
);

CREATE TABLE Customer (
    customerID INT PRIMARY KEY NOT NULL,
    customerName VARCHAR(80) NOT NULL,
    customerAddress VARCHAR(255) NOT NULL,
    customerContactNum VARCHAR(20) NOT NULL
);

CREATE TABLE Employee (
    employeeID INT PRIMARY KEY NOT NULL,
    employeeName VARCHAR(80) NOT NULL,
    employeeAddress VARCHAR(255) NOT NULL,
    employeeContactNum VARCHAR(20) NOT NULL,
    employeeRole VARCHAR(20) NOT NULL
);

CREATE TABLE Product (
    productID INT PRIMARY KEY NOT NULL,
    productName VARCHAR(100) NOT NULL,
    productDesc VARCHAR(255) NOT NULL,
    productSerialNum VARCHAR(80) NOT NULL,
    productBuyPrice DECIMAL(10,2) NOT NULL,
    productSellPrice DECIMAL(10,2) NOT NULL,
    productCategory VARCHAR(20) NOT NULL,
    productStock INT NOT NULL,
    supplierID INT NOT NULL,
    FOREIGN KEY (supplierID) REFERENCES Supplier(supplierID)
);

CREATE TABLE Transaction (
    transactionID INT PRIMARY KEY NOT NULL,
    invoiceNumber VARCHAR(80) NOT NULL,
    transactionQty INT NOT NULL,
    transactionDate DATE NOT NULL,
    transactionType VARCHAR(20) NOT NULL,
    productID INT NOT NULL,
    customerID INT NOT NULL,
    employeeID INT NOT NULL,
    FOREIGN KEY (productID) REFERENCES Product(productID),
    FOREIGN KEY (customerID) REFERENCES Customer(customerID),
    FOREIGN KEY (employeeID) REFERENCES Employee(employeeID)
);
