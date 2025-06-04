#!/bin/bash
# This script sets up everything needed to load dengue data into PostgreSQL in OpenShift

# Create ConfigMap for SQL schema
echo "Creating SQL schema ConfigMap..."
oc create configmap db-schema --from-file=../sql/load_data.sql -n open-dengue-data

# Expand PostgreSQL storage
echo "Expanding PostgreSQL storage to 10Gi..."
cat <<EOF | oc apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: postgresql
  namespace: open-dengue-data
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  storageClassName: ocs-storagecluster-ceph-rbd
EOF

# Restart PostgreSQL deployment to pick up new storage size
echo "Restarting PostgreSQL deployment..."
oc scale dc postgresql --replicas=0 -n open-dengue-data
sleep 5
oc scale dc postgresql --replicas=1 -n open-dengue-data
sleep 10

# Wait for PostgreSQL to be ready
echo "Waiting for PostgreSQL to be ready..."
oc wait --for=condition=Ready pod -l name=postgresql -n open-dengue-data --timeout=60s

# Create and run the data import job
echo "Creating data import job..."
cat <<EOF | oc apply -f -
apiVersion: batch/v1
kind: Job
metadata:
  name: dengue-data-import
  namespace: open-dengue-data
spec:
  backoffLimit: 3
  template:
    spec:
      containers:
      - name: data-importer
        image: postgres:13
        resources:
          requests:
            memory: "512Mi"
            cpu: "500m"
          limits:
            memory: "2Gi"
            cpu: "1"
        command:
        - "/bin/bash"
        - "-c"
        - |
          set -e
          
          # Connection parameters
          DB_HOST="postgresql"
          DB_PORT="5432"
          DB_NAME="sampledb"
          DB_USER="user5T0"
          DB_PASSWORD="I1A37SHxlTjB6ulf"
          
          echo "Starting data import process..."
          
          # Wait for PostgreSQL to be ready
          echo "Waiting for PostgreSQL to be ready..."
          until PGPASSWORD=\$DB_PASSWORD psql -h \$DB_HOST -p \$DB_PORT -U \$DB_USER -d \$DB_NAME -c '\q' 2>/dev/null; do
            echo "PostgreSQL is unavailable - sleeping"
            sleep 1
          done
          
          # Create database schema
          echo "Creating database schema..."
          PGPASSWORD=\$DB_PASSWORD psql -h \$DB_HOST -p \$DB_PORT -U \$DB_USER -d \$DB_NAME -f /schema/load_data.sql
          
          # Process CSV files to handle nulls
          echo "Processing CSV files..."
          sed 's/NA//g' /data/National_extract_V1_2_2.csv > /tmp/national_data.csv
          
          # Import National data
          echo "Importing National data..."
          PGPASSWORD=\$DB_PASSWORD psql -h \$DB_HOST -p \$DB_PORT -U \$DB_USER -d \$DB_NAME -c "\COPY national_data(adm_0_name, adm_1_name, adm_2_name, full_name, iso_a0, fao_gaul_code, rne_iso_code, ibge_code, calendar_start_date, calendar_end_date, year, dengue_total, case_definition_standardised, s_res, t_res, uuid) FROM '/tmp/national_data.csv' CSV HEADER"
          
          # Process and import Spatial data
          echo "Processing Spatial data..."
          sed 's/NA//g' /data/Spatial_extract_V1_2_2.csv > /tmp/spatial_data.csv
          
          echo "Importing Spatial data..."
          PGPASSWORD=\$DB_PASSWORD psql -h \$DB_HOST -p \$DB_PORT -U \$DB_USER -d \$DB_NAME -c "\COPY spatial_data(adm_0_name, adm_1_name, adm_2_name, full_name, iso_a0, fao_gaul_code, rne_iso_code, ibge_code, calendar_start_date, calendar_end_date, year, dengue_total, case_definition_standardised, s_res, t_res, uuid) FROM '/tmp/spatial_data.csv' CSV HEADER"
          
          # Process and import Temporal data
          echo "Processing Temporal data..."
          sed 's/NA//g' /data/Temporal_extract_V1_2_2.csv > /tmp/temporal_data.csv
          
          echo "Importing Temporal data..."
          PGPASSWORD=\$DB_PASSWORD psql -h \$DB_HOST -p \$DB_PORT -U \$DB_USER -d \$DB_NAME -c "\COPY temporal_data(adm_0_name, adm_1_name, adm_2_name, full_name, iso_a0, fao_gaul_code, rne_iso_code, ibge_code, calendar_start_date, calendar_end_date, year, dengue_total, case_definition_standardised, s_res, t_res, uuid) FROM '/tmp/temporal_data.csv' CSV HEADER"
          
          # Verify data loaded successfully
          echo "Verifying data loaded successfully..."
          PGPASSWORD=\$DB_PASSWORD psql -h \$DB_HOST -p \$DB_PORT -U \$DB_USER -d \$DB_NAME -c "
            SELECT 'national_data' as table_name, COUNT(*) as row_count FROM national_data
            UNION ALL
            SELECT 'spatial_data' as table_name, COUNT(*) as row_count FROM spatial_data
            UNION ALL
            SELECT 'temporal_data' as table_name, COUNT(*) as row_count FROM temporal_data;"
          
          echo "Data import complete!"
        volumeMounts:
        - name: csv-data
          mountPath: /data
          readOnly: true
        - name: schema
          mountPath: /schema
          readOnly: true
      restartPolicy: Never
      volumes:
      - name: csv-data
        persistentVolumeClaim:
          claimName: csv-data
      - name: schema
        configMap:
          name: db-schema
EOF

echo "Monitoring job status..."
oc logs -f job/dengue-data-import -n open-dengue-data

echo "All done!"