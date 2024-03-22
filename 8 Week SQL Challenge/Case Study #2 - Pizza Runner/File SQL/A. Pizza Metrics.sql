/* -------------------
     A. Pizza Metrics
   -------------------*/

-- 1. How many pizzas were ordered?
SELECT 
	COUNT(order_id) AS "total order pizza"
FROM customer_orders;

-- 2. How many unique customer orders were made?
SELECT 
	COUNT(DISTINCT order_id) AS "total unique order"
FROM customer_orders_temp;

-- 3. How many successful orders were delivered by each runner?
SELECT 
	runner_id,
    COUNT(runner_id) AS "number of ordered succesfull"
FROM runner_orders_temp
WHERE cancellation IS NULL
GROUP BY 1;

-- 4. How many of each type of pizza was delivered?
SELECT 
	pizza_id,
    pizza_name,
    COUNT(order_id) AS "number of pizza delivered"
FROM customer_orders_temp
INNER JOIN runner_orders_temp
	USING(order_id)
INNER JOIN pizza_names
	USING(pizza_id)
WHERE cancellation IS NULL
GROUP BY 1,2;

-- 5. How many Vegetarian and Meatlovers were ordered by each customer?
SELECT 
	customer_id,
    pizza_name,
    COUNT(*) AS "number of pizza"
FROM customer_orders_temp
INNER JOIN pizza_names 
	USING(pizza_id)
GROUP BY 1,2
ORDER BY 1,2;

-- 6. What was the maximum number of pizzas delivered in a single order?
SELECT 
	customer_id,
    order_id,
    COUNT(*) AS count_pizza
FROM customer_orders_temp
INNER JOIN runner_orders_temp
	USING(order_id)
WHERE cancellation IS NULL
GROUP BY 1,2
ORDER BY 3 DESC
LIMIT 1;

-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
SELECT 
	customer_id,
    SUM(CASE WHEN (exclusions IS NOT NULL OR extras IS NOT NULL) THEN 1
    ELSE 0 END) AS "number of changes",
    SUM(CASE WHEN (exclusions IS NULL AND extras IS NULL) THEN 1
    ELSE 0 END) AS "number of no changes"
FROM customer_orders_temp
INNER JOIN runner_orders_temp
	USING(order_id)
WHERE cancellation IS NULL
GROUP BY 1;
    
-- 8. How many pizzas were delivered that had both exclusions and extras?
SELECT
	customer_id,
	SUM(CASE WHEN (exclusions IS NOT NULL AND extras IS NOT NULL) THEN 1
    ELSE 0 END) AS "both changes"
FROM customer_orders_temp
INNER JOIN runner_orders_temp
	USING(order_id)
WHERE cancellation IS NULL
GROUP BY 1;

-- 9. What was the total volume of pizzas ordered for each hour of the day?
SELECT 
	EXTRACT(hour FROM order_time) AS "Hour",
    COUNT(order_id) AS "number of order"
FROM customer_orders_temp
GROUP BY 1
ORDER BY 1;

-- 10. What was the volume of orders for each day of the week?
SELECT
	DAYNAME(order_time) AS 'Day Of Week',
    COUNT(order_id) AS "number of order"
FROM customer_orders_temp
GROUP BY 1
ORDER BY 2 DESC;

