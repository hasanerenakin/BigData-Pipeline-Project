{{ config(materialized='view') }}

SELECT DISTINCT
    payment_type
FROM {{ ref('silver_order_payments') }}
WHERE payment_type IS NOT NULL;
