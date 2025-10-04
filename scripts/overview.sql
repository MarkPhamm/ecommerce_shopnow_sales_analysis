SELECT
  COUNT(DISTINCT customer_id) AS total_customers,
  COUNT(*) AS total_orders,
  MIN(order_date) AS earliest_order,
  MAX(order_date) AS latest_order
FROM ecommerce;