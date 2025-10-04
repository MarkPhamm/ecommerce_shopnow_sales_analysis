WITH analysis_date AS (
    -- Define analysis date: the most recent order_date in the dataset
    SELECT DATE(MAX(order_date)) AS ref_date
    FROM ecommerce
),

-- 1. Calculate R, F, M for each customer
rfm_base AS (
    SELECT 
        e.customer_id,
        -- Recency = days since the most recent order compared to the analysis date
        CAST(julianday((SELECT ref_date FROM analysis_date)) - julianday(MAX(e.order_date)) AS INT) AS recency,
        
        -- Frequency = number of distinct orders
        COUNT(DISTINCT e.order_id) AS frequency,
        
        -- Monetary = total spending
        ROUND(SUM(e.amount), 2) AS monetary
    FROM ecommerce e
    GROUP BY e.customer_id
),

-- 2. Assign R, F, M scores (scale 1–5 using quintiles)
rfm_scores AS (
    SELECT
        customer_id,
        recency,
        frequency,
        monetary,
        
        -- Recency: smaller values are better → reverse the scale
        6 - NTILE(5) OVER (ORDER BY recency ASC) AS r_score,
        
        -- Frequency: higher values are better
        NTILE(5) OVER (ORDER BY frequency ASC) AS f_score,
        
        -- Monetary: higher values are better
        NTILE(5) OVER (ORDER BY monetary ASC) AS m_score
    FROM rfm_base
)

-- 3. Compute total RFM score and assign customer segment
SELECT 
    customer_id,
    recency,
    frequency,
    monetary,
    r_score,
    f_score,
    m_score,
    (r_score + f_score + m_score) AS rfm_score,
    
    CASE
        WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Champions'
        WHEN r_score >= 3 AND f_score >= 3 THEN 'Potential'
        WHEN r_score <= 2 AND f_score <= 2 THEN 'At Risk'
        ELSE 'Others'
    END AS customer_segment
FROM rfm_scores
ORDER BY rfm_score DESC, customer_id;
