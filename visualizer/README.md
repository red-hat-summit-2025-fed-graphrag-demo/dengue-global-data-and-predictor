# Dengue Data Visualizer

A web-based visualization application for dengue data, built with Flask and Chart.js.

## Features

- **Dashboard**: Overview of global dengue statistics
- **Country Details**: Detailed view of dengue data for specific countries
- **Interactive Charts**: Visualizations of dengue case trends over time
- **API Integration**: Consumes data from the Dengue Data API
- **Responsive Design**: Works on desktop and mobile devices

## Screenshots

(Screenshots would be added here once the application is deployed)

## Local Development

### Prerequisites

- Python 3.9+
- Dengue Data API service running (either locally or in OpenShift)

### Setup

1. Install dependencies:
   ```
   pip install -r requirements.txt
   ```

2. Set environment variables:
   ```
   export API_HOST=localhost  # or the API service address
   export API_PORT=8000       # or the API service port
   ```

3. Run the server:
   ```
   python app.py
   ```

4. Access the visualizer at http://localhost:5000

## Deployment

The visualizer can be deployed to OpenShift using the provided Dockerfile and Kubernetes manifests:

1. Build the Docker image:
   ```
   docker build -t dengue-visualizer .
   ```

2. Deploy to OpenShift:
   ```
   oc apply -f ../k8s/apps/visualizer-deployment.yaml
   ```

Or use the provided deployment script:
```
cd ../scripts
./deploy_apps.sh
```

## Configuration

The visualizer can be configured using environment variables:

- `API_HOST`: Hostname of the Dengue Data API service (default: dengue-api)
- `API_PORT`: Port of the Dengue Data API service (default: 8000)

## Pages

- **Dashboard** (`/`): Global statistics and top countries
- **Country Details** (`/country/<country_name>`): Detailed view for a specific country
- **Health Check** (`/health`): Service health check endpoint
- **API Proxy** (`/api/proxy/<endpoint>`): Proxy to the backend API

For more details, see the complete documentation in `/docs/VISUALIZER_GUIDE.md`.