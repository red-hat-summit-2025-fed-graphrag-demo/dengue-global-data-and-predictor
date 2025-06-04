# Dengue Data API

A FastAPI service that provides access to dengue data stored in PostgreSQL.

## Features

- **REST API**: Provides endpoints for accessing and querying dengue data
- **Swagger Documentation**: Self-documenting API with Swagger UI
- **Database Integration**: Connects to PostgreSQL database using SQLAlchemy
- **Data Validation**: Uses Pydantic for data validation and serialization
- **Testing**: Includes unit tests for API endpoints

## API Endpoints

- `/`: Root endpoint with API information
- `/health`: Health check endpoint to test database connection
- `/national/stats`: Get overall statistics about the dengue data
- `/national/countries`: Get top countries by total dengue cases
- `/national/yearly`: Get yearly dengue case totals
- `/spatial/regions`: Get regional dengue case totals
- `/temporal/data`: Get temporal dengue case data for a specific country

## Local Development

### Prerequisites

- Python 3.9+
- PostgreSQL database with dengue data

### Setup

1. Install dependencies:
   ```
   pip install -r requirements.txt
   ```

2. Set environment variables:
   ```
   export DB_HOST=localhost
   export DB_PORT=5432
   export DB_NAME=sampledb
   export DB_USER=user5T0
   export DB_PASSWORD=I1A37SHxlTjB6ulf
   ```

3. Run the server:
   ```
   uvicorn main:app --reload
   ```

4. Access the API at http://localhost:8000 and the documentation at http://localhost:8000/docs

### Running Tests

To run the API tests:
```
./run_tests.sh
```

## Deployment

The API can be deployed to OpenShift using the provided Dockerfile and Kubernetes manifests:

1. Build the Docker image:
   ```
   docker build -t dengue-api .
   ```

2. Deploy to OpenShift:
   ```
   oc apply -f ../k8s/apps/api-deployment.yaml
   ```

Or use the provided deployment script:
```
cd ../scripts
./deploy_apps.sh
```

## Configuration

The API can be configured using environment variables:

- `DB_HOST`: PostgreSQL hostname (default: postgresql)
- `DB_PORT`: PostgreSQL port (default: 5432)
- `DB_NAME`: Database name (default: sampledb)
- `DB_USER`: Database username (default: user5T0)
- `DB_PASSWORD`: Database password

For more details, see the complete API documentation in `/docs/API_GUIDE.md`.