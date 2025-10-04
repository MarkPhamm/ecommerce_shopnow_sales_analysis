-- Identify the first purchase month for each customer (cohort)
WITH first_order AS (
    SELECT
        customer_id,
        strftime('%Y-%m-01', MIN(order_date)) AS cohort_month
    FROM ecommerce
    GROUP BY customer_id
),

-- Assign cohort month and calculate period_index for each order
orders_with_cohort AS (
    SELECT
        e.customer_id,
        strftime('%Y-%m-01', e.order_date) AS order_month,
        f.cohort_month,
        ((CAST(strftime('%Y', e.order_date) AS INTEGER) - CAST(strftime('%Y', f.cohort_month) AS INTEGER)) * 12
         + (CAST(strftime('%m', e.order_date) AS INTEGER) - CAST(strftime('%m', f.cohort_month) AS INTEGER))
        ) AS period_index
    FROM ecommerce e
    JOIN first_order f ON e.customer_id = f.customer_id
)

-- Count returning customers per cohort over time
SELECT
    cohort_month,
    period_index,
    COUNT(DISTINCT customer_id) AS num_customers
FROM orders_with_cohort
GROUP BY cohort_month, period_index
ORDER BY cohort_month, period_index;
