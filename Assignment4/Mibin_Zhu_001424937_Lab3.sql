--Lab3.Question1
USE AdventureWorks2008R2;
SELECT c.CustomerID, c.TerritoryID, COUNT(o.SalesOrderid) [Total Orders],
(
	CASE
		WHEN COUNT(o.SalesOrderid) = 0 THEN 'No Order'
		WHEN COUNT(o.SalesOrderid) = 1 THEN 'One Time'
		WHEN COUNT(o.SalesOrderid) >= 2 AND COUNT(o.SalesOrderid) <= 5 THEN 'Regular'
		WHEN COUNT(o.SalesOrderid) >= 6 AND COUNT(o.SalesOrderid) <= 10 THEN 'Often'
		ELSE 'Loyal'
	END
) AS OrderLevel
FROM Sales.Customer c LEFT OUTER JOIN Sales.SalesOrderHeader o
ON c.CustomerID = o.CustomerID
WHERE DATEPART(year, OrderDate) = 2007
GROUP BY c.TerritoryID, c.CustomerID;

--Lab3.Question2
USE AdventureWorks2008R2;
SELECT
	RANK() OVER (PARTITION BY c.TerritoryID ORDER BY COUNT(o.SalesOrderid) DESC) AS [Rank],
	c.CustomerID, c.TerritoryID, COUNT(o.SalesOrderid) [Total Orders]
FROM Sales.Customer c LEFT OUTER JOIN Sales.SalesOrderHeader o
ON c.CustomerID = o.CustomerID
WHERE DATEPART(year, OrderDate) = 2007
GROUP BY c.TerritoryID, c.CustomerID;

--Lab3.Question3
USE AdventureWorks2008R2;
SELECT MAX(sp.Bonus)
FROM Sales.SalesPerson sp
LEFT JOIN HumanResources.Employee e ON sp.BusinessEntityID = e.BusinessEntityID
LEFT JOIN Sales.SalesTerritory st ON sp.TerritoryID = st.TerritoryID
WHERE e.Gender = 'M' AND st.[Group] = 'North America';

--Lab3.Question4
USE AdventureWorks2008R2;
SELECT temp.OrderDate, temp.ProductID, maxtemp.MaxOrderTotal AS OrderTotal
FROM
(	
	SELECT soh.OrderDate AS OrderDate, sod.ProductID AS ProductID, SUM(sod.OrderQty) AS OrderTotal
	FROM Sales.SalesOrderHeader soh JOIN Sales.SalesOrderDetail sod
	ON soh.SalesOrderID = sod.SalesOrderID
	GROUP BY sod.ProductID, soh.OrderDate
) AS temp
JOIN
(
	SELECT newtemp.OrderDate AS OrderDate, MAX(newtemp.OrderTotal) AS MaxOrderTotal
	FROM
	(	
		SELECT soh.OrderDate AS OrderDate, sod.ProductID AS ProductID, SUM(sod.OrderQty) AS OrderTotal
		FROM Sales.SalesOrderHeader soh JOIN Sales.SalesOrderDetail sod
		ON soh.SalesOrderID = sod.SalesOrderID
		GROUP BY sod.ProductID, soh.OrderDate
	) AS newtemp
	GROUP BY newtemp.OrderDate
) AS maxtemp
ON temp.OrderDate = maxtemp.OrderDate AND temp.OrderTotal = maxtemp.MaxOrderTotal
ORDER BY temp.OrderDate;

--Lab3.Question5
USE AdventureWorks2008R2;
SELECT soh.CustomerID
FROM Sales.SalesOrderHeader soh JOIN Sales.SalesOrderDetail sod
ON soh.SalesOrderID = sod.SalesOrderID
WHERE CAST(soh.OrderDate AS Date) > '2008-07-01' AND (sod.ProductID = '711' OR sod.ProductID = '712')
GROUP BY soh.CustomerID HAVING COUNT(sod.ProductID) > 1
ORDER BY soh.CustomerID;