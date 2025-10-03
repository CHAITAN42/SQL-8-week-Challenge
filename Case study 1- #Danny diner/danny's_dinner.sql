create database dannys_dinner;
use dannys_dinner;

-- Create sales table
CREATE TABLE sales (
  customer_id VARCHAR(1),
  order_date DATE,
  product_id INT
);

INSERT INTO sales (customer_id, order_date, product_id) VALUES
  ('A', '2021-01-01', 1),
  ('A', '2021-01-01', 2),
  ('A', '2021-01-07', 2),
  ('A', '2021-01-10', 3),
  ('A', '2021-01-11', 3),
  ('A', '2021-01-11', 3),
  ('B', '2021-01-01', 2),
  ('B', '2021-01-02', 2),
  ('B', '2021-01-04', 1),
  ('B', '2021-01-11', 1),
  ('B', '2021-01-16', 3),
  ('B', '2021-02-01', 3),
  ('C', '2021-01-01', 3),
  ('C', '2021-01-01', 3),
  ('C', '2021-01-07', 3);

-- Create menu table
CREATE TABLE menu (
  product_id INT,
  product_name VARCHAR(10),
  price INT
);

INSERT INTO menu (product_id, product_name, price) VALUES
  (1, 'sushi', 10),
  (2, 'curry', 15),
  (3, 'ramen', 12);

-- Create members table
CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);

INSERT INTO members (customer_id, join_date) VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');


# 1. What is the total amount each customer spent at the restaurant?
select customer_id,sum(price) as Total_Spent from sales as s 
inner join Menu m using (product_id) group by customer_id;

# 2. How many days has each customer visited the restaurant?
select customer_id, count(distinct(order_date)) as No_of_Visits
from sales s group by customer_id;

# 2.1 How many times each customer visited the restaurant ?
select customer_id, count(customer_id) as No_of_visit from sales s 
group by customer_id;

# 3. What was the first item from the menu purchased by each customer?

select customer_id,product_name from (select *,row_number() over(partition by customer_id order by order_date desc) as rn 
from sales as s inner join menu m using(product_id)) as t where rn = 1; 

# 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

select product_name, count(product_name) as no_of_purchases 
from sales as s inner join menu as m using(product_id)
group by product_name
order by no_of_purchases desc
limit 1;

# 5. Which item was the most popular for each customer?
select * from (
select customer_id,product_name,count(*) as No_of_times,
dense_rank() over(partition by customer_id order by count(*) desc) as Drnk from sales s 
inner join menu m using(product_id) group by customer_id,product_name) as t 
where drnk =1;

# 6. Which item was purchased first by the customer after they became a member?

select * from (
select s.customer_id,order_date,join_date,product_name,
row_number() over(partition by s.customer_id order by s.order_date) as rn
 from sales s inner join menu as m using(product_id) inner join members as mb
on s.customer_id=mb.customer_id and order_date > join_date) as t where rn = 1;

# 7. Which item was purchased just before the customer became a member?

select * from (
select s.customer_id,order_date,join_date,product_name,rank() over(partition by s.customer_id order by order_date desc) as rn
 from sales s inner join menu m using(product_id)
inner join members mb on s.customer_id = mb.customer_id and s.order_date<mb.join_date) as t
where rn = 1;


# 8. What is the total items and amount spent for each member before they became a member?

select s.customer_id,count(s.customer_id) as No_of_Items,sum(price) as Total_Amount_Spent
 from sales s inner join menu m using(product_id) inner join members mb 
on s.customer_id = mb.customer_id and order_date < join_date
group by s.customer_id order by customer_id;


# 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier -
#  how many points would each customer have?

select customer_id,sum(case when product_name = "Sushi" then Price*20 
else Price * 10 end) as Total_Points
 from sales s inner join menu m using(product_id) 
 group by customer_id;
