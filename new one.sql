SHOW VARIABLES LIKE 'port';
CREATE DATABASE customer_behavior;
SELECT * FROM customer_shopping_behavior;
-- =========================================
-- Q1. Total Revenue by Gender
-- Purpose: Compare spending between male and female customers
-- =========================================
SELECT Gender, 
       SUM(`Purchase Amount (USD)`) AS revenue
FROM customer_shopping_behavior
GROUP BY Gender;

DESCRIBE customer_shopping_behavior;

ALTER TABLE customer_shopping_behavior
CHANGE COLUMN `ï»¿Customer ID` `Customer ID` INT;

-- =========================================
-- Q2. High-Spending Discount Users
-- Purpose: Find customers who used discounts but still spent above average
-- =========================================
SELECT `Customer ID`, `Purchase Amount (USD)`
FROM customer_shopping_behavior
WHERE `Discount Applied` = 'Yes' 
AND `Purchase Amount (USD)` >= (
    SELECT AVG(`Purchase Amount (USD)`) 
    FROM customer_shopping_behavior
);


-- =========================================
-- Q3. Top 5 Products by Review Rating
-- Purpose: Identify best-rated products based on customer feedback
-- =========================================
SELECT `Item Purchased`, 
       ROUND(AVG(`Review Rating`),2) AS avg_rating
FROM customer_shopping_behavior
GROUP BY `Item Purchased`
ORDER BY avg_rating DESC
LIMIT 5;

-- =========================================
-- Q4. Shipping Type Comparison
-- Purpose: Compare average spending across shipping methods
-- =========================================
SELECT `Shipping Type`, 
       ROUND(AVG(`Purchase Amount (USD)`),2) AS avg_spend
FROM customer_shopping_behavior
WHERE `Shipping Type` IN ('Standard','Express')
GROUP BY `Shipping Type`;

-- =========================================
-- Q5. Subscription Impact Analysis
-- Purpose: Check if subscribed customers spend more
-- =========================================
SELECT `Subscription Status`,
       COUNT(`Customer ID`) AS total_customers,
       ROUND(AVG(`Purchase Amount (USD)`),2) AS avg_spend,
       ROUND(SUM(`Purchase Amount (USD)`),2) AS total_revenue
FROM customer_shopping_behavior
GROUP BY `Subscription Status`
ORDER BY total_revenue DESC;


-- =========================================
-- Q7. Customer Segmentation (New / Returning / Loyal)
-- Purpose: Segment customers based on purchase history
-- =========================================
WITH customer_type AS (
    SELECT `Customer ID`, 
           `Previous Purchases`,
           CASE 
               WHEN `Previous Purchases` = 1 THEN 'New'
               WHEN `Previous Purchases` BETWEEN 2 AND 10 THEN 'Returning'
               ELSE 'Loyal'
           END AS customer_segment
    FROM customer_shopping_behavior
)

SELECT customer_segment,
       COUNT(*) AS total_customers
FROM customer_type
GROUP BY customer_segment;

-- =========================================
-- Q8. Top 3 Products in Each Category
-- Purpose: Find best-selling products within each category
-- =========================================
WITH item_counts AS (
    SELECT `Category`,
           `Item Purchased`,
           COUNT(`Customer ID`) AS total_orders,
           ROW_NUMBER() OVER (
               PARTITION BY `Category` 
               ORDER BY COUNT(`Customer ID`) DESC
           ) AS item_rank
    FROM customer_shopping_behavior
    GROUP BY `Category`, `Item Purchased`
)

SELECT *
FROM item_counts
WHERE item_rank <= 3;

-- =========================================
-- Q9. Repeat Buyers vs Subscription
-- Purpose: Check if frequent buyers are more likely to subscribe
-- =========================================
SELECT `Subscription Status`,
       COUNT(`Customer ID`) AS repeat_buyers
FROM customer_shopping_behavior
WHERE `Previous Purchases` > 5
GROUP BY `Subscription Status`;

-- =========================================
-- Q10. Revenue by Age Group
-- Purpose: Analyze which age group contributes most revenue
-- =========================================
SELECT 
    CASE 
        WHEN Age < 25 THEN 'Young'
        WHEN Age BETWEEN 25 AND 40 THEN 'Adult'
        ELSE 'Senior'
    END AS age_group,
    SUM(`Purchase Amount (USD)`) AS total_revenue
FROM customer_shopping_behavior
GROUP BY age_group
ORDER BY total_revenue DESC;
