{{ config(materialized='view') }}

SELECT DISTINCT
    geolocation_zip_code_prefix,
    avg_latitude,
    avg_longitude,
    city,
    state
FROM {{ ref('silver_geolocation') }};
