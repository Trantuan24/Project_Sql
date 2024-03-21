# Case Study #1: Danny's Diner

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
| A           | $76         |
| B           | $74         |
| C           | $36         |

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


