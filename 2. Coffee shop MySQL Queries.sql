SELECT * FROM coffee_shop_db.`coffee shop sales`;

-- 1. Checking data types of all columns
describe `coffee shop sales`;


-- 2. Changing 'ï»¿transaction_id' into transaction_id
ALTER TABLE 
	`coffee shop sales` 
CHANGE COLUMN `ï»¿transaction_id`  transaction_id INT ;

-- 3. Changing data type of 'transaction_date' 
	-- adding transaction_date_2 after transaction_id
ALTER TABLE `coffee shop sales` ADD transaction_date_2 DATE after transaction_id;

	-- Storing values of transaction_date into transaction_date_2 by converting a string into a date value based on a specified format string.
UPDATE `coffee shop sales`
SET transaction_date_2 = STR_TO_DATE(transaction_date, '%m/%d/%Y');
	
    -- droping the transaction_date column
ALTER TABLE `coffee shop sales`
DROP COLUMN transaction_date;

	-- Renaming transaction_date_2 TO transaction_date
ALTER TABLE `coffee shop sales`
RENAME COLUMN transaction_date_2 TO transaction_date;

-- 4. Changing data type of 'transaction_time
	-- converting a string into a date value based on a specified format string.
	UPDATE `coffee shop sales`
	SET transaction_time = STR_TO_DATE(transaction_time, '%H:%i:%s');
    
    -- Converting data type of transaction_time to Time
    Alter table `coffee shop sales`
    modify column transaction_time time;
    
-- 5.Total Sales by Month
DELIMITER // 
create procedure `Sales_KPI's`(in month_Number INT)
Begin
    -- Total Sales by Month
	Select Concat(round(sum(transaction_qty*unit_price)/1000,1),'K') as Total_Sales
	from `coffee shop sales`
	where month(transaction_date)= month_Number ;
    
    -- Determine the month-on-month increase or decrease in sales.
    select 
		month(transaction_date) as `Month`,
		Concat(round(sum(transaction_qty*unit_price)/1000,1),'K') as Total_Sales,
		round((sum(transaction_qty*unit_price)-lag(sum(transaction_qty*unit_price),1) over(order by month(transaction_date)))/
		lag(sum(transaction_qty*unit_price),1) over(order by month(transaction_date))*100,2) as MOM_Increase
	from `coffee shop sales`
	where month(transaction_date) in(month_Number,month_Number+1)
	GROUP BY 1
	order by 2 ;
    
    -- Calculate the difference in sales between the selected month and the previous month.
     SELECT 
        MONTH(transaction_date) AS `Month`,
        Concat(ROUND(SUM(transaction_qty * unit_price)/1000,1),'K') AS Total_Sales,
        Concat(ROUND((SUM(transaction_qty * unit_price) - LAG(SUM(transaction_qty * unit_price), 1) OVER (ORDER BY MONTH(transaction_date)))/1000,1),'K') AS Sales_Difference
    FROM `coffee shop sales`
    WHERE MONTH(transaction_date) IN (month_Number, month_Number + 1)
    GROUP BY 1
    ORDER BY 1 ;
end//
DELIMITER ;

-- 6. Total Orders by Month
DELIMITER // 
create procedure `Order_KPI's`(in month_Number INT)
Begin

-- 1.	Calculate the total number of orders for each respective month.
    Select Concat(Round(count(transaction_id)/1000,1),'K') as Total_orders
	from `coffee shop sales`
	where month(transaction_date)= month_Number;
    
-- 2. Determine the month-on-month increase or decrease in the number of orders.
select 
		month(transaction_date) as `Month`,
		Concat(round(count(transaction_id)/1000,1),'K') as Total_orders,
		((count(transaction_id)-lag(count(transaction_id),1) over(order by month(transaction_date)))/
		lag(count(transaction_id),1) over(order by month(transaction_date))*100) as MOM_Increase
	from `coffee shop sales`
	where month(transaction_date) in(month_Number,month_Number+1)
	GROUP BY 1
	order by 2 ;
    
    -- 3.Calculate the difference in the number of orders between the selected month and the previous month. 
SELECT 
        MONTH(transaction_date) AS `Month`,
        concat(round(count(transaction_id)/1000,1),'K') AS Total_orders,
        concat(round((count(transaction_id) - LAG(count(transaction_id), 1) OVER (ORDER BY MONTH(transaction_date)))/1000,1),'K') AS Order_Difference
    FROM `coffee shop sales`
    WHERE MONTH(transaction_date) IN (month_Number, month_Number+1)
    GROUP BY 1
    ORDER BY 1 ;
