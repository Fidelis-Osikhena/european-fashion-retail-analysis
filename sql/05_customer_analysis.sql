-- 1. How many customers actually made a purchase?
SELECT COUNT(DISTINCT customer_id) AS purchasing_customers
FROM sales;

-- 2. One-time vs repeat customers
WITH customer_orders AS (
    SELECT
        customer_id,
        COUNT(*) AS order_count,
        SUM(total_amount) AS lifetime_revenue
    FROM sales
    GROUP BY customer_id
),
customer_types AS (
    SELECT
        customer_id,
        order_count,
        lifetime_revenue,
        CASE
            WHEN order_count = 1 THEN 'One-time'
            ELSE 'Repeat'
        END AS customer_type
    FROM customer_orders
)
SELECT
    customer_type,
    COUNT(*) AS number_of_customers,
    ROUND(SUM(lifetime_revenue), 2) AS total_revenue,
    ROUND(AVG(lifetime_revenue), 2) AS avg_revenue_per_customer,
    ROUND(
        SUM(lifetime_revenue)
        / SUM(SUM(lifetime_revenue)) OVER () * 100,
        2
    ) AS pct_of_revenue
FROM customer_types
GROUP BY customer_type
ORDER BY total_revenue DESC;

-- 3. Top 10 customers by lifetime revenue
SELECT
    s.customer_id,
    c.country,
    ROUND(SUM(s.total_amount), 2) AS lifetime_revenue,
    COUNT(*)                      AS total_orders,
    ROUND(AVG(s.total_amount), 2) AS avg_order_value
FROM sales s
JOIN customers c ON s.customer_id = c.customer_id
GROUP BY s.customer_id, c.country
ORDER BY lifetime_revenue DESC
LIMIT 10;

-- 4. Purchase frequency by country
SELECT
    c.country,
    COUNT(DISTINCT s.customer_id)                                          AS purchasing_customers,
    COUNT(*)                                                                AS total_orders,
    ROUND(COUNT(*) * 1.0 / COUNT(DISTINCT s.customer_id), 2)               AS avg_orders_per_customer,
    ROUND(SUM(s.total_amount), 2) AS revenue,
    ROUND(
    SUM(s.total_amount)
    / COUNT(DISTINCT s.customer_id),
    2
) AS revenue_per_customer
FROM sales s
JOIN customers c ON s.customer_id = c.customer_id
GROUP BY c.country
ORDER BY avg_orders_per_customer DESC;



-- ============================================================
-- RFM CUSTOMER SEGMENTATION
-- ============================================================