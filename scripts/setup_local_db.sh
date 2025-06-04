#!/bin/bash
# This script sets up a local PostgreSQL database and imports the dengue data

# Set PostgreSQL connection parameters
DB_HOST="localhost"
DB_PORT="5432"
DB_NAME="denguedb"
DB_USER="postgres"
DB_PASSWORD="postgres"

# Create database if it doesn't exist
echo "Creating database if it doesn't exist..."
psql -h $DB_HOST -p $DB_PORT -U $DB_USER -c "CREATE DATABASE $DB_NAME;" || true

# Create schema and import data
echo "Creating schema and importing data..."
psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f ../sql/load_data.sql

# Process CSV files to handle nulls
echo "Processing CSV files..."
sed 's/NA//g' ../National_extract_V1_2_2.csv > /tmp/national_data.csv
sed 's/NA//g' ../Spatial_extract_V1_2_2.csv > /tmp/spatial_data.csv
sed 's/NA//g' ../Temporal_extract_V1_2_2.csv > /tmp/temporal_data.csv

# Import data
echo "Importing National data..."
psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "\COPY national_data(adm_0_name, adm_1_name, adm_2_name, full_name, iso_a0, fao_gaul_code, rne_iso_code, ibge_code, calendar_start_date, calendar_end_date, year, dengue_total, case_definition_standardised, s_res, t_res, uuid) FROM '/tmp/national_data.csv' CSV HEADER"

echo "Importing Spatial data..."
psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "\COPY spatial_data(adm_0_name, adm_1_name, adm_2_name, full_name, iso_a0, fao_gaul_code, rne_iso_code, ibge_code, calendar_start_date, calendar_end_date, year, dengue_total, case_definition_standardised, s_res, t_res, uuid) FROM '/tmp/spatial_data.csv' CSV HEADER"

echo "Importing Temporal data..."
psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "\COPY temporal_data(adm_0_name, adm_1_name, adm_2_name, full_name, iso_a0, fao_gaul_code, rne_iso_code, ibge_code, calendar_start_date, calendar_end_date, year, dengue_total, case_definition_standardised, s_res, t_res, uuid) FROM '/tmp/temporal_data.csv' CSV HEADER"

# Verify data loaded successfully
echo "Verifying data loaded successfully..."
psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "
  SELECT 'national_data' as table_name, COUNT(*) as row_count FROM national_data
  UNION ALL
  SELECT 'spatial_data' as table_name, COUNT(*) as row_count FROM spatial_data
  UNION ALL
  SELECT 'temporal_data' as table_name, COUNT(*) as row_count FROM temporal_data;"

echo "Data import complete!"