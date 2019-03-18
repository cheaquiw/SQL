/*Creates temporary table for sum of hours each week by job title treats null values as equaling zero.*/
DROP TABLE IF EXISTS #WeeklyTotalsByJobTitle
CREATE TABLE #WeeklyTotalsByJobTitle (BusinessEntityID INT, Department VARCHAR(100), Week1Total INT, Week2Total INT, Week3Total INT, Week4Total INT)
INSERT INTO #WeeklyTotalsByJobTitle (BusinessEntityID, Department, Week1Total, Week2Total, Week3Total, Week4Total)
	SELECT BusinessEntityID, Department, [Week 1], [Week 2], [Week 3], [Week 4]
		FROM Hours AS H, HumanResources.vEmployeeDepartment AS D
		WHERE H.[Last Name] = D.LastName AND H.[First Name] = D.FirstName

SELECT Department, SUM(Week1Total) AS Week1Total, SUM(Week2Total) AS Week2Total, SUM(Week3Total) AS Week3Total, SUM(Week4Total)AS Week4Total 
	FROM #WeeklyTotalsByJobTitle
	GROUP BY Department

--Creates temporary table, which classifies employee's status as 'Active' or 'Inactive' based on if they have any hours worked for the month.
DROP TABLE IF EXISTS #Status
CREATE TABLE #Status (FirstName VARCHAR(100), LastName VARCHAR(100), Status VARCHAR(100))
INSERT INTO #Status (FirstName, LastName, Status)
	SELECT [First Name], [Last Name], 
		CASE
			WHEN [Week 1] IS NULL AND [Week 2] IS NULL AND [Week 3] IS NULL AND [Week 4] IS NULL
			THEN 'Inactive'
			WHEN [Week 1] IS NOT NULL OR [Week 2] IS NOT NULL OR [Week 3] IS NOT NULL OR [Week 4] IS NOT NULL
			THEN 'Active'
		END AS Status
		FROM Hours

--SELECTS BusinessEntityIDs of Inactive employees
SELECT BusinessEntityID 
	FROM #Status AS S, HumanResources.vEmployee AS E
	WHERE S.Status = 'Inactive' AND S.LastName = E.LastName AND S.FirstName = E.FirstName
	ORDER BY BusinessEntityID
--Sums the amount the inactive employees would make if they were full time
SELECT SUM(Rate * 40 * 52) AS TotalAnnualPay 
	FROM HumanResources.EmployeePayHistory
	WHERE BusinessEntityID IN (60, 68, 121, 193)

--Lists the Managers for the employees that have 0 hours for the month. All work around a warehouse, and under the same general manager
exec uspGetEmployeeManagers 60
exec uspGetEmployeeManagers 68
exec uspGetEmployeeManagers 121
exec uspGetEmployeeManagers 193

--Creates temporary table with all employees' direct manager
DROP TABLE IF EXISTS #ManagerList
CREATE TABLE #ManagerList (RecursionLevel INT, BusinessEntityID INT, FirstName VARCHAR(100), 
	LastName VARCHAR(100), OrganizationNode VARCHAR(100), ManagerFirstName VARCHAR(100), ManagerLastName VARCHAR(100))

DECLARE @cnt INT = 0;
WHILE @cnt < 291
	BEGIN
		INSERT INTO #ManagerList
		exec uspGetEmployeeManagers @Cnt
		SET @cnt = @cnt + 1;
	END

--Counts all employees at the company
SELECT COUNT(DISTINCT BusinessEntityID) AS TotalEmployees FROM HumanResources.Employee

/*Since all inactive employees are under the Production Control Manager Krebs or someone under him, this counts total number of employees under him*/
SELECT COUNT(DISTINCT BusinessEntityID) AS TotalEmployeesUnderKrebs
	FROM #ManagerList 
	WHERE ManagerLastName = 'Krebs' OR ManagerLastName IN (
		SELECT distinct LastName
			FROM #ManagerList 
			WHERE ManagerLastName = 'Krebs')

/*Since all inactive employees are involved in or around the warehouse in Production or 
Shipping and Receiving, this counts total number of employees in those departments*/
SELECT COUNT(DISTINCT BusinessEntityID) AS TotalEmployeesAroundWarehouse
	FROM HumanResources.vEmployeeDepartment
	WHERE Department LIKE ('Production%') OR Department LIKE ('Ship%')
 
