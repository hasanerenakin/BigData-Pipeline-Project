{{ config(materialized='view') }}

SELECT
    r.review_id,
    r.order_id,
    oi.order_item_id,
    oi.product_id,
    oi.seller_id,
    o.customer_id,
    o.order_purchase_timestamp,
    r.review_score
FROM {{ ref('silver_order_reviews') }} r
JOIN {{ ref('silver_orders') }} o
    ON r.order_id = o.order_id
JOIN {{ ref('silver_order_items') }} oi
    ON r.order_id = oi.order_id;
