#!/bin/bash
# Script to run tests for the API

# Check if dependencies are installed
if ! command -v pytest &> /dev/null; then
    echo "Installing required dependencies..."
    pip install -r requirements.txt
fi

echo "Running API tests..."
pytest -v tests/