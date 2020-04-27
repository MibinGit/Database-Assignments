--PIVOT TEST
USE AdventureWorks2008R2;
SELECT 'AverageCost' AS Cost_By_Days,
[0], [1], [2], [3], [4]
FROM
(
	SELECT DaysToManufacture, StandardCost
	FROM Production.Product
) AS SourceTable
PIVOT
(
	AVG(StandardCost)
	FOR DaysToManufacture IN ([0], [1], [2], [3], [4])
) AS PivotTable;

--UNPIVOT TEST
USE ZHU_MIBIN_TEST;
CREATE TABLE dbo.CustomerPhone
(
	CustomerID INT,
	Phone1 VARCHAR(20),
	Phone2 VARCHAR(20),
	Phone3 VARCHAR(20)
)

INSERT INTO CustomerPhone
VALUES
(1, 43514124124, 343242342334, NULL),
(2, 43875783462, 984528364784, 2348983743),
(3, 43875783462, 984528364784, NULL);

SELECT CustomerID, Phone
FROM
(
	SELECT CustomerID, Phone1, Phone2, Phone3
	FROM dbo.CustomerPhone
) AS Original
UNPIVOT
(
	Phone
	FOR Phones IN (Phone1, Phone2, Phone3)
) AS Unp;

DROP TABLE dbo.CustomerPhone;

--Horizontal Reporting Format SELECT TOP 1 WITH TIES TEST
USE AdventureWorks2008R2;
SELECT DISTINCT TERRITORYID,
STUFF
(
	(
		SELECT TOP 1 WITH TIES ',' + CAST(sod.CUSTOMERID AS CHAR(5))
		FROM Sales.SalesOrderHeader sod
		WHERE sod.TERRITORYID = sodtemp.TERRITORYID
		GROUP BY TERRITORYID, CustomerID
		ORDER BY COUNT(SalesOrderID) DESC
		FOR XML PATH('')
	), 1, 2, ''
) TopCustomers
FROM Sales.SalesOrderHeader sodtemp
ORDER BY TERRITORYID;

--Horizontal Reporting Format FOR XML PATH + Ranking TEST
USE AdventureWorks2008R2;
With temp AS
(
	SELECT TERRITORYID, CustomerID,
	RANK() OVER (PARTITION BY TERRITORYID ORDER BY COUNT(SalesOrderID) DESC) AS CustomerRank
	FROM Sales.SalesOrderHeader
	GROUP BY TERRITORYID, CustomerID
)
SELECT DISTINCT TERRITORYID,
STUFF
(
	(
		SELECT ',' + CAST(CUSTOMERID AS CHAR(5))
		FROM temp t2
		WHERE t2.TERRITORYID = t1.TERRITORYID AND CustomerRank = 1
		ORDER BY CustomerID
		FOR XML PATH('')
	), 1, 2, ''
) TopCustomers
FROM temp t1;

--Horizontal Reporting Format USING FUNCTION TEST
USE ZHU_MIBIN_TEST;
CREATE FUNCTION dbo.ufGetTerritoryTopCustomer(@tid INT)
RETURNS TABLE AS
RETURN
SELECT TOP 1 WITH TIES TERRITORYID, CustomerID
FROM AdventureWorks2008R2.Sales.SalesOrderHeader
WHERE TERRITORYID = @tid
GROUP BY TERRITORYID, CustomerID
ORDER BY COUNT(SalesOrderID) DESC;

With temp AS
(
	SELECT DISTINCT sod.TERRITORYID, u.CustomerID
	FROM AdventureWorks2008R2.Sales.SalesOrderHeader sod
	CROSS APPLY ZHU_MIBIN_TEST.dbo.ufGetTerritoryTopCustomer(TERRITORYID) u
)
SELECT DISTINCT TERRITORYID,
STUFF
(
	(
		SELECT ',' + CAST(CUSTOMERID AS CHAR(5))
		FROM temp t2
		WHERE t2.TERRITORYID = t1.TERRITORYID
		ORDER BY CustomerID
		FOR XML PATH('')
	), 1, 2, ''
) TopCustomers
FROM temp t1;

--Table-Level Constraint TEST
USE ZHU_MIBIN_TEST;
CREATE DATABASE Flight
USE Flight
CREATE TABLE Reservation
(
	PassengerName VARCHAR(30),
	FlightNo SMALLINT,
	FlightDate DATE
);

CREATE TABLE Behavior
(
	PassengerName VARCHAR(30),
	BehaviorType VARCHAR(20),
	BehaviorDate DATE
);

--Can not CREATE cause it is master bench
USE ZHU_MIBIN_TEST;
CREATE FUNCTION CheckBehavior (@PName VARCHAR(30))
RETURNS SMALLINT
AS
BEGIN
	DECLARE @Count SMALLINT = 0;
	SELECT @Count = Count(PassengerName)
	FROM Behavior
	WHERE PassengerName = @PName
	AND BehaviorType = 'Abusive';
	RETURN @Count
END;

ALTER TABLE Reservation ADD CONSTRAINT BanBadBehavior CHECK (dbo.CheckBehavior(PassengerName) = 0);

INSERT INTO Flight.dbo.Reservation (PassengerName, FlightNo, FlightDate)
VALUES ('Peter', 33, '12-30-2019');

DROP FUNCTION CheckBehavior;

--Trigger TEST
CREATE DATABASE Flight
USE Flight
CREATE TABLE Reservation
(
	PassengerName VARCHAR(30),
	FlightNo SMALLINT,
	FlightDate DATE
);

CREATE TABLE Behavior
(
	PassengerName VARCHAR(30),
	BehaviorType VARCHAR(20),
	BehaviorDate DATE
);

--Can not CREATE cause it is master bench
USE ZHU_MIBIN_TEST;
CREATE TRIGGER TR_CheckBehavior
ON dbo.Reservation
AFTER INSERT AS
BEGIN
	DECLARE @Count SMALLINT = 0;
	SELECT @Count = Count(PassengerName)
	FROM AdventureWorks2008R2.dbo.Behavior
	WHERE PassengerName = (SELECT PassengerName FROM Inserted)
	AND BehaviorType = 'Abusive';

	IF @Count > 0
	BEGIN
		ROLLBACK;
	END
END;

INSERT INTO Flight.dbo.Reservation (PassengerName, FlightNo, FlightDate)
VALUES ('Peter', 33, '12-30-2019');

DROP TRIGGER TR_CheckBehavior;

--SCALAR FUNCTION TEST
USE ZHU_MIBIN_TEST;
CREATE FUNCTION uf_GetAccountNumberForCustomer(@CustID INT)
RETURNS VARCHAR(10)
AS
BEGIN
	DECLARE @AcctNo VARCHAR(10);
	SELECT @AcctNo = AccountNumber
	FROM AdventureWorks2008R2.Sales.Customer
	WHERE CustomerID = @CustID
	RETURN @AcctNo;
END;

--PROCEDURE TEST
USE ZHU_MIBIN_TEST;
CREATE PROCEDURE Person.GetEmployee
(
	@BusinessEntityID INT = 199,
	@Email_Address NVARCHAR(50) OUTPUT,
	@Full_Name NVARCHAR(100) OUTPUT
)
AS
BEGIN
	SELECT @Email_Address = ea.EmailAddress,
	@Full_Name = p.FirstName + ' ' + COALESCE(p.MiddleName, '') + ' ' + p.LastName
	FROM dbo.HumanResources.Employee e
	INNER JOIN dbo.Person.Person p
	ON e.BusinessEntityID = p.BusinessEntityID
	INNER JOIN dbo.Person.EailAddress ea
	ON p.BusinessEntityID = ea.BusinessEntityID
	WHERE e.BusinessEntityID = @BusinessEntityID;
	
	RETURN
	(
		CASE
			WHEN @Email_Address IS NULL THEN 1
			ELSE 0
		END
	);
END;

DECLARE @Email NVARCHAR(50), @Name NVARCHAR(100), @Result INT;
EXECUTE @Result = Person.GetEmployee 123, @Email OUTPUT, @Name OUTPUT;
SELECT @Result AS Result, @Email AS Email, @Name AS [Name];