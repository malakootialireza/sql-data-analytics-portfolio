/*
Project: Customer Cohort Retention Analysis
Script: 01_data_exploration.sql
Purpose: Inspect the imported synthetic order data.
Expected table: dbo.CohortOrders
*/

-- 1. Preview records
SELECT TOP (20)
    OrderID,
    CustomerID,
    OrderDate,
    OrderAmount
FROM dbo.CohortOrders
ORDER BY OrderDate, OrderID;

-- 2. Dataset size and date range
SELECT
    COUNT(*) AS OrderRows,
    COUNT(DISTINCT OrderID) AS DistinctOrders,
    COUNT(DISTINCT CustomerID) AS DistinctCustomers,
    MIN(OrderDate) AS FirstOrderDate,
    MAX(OrderDate) AS LatestOrderDate
FROM dbo.CohortOrders;

-- 3. Check nulls
SELECT
    SUM(CASE WHEN OrderID IS NULL THEN 1 ELSE 0 END) AS NullOrderID,
    SUM(CASE WHEN CustomerID IS NULL THEN 1 ELSE 0 END) AS NullCustomerID,
    SUM(CASE WHEN OrderDate IS NULL THEN 1 ELSE 0 END) AS NullOrderDate,
    SUM(CASE WHEN OrderAmount IS NULL THEN 1 ELSE 0 END) AS NullOrderAmount
FROM dbo.CohortOrders;

-- 4. Check duplicate order IDs
SELECT
    OrderID,
    COUNT(*) AS RowCount
FROM dbo.CohortOrders
GROUP BY OrderID
HAVING COUNT(*) > 1;

-- 5. Check invalid values
SELECT *
FROM dbo.CohortOrders
WHERE OrderAmount < 0
   OR OrderDate IS NULL
   OR CustomerID IS NULL;
