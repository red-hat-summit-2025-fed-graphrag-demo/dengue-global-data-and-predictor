-- Get counts by dataset
SELECT 'national_data' as table_name, COUNT(*) as row_count FROM national_data
UNION ALL
SELECT 'spatial_data' as table_name, COUNT(*) as row_count FROM spatial_data
UNION ALL
SELECT 'temporal_data' as table_name, COUNT(*) as row_count FROM temporal_data;

-- Sample data from each table
SELECT * FROM national_data LIMIT 5;
SELECT * FROM spatial_data LIMIT 5;
SELECT * FROM temporal_data LIMIT 5;

-- Check distinct countries by dengue cases
SELECT adm_0_name, SUM(dengue_total) as total_cases
FROM national_data 
GROUP BY adm_0_name
ORDER BY total_cases DESC
LIMIT 10;

-- View data from unique views
SELECT COUNT(*) FROM national_data_unique;
SELECT COUNT(*) FROM spatial_data_unique;
SELECT COUNT(*) FROM temporal_data_unique;