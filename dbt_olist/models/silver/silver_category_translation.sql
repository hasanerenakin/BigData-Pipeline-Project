{{ config(materialized='view') }}

SELECT DISTINCT
    product_category_name,
    product_category_name_english
FROM {{ ref('bronze_category_translation') }}
WHERE product_category_name IS NOT NULL;
