--SELECT * from df_sales

-- ¿Cuáles son los 10 productos que más ingresos generan?
SELECT product_id, product_name, SUM(sales) AS total_sales
FROM df_sales
GROUP BY product_id, product_name
ORDER BY total_sales DESC
FETCH FIRST 10 ROWS ONLY

-- ¿Cuáles son los 5 productos más vendidos en cada región?
WITH cte AS(
SELECT product_id, product_name, region, SUM(quantity) AS total_quantity
FROM df_sales
GROUP BY region, product_id, product_name)
SELECT * from (
SELECT *, row_number() OVER(PARTITION BY region
ORDER BY total_quantity DESC) AS ranking
FROM cte) 
WHERE ranking<=5

-- Determinar el crecimiento mensual de ventas para cada año (2021 a 2024)

WITH cte2 AS (
WITH cte AS (
SELECT EXTRACT(YEAR FROM order_date) AS years, EXTRACT(MONTH FROM order_date) AS months,
SUM(sales) AS monthly_sales FROM df_sales
GROUP BY years, months
)
SELECT months,
SUM(CASE WHEN years=2021 THEN monthly_sales else 0 END) AS sales_2021,
SUM(CASE WHEN years=2022 THEN monthly_sales else 0 END) AS sales_2022,
SUM(CASE WHEN years=2023 THEN monthly_sales else 0 END) AS sales_2023,
SUM(CASE WHEN years=2024 THEN monthly_sales else 0 END) AS sales_2024
FROM cte
GROUP BY months
ORDER BY months
)
SELECT months,
TO_CHAR(100*(sales_2022 - sales_2021)/sales_2021, '990D99%') AS crec_YoY_2022,
TO_CHAR(100*(sales_2023 - sales_2022)/sales_2022, '990D99%') AS crec_YoY_2023,
TO_CHAR(100*(sales_2024 - sales_2023)/sales_2023, '990D99%') AS crec_YoY_2024,
TO_CHAR(100*(sales_2024 - sales_2021)/sales_2021/3, '990D99%') AS crec_YoY_promedio
FROM cte2

-- Para cada categoría determinar en qué mes se obtuvieron las mayores ventas

WITH cte AS (
SELECT category, TO_CHAR(order_date, 'YYYYMM') AS order_year_month,
SUM (sales) AS total_sales
FROM df_sales
GROUP BY category, order_year_month
)
SELECT * from (
SELECT *, row_number() OVER(PARTITION BY category
ORDER BY total_sales DESC) AS ranking
FROM cte) 
WHERE ranking=1

-- Qué sub-categoría tuvo mayor crecimiento de margen en cada año?

WITH cte2 AS (
SELECT sub_category,
EXTRACT(YEAR FROM order_date) AS years,
SUM(profit) AS total_profit,
LAG(SUM(profit)) OVER (PARTITION BY sub_category ORDER BY EXTRACT(YEAR FROM order_date)) AS prev_profit,
CASE WHEN 
LAG(SUM(profit)) OVER (PARTITION BY sub_category ORDER BY EXTRACT(YEAR FROM order_date)) = 0 THEN NULL
ELSE TO_CHAR(100*(SUM(profit) - LAG(SUM(profit)) OVER (PARTITION BY sub_category ORDER BY EXTRACT(YEAR FROM order_date))) /
			ABS(LAG(SUM(profit)) OVER (PARTITION BY sub_category ORDER BY EXTRACT(YEAR FROM order_date))), '9999D99%')
END AS crec_yoy
FROM df_sales
GROUP BY sub_category, years
),
cte AS (
SELECT sub_category, years, total_profit, crec_yoy,
RANK() OVER (PARTITION BY years ORDER BY crec_yoy DESC) AS ranking
FROM cte2
WHERE crec_yoy IS NOT null
)
SELECT sub_category, years, total_profit, crec_yoy
FROM cte
WHERE ranking = 1;

-- Cuántos días demora en promedio cada método de despacho? Hay diferencias por region?

SELECT ship_mode, region,
ROUND(AVG(ship_date - order_date),2) AS dias_demora,
ROUND(STDDEV(ship_date - order_date),3) AS STDEV
FROM df_sales
GROUP BY ship_mode, region
ORDER BY ship_mode

-- 3 Clientes que más compran en cada año?

WITH cte AS(
SELECT customer_id, region, segment, EXTRACT(YEAR FROM order_date) AS years,
SUM(CASE WHEN EXTRACT(YEAR FROM order_date)=2021 THEN sales else 0 END) AS sales_2021,
SUM(CASE WHEN EXTRACT(YEAR FROM order_date)=2022 THEN sales else 0 END) AS sales_2022,
SUM(CASE WHEN EXTRACT(YEAR FROM order_date)=2023 THEN sales else 0 END) AS sales_2023,
SUM(CASE WHEN EXTRACT(YEAR FROM order_date)=2024 THEN sales else 0 END) AS sales_2024
FROM df_sales
GROUP BY customer_id, years, region, segment
)
,cte2 AS(
SELECT *,
DENSE_RANK() OVER (ORDER BY sales_2021 DESC) AS ranking_2021,
DENSE_RANK() OVER (ORDER BY sales_2022 DESC) AS ranking_2022,
DENSE_RANK() OVER (ORDER BY sales_2023 DESC) AS ranking_2023,
DENSE_RANK() OVER (ORDER BY sales_2024 DESC) AS ranking_2024
FROM cte
),
cte3 AS(
SELECT customer_id, region, segment, SUM(sales_2021) AS sales_2021,
SUM(sales_2022) AS sales_2022, SUM(sales_2023) AS sales_2023, SUM(sales_2024) AS sales_2024,
MIN(ranking_2021) AS rank_2021, MIN(ranking_2022) AS rank_2022,
MIN(ranking_2023) AS rank_2023, MIN(ranking_2024) AS rank_2024
FROM cte2
GROUP BY customer_id, region, segment
)
SELECT cte3.customer_id, region, segment, sales_2021, sales_2022, sales_2023, sales_2024
FROM cte3
WHERE rank_2021<=3 OR rank_2022<=3 OR rank_2023<=3 OR rank_2024<=3

-- Describir los cluster en función de otras columnas

WITH rank_cat AS (
SELECT cluster, category AS mode_cat,
DENSE_RANK() OVER (PARTITION BY cluster ORDER BY COUNT(*) DESC) AS rank_sc
FROM df_sales
GROUP BY cluster, category
),
rank_seg AS (
SELECT cluster, segment AS mode_segment,
DENSE_RANK() OVER (PARTITION BY cluster ORDER BY COUNT(*) DESC) AS rank_sg
FROM df_sales
GROUP BY cluster, segment
),
rank_sta AS (
SELECT cluster, state AS mode_state,
DENSE_RANK() OVER (PARTITION BY cluster ORDER BY COUNT(*) DESC) AS rank_st
FROM df_sales
GROUP BY cluster, state
)
SELECT rank_cat.cluster, mode_cat, mode_segment, mode_state,
ROUND(AVG(sales),2) AS average_sales,
ROUND(100*AVG(discount),2) AS average_discount,
ROUND(AVG(profit),2) AS average_profit
FROM rank_cat
LEFT JOIN rank_seg AS a ON rank_cat.cluster=a.cluster
LEFT JOIN rank_sta AS b ON rank_cat.cluster=b.cluster
LEFT JOIN df_sales AS c ON rank_cat.cluster=c.cluster
WHERE rank_sg = 1 AND rank_sc = 1 AND rank_st = 1
GROUP BY rank_cat.cluster,mode_cat, mode_segment, mode_state
ORDER BY cluster


