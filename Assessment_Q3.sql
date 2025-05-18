WITH latest_transactions AS (
    -- Find the most recent transaction date for each plan
    -- by combining both savings and withdrawal transactions
    SELECT 
        p.id AS plan_id,
        p.owner_id,
        -- Categorize plan type
        CASE 
            WHEN p.is_regular_savings = 1 THEN 'Savings'
            WHEN p.is_a_fund = 1 THEN 'Investment'
            ELSE 'Other'
        END AS type,
        -- Complex logic to determine the last transaction date
        -- by comparing the latest savings and withdrawal dates
        CASE
            WHEN MAX(s.transaction_date) IS NULL AND MAX(w.transaction_date) IS NULL THEN NULL
            WHEN MAX(s.transaction_date) IS NULL THEN MAX(w.transaction_date)
            WHEN MAX(w.transaction_date) IS NULL THEN MAX(s.transaction_date)
            WHEN MAX(s.transaction_date) > MAX(w.transaction_date) THEN MAX(s.transaction_date)
            ELSE MAX(w.transaction_date)
        END AS last_transaction_date
    FROM plans_plan p
    LEFT JOIN savings_savingsaccount s ON p.id = s.plan_id
    LEFT JOIN withdrawals_withdrawal w ON p.id = w.plan_id
    GROUP BY p.id, p.owner_id, p.is_regular_savings, p.is_a_fund
)

-- Final query: Return inactive plans (no activity for over 365 days)
SELECT 
    plan_id,
    owner_id,
    type,
    last_transaction_date,
    DATEDIFF(CURRENT_DATE, last_transaction_date) AS inactivity_days -- Calculate days since last activity
FROM latest_transactions
WHERE last_transaction_date IS NOT NULL
AND last_transaction_date < DATE_SUB(CURRENT_DATE, INTERVAL 365 DAY) -- Filter for plans inactive for more than a year
ORDER BY inactivity_days DESC; -- Show most inactive plans first