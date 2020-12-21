WITH model AS (
  SELECT * FROM {{ ref('effective_subscription_changes') }}
),

correct_data AS (
  SELECT * FROM {{ source('subscription_price_changes', 'effective_subscription_changes') }}
),

test AS (
  SELECT * FROM model
  EXCEPT DISTINCT
  SELECT * FROM correct_data
)

SELECT * FROM test