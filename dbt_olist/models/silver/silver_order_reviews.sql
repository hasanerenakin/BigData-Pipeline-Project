{{ config(materialized='view') }}

SELECT DISTINCT
    review_id,
    order_id,
    CAST(review_score AS DOUBLE) AS review_score,
    CAST(review_creation_date AS TIMESTAMP) AS review_creation_date,
    CAST(review_answer_timestamp AS TIMESTAMP) AS review_answer_timestamp
FROM {{ ref('bronze_order_reviews') }}
WHERE review_id IS NOT NULL
  AND order_id IS NOT NULL;
