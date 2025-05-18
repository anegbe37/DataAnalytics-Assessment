WITH customer_monthly_transactions AS (
    -- Calculate transaction count for each customer per month
    SELECT 
        u.id AS owner_id,
        DATE_FORMAT(s.transaction_date, '%Y-%m-01') AS month, -- Group by first day of month
        COUNT(*) AS transaction_count
    FROM users_customuser u
    JOIN savings_savingsaccount s ON u.id = s.owner_id
    GROUP BY u.id, DATE_FORMAT(s.transaction_date, '%Y-%m-01')
),
customer_avg_transactions AS (
    -- Calculate average monthly transactions for each customer
    SELECT 
        owner_id,
        AVG(transaction_count) AS avg_transactions_per_month
    FROM customer_monthly_transactions
    GROUP BY owner_id
),
frequency_categories AS (
    -- Categorize customers by transaction frequency:
    -- High: 10+ transactions per month
    -- Medium: 3-9 transactions per month
    -- Low: Less than 3 transactions per month
    SELECT 
        CASE 
            WHEN avg_transactions_per_month >= 10 THEN 'High Frequency'
            WHEN avg_transactions_per_month >= 3 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS frequency_category,
        COUNT(*) AS customer_count, -- Count customers in each category
        ROUND(AVG(avg_transactions_per_month), 1) AS avg_transactions_per_month -- Average transactions for the category
    FROM customer_avg_transactions
    GROUP BY frequency_category
)

-- Final query: Return the frequency category statistics
SELECT *
FROM frequency_categories
ORDER BY 
    CASE frequency_category -- Order categories from high to low
        WHEN 'High Frequency' THEN 1
        WHEN 'Medium Frequency' THEN 2
        ELSE 3
    END;