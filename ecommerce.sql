

/* Create a temporary table that joins the orders, 
order_products, and products tables to get information about 
each order, including the products that were purchased and 
their department and aisle information*/
create temp table order_info as (
select o.order_id, o.order_number, o.order_dow, o.order_hour_of_day,
o.days_since_prior_order,pr.product_id, pr.add_to_cart_order, pr.reordered,
p.product_name, p.aisle_id, p.department_id from orders o join order_products pr on o.order_id=pr.order_id
join products p on p.product_id = pr.product_id
	);
	
select *from order_info;
	
/* Create a temporary table that groups the orders by product
and finds the total number of times each product was purchased, 
the total number of times each product was reordered, 
and the average number of times each product was added to a cart. */

create temp table product_order_summary as(
select product_id ,product_name ,count(*) as total_numer_of_times_product_purchased,
count( CASE WHEN reordered=1 THEN 1 ELSE NULL END) as total_reorders,
avg(add_to_cart_order) as avg_add_to_cart
from order_info group by product_id,product_name);

select *from product_order_summary;

/* Create a temporary table that groups the orders by department 
and finds the total number of products purchased,
the total number of unique products purchased, 
the total number of products purchased on weekdays vs weekends, and 
the average time of day that products in each department are ordered. */


create temp table department_order_summary as
select department_id, count(product_id) as total_products_purchased,
       count(distinct product_id) as total_unique_products,
	   count( case when order_dow<6 then 1 else null end) as total_weekday_purchases,
	   count(case when order_dow >=6 then 1 else null end) as total_weekend_purchases,
	   avg(order_hour_of_day) as average_time_of_day
from order_info group by department_id;


select *from department_order_summary;

/*
Create a temporary table that groups the orders
by aisle and finds the top 10 most popular aisles, 
including the total number of products purchased 
and the total number of unique products purchased from each aisle.
*/
 create temp table aisle_order_summary as
 
 (select aisle_id ,count(*) as total_orders ,
 count(distinct product_id) as total_unique_products_purchased
 from order_info group by aisle_id order by total_orders desc limit 10);
 
 select *from aisle_order_summary;
 
 
 /*   Combine the information from the previous temporary tables 
 into a final table that shows the product ID, product name, 
 department ID, department name, aisle ID, aisle name,
 total number of times purchased, total number of times reordered, 
 average number of times added to cart, total number of products purchased,
 total number of unique products purchased, 
 total number of products purchased on weekdays, 
 total number of products purchased on weekends, 
 and average time of day products are ordered in each department. */                       */
 
 

CREATE TEMPORARY TABLE product_behavior_analysis AS
   ( SELECT pr.product_id, pr.product_name, pr.department_id, d.department, pr.aisle_id, a.aisle,
           pos.total_numer_of_times_product_purchased, pos.total_reorders, pos.avg_add_to_cart,
           dos.total_products_purchased, dos.total_unique_products,
           dos.total_weekday_purchases, dos.total_weekend_purchases, dos.average_time_of_day
    FROM product_order_summary AS pos
    JOIN products AS pr ON pos.product_id = pr.product_id
    JOIN departments AS d ON pr.department_id = d.department_id
    JOIN aisles AS a ON pr.aisle_id = a.aisle_id
    JOIN department_order_summary AS dos ON pr.department_id = dos.department_id);

 select *from product_behavior_analysis;