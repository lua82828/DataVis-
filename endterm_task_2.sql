WITH monthly_stats AS (
    SELECT 
        DATE_FORMAT(date_new, '%Y-%m') AS month,  -- Grouping by month
        COUNT(DISTINCT Id_check) AS total_transactions,  -- Number of transactions
        SUM(Sum_payment) AS total_amount,  -- Total amount spent
        COUNT(DISTINCT ID_client) AS total_clients,  -- Number of unique clients per month
        AVG(Sum_payment) AS avg_check,  -- Average check per transaction
        AVG(Count_products) AS avg_products_per_transaction  -- Average products per transaction
    FROM `endterm`.`transactions_info`
    WHERE date_new BETWEEN '2015-06-01' AND '2016-06-01'
    GROUP BY month
),
gender_stats AS (
    SELECT 
        DATE_FORMAT(t.date_new, '%Y-%m') AS month,
        c.Gender,
        COUNT(DISTINCT t.Id_check) AS transaction_count,
        SUM(t.Sum_payment) AS total_spent
    FROM `endterm`.`transactions_info` t
    JOIN `endterm`.`customer_info.xlsx - query_for_abt_customerinfo_0002` c ON t.ID_client = c.Id_client
    WHERE t.date_new BETWEEN '2015-06-01' AND '2016-06-01'
    GROUP BY month, c.Gender
),
yearly_totals AS (
    SELECT 
        SUM(Sum_payment) AS total_amount_year,  -- Total amount spent for the year
        COUNT(DISTINCT Id_check) AS total_transactions_year  -- Total transactions for the year
    FROM `endterm`.`transactions_info`
    WHERE date_new BETWEEN '2015-06-01' AND '2016-06-01'
)
SELECT 
    ms.month,
    ms.avg_check,
    ms.avg_products_per_transaction,
    ms.total_transactions,
    ms.total_clients,
    (ms.total_amount / yt.total_amount_year) * 100 AS share_of_total_amount,  -- Percentage share of the total amount for each month
    (ms.total_transactions / yt.total_transactions_year) * 100 AS share_of_total_transactions,  -- Percentage share of total transactions for each month
    -- Gender distribution and percentage share of amount per gender
    SUM(CASE WHEN gs.Gender = 'M' THEN gs.transaction_count ELSE 0 END) AS male_transactions,
    SUM(CASE WHEN gs.Gender = 'M' THEN gs.total_spent ELSE 0 END) AS male_spending,
    SUM(CASE WHEN gs.Gender = 'F' THEN gs.transaction_count ELSE 0 END) AS female_transactions,
    SUM(CASE WHEN gs.Gender = 'F' THEN gs.total_spent ELSE 0 END) AS female_spending,
    SUM(CASE WHEN gs.Gender IS NULL THEN gs.transaction_count ELSE 0 END) AS NA_transactions,
    SUM(CASE WHEN gs.Gender IS NULL THEN gs.total_spent ELSE 0 END) AS NA_spending,
    -- Percentage breakdown of spending for each gender
    SUM(CASE WHEN gs.Gender = 'M' THEN gs.total_spent ELSE 0 END) / ms.total_amount * 100 AS male_percentage_of_spending,
    SUM(CASE WHEN gs.Gender = 'F' THEN gs.total_spent ELSE 0 END) / ms.total_amount * 100 AS female_percentage_of_spending,
    SUM(CASE WHEN gs.Gender IS NULL THEN gs.total_spent ELSE 0 END) / ms.total_amount * 100 AS NA_percentage_of_spending
FROM monthly_stats ms
LEFT JOIN gender_stats gs ON ms.month = gs.month
JOIN yearly_totals yt  -- Join yearly totals in this part of the query
GROUP BY ms.month, yt.total_amount_year, yt.total_transactions_year
ORDER BY ms.month;

