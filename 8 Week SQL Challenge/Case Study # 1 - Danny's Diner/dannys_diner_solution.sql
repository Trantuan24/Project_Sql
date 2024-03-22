/* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?
SELECT 
	customer_id,
    SUM(price) AS total_price
FROM sales
INNER JOIN menu
	USING(product_id)
GROUP BY 1;

-- 2. How many days has each customer visited the restaurant?
SELECT 
	customer_id,
    COUNT(DISTINCT order_date) AS total_days
FROM sales
GROUP BY 1;
	
-- 3. What was the first item from the menu purchased by each customer?
WITH order_date_rank AS(
	SELECT 
		customer_id,
        order_date,
        product_name,
        dense_rank() over(
			partition by customer_id
			order by order_date) AS ranks
	FROM sales  s
    INNER JOIN menu m
		USING(product_id)
)
SELECT DISTINCT 
	customer_id,
    product_name
FROM order_date_rank
WHERE ranks = 1;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT 
	product_name,
    COUNT(order_date) AS number_of_purchase
FROM menu
INNER JOIN sales
	USING(product_id)
GROUP BY 1
ORDER BY number_of_purchase DESC
LIMIT 1;

-- 5. Which item was the most popular for each customer?
WITH most_popular AS(
	SELECT 
		customer_id, 
        product_name,
        COUNT(m.product_id) AS number_order,
        dense_rank() over(
			partition by customer_id
            order by COUNT(m.product_id) DESC ) AS ranks
		FROM menu m
		INNER JOIN sales s
			USING(product_id)
		GROUP BY 1, 2
)
SELECT DISTINCT
	customer_id, 
    product_name,
    number_order
FROM most_popular
WHERE ranks = 1;
	
-- 6. Which item was purchased first by the customer after they became a member?
WITH joined_member AS(
	SELECT 
		customer_id,
        product_name,
        join_date,
        order_date,
        dense_rank() over(
			partition by customer_id
            order by order_date
        ) AS ranks
    FROM sales s
    INNER JOIN members ms  
		USING(customer_id)  
	INNER JOIN menu m
		USING(product_id)
	WHERE s.order_date >= ms.join_date
)
SELECT DISTINCT 
	customer_id,
    product_name,
    order_date
FROM joined_member
WHERE ranks = 1;

-- 7. Which item was purchased just before the customer became a member?
WITH last_purchase AS(
	SELECT 
		customer_id,
        product_name,
        join_date,
        order_date,
        dense_rank() over(
			partition by customer_id
            order by order_date
        ) AS ranks
    FROM sales s
    INNER JOIN members ms  
		USING(customer_id)  
	INNER JOIN menu m
		USING(product_id)
	WHERE s.order_date < ms.join_date
)
SELECT DISTINCT 
	customer_id,
    product_name,
    order_date,
    join_date
FROM last_purchase
WHERE ranks = 1;

-- 8. What is the total items and amount spent for each member before they became a member?
SELECT 
	customer_id,
	COUNT(product_name) AS total_product,
	SUM(price) AS total_price
FROM sales s
INNER JOIN members ms  
	USING(customer_id)  
INNER JOIN menu m
	USING(product_id)
WHERE s.order_date < ms.join_date
GROUP BY 1
ORDER BY 1;

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
SELECT 
	customer_id,
    SUM(CASE WHEN product_name = 'sushi' THEN price * 20
    ELSE price *10 END) AS total_point
FROM sales
INNER JOIN menu
	USING(product_id)
GROUP BY 1;

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, 
-- not just sushi - how many points do customer A and B have at the end of January?

WITH dates_cte AS(
	SELECT 
		customer_id,
        join_date,
        DATE_ADD(join_date, INTERVAL 6 DAY) last_date
    FROM members
)
SELECT 
	s.customer_id,
    SUM(CASE WHEN product_name = 'sushi' THEN price * 20
		WHEN order_date BETWEEN join_date AND last_date THEN price * 20
        ELSE price * 10 END) AS total_point
FROM sales s
INNER JOIN dates_cte d
	ON s.customer_id = d.customer_id
INNER JOIN menu m
	ON m.product_id = s.product_id
WHERE order_date >= join_date AND order_date <= '2021-01-31'
GROUP BY 1
ORDER BY 1;


/* ----------------
   Bonus Questions
   ----------------*/
-- Join All The Things
SELECT 
	customer_id,
    order_date,
    product_name,
    price,
    CASE WHEN join_date <= order_date THEN 'Y'
    ELSE 'N' END AS member
FROM sales s
LEFT JOIN members ms  
	USING(customer_id)  
INNER JOIN menu m
	USING(product_id)
ORDER BY 1,2;

-- Rank All The Things
WITH table_new AS (
	SELECT 
		customer_id,
		order_date,
		product_name,
		price,
		CASE WHEN join_date <= order_date THEN 'Y'
		ELSE 'N' END AS member
	FROM sales s
	LEFT JOIN members ms  
		USING(customer_id)  
	INNER JOIN menu m
		USING(product_id)
	ORDER BY 1,2
)
SELECT *,
	CASE WHEN member = 'N' then NULL
    ELSE DENSE_RANK() OVER (PARTITION BY customer_id, member
							ORDER BY order_date)  END AS ranking
FROM table_new;













