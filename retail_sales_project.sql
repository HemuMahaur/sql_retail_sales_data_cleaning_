
 --   RETAIL SALES ANALYTICS PROJECT
  --  SQL | Data Cleaning | Data Analyis

USE retail_data_set;
SET SQL_SAFE_UPDATES=0 ;

-- View Dataset
SELECT *FROM retail_sales_customer;

-- Rename columns for easier SQL queries
--  Standardize column names


ALTER TABLE retail_sales_customer
CHANGE `Transaction ID` transaction_id INT;

ALTER TABLE retail_sales_customer
CHANGE `Customer ID` customer_id VARCHAR(50);

ALTER TABLE retail_sales_customer
CHANGE `Product Category` product_category VARCHAR(50);

ALTER TABLE retail_sales_customer
CHANGE `Price per Unit` price_per_unit DECIMAL(10,2);

ALTER TABLE retail_sales_customer
CHANGE `Total Amount` total_amount DECIMAL(10,2);

ALTER TABLE retail_sales_customer
CHANGE `Date` sale_date DATE;

-- STEP 2: Total Records

SELECT COUNT(*) AS total_records
FROM retail_sales_customer;

-- =====================================================
-- STEP 3: Check Duplicate Customers
-- =====================================================
SELECT
customer_id,
COUNT(*) duplicate_count
FROM retail_sales_customer
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- STEP 4: Check Missing Values

SELECT
SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) customer_nulls,
SUM(CASE WHEN age IS NULL THEN 1 ELSE 0 END) age_nulls,
SUM(CASE WHEN gender IS NULL THEN 1 ELSE 0 END) gender_nulls,
SUM(CASE WHEN product_category IS NULL THEN 1 ELSE 0 END) category_nulls,
SUM(CASE WHEN quantity IS NULL THEN 1 ELSE 0 END) quantity_nulls,
SUM(CASE WHEN total_amount IS NULL THEN 1 ELSE 0 END) amount_nulls
FROM retail_sales_customer;

-- STEP 5: Remove Records With Missing Customer ID

DELETE FROM retail_sales_customer
WHERE customer_id IS NULL;


--  Fill Missing Age Values

UPDATE retail_sales_customer
SET age =
(
SELECT ROUND(AVG(age))
FROM
(
SELECT age
FROM retail_sales_customer
) x
)
WHERE age IS NULL;

-- =====================================================
-- STEP 7: Remove Extra Spaces
-- =====================================================
UPDATE retail_sales_customer
SET gender = TRIM(gender),
product_category = TRIM(product_category);


--  Standardize Gender Values

UPDATE retail_sales_customer
SET gender = 'Male'
WHERE LOWER(gender) IN ('m','male');

UPDATE retail_sales_customer
SET gender = 'Female'
WHERE LOWER(gender) IN ('f','female');


-- STEP 9: Check Invalid Revenue
-- =====================================================
SELECT *
FROM retail_sales_customer
WHERE total_amount <= 0;


--  Check Missing Dates

SELECT *
FROM retail_sales_customer
WHERE sale_date IS NULL;


--  Total Unique Customers

SELECT COUNT(DISTINCT customer_id) AS unique_customers
FROM retail_sales_customer;


-- Product Categories
SELECT DISTINCT product_category
FROM retail_sales_customer;


-- Revenue Outlier Detection

SELECT *
FROM retail_sales_customer
WHERE total_amount >
(
SELECT AVG(total_amount)
+ 3 * STDDEV(total_amount)
FROM retail_sales_customer
);


--  Sales Date Range

SELECT
MIN(sale_date) AS start_date,
MAX(sale_date) AS end_date,
COUNT(*) AS total_transactions
FROM retail_sales_customer;


-- STEP 15: Customer Distribution By Gender

SELECT
gender,
COUNT(*) AS customer_count
FROM retail_sales_customer
GROUP BY gender;


-- Revenue By Category

SELECT
product_category,
SUM(total_amount) AS revenue
FROM retail_sales_customer
GROUP BY product_category
ORDER BY revenue DESC;


--  Customer Segmentation

WITH customer_sales AS
(
SELECT
customer_id,
SUM(total_amount) AS revenue
FROM retail_sales_customer
GROUP BY customer_id
)
SELECT *,
CASE
WHEN revenue > 10000 THEN 'High Value'
WHEN revenue > 5000 THEN 'Medium Value'
ELSE 'Low Value'
END AS customer_segment
FROM customer_sales;


--  Total Revenue
SELECT SUM(total_amount) AS total_revenue
FROM retail_sales_customer;


-- Total Customers

SELECT COUNT(DISTINCT customer_id) AS total_customers
FROM retail_sales_customer;


-- Monthly Revenue Trend

SELECT
YEAR(sale_date) AS year_,
MONTH(sale_date) AS month_,
SUM(total_amount) AS revenue
FROM retail_sales_customer
GROUP BY YEAR(sale_date), MONTH(sale_date)
ORDER BY year_, month_;


--  Top 10 Customers

SELECT
customer_id,
SUM(total_amount) AS revenue
FROM retail_sales_customer
GROUP BY customer_id
ORDER BY revenue DESC
LIMIT 10;


-- Revenue By Gender

SELECT
gender,
SUM(total_amount) AS revenue
FROM retail_sales_customer
GROUP BY gender;


-- Customer Lifetime Value

SELECT
customer_id,
SUM(total_amount) AS lifetime_value
FROM retail_sales_customer
GROUP BY customer_id
ORDER BY lifetime_value DESC;


-- Revenue By Age Group

SELECT
CASE
WHEN age BETWEEN 18 AND 25 THEN '18-25'
WHEN age BETWEEN 26 AND 35 THEN '26-35'
WHEN age BETWEEN 36 AND 45 THEN '36-45'
ELSE '46+'
END AS age_group,
SUM(total_amount) AS revenue
FROM retail_sales_customer
GROUP BY age_group;


--  Running Revenue

SELECT
sale_date,
total_amount,
SUM(total_amount)
OVER(ORDER BY sale_date) AS running_revenue
FROM retail_sales_customer;


--  Repeat Customers

SELECT
customer_id,
COUNT(*) AS orders_count
FROM retail_sales_customer
GROUP BY customer_id
HAVING COUNT(*) > 1;

SET SQL_SAFE_UPDATES = 1;