#!/bin/bash
set -e

# Connection parameters
DB_HOST=${DB_HOST:-postgresql}
DB_PORT=${DB_PORT:-5432}
DB_NAME=${DB_NAME:-sampledb}
DB_USER=${DB_USER:-user5T0}
DB_PASSWORD=${DB_PASSWORD:-I1A37SHxlTjB6ulf}

echo "Starting data import process..."

# Create database schema
echo "Creating database schema..."
PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f load_data.sql

# Process CSV files to handle nulls
echo "Processing CSV files..."
sed 's/NA//g' National_extract_V1_2_2.csv > /tmp/national_data.csv
sed 's/NA//g' Spatial_extract_V1_2_2.csv > /tmp/spatial_data.csv
sed 's/NA//g' Temporal_extract_V1_2_2.csv > /tmp/temporal_data.csv

# Import data in chunks to avoid disk space issues
echo "Importing National data..."
PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "\COPY national_data(adm_0_name, adm_1_name, adm_2_name, full_name, iso_a0, fao_gaul_code, rne_iso_code, ibge_code, calendar_start_date, calendar_end_date, year, dengue_total, case_definition_standardised, s_res, t_res, uuid) FROM '/tmp/national_data.csv' CSV HEADER"

echo "Importing Spatial data..."
PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "\COPY spatial_data(adm_0_name, adm_1_name, adm_2_name, full_name, iso_a0, fao_gaul_code, rne_iso_code, ibge_code, calendar_start_date, calendar_end_date, year, dengue_total, case_definition_standardised, s_res, t_res, uuid) FROM '/tmp/spatial_data.csv' CSV HEADER"

echo "Importing Temporal data..."
PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "\COPY temporal_data(adm_0_name, adm_1_name, adm_2_name, full_name, iso_a0, fao_gaul_code, rne_iso_code, ibge_code, calendar_start_date, calendar_end_date, year, dengue_total, case_definition_standardised, s_res, t_res, uuid) FROM '/tmp/temporal_data.csv' CSV HEADER"

# Verify data loaded successfully
echo "Verifying data loaded successfully..."
PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "
  SELECT 'national_data' as table_name, COUNT(*) as row_count FROM national_data
  UNION ALL
  SELECT 'spatial_data' as table_name, COUNT(*) as row_count FROM spatial_data
  UNION ALL
  SELECT 'temporal_data' as table_name, COUNT(*) as row_count FROM temporal_data;"

echo "Data import complete!"