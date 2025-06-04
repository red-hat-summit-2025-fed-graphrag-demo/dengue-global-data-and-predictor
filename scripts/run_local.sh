#!/bin/bash
# Script to run the API and visualizer locally with a simulated database

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is required to run this script."
    exit 1
fi

# Function to cleanup resources on exit
cleanup() {
    echo "Cleaning up resources..."
    docker stop dengue-postgres 2>/dev/null || true
    docker rm dengue-postgres 2>/dev/null || true
    kill $API_PID 2>/dev/null || true
    kill $VISUALIZER_PID 2>/dev/null || true
}

# Set up cleanup on script exit
trap cleanup EXIT

# Start PostgreSQL container
echo "Starting PostgreSQL container..."
docker run --name dengue-postgres -e POSTGRES_USER=user5T0 -e POSTGRES_PASSWORD=I1A37SHxlTjB6ulf \
    -e POSTGRES_DB=sampledb -p 5432:5432 -d postgres:13

echo "Waiting for PostgreSQL to start..."
sleep 5

# Create schema and sample data
echo "Creating schema and sample data..."
docker cp "$ROOT_DIR/sql/load_data.sql" dengue-postgres:/tmp/
docker exec dengue-postgres psql -U user5T0 -d sampledb -f /tmp/load_data.sql

echo "Loading sample data..."
cat > /tmp/sample_data.sql << EOF
-- Sample data for national_data
INSERT INTO national_data (adm_0_name, adm_1_name, adm_2_name, full_name, iso_a0, fao_gaul_code, rne_iso_code, 
                         calendar_start_date, calendar_end_date, year, dengue_total, 
                         case_definition_standardised, s_res, t_res, uuid)
VALUES 
('BRAZIL', NULL, NULL, 'BRAZIL', 'BRA', 123, 'BRA', '2020-01-01', '2020-01-07', 2020, 5000, 'Suspected', 'Admin0', 'Week', 'BR-2020-W01'),
('BRAZIL', NULL, NULL, 'BRAZIL', 'BRA', 123, 'BRA', '2020-01-08', '2020-01-14', 2020, 6000, 'Suspected', 'Admin0', 'Week', 'BR-2020-W02'),
('BRAZIL', NULL, NULL, 'BRAZIL', 'BRA', 123, 'BRA', '2021-01-01', '2021-01-07', 2021, 7000, 'Suspected', 'Admin0', 'Week', 'BR-2021-W01'),
('THAILAND', NULL, NULL, 'THAILAND', 'THA', 456, 'THA', '2020-01-01', '2020-01-07', 2020, 3000, 'Suspected', 'Admin0', 'Week', 'TH-2020-W01'),
('THAILAND', NULL, NULL, 'THAILAND', 'THA', 456, 'THA', '2021-01-01', '2021-01-07', 2021, 4000, 'Suspected', 'Admin0', 'Week', 'TH-2021-W01'),
('MEXICO', NULL, NULL, 'MEXICO', 'MEX', 789, 'MEX', '2020-01-01', '2020-01-07', 2020, 2000, 'Suspected', 'Admin0', 'Week', 'MX-2020-W01');

-- Sample data for spatial_data
INSERT INTO spatial_data (adm_0_name, adm_1_name, adm_2_name, full_name, iso_a0, fao_gaul_code, rne_iso_code, 
                         calendar_start_date, calendar_end_date, year, dengue_total, 
                         case_definition_standardised, s_res, t_res, uuid)
VALUES 
('BRAZIL', 'SAO PAULO', NULL, 'BRAZIL - SAO PAULO', 'BRA', 123, 'BRA', '2020-01-01', '2020-01-07', 2020, 2000, 'Suspected', 'Admin1', 'Week', 'BR-SP-2020-W01'),
('BRAZIL', 'RIO DE JANEIRO', NULL, 'BRAZIL - RIO DE JANEIRO', 'BRA', 123, 'BRA', '2020-01-01', '2020-01-07', 2020, 1500, 'Suspected', 'Admin1', 'Week', 'BR-RJ-2020-W01'),
('BRAZIL', 'MINAS GERAIS', NULL, 'BRAZIL - MINAS GERAIS', 'BRA', 123, 'BRA', '2020-01-01', '2020-01-07', 2020, 1200, 'Suspected', 'Admin1', 'Week', 'BR-MG-2020-W01'),
('THAILAND', 'BANGKOK', NULL, 'THAILAND - BANGKOK', 'THA', 456, 'THA', '2020-01-01', '2020-01-07', 2020, 1800, 'Suspected', 'Admin1', 'Week', 'TH-BK-2020-W01'),
('THAILAND', 'CHIANG MAI', NULL, 'THAILAND - CHIANG MAI', 'THA', 456, 'THA', '2020-01-01', '2020-01-07', 2020, 900, 'Suspected', 'Admin1', 'Week', 'TH-CM-2020-W01');

