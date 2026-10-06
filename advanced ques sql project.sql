-- Calculate the percentage contribution of each pizza type to total revenue.
-- with total_sale_cte as(
-- select sum(od.quantity *p.price) as total_sale
-- from pizzas as p
-- join order_details as od
-- on od.pizza_id =p.pizza_id
-- ) select pt.category ,round((sum(od.quantity*p.price) * 100 /total_sale),2) as revenue
-- from pizza_types as pt
-- join pizzas as p
-- on p.pizza_type_id =pt.pizza_type_id
-- join order_details as od
-- on od.pizza_id=p.pizza_id
-- cross join total_sale_cte as cte
-- group by pt.category,total_sale;

select pt.category,
round(sum(od.quantity*p.price) * 100/sum(sum(od.quantity*p.price))over() ,2)as percentage_distribution
from pizza_types as pt
join pizzas as p
on p.pizza_type_id=pt.pizza_type_id
join order_details as od
on od.pizza_id=p.pizza_id
group by pt.category;




-- Analyze the cumulative revenue generated over time.
select o.order_date,
 round(sum(od.quantity*p.price) ,3)as daily_revenue, 
round(sum(sum(od.quantity*p.price)) over(order by o.order_date) ,3)as cummulative_revenue
from orders as o
join order_details as od
on od.order_id=o.order_id
join pizzas as p
on p.pizza_id=od.pizza_id
group by o.order_date
order by o.order_date;



-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
with cte_name as (
    select
		pt.category,
		pt.name,
		sum(od.quantity*p.price) as revenue ,
		dense_rank() over(partition  by pt.category order by sum(od.quantity*p.price) desc) as rank_no
	from pizza_types as pt
	join pizzas as p on p.pizza_type_id =pt.pizza_type_id
	join order_details as od on od.pizza_id=p.pizza_id
	group by pt.category,pt.name
	order by pt.category,pt.name
)
select category,name,revenue,rank_no
from cte_name
where rank_no<=3
order by cte_name.category,cte_name.rank_no
;
