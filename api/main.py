from fastapi import FastAPI, Depends, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from sqlalchemy import func, select, and_, desc
from typing import List, Optional
from datetime import date

import database
import schemas

app = FastAPI(
    title="Dengue Data API",
    description="API for accessing dengue fever data from around the world",
    version="1.0.0"
)

# Enable CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, restrict this to specific origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/", response_model=schemas.ApiResponse)
def root():
    """Root endpoint with API information"""
    return schemas.ApiResponse(
        status="success",
        data={
            "api_name": "Dengue Data API",
            "version": "1.0.0",
            "endpoints": [
                "/national/stats",
                "/national/countries",
                "/national/yearly",
                "/spatial/regions",
                "/temporal/data",
                "/health"
            ]
        },
        message="Welcome to the Dengue Data API"
    )

@app.get("/health")
def health_check(db: Session = Depends(database.get_db)):
    """Health check endpoint that tests database connection"""
    try:
        # Simple database connection test
        result = db.execute(select(func.count()).select_from(database.national_data)).scalar()
        return {"status": "healthy", "database_connection": "ok", "records_count": result}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Database connection error: {str(e)}")

@app.get("/national/stats", response_model=schemas.ApiResponse)
def get_national_stats(db: Session = Depends(database.get_db)):
    """Get overall statistics about the dengue data"""
    try:
        # Get record count
        record_count = db.execute(select(func.count()).select_from(database.national_data)).scalar()
        
        # Get total cases
        total_cases = db.execute(
            select(func.sum(database.national_data.c.dengue_total)).select_from(database.national_data)
        ).scalar() or 0
        
        # Get unique countries count
        countries_count = db.execute(
            select(func.count(database.national_data.c.adm_0_name.distinct())).select_from(database.national_data)
        ).scalar()
        
        # Get year range
        min_year = db.execute(
            select(func.min(database.national_data.c.year)).select_from(database.national_data)
        ).scalar()
        
        max_year = db.execute(
            select(func.max(database.national_data.c.year)).select_from(database.national_data)
        ).scalar()
        
        year_range = list(range(min_year, max_year + 1)) if min_year and max_year else []
        
        stats = schemas.DengueStats(
            total_records=record_count,
            total_cases=total_cases,
            countries_count=countries_count,
            year_range=year_range
        )
        
        return schemas.ApiResponse(status="success", data=stats)
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/national/countries", response_model=schemas.ApiResponse)
def get_top_countries(
    limit: int = Query(10, description="Number of top countries to return"),
    db: Session = Depends(database.get_db)
):
    """Get top countries by total dengue cases"""
    try:
        query = select(
            database.national_data.c.adm_0_name.label("country"),
            func.sum(database.national_data.c.dengue_total).label("total_cases")
        ).select_from(
            database.national_data
        ).group_by(
            database.national_data.c.adm_0_name
        ).order_by(
            desc("total_cases")
        ).limit(limit)
        
        results = [
            schemas.CountryTotal(country=row.country, total_cases=row.total_cases)
            for row in db.execute(query).all()
        ]
        
        return schemas.ApiResponse(status="success", data=results)
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/national/yearly", response_model=schemas.ApiResponse)
def get_yearly_data(
    country: Optional[str] = None,
    db: Session = Depends(database.get_db)
):
    """Get yearly dengue case totals, optionally filtered by country"""
    try:
        query = select(
            database.national_data.c.year.label("year"),
            func.sum(database.national_data.c.dengue_total).label("total_cases")
        ).select_from(
            database.national_data
        )
        
        if country:
            query = query.where(
                func.lower(database.national_data.c.adm_0_name) == func.lower(country)
            )
        
        query = query.group_by(
            database.national_data.c.year
        ).order_by(
            database.national_data.c.year
        )
        
        results = [
            schemas.YearlyTotal(year=row.year, total_cases=row.total_cases)
            for row in db.execute(query).all()
        ]
        
        return schemas.ApiResponse(status="success", data=results)
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/spatial/regions", response_model=schemas.ApiResponse)
def get_regional_data(
    country: Optional[str] = None,
    year: Optional[int] = None,
    limit: int = Query(20, description="Number of regions to return"),
    db: Session = Depends(database.get_db)
):
    """Get regional dengue case totals, optionally filtered by country and year"""
    try:
        query = select(
            database.spatial_data.c.adm_0_name.label("country"),
            database.spatial_data.c.adm_1_name.label("region"),
            func.sum(database.spatial_data.c.dengue_total).label("total_cases")
        ).select_from(
            database.spatial_data
        ).where(
            database.spatial_data.c.adm_1_name != None  # Filter out None values
        )
        
        # Apply optional filters
        if country:
            query = query.where(
                func.lower(database.spatial_data.c.adm_0_name) == func.lower(country)
            )
        
        if year:
            query = query.where(
                database.spatial_data.c.year == year
            )
        
        query = query.group_by(
            database.spatial_data.c.adm_0_name,
            database.spatial_data.c.adm_1_name
        ).order_by(
            desc("total_cases")
        ).limit(limit)
        
        results = [
            schemas.RegionalTotal(
                country=row.country, 
                region=row.region if row.region else "Unknown", 
                total_cases=row.total_cases
            )
            for row in db.execute(query).all()
        ]
        
        return schemas.ApiResponse(status="success", data=results)
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/temporal/data", response_model=schemas.ApiResponse)
def get_temporal_data(
    country: str = Query(..., description="Country to get temporal data for"),
    start_date: Optional[date] = None,
    end_date: Optional[date] = None,
    limit: int = Query(100, description="Number of records to return"),
    db: Session = Depends(database.get_db)
):
    """Get temporal dengue case data for a specific country"""
    try:
        query = select(
            database.temporal_data.c.adm_0_name,
            database.temporal_data.c.calendar_start_date,
            database.temporal_data.c.calendar_end_date,
            database.temporal_data.c.year,
            database.temporal_data.c.dengue_total,
            database.temporal_data.c.t_res
        ).select_from(
            database.temporal_data
        ).where(
            func.lower(database.temporal_data.c.adm_0_name) == func.lower(country)
        )
        
        # Apply date filters if provided
        if start_date:
            query = query.where(
                database.temporal_data.c.calendar_start_date >= start_date
            )
        
        if end_date:
            query = query.where(
                database.temporal_data.c.calendar_end_date <= end_date
            )
        
        query = query.order_by(
            database.temporal_data.c.calendar_start_date
        ).limit(limit)
        
        results = [
            {
                "country": row.adm_0_name,
                "start_date": row.calendar_start_date.isoformat() if row.calendar_start_date else None,
                "end_date": row.calendar_end_date.isoformat() if row.calendar_end_date else None,
                "year": row.year,
                "dengue_cases": row.dengue_total,
                "time_resolution": row.t_res
            }
            for row in db.execute(query).all()
        ]
        
        return schemas.ApiResponse(status="success", data=results)
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)