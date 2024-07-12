---------------------------
-- total sales kpi
CREATE OR ALTER PROC spTotalSales
	@year int = 2020
AS
BEGIN 

	SELECT 
		SUM(unit_price * order_quantity) as sales 
	FROM fct_sales 
	where YEAR(ORDER_DATE) = @year

END

EXEC spTotalSales 

select * from fct_sales 

-- total sales kpi yoy
CREATE OR ALTER PROC spYoYTotalSales
	@year int = 2020
AS
BEGIN
	
	WITH cy_total_sales 
	AS 
	(
		SELECT 
			SUM(unit_price * order_quantity) as cy_sales 
		FROM fct_sales 
		where YEAR(ORDER_DATE) = @year
	), 
	py_total_sales
	AS
	(
		SELECT 
			SUM(unit_price * order_quantity) as py_sales 
		FROM fct_sales 
		where YEAR(ORDER_DATE) = @year - 1
	)
	SELECT 
		((cy_sales- py_sales) / py_sales) * 100 
	FROM 
		cy_total_sales, py_total_sales

END

EXEC spYoYTotalSales 


--- line chart inside kpi sales 
--monthly sales current year 

CREATE OR ALTER PROC spMonthLineCYSales
	@year int = 2020
AS
BEGIN
	SELECT 
		MONTH(order_date) as month,
		SUM(unit_price * order_quantity) as sales 
	FROM fct_sales
	where YEAR(order_date) = @year 
	group by MONTH(order_date)
	order by 1 asc
END

EXEC spMonthLineSales


CREATE OR ALTER PROC spMonthLinePYSales
	@year int = 2020
AS
BEGIN
	SELECT 
		MONTH(order_date) as month,
		SUM(unit_price * order_quantity) as sales 
	FROM fct_sales
	where YEAR(order_date) = @year -1
	group by MONTH(order_date)
	order by 1 asc
END

EXEC spMonthLinePYSales



-----------------------------------------
-- total profit kpi
CREATE OR ALTER PROC spTotalProfit
	@year int = 2020
AS
BEGIN 

	SELECT 
		SUM((unit_price-unit_cost) * order_quantity) as profit 
	FROM fct_sales 
	where YEAR(ORDER_DATE) = @year

END

EXEC spTotalProfit 

select * from fct_sales 

-- total profit kpi yoy
CREATE OR ALTER PROC spYoYTotalProfit
	@year int = 2020
AS
BEGIN
	
	WITH cy_total_profit 
	AS 
	(
		SELECT 
			SUM((unit_price-unit_cost) * order_quantity) as cy_profit
		FROM fct_sales 
		where YEAR(ORDER_DATE) = @year
	), 
	py_total_profit
	AS
	(
		SELECT 
			SUM((unit_price-unit_cost) * order_quantity) as py_profit 
		FROM fct_sales 
		where YEAR(ORDER_DATE) = @year - 1
	)
	SELECT 
		((cy_profit- py_profit) / py_profit) * 100 
	FROM 
		cy_total_profit, py_total_profit

END

EXEC spYoYTotalProfit


--- line chart inside kpi profit 
--monthly sales current year 

CREATE OR ALTER PROC spMonthLineCYProfit
	@year int = 2020
AS
BEGIN
	SELECT 
		MONTH(order_date) as month,
		SUM((unit_price-unit_cost) * order_quantity) as profit 
	FROM fct_sales
	where YEAR(order_date) = 2020 
	group by MONTH(order_date)
	order by 1 asc
END

EXEC spMonthLineCYProfit


CREATE OR ALTER PROC spMonthLinePYProfit
	@year int = 2020
AS
BEGIN
	SELECT 
		MONTH(order_date) as month,
		SUM((unit_price-unit_cost) * order_quantity) as profit 
	FROM fct_sales
	where YEAR(order_date) = @year -1
	group by MONTH(order_date)
	order by 1 asc
END

EXEC spMonthLinePYProfit





