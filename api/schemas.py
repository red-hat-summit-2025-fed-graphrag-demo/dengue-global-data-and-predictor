from pydantic import BaseModel
from typing import Optional, List, Dict, Any
from datetime import date

class DengueDataBase(BaseModel):
    adm_0_name: Optional[str] = None
    adm_1_name: Optional[str] = None
    adm_2_name: Optional[str] = None
    full_name: Optional[str] = None
    iso_a0: Optional[str] = None
    fao_gaul_code: Optional[int] = None
    rne_iso_code: Optional[str] = None
    ibge_code: Optional[str] = None
    calendar_start_date: Optional[date] = None
    calendar_end_date: Optional[date] = None
    year: Optional[int] = None
    dengue_total: Optional[float] = None
    case_definition_standardised: Optional[str] = None
    s_res: Optional[str] = None
    t_res: Optional[str] = None
    uuid: Optional[str] = None

class DengueData(DengueDataBase):
    id: int

    class Config:
        orm_mode = True

class CountryTotal(BaseModel):
    country: str
    total_cases: float

class YearlyTotal(BaseModel):
    year: int
    total_cases: float

class RegionalTotal(BaseModel):
    country: str
    region: str
    total_cases: float

class DengueStats(BaseModel):
    total_records: int
    total_cases: float
    countries_count: int
    year_range: List[int]

class FilterParams(BaseModel):
    country: Optional[str] = None
    region: Optional[str] = None
    year: Optional[int] = None
    start_date: Optional[date] = None
    end_date: Optional[date] = None

class ApiResponse(BaseModel):
    status: str
    data: Any
    message: Optional[str] = None