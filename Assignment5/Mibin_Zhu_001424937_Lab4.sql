--Lab4.PartA.STEP1/STEP2
CREATE DATABASE "ZHU_MIBIN_TEST";

USE "ZHU_MIBIN_TEST";
--CREATE TABLE
CREATE TABLE dbo.Customers
(
    CustomerID varchar(5) NOT NULL PRIMARY KEY,
    Name varchar(40) NOT NULL,
    Gender varchar(5) NOT NULL,
    Email varchar(40) NOT NULL
);

CREATE TABLE dbo.Orders
(
    OrderID int IDENTITY NOT NULL PRIMARY KEY,
    CustomerID varchar(5) NOT NULL
        REFERENCES Customers(CustomerID),
    OrderDate datetime DEFAULT Current_Timestamp,
    OrderPlace varchar(40) NOT NULL
);

CREATE TABLE dbo.Products
(
    ProductID int IDENTITY NOT NULL PRIMARY KEY,
    Name varchar(40) NOT NULL,
    UnitPrice int NOT NULL,
    ProductType varchar(40) NOT NULL
);

CREATE TABLE dbo.OrderItems
(
	OrderID int NOT NULL
		REFERENCES dbo.Orders(OrderID),
	ProductID int NOT NULL
		REFERENCES dbo.Products(ProductID),
    UnitPrice int NOT NULL,
    Quantity int NOT NULL
        CONSTRAINT PKOrderItem PRIMARY KEY CLUSTERED (OrderID, ProductID)
);

CREATE TABLE dbo.TestDelete
(
    TestID int NOT NULL PRIMARY KEY,
    TestName varchar(40) NOT NULL
);

--ADD COLUMN
ALTER TABLE dbo.TestDelete ADD MoreID INT NOT NULL
USE "ZHU_MIBIN_TEST";
--CREATE COLUMN
INSERT dbo.Customers VALUES ('A100', 'Bob', 'm', 'bob@neu.edu'), ('A101', 'Tina', 'f', 'tina@neu.edu'), ('B101', 'Jason', 'm', 'jason@neu.edu');
INSERT dbo.Customers VALUES ('C100', 'Tom', 'm', 'tom@neu.edu'), ('C101', 'Stacy', 'f', 'stacy@neu.edu'), ('D201', 'Kirito', 'm', 'kirito@neu.edu');
INSERT dbo.Orders (CustomerID, OrderPlace) VALUES ('A100', 'pk'), ('A101', 'pk2'), ('B101', 'sk'), ('C100', 'pk'), ('C101', 'pk2'), ('D201', 'pk2');
INSERT dbo.Products VALUES ('Apple', 6.23, 'food'), ('DOTA2', 8.88, 'game'), ('Bear', 10.55, 'drink'), ('Coco', 6.88, 'drink'), ('Pen', 0.25, 'use'), ('DOTA3', 12.88, 'game');
INSERT dbo.OrderItems VALUES (1, 1, 6.23, 3), (2, 2, 8.88, 5), (3, 3, 10.55, 2), (4, 4, 6.88, 4), (5, 5, 0.25, 3), (6, 6, 12.88, 3);
INSERT dbo.TestDelete VALUES ('1', 'KL', '100'), ('2', 'KeyNG', '101'), ('3', 'TT', '102');
--QUERIES
SELECT *
FROM dbo.Products
WHERE Products.ProductType = 'game'
ORDER BY Products.UnitPrice DESC;
--UPDATE COLUMN
UPDATE Customers SET Email = 'notbob@neu.edu' WHERE Name = 'Bob'
UPDATE Products SET ProductType = 'uncertain' WHERE Name = 'Coco'
--DELETE COLUMN
DELETE FROM TestDelete WHERE TestName = 'KL'
DELETE FROM TestDelete WHERE TestName = 'TT'

USE "ZHU_MIBIN_TEST";
--DELETE TABLE
DROP TABLE OrderItems;
DROP TABLE Products;
DROP TABLE Orders;
DROP TABLE Customers;
DROP TABLE TestDelete;

--Lab4.PartA.STEP3
USE "ZHU_MIBIN_TEST";
CREATE TABLE dbo.TargetCustomers
(
    TargetID varchar(5) NOT NULL PRIMARY KEY,
    FirstName varchar(40) NOT NULL,
    LastName varchar(40) NOT NULL,
    Address varchar(40) NOT NULL,
    City varchar(20) NOT NULL,
    State varchar(40) NOT NULL,
    ZipCode varchar(20) NOT NULL
);

CREATE TABLE dbo.MailingList
(
    MailingListID varchar(5) NOT NULL PRIMARY KEY,
    MailingList varchar(40) NOT NULL
);

CREATE TABLE dbo.TargetMailingLists
(
    TargetID varchar(5) NOT NULL
        REFERENCES TargetCustomers(TargetID),
    MailingListID varchar(5) NOT NULL
        REFERENCES MailingList(MailingListID)
        CONSTRAINT PKTargetMailingList PRIMARY KEY CLUSTERED (TargetID, MailingListID)
);

--Lab4.PartB
USE AdventureWorks2008R2;
SELECT DISTINCT sod.SalesOrderID,
STUFF((
	SELECT ',' + RTRIM(CAST(ProductID AS char))
	FROM Sales.SalesOrderDetail
	WHERE SalesOrderID = sod.SalesOrderID
	ORDER BY ProductID
	FOR XML PATH('')), 1, 1, '') AS ProductID
FROM Sales.SalesOrderDetail sod
ORDER BY SalesOrderID;

--Lab4.PartC
USE AdventureWorks2008R2;
WITH Parts(AssemblyID, ComponentID, PerAssemblyQty, EndDate, ComponentLevel) AS
(
	SELECT b.ProductAssemblyID, b.ComponentID, b.PerAssemblyQty, b.EndDate, 0 AS ComponentLevel
	FROM Production.BillOfMaterials AS b
	WHERE b.ProductAssemblyID = 992 AND b.EndDate IS NULL
	UNION ALL
	SELECT bom.ProductAssemblyID, bom.ComponentID, p.PerAssemblyQty, bom.EndDate, ComponentLevel + 1
	FROM Production.BillOfMaterials AS bom
	INNER JOIN Parts AS p
	ON bom.ProductAssemblyID = p.ComponentID AND bom.EndDate IS NULL
)
SELECT * FROM
(
	SELECT RANK() OVER (PARTITION BY ComponentLevel ORDER BY pr.ListPrice DESC) [Rank], AssemblyID, ComponentID, Name, pr.ListPrice, PerAssemblyQty, ComponentLevel
	FROM Parts AS p INNER JOIN Production.Product AS pr
	ON p.ComponentID = pr.ProductID
) AS temp
WHERE temp.[Rank] = 1;