-- Get dengue cases by region and year
SELECT adm_0_name, adm_1_name, year, SUM(dengue_total) as total_cases
FROM spatial_data
WHERE adm_1_name IS NOT NULL
GROUP BY adm_0_name, adm_1_name, year
ORDER BY adm_0_name, adm_1_name, year;