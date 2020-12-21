WITH source AS (
  SELECT * FROM {{ source('subscription_price_changes', 'rebillings') }}
)

SELECT * FROM source