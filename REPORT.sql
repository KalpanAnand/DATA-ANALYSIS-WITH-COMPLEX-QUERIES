CREATE DATABASE REPORT;

USE REPORT;

-- Create the sales table
CREATE TABLE sales (
    sale_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT,
    sale_date DATE,
    quantity INT,
    price DECIMAL(10, 2),
    customer_id INT
);

-- Insert sample data into the sales table
INSERT INTO sales (product_id, sale_date, quantity, price, customer_id) VALUES
(1, '2023-01-15', 2, 10.00, 101),
(2, '2023-01-20', 1, 25.00, 102),
(1, '2023-01-28', 3, 10.00, 103),
(3, '2023-02-05', 1, 50.00, 101),
(2, '2023-02-12', 2, 25.00, 102),
(1, '2023-02-18', 1, 10.00, 104),
(4, '2023-03-01', 5, 5.00, 103),
(3, '2023-03-08', 2, 50.00, 101),
(2, '2023-03-15', 3, 25.00, 102),
(1, '2023-03-22', 1, 10.00, 105),
(5, '2023-04-03', 2, 15.00, 101),
(2, '2023-04-10', 1, 25.00, 102),
(3, '2023-04-17', 3, 50.00, 103),
(1, '2023-04-24', 1, 10.00, 104),
(1, '2023-05-01', 4, 10.00, 105),
(2, '2023-05-08', 2, 25.00, 101),
(3, '2023-05-15', 1, 50.00, 102),
(4, '2023-05-22', 3, 5.00, 103),
(5, '2023-05-29', 2, 15.00, 104);


SELECT * FROM sales;


-- 1. Create a CTE for monthly sales
WITH MonthlySales AS (
    SELECT
        DATE_FORMAT(sale_date, '%Y-%m') AS sale_month,
        SUM(quantity * price) AS total_sales
    FROM
        sales
    GROUP BY
        sale_month
),

-- 2. Create a CTE for product sales
ProductSales AS (
  SELECT
        product_id,
        SUM(quantity * price) AS product_total_sales
    FROM
        sales
    GROUP BY
        product_id
),

-- 3. Combine CTEs and use window functions
SalesReport AS (
SELECT
    ms.sale_month,
    ms.total_sales,
    SUM(ms.total_sales) OVER (ORDER BY ms.sale_month) AS running_total_sales,  -- Running total
    ps.product_id,
    ps.product_total_sales,
    RANK() OVER (ORDER BY ps.product_total_sales DESC) AS product_rank,  -- Product rank
    (ps.product_total_sales / ms.total_sales) * 100 AS product_contribution_percentage  -- % contribution
FROM
    MonthlySales ms
JOIN
  (SELECT
        DATE_FORMAT(sale_date, '%Y-%m') AS sale_month,
        product_id,
        SUM(quantity * price) AS product_total_sales
    FROM
        sales
    GROUP BY
        sale_month, product_id) as ps ON ms.sale_month = ps.sale_month
ORDER BY ms.sale_month, ps.product_total_sales DESC
)

-- 4. Final report output
SELECT
    sale_month,
    total_sales,
    running_total_sales,
    product_id,
    product_total_sales,
    product_rank,
    product_contribution_percentage
FROM
    SalesReport;

-- Example of finding top selling product in each month using window function in a subquery

SELECT sale_month, product_id, product_total_sales
FROM (
  SELECT
        DATE_FORMAT(sale_date, '%Y-%m') AS sale_month,
        product_id,
        SUM(quantity * price) AS product_total_sales,
        ROW_NUMBER() OVER (PARTITION BY DATE_FORMAT(sale_date, '%Y-%m') ORDER BY SUM(quantity * price) DESC) as rn
    FROM
        sales
    GROUP BY
        sale_month, product_id
) ranked_products
WHERE rn = 1;