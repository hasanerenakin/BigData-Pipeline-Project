{{ config(materialized='view') }}

SELECT DISTINCT
    seller_id,
    CAST(seller_zip_code_prefix AS INT) AS seller_zip_code_prefix,
    LOWER(TRIM(seller_city)) AS seller_city,
    UPPER(TRIM(seller_state)) AS seller_state
FROM {{ ref('bronze_sellers') }}
WHERE seller_id IS NOT NULL;