-----------------------------------------
-- total Quantity KPI
CREATE OR ALTER PROC spTotalQuantity
	@year int = 2020
AS
BEGIN 

	SELECT 
		SUM(order_quantity) as quantity 
	FROM fct_sales 
	where YEAR(ORDER_DATE) = @year

END

EXEC spTotalQuantity 

select * from fct_sales 

-- total order kpi yoy
CREATE OR ALTER PROC spYoYTotalQuantity
	@year int = 2020
AS
BEGIN
	
	WITH cy_total_qnty
	AS 
	(
		SELECT 
			SUM(order_quantity) as cy_quantity
		FROM fct_sales 
		where YEAR(ORDER_DATE) = @year
	), 
	py_total_qnty
	AS
	(
		SELECT 
			SUM(order_quantity) as py_quantity
		FROM fct_sales 
		where YEAR(ORDER_DATE) = @year - 1
	)
	SELECT 
		((CAST(cy_quantity as decimal(10,2))- py_quantity) / py_quantity) * 100 
	FROM 
		cy_total_qnty, py_total_qnty

END

EXEC spYoYTotalQuantity


--- line chart inside kpi quantity 
--monthly quantity current year 

CREATE OR ALTER PROC spMonthLineCYQnty
	@year int = 2020
AS
BEGIN
	SELECT 
		MONTH(order_date) as month,
		SUM(order_quantity) as qnty
	FROM fct_sales
	where YEAR(order_date) = @year 
	group by MONTH(order_date)
	order by 1 asc
END

EXEC spMonthLineCYQnty


CREATE OR ALTER PROC spMonthLinePYQnty
	@year int = 2020
AS
BEGIN
	SELECT 
		MONTH(order_date) as month,
		SUM(order_quantity) as qnty
	FROM fct_sales
	where YEAR(order_date) = @year -1
	group by MONTH(order_date)
	order by 1 asc
END

EXEC spMonthLinePYQnty




----------------------------------------
-- prior vs current sales by region 

SELECT 
	dr.region,
	SUM(fs.unit_price * fs.order_quantity) as sales
FROM fct_sales fs
INNER JOIN dim_store_location as dsl
ON fs.store_id = dsl.store_id
INNER JOIN dim_region as dr
ON dsl.state_code = dr.state_code
where YEAR(fs.order_date) = 2020
group by dr.region
order by 2 asc

SELECT 
	dr.region,
	SUM(fs.unit_price * fs.order_quantity) as sales
FROM fct_sales fs
INNER JOIN dim_store_location as dsl
ON fs.store_id = dsl.store_id
INNER JOIN dim_region as dr
ON dsl.state_code = dr.state_code
where YEAR(fs.order_date) = 2020 - 1
group by dr.region
order by 2 asc



-------------------------------------------
--customer
CREATE OR ALTER PROC customer_top10
	@year int = 2020
AS
BEGIN 

	SELECT 
		top 10
		dc.customer_name,
		SUM(order_quantity) as qnty
	FROM fct_sales fs
	INNER JOIN dim_customer dc
	ON fs.customer_id = dc.customer_id
	where YEAR(order_date) = @year
	group by dc.customer_name
	order by 2 desc

END

EXEC customer_top10


----------------------------------------
-- monthly cur yr sales

CREATE OR ALTER PROC customer_top10
	@year int = 2020
AS
BEGIN 

	SELECT 
		MONTH(order_date) as month,
		SUM(unit_price * order_quantity) as sales 
	FROM fct_sales 
	where YEAR(order_date)  = @year 
	group by month(order_date)
	order by month asc

END

----------------------------------------
-- monthly cur yr profit
CREATE OR ALTER PROC customer_top10
	@year int = 2020
AS
BEGIN 

	SELECT 
		MONTH(order_date) as month,
		SUM((unit_price - unit_cost) * order_quantity) as sales 
	FROM fct_sales 
	where YEAR(order_date)  = @year 
	group by month(order_date)
	order by month asc

END