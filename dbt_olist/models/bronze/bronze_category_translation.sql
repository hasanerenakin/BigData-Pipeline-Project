{{ config(materialized='view') }}

SELECT *
FROM {{ source('olist_raw', 'category_translation') }};
