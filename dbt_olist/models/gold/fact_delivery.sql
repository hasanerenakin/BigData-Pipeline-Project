{{ config(materialized='view') }}

SELECT
    o.order_id,
    o.customer_id,
    c.customer_state,
    c.customer_city,
    o.order_status,
    o.order_purchase_timestamp,
    o.order_approved_at,
    o.order_delivered_carrier_date,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,
    DATEDIFF(
        CAST(o.order_delivered_customer_date AS DATE),
        CAST(o.order_purchase_timestamp AS DATE)
    ) AS delivery_days
FROM {{ ref('silver_orders') }} o
JOIN {{ ref('silver_customers') }} c
    ON o.customer_id = c.customer_id
WHERE o.order_delivered_customer_date IS NOT NULL
  AND o.order_purchase_timestamp IS NOT NULL;
