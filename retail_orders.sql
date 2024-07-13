--Q1. Average order value (AOV) for each month.
select date_trunc('month', order_date) as order_month,
       round(avg(sale_price * quantity),2) as avg_order_value
from retail_orders
group by order_month
order by order_month;

--Q2. Total discount amount given for each region
select region, round(sum(discount_percent * sale_price * quantity / 100),2) as total_discount
from retail_orders
group by region
order by total_discount desc;

--Q3. Top segment that generate the most revenue
select segment, sum(sale_price * quantity) as total_revenue
from retail_orders
group by segment
order by total_revenue desc
limit 1;

--Q4. Top 5 products with the highest sales revenue
select product_id, sum(sale_price * quantity) as total_revenue
from retail_orders
group by product_id
order by total_revenue desc
limit 5;

--Q5. The top product categories by total sales revenue in each region
with category_sales as (
    select region, category, SUM(sale_price * quantity) AS total_sales_revenue    
    from retail_orders    
    group by region, category
),
ranked_categories as (
    select region, category, total_sales_revenue,
        row_number() over (partition by region order by total_sales_revenue desc) as category_rank
    from category_sales  
)
SELECT region, category, total_sales_revenue
from ranked_categories
order by region, total_sales_revenue desc;

--Q6. Correlation between discount percentage and total sales revenue across different product categories?
with category_sales as (
    select category, sum(sale_price * quantity) as total_sales_revenue, avg(discount_percent) as avg_discount_percent    
    from retail_orders   
    group by category      
)
select category, corr(avg_discount_percent, total_sales_revenue) as correlation_coefficient    
from category_sales
group by category
order by correlation_coefficient desc;

--Q7. Top 3 cities with the highest average order quantity for each product category
with city_order_quantity as (
    select category, city,
        avg(quantity) as avg_order_quantity,
        row_number() over (partition by category order by avg(quantity) desc) as city_rank
    from retail_orders   
    group by category, city   
)
select category, city, cast(avg_order_quantity as int)
from city_order_quantity    
where city_rank <= 3    
order by category, avg_order_quantity desc;

--Q8. Regions wise average order value for each product category
with category_avg_order_value as (
    select region, category,
		round(AVG(sale_price * quantity),2) AS avg_order_value
    from retail_orders
    group by region, category
)
select region, category, avg_order_value
from category_avg_order_value
order by region, category;

--Q9. Highest average order value for each product category (region)
with category_region_sales as (
    select category, region,
        round(avg(sale_price * quantity),2) as avg_order_value,
        row_number() over (partition by category order by avg(sale_price * quantity) desc) as region_rank
    from retail_orders
    group by category, region    
)
select category, region, avg_order_value
from category_region_sales
where region_rank = 1
order by category, avg_order_value DESC;
    


