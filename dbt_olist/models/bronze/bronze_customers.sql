{{ config(materialized='view') }}

SELECT *
FROM {{ source('olist_raw', 'customers') }};
