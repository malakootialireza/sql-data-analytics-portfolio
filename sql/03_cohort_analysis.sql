/*
Project: Customer Cohort Retention Analysis
Script: 03_cohort_analysis.sql
Purpose: Return a wide cohort retention table: CohortMonth, CohortSize, M0...M12.
Important: Months after the latest fully completed month are returned as NULL.
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
        cfo.CohortMonth,
        cma.ActivityMonth,
        DATEDIFF(MONTH, cfo.CohortMonth, cma.ActivityMonth) AS MonthIndex,
        cfo.CustomerID
    FROM CustomerFirstOrder cfo
    INNER JOIN CustomerMonthlyActivity cma
        ON cma.CustomerID = cfo.CustomerID
       AND cma.ActivityMonth >= cfo.CohortMonth
),
CohortSizes AS
(
    SELECT
        CohortMonth,
        COUNT(DISTINCT CustomerID) AS CohortSize
    FROM CustomerFirstOrder
    GROUP BY CohortMonth
),
Retention AS
(
    SELECT
        ca.CohortMonth,
        ca.MonthIndex,
        COUNT(DISTINCT ca.CustomerID) AS ActiveCustomers
    FROM CohortActivity ca
    GROUP BY ca.CohortMonth, ca.MonthIndex
),
LastCompleteMonth AS
(
    SELECT
        DATEFROMPARTS(
            YEAR(EOMONTH(MAX(OrderDate), -1)),
            MONTH(EOMONTH(MAX(OrderDate), -1)),
            1
        ) AS LastCompleteMonth
    FROM dbo.vw_CohortOrders_Clean
)
SELECT
    CONVERT(char(7), cs.CohortMonth, 126) AS CohortMonth,
    cs.CohortSize,

    CAST(MAX(CASE WHEN r.MonthIndex = 0
        AND DATEADD(MONTH, 0, cs.CohortMonth) <= lcm.LastCompleteMonth
        THEN 100.0 * r.ActiveCustomers / NULLIF(cs.CohortSize, 0) END) AS decimal(5,2)) AS M0,

    CAST(MAX(CASE WHEN r.MonthIndex = 1
        AND DATEADD(MONTH, 1, cs.CohortMonth) <= lcm.LastCompleteMonth
        THEN 100.0 * r.ActiveCustomers / NULLIF(cs.CohortSize, 0) END) AS decimal(5,2)) AS M1,

    CAST(MAX(CASE WHEN r.MonthIndex = 2
        AND DATEADD(MONTH, 2, cs.CohortMonth) <= lcm.LastCompleteMonth
        THEN 100.0 * r.ActiveCustomers / NULLIF(cs.CohortSize, 0) END) AS decimal(5,2)) AS M2,

    CAST(MAX(CASE WHEN r.MonthIndex = 3
        AND DATEADD(MONTH, 3, cs.CohortMonth) <= lcm.LastCompleteMonth
        THEN 100.0 * r.ActiveCustomers / NULLIF(cs.CohortSize, 0) END) AS decimal(5,2)) AS M3,

    CAST(MAX(CASE WHEN r.MonthIndex = 4
        AND DATEADD(MONTH, 4, cs.CohortMonth) <= lcm.LastCompleteMonth
        THEN 100.0 * r.ActiveCustomers / NULLIF(cs.CohortSize, 0) END) AS decimal(5,2)) AS M4,

    CAST(MAX(CASE WHEN r.MonthIndex = 5
        AND DATEADD(MONTH, 5, cs.CohortMonth) <= lcm.LastCompleteMonth
        THEN 100.0 * r.ActiveCustomers / NULLIF(cs.CohortSize, 0) END) AS decimal(5,2)) AS M5,

    CAST(MAX(CASE WHEN r.MonthIndex = 6
        AND DATEADD(MONTH, 6, cs.CohortMonth) <= lcm.LastCompleteMonth
        THEN 100.0 * r.ActiveCustomers / NULLIF(cs.CohortSize, 0) END) AS decimal(5,2)) AS M6,

    CAST(MAX(CASE WHEN r.MonthIndex = 7
        AND DATEADD(MONTH, 7, cs.CohortMonth) <= lcm.LastCompleteMonth
        THEN 100.0 * r.ActiveCustomers / NULLIF(cs.CohortSize, 0) END) AS decimal(5,2)) AS M7,

    CAST(MAX(CASE WHEN r.MonthIndex = 8
        AND DATEADD(MONTH, 8, cs.CohortMonth) <= lcm.LastCompleteMonth
        THEN 100.0 * r.ActiveCustomers / NULLIF(cs.CohortSize, 0) END) AS decimal(5,2)) AS M8,

    CAST(MAX(CASE WHEN r.MonthIndex = 9
        AND DATEADD(MONTH, 9, cs.CohortMonth) <= lcm.LastCompleteMonth
        THEN 100.0 * r.ActiveCustomers / NULLIF(cs.CohortSize, 0) END) AS decimal(5,2)) AS M9,

    CAST(MAX(CASE WHEN r.MonthIndex = 10
        AND DATEADD(MONTH, 10, cs.CohortMonth) <= lcm.LastCompleteMonth
        THEN 100.0 * r.ActiveCustomers / NULLIF(cs.CohortSize, 0) END) AS decimal(5,2)) AS M10,

    CAST(MAX(CASE WHEN r.MonthIndex = 11
        AND DATEADD(MONTH, 11, cs.CohortMonth) <= lcm.LastCompleteMonth
        THEN 100.0 * r.ActiveCustomers / NULLIF(cs.CohortSize, 0) END) AS decimal(5,2)) AS M11,

    CAST(MAX(CASE WHEN r.MonthIndex = 12
        AND DATEADD(MONTH, 12, cs.CohortMonth) <= lcm.LastCompleteMonth
        THEN 100.0 * r.ActiveCustomers / NULLIF(cs.CohortSize, 0) END) AS decimal(5,2)) AS M12

FROM CohortSizes cs
CROSS JOIN LastCompleteMonth lcm
LEFT JOIN Retention r
    ON r.CohortMonth = cs.CohortMonth
GROUP BY
    cs.CohortMonth,
    cs.CohortSize,
    lcm.LastCompleteMonth
ORDER BY cs.CohortMonth;
