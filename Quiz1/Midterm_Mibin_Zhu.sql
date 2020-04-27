--Midterm.Question3
USE AdventureWorks2008R2;
SELECT soh.OrderDate, COUNT(DISTINCT prod.Color) AS ColorSum
FROM Sales.SalesOrderHeader soh LEFT JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
LEFT JOIN Production.Product prod ON sod.ProductID = prod.ProductID
WHERE prod.Color IS NOT NULL GROUP BY soh.OrderDate
HAVING COUNT(DISTINCT prod.Color) > 7
ORDER BY ColorSum DESC;

--Midterm.Question4
USE AdventureWorks2008R2;
SELECT sd.ProductID, MONTH(sh.OrderDate) AS MonthOfSale, pp.color
FROM Sales.SalesOrderHeader sh INNER JOIN Sales.SalesOrderDetail sd ON sh.SalesOrderID = sd.SalesOrderID 
INNER JOIN Production.Product pp ON sd.ProductID = pp.ProductID
WHERE DATEPART(year, OrderDate) = 2007 AND pp.color NOT IN ('White')
ORDER BY sh.OrderDate;

--Midterm.Question5
USE AdventureWorks2008R2;
SELECT ssh.SalesOrderID, ssh.TotalDue, ssh.TerritoryID
FROM Sales.SalesOrderHeader ssh
WHERE ssh.TotalDue IN (SELECT MAX(sh.TotalDue)
FROM Sales.SalesOrderHeader sh LEFT JOIN Sales.SalesTerritory st
ON sh.TerritoryID = st.TerritoryID
GROUP BY sh.TerritoryID)
ORDER BY ssh.TerritoryID;