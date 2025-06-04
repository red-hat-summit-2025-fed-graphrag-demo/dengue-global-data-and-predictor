#!/bin/bash
# Script to build and deploy the API and visualizer applications to OpenShift

set -e

# Check if logged in to OpenShift
if ! oc whoami &> /dev/null; then
    echo "Error: You must be logged in to OpenShift."
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
PROJECT_NAME="open-dengue-data"

# Check if project exists
if ! oc get project "$PROJECT_NAME" &> /dev/null; then
    echo "Creating project $PROJECT_NAME..."
    oc new-project "$PROJECT_NAME"
fi

# Set current project
oc project "$PROJECT_NAME"

# Ensure PostgreSQL is running
if ! oc get deployment postgresql &> /dev/null && ! oc get dc postgresql &> /dev/null; then
    echo "PostgreSQL is not deployed. Deploying now..."
    oc apply -f "$ROOT_DIR/k8s/deploy-postgres.yaml"
    
    # Wait for PostgreSQL to be ready
    echo "Waiting for PostgreSQL to be ready..."
    oc rollout status deployment/postgresql || oc rollout status dc/postgresql
fi

echo "Building and deploying API..."
cd "$ROOT_DIR/api"

# Create binary build
if ! oc get buildconfig dengue-api &> /dev/null; then
    echo "Creating build config for API..."
    oc new-build --name=dengue-api --binary=true --strategy=docker
fi

# Start build from source
echo "Starting build for API..."
oc start-build dengue-api --from-dir=. --follow

# Apply deployment config if it doesn't exist
if ! oc get deployment dengue-api &> /dev/null; then
    echo "Creating API deployment..."
    oc apply -f "$ROOT_DIR/k8s/apps/api-deployment.yaml"
fi

echo "Building and deploying Visualizer..."
cd "$ROOT_DIR/visualizer"

# Create binary build
if ! oc get buildconfig dengue-visualizer &> /dev/null; then
    echo "Creating build config for Visualizer..."
    oc new-build --name=dengue-visualizer --binary=true --strategy=docker
fi

# Start build from source
echo "Starting build for Visualizer..."
oc start-build dengue-visualizer --from-dir=. --follow

# Apply deployment config if it doesn't exist
if ! oc get deployment dengue-visualizer &> /dev/null; then
    echo "Creating Visualizer deployment..."
    oc apply -f "$ROOT_DIR/k8s/apps/visualizer-deployment.yaml"
fi

# Wait for deployments to be ready
echo "Waiting for API deployment to be ready..."
oc rollout status deployment/dengue-api

echo "Waiting for Visualizer deployment to be ready..."
oc rollout status deployment/dengue-visualizer

# Get the route URL
ROUTE_URL=$(oc get route dengue-visualizer -o jsonpath='{.spec.host}')
echo "Application deployed successfully!"
echo "You can access the visualizer at: http://$ROUTE_URL"

# Test the API
echo "Testing API endpoints..."
API_POD=$(oc get pod -l app=dengue-api -o jsonpath='{.items[0].metadata.name}')
echo "Using API pod: $API_POD"

# Test health endpoint
echo "- Testing /health endpoint..."
oc exec "$API_POD" -- curl -s http://localhost:8000/health | grep "healthy" && echo "  Health check: OK" || echo "  Health check: FAILED"

# Test stats endpoint
echo "- Testing /national/stats endpoint..."
oc exec "$API_POD" -- curl -s http://localhost:8000/national/stats | grep "success" && echo "  Stats endpoint: OK" || echo "  Stats endpoint: FAILED"

# Test countries endpoint
echo "- Testing /national/countries endpoint..."
oc exec "$API_POD" -- curl -s http://localhost:8000/national/countries | grep "success" && echo "  Countries endpoint: OK" || echo "  Countries endpoint: FAILED"

# Test yearly endpoint
echo "- Testing /national/yearly endpoint..."
oc exec "$API_POD" -- curl -s http://localhost:8000/national/yearly | grep "success" && echo "  Yearly endpoint: OK" || echo "  Yearly endpoint: FAILED"

echo "Setup complete!"