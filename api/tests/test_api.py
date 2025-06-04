import pytest
from fastapi.testclient import TestClient
from main import app
import json
from unittest import mock

# Create test client
client = TestClient(app)

# Mock the database dependency to avoid actual DB connections
@pytest.fixture(autouse=True)
def mock_db_dependency():
    with mock.patch("main.database.get_db") as _fixture:
        yield _fixture

def test_root_endpoint():
    """Test the root endpoint returns correct information"""
    response = client.get("/")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "success"
    assert "api_name" in data["data"]
    assert "endpoints" in data["data"]

def test_health_endpoint(mock_db_dependency):
    """Test the health endpoint with mocked database"""
    # Mock the database query execution
    mock_db = mock.MagicMock()
    mock_db_dependency.return_value.__next__.return_value = mock_db
    mock_db.execute().scalar.return_value = 100
    
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "healthy"
    assert data["database_connection"] == "ok"
    assert data["records_count"] == 100

def test_national_stats_endpoint(mock_db_dependency):
    """Test the national stats endpoint with mocked database"""
    # Mock the database query executions
    mock_db = mock.MagicMock()
    mock_db_dependency.return_value.__next__.return_value = mock_db
    
    # Set up return values for different queries
    mock_execute = mock_db.execute
    mock_execute.return_value.scalar.side_effect = [10000, 1000000, 50, 1990, 2023]
    
    response = client.get("/national/stats")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "success"
    assert data["data"]["total_records"] == 10000
    assert data["data"]["total_cases"] == 1000000
    assert data["data"]["countries_count"] == 50
    assert len(data["data"]["year_range"]) == 34  # 2023-1990+1

def test_national_countries_endpoint(mock_db_dependency):
    """Test the national countries endpoint with mocked database"""
    # Mock data for countries
    mock_countries = [
        mock.MagicMock(country="Brazil", total_cases=1000000),
        mock.MagicMock(country="Thailand", total_cases=500000),
        mock.MagicMock(country="Mexico", total_cases=300000),
    ]
    
    # Mock the database query
    mock_db = mock.MagicMock()
    mock_db_dependency.return_value.__next__.return_value = mock_db
    mock_db.execute.return_value.all.return_value = mock_countries
    
    response = client.get("/national/countries?limit=3")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "success"
    assert len(data["data"]) == 3
    assert data["data"][0]["country"] == "Brazil"
    assert data["data"][0]["total_cases"] == 1000000

def test_national_yearly_endpoint(mock_db_dependency):
    """Test the national yearly endpoint with mocked database"""
    # Mock data for yearly totals
    mock_yearly = [
        mock.MagicMock(year=2020, total_cases=100000),
        mock.MagicMock(year=2021, total_cases=150000),
        mock.MagicMock(year=2022, total_cases=120000),
    ]
    
    # Mock the database query
    mock_db = mock.MagicMock()
    mock_db_dependency.return_value.__next__.return_value = mock_db
    mock_db.execute.return_value.all.return_value = mock_yearly
    
    response = client.get("/national/yearly")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "success"
    assert len(data["data"]) == 3
    assert data["data"][0]["year"] == 2020
    assert data["data"][1]["year"] == 2021
    assert data["data"][2]["year"] == 2022

def test_spatial_regions_endpoint(mock_db_dependency):
    """Test the spatial regions endpoint with mocked database"""
    # Mock data for regions
    mock_regions = [
        mock.MagicMock(country="Brazil", region="Sao Paulo", total_cases=500000),
        mock.MagicMock(country="Brazil", region="Rio de Janeiro", total_cases=300000),
    ]
    
    # Mock the database query
    mock_db = mock.MagicMock()
    mock_db_dependency.return_value.__next__.return_value = mock_db
    mock_db.execute.return_value.all.return_value = mock_regions
    
    response = client.get("/spatial/regions?country=Brazil&limit=2")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "success"
    assert len(data["data"]) == 2
    assert data["data"][0]["country"] == "Brazil"
    assert data["data"][0]["region"] == "Sao Paulo"
    assert data["data"][1]["region"] == "Rio de Janeiro"

def test_temporal_data_endpoint(mock_db_dependency):
    """Test the temporal data endpoint with mocked database"""
    # Create a mock row with the necessary attributes
    class MockRow:
        def __init__(self, **kwargs):
            for key, value in kwargs.items():
                setattr(self, key, value)
    
    # Mock data for temporal data
    from datetime import date
    mock_temporal = [
        MockRow(
            adm_0_name="Brazil",
            calendar_start_date=date(2022, 1, 1),
            calendar_end_date=date(2022, 1, 7),
            year=2022,
            dengue_total=5000,
            t_res="Week"
        ),
        MockRow(
            adm_0_name="Brazil",
            calendar_start_date=date(2022, 1, 8),
            calendar_end_date=date(2022, 1, 14),
            year=2022,
            dengue_total=6000,
            t_res="Week"
        ),
    ]
    
    # Mock the database query
    mock_db = mock.MagicMock()
    mock_db_dependency.return_value.__next__.return_value = mock_db
    mock_db.execute.return_value.all.return_value = mock_temporal
    
    response = client.get("/temporal/data?country=Brazil&limit=2")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "success"
    assert len(data["data"]) == 2
    assert data["data"][0]["country"] == "Brazil"
    assert data["data"][0]["year"] == 2022
    assert data["data"][0]["dengue_cases"] == 5000