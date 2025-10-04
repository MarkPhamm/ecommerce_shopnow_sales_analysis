WITH customer_stats AS (
    SELECT 
        customer_id,
        COUNT(DISTINCT order_id) AS total_orders,
        SUM(amount) AS total_revenue
    FROM ecommerce
    GROUP BY customer_id
),

-- Calculate per-customer Average Order Value
customer_aov AS (
    SELECT
        customer_id,
        ROUND(total_revenue * 1.0 / total_orders, 2) AS avg_order_value,
        total_orders,
        total_revenue
    FROM customer_stats
),

-- Calculate purchase frequency for each customer
purchase_freq AS (
    SELECT
        customer_id,
        avg_order_value,
        total_orders,
        total_revenue,
        ROUND(total_orders * 1.0 / (SELECT COUNT(DISTINCT customer_id) FROM ecommerce), 3) AS purchase_frequency
    FROM customer_aov
)

-- Calculate CLV and assign segment
SELECT
    customer_id,
    printf('$%.2f', avg_order_value) AS avg_order_value,
    purchase_frequency,
    printf('$%.2f', ROUND(avg_order_value * purchase_frequency, 2)) AS CLV,
    CASE
        WHEN purchase_frequency >= 0.03 THEN 'Champions'
        WHEN purchase_frequency BETWEEN 0.015 AND 0.029 THEN 'Potential'
        ELSE 'At Risk'
    END AS customer_segment
FROM purchase_freq
ORDER BY CLV DESC;
