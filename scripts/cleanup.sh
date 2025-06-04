#!/bin/bash
# This script cleans up resources created in OpenShift

echo "Cleaning up resources in open-dengue-data namespace..."

# Delete API and visualizer
echo "Deleting API and visualizer applications..."
oc delete deployment dengue-api -n open-dengue-data || true
oc delete deployment dengue-visualizer -n open-dengue-data || true
oc delete service dengue-api -n open-dengue-data || true
oc delete service dengue-visualizer -n open-dengue-data || true
oc delete route dengue-visualizer -n open-dengue-data || true
oc delete configmap dengue-api-config -n open-dengue-data || true
oc delete configmap dengue-visualizer-config -n open-dengue-data || true
oc delete buildconfig dengue-api -n open-dengue-data || true
oc delete buildconfig dengue-visualizer -n open-dengue-data || true
oc delete imagestream dengue-api -n open-dengue-data || true
oc delete imagestream dengue-visualizer -n open-dengue-data || true

# Delete data import job
echo "Deleting data import job..."
oc delete job dengue-data-import -n open-dengue-data || true

# Delete CSV server
echo "Deleting CSV server..."
oc delete service csv-server -n open-dengue-data || true
oc delete pod csv-server -n open-dengue-data || true

# Delete PostgreSQL client
echo "Deleting PostgreSQL client..."
oc delete pod pg-client -n open-dengue-data || true

# Delete PVCs (data will be lost!)
echo "Deleting PVCs..."
oc delete pvc csv-data -n open-dengue-data || true
oc delete pvc dengue-data-pvc -n open-dengue-data || true

# Delete ConfigMap
echo "Deleting ConfigMap..."
oc delete configmap db-schema -n open-dengue-data || true
oc delete configmap data-loader-script -n open-dengue-data || true

echo "Cleanup complete!"