-- Sample data for temporal_data
INSERT INTO temporal_data (adm_0_name, adm_1_name, adm_2_name, full_name, iso_a0, fao_gaul_code, rne_iso_code, 
                         calendar_start_date, calendar_end_date, year, dengue_total, 
                         case_definition_standardised, s_res, t_res, uuid)
VALUES 
('BRAZIL', NULL, NULL, 'BRAZIL', 'BRA', 123, 'BRA', '2020-01-01', '2020-01-07', 2020, 5000, 'Suspected', 'Admin0', 'Week', 'BR-2020-W01'),
('BRAZIL', NULL, NULL, 'BRAZIL', 'BRA', 123, 'BRA', '2020-01-08', '2020-01-14', 2020, 6000, 'Suspected', 'Admin0', 'Week', 'BR-2020-W02'),
('BRAZIL', NULL, NULL, 'BRAZIL', 'BRA', 123, 'BRA', '2020-01-15', '2020-01-21', 2020, 7000, 'Suspected', 'Admin0', 'Week', 'BR-2020-W03'),
('BRAZIL', NULL, NULL, 'BRAZIL', 'BRA', 123, 'BRA', '2020-01-22', '2020-01-28', 2020, 6500, 'Suspected', 'Admin0', 'Week', 'BR-2020-W04'),
('BRAZIL', NULL, NULL, 'BRAZIL', 'BRA', 123, 'BRA', '2020-01-29', '2020-02-04', 2020, 8000, 'Suspected', 'Admin0', 'Week', 'BR-2020-W05'),
('BRAZIL', NULL, NULL, 'BRAZIL', 'BRA', 123, 'BRA', '2020-02-05', '2020-02-11', 2020, 8500, 'Suspected', 'Admin0', 'Week', 'BR-2020-W06'),
('BRAZIL', NULL, NULL, 'BRAZIL', 'BRA', 123, 'BRA', '2020-02-12', '2020-02-18', 2020, 9000, 'Suspected', 'Admin0', 'Week', 'BR-2020-W07'),
('BRAZIL', NULL, NULL, 'BRAZIL', 'BRA', 123, 'BRA', '2020-02-19', '2020-02-25', 2020, 8000, 'Suspected', 'Admin0', 'Week', 'BR-2020-W08'),
('BRAZIL', NULL, NULL, 'BRAZIL', 'BRA', 123, 'BRA', '2020-02-26', '2020-03-03', 2020, 7500, 'Suspected', 'Admin0', 'Week', 'BR-2020-W09'),
('BRAZIL', NULL, NULL, 'BRAZIL', 'BRA', 123, 'BRA', '2020-03-04', '2020-03-10', 2020, 7000, 'Suspected', 'Admin0', 'Week', 'BR-2020-W10');
EOF

docker cp /tmp/sample_data.sql dengue-postgres:/tmp/
docker exec dengue-postgres psql -U user5T0 -d sampledb -f /tmp/sample_data.sql
rm /tmp/sample_data.sql

# Set up environment for API and visualizer
echo "Setting up environment..."
export DB_HOST=localhost
export DB_PORT=5432
export DB_NAME=sampledb
export DB_USER=user5T0
export DB_PASSWORD=I1A37SHxlTjB6ulf

# Start API service in background
echo "Starting API service..."
cd "$ROOT_DIR/api"
python -c "import sys; sys.exit(0)" || pip install -r requirements.txt
uvicorn main:app --reload --host 0.0.0.0 --port 8000 &
API_PID=$!

echo "API service started with PID: $API_PID"
echo "API is available at: http://localhost:8000"
echo "API documentation is available at: http://localhost:8000/docs"

# Wait for API to start
echo "Waiting for API to start..."
sleep 5

# Set up environment for visualizer
export API_HOST=localhost
export API_PORT=8000

# Start visualizer in background
echo "Starting visualizer..."
cd "$ROOT_DIR/visualizer"
python -c "import sys; sys.exit(0)" || pip install -r requirements.txt
python app.py &
VISUALIZER_PID=$!

echo "Visualizer started with PID: $VISUALIZER_PID"
echo "Visualizer is available at: http://localhost:5000"

echo ""
echo "=============================================="
echo "Local development environment is running:"
echo "- API: http://localhost:8000"
echo "- API Docs: http://localhost:8000/docs"
echo "- Visualizer: http://localhost:5000"
echo "- Database: PostgreSQL @ localhost:5432"
echo ""
echo "Press Ctrl+C to stop all services"
echo "=============================================="

# Wait for user to press Ctrl+C
wait $API_PID $VISUALIZER_PID