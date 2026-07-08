CREATE DATABASE IF NOT EXISTS olist;

USE olist;

CREATE OR REPLACE VIEW dim_customer AS
SELECT DISTINCT
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state
FROM customers;

CREATE OR REPLACE VIEW dim_seller AS
SELECT DISTINCT
    seller_id,
    seller_zip_code_prefix,
    seller_city,
    seller_state
FROM sellers;

CREATE OR REPLACE VIEW dim_product AS
SELECT DISTINCT
    p.product_id,
    p.product_category_name,
    COALESCE(t.product_category_name_english, p.product_category_name, 'unknown') AS product_category_name_english,
    p.product_name_lenght,
    p.product_description_lenght,
    p.product_photos_qty,
    p.product_weight_g,
    p.product_length_cm,
    p.product_height_cm,
    p.product_width_cm
FROM products p
LEFT JOIN category_translation t
    ON p.product_category_name = t.product_category_name;

CREATE OR REPLACE VIEW dim_order_status AS
SELECT DISTINCT
    order_status
FROM orders;

CREATE OR REPLACE VIEW dim_payment_type AS
SELECT DISTINCT
    payment_type
FROM order_payments;

CREATE OR REPLACE VIEW fact_order_items AS
SELECT
    oi.order_id,
    oi.order_item_id,
    oi.product_id,
    oi.seller_id,
    o.customer_id,
    o.order_status,
    CAST(o.order_purchase_timestamp AS TIMESTAMP) AS order_purchase_timestamp,
    oi.price,
    oi.freight_value
FROM order_items oi
JOIN orders o
    ON oi.order_id = o.order_id;

CREATE OR REPLACE VIEW fact_payments AS
SELECT
    p.order_id,
    o.customer_id,
    p.payment_sequential,
    p.payment_type,
    p.payment_installments,
    p.payment_value,
    CAST(o.order_purchase_timestamp AS TIMESTAMP) AS order_purchase_timestamp
FROM order_payments p
JOIN orders o
    ON p.order_id = o.order_id;

CREATE OR REPLACE VIEW fact_delivery AS
SELECT
    o.order_id,
    o.customer_id,
    c.customer_state,
    c.customer_city,
    o.order_status,
    CAST(o.order_purchase_timestamp AS TIMESTAMP) AS order_purchase_timestamp,
    CAST(o.order_approved_at AS TIMESTAMP) AS order_approved_at,
    CAST(o.order_delivered_carrier_date AS TIMESTAMP) AS order_delivered_carrier_date,
    CAST(o.order_delivered_customer_date AS TIMESTAMP) AS order_delivered_customer_date,
    CAST(o.order_estimated_delivery_date AS TIMESTAMP) AS order_estimated_delivery_date,
    DATEDIFF(
        CAST(o.order_delivered_customer_date AS DATE),
        CAST(o.order_purchase_timestamp AS DATE)
    ) AS delivery_days
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
WHERE o.order_delivered_customer_date IS NOT NULL
  AND o.order_purchase_timestamp IS NOT NULL;

CREATE OR REPLACE VIEW fact_review_items AS
SELECT
    r.review_id,
    r.order_id,
    oi.order_item_id,
    oi.product_id,
    oi.seller_id,
    o.customer_id,
    CAST(o.order_purchase_timestamp AS TIMESTAMP) AS order_purchase_timestamp,
    CAST(r.review_score AS DOUBLE) AS review_score
FROM order_reviews r
JOIN orders o
    ON r.order_id = o.order_id
JOIN order_items oi
    ON r.order_id = oi.order_id;

SHOW TABLES;
