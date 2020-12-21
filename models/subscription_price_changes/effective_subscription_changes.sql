WITH subscription_periods AS (
  SELECT
    rebilling_id,
    subscription_id,
    DATE_ADD(rebilled_at, INTERVAL -1 MONTH) AS period_start_at,
    rebilled_at AS period_end_at
   FROM {{ ref('stg_subscription_price_changes__rebillings') }}
),

price_change_period AS (
  SELECT
    changes.subscription_id,
    changes.price,
    changes.changed_at,
    periods.rebilling_id,
    periods.period_end_at
   FROM {{ ref('stg_subscription_price_changes__subscription_price_changes') }} changes
   INNER JOIN subscription_periods periods ON changes.subscription_id = periods.subscription_id
                                         AND changes.changed_at BETWEEN periods.period_start_at AND periods.period_end_at
),

final AS (
  SELECT DISTINCT
    subscription_id,
    LAST_VALUE(price) OVER (PARTITION BY subscription_id, period_end_at ORDER BY changed_at
                            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS new_price,
    LAST_VALUE(changed_at) OVER (PARTITION BY subscription_id, period_end_at ORDER BY changed_at
                                 ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS changed_at,
    period_end_at AS effective_at
   FROM price_change_period
)

SELECT * FROM final