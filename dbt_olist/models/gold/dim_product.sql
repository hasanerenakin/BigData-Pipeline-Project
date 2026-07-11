{{ config(materialized='view') }}

SELECT DISTINCT
    p.product_id,
    p.product_category_name,
    COALESCE(t.product_category_name_english, p.product_category_name, 'unknown') AS product_category_name_english,
    p.product_name_lenght,
    p.product_description_lenght,
    p.product_photos_qty,
    p.product_weight_g,
    p.product_length_cm,
    p.product_height_cm,
    p.product_width_cm
FROM {{ ref('silver_products') }} p
LEFT JOIN {{ ref('silver_category_translation') }} t
    ON p.product_category_name = t.product_category_name;
