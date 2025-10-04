WITH customer_stats AS (
    -- Step 1: Calculate total orders and total revenue per customer
    SELECT 
        customer_id,
        COUNT(DISTINCT order_id) AS total_orders,
        SUM(amount) AS total_revenue
    FROM ecommerce
    GROUP BY customer_id
),

customer_aov AS (
    -- Step 2: Calculate Average Order Value (AOV)
    SELECT
        customer_id,
        ROUND(total_revenue * 1.0 / total_orders, 2) AS avg_order_value,
        total_orders,
        total_revenue
    FROM customer_stats
),

purchase_freq AS (
    -- Step 3: Calculate Purchase Frequency for each customer
    SELECT
        customer_id,
        avg_order_value,
        total_orders,
        total_revenue,
        ROUND(total_orders * 1.0 / (SELECT COUNT(DISTINCT customer_id) FROM ecommerce), 3) AS purchase_frequency
    FROM customer_aov
),

clv_calc AS (
    -- Step 4: Calculate CLV
    SELECT
        customer_id,
        avg_order_value,
        purchase_frequency,
        ROUND(avg_order_value * purchase_frequency, 2) AS CLV
    FROM purchase_freq
)

-- Step 5: Assign segment and recommended action
SELECT
    customer_id,
    printf('$%.0f', avg_order_value) AS AOV,
    purchase_frequency,
    CLV,
    CASE
        WHEN purchase_frequency >= 0.03 THEN 'Champions'
        WHEN purchase_frequency BETWEEN 0.015 AND 0.029 THEN 'Potential'
        WHEN purchase_frequency < 0.015 AND purchase_frequency > 0 THEN 'At Risk'
        ELSE 'Lost'
    END AS segment,
    CASE
        WHEN purchase_frequency >= 0.03 THEN 'Maintain VIP relationship, upsell'
        WHEN purchase_frequency BETWEEN 0.015 AND 0.029 THEN 'Encourage early repurchase with offers'
        WHEN purchase_frequency < 0.015 AND purchase_frequency > 0 THEN 'Optimize remarketing campaigns or replace'
        ELSE 'Exclude from main campaigns'
    END AS action_plan
FROM clv_calc
ORDER BY CLV DESC;
