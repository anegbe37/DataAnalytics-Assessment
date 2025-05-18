/**
 * Purpose: Calculate estimated customer lifetime value (CLV)
 * This query computes a customer lifetime value estimate based on transaction frequency,
 * tenure, and average transaction amount to help identify most valuable customers.
 */

WITH customer_transactions AS (
    -- Gather customer transaction data and calculate key metrics
    SELECT 
        u.id AS customer_id,
        CONCAT(u.first_name, ' ', u.last_name) AS name,
        TIMESTAMPDIFF(MONTH, u.date_joined, CURRENT_DATE) AS tenure_months, -- Customer tenure in months
        -- Count unique transactions (combining savings and withdrawals)
        COUNT(DISTINCT CASE WHEN s.id IS NOT NULL THEN s.id END + 
               CASE WHEN w.id IS NOT NULL THEN w.id END) AS total_transactions,
        -- Calculate total amount in naira (converting from kobo)
        COALESCE(SUM(IFNULL(s.confirmed_amount, 0) + IFNULL(w.amount_withdrawn, 0)), 0) / 100 AS total_amount
    FROM users_customuser u
    LEFT JOIN savings_savingsaccount s ON u.id = s.owner_id
    LEFT JOIN withdrawals_withdrawal w ON u.id = w.owner_id
    GROUP BY u.id, u.first_name, u.last_name, u.date_joined
)

-- Final query: Calculate the estimated CLV for each customer
SELECT 
    customer_id,
    name,
    tenure_months,
    total_transactions,
    -- CLV formula: (annual transaction rate) * (average transaction value) * (value factor)
    -- The formula uses 0.001 as a simplified value factor multiplier
    CASE 
        WHEN tenure_months = 0 OR total_transactions = 0 THEN 0 -- Handle edge cases
        ELSE ROUND(
            (total_transactions / tenure_months) * 12 * -- Annual transaction rate
            (0.001 * (total_amount / total_transactions)), -- Value factor * avg transaction amount
            2
        )
    END AS estimated_clv
FROM customer_transactions
ORDER BY estimated_clv DESC -- Sort by highest CLV first