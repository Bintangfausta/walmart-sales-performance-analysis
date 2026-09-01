-- =====================================================================
-- Walmart Sales Performance Analysis
-- Exploratory Data Analysis (EDA) & Business Questions
-- =====================================================================
-- Deskripsi:
-- File ini berisi query SQL untuk eksplorasi data dan menjawab
-- serangkaian business questions terkait performa penjualan Walmart
-- pada periode 2022-2023. Data yang digunakan merupakan hasil dari
-- proses data cleaning menggunakan Python.
-- Lihat: notebooks/01_data_cleaning.ipynb
-- =====================================================================


-- ---------------------------------------------------------------------
-- SECTION 1: Initial Data Exploration
-- ---------------------------------------------------------------------

SELECT * FROM walmart LIMIT 20;

SELECT COUNT(*) AS total_rows FROM walmart;

SELECT DISTINCT payment_method FROM walmart;

SELECT
    payment_method,
    COUNT(*) AS total_transactions
FROM walmart
GROUP BY payment_method;

SELECT COUNT(DISTINCT branch) AS total_branch FROM walmart;

SELECT MAX(quantity) AS max_quantity FROM walmart;
SELECT MIN(quantity) AS min_quantity FROM walmart;


-- ---------------------------------------------------------------------
-- SECTION 2: Business Questions & Solutions
-- ---------------------------------------------------------------------

-- Question 1: Find different payment methods, number of transactions,
-- and number of quantities sold for each method.

SELECT
    payment_method,
    COUNT(*) AS total_transactions,
    SUM(quantity) AS total_qty_sold
FROM walmart
GROUP BY payment_method;


-- Question 2: Identify the highest-rated category in each branch,
-- displaying the branch, category, and average rating.

SELECT branch, category, avg_rating
FROM (
    SELECT
        branch,
        category,
        AVG(rating) AS avg_rating,
        RANK() OVER (PARTITION BY branch ORDER BY AVG(rating) DESC) AS rank
    FROM walmart
    GROUP BY branch, category
) ranked
WHERE rank = 1
ORDER BY branch;


-- Question 3: Identify the busiest day for each branch based on the
-- number of transactions.

WITH daily_counts AS (
    SELECT
        branch,
        TO_CHAR(TO_DATE(date, 'DD/MM/YY'), 'Day') AS day_of_week,
        COUNT(invoice_id) AS transaction_count
    FROM walmart
    GROUP BY branch, day_of_week
),
ranked AS (
    SELECT
        branch,
        day_of_week,
        transaction_count,
        RANK() OVER (PARTITION BY branch ORDER BY transaction_count DESC) AS rnk
    FROM daily_counts
)
SELECT
    branch,
    TRIM(day_of_week) AS busiest_day,
    transaction_count
FROM ranked
WHERE rnk = 1
ORDER BY branch;


-- Question 4: Calculate the total quantity of items sold per payment
-- method. List payment_method and total_quantity.

SELECT
    payment_method,
    SUM(quantity) AS total_quantity
FROM walmart
GROUP BY payment_method;


-- Question 5: Determine the average, minimum, and maximum rating of
-- products for each city. List city, average_rating, min_rating, max_rating.

SELECT
    city,
    category,
    AVG(rating) AS average_rating,
    MIN(rating) AS min_rating,
    MAX(rating) AS max_rating
FROM walmart
GROUP BY 1, 2;


-- Question 6: Calculate the total profit for each category, where
-- total_profit = unit_price * quantity * profit_margin. List category
-- and total_profit, ordered from highest to lowest.

SELECT
    category,
    SUM(total * profit_margin) AS total_profit
FROM walmart
GROUP BY category
ORDER BY total_profit DESC;


-- Question 7: Determine the most common (preferred) payment method for
-- each branch. Display branch and preferred_payment_method.

SELECT
    branch,
    payment_method AS preferred_payment_method,
    total_transactions
FROM (
    SELECT
        branch,
        payment_method,
        COUNT(*) AS total_transactions,
        RANK() OVER (PARTITION BY branch ORDER BY COUNT(*) DESC) AS rank
    FROM walmart
    GROUP BY branch, payment_method
) ranked
WHERE rank = 1
ORDER BY branch;


-- Question 8: Categorize sales into 3 shifts (Morning, Afternoon,
-- Evening) and find the number of invoices for each shift, per branch.

SELECT
    branch,
    CASE
        WHEN EXTRACT(HOUR FROM (time::time)) < 12 THEN 'Morning'
        WHEN EXTRACT(HOUR FROM (time::time)) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS day_time,
    COUNT(*) AS total_invoices
FROM walmart
GROUP BY branch, day_time
ORDER BY branch, total_invoices DESC;


-- Question 9: Identify the 5 branches with the highest revenue decrease
-- ratio compared to the previous year (current year 2023 vs last year 2022).

-- decrease_ratio = (last_year_revenue - current_year_revenue) / last_year_revenue * 100

WITH revenue_2022 AS (
    SELECT
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2022
    GROUP BY branch
),
revenue_2023 AS (
    SELECT
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2023
    GROUP BY branch
)
SELECT
    ry2022.branch,
    ry2022.revenue AS last_year_revenue,
    ry2023.revenue AS current_year_revenue,
    ROUND(
        (ry2022.revenue - ry2023.revenue)::numeric / ry2022.revenue::numeric * 100,
        2
    ) AS revenue_decrease_ratio
FROM revenue_2022 AS ry2022
JOIN revenue_2023 AS ry2023 ON ry2022.branch = ry2023.branch
WHERE ry2022.revenue > ry2023.revenue
ORDER BY revenue_decrease_ratio DESC
LIMIT 5;
