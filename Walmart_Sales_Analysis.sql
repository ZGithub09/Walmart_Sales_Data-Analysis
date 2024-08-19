-- Create database
CREATE DATABASE IF NOT EXISTS walmart_sales;

CREATE TABLE IF NOT EXISTS sales (
    invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10 , 2 ) NOT NULL,
    quantity INT NOT NULL,
    tax_pct FLOAT(6 , 4 ) NOT NULL,
    total DECIMAL(12 , 4 ) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment_method VARCHAR(15) NOT NULL,
    cogs DECIMAL(10 , 2 ) NOT NULL,
    gross_margin_pct FLOAT(11 , 9 ),
    gross_income DECIMAL(12 , 4 ),
    rating FLOAT(2 , 1 )
);

SELECT 
    *
FROM
    sales;

-- Feature Engineering

SELECT 
    time,
    CASE
        WHEN time BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
        WHEN time BETWEEN '12:01:00' AND '17:00:00' THEN 'Aftenoon'
        ELSE 'Evening'
    END time_of_date
FROM
    sales;

ALTER TABLE sales
ADD COLUMN time_of_dat VARCHAR(10);

-- Disable safe update mode 
SET SQL_SAFE_UPDATES = 0;

UPDATE sales 
SET 
    time_of_dat = CASE
        WHEN time BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
        WHEN time BETWEEN '12:01:00' AND '17:00:00' THEN 'Afternoon'
        ELSE 'Evening'
    END;

-- Day name
SELECT 
    date, DAYNAME(date) AS Day_name
FROM
    sales;

ALTER TABLE sales ADD COLUMN day_name VARCHAR(10);

UPDATE sales 
SET 
    day_name = DAYNAME(date);

-- Month name
SELECT 
    date, MONTHNAME(date) AS month_name
FROM
    sales;

ALTER TABLE sales ADD COLUMN month_name VARCHAR(10);

UPDATE sales 
SET 
    month_name = MONTHNAME(date);

-- Re-enable safe update mode
SET SQL_SAFE_UPDATES = 1;

-- Generic Question

SELECT DISTINCT
    city
FROM
    sales;
    
-- 2. In which city is each branch?
SELECT DISTINCT
    city, branch
FROM
    sales;

-- Product
-- 1. How many unique product lines does the data have?
SELECT 
    COUNT(DISTINCT product_line) AS count_of_product
FROM
    sales;
    
-- 2. What is the most common payment method?
SELECT 
    payment_method, COUNT(payment_method) AS count
FROM
    sales
GROUP BY payment_method
ORDER BY count DESC;

-- 3. What is the most selling product line?
SELECT 
    product_line, COUNT(product_line) AS count
FROM
    sales
GROUP BY product_line
ORDER BY count DESC;

-- 4. What is the total revenue by month?
SELECT 
    month_name AS month, SUM(total) AS revenue
FROM
    sales
GROUP BY month
ORDER BY revenue DESC;

-- 5. What month had the largest COGS?
SELECT 
    month_name AS month, SUM(cogs) AS cogs
FROM
    sales
GROUP BY month
ORDER BY cogs DESC;

-- 6. What product line had the largest revenue?
SELECT 
    product_line, SUM(total) AS revenue
FROM
    sales
GROUP BY product_line
ORDER BY revenue DESC;

-- 7. Which city generates the most income?
SELECT 
    city, SUM(total) AS revenue
FROM
    sales
GROUP BY city
ORDER BY revenue DESC;

-- 8. What product line had the largest VAT?
SELECT 
    product_line, AVG(tax_pct) AS avg_tax
FROM
    sales
GROUP BY product_line
ORDER BY avg_tax DESC;

-- 9. Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales
SELECT product_line, avg_sales,
       CASE
           WHEN avg_sales > avg(avg_sales) OVER() THEN 'Good'
           ELSE 'Bad'
       END AS sales_category
FROM (
    SELECT product_line, AVG(total) AS avg_sales
    FROM sales
    GROUP BY product_line
) AS subquery;

-- 10. Which branch sold more products than average product sold?
SELECT 
    branch, SUM(quantity) AS qty
FROM
    sales
GROUP BY branch
HAVING SUM(quantity) > (SELECT 
        AVG(quantity)
    FROM
        sales)
ORDER BY qty DESC;

-- 11. What is the most common product line by gender?
SELECT 
    gender, product_line, COUNT(gender) AS count
FROM
    sales
GROUP BY gender , product_line
ORDER BY count DESC;

-- 12. What is the average rating of each product line?
SELECT 
    product_line, ROUND(AVG(rating), 1) AS avg_rating
FROM
    sales
GROUP BY product_line
ORDER BY avg_rating DESC;

-- Sales

SELECT 
    time_of_day AS week, COUNT(*) AS count
FROM
    sales
WHERE
    day_name = 'Monday'
GROUP BY week
ORDER BY count DESC;

-- 2. Which of the customer types brings the most revenue?
SELECT 
    customer_type, SUM(total) AS revenue
FROM
    sales
GROUP BY customer_type
ORDER BY revenue DESC;

-- 3. Which city has the largest tax percent/ VAT (**Value Added Tax**)?
SELECT 
    city, ROUND(AVG(tax_pct), 2) AS avg_tax_pct
FROM
    sales
GROUP BY city
ORDER BY avg_tax_pct DESC;

-- 4. Which customer type pays the most in VAT?
SELECT 
    customer_type, AVG(tax_pct) AS avg_tax_pct
FROM
    sales
GROUP BY customer_type
ORDER BY avg_tax_pct DESC;

-- Customer Analysis
-- 1. How many unique customer types does the data have?
SELECT DISTINCT
    customer_type
FROM
    sales;

-- 2. How many unique payment methods does the data have?
SELECT DISTINCT
    payment_method
FROM
    sales;

-- 3. Which is the most common customer type?
SELECT 
    customer_type, COUNT(*) AS cust_cnt
FROM
    sales
GROUP BY customer_type
ORDER BY cust_cnt DESC;

-- 4. What is the gender of most of the customers?
SELECT 
    gender, COUNT(*) AS gender_cnt
FROM
    sales
GROUP BY gender
ORDER BY gender_cnt DESC;

-- 5. What is the gender distribution per branch?
SELECT 
    gender, COUNT(*) AS gender_cnt
FROM
    sales
WHERE
    branch = 'B'
GROUP BY gender
ORDER BY gender_cnt DESC;

-- 6. Which time of the day do customers give most ratings?
SELECT 
    time_of_day, AVG(rating) AS avg_rating
FROM
    sales
GROUP BY time_of_day
ORDER BY avg_rating DESC;

-- 7. Which time of the day do customers give most ratings per branch?
SELECT 
    time_of_day, AVG(rating) AS avg_rating
FROM
    sales
WHERE
    branch = 'C'
GROUP BY time_of_day
ORDER BY avg_rating DESC;

-- 8. Which day of the week has the best avg ratings?
SELECT 
    day_name, AVG(rating) AS avg_rating
FROM
    sales
GROUP BY day_name
ORDER BY avg_rating DESC;

-- 9. Which day of the week has the best average ratings per branch?
SELECT 
    day_name, AVG(rating) AS avg_rating
FROM
    sales
WHERE
    branch = 'C'
GROUP BY day_name
ORDER BY avg_rating DESC;