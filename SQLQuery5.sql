/*Creates temporary table for sum of hours each week by job title treates null values as equalling zero.*/
DROP TABLE IF EXISTS #WeeklyTotalsByJobTitle
CREATE TABLE #WeeklyTotalsByJobTitle (BusinessEntityID INT, Department VARCHAR(100), Week1Total INT, Week2Total INT, Week3Total INT, Week4Total INT)
INSERT INTO #WeeklyTotalsByJobTitle (BusinessEntityID, Department, Week1Total, Week2Total, Week3Total, Week4Total)
	SELECT BusinessEntityID, Department, [Week 1], [Week 2], [Week 3], [Week 4]
		FROM Hours AS H, HumanResources.vEmployeeDepartment AS D
		WHERE H.[Last Name] = D.LastName AND H.[First Name] = D.FirstName

SELECT * FROM #WeeklyTotalsByJobTitle

DROP TABLE IF EXISTS #WeeklyTotalsByDepartment
CREATE TABLE #WeeklyTotalsByDepartment (Department VARCHAR(100), Week1Total INT, Week2Total INT, Week3Total INT, Week4Total INT)
INSERT INTO #WeeklyTotalsByDepartment (Department, Week1Total, Week2Total, Week3Total, Week4Total) 
	SELECT Department, SUM(Week1Total), SUM(Week2Total), SUM(Week3Total), SUM(Week4Total) 
		FROM #WeeklyTotalsByJobTitle
		GROUP BY Department

DROP TABLE IF EXISTS #MonthlyTotalsByDepartment
CREATE TABLE #MonthlyTotalsByDepartment (Department VARCHAR(100), Week1Total INT, Week2Total INT, Week3Total INT, Week4Total INT, MonthlyTotal INT)
INSERT INTO #MonthlyTotalsByDepartment (Department, Week1Total, Week2Total, Week3Total, Week4Total, MonthlyTotal)
	SELECT Department, Week1Total, Week2Total, Week3Total, Week4Total, SUM(Week1Total + Week2Total + Week3Total + Week4Total) AS MonthlyTotal  
		FROM #WeeklyTotalsByDepartment
		GROUP BY Department, Week1Total, Week2Total, Week3Total, Week4Total
SELECT * FROM #MonthlyTotalsByDepartment

DROP TABLE IF EXISTS #DeficiencyByJobTitle
CREATE TABLE #DeficiencyByJobTitle (BusinessEntityID INT, Department VARCHAR(100), Week1 INT, Week2 INT, Week3 INT, Week4 INT)
INSERT INTO #DeficiencyByJobTitle (BusinessEntityID, Department, Week1, Week2, Week3, Week4)
SELECT BusinessEntityID, Department, 
	CASE
		WHEN Week1Total IS NULL THEN 40
		WHEN Week1Total <= 40 THEN 40 - Week1Total
	END AS Week1,
	CASE
		WHEN Week2Total IS NULL THEN 40
		WHEN Week2Total <= 40 THEN 40 - Week2Total
	END AS Week2,
	CASE
		WHEN Week3Total IS NULL THEN 40
		WHEN Week3Total <= 40 THEN 40 - Week3Total
	END AS Week3,
	CASE
		WHEN Week4Total IS NULL THEN 40
		WHEN Week4Total <= 40 THEN 40 - Week4Total 
	END	AS Week4
		FROM #WeeklyTotalsByJobTitle
SELECT * FROM #DeficiencyByJobTitle

DROP TABLE IF EXISTS #DeficiencyByDepartment
CREATE TABLE #DeficiencyByDepartment (Department VARCHAR(100), Week1 INT, Week2 INT, Week3 INT, Week4 INT)
INSERT INTO #DeficiencyByDepartment (Department, Week1, Week2, Week3, Week4)
	SELECT Department, SUM(Week1), SUM(Week2), SUM(Week3), SUM(Week4) 
		FROM #DeficiencyByJobTitle
		GROUP BY Department
SELECT * FROM #DeficiencyByDepartment

DROP TABLE IF EXISTS #MonthlyDeficiencyByDepartment
CREATE TABLE #MonthlyDeficiencyByDepartment (Department VARCHAR(100), Week1Total INT, Week2Total INT, Week3Total INT, Week4Total INT, MonthlyTotals INT)
INSERT INTO #MonthlyDeficiencyByDepartment (Department, Week1Total, Week2Total, Week3Total, Week4Total, MonthlyTotals)
	SELECT Department, Week1, Week2, Week3, Week4, SUM(Week1 + Week2 + Week3 + Week4) 
		FROM #DeficiencyByDepartment
		GROUP BY Department, Week1, Week2, Week3, Week4

SELECT  Department, Week1Total / 40, Week2Total / 40, Week3Total / 40, Week4Total / 40, MonthlyTotals / 160
FROM #MonthlyDeficiencyByDepartment

SELECT D.Department, (D.Week1Total + T.Week1Total) / 40 AS Week1TotalPeople,  (D.Week2Total + T.Week2Total) / 40 AS Week2TotalPeople,  (D.Week3Total + T.Week3Total) / 40 AS Week3TotalPeople,  (D.Week4Total + T.Week4Total) / 40 AS Week4TotalPeople, (D.MonthlyTotals + T.MonthlyTotal) / 160 AS MonthlyTotals
	FROM #MonthlyDeficiencyByDepartment AS D, #MonthlyTotalsByDepartment T
	WHERE D.Department = T.Department