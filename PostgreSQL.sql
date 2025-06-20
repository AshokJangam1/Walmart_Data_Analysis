SELECT * FROM walmart;


--

SELECT COUNT(*) FROM walmart;

SELECT 
	payment_method,
	COUNT(*)
FROM walmart
Group BY payment_method


SELECT COUNT(Distinct branch)
	Branch
FROM walmart;

SELECT MAX(quantity) FROM walmart;
SELECT MIN(quantity) FROM walmart;


--BUSINESS PROBLEMS

--Q1. Find different payment method and transations, number of qty sold.

SELECT 

	payment_method,
	Count(*) as no_of_payments,
	SUM(quantity) as no_of_qty_sold
FROM walmart
GROUP BY payment_method
	

--Q2. Identify the highest-rated category in each branch, displaying the branch, category
-- AVG RATING
SELECT *
FROM
(
	SELECT 
		branch,
		category,
		AVG(rating) as avg_rating,
		RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) as rank
	FROM walmart
	GROUP BY 1,2
)
WHERE rank=1


--Q3. Identify the busiest day for each branch based on the number of transactions.
SELECT *
FROM

	(SELECT 
		branch,
		TO_CHAR(TO_DATE(date,'DD/MM/YY'),'Day') As Day_name,
		COUNT(*) as no_of_transactions,
		RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) as rank
	FROM walmart
	GROUP BY 1,2
	)
WHERE rank=1


--Q4.Calculate the total quantity of items sold per payment method. list payment_method and total_quantity.


SELECT 

	payment_method,
	--Count(*) as no_of_payments,
	SUM(quantity) as no_of_qty_sold
FROM walmart
GROUP BY payment_method

--Q5. Determine the average, minimum and maximum rating of category for each city.
--list the city, averege_rating, min_rating, max_rating.

SELECT 
	city,
	category,
	MIN(rating) as min_rating,
	MAX(rating) as max_rating,
	AVG(rating) as avg_rating

FROM walmart
GROUP BY 1,2

--Q6. Calculate the total profit for each category by considering total_profit as (unit_price* quantity *profit_margin).
--List category and total_profit, ordered from highest to lowest profit.

SELECT
	category,
	(unit_price* quantity *profit_margin) as total_profit
FROM walmart
ORDER BY total_profit DESC

--Q7. Determine the most common payment method for each branch. Display branch and the preferred_payment_method.
WITH walmart
AS
(SELECT 
	branch,
	payment_method,
	COUNT(*) as total_trans,
	RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) as rank
FROM walmart
GROUP BY 1,2
)
SELECT * 
FROM walmart
WHERE rank =1


--Q8.Caterize sales into 3 groups MORNING, AFTERNOON, EVENING
--Find out which of the shift and number of invoices

SELECT 
	branch,
	CASE 
		WHEN EXTRACT (HOUR FROM(time:: time))<12 THEN 'MORNING'
		WHEN EXTRACT (HOUR FROM(time:: time)) BETWEEN 12 AND 17 THEN 'AFTERNOON'
		ELSE 'EVENING'
	END day_time,
	COUNT(*)
FROM walmart
GROUP BY 1,2
ORDER BY 1,3 DESC

--Q9. Identify % branch with highest decrease ratio in revenue compared to last year(current year 2023 and last year 2022).

--rdr==last_rev-cr_rev/ls_rev*100
SELECT
	*,
	EXTRACT(YEAR FROM TO_DATE(date,'DD/MM/YY')) as formated_date
FROM walmart

--2022 sales
WITH revenue_2022 AS
(	
	SELECT 	
		branch,
		SUM(total) as revenue
	FROM walmart
	WHERE EXTRACT(YEAR FROM TO_DATE(date,'DD/MM/YY')) = 2022
	GROUP BY branch
),
revenue_2023 AS
(
	SELECT 	
		branch,
		SUM(total) as revenue
	FROM walmart
	WHERE EXTRACT(YEAR FROM TO_DATE(date,'DD/MM/YY')) = 2023
	GROUP BY branch
)
SELECT 
	ls.branch,
	ls.revenue as last_year_revenue,
	cs.revenue as current_year_revenue,
	ROUND(
		(ls.revenue - cs.revenue)::numeric / ls.revenue::numeric * 100, 2
	) as rev_dec_ratio
FROM revenue_2022 as ls
JOIN revenue_2023 as cs
	ON ls.branch = cs.branch
WHERE ls.revenue > cs.revenue
ORDER BY rev_dec_ratio DESC
LIMIT 5
