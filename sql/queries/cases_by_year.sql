-- Get dengue cases by year
SELECT year, SUM(dengue_total) as total_cases
FROM national_data
GROUP BY year
ORDER BY year;