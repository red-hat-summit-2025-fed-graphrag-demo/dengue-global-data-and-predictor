from sqlalchemy import create_engine, Column, Integer, String, Float, Date, MetaData, Table
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
import os
from dotenv import load_dotenv

load_dotenv()

# Database connection settings
DB_HOST = os.getenv("DB_HOST", "postgresql")
DB_PORT = os.getenv("DB_PORT", "5432")
DB_NAME = os.getenv("DB_NAME", "sampledb")
DB_USER = os.getenv("DB_USER", "user5T0")
DB_PASSWORD = os.getenv("DB_PASSWORD", "I1A37SHxlTjB6ulf")

# Create SQLAlchemy engine
DATABASE_URL = f"postgresql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
engine = create_engine(DATABASE_URL)

# Create session factory bound to engine
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Create Base class for declarative models
Base = declarative_base()

# Database dependency
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# Define tables that match existing PostgreSQL tables
metadata = MetaData()

# National data table
national_data = Table(
    'national_data', 
    metadata,
    Column('id', Integer, primary_key=True),
    Column('adm_0_name', String(255)),
    Column('adm_1_name', String(255)),
    Column('adm_2_name', String(255)),
    Column('full_name', String(255)),
    Column('iso_a0', String(10)),
    Column('fao_gaul_code', Integer),
    Column('rne_iso_code', String(10)),
    Column('ibge_code', String(255)),
    Column('calendar_start_date', Date),
    Column('calendar_end_date', Date),
    Column('year', Integer),
    Column('dengue_total', Float),
    Column('case_definition_standardised', String(50)),
    Column('s_res', String(50)),
    Column('t_res', String(50)),
    Column('uuid', String(100))
)

# Spatial data table
spatial_data = Table(
    'spatial_data', 
    metadata,
    Column('id', Integer, primary_key=True),
    Column('adm_0_name', String(255)),
    Column('adm_1_name', String(255)),
    Column('adm_2_name', String(255)),
    Column('full_name', String(255)),
    Column('iso_a0', String(10)),
    Column('fao_gaul_code', Integer),
    Column('rne_iso_code', String(10)),
    Column('ibge_code', String(255)),
    Column('calendar_start_date', Date),
    Column('calendar_end_date', Date),
    Column('year', Integer),
    Column('dengue_total', Float),
    Column('case_definition_standardised', String(50)),
    Column('s_res', String(50)),
    Column('t_res', String(50)),
    Column('uuid', String(100))
)

# Temporal data table
temporal_data = Table(
    'temporal_data', 
    metadata,
    Column('id', Integer, primary_key=True),
    Column('adm_0_name', String(255)),
    Column('adm_1_name', String(255)),
    Column('adm_2_name', String(255)),
    Column('full_name', String(255)),
    Column('iso_a0', String(10)),
    Column('fao_gaul_code', Integer),
    Column('rne_iso_code', String(10)),
    Column('ibge_code', String(255)),
    Column('calendar_start_date', Date),
    Column('calendar_end_date', Date),
    Column('year', Integer),
    Column('dengue_total', Float),
    Column('case_definition_standardised', String(50)),
    Column('s_res', String(50)),
    Column('t_res', String(50)),
    Column('uuid', String(100))
)