#!/bin/bash
# Script to clean up the dengue-app Helm release from OpenShift

set -e

PROJECT_NAME="open-dengue-data"

# Check if logged in to OpenShift
if ! oc whoami &> /dev/null; then
    echo "Error: You must be logged in to OpenShift."
    exit 1
fi

# Set project
if ! oc get project "$PROJECT_NAME" &> /dev/null; then
    echo "Project $PROJECT_NAME does not exist."
    exit 0
else
    echo "Using project $PROJECT_NAME..."
    oc project "$PROJECT_NAME"
fi

# Check if helm command is available
if ! command -v helm &> /dev/null; then
    echo "Error: Helm is required but not installed. Please install Helm."
    exit 1
fi

echo "Uninstalling dengue-app Helm release..."
helm uninstall dengue-app --namespace "$PROJECT_NAME" || true

echo "Cleaning up any leftover resources..."
oc delete all -l app.kubernetes.io/instance=dengue-app --namespace "$PROJECT_NAME" || true
oc delete pvc -l app.kubernetes.io/instance=dengue-app --namespace "$PROJECT_NAME" || true
oc delete cm -l app.kubernetes.io/instance=dengue-app --namespace "$PROJECT_NAME" || true
oc delete secret -l app.kubernetes.io/instance=dengue-app --namespace "$PROJECT_NAME" || true

echo "Cleanup complete!"