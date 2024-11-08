LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/transactions_info.xlsx - TRANSACTIONS (1).csv'
INTO TABLE endterm.`transactions_info`
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@date_new, Id_check, ID_client, Count_products, Sum_payment)  -- Temporarily load the date as a string
SET date_new = STR_TO_DATE(@date_new, '%d/%m/%Y');  -- Convert to the correct date format

WITH monthly_transactions AS (
    SELECT 
        ID_client, 
        DATE_FORMAT(date_new, '%Y-%m') AS month,
        COUNT(DISTINCT Id_check) AS transaction_count,
        AVG(Sum_payment) AS avg_check
    FROM `endterm`.`transactions_info`
    WHERE date_new BETWEEN '2015-06-01' AND '2016-06-01'
    GROUP BY ID_client, month
),
continuous_customers AS (
    SELECT 
        ID_client
    FROM monthly_transactions
    GROUP BY ID_client
    HAVING COUNT(month) = 12  -- Clients who have transactions in every month
)

SELECT 
    c.Id_client,
    SUM(t.Sum_payment) / COUNT(DISTINCT t.Id_check) AS avg_check,  -- Average check
    SUM(t.Sum_payment) / 12 AS avg_monthly_amount,  -- Average amount spent per month
    COUNT(t.Id_check) AS total_transactions  -- Total transactions
FROM continuous_customers cc
JOIN `endterm`.`transactions_info` t ON cc.ID_client = t.ID_client
JOIN `endterm`.`customer_info.xlsx - query_for_abt_customerinfo_0002` c ON cc.ID_client = c.Id_client
WHERE t.date_new BETWEEN '2015-06-01' AND '2016-06-01'
GROUP BY c.Id_client;






    
