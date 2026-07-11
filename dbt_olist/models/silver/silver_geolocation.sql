{{ config(materialized='view') }}

SELECT
    CAST(geolocation_zip_code_prefix AS INT) AS geolocation_zip_code_prefix,
    ROUND(AVG(CAST(geolocation_lat AS DOUBLE)), 6) AS avg_latitude,
    ROUND(AVG(CAST(geolocation_lng AS DOUBLE)), 6) AS avg_longitude,
    LOWER(TRIM(geolocation_city)) AS city,
    UPPER(TRIM(geolocation_state)) AS state
FROM {{ ref('bronze_geolocation') }}
WHERE geolocation_zip_code_prefix IS NOT NULL
GROUP BY
    CAST(geolocation_zip_code_prefix AS INT),
    LOWER(TRIM(geolocation_city)),
    UPPER(TRIM(geolocation_state));
