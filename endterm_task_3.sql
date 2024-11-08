WITH age_groups AS (
    -- Create age groups with a 10-year step
    SELECT 
        CASE
            WHEN Age IS NULL THEN 'Unknown'
            WHEN Age BETWEEN 0 AND 9 THEN '0-9'
            WHEN Age BETWEEN 10 AND 19 THEN '10-19'
            WHEN Age BETWEEN 20 AND 29 THEN '20-29'
            WHEN Age BETWEEN 30 AND 39 THEN '30-39'
            WHEN Age BETWEEN 40 AND 49 THEN '40-49'
            WHEN Age BETWEEN 50 AND 59 THEN '50-59'
            WHEN Age BETWEEN 60 AND 69 THEN '60-69'
            WHEN Age BETWEEN 70 AND 79 THEN '70-79'
            WHEN Age BETWEEN 80 AND 89 THEN '80-89'
            ELSE '90+'  -- Handle age 90 and above
        END AS age_group,
        c.Id_client,
        c.Age
    FROM `endterm`.`customer_info.xlsx - query_for_abt_customerinfo_0002` c
),
quarterly_transactions AS (
    -- Get quarterly statistics for each client and age group
    SELECT 
        ag.age_group,
        DATE_FORMAT(t.date_new, '%Y-Q%q') AS quarter,  -- Create quarter column
        COUNT(DISTINCT t.Id_check) AS total_transactions,
        SUM(t.Sum_payment) AS total_spent
    FROM `endterm`.`transactions_info` t
    JOIN age_groups ag ON t.ID_client = ag.Id_client
    WHERE t.date_new BETWEEN '2015-06-01' AND '2016-06-01'
    GROUP BY ag.age_group, quarter
),
total_yearly_data AS (
    -- Get yearly totals for each age group
    SELECT 
        ag.age_group,
        COUNT(DISTINCT t.Id_check) AS total_transactions_year,
        SUM(t.Sum_payment) AS total_spent_year
    FROM `endterm`.`transactions_info` t
    JOIN age_groups ag ON t.ID_client = ag.Id_client
    WHERE t.date_new BETWEEN '2015-06-01' AND '2016-06-01'
    GROUP BY ag.age_group
)
SELECT 
    q.age_group,
    q.quarter,
    q.total_transactions,
    q.total_spent,
    (q.total_transactions / ty.total_transactions_year) * 100 AS transactions_percentage,
    (q.total_spent / ty.total_spent_year) * 100 AS spending_percentage,
    ty.total_transactions_year,
    ty.total_spent_year
FROM quarterly_transactions q
JOIN total_yearly_data ty ON q.age_group = ty.age_group
ORDER BY q.age_group, q.quarter;
