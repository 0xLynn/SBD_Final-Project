-- View
CREATE VIEW StockflowView AS
SELECT 
    p.productName,
    s.supplierName,
    SUM(t.transactionQty) AS totalQuantity,
    t.transactionType,
    t.transactionDate
FROM 
    Product p
JOIN Supplier s ON p.supplierID = s.supplierID
LEFT JOIN Transaction t ON p.productID = t.productID
WHERE
    p.productStock > 0 
    AND t.transactionType IN ('buy') 
    AND t.transactionDate >= '2023-01-01'
GROUP BY --buat misahin tiap product, if not will sum the entire dataset
    p.productName, s.supplierName, t.transactionType, t.transactionDate
HAVING 
    SUM(t.transactionQty) > 10;

-- Stored Procedure
DELIMITER //

CREATE PROCEDURE stockSummary(IN startDate DATE)
BEGIN
    DECLARE totalProducts INT;

    SELECT COUNT(*) INTO totalProducts FROM Product WHERE productStock > 0;

    SELECT 
        p.productName,
        s.supplierName,
        SUM(t.transactionQty) AS totalQuantity,
        t.transactionType,
        t.transactionDate
    FROM 
        Product p
    JOIN Supplier s ON p.supplierID = s.supplierID
    LEFT JOIN (
        SELECT *
        FROM Transaction
        WHERE transactionDate >= startDate
    ) t ON p.productID = t.productID
    WHERE 
        p.productStock > 0 
        AND t.transactionType IN ('buy') 
        AND t.transactionDate >= '2023-01-01'
    GROUP BY 
        p.productName, s.supplierName, t.transactionType, t.transactionDate
    HAVING 
        SUM(t.transactionQty) > 10
    ORDER BY 
        t.transactionDate;

END //

DELIMITER ;

/*Usage: CALL stockSummary('yyyy-mm-dd');*/

-- Stored Function
DELIMITER //

CREATE FUNCTION maxproductSupplier()
RETURNS VARCHAR(80)
BEGIN
    DECLARE supplierName VARCHAR(80);

    SELECT s.supplierName INTO supplierName
    FROM Supplier s
    JOIN Product p ON s.supplierID = p.supplierID
    GROUP BY s.supplierID, s.supplierName
    ORDER BY COUNT(p.productID) DESC
    LIMIT 1;

    RETURN supplierName;
END //

DELIMITER ;

-- Trigger
CREATE TABLE IF NOT EXISTS ProductAuditLog (
    logID INT AUTO_INCREMENT PRIMARY KEY,
    logTimestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    logMessage VARCHAR(255)
);

DELIMITER //

CREATE TRIGGER ProductInsertAudit
AFTER INSERT ON Product
FOR EACH ROW
BEGIN
    DECLARE productName VARCHAR(100);
    DECLARE supplierName VARCHAR(100);
    DECLARE actionMessage VARCHAR(255);

    SELECT p.productName, s.supplierName
    INTO productName, supplierName
    FROM Product p
    JOIN Supplier s ON p.supplierID = s.supplierID
    WHERE p.productID = NEW.productID;

    SET actionMessage = CONCAT('Product "', productName, '" from supplier "', supplierName, '" inserted.');

    INSERT INTO ProductAuditLog (logTimestamp, logMessage)
    VALUES (NOW(), actionMessage);
END //

DELIMITER ;

--INSERT INTO Product (productID, productName, productDesc, productSerialNum, productBuyPrice, productSellPrice, productCategory, productStock, supplierID) VALUES (1001, 'Bisolvon', 'Buat batuk pilek ngab', '9033578478', 27.8, 44.3, 'Antibiotic', 200, 776);

-- Transaction & Rollback
START TRANSACTION;

UPDATE Product
SET productStock = productStock - 5
WHERE productID = 1001;

INSERT INTO Transaction (invoiceNumber, transactionQty, transactionDate, transactionType, productID, customerID, employeeID)
VALUES ('INV-54321', 5, '2023-01-15', 'buy', 1001, 2, 888);

COMMIT;

SELECT productName, productStock
FROM Product
WHERE productID = 1001;

SELECT *
FROM Transaction
WHERE invoiceNumber = 'INV-54321';

START TRANSACTION;

UPDATE Product
SET productStock = productStock + 5
WHERE productID = 1001;

SELECT productName, productStock
FROM Product
WHERE productID = 1001;

SELECT *
FROM Transaction
WHERE invoiceNumber = 'INV-54321';

ROLLBACK;