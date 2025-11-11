--MONDAY COFFEE ANALYSIS--
use [Mondaycoffedb]

SELECT * FROM SALES
SELECT * FROM[dbo].[city]
SELECT * FROM[dbo].[customers]
SELECT * FROM[dbo].[products]


/*(1)Coffee Consumers Count--
How many people in each city are estimated to consume coffee, given that 25% of the population does?*/
SELECT  
     [city_name],
    
	     round( ([population]*0.25)/1000000,2) as coff_consumer_million
		  ,city_rank
from  city
order by 2 desc;


/*(2) Total revenue from coffee sales
what is the total revenue generated from coffee sales across all cities in th last quarter of 2023?
*/

select 
city_name,
sum(total) as total_sales
from [dbo].[sales]
left join [dbo].[customers]
on  [dbo].[customers].customer_id=[dbo].[sales].customer_id
left join [dbo].[city]
on [dbo].[city].city_id = [dbo].[customers].city_id
where datepart( year , sale_date) = 2023 and
datepart( quarter, sale_date) = 4
group by city_name
order by 2 desc;

/*(3) Sales count for each product
how many units of each coffee product have been sold?
*/

SELECT 
     product_name,
     COUNT(sale_id) as total_unit
FROM sales
left join [dbo].[products]
on [dbo].[products].product_id = sales.product_id
group by product_name
order by 2 desc 


/*(4) Average sales amount per city
what is the average sales  amount per customer in each city?
*/
SELECT *,

     (total_sales/total_customer) as avg_s_cus_by_city
from(
SELECT 
      city_name,
	  SUM(total) as total_sales,
      COUNT(distinct[dbo].[customers].customer_id ) AS total_customer
from [dbo].[sales]
left join [dbo].[customers]
on  [dbo].[customers].customer_id=[dbo].[sales].customer_id
left join [dbo].[city]
on [dbo].[city].city_id = [dbo].[customers].city_id
group by city_name
) as table1
order by 2 desc;

/*(5)City Population and Coffee Consumers
Provide a list of cities along with their populations and estimated coffee consumers.*/
SELECT
      city_name,
	  population,
	  COUNT(distinct sale_id) as total_consumer
FROM [dbo].[city] AS C
LEFT JOIN [dbo].[customers] AS CU
ON CU.city_id = C.city_id
left join [dbo].[sales] AS S
ON S.customer_id = CU.customer_id
GROUP BY city_name,population
order by 3  desc;

/*(6)Top Selling Products by City
What are the top 3 selling products in each city based on sales volume?*/
select city_name,
       product_name,
	   total_sale
from(
SELECT 
     city_name,
     product_name,
	 SUM(total) as total_sale,
	 ROW_NUMBER() over (partition by city_name order by SUM(total) desc) as rank
FROM products as p
left join [dbo].[sales] as s
on p.product_id = s.product_id
left join [dbo].[customers] as cu
on cu.customer_id = s.customer_id
left join [dbo].[city] ci
on ci.city_id = cu.city_id
group by city_name,product_name
) as rtable
where rank<= 3
order by city_name asc , total_sale desc;

