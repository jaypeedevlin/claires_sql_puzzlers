WITH source AS (
  SELECT * FROM {{ source('apportioning_payments', 'payments') }}
)

SELECT * FROM source