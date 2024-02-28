-- SQL Project - 1 

-- Below Concepts are used in the projects.

-- SUM AND COUNT AGGREGATE FUNCTIONS
-- RANKING FUNCTIONS 
-- GROUP BY CLAUSE AND ORDER BY CLAUSE 
-- CASE STATEMENTS
-- COMMON TABLE EXPRESSIONS

-- Each of the following case study questions can be answered using a single SQL statement.

-- 1.what is the total amount each customer spent at the restaurant?
select s.cust_id,sum(m.price) as Price 
from sales s inner join menu m on s.product_id=m.product_id 
group by s.cust_id;

-- 2.How many days has each customer visited the restaurant?
SELECT cust_id,COUNT(DISTINCT order_date) AS visit 
FROM sales 
GROUP BY cust_id;

-- 3.what was the first item from the menu purchased by each customer?
WITH CTE AS
(SELECT s.cust_id,m.product_name,s.order_date,
RANK() OVER(PARTITION BY s.cust_id ORDER BY s.order_date) AS RK
FROM sales s INNER JOIN menu m ON m.product_id=s.product_id)
SELECT DISTINCT * FROM CTE WHERE RK = 1;

-- 4.what is the most purchased item on the menu and how many items was it purchased by all customers?
SELECT m.product_name,COUNT(m.product_id) AS CT FROM sales s 
INNER JOIN menu m ON s.product_id=m.product_id
GROUP BY m.product_name
ORDER BY CT DESC LIMIT 1;

-- 5.which item was the most popular for each customer?
WITH cte AS
(SELECT s.cust_id,m.product_name,COUNT(m.product_id) AS No_of_Purchased,
RANK() OVER(PARTITION BY s.cust_id ORDER BY COUNT(m.product_id) DESC) AS RK 
FROM sales s 
INNER JOIN menu m ON s.product_id=m.product_id
GROUP BY s.cust_id,m.product_name)
SELECT cust_id,product_name FROM cte
where RK =1;

-- 6.which item was purchased first by the customer after they became a member?
SELECT * FROM sales ;
SELECT * FROM menu ;
SELECT * FROM members;

WITH cte As
(
SELECT s.cust_id,s.order_date,m.product_name,Mem.join_date ,
RANK() OVER(PARTITION BY Mem.customer_id ORDER BY s.order_date) AS RK
FROM sales s
INNER JOIN menu m ON s.product_id = m.product_id
INNER JOIN members Mem ON s.cust_id = Mem.customer_id 
WHERE s.order_date >= Mem.join_date
)
SELECT * FROM cte 
WHERE RK = 1;

-- 7.which item was purchased just before the customer became a member?
 
 WITH cte As
(
SELECT s.cust_id,s.order_date,m.product_name,Mem.join_date ,
RANK() OVER(PARTITION BY Mem.customer_id ORDER BY s.order_date) AS RK
FROM sales s
INNER JOIN menu m ON s.product_id = m.product_id
INNER JOIN members Mem ON s.cust_id = Mem.customer_id 
WHERE s.order_date <Mem.join_date
)
SELECT * FROM cte 
WHERE RK = 1;

-- 8.What is the total items and amount spent for each member before they became a member?
SELECT s.cust_id,COUNT(product_name) AS totat_items,SUM(price) AS amount_spent
FROM sales s 
INNER JOIN members m ON s.cust_id = m.customer_id
INNER JOIN menu me ON me.product_id = s.product_id
WHERE s.order_date < m.join_date
GROUP BY s.cust_id;

-- 9.If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
SELECT s.cust_id,
     SUM(CASE 
        WHEN m.product_name = "sushi" THEN m.price * 10 *2 
        ELSE m.price * 10
     END) AS points
FROM menu m
INNER JOIN sales s ON s.product_id = m.product_id
GROUP BY s.cust_id;

-- 10.In the first week after a customer joins the program (including their join date) 
-- they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

SELECT s.cust_id,SUM(m.price)*10*2 AS Sum_points
FROM menu m
INNER JOIN sales s ON s.product_id = m.product_id
INNER JOIN members me ON me.customer_id = s.cust_id
WHERE s.order_date BETWEEN me.join_date AND me.join_date + 7
AND s.order_date <= "2021-01-31"
GROUP BY s.cust_id








