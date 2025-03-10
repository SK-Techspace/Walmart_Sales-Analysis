SELECT * FROM walmart;

--DROP TABLE "Walmart";
--

SELECT COUNT(*) FROM walmart;

SELECT payment_method,
 COUNT(*) 
 FROM walmart
 GROUP BY payment_method;

SELECT 
COUNT(DISTINCT branch)
FROM walmart;

SELECT 
MIN(quantity)
FROM walmart;

-- Business Problems

-- Problem 1: For each payment method, find the number of transactions and the quantity sold.

SELECT payment_method, COUNT(invoice_id) AS total_transactions, SUM(quantity) AS total_quantity_sold 
FROM walmart GROUP BY payment_method ORDER BY total_quantity_sold DESC;

-- Problem 2: To identify the highest-rated category in each branch and the average rating.

SELECT *
FROM
(   SELECT branch, category, MAX(rating) AS max_rating ,  AVG(rating) AS average_rating,
    RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) as rank
    FROM walmart 
    GROUP BY 1,2
)
WHERE rank = 1;

-- Problem 3: Identify the busiest day for each branch based on the number of transaction.

SELECT *
FROM
(SELECT 
       branch,
       TO_CHAR(TO_DATE (date, 'DD/MM/YY'), 'Day') as day_name,
	   COUNT(*) AS no_of_transactions,
	   RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) as RANK
from walmart
GROUP BY 1,2 
)
WHERE RANK = 1;

-- Problem 4: Calculate the total quantity of items sold per payment method. List payment method and total quantity.

SELECT payment_method, SUM(quantity) AS total_quantity
FROM walmart
GROUP BY payment_method;

-- Problem 5: Determine the average, min and max rating for category of each city. List the city, average rating, minimum rating and maximum rating.

SELECT city, category, AVG(rating) AS avg_rating, MAX(rating) AS max_rating, MIN(rating) AS min_rating
FROM walmart
GROUP BY 1,2 order by 1,3 DESC;

-- Problem 6: Calculate the total profit for each category by considering the total profit. List Category and total profit and sort the total profit from highest to lowest.

SELECT category, SUM(total_price) AS total_revenue , SUM(total_price * profit_margin) As total_profit 
FROM walmart
GROUP BY category
ORDER BY total_profit DESC;

-- Problem 7: Determine the most common payment method for each branch. Display branch and the prefered payment method.

WITH CTE
AS
(SELECT branch, payment_method, COUNT(*) AS total_trans,
RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS RANK
FROM walmart
GROUP BY 1,2)
SELECT branch, payment_method
FROM CTE 
WHERE RANK = 1;

-- Problem 8: Categorize Sales into three shifts Morning, Afternoon, Evening. Find out number of transaction in each shift.

SELECT branch,
         CASE
             WHEN EXTRACT (HOUR FROM(time::time)) < 12 THEN 'Morning'
             WHEN EXTRACT (HOUR FROM(time::time)) BETWEEN 12 AND 17 THEN 'Afternoon'
             ELSE 'Evening'
		 END day_time,
		 COUNT(*) AS no_of_trans
FROM walmart
GROUP BY 1,2
ORDER BY 1,3 DESC;

-- Problem 9: To Identify 5 branch with highest decrease percentage in revenue compare to last year, current year being 2023 and last being 2022.


SELECT *,
EXTRACT (YEAR FROM TO_DATE (date, 'DD/MM/YY')) AS formatted_date
FROM walmart

--Revenue for 2022
WITH revenue_22
AS
(SELECT branch, SUM(total_price) AS revenue
FROM walmart 
WHERE EXTRACT (YEAR FROM TO_DATE (date, 'DD/MM/YY')) = 2022
GROUP BY 1),

--Revenue for 2023
revenue_23
AS
(SELECT branch, SUM(total_price) AS revenue
FROM walmart 
WHERE EXTRACT (YEAR FROM TO_DATE (date, 'DD/MM/YY')) = 2023
GROUP BY 1)

SELECT ls.branch, ls.revenue AS last_year_revenue, cs.revenue AS cr_year_revenue,  
      ROUND((ls.revenue - cs.revenue)::numeric/ls.revenue::numeric * 100,2) AS per_dec_ratio
FROM revenue_22 AS ls
JOIN 
     revenue_23 AS cs
ON ls.branch = cs.branch
WHERE ls.revenue > cs.revenue
ORDER BY 4 DESC
LIMIT 5;

