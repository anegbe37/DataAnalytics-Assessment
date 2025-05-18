This README explains my approach to each SQL query in the assessment and documents the challenges I encountered.

Query 1 Approach:
For Assessment Q1, I was to find customers with both savings and investment plans.
I broke this down into three logical steps using CTEs:
First, I isolated customers with active savings accounts by looking for confirmed deposits greater than zero. This gave me a clean list of savings customers without duplicates.
Next, I did the same for investment customers, finding those with funded investment accounts.
Then I created a comprehensive view of each customer's portfolio in the customer_deposits CTE. This shows me how many savings plans they have, how many investments, and their total deposits across all products (converted from kobo to naira for readability).
The main query then filters for only those customers who appear in both product categories and sorts them by their total deposits. This approach helps identify most valuable cross-product customers.

Query 2 Approach:
For Assessment Q2, I was to find average number of transactions per month.
I started by breaking down each customer's activity by month. This monthly view gives a more reliable picture than looking at raw transaction count, it accounts for customers who might make many transactions at a go rather than over time.
From there, I calculated each customer's average monthly transaction volume.
I then classified customers into the three segments:
High-frequency users (10+ transactions monthly)
Medium-frequency users (3-9 transactions monthly)
Low-frequency users (fewer than 3 transactions monthly)

Query 3 Approach:
For Assessment Q3, I was to find inactive accounts in over a year
I needed to find plans with no activity for over a year, considering both deposits and withdrawals. The hard part was getting the most recent activity date across different transaction types.
To solve this, I created a CTE that examines each plan and finds its latest transaction date from either savings or withdrawals (whichever came last). I also classified each plan by type (Savings or Investment).
The main query then calculates exactly how many days each plan has been inactive and filters for those inactive for over a year. The results are ordered by inactivity duration.

Query 4 Approach:
For Assessment Q4, I was to find Customer Lifetime Value (CLV) Estimation.
The formula I used annualizes the customer's transaction rate (transactions per month × 12) and multiplies it by a value factor based on their average transaction size, with a 0.1% conversion factor to represent profit margin.
I then ordered by estimated CLV in descending order.
