{{ config(materialized='view') }}

SELECT
    oi.order_id,
    oi.order_item_id,
    oi.product_id,
    oi.seller_id,
    o.customer_id,
    o.order_status,
    o.order_purchase_timestamp,
    oi.price,
    oi.freight_value
FROM {{ ref('silver_order_items') }} oi
JOIN {{ ref('silver_orders') }} o
    ON oi.order_id = o.order_id;
