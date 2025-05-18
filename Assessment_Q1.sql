/**
 * Purpose: Identify customers who have both savings and investment products
 * This query finds customers who have active accounts in both regular savings and investment funds,
 * showing their account counts and total deposits sorted by highest deposit amount.
 */

WITH savings_customers AS (
    -- Identify customers who have at least one confirmed savings transaction
    SELECT DISTINCT p.owner_id
    FROM plans_plan p
    JOIN savings_savingsaccount s ON p.id = s.plan_id
    WHERE p.is_regular_savings = 1 
    AND s.confirmed_amount > 0
),
investment_customers AS (
    -- Identify customers who have at least one confirmed investment transaction
    SELECT DISTINCT p.owner_id
    FROM plans_plan p
    JOIN savings_savingsaccount s ON p.id = s.plan_id
    WHERE p.is_a_fund = 1 
    AND s.confirmed_amount > 0
),
customer_deposits AS (
    -- Calculate overall customer statistics including total deposits
    SELECT 
        u.id AS owner_id,
        CONCAT(u.first_name, ' ', u.last_name) AS name,
        COUNT(DISTINCT CASE WHEN p.is_regular_savings = 1 THEN p.id END) AS savings_count,
        COUNT(DISTINCT CASE WHEN p.is_a_fund = 1 THEN p.id END) AS investment_count,
        COALESCE(SUM(s.confirmed_amount), 0) / 100 AS total_deposits -- Convert from kobo to naira (100 kobo = 1 naira)
    FROM users_customuser u
    LEFT JOIN plans_plan p ON u.id = p.owner_id
    LEFT JOIN savings_savingsaccount s ON p.id = s.plan_id
    GROUP BY u.id, u.first_name, u.last_name
)

-- Final query: Return customers who have both savings and investment products
SELECT 
    cd.owner_id,
    cd.name,
    cd.savings_count,
    cd.investment_count,
    cd.total_deposits
FROM customer_deposits cd
WHERE cd.owner_id IN (SELECT owner_id FROM savings_customers)
AND cd.owner_id IN (SELECT owner_id FROM investment_customers)
ORDER BY cd.total_deposits DESC; -- Sort by highest deposit amount first