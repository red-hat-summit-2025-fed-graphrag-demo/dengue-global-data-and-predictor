# Open Dengue Data

This repository contains dengue data extracted from multiple sources and tools to import it into a PostgreSQL database.

## CSV Data Files

- `National_extract_V1_2_2.csv`: National-level dengue data with 31,032 records
- `Spatial_extract_V1_2_2.csv`: Spatial dengue data with 2,476,894 records
- `Temporal_extract_V1_2_2.csv`: Temporal dengue data with 2,484,356 records

## Directory Structure

- `/docs`: Documentation files
  - `README_DB.md`: Database documentation
  - `citation.md`: Citation information for the data

- `/scripts`: Scripts for setting up and loading data
  - `load_in_openshift.sh`: Script to load data in OpenShift
  - `setup_local_db.sh`: Script to set up a local PostgreSQL database
  - `cleanup.sh`: Script to clean up OpenShift resources
  - `import_data.sh`: Script to import data into an existing database
  - `deploy_apps.sh`: Script to build and deploy API and visualizer

- `/sql`: SQL scripts for database setup and queries
  - `load_data.sql`: Schema creation script
  - `verify_data.sql`: Data verification queries
  - `/queries`: Example SQL queries

- `/k8s`: Kubernetes/OpenShift manifest files
  - `deploy-postgres.yaml`: PostgreSQL deployment
  - `data-import-job.yaml`: Data import job
  - `csv-server.yaml`: CSV file server
  - `pg-client-pod.yaml`: PostgreSQL client pod
  - `/apps`: Application deployment manifests
    - `api-deployment.yaml`: FastAPI service deployment
    - `visualizer-deployment.yaml`: Web visualizer deployment

- `/api`: FastAPI service for accessing dengue data
  - REST API endpoints for querying the database
  - Unit tests for API endpoints

- `/visualizer`: Web-based visualizer for dengue data
  - Dashboard showing global statistics
  - Country-specific visualizations
  - Interactive charts

## Getting Started

### Local Setup

#### Database Setup

1. Make sure PostgreSQL is installed and running
2. Run the local setup script:
   ```
   cd scripts
   ./setup_local_db.sh
   ```

#### API and Visualizer Development

To run both the API and visualizer locally with a simulated database:

```
cd scripts
./run_local.sh
```

This will:
1. Start a PostgreSQL container with sample data
2. Run the FastAPI service at http://localhost:8000
3. Run the visualizer at http://localhost:5000

You can then access:
- **API Documentation**: http://localhost:8000/docs
- **Web Visualizer**: http://localhost:5000

### OpenShift Setup

1. Make sure you're logged in to your OpenShift cluster
2. Create the project if it doesn't exist:
   ```
   oc new-project open-dengue-data
   ```
3. Deploy PostgreSQL:
   ```
   oc apply -f k8s/deploy-postgres.yaml
   ```
4. Upload CSV files to a volume:
   ```
   oc apply -f k8s/csv-server.yaml
   oc cp National_extract_V1_2_2.csv open-dengue-data/csv-server:/data/
   oc cp Spatial_extract_V1_2_2.csv open-dengue-data/csv-server:/data/
   oc cp Temporal_extract_V1_2_2.csv open-dengue-data/csv-server:/data/
   ```
5. Run the data import job:
   ```
   oc apply -f k8s/data-import-job.yaml
   ```

Alternatively, you can run the all-in-one script:
```
cd scripts
./load_in_openshift.sh
```

To clean up resources when done:
```
cd scripts
./cleanup.sh
```

### Deploying API and Visualizer

After you've loaded the data, you can deploy the API service and web visualizer:

```
cd scripts
./deploy_apps.sh
```

This will:
1. Build and deploy the FastAPI service for accessing dengue data
2. Build and deploy the web-based visualizer
3. Create a route to access the visualizer
4. Test the API endpoints

Once deployed, you can access:
- **API Documentation**: http://dengue-api:8000/docs (within the cluster)
- **Web Visualizer**: http://dengue-visualizer-open-dengue-data.apps.[cluster-domain]

## Documentation

For more information, see:
- [Database Structure](docs/README_DB.md) - Details about the PostgreSQL database
- [API Guide](docs/API_GUIDE.md) - FastAPI service endpoints and usage
- [Visualizer Guide](docs/VISUALIZER_GUIDE.md) - Web visualizer features and usage