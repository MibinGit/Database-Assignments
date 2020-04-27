--Lab5-1
USE "ZHU_MIBIN_TEST";
--DROP FUNCTION dbo.calculateTotalSales;
CREATE FUNCTION dbo.calculateTotalSales(@beginYear INT, @endYear INT, @Month INT)
RETURNS TABLE
AS
RETURN
(
	SELECT ISNULL(SUM(TotalDue), 0) AS TotalDue
	FROM AdventureWorks2008R2.sales.SalesOrderHeader soh
 	WHERE MONTH(soh.DueDate) = @Month AND YEAR(soh.DueDate) >= @beginYear AND YEAR(soh.DueDate) <= @endYear
);
 
SELECT * FROM ZHU_MIBIN_TEST.dbo.calculateTotalSales(2007, 2008, 3);

--Lab5-2
USE "ZHU_MIBIN_TEST";
--DROP TABLE DateRange;
--DROP PROCEDURE storeData;
CREATE TABLE DateRange
(
	DateID INT IDENTITY,
	DateValue DATE,
	Year INT,
	Quarter INT,
	Month INT,
	DayOfWeek INT
);

CREATE PROCEDURE storeData
	@startingDate DATE,
    @consecutiveDays INT
AS
DECLARE @count INT
SET @count = 0;
WHILE(@count < @consecutiveDays)
BEGIN
	SET IDENTITY_INSERT ZHU_MIBIN_TEST.dbo.DateRange OFF;
	INSERT INTO ZHU_MIBIN_TEST.dbo.DateRange
	(
		DateValue,
		Year,
		Quarter,
		Month,
		DayOfWeek
	)
	VALUES
	(
		DATEADD(DAY, @count, @startingDate),
		YEAR(DATEADD(DAY, @count, @startingDate)),
		DATEPART(QUARTER, DATEADD(DAY, @count, @startingDate)),
		MONTH(DATEADD(DAY, @count, @startingDate)),
		DATEPART(WEEKDAY, DATEADD(DAY, @count, @startingDate))
	);
	SET @count = @count + 1;
END;

DECLARE @startingDate DATE
DECLARE @count INT
SET @count = 100
SET @startingDate = '2008-03-23'
EXEC storeData @startingDate, @count;

SELECT * FROM ZHU_MIBIN_TEST.dbo.DateRange;

--Lab5-3 PART1
USE "ZHU_MIBIN_TEST";
--DROP FUNCTION uf_GetCustomerName;
CREATE FUNCTION uf_GetCustomerName(@CustID INT)
RETURNS @tbl TABLE(name VARCHAR(200))
BEGIN
	DECLARE @fullname VARCHAR(200) = '';
	SELECT @fullname = p.FirstName + ' ' + p.LastName
	FROM AdventureWorks2008R2.Sales.Customer c JOIN AdventureWorks2008R2.Person.Person p
	ON c.PersonID = p.BusinessEntityID
	WHERE c.CustomerID = @custID;
	INSERT INTO @tbl VALUES(@fullname);
	RETURN;
END;

SELECT * FROM ZHU_MIBIN_TEST.dbo.uf_GetCustomerName(11000);

--Lab5-3 PART2
SELECT soh.CustomerID AS CustomerID, fgc.name AS CustomerName, COUNT(DISTINCT soh.SalesOrderID) AS TotalOrder, COUNT(DISTINCT sod.ProductID) AS ProductCount
FROM AdventureWorks2008R2.Sales.SalesOrderHeader soh JOIN AdventureWorks2008R2.Sales.SalesOrderDetail sod
ON soh.SalesOrderID = sod.SalesOrderID
CROSS APPLY ZHU_MIBIN_TEST.dbo.uf_GetCustomerName(soh.CustomerID) AS fgc
GROUP BY soh.CustomerID, fgc.name
ORDER BY soh.CustomerID ASC;

--Lab5-4
USE "ZHU_MIBIN_TEST";
--DROP TABLE SaleOrderDetail;
--DROP TABLE SaleOrder;
--DROP TABLE Customer;
CREATE TABLE Customer
(
	CustomerID INT PRIMARY KEY,
	CustomerLName VARCHAR(30),
	CustomerFName VARCHAR(30)
);

CREATE TABLE SaleOrder
(
	OrderID INT IDENTITY PRIMARY KEY,
	CustomerID INT REFERENCES Customer(CustomerID),
	OrderDate DATE,
	LastModified DATETIME
);

CREATE TABLE SaleOrderDetail
(
	OrderID INT REFERENCES SaleOrder(OrderID),
	ProductID INT,
	Quantity INT,
	UnitPrice INT,
	PRIMARY KEY (OrderID, ProductID)
);

CREATE TRIGGER LastModified
ON ZHU_MIBIN_TEST.dbo.SaleOrderDetail
AFTER INSERT, UPDATE, DELETE AS
BEGIN
	UPDATE dbo.SaleOrder SET LastModified = GETDATE()
	WHERE OrderID = ISNULL((SELECT OrderID FROM Inserted), (SELECT OrderID FROM Deleted))
END;

INSERT Customer VALUES (1001, 'MIBIN', 'ZHU'), (1002, 'JASON', 'CHEN'), (1003, 'GREAT', 'BIG');
INSERT SaleOrder VALUES (1001, '2019-11-11', '2019-11-11 11:11:11'), (1002, '2019-11-11', '2019-11-11 11:11:11'), (1003, '2019-11-11', '2019-11-11 11:11:11');
INSERT SaleOrderDetail VALUES (1, 1, 256, 10);
UPDATE SaleOrderDetail SET Quantity = 255 WHERE OrderID = 1;
DELETE SaleOrderDetail WHERE OrderID = 1;