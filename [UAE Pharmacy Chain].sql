USE [UAE Pharmacy Chain];
GO

-----------------------------------------------------
print'Drop existing tables...';
-----------------------------------------------------
DROP TABLE IF EXISTS August_sales;
DROP TABLE IF EXISTS September_sales;
DROP TABLE IF EXISTS October_sales;

-----------------------------------------------------
print'Creating tables....';
-----------------------------------------------------
CREATE TABLE August_sales (
    order_number NVARCHAR(100) NOT NULL,
    item_number NVARCHAR(100) NOT NULL,
    item_name NVARCHAR(100) NOT NULL,
    quantity INT NOT NULL,
    order_date DATE,
    order_time TIME,
    unit_price DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    item_category_level_A NVARCHAR(100),
    item_category_level_B NVARCHAR(100),
    employee_id NVARCHAR(100),
    employee_team NVARCHAR(100),
    pharmacy_no NVARCHAR(100),
    city NVARCHAR(100),
    payment_type NVARCHAR(100),
    prescription_type NVARCHAR(100),
    customer_id NVARCHAR(100),
    order_total DECIMAL(10,2)
);

CREATE TABLE September_sales (
    order_number NVARCHAR(100) NOT NULL,
    item_number NVARCHAR(100) NOT NULL,
    item_name NVARCHAR(100) NOT NULL,
    quantity INT NOT NULL,
    order_date DATE,
    order_time TIME,
    unit_price DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    item_category_level_A NVARCHAR(100),
    item_category_level_B NVARCHAR(100),
    employee_id NVARCHAR(100),
    employee_team NVARCHAR(100),
    pharmacy_no NVARCHAR(100),
    city NVARCHAR(100),
    payment_type NVARCHAR(100),
    prescription_type NVARCHAR(100),
    customer_id NVARCHAR(100),
    order_total DECIMAL(10,2)
);

CREATE TABLE October_sales (
    order_number NVARCHAR(100) NOT NULL,
    item_number NVARCHAR(100) NOT NULL,
    item_name NVARCHAR(100) NOT NULL,
    quantity INT NOT NULL,
    order_date DATE,
    order_time TIME,
    unit_price DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    item_category_level_A NVARCHAR(100),
    item_category_level_B NVARCHAR(100),
    employee_id NVARCHAR(100),
    employee_team NVARCHAR(100),
    pharmacy_no NVARCHAR(100),
    city NVARCHAR(100),
    payment_type NVARCHAR(100),
    prescription_type NVARCHAR(100),
    customer_id NVARCHAR(100),
    order_total DECIMAL(10,2)
);

-----------------------------------------------------
print'Bulk Insert...';
-----------------------------------------------------
SET DATEFORMAT dmy;

BULK INSERT August_sales
FROM 'D:\SQL\Pharmacy chain\pharmacy_aug2025_v7_full.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

BULK INSERT September_sales
FROM 'D:\SQL\Pharmacy chain\pharmacy_sep2025_v7_full.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

BULK INSERT October_sales
FROM 'D:\SQL\Pharmacy chain\pharmacy_oct2025_v7_full.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

-----------------------------------------------------
print'Combine into Master Table...';
-----------------------------------------------------
DROP TABLE IF EXISTS Master_sales;

SELECT * INTO Master_sales
FROM August_sales
UNION ALL
SELECT * FROM September_sales
UNION ALL
SELECT * FROM October_sales;

-----------------------------------------------------
print'creating Indexes for faster calling...';
-----------------------------------------------------
DROP INDEX IF EXISTS idx_order_date ON Master_sales;
CREATE CLUSTERED INDEX idx_order_date
ON Master_sales(order_date);

DROP INDEX IF EXISTS idx_composite ON Master_sales;
CREATE NONCLUSTERED INDEX idx_composite
ON Master_sales(order_number, order_date, employee_team);

-----------------------------------------------------
PRINT '=============================';
print'Analyzing data......';
-----------------------------------------------------
-- Total Sales Overall
-----------------------------------------------------

SELECT
    SUM(order_total) AS total_sales,
    COUNT(DISTINCT order_number) AS total_orders,
    COUNT(DISTINCT customer_id) AS total_customers
FROM Master_sales;
GO

