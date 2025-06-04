#!/bin/bash
# Script to deploy the dengue-app Helm chart to OpenShift

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
HELM_DIR="$ROOT_DIR/helm/dengue-app"

# Check if logged in to OpenShift
if ! oc whoami &> /dev/null; then
    echo "Error: You must be logged in to OpenShift."
    exit 1
fi

# Set project
PROJECT_NAME="open-dengue-data"
if ! oc get project "$PROJECT_NAME" &> /dev/null; then
    echo "Creating project $PROJECT_NAME..."
    oc new-project "$PROJECT_NAME"
else
    echo "Using existing project $PROJECT_NAME..."
    oc project "$PROJECT_NAME"
fi

# Check if helm command is available
if ! command -v helm &> /dev/null; then
    echo "Error: Helm is required but not installed. Please install Helm."
    exit 1
fi

# Add Bitnami repo if not already added
if ! helm repo list | grep -q "bitnami"; then
    echo "Adding Bitnami Helm repository..."
    helm repo add bitnami https://charts.bitnami.com/bitnami
fi

echo "Updating Helm repositories..."
helm repo update

echo "Installing/Upgrading dengue-app Helm chart..."
helm upgrade --install dengue-app "$HELM_DIR" \
  --namespace "$PROJECT_NAME" \
  --set postgresql.auth.password="I1A37SHxlTjB6ulf" \
  --set postgresql.primary.persistence.size=8Gi \
  --wait

# Wait for all pods to be ready
echo "Waiting for all pods to be ready..."
oc wait --for=condition=ready pod -l app.kubernetes.io/instance=dengue-app --timeout=300s

# Get the visualizer route
ROUTE_URL=$(oc get route dengue-app-visualizer -o jsonpath='{.spec.host}')
echo "===================================================="
echo "Dengue Data application deployed successfully!"
echo "Visualizer URL: http://$ROUTE_URL"
echo "===================================================="

# Test API endpoints
echo "Testing API endpoints..."
API_POD=$(oc get pod -l app=dengue-app-api -o jsonpath='{.items[0].metadata.name}')
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

echo "Deployment complete!"