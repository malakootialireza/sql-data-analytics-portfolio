# Customer Cohort Retention Analysis

A portfolio project demonstrating customer cohort analysis using SQL Server (T-SQL). The project uses a **synthetic e-commerce dataset** so it can be shared publicly without exposing business or customer information.

## Business Problem

A business wants to understand whether customers return after their first purchase and how retention changes across acquisition cohorts.

## Questions Answered

- How many customers belong to each monthly cohort?
- What percentage of each cohort is active in subsequent months?
- How does retention vary by cohort and month since first purchase?
- Which periods show the largest drop in returning customers?

## Dataset

`data/sample_data.csv` contains synthetic order-level data with these columns:

| Column | Description |
|---|---|
| `OrderID` | Unique order identifier |
| `CustomerID` | Synthetic customer identifier |
| `OrderDate` | Order date in ISO format (`YYYY-MM-DD`) |
| `OrderAmount` | Order amount in arbitrary currency units |

The dataset is intentionally small and suitable for learning, demonstration, and portfolio review.

## Methodology

1. Explore the order data and validate key fields.
2. Define each customer's cohort as the month of their first order.
3. Count distinct active customers by cohort and calendar month.
4. Calculate `MonthIndex` (`0` = cohort month, `1` = next calendar month, etc.).
5. Calculate retention as active customers in a cohort-month divided by the original cohort size.
6. Do not report incomplete calendar months as completed periods. The SQL uses the latest date available in the dataset to determine the last fully completed month.

## SQL Scripts

Run the scripts in order:

1. `sql/01_data_exploration.sql`
2. `sql/02_data_preparation.sql`
3. `sql/03_cohort_analysis.sql`
4. `sql/04_retention_summary.sql`

The scripts assume the CSV has been imported into SQL Server as `dbo.CohortOrders`. See **How to Run** below.

## How to Run

1. In SQL Server Management Studio (SSMS), create a database, for example `CohortPortfolio`.
2. Import `data/sample_data.csv` using the SSMS Import Flat File wizard (or the Import Data wizard).
3. Name the imported table `dbo.CohortOrders`.
4. Ensure the column types are:
   - `OrderID`: `varchar(20)`
   - `CustomerID`: `varchar(20)`
   - `OrderDate`: `date`
   - `OrderAmount`: `decimal(12,2)`
5. Open and execute the SQL scripts in order.

> If you import the date column as text, convert it to `date` before running the analysis. The SQL scripts assume `OrderDate` is already a date type.

## Metric Definitions

- **Cohort:** Month of a customer's first order.
- **Cohort Size:** Distinct number of customers whose first order occurred in that cohort month.
- **Active Customer:** A customer with at least one order in the relevant calendar month.
- **MonthIndex:** Number of calendar-month boundaries between the cohort month and activity month.
- **Retention Rate:** `ActiveCustomers / CohortSize * 100`.
- **M0:** Activity in the cohort month; normally 100% when each cohort is defined by first purchase.

## Limitations

- This is synthetic data and does not represent a real business.
- Retention is based on at least one order in a calendar month; other businesses may define activity differently.
- The latest fully completed month is inferred from the latest order date in the dataset. In a production analysis, a trusted data-refresh date or reporting calendar may be preferable.

## Skills Demonstrated

SQL Server, T-SQL, data validation, CTEs, date functions, distinct counting, cohort construction, retention metrics, and business-oriented documentation.
