{{ config(materialized='view') }}

SELECT *
FROM {{ source('olist_raw', 'order_items') }};
