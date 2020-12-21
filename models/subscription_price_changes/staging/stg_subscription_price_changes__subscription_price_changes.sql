WITH source AS (
  SELECT * FROM {{ source('subscription_price_changes', 'subscription_price_changes') }}
)

SELECT * FROM source