-- Create tables
CREATE TABLE IF NOT EXISTS national_data (
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

CREATE TABLE IF NOT EXISTS spatial_data (
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

CREATE TABLE IF NOT EXISTS temporal_data (
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

-- Create indexes
CREATE INDEX IF NOT EXISTS national_data_iso_year_idx ON national_data(iso_a0, year);
CREATE INDEX IF NOT EXISTS national_data_date_range_idx ON national_data(calendar_start_date, calendar_end_date);

CREATE INDEX IF NOT EXISTS spatial_data_iso_year_idx ON spatial_data(iso_a0, year);
CREATE INDEX IF NOT EXISTS spatial_data_date_range_idx ON spatial_data(calendar_start_date, calendar_end_date);
CREATE INDEX IF NOT EXISTS spatial_data_location_idx ON spatial_data(adm_0_name, adm_1_name, adm_2_name);

CREATE INDEX IF NOT EXISTS temporal_data_iso_year_idx ON temporal_data(iso_a0, year);
CREATE INDEX IF NOT EXISTS temporal_data_date_range_idx ON temporal_data(calendar_start_date, calendar_end_date);
CREATE INDEX IF NOT EXISTS temporal_data_t_res_idx ON temporal_data(t_res);

-- Create convenient views for distinct data access
CREATE OR REPLACE VIEW national_data_unique AS
SELECT DISTINCT ON (iso_a0, calendar_start_date, calendar_end_date) *
FROM national_data
ORDER BY iso_a0, calendar_start_date, calendar_end_date, id DESC;

CREATE OR REPLACE VIEW spatial_data_unique AS
SELECT DISTINCT ON (iso_a0, adm_1_name, adm_2_name, calendar_start_date, calendar_end_date) *
FROM spatial_data
ORDER BY iso_a0, adm_1_name, adm_2_name, calendar_start_date, calendar_end_date, id DESC;
    
CREATE OR REPLACE VIEW temporal_data_unique AS
SELECT DISTINCT ON (iso_a0, calendar_start_date, calendar_end_date, t_res) *
FROM temporal_data
ORDER BY iso_a0, calendar_start_date, calendar_end_date, t_res, id DESC;