# Case Study #1: Danny's Diner
![aaa](https://github.com/Trantuan24/Project_Sql/assets/145254268/28867d3c-27e4-4561-8a87-d2d5477e027e)

- Case Study #1 Information: [Click Here!](https://8weeksqlchallenge.com/case-study-1/)
***
## Case Study Questions

1. What is the total amount each customer spent at the restaurant?
2. How many days has each customer visited the restaurant?
3. What was the first item from the menu purchased by each customer?
4. What is the most purchased item on the menu and how many times was it purchased by all customers?
5. Which item was the most popular for each customer?
6. Which item was purchased first by the customer after they became a member?
7. Which item was purchased just before the customer became a member?
10. What is the total items and amount spent for each member before they became a member?
11. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
12. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
***

###  1. What is the total amount each customer spent at the restaurant?

```sql
SELECT 
    customer_id,
    SUM(price) AS total_price
FROM sales
INNER JOIN menu
    USING(product_id)
GROUP BY 1;
```

#### Result set:
| customer_id | total_price |
| ----------- | ----------- |
| A           | 76          |
| B           | 74          |
| C           | 36          |

***

###  2. How many days has each customer visited the restaurant?

```sql
SELECT 
    customer_id,
    COUNT(DISTINCT order_date) AS total_days
FROM sales
GROUP BY 1;
``` 
	
#### Result set:
| customer_id | total_days  |
| ----------- | ----------- |
| A           | 4           |
| B           | 6           |
| C           | 2           |

***

###  3. What was the first item from the menu purchased by each customer?

```sql
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
```
	
#### Result set:
| customer_id | product_name |
| ----------- | ------------ |
| A           | sushi        |
| A           | curry        |
| B           | curry        |
| C           | ramen        |

***

###  4. What is the most purchased item on the menu and how many times was it purchased by all customers?

```sql
SELECT 
    product_name,
    COUNT(order_date) AS number_of_purchase
FROM menu
INNER JOIN sales
    USING(product_id)
GROUP BY 1
ORDER BY number_of_purchase DESC
LIMIT 1;
```

#### Result set:
| product_name | number_of_purchase |
| ------------ | ------------------ |
| ramen        | 8                  |

***

###  5. Which item was the most popular for each customer?

```sql
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
```

#### Result set:
| customer_id | product_name | number_order |
| ----------- | ------------ | ------------ |
| A           | ramen        | 3            |
| B           | curry        | 2            |
| B           | ramen        | 2            |
| B           | sushi        | 2            |
| C           | ramen        | 3            |

***

###  6. Which item was purchased first by the customer after they became a member?

```sql
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
```

#### Result set:
| customer_id | product_name | order_date |
| ----------- | ------------ | ---------- |
| A           | curry        | 2021-01-07 |
| B           | sushi        | 2021-01-11 |

***

###  7. Which item was purchased just before the customer became a member?

```sql
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
```

#### Result set:
| customer_id | product_name | order_date   | join_date  |
| ----------- | ------------ | ------------ | ---------- |
| A           | sushi        | 2021-01-01   | 2021-01-07 |
| A           | curry        | 2021-01-01   | 2021-01-07 |
| B           | sushi        | 2021-01-01   | 2021-01-09 |

***

###  8. What is the total items and amount spent for each member before they became a member?

```sql
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
```
#### Result set:
| customer_id | total_items | total_price |
| ----------- | ----------- | ----------- |
| A           | 2           | 25          |
| B           | 3           | 40          |

***

###  9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

```sql
SELECT 
    customer_id,
    SUM(CASE WHEN product_name = 'sushi' THEN price * 20
    ELSE price *10 END) AS total_point
FROM sales
INNER JOIN menu
    USING(product_id)
GROUP BY 1;
```

#### Result set:
| customer_id | total_point |
| ----------- | ----------- |
| A           | 860         |
| B           | 940         |
| C           | 360         |

***

###  10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January

```sql
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
```

#### Result set:
| customer_id | total_point |
| ----------- | ----------- |
| A           | 1020        |
| B           | 320         |

***

###  Bonus Questions

#### Join All The Things
The following questions are related creating basic data tables that Danny and his team can use to quickly derive insights without needing to join the underlying tables using SQL. 
Fill Member column as 'N' if the purchase was made before becoming a member and 'Y' if the after is amde after joining the membership.

```sql
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
```

#### Result set:
![Screenshot 2024-03-21 211104](https://github.com/Trantuan24/Project_Sql/assets/145254268/adfdbdec-0edb-4e0b-a1fb-f4189242831b)

***

#### Rank All The Things
Danny also requires further information about the ranking of customer products, but he purposely does not need the ranking for non-member purchases so he expects null ranking values for the records when customers are not yet part of the loyalty program.
```sql
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
```

#### Result set:
![Screenshot 2024-03-22 183911](https://github.com/Trantuan24/Project_Sql/assets/145254268/0b377c63-2ee6-4dac-8675-f657c2fcaf61)