-----------------------------------------------------
-- Sales per City
-----------------------------------------------------
DROP VIEW IF EXISTS sales_per_city;
GO

CREATE VIEW sales_per_city AS
SELECT
    city,
    COUNT(DISTINCT order_number) AS total_orders,
    COUNT(DISTINCT customer_id) AS total_customers,
    SUM(order_total) AS total_sales,
    SUM(order_total) / COUNT(DISTINCT order_number) AS basket_value,
    CAST(CAST(SUM(quantity) AS DECIMAL(10,2)) / COUNT(DISTINCT order_number) AS DECIMAL(10,2)) AS basket_size
FROM Master_sales
GROUP BY city;
GO

-----------------------------------------------------
-- Sales per Pharmacy
-----------------------------------------------------
DROP VIEW IF EXISTS Sales_per_pharmacy;
GO

CREATE VIEW Sales_per_pharmacy AS
SELECT
    pharmacy_no,
    COUNT(DISTINCT order_number) AS total_orders,
    COUNT(DISTINCT customer_id) AS total_customers,
    SUM(order_total) AS total_sales,
    SUM(order_total) / COUNT(DISTINCT order_number) AS basket_value,
    CAST(CAST(SUM(quantity) AS DECIMAL(10,2)) / COUNT(DISTINCT order_number) AS DECIMAL(10,2)) AS basket_size
FROM Master_sales
GROUP BY pharmacy_no;
GO

-----------------------------------------------------
-- Top Five Performing Employees in Every Team
-----------------------------------------------------
DROP VIEW IF EXISTS best_sellers;
GO

CREATE VIEW best_sellers AS
WITH cte AS (
    SELECT
        employee_team,
        employee_id,
        COUNT(DISTINCT order_number) AS total_orders,
        COUNT(DISTINCT customer_id) AS total_customers,
        SUM(order_total) AS total_sales,
        SUM(order_total) / COUNT(DISTINCT order_number) AS basket_value,
        CAST(CAST(SUM(quantity) AS DECIMAL(10,2)) / COUNT(DISTINCT order_number) AS DECIMAL(10,2)) AS basket_size,
        DENSE_RANK() OVER(PARTITION BY employee_team ORDER BY SUM(order_total) DESC) AS rn
    FROM Master_sales
    GROUP BY employee_team, employee_id
)
SELECT * FROM cte
WHERE rn <= 5;
GO

-----------------------------------------------------
-- Average Daily Sales
-----------------------------------------------------
SELECT AVG(daily_sales) AS average_daily_sales
FROM (
    SELECT order_date, SUM(order_total) AS daily_sales
    FROM Master_sales
    GROUP BY order_date
) AS t;

-- Average Daily Sales per Team
SELECT employee_team,
       AVG(daily_sales) AS average_daily_sales,
       AVG(daily_orders) AS average_daily_orders
FROM (
    SELECT employee_team, order_date,
           SUM(order_total) AS daily_sales,
           COUNT(DISTINCT order_number) AS daily_orders
    FROM Master_sales
    GROUP BY employee_team, order_date
) AS t
GROUP BY employee_team;

-----------------------------------------------------
-- Sales per Month
-----------------------------------------------------
SELECT DATENAME(MONTH, order_date) AS month,
       SUM(order_total) AS total_sales
FROM Master_sales
GROUP BY DATENAME(MONTH, order_date);

-----------------------------------------------------
-- Sales Across Days of the Week
-----------------------------------------------------
SELECT DATENAME(WEEKDAY, order_date) AS weekday,
       SUM(order_total) AS total_sales
FROM Master_sales
GROUP BY DATENAME(WEEKDAY, order_date);

-- Sales Across Every Hour (Rush Hours)
SELECT DATENAME(HOUR, order_time) AS daily_hours,
       COUNT(DISTINCT order_number) AS order_count,
       SUM(order_total) AS total_sales
FROM Master_sales
GROUP BY DATENAME(HOUR, order_time)
ORDER BY daily_hours;

-----------------------------------------------------
-- Sales per Category
-----------------------------------------------------
SELECT item_category_level_A,
       SUM(order_total) AS total_sales,
       CAST(CAST(SUM(order_total) * 100 / (SELECT SUM(order_total) FROM Master_sales) AS DECIMAL(10,2)) AS NVARCHAR) + '%' AS percent_cont
