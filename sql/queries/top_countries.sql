-- Get top 10 countries by dengue cases
SELECT adm_0_name, SUM(dengue_total) as total_cases
FROM national_data 
GROUP BY adm_0_name
ORDER BY total_cases DESC
LIMIT 10;