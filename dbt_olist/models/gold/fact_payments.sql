{{ config(materialized='view') }}

SELECT
    p.order_id,
    o.customer_id,
    p.payment_sequential,
    p.payment_type,
    p.payment_installments,
    p.payment_value,
    o.order_purchase_timestamp
FROM {{ ref('silver_order_payments') }} p
JOIN {{ ref('silver_orders') }} o
    ON p.order_id = o.order_id;
