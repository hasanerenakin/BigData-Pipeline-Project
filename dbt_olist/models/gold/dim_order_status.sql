{{ config(materialized='view') }}

SELECT DISTINCT
    order_status
FROM {{ ref('silver_orders') }}
WHERE order_status IS NOT NULL;