FROM Master_sales
GROUP BY item_category_level_A
ORDER BY total_sales DESC;

-- Sales per Category Level B
SELECT item_category_level_B,
       SUM(order_total) AS total_sales,
       CAST(CAST(SUM(order_total) * 100 / (SELECT SUM(order_total) FROM Master_sales) AS DECIMAL(10,2)) AS NVARCHAR) + '%' AS percent_cont
FROM Master_sales
GROUP BY item_category_level_B
ORDER BY total_sales DESC;

-----------------------------------------------------
-- Payment Type & Percent Contribution
-----------------------------------------------------
SELECT prescription_type,
       SUM(order_total) AS total_sales,
       CAST(CAST(SUM(order_total) * 100 / (SELECT SUM(order_total) FROM Master_sales) AS DECIMAL(10,2)) AS NVARCHAR) + '%' AS perc_contribution
FROM Master_sales
GROUP BY prescription_type;

-----------------------------------------------------
-- Detecting Outliers
-----------------------------------------------------
DROP VIEW IF EXISTS outliers;
GO

CREATE VIEW outliers AS
WITH order_total AS (
    SELECT order_number, SUM(order_total) AS total
    FROM Master_sales
    GROUP BY order_number
),
meantable AS (
    SELECT AVG(total) AS mean, STDEV(total) AS std
    FROM order_total
)
SELECT
    o.order_number,
    o.total,
    m.mean,
    m.std,
    (o.total - m.mean) / m.std AS flag,
    CASE
        WHEN ABS((o.total - m.mean) / m.std) > 5 THEN 'OUTLIER'
        ELSE 'NORMAL'
    END AS classification
FROM order_total o
CROSS JOIN meantable m
WHERE ABS((o.total - m.mean) / m.std) > 5;
GO

-----------------------------------------------------
-- Customer Segmentation
-----------------------------------------------------
DROP VIEW IF EXISTS customers_segmented;
GO

CREATE VIEW customers_segmented AS
WITH cte AS (
    SELECT customer_id,
           COUNT(DISTINCT order_number) AS orders_count,
           SUM(order_total) AS total_value,
           MAX(order_date) AS last_order_date
    FROM Master_sales
    GROUP BY customer_id
)
SELECT
    customer_id,
    orders_count,
    total_value,
    last_order_date,
    NTILE(10) OVER (ORDER BY orders_count) AS frequency,
    NTILE(10) OVER (ORDER BY total_value) AS monetary,
    CASE
        WHEN DATEDIFF(DAY, last_order_date, GETDATE()) > 60 THEN 'Churned'
        WHEN DATEDIFF(DAY, last_order_date, GETDATE()) < 30 AND orders_count = 1 THEN 'New'
        ELSE 'Active'
    END AS customer_status
FROM cte;
GO

-----------------------------------------------------
-- Items Sold Together (Cross-Selling)
-----------------------------------------------------
DROP VIEW IF EXISTS items_relation;
GO

CREATE VIEW items_relation AS
SELECT
    a.item_number AS item_number_A,
    a.item_name AS item_name_A,
    b.item_number AS item_number_B,
    b.item_name AS item_name_B,
    COUNT(DISTINCT a.order_number) AS times_bought_together
FROM Master_sales a
JOIN Master_sales b
    ON a.order_number = b.order_number
   AND a.item_number < b.item_number
GROUP BY a.item_name, b.item_name, a.item_number, b.item_number;
GO

-----------------------------------------------------
-- Monthly Growth
-----------------------------------------------------
WITH cte AS (
    SELECT
        MONTH(order_date) AS month,
        DATENAME(MONTH, order_date) AS month_name,
        SUM(order_total) AS total
    FROM Master_sales
    GROUP BY MONTH(order_date), DATENAME(MONTH, order_date)
)
SELECT
    month_name,
    total,
    LAG(total) OVER (ORDER BY month) AS prev_month,
    ROUND((total - LAG(total) OVER (ORDER BY month)) * 100.0 / LAG(total) OVER (ORDER BY month), 2) AS growth_percent
FROM cte;
