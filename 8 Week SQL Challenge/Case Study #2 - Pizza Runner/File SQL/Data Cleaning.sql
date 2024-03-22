/* --------------------------------
    Data Cleaning & Transformation
   --------------------------------*/
   
/* Table: customer_orders */

-- Các giá trị duy nhất trong các cột exclusions, extras
SELECT DISTINCT exclusions, extras FROM customer_orders;
-- Tồn tại 'null' và '' ở cả 2 cột --> Chuyển về NULL --> S/d bảng tạm customer_orders_temp

DROP TABLE IF EXISTS customer_orders_temp;

CREATE TEMPORARY TABLE customer_orders_temp AS
SELECT order_id,
       customer_id,
       pizza_id,
       CASE WHEN exclusions IN ('null', '') THEN NULL
           ELSE exclusions END AS exclusions,
       CASE WHEN extras IN ('null', '') THEN NULL
           ELSE extras END AS extras,
       order_time
FROM customer_orders;

SELECT * FROM customer_orders_temp;

/* Table: runner_orders */

-- Các giá trị duy nhất trong các cột pickup_time, distance, duration, cancellation
SELECT DISTINCT pickup_time, distance, duration, cancellation FROM runner_orders;
-- Các cột pickup_time, distance, duration có 'null' còn cột cancellation có cả 'null' và '' --> Chuyển về NULL 
-- Các cột distance, duration chứa đơn vị 'km', 'minutes' --> S/d regexp_replace loại bỏ đơn vị --> Chuyển về kiểu số 
-- Kiểu dữ liệu pickup_time chuyển thành time
-- > S/d bảng tạm runner_orders_temp

DROP TABLE IF EXISTS runner_orders_temp;

CREATE TEMPORARY TABLE runner_orders_temp AS
SELECT 
	order_id,
    runner_id,
    CAST(CASE WHEN pickup_time = 'null' THEN NULL
			ELSE pickup_time END 
        AS DATETIME) AS pickup_time,
	CASE WHEN distance = 'null' THEN NULL
		ELSE CAST(regexp_replace(distance, '[a-z]+', '') AS FLOAT) END AS distance,
	CASE WHEN duration = 'null' THEN NULL
		ELSE CAST(regexp_replace(duration, '[a-z]+', '') AS FLOAT) END AS duration,
	CASE WHEN cancellation IN ('null', '') THEN NULL
		ELSE cancellation END AS cancellation
FROM runner_orders;

SELECT * FROM runner_orders_temp;

-- Kiểm tra lại kiểu dữ liệu
DESCRIBE runner_orders_temp; 