end//
DELIMITER ;

-- 7. Total Quantity by Month
DELIMITER // 
create procedure `Quantity_KPI's`(in month_Number INT)
Begin
   -- Calculate the total quantity sold for each respective month.
    Select concat(round(sum(transaction_qty)/1000,1),'K') as Total_Quantity
	from `coffee shop sales`
	where month(transaction_date)= month_Number;
    
    -- Determine the month-on-month increase or decrease in the total quantity sold.
    select 
		month(transaction_date) as `Month`,
		concat(round(sum(transaction_qty)/1000,1),'K') as Total_Quantity,
		((sum(transaction_qty)-lag(sum(transaction_qty),1) over(order by month(transaction_date)))/
		lag(sum(transaction_qty),1) over(order by month(transaction_date))*100) as MOM_Increase
	from `coffee shop sales`
	where month(transaction_date) in(month_Number,month_Number+1)
	GROUP BY 1
	order by 2 ;

  -- Calculate the difference in the total quantity sold between the selected month and the previous month.
   SELECT 
        MONTH(transaction_date) AS `Month`,
        concat(round(sum(transaction_qty)/1000,1),'K') AS Total_Quantity,
        concat(round((sum(transaction_qty) - LAG(sum(transaction_qty), 1) OVER (ORDER BY MONTH(transaction_date)))/1000,1),'K') AS Quantity_Difference
    FROM `coffee shop sales`
    WHERE MONTH(transaction_date) IN (month_Number, month_Number+1)
    GROUP BY 1
    ORDER BY 1 ;
    end//
DELIMITER ;

-- 8. Calender Heat Map (Total sales, Total quantity, total orders)
Select 
	Concat(round(sum(transaction_qty*unit_price)/1000,1),'K') as total_sales,
	concat(round(sum(transaction_qty)/1000,1),'K') as Total_Quantity,
    Concat(Round(count(transaction_id)/1000,1),'K') as Total_orders
from `coffee shop sales`
where transaction_date='2023-05-18';

-- 9. Sales Analysis by Weekdays and Weekends:
select
	case when dayofweek(transaction_date) in (1,7) then 'WeekEnd'
    else 'WeekDay'
    end as Day_Type,
	Concat(round(sum(transaction_qty*unit_price)/1000,1),'K') as Total_sales
from `coffee shop sales`
where month(transaction_date)=5 -- May month
group by 
	case when dayofweek(transaction_date) in (1,7) then 'WeekEnd'
    else 'WeekDay'
    end;
    
-- 10. Sales Analysis by Store Location:-
select
	store_location ,
	Concat(round(sum(transaction_qty*unit_price)/1000,1),'K') as Total_sales
from `coffee shop sales`
where month(transaction_date)=5 -- May month
group by  store_location
order by 2 desc;

-- 11. Daily Sales Analysis with Average Line:-
-- 1. Average sales:-
select concat(round(avg(total_sales)/1000,1),'K')
from(
	select sum(transaction_qty*unit_price)as total_sales
from `coffee shop sales`
where month(transaction_date)=5 -- May month
group by  transaction_date
) as Inner_Query;

-- 2. Daily total Sales:- 
select
	day(transaction_date) as day_of_month ,
	Concat(round(sum(transaction_qty*unit_price)/1000,1),'K') as Total_sales
from `coffee shop sales`
where month(transaction_date)=5 -- May month
group by  1
order by 1 ;

-- Comparing daily sales with Average using subquery
select
	Day_of_month,
    case when (Total_sales>avg_sales) then 'Above Average'
		 when (Total_sales<avg_sales) then 'Below Average'
         else 'Equal to Average' end as sales_status ,
	Total_sales,
	concat(round(avg_sales/1000,3),'K') as average_sales
from (
	select
		day(transaction_date) as Day_of_month,
		Concat(round(sum(transaction_qty*unit_price)/1000,1),'K') as Total_sales,
		avg(sum(transaction_qty*unit_price)) over() as avg_sales
	from `coffee shop sales`
	where month(transaction_date)=5 -- May month
	group by day(transaction_date)
) As Inner_Query
order by Day_of_month ;

