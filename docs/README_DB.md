# Open Dengue Data PostgreSQL Database

## Database Structure

We have created three PostgreSQL tables to store the dengue data:

1. **national_data**: Contains national-level dengue data with 31,032 records
2. **spatial_data**: Contains spatial dengue data with 2,476,894 records  
3. **temporal_data**: Contains temporal dengue data with 2,484,356 records

### Table Schema

All tables share the following schema:

```sql
CREATE TABLE IF NOT EXISTS [table_name] (
    id SERIAL PRIMARY KEY,
    adm_0_name VARCHAR(255),
    adm_1_name VARCHAR(255),
    adm_2_name VARCHAR(255),
    full_name VARCHAR(255),
    iso_a0 VARCHAR(10),
    fao_gaul_code BIGINT,
    rne_iso_code VARCHAR(10),
    ibge_code VARCHAR(255),
    calendar_start_date DATE,
    calendar_end_date DATE,
    year INT,
    dengue_total FLOAT,
    case_definition_standardised VARCHAR(50),
    s_res VARCHAR(50),
    t_res VARCHAR(50),
    uuid VARCHAR(100)
);
```

### Indexes

We created the following indexes to improve query performance:

```sql
-- National data indexes
CREATE INDEX national_data_iso_year_idx ON national_data(iso_a0, year);
CREATE INDEX national_data_date_range_idx ON national_data(calendar_start_date, calendar_end_date);

-- Spatial data indexes
CREATE INDEX spatial_data_iso_year_idx ON spatial_data(iso_a0, year);
CREATE INDEX spatial_data_date_range_idx ON spatial_data(calendar_start_date, calendar_end_date);
CREATE INDEX spatial_data_location_idx ON spatial_data(adm_0_name, adm_1_name, adm_2_name);

-- Temporal data indexes
CREATE INDEX temporal_data_iso_year_idx ON temporal_data(iso_a0, year);
CREATE INDEX temporal_data_date_range_idx ON temporal_data(calendar_start_date, calendar_end_date);
CREATE INDEX temporal_data_t_res_idx ON temporal_data(t_res);
```

### Views

We also created the following views to handle duplicate data:

```sql
-- National data unique view
CREATE OR REPLACE VIEW national_data_unique AS
SELECT DISTINCT ON (iso_a0, calendar_start_date, calendar_end_date) *
FROM national_data
ORDER BY iso_a0, calendar_start_date, calendar_end_date, id DESC;

-- Spatial data unique view
CREATE OR REPLACE VIEW spatial_data_unique AS
SELECT DISTINCT ON (iso_a0, adm_1_name, adm_2_name, calendar_start_date, calendar_end_date) *
FROM spatial_data
ORDER BY iso_a0, adm_1_name, adm_2_name, calendar_start_date, calendar_end_date, id DESC;
    
-- Temporal data unique view
CREATE OR REPLACE VIEW temporal_data_unique AS
SELECT DISTINCT ON (iso_a0, calendar_start_date, calendar_end_date, t_res) *
FROM temporal_data
ORDER BY iso_a0, calendar_start_date, calendar_end_date, t_res, id DESC;
```

## Sample Queries

### Get counts by dataset

```sql
SELECT 'national_data' as table_name, COUNT(*) as row_count FROM national_data
UNION ALL
SELECT 'spatial_data' as table_name, COUNT(*) as row_count FROM spatial_data
UNION ALL
SELECT 'temporal_data' as table_name, COUNT(*) as row_count FROM temporal_data;
```

### Get top 10 countries by dengue cases

```sql
SELECT adm_0_name, SUM(dengue_total) as total_cases
FROM national_data 
GROUP BY adm_0_name
ORDER BY total_cases DESC
LIMIT 10;
```

Result:
```
 adm_0_name  | total_cases 
-------------+-------------
 BRAZIL      |    43977978
 VIET M      |     9003800
 PHILIPPINES |     8756442
 INDONESIA   |     5537722
 THAILAND    |     5351372
 MEXICO      |     4912724
 MALAYSIA    |     4371622
 INDIA       |     2679462
 VENEZUELA   |     2547106
 COLOMBIA    |     2405368
```

### Get dengue cases by year

```sql
SELECT year, SUM(dengue_total) as total_cases
FROM national_data
GROUP BY year
ORDER BY year;
```

### Get dengue cases by region and year

```sql
SELECT adm_0_name, year, SUM(dengue_total) as total_cases
FROM spatial_data
WHERE adm_1_name IS NOT NULL
GROUP BY adm_0_name, year
ORDER BY adm_0_name, year;
```

## Connection Information

The database is available within the OpenShift cluster:

- **Host**: postgresql.open-dengue-data.svc
- **Port**: 5432
- **Database**: sampledb
- **Username**: user5T0
- **Password**: I1A37SHxlTjB6ulf