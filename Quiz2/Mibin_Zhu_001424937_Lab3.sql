--Lab3.Question1 用CASE WHEN的写法给这个数据库加一列
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

--Lab3.Question2 添加RANK() OVER 根据SalesOrderid排序 同样也根据TerritoryID排序
USE AdventureWorks2008R2;
SELECT
	RANK() OVER (PARTITION BY c.TerritoryID ORDER BY COUNT(o.SalesOrderid) DESC) AS [Rank],
	c.CustomerID, c.TerritoryID, COUNT(o.SalesOrderid) [Total Orders]
FROM Sales.Customer c LEFT OUTER JOIN Sales.SalesOrderHeader o
ON c.CustomerID = o.CustomerID
WHERE DATEPART(year, OrderDate) = 2007
GROUP BY c.TerritoryID, c.CustomerID;

--Lab3.Question3 根据分组简单选取最高的
USE AdventureWorks2008R2;
SELECT MAX(sp.Bonus)
FROM Sales.SalesPerson sp
LEFT JOIN HumanResources.Employee e ON sp.BusinessEntityID = e.BusinessEntityID
LEFT JOIN Sales.SalesTerritory st ON sp.TerritoryID = st.TerritoryID
WHERE e.Gender = 'M' AND st.[Group] = 'North America';

--Lab3.Question4 通过链接包含有order日期以及产品id的temp表和包含有order日期以及最大sod.OrderQty的maxtemp表
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

--Lab3.Question5 应用CAST方法将日期转换 并且返回ID
USE AdventureWorks2008R2;
SELECT soh.CustomerID
FROM Sales.SalesOrderHeader soh JOIN Sales.SalesOrderDetail sod
ON soh.SalesOrderID = sod.SalesOrderID
WHERE CAST(soh.OrderDate AS Date) > '2008-07-01' AND (sod.ProductID = '711' OR sod.ProductID = '712')
GROUP BY soh.CustomerID HAVING COUNT(sod.ProductID) > 1
ORDER BY soh.CustomerID;

--Lab3 PDF
--CASE WHEN例子
USE AdventureWorks2008R2;
SELECT ProductID, Name, ListPrice,
(
	SELECT ROUND(AVG(ListPrice), 2) AS AvgPrice
	FROM Production.Product) AP , 
	CASE
		WHEN ListPrice - (SELECT ROUND(AVG(ListPrice), 2) AS AvgPrice FROM Production.Product) = 0 THEN 'Average Price'
		WHEN ListPrice - (SELECT ROUND(AVG(ListPrice), 2) AS AvgPrice FROM Production.Product) < 0 THEN 'Below Average Price'
		ELSE 'Above Average Price' 
	END AS PriceComparison
FROM Production.Product ORDER BY ListPrice DESC;

--RANK + PARTITION BY例子
USE AdventureWorks2008R2;
SELECT RANK() OVER (PARTITION BY ProductID ORDER BY OrderQty DESC) AS [Rank],
SalesOrderID, ProductID, UnitPrice, OrderQty
FROM Sales.SalesOrderDetail
WHERE UnitPrice > 75;

--DENSE_RANK输出的结果都是连续的
USE AdventureWorks2008R2;
SELECT i.ProductID, p.Name, i.LocationID, i.Quantity,
DENSE_RANK() OVER (PARTITION BY i.LocationID ORDER BY i.Quantity DESC) AS Rank
FROM Production.ProductInventory AS i
INNER JOIN Production.Product AS p
ON i.ProductID = p.ProductID
WHERE i.LocationID BETWEEN 3 AND 4
ORDER BY i.LocationID;