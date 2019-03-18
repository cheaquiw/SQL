SELECT Name, SalesOrderDetail.SalesOrderID, OrderQty, Production.ProductListPriceHistory.ListPrice, 
	(Production.ProductListPriceHistory.ListPrice * SalesOrderDetail.OrderQty) AS ListedTotalSale, UnitPrice AS SellPrice, (OrderQty * UnitPrice) 
	AS ActualTotalSale, ((OrderQty * UnitPrice) - (Production.ProductListPriceHistory.ListPrice * SalesOrderDetail.OrderQty)) AS DifferenceOfRevenue, 
	DiscountPct, CONVERT(VARCHAR, SpecialOffer_inmem.StartDate, 110) AS StartDiscount, CONVERT(VARCHAR, SpecialOffer_inmem.EndDate, 110) AS EndDiscount,
	CONVERT(VARCHAR, OrderDate, 110) AS OrderDate

	FROM Production.Product, Sales.SalesOrderDetail, Sales.SalesOrderHeader, Sales.SpecialOffer_inmem, Production.ProductListPriceHistory

	WHERE Production.Product.ProductID=723 AND Sales.SpecialOffer_inmem.Description LIKE 'LL Road Frame%' AND 
	Production.Product.ProductID=Sales.SalesOrderDetail.ProductID AND Sales.SalesOrderDetail.SalesOrderID=Sales.SalesOrderHeader.SalesOrderID AND
	Production.Product.ProductID=Production.ProductListPriceHistory.ProductID AND 
	Production.ProductListPriceHistory.StartDate <= Sales.SalesOrderHeader.OrderDate AND
	(Sales.SalesOrderHeader.OrderDate < Production.ProductListPriceHistory.EndDate OR
	Production.ProductListPriceHistory.EndDate IS NULL) AND
	(Sales.SpecialOffer_inmem.StartDate <= Sales.SalesOrderHeader.OrderDate AND 
	Sales.SpecialOffer_inmem.EndDate > Sales.SalesOrderHeader.OrderDate)


CREATE TABLE #OrdersDuringDiscount (Name VARCHAR(100), SalesOrderID INT, OrderQty INT, ListPrice FLOAT, ListedTotalSale FLOAT, SellPrice FLOAT, 
	ActualTotalSale FLOAT, DifferenceOfRevenue FLOAT, DiscountPct FLOAT, StartDiscount DATE, EndDiscount DATE, OrderDate DATE)

INSERT INTO #OrdersDuringDiscount (Name, SalesOrderID, OrderQty, ListPrice, ListedTotalSale, SellPrice, ActualTotalSale, DifferenceOfRevenue, 
	DiscountPct, StartDiscount, EndDiscount, OrderDate)

	SELECT Name, SalesOrderDetail.SalesOrderID, OrderQty, Production.ProductListPriceHistory.ListPrice,  (Production.ProductListPriceHistory.ListPrice * SalesOrderDetail.OrderQty) AS ListedTotalSale, UnitPrice AS SellPrice, (OrderQty * UnitPrice) 
		AS ActualTotalSale, ((OrderQty * UnitPrice) - (Production.ProductListPriceHistory.ListPrice * SalesOrderDetail.OrderQty)) AS DifferenceOfRevenue, DiscountPct, CONVERT(VARCHAR, SpecialOffer_inmem.StartDate, 110) AS StartDiscount, CONVERT(VARCHAR, SpecialOffer_inmem.EndDate, 110) AS EndDiscount, CONVERT(VARCHAR, OrderDate, 110) AS OrderDate

		FROM Production.Product, Sales.SalesOrderDetail, Sales.SalesOrderHeader, Sales.SpecialOffer_inmem, Production.ProductListPriceHistory

		WHERE Production.Product.ProductID=723 AND Sales.SpecialOffer_inmem.Description LIKE 'LL Road Frame%' AND 
			Production.Product.ProductID=Sales.SalesOrderDetail.ProductID AND Sales.SalesOrderDetail.SalesOrderID=Sales.SalesOrderHeader.SalesOrderID AND
			Production.Product.ProductID=Production.ProductListPriceHistory.ProductID AND 
			Production.ProductListPriceHistory.StartDate <= Sales.SalesOrderHeader.OrderDate AND
			(Sales.SalesOrderHeader.OrderDate < Production.ProductListPriceHistory.EndDate OR
			Production.ProductListPriceHistory.EndDate IS NULL) AND
			(Sales.SpecialOffer_inmem.StartDate <= Sales.SalesOrderHeader.OrderDate AND 
			Sales.SpecialOffer_inmem.EndDate > Sales.SalesOrderHeader.OrderDate)
