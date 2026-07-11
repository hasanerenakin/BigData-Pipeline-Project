{{ config(materialized='view') }}

SELECT DISTINCT
    order_id,
    CAST(payment_sequential AS INT) AS payment_sequential,
    payment_type,
    CAST(payment_installments AS INT) AS payment_installments,
    CAST(payment_value AS DOUBLE) AS payment_value
FROM {{ ref('bronze_order_payments') }}
WHERE order_id IS NOT NULL;
