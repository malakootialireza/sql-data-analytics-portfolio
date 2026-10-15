/*
Project: Customer Cohort Retention Analysis
Script: 04_retention_summary.sql
Purpose: Summarize average retention by month index.
This long-format result is useful for a line chart in Metabase or Power BI.
Expected view: dbo.vw_CohortOrders_Clean
*/

WITH CustomerFirstOrder AS
(
    SELECT
        CustomerID,
        DATEFROMPARTS(YEAR(MIN(OrderDate)), MONTH(MIN(OrderDate)), 1) AS CohortMonth
    FROM dbo.vw_CohortOrders_Clean
    GROUP BY CustomerID
),
CustomerMonthlyActivity AS
(
    SELECT DISTINCT
        CustomerID,
        DATEFROMPARTS(YEAR(OrderDate), MONTH(OrderDate), 1) AS ActivityMonth
    FROM dbo.vw_CohortOrders_Clean
),
CohortActivity AS
(
    SELECT
        f.CohortMonth,
        a.ActivityMonth,
        DATEDIFF(MONTH, f.CohortMonth, a.ActivityMonth) AS MonthIndex,
        f.CustomerID
    FROM CustomerFirstOrder f
    INNER JOIN CustomerMonthlyActivity a
        ON a.CustomerID = f.CustomerID
       AND a.ActivityMonth >= f.CohortMonth
),
CohortSizes AS
(
    SELECT CohortMonth, COUNT(*) AS CohortSize
    FROM CustomerFirstOrder
    GROUP BY CohortMonth
),
CohortRetention AS
(
    SELECT
        ca.CohortMonth,
        ca.MonthIndex,
        COUNT(DISTINCT ca.CustomerID) AS ActiveCustomers,
        cs.CohortSize,
        CAST(100.0 * COUNT(DISTINCT ca.CustomerID) / NULLIF(cs.CohortSize, 0) AS decimal(7,2)) AS RetentionRate
    FROM CohortActivity ca
    INNER JOIN CohortSizes cs
        ON cs.CohortMonth = ca.CohortMonth
    GROUP BY ca.CohortMonth, ca.MonthIndex, cs.CohortSize
),
LastCompleteMonth AS
(
    SELECT DATEFROMPARTS(
        YEAR(EOMONTH(MAX(OrderDate), -1)),
        MONTH(EOMONTH(MAX(OrderDate), -1)),
        1
    ) AS LastCompleteMonth
    FROM dbo.vw_CohortOrders_Clean
)
SELECT
    cr.MonthIndex,
    COUNT(*) AS CohortsIncluded,
    CAST(AVG(cr.RetentionRate) AS decimal(7,2)) AS AverageRetentionRate
FROM CohortRetention cr
CROSS JOIN LastCompleteMonth lcm
WHERE DATEADD(MONTH, cr.MonthIndex, cr.CohortMonth) <= lcm.LastCompleteMonth
GROUP BY cr.MonthIndex
ORDER BY cr.MonthIndex;
