--Q1 : When is the peak season of our ecommerce ?
SELECT TO_CHAR(order_date, 'Month') AS month, EXTRACT(MONTH FROM order_date) AS month_number,
COUNT(order_id) AS total_orders
FROM fact_order
GROUP BY TO_CHAR(order_date, 'Month'), EXTRACT(MONTH FROM order_date)
ORDER BY total_orders desc;

--Q2 What time users are most likely make an order or using the ecommerce app?
SELECT TO_CHAR(order_date, 'HH12 AM') AS hour_of_day, 
COUNT(order_id) AS total_orders
FROM fact_order GROUP BY TO_CHAR(order_date, 'HH12 AM'), EXTRACT(HOUR FROM order_date)
ORDER BY total_orders DESC;

--Q3 What is the preferred way to pay in the ecommerce?
Select payment_type,COALESCE(Count(order_id),0) total_orders from dim_payments
group by payment_type
order by total_orders DESC 

--Q4 How many installment is usually done when paying in the ecommerce?
SELECT round(avg(payment_installments),) AS average_installments
FROM dim_payments;
-- Q5 :What is the average spending time for user for our ecommerce?
Select Round(AVG(Extract(epoch from (delivered_date - order_date)) / 3600), 2) as average_spending_time_hours, 
round(avg(extract(epoch from (delivered_date - order_date)) / 3600 / 24), 2) as average_spending_time_days 
From fact_order;
-- Q6: What is the frequency of purchase on each state?
select c.customer_state state , count(o.order_id) as purchase
from fact_order o
Join dim_customers c
on o.customer_key = c.customer_key
group by c.customer_state
order by purchase desc


-- Q7 : Which logistic route that have heavy traffic in our ecommerce?
Select s.seller_city as seller_city, c.customer_city as customer_city, COUNT(DISTINCT o.order_id) as total_orders
FROM fact_order o
inner join dim_sellers s on o.seller_key = s.seller_key
inner join dim_customers c on o.customer_key = c.customer_key
group by s.seller_city, c.customer_city order by total_orders desc
Limit 5;

--Q8 : How many late delivered order in our ecommerce? Are late order affecting the customer satisfaction?
WITH delivery_status_cte as (
select case when delivered_date > estimated_time_delivery then 'Late' else 'On Time' end as delivery_status, 
feedback_score 
from fact_order o 
join dim_feedback f on f.feedback_key = o.feedback_key
)
SELECT delivery_status, ROUND(AVG(feedback_score), 1) as average_rating, 
count(*) as total_orders from delivery_status_cte group by delivery_status;
--Q9 : How long are the delay for delivery / shipping process in each state?
select 
c.customer_state,
Round(avg(Extract(epoch from o.delivered_date - o.pickup_date) / 3600 / 24), 2) as avg_delay_days 
from fact_order o
JOIN dim_customers c ON o.customer_key = c.customer_key
where o.delivered_date > o.pickup_date
group by c.customer_state
Order by avg_delay_days desc

--Q10 
select c.customer_state,Round(avg(Extract(epoch from o.delivered_date - o.estimated_time_delivery) / 3600 / 24), 2) as avg_delivery_diff
from fact_order o
JOIN dim_customers c ON o.customer_key = c.customer_key
where delivered_date is not null and estimated_time_delivery is not null
group by c.customer_state 
Order by avg_delivery_diff asc
