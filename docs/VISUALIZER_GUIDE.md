# Dengue Data Visualizer Guide

This document provides information about the Dengue Data Visualizer web application.

## Access

The visualizer is accessible through an OpenShift route at:

```
http://dengue-visualizer-open-dengue-data.apps.[cluster-domain]
```

## Features

### Dashboard

The main dashboard provides an overview of dengue data globally:

- **Key Statistics**: Total records, total cases, countries count, and year range
- **Yearly Trend**: Chart showing global dengue cases by year
- **Top Countries**: Table listing the top countries by total dengue cases

### Country Detail View

Clicking on a country name takes you to a detailed view for that country:

- **Country Statistics**: Yearly chart showing cases over time for the selected country
- **Regional Breakdown**: Table showing cases by region within the country
- **Temporal Chart**: Detailed time-series chart showing dengue cases for the selected country
- **Recent Data**: Table showing the most recent data points for the country

## Implementation Details

The visualizer is a Flask web application that:

1. Communicates with the Dengue Data API to fetch data
2. Renders interactive charts using Chart.js
3. Provides a responsive, user-friendly interface using Bootstrap 5

## Technical Architecture

- **Frontend**: HTML/CSS/JavaScript with Chart.js for visualizations
- **Backend**: Flask (Python) serving as a thin presentation layer
- **Data Source**: Dengue Data API (FastAPI service)
- **Deployment**: Container deployed on OpenShift

## Development

To run the visualizer locally for development:

1. Install requirements:
   ```
   cd visualizer
   pip install -r requirements.txt
   ```

2. Set environment variables:
   ```
   export API_HOST=localhost
   export API_PORT=8000
   ```

3. Run the development server:
   ```
   python app.py
   ```

4. Access the visualizer at http://localhost:5000

## Troubleshooting

If the visualizer shows an error connecting to the API:

1. Check that the API service is running:
   ```
   oc get pods -l app=dengue-api
   ```

2. Verify the API is accessible:
   ```
   oc exec [visualizer-pod] -- curl -s http://dengue-api:8000/health
   ```

3. Check visualizer logs:
   ```
   oc logs [visualizer-pod]
   ```