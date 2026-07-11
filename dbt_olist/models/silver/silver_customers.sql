{{ config(materialized='view') }}

SELECT DISTINCT
    customer_id,
    customer_unique_id,
    CAST(customer_zip_code_prefix AS INT) AS customer_zip_code_prefix,
    LOWER(TRIM(customer_city)) AS customer_city,
    UPPER(TRIM(customer_state)) AS customer_state
FROM {{ ref('bronze_customers') }}
WHERE customer_id IS NOT NULL;
