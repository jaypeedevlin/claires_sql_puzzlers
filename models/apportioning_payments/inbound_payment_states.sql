WITH payments as (
  SELECT * FROM {{ ref('stg_apportioning_payments__payments') }}
),

inbounds AS (
  SELECT * FROM payments
  WHERE payment_type = 'inbound'
),

payouts AS (
  SELECT * FROM payments
  WHERE payment_type = 'payout'
),

refunds AS (
  SELECT * FROM payments
  WHERE payment_type = 'refund'
),

inbounds_with_prev AS (
  SELECT
    *,
    COALESCE(SUM(amount) OVER (PARTITION BY task_id ORDER BY payment_id
                               ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING), 0) AS previous_amounts
  FROM inbounds
),

with_payouts AS (
  SELECT
    inbounds.task_id,
    inbounds.payment_id AS inbound_payment_id,
    inbounds.amount AS inbound_amount,
    CASE
      WHEN payouts.amount - inbounds.previous_amounts > inbounds.amount -- when payout balance exceeds the inbounds amount
        THEN inbounds.amount -- then payout the full inbound amount.
      WHEN inbounds.previous_amounts > 0 -- when it's the second or later payment
        AND payouts.amount > inbounds.previous_amounts -- and there's still a payout balance
        AND payouts.amount <= inbounds.amount + inbounds.previous_amounts -- and the payout can be finalized in full
        THEN payouts.amount - inbounds.previous_amounts -- then payout whatever is left 
      WHEN inbounds.previous_amounts > payouts.amount -- when the payouts are complete
        THEN 0 -- then don't pay anything out
      ELSE COALESCE(payouts.amount, 0) -- when there is either no payout, or the remaining payout exceeds the inbound amount
      END AS payout_amount
   FROM inbounds_with_prev inbounds
   LEFT JOIN payouts ON inbounds.task_id = payouts.task_id
),

with_refunds AS (
  SELECT
    with_payouts.*,
    CASE
      WHEN refunds.amount IS NULL THEN 0 -- handles in progress cases
      ELSE with_payouts.inbound_amount - with_payouts.payout_amount
      END AS refund_amount
  FROM with_payouts
  LEFT JOIN refunds on refunds.task_id = with_payouts.task_id
),

with_escrow_balance AS (
  SELECT
    *,
    inbound_amount - payout_amount - refund_amount AS in_escrow
  FROM with_refunds
)

SELECT * FROM with_escrow_balance