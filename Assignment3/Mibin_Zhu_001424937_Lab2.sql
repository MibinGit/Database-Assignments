--Lab2.Question1
USE AdventureWorks2008R2;
SELECT ProductID AS Pid, Name AS Pn, CAST(SellStartDate AS DATE) AS SellStartDate
FROM Production.Product
WHERE SellStartDate > '2006-02-01 00:00:00' AND Color = 'Yellow'
ORDER BY SellStartDate;

--Lab2.Question2
USE AdventureWorks2008R2;
SELECT soh.CustomerID, soh.AccountNumber, l.LatestOrderDate, l.OrderTotalNumber
FROM Sales.SalesOrderHeader soh
JOIN
(
	SELECT CustomerID, MAX(OrderDate) AS LatestOrderDate, COUNT(CustomerID) AS OrderTotalNumber
	FROM Sales.SalesOrderHeader
	GROUP BY CustomerID
) AS l
ON soh.CustomerID = l.CustomerID AND soh.OrderDate = l.LatestOrderDate
ORDER BY CustomerID;

--Lab2.Question3
USE AdventureWorks2008R2;
SELECT ProductID AS Pid, Name AS Pn, ListPrice AS ListPrice
FROM Production.Product
WHERE ListPrice >
(
	SELECT AVG(ListPrice)
	FROM Production.Product
)
ORDER BY Pid;

--Lab2.Question4
SELECT p.ProductID AS Pid, p.Name AS Pn, s.SoldQuantity
FROM Production.Product p
JOIN
(
	SELECT ProductID, SUM(OrderQty) AS SoldQuantity
	FROM Sales.SalesOrderDetail
	GROUP BY ProductID HAVING SUM(OrderQty) > 50
) AS s
ON p.ProductID = s.ProductID
ORDER BY SoldQuantity DESC;

--Lab2.Question5
USE AdventureWorks2008R2;
SELECT soh.SalesOrderID, soh.SalesPersonID, n.TotalDifferentProduct
FROM Sales.SalesOrderHeader soh
JOIN
(
	SELECT SalesOrderID, COUNT(ProductID) AS TotalDifferentProduct
	FROM Sales.SalesOrderDetail
	GROUP BY SalesOrderID HAVING COUNT(ProductID) > 70
) AS n
ON soh.SalesOrderID = n.SalesOrderID
ORDER BY soh.SalesPersonID;

--Lab2.Question6
USE AdventureWorks2008R2;
SELECT p.ProductID, p.Name
FROM Production.Product p
LEFT JOIN
(
	SELECT sod.ProductID, sod.SalesOrderID, soh.OrderDate
	FROM Sales.SalesOrderDetail sod JOIN Sales.SalesOrde、rHeader soh
	ON sod.SalesOrderID = soh.SalesOrderID
	WHERE soh.OrderDate LIKE '%2007%'
) AS s
ON p.ProductID = s.ProductID
WHERE s.ProductID IS NULL
ORDER BY p.ProductID;