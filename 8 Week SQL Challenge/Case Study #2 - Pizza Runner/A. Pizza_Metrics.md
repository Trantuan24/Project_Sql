# Case Study #2: Pizza runner - A. Pizza Metrics

## Case Study Questions

1. How many pizzas were ordered?
2. How many unique customer orders were made?
3. How many successful orders were delivered by each runner?
4. How many of each type of pizza was delivered?
5. How many Vegetarian and Meatlovers were ordered by each customer?
6. What was the maximum number of pizzas delivered in a single order?
7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
8. How many pizzas were delivered that had both exclusions and extras?
9. What was the total volume of pizzas ordered for each hour of the day?
10. What was the volume of orders for each day of the week?

***

###  1. How many pizzas were ordered?

```sql
SELECT 
	COUNT(order_id) AS "total order pizza"
FROM customer_orders;
```

#### Result set:
![image](https://github.com/Trantuan24/Project_Sql/assets/145254268/11c34b8a-b084-4248-a6ec-5f30e89ba571)

***

###  2. How many unique customer orders were made?

```sql
SELECT 
	COUNT(DISTINCT order_id) AS "total unique order"
FROM customer_orders_temp;
```

#### Result set:
![image](https://github.com/Trantuan24/Project_Sql/assets/145254268/ddee7436-2386-41fe-b4e0-81b15aea5426)

***

###  3. How many successful orders were delivered by each runner?

```sql
SELECT 
	  runner_id,
    COUNT(runner_id) AS "number of ordered succesfull"
FROM runner_orders_temp
WHERE cancellation IS NULL
GROUP BY 1;
```

#### Result set:
![image](https://github.com/Trantuan24/Project_Sql/assets/145254268/dbf7ef25-eaf5-43d1-8288-622ea478bc89)

***

###  4. How many of each type of pizza was delivered?

```sql
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
```

#### Result set:
![image](https://github.com/Trantuan24/Project_Sql/assets/145254268/a6b5386a-4946-4c07-a1ce-e2f3cbe18b53)

***

###  5. How many Vegetarian and Meatlovers were ordered by each customer?

```sql
SELECT 
	  customer_id,
    pizza_name,
    COUNT(*) AS "number of pizza"
FROM customer_orders_temp
INNER JOIN pizza_names 
	USING(pizza_id)
GROUP BY 1,2
ORDER BY 1,2;
```

#### Result set:
![image](https://github.com/Trantuan24/Project_Sql/assets/145254268/942d7c1e-e5bc-45e3-b803-2bd2bc40b02e)

***

###  6. What was the maximum number of pizzas delivered in a single order?

```sql
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
```

#### Result set:
![image](https://github.com/Trantuan24/Project_Sql/assets/145254268/6a512a01-0bcb-4d85-8b40-b8777529e9b1)

***

###  7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
- at least 1 change -> either exclusion or extras 
- no changes -> exclusion and extras are NULL

```sql
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
```

#### Result set:
![image](https://github.com/Trantuan24/Project_Sql/assets/145254268/860c2e4a-a1e7-4f6a-89ae-38125a4401fc)

***

###  8. How many pizzas were delivered that had both exclusions and extras?

```sql
SELECT
	customer_id,
	SUM(CASE WHEN (exclusions IS NOT NULL AND extras IS NOT NULL) THEN 1
      ELSE 0 END) AS "both changes"
FROM customer_orders_temp
INNER JOIN runner_orders_temp
	USING(order_id)
WHERE cancellation IS NULL
GROUP BY 1;
```

#### Result set:
![image](https://github.com/Trantuan24/Project_Sql/assets/145254268/fa9428c1-5955-47c4-b00c-57549f1b8841)

***

###  9. What was the total volume of pizzas ordered for each hour of the day?

```sql
SELECT 
	  EXTRACT(hour FROM order_time) AS "Hour",
    COUNT(order_id) AS "number of order"
FROM customer_orders_temp
GROUP BY 1
ORDER BY 1;
```

#### Result set:
![image](https://github.com/Trantuan24/Project_Sql/assets/145254268/277e90a0-46b7-4a54-a788-f93c823e6b28)

***

###  10. What was the volume of orders for each day of the week?

```sql
SELECT
	  DAYNAME(order_time) AS 'Day Of Week',
    COUNT(order_id) AS "number of order"
FROM customer_orders_temp
GROUP BY 1
ORDER BY 2 DESC;
```

#### Result set:
![image](https://github.com/Trantuan24/Project_Sql/assets/145254268/5b5fdc9f-bc7d-4c98-83b9-70395f40dcca)

