CREATE TABLE #AppliedListPrice (ProductID INT, Name VARCHAR(100), SalesOrderID INT, OrderDate DATE, StartDate DATE, EndDate DATE, ListPrice FLOAT, OrderQty INT, TotalSale FLOAT)

INSERT INTO #AppliedListPrice (ProductID, Name, SalesOrderID, OrderDate, StartDate, EndDate, ListPrice, OrderQty, TotalSale)
SELECT Production.Product.ProductID, Production.Product.Name, Sales.SalesOrderHeader.SalesOrderID, OrderDate, 
	Production.ProductListPriceHistory.StartDate, Production.ProductListPriceHistory.EndDate, Production.ProductListPriceHistory.ListPrice, 
	SalesOrderDetail.OrderQty, (Production.ProductListPriceHistory.ListPrice * SalesOrderDetail.OrderQty) AS TotalSale

	FROM Production.Product, Sales.SalesOrderDetail, Sales.SalesOrderHeader, Production.ProductListPriceHistory

	WHERE Name='LL Road Frame - Black, 60' AND 	Product.ProductID=Sales.SalesOrderDetail.ProductID AND
		Production.Product.ProductID=Production.ProductListPriceHistory.ProductID AND
		Sales.SalesOrderDetail.SalesOrderID=Sales.SalesOrderHeader.SalesOrderID AND
		Production.ProductListPriceHistory.StartDate <= Sales.SalesOrderHeader.OrderDate AND
			(Sales.SalesOrderHeader.OrderDate < Production.ProductListPriceHistory.EndDate OR
			Production.ProductListPriceHistory.EndDate IS NULL)

SELECT * FROM #AppliedListPrice

CREATE TABLE #CostvRevenueJuly13 (ProductID INT, SalesOrderID INT, OrderDate DATE, Quantity INT, UnitCost FLOAT, UnitRevenue FLOAT, 
	TotalCost FLOAT, TotalRevenue FLOAT, TransactionProfit FLOAT)

INSERT INTO #CostvRevenueJuly13 (ProductID, SalesOrderID, OrderDate, Quantity, UnitCost, UnitRevenue, TotalCost, TotalRevenue, TransactionProfit)
SELECT DISTINCT Production.TransactionHistory.ProductID, Sales.SalesOrderDetail.SalesOrderID, Sales.SalesOrderHeader.OrderDate, 
	Sales.SalesOrderDetail.OrderQty, Production.TransactionHistory.ActualCost, Sales.SalesOrderDetail.UnitPrice, 
	Sales.SalesOrderDetail.OrderQty * Production.TransactionHistory.ActualCost, Sales.SalesOrderDetail.UnitPrice * Sales.SalesOrderDetail.OrderQty, 
	Sales.SalesOrderDetail.UnitPrice * Sales.SalesOrderDetail.OrderQty - Sales.SalesOrderDetail.OrderQty * Production.TransactionHistory.ActualCost

	FROM Production.TransactionHistory, Sales.SalesOrderDetail, Sales.SalesOrderHeader

	WHERE Production.TransactionHistory.ProductID=723 AND Production.TransactionHistory.ProductID=Sales.SalesOrderDetail.ProductID AND 
		Sales.SalesOrderDetail.SalesOrderID=Sales.SalesOrderHeader.SalesOrderID AND 
		Sales.SalesOrderHeader.OrderDate=Production.TransactionHistory.TransactionDate AND Production.TransactionHistory.ActualCost <> 0

CREATE TABLE #CostvRevenue (ProductID INT, SalesOrderID INT, OrderDate DATE, Quantity INT, UnitCost FLOAT, UnitRevenue FLOAT, 
	TotalCost FLOAT, TotalRevenue FLOAT, TransactionProfit FLOAT)

INSERT INTO #CostvRevenue (ProductID, SalesOrderID, OrderDate, Quantity, UnitCost, UnitRevenue, TotalCost, TotalRevenue, TransactionProfit)
SELECT DISTINCT Production.TransactionHistoryArchive.ProductID, Sales.SalesOrderDetail.SalesOrderID, Sales.SalesOrderHeader.OrderDate, 
	Sales.SalesOrderDetail.OrderQty, Production.TransactionHistoryArchive.ActualCost, Sales.SalesOrderDetail.UnitPrice, 
	Sales.SalesOrderDetail.OrderQty * Production.TransactionHistoryArchive.ActualCost, Sales.SalesOrderDetail.UnitPrice * 
	Sales.SalesOrderDetail.OrderQty, Sales.SalesOrderDetail.UnitPrice * Sales.SalesOrderDetail.OrderQty - Sales.SalesOrderDetail.OrderQty * 
	Production.TransactionHistoryArchive.ActualCost

	FROM Production.TransactionHistoryArchive, Sales.SalesOrderDetail, Sales.SalesOrderHeader

	WHERE Production.TransactionHistoryArchive.ProductID=723 AND Production.TransactionHistoryArchive.ProductID=Sales.SalesOrderDetail.ProductID AND 
		Sales.SalesOrderDetail.SalesOrderID=Sales.SalesOrderHeader.SalesOrderID AND 
		Sales.SalesOrderHeader.OrderDate=Production.TransactionHistoryArchive.TransactionDate AND Production.TransactionHistoryArchive.ActualCost <> 0

INSERT INTO #CostvRevenue
SELECT * FROM #CostvRevenueJuly13

SELECT * FROM #CostvRevenue