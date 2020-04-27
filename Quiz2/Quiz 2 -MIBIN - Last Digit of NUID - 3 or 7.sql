-- Last Digit of NUID: 3 or 7
-- Your NUID: 001424937
-- Your Name: Mibin Zhu

--------------- Question 1 (3 points) -------------------

/* Rewrite the following query to present the same data in a horizontal format,
   as listed below, using the SQL PIVOT command. */

/*USE AdventureWorks2008R2;
SELECT TerritoryID, month(OrderDate) [Year], 
       SUM(TotalDue) AS [Sale Amount]
FROM Sales.SalesOrderHeader
WHERE year(OrderDate) = 2007 and month(OrderDate) between 1 and 5
GROUP BY TerritoryID, month(OrderDate)
ORDER BY TerritoryID, month(OrderDate); */

USE AdventureWorks2008R2;
SELECT TerritoryID AS TerritoryID,
[1] AS [January], [2] AS [February], [3] AS [March], [4] AS [April], [5] AS [May]
FROM
(
	SELECT TerritoryID, month(OrderDate) [Year], SUM(TotalDue) AS TotalDue
	FROM Sales.SalesOrderHeader
	WHERE year(OrderDate) = 2007 and month(OrderDate) between 1 and 5
	GROUP BY TerritoryID, month(OrderDate)
) AS SourceTable
PIVOT
(
	SUM(TotalDue)
	FOR [Year] IN ([1], [2], [3], [4], [5])
) AS PivotTable;

/*
TerritoryID	January	February	March	April	May
1			270040	494871		135313	320453	599402
2			269839	312669		171608	377472	386357
3			166678	263551		202261	218488	322145
4			368640	783326		538495	493877	992669
5			140842	240255		157418	196643	242404
6			311454	417632		475132	507594	560034
7			83828	206536		140724	129677	272150
8			41897	70938		58418	81116	61234
9			205793	229599		219661	226915	225594
10			109636	206680		198662	108490	204377
*/



--------------- Question 2 (4 points) ------------------

/* Write a query to retrieve the top three products of each territory.
   Use the sum of OrderQty in Sales.SalesOrderDetail to determine the total sold quantity.
   The top 3 products have the three highest total sold quantities. Your solution
   should retrieve a tie if there is any. The report should have the following format.
   The first number in a set is the product id, the second is the told sold quantity.
   Number sets are separated by ','.
   Sort the report by TerritoryID.

TerritoryID	name			Top3Orders
	1		Northwest		870 947, 712 887, 711 794
	2		Northeast		715 549, 712 514, 711 423
	3		Central			712 584, 715 562, 711 440
	4		Southwest		712 1702, 715 1446, 711 1385
	5		Southeast		715 539, 712 537, 711 427
	6		Canada			712 1638, 715 1433, 708 1285
	7		France			712 587, 870 568, 711 519
	8		Germany			870 677, 712 555, 708 415
	9		Australia		870 913, 873 674, 712 619
	10		United Kingdom	712 688, 870 679, 711 560
   
*/

USE AdventureWorks2008R2;
WITH currenttable AS
(
	SELECT st.TerritoryID, st.Name, sod.ProductID, SUM(sod.OrderQty) AS TotalAmount
	FROM Sales.SalesTerritory st JOIN Sales.SalesOrderHeader soh ON st.TerritoryID = soh.TerritoryID
	JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
	GROUP BY st.TerritoryID, st.Name, sod.ProductID
)
SELECT DISTINCT currenttable.TerritoryID, currenttable.Name,
STUFF
(
	(
		SELECT TOP 3 WITH TIES ',' + CAST(currenttable.ProductID AS CHAR(10)) + ' ' + CAST(currenttable.TotalAmount AS CHAR(10))
		FROM currenttable
		WHERE currenttable.TerritoryID = temp.TerritoryID
		ORDER BY TotalAmount DESC
		FOR XML PATH('')
	), 1, 2, ''
) TopProduct
FROM currenttable temp
ORDER BY currenttable.TerritoryID;

--------------- Question 3 (4 points) -----------------

/* Given the following tables, there is a university rule
   preventing a student from enrolling in a new class if there is
   an unpaid fine. Please write a table-level constraint
   to implement the rule. */

USE ZHU_MIBIN_TEST;
create table Course
(CourseID int primary key,
 CourseName varchar(50),
 InstructorID int,
 AcademicYear int,
 Semester smallint);

create table Student
(StudentID int primary key,
 LastName varchar (50),
 FirstName varchar (50),
 Email varchar(30),
 PhoneNumber varchar (20));

create table Enrollment
(CourseID int references Course(CourseID),
 StudentID int references Student(StudentID),
 RegisterDate date,
 primary key (CourseID, StudentID));

create table Fine
(StudentID int references Student(StudentID),
 IssueDate date,
 Amount money,
 PaidDate date
 primary key (StudentID, IssueDate));

USE ZHU_MIBIN_TEST;
CREATE FUNCTION CheckFine (@SID INT)
RETURNS SMALLINT
AS
BEGIN
	DECLARE @Count SMALLINT = 0;
	SELECT @Count = Count(StudentID)
	FROM Enrollment
	WHERE StudentID = @SID
	AND PaidDate IS NULL;
	RETURN @Count
END;

ALTER TABLE Enrollment ADD CONSTRAINT NoPaidForFine CHECK (dbo.CheckFine(StudentID) = 0);

--------------- Question 4 (4 points) ---------------------

/* There is a business rule about the employee's training.
   No employee can spend more than $20,000 on training per year.
   Any attempt to spend more than $20,000 for an employee's training
   in a year must be logged in an audit table and the violating
   training expense is not allowed.

   Given the following 4 tables, please write a trigger to implement
   the business rule. The rule must be enforced every year.
   Assume only one training expense is entered in the database
   at a time. You can just consider the INSERT scenarios.
*/

USE ZHU_MIBIN_TEST;
create table Employee
(EmployeeID int primary key,
 EmpLastName varchar(50),
 EmpFirstName varchar(50),
 DepartmentID smallint);

create table Training
(TrainingID int primary key,
 CategoryID smallint,
 Description varchar(200));

create table TrainingExpense
(EmployeeID int NOT NULL,
 TrainingID int NOT NULL,
 TrainingDate date NOT NULL,
 TrainingCost money
 primary key(EmployeeID, TrainingID, TrainingDate));

create table TrainingAudit  -- Audit Table
(AuditID int identity primary key,
 EnteredBy varchar(50) default original_login(),
 EnterTime datetime default getdate(),
 EnteredAmount int not null);
 
USE ZHU_MIBIN_TEST;
CREATE TRIGGER TR_NoMorePay
ON dbo.TrainingAudit
AFTER INSERT AS
BEGIN
	DECLARE @Count SMALLINT = 0;
	SELECT @Count = Count(EmployeeID)
	FROM dbo.TrainingExpense
	WHERE EmployeeID = (SELECT EmployeeID FROM Inserted)
	AND TrainingCost > 20000;

	IF @Count > 0
	BEGIN
		ROLLBACK;
	END
END;