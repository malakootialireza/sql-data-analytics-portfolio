/*
Project: Customer Cohort Retention Analysis
Script: 02_data_preparation.sql
Purpose: Create a clean view used by the cohort analysis.
Expected table: dbo.CohortOrders
*/

CREATE OR ALTER VIEW dbo.vw_CohortOrders_Clean
AS
SELECT
    OrderID,
    CustomerID,
    CAST(OrderDate AS date) AS OrderDate,
    CAST(OrderAmount AS decimal(12, 2)) AS OrderAmount
FROM dbo.CohortOrders
WHERE OrderID IS NOT NULL
  AND CustomerID IS NOT NULL
  AND OrderDate IS NOT NULL
  AND OrderAmount IS NOT NULL
  AND OrderAmount >= 0;
GO

-- Validate the clean view
SELECT
    COUNT(*) AS CleanOrderRows,
    COUNT(DISTINCT OrderID) AS DistinctOrders,
    COUNT(DISTINCT CustomerID) AS DistinctCustomers,
    MIN(OrderDate) AS FirstOrderDate,
    MAX(OrderDate) AS LatestOrderDate
FROM dbo.vw_CohortOrders_Clean;
