-- 1. What is the retailer's total revenue?
SELECT ROUND(SUM(total_amount), 2) AS total_revenue
FROM sales;

-- 2. How many orders were placed?
SELECT COUNT(*) AS total_orders
FROM sales;

-- 3. What is the average order value?
SELECT ROUND(AVG(total_amount), 2) AS avg_order_value
FROM sales;

-- 4. How many units were sold?
SELECT SUM(quantity) AS total_units_sold
FROM salesitems;

-- 5. What is the average number of items per order?
SELECT ROUND(SUM(si.quantity) * 1.0 / COUNT(DISTINCT s.sale_id), 2) AS avg_items_per_order
FROM sales s
JOIN salesitems si ON s.sale_id = si.sale_id;


-- Revenue and orders by sales channel
SELECT
    channel,
    ROUND(SUM(total_amount), 2)                                         AS total_revenue,
    COUNT(*)                                                            AS number_of_orders,
    ROUND(AVG(total_amount), 2)                                         AS avg_order_value,
    ROUND(SUM(total_amount) * 100.0 / SUM(SUM(total_amount)) OVER (), 2) AS pct_of_total_revenue
FROM sales
GROUP BY channel
ORDER BY total_revenue DESC;

-- Revenue and orders by country
SELECT
    country,
    ROUND(SUM(total_amount), 2)  AS total_revenue,
    COUNT(*)                     AS number_of_orders,
    ROUND(AVG(total_amount), 2)  AS avg_order_value,
    RANK() OVER (ORDER BY SUM(total_amount) DESC) AS revenue_rank
FROM sales
GROUP BY country
ORDER BY revenue_rank;

-- Monthly sales performance
WITH monthly_orders AS (
    SELECT
        TO_CHAR(sale_date, 'YYYY-MM') AS month,
        sale_id,
        total_amount
    FROM sales
),
monthly_units AS (
    SELECT
        s.sale_id,
        SUM(si.quantity) AS quantity
    FROM sales s
    JOIN salesitems si ON s.sale_id = si.sale_id
    GROUP BY s.sale_id
)
SELECT
    mo.month,
    ROUND(SUM(mo.total_amount), 2)               AS revenue,
    COUNT(DISTINCT mo.sale_id)                   AS orders,
    SUM(mu.quantity)                             AS units_sold,
    ROUND(AVG(mo.total_amount), 2)               AS avg_order_value
FROM monthly_orders mo
JOIN monthly_units mu ON mo.sale_id = mu.sale_id
GROUP BY mo.month
ORDER BY mo.month;


-- Date coverage
SELECT
    MIN(sale_date) AS first_sale_date,
    MAX(sale_date) AS last_sale_date
FROM sales;

WITH monthly_sales AS (
    SELECT
        DATE_TRUNC('month', sale_date) AS month,
        SUM(total_amount) AS revenue
    FROM sales
    GROUP BY DATE_TRUNC('month', sale_date)
),
monthly_growth AS (
    SELECT
        month,
        revenue,
        LAG(revenue) OVER (ORDER BY month) AS previous_month_revenue
    FROM monthly_sales
)
SELECT
    TO_CHAR(month, 'YYYY-MM') AS month,
    ROUND(revenue, 2) AS revenue,
    ROUND(previous_month_revenue, 2) AS previous_month_revenue,
    ROUND(
        (revenue - previous_month_revenue)
        / previous_month_revenue * 100,
        2
    ) AS month_over_month_growth_pct
FROM monthly_growth
ORDER BY month;

-- For each country, which sales channel generates the most revenue?
WITH country_channel_revenue AS (
    SELECT
        country,
        channel,
        SUM(total_amount) AS revenue,
        COUNT(*)           AS orders
    FROM sales
    GROUP BY country, channel
),
ranked AS (
    SELECT
        country,
        channel,
        revenue,
        orders,
        RANK() OVER (PARTITION BY country ORDER BY revenue DESC) AS channel_rank
    FROM country_channel_revenue
)
SELECT
    country,
    channel   AS top_channel,
    ROUND(revenue, 2) AS revenue,
    orders
FROM ranked
WHERE channel_rank = 1
ORDER BY revenue DESC;

-- 1. Top 10 products by revenue
SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.brand,
    ROUND(SUM(si.sale_total), 2) AS total_revenue,
    SUM(si.quantity)                        AS units_sold
FROM salesitems si
JOIN products p ON si.product_id = p.product_id
GROUP BY p.product_id, p.product_name, p.category, p.brand
ORDER BY total_revenue DESC
LIMIT 10;

-- 2. Top 10 products by units sold
SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.brand,
    SUM(si.quantity)                        AS units_sold,
    ROUND(SUM(si.sale_total), 2) AS total_revenue
FROM salesitems si
JOIN products p ON si.product_id = p.product_id
GROUP BY p.product_id, p.product_name, p.category, p.brand
ORDER BY units_sold DESC
LIMIT 10;

-- 3. Revenue, units sold, and estimated gross profit by category
SELECT
    p.category,
    ROUND(SUM(si.sale_total), 2)                                   AS total_revenue,
    SUM(si.quantity)                                                          AS units_sold,
    ROUND(SUM(si.sale_total) - SUM(p.cost_price * si.quantity), 2) AS estimated_gross_profit
FROM salesitems si
JOIN products p ON si.product_id = p.product_id
GROUP BY p.category
ORDER BY total_revenue DESC;

-- 4. Revenue and gross profit by brand
SELECT
    p.brand,
    ROUND(SUM(si.sale_total), 2)                                   AS total_revenue,
    ROUND(SUM(si.sale_total) - SUM(p.cost_price * si.quantity), 2) AS gross_profit
FROM salesitems si
JOIN products p ON si.product_id = p.product_id
GROUP BY p.brand
ORDER BY total_revenue DESC;

-- 5. Top 5 most profitable products
SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.brand,
    SUM(si.quantity)                                                          AS units_sold,
    ROUND(SUM(si.sale_total), 2)                                   AS total_revenue,
    ROUND(SUM(si.sale_total) - SUM(p.cost_price * si.quantity), 2) AS gross_profit
FROM salesitems si
JOIN products p ON si.product_id = p.product_id
GROUP BY p.product_id, p.product_name, p.category, p.brand
ORDER BY gross_profit DESC
LIMIT 5;