-- Comparing daily sales with Average using CTE
WITH Inner_Query AS (
    SELECT
        DAY(transaction_date) AS Day_of_month,
        SUM(transaction_qty * unit_price) AS Total_sales
    FROM `coffee shop sales`
    WHERE MONTH(transaction_date) = 5 -- May month
    GROUP BY DAY(transaction_date)
),
Avg_Sales_CTE AS (
    SELECT
        concat(round(AVG(Total_sales)/1000,3),'K') AS avg_sales
    FROM Inner_Query
)
SELECT
    Inner_Query.Day_of_month,
    CONCAT(ROUND(Total_sales / 1000, 1), 'K') AS Total_sales,
    CASE 
        WHEN Total_sales > avg_sales THEN 'Above Average'
        WHEN Total_sales < avg_sales THEN 'Below Average'
        ELSE 'Equal to Average' 
    END AS sales_status,
    avg_sales
FROM Inner_Query, Avg_Sales_CTE
ORDER BY Inner_Query.Day_of_month;

-- 12. Sales Analysis by Product Category:
select
	product_category,
	Concat(round(sum(transaction_qty*unit_price)/1000,1),'K') as Total_sales
from `coffee shop sales`
WHERE MONTH(transaction_date) = 5 -- May month
GROUP BY 1
order by 2 desc;

-- 13 Top 10 Products by Sales:
select
	product_type,
	sum(transaction_qty*unit_price) as Total_sales -- If we use concat() and round() it will give wrong answer.
from `coffee shop sales`
WHERE MONTH(transaction_date) = 5 and product_category='Coffee'-- May month
GROUP BY product_type
order by 2 desc 
limit 10;

-- 14. Sales Analysis by Days and Hours:
-- 1. Sales Analysis by hours
Select 
	hour(transaction_time) as Hours,
	sum(transaction_qty*unit_price) as total_sales,
	sum(transaction_qty) as Total_Quantity,
    count(transaction_id) as Total_orders
from `coffee shop sales`
where month(transaction_date)=5 
group by 1
order by 1;
	
-- 2. Sales Analysis by week Days
Select 
	case 
		when dayofweek(transaction_date)=2 then 'Monday'
		when dayofweek(transaction_date)=3 then 'Tuesday'
        when dayofweek(transaction_date)=4 then 'Wednesday'
        when dayofweek(transaction_date)=5 then 'Thursday'
        when dayofweek(transaction_date)=6 then 'Friday'
        when dayofweek(transaction_date)=7 then 'Saturday'
        else 'Sunday' end as Day_of_week,
	round(sum(transaction_qty*unit_price)) as total_sales
from `coffee shop sales`
where month(transaction_date)=5 
group by case 
		when dayofweek(transaction_date)=2 then 'Monday'
		when dayofweek(transaction_date)=3 then 'Tuesday'
        when dayofweek(transaction_date)=4 then 'Wednesday'
        when dayofweek(transaction_date)=5 then 'Thursday'
        when dayofweek(transaction_date)=6 then 'Friday'
        when dayofweek(transaction_date)=7 then 'Saturday'
        else 'Sunday' end
;

-- Sales Analysis by week Days and Hours:
SELECT 
    HOUR(transaction_time) AS Hours,
    ROUND(SUM(CASE WHEN DAYOFWEEK(transaction_date) = 2 THEN transaction_qty * unit_price ELSE 0 END)) AS Monday,
    ROUND(SUM(CASE WHEN DAYOFWEEK(transaction_date) = 3 THEN transaction_qty * unit_price ELSE 0 END)) AS Tuesday,
    ROUND(SUM(CASE WHEN DAYOFWEEK(transaction_date) = 4 THEN transaction_qty * unit_price ELSE 0 END)) AS Wednesday,
    ROUND(SUM(CASE WHEN DAYOFWEEK(transaction_date) = 5 THEN transaction_qty * unit_price ELSE 0 END)) AS Thursday,
    ROUND(SUM(CASE WHEN DAYOFWEEK(transaction_date) = 6 THEN transaction_qty * unit_price ELSE 0 END)) AS Friday,
    ROUND(SUM(CASE WHEN DAYOFWEEK(transaction_date) = 7 THEN transaction_qty * unit_price ELSE 0 END)) AS Saturday,
    ROUND(SUM(CASE WHEN DAYOFWEEK(transaction_date) = 1 THEN transaction_qty * unit_price ELSE 0 END)) AS Sunday
FROM 
    `coffee shop sales`
WHERE 
    MONTH(transaction_date) = 5 
GROUP BY 
    HOUR(transaction_time)
ORDER BY 
    HOUR(transaction_time);
