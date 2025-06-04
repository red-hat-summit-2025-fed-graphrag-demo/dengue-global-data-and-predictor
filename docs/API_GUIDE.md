# Dengue Data API Guide

This document provides information about the Dengue Data API endpoints and usage.

## Base URL

Within the OpenShift cluster: `http://dengue-api:8000`

## API Documentation

The API includes Swagger documentation at `/docs` and ReDoc at `/redoc`.

## Endpoints

### Root - `/`

Returns basic information about the API.

**Example Response:**
```json
{
  "status": "success",
  "data": {
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
  "message": "Welcome to the Dengue Data API"
}
```

### Health Check - `/health`

Checks if the API is running correctly and can connect to the database.

**Example Response:**
```json
{
  "status": "healthy",
  "database_connection": "ok",
  "records_count": 31032
}
```

### National Statistics - `/national/stats`

Returns overall statistics about the dengue data.

**Example Response:**
```json
{
  "status": "success",
  "data": {
    "total_records": 31032,
    "total_cases": 98765432,
    "countries_count": 124,
    "year_range": [1990, 1991, ..., 2023]
  }
}
```

### Top Countries - `/national/countries`

Returns top countries by total dengue cases.

**Parameters:**
- `limit` (optional): Number of countries to return, default is 10

**Example Request:** `/national/countries?limit=5`

**Example Response:**
```json
{
  "status": "success",
  "data": [
    {
      "country": "BRAZIL",
      "total_cases": 43977978
    },
    {
      "country": "VIET NAM",
      "total_cases": 9003800
    },
    {
      "country": "PHILIPPINES",
      "total_cases": 8756442
    },
    {
      "country": "INDONESIA",
      "total_cases": 5537722
    },
    {
      "country": "THAILAND",
      "total_cases": 5351372
    }
  ]
}
```

### Yearly Data - `/national/yearly`

Returns yearly dengue case totals, optionally filtered by country.

**Parameters:**
- `country` (optional): Country name to filter data

**Example Request:** `/national/yearly?country=BRAZIL`

**Example Response:**
```json
{
  "status": "success",
  "data": [
    {
      "year": 1990,
      "total_cases": 40279
    },
    {
      "year": 1991,
      "total_cases": 104398
    },
    ...
  ]
}
```

### Regional Data - `/spatial/regions`

Returns regional dengue case totals, optionally filtered by country and year.

**Parameters:**
- `country` (optional): Country name to filter data
- `year` (optional): Year to filter data
- `limit` (optional): Number of regions to return, default is 20

**Example Request:** `/spatial/regions?country=BRAZIL&year=2019&limit=5`

**Example Response:**
```json
{
  "status": "success",
  "data": [
    {
      "country": "BRAZIL",
      "region": "SAO PAULO",
      "total_cases": 450000
    },
    {
      "country": "BRAZIL",
      "region": "MINAS GERAIS",
      "total_cases": 298000
    },
    ...
  ]
}
```

### Temporal Data - `/temporal/data`

Returns temporal dengue case data for a specific country.

**Parameters:**
- `country` (required): Country to get temporal data for
- `start_date` (optional): Start date in ISO format (YYYY-MM-DD)
- `end_date` (optional): End date in ISO format (YYYY-MM-DD)
- `limit` (optional): Number of records to return, default is 100

**Example Request:** `/temporal/data?country=BRAZIL&start_date=2020-01-01&end_date=2020-12-31&limit=5`

**Example Response:**
```json
{
  "status": "success",
  "data": [
    {
      "country": "BRAZIL",
      "start_date": "2020-01-05",
      "end_date": "2020-01-11",
      "year": 2020,
      "dengue_cases": 12500,
      "time_resolution": "Week"
    },
    {
      "country": "BRAZIL",
      "start_date": "2020-01-12",
      "end_date": "2020-01-18",
      "year": 2020,
      "dengue_cases": 14300,
      "time_resolution": "Week"
    },
    ...
  ]
}
```

## Error Handling

API errors return a JSON response with HTTP status code 4xx or 5xx:

```json
{
  "detail": "Error message"
}
```

Common error codes:
- 400: Bad Request (invalid parameters)
- 404: Not Found
- 500: Internal Server Error

## Testing

Run API tests with:

```bash
cd api
./run_tests.sh
```