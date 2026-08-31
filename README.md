# Walmart Retail Branch Performance and Sales Trend Analysis, 2022–2023

## 1. Executive Summary

This project analyzes transactional sales data across multiple Walmart branches to uncover the operational and revenue drivers behind branch-level performance. The analysis moves beyond simple reporting to answer a core business question: **which branches, categories, and customer behaviors are driving — or dragging — revenue, and what should management do about it?**

### Business Goals & Objectives

- Identify which product categories and branches consistently deliver the highest customer satisfaction and profitability.
- Understand customer payment preferences to inform point-of-sale and partnership strategy.
- Detect operational peak periods (day of week, time of day) to optimize staffing and inventory allocation.
- Quantify Year-over-Year (2022 vs. 2023) revenue performance at the branch level to flag underperforming locations for management intervention.
- Translate raw transactional data into a decision-ready set of insights and strategic recommendations for retail leadership.

---

## 2. Tech Stack / Tools Used

| Layer | Tools |
|---|---|
| Data Cleaning & Integration | Python, Pandas |
| Database | PostgreSQL |
| Data Loading (ETL) | SQLAlchemy, psycopg2 |
| Analysis & Querying | SQL (CTEs, Window Functions, Aggregations) |
| Environment | Jupyter Notebook |

---

## 3. Business Problems Addressed

The analysis was structured around the following business questions:

1. What are the most-used payment methods, and how many transactions and units sold does each represent?
2. Which product category earns the highest average customer rating in each branch?
3. Which day of the week is the busiest (by transaction volume) for each branch?
4. What is the total quantity of items sold, broken down by payment method?
5. What are the average, minimum, and maximum product ratings by city and category?
6. Which product category generates the highest total profit (unit price × quantity × profit margin)?
7. What is the most preferred payment method in each individual branch?
8. How do sales volumes shift across Morning, Afternoon, and Evening shifts?
9. Which branches show the sharpest revenue decline from 2022 to 2023, and by how much?

---

## 4. Data Pipeline & Methodology

The project follows a standard **ETL → Analysis** workflow, split across two stages:

**Stage 1 — Data Cleaning & Integration (Python / Pandas)**
- Ingested the raw dataset (**10,051 rows × 11 columns**) from `Walmart.csv`.
- Performed data quality checks using `.info()`, `.describe()`, and `.isnull().sum()` to profile data types, missing values, and statistical outliers.
- Removed exact duplicate transactions using `drop_duplicates()`.
- Dropped incomplete records containing missing values (`dropna()`), reducing the dataset to **9,969 clean rows**.
- Cleaned the `unit_price` field by stripping currency symbols (`$`) and casting it to a numeric (float) type for calculation.
- Standardized column naming conventions to lowercase for consistency with SQL querying.
- Engineered a new `total` column (`unit_price × quantity`) to represent transaction-level revenue.
- Exported the cleaned dataset to `walmart_clean_data.csv` and loaded it into a PostgreSQL database (`walmart` table) via `SQLAlchemy`, with a row-count validation query to confirm a successful, lossless load.

**Stage 2 — Exploratory Data Analysis & Business Querying (SQL / PostgreSQL)**
- Queried the cleaned `walmart` table directly in PostgreSQL to answer each of the nine business problems above.
- Applied `GROUP BY` aggregations to summarize payment methods, ratings, and quantities.
- Used `CASE WHEN` logic to segment transactions into Morning / Afternoon / Evening shifts based on transaction timestamps.
- Leveraged **Window Functions** (`RANK() OVER (PARTITION BY ...)`) to identify the top-ranked category, day, and payment method *per branch*, rather than globally.
- Built **CTEs (Common Table Expressions)** to isolate 2022 and 2023 revenue by branch, then **joined** the two periods to calculate a Year-over-Year revenue decline ratio, surfacing the five branches most in need of strategic attention.

---

## 5. Key Business Insights & Recommendations

> **Note:** The figures below are placeholders. Replace `[X]%` and `[Branch Name]` with the actual results generated from your query outputs before publishing.

**Insight 1 — Payment Method Concentration**
`[Payment Method, e.g., Ewallet]` accounts for `[X]%` of all transactions and `[X]` units sold, making it the dominant checkout channel.
**Recommendation:** Prioritize this channel in loyalty and cashback promotions, and ensure infrastructure (uptime, transaction speed) is prioritized for this payment rail during peak hours.

**Insight 2 — Category Performance Varies Sharply by Branch**
The top-rated category is not uniform across branches — `[Branch Name]` rates `[Category Name]` highest at `[X.X]` average, while other branches favor different categories.
**Recommendation:** Move away from a one-size-fits-all merchandising strategy; tailor category placement and promotional focus per branch based on local customer preference.

**Insight 3 — Predictable Weekly Traffic Patterns**
`[Day of Week]` is consistently the busiest day across the majority of branches, with transaction counts peaking at `[X]` transactions.
**Recommendation:** Align staff scheduling and inventory replenishment cycles to front-load resources ahead of this peak day, reducing checkout wait times and stockouts.

**Insight 4 — Profitability Is Not Evenly Distributed Across Categories**
The `[Category Name]` category generates the highest total profit at `[$X]`, despite not necessarily having the highest sales volume.
**Recommendation:** Shift marketing spend and shelf space toward high-margin categories rather than optimizing purely for unit volume.

**Insight 5 — Significant Year-over-Year Revenue Decline at Specific Branches**
Five branches — led by `[Branch Name]` — recorded a revenue decline of up to `[X]%` from 2022 to 2023.
**Recommendation:** Conduct a root-cause audit (local competition, staffing, stock availability, or regional demand shifts) at these five branches, and consider a targeted revenue-recovery plan, such as localized promotions or operational review.

---

## 6. Repository Structure

```
walmart-sales-performance-analysis/
│
├── README.md                          # Project overview and business insights
├── data/
│   ├── Walmart.csv                    # Raw source dataset (10,051 rows)
│   └── walmart_clean_data.csv         # Cleaned dataset after Python processing (9,969 rows)
│
├── notebooks/
│   └── walmart_data_cleaning.ipynb    # Data cleaning, feature engineering & PostgreSQL loading (Python/Pandas)
│
├── sql/
│   └── EDA & Business Problem.sql     # Exploratory data analysis & 9 business problem queries (PostgreSQL)
│
└── assets/                            # (Optional) Charts, dashboard screenshots, or exported visuals
```

---

### Author's Note
This project demonstrates an end-to-end analytics workflow — from raw, messy transactional data to a clean relational database, through to SQL-driven business intelligence — reflecting the type of analysis a retail data analyst would deliver to support branch-level decision-making.
