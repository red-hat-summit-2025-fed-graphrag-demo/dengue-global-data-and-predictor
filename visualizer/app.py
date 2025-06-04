from flask import Flask, render_template, request, jsonify
import requests
import os
from dotenv import load_dotenv
from filters import format_number

load_dotenv()

app = Flask(__name__)

# Register custom filters
app.jinja_env.filters['format_number'] = format_number

# Configuration
API_HOST = os.getenv("API_HOST", "dengue-api")
API_PORT = os.getenv("API_PORT", "8000")
API_BASE_URL = f"http://{API_HOST}:{API_PORT}"

def get_api_data(endpoint, params=None):
    """Helper function to call the API"""
    try:
        response = requests.get(f"{API_BASE_URL}{endpoint}", params=params)
        response.raise_for_status()
        return response.json()
    except requests.exceptions.RequestException as e:
        print(f"API error: {str(e)}")
        return {"status": "error", "data": None, "message": str(e)}

@app.route('/')
def index():
    """Main dashboard page"""
    try:
        # Get stats for dashboard
        stats_response = get_api_data('/national/stats')
        stats = stats_response.get('data', {})
        
        # Get top countries
        countries_response = get_api_data('/national/countries', {'limit': 10})
        countries = countries_response.get('data', [])
        
        # Get yearly data
        yearly_response = get_api_data('/national/yearly')
        yearly_data = yearly_response.get('data', [])
        
        return render_template(
            'index.html',
            stats=stats,
            countries=countries,
            yearly_data=yearly_data,
            api_status=stats_response.get('status', 'error')
        )
    except Exception as e:
        return render_template('error.html', error=str(e))

@app.route('/country/<country_name>')
def country_details(country_name):
    """Country detail page"""
    try:
        # Get country yearly data
        yearly_response = get_api_data('/national/yearly', {'country': country_name})
        yearly_data = yearly_response.get('data', [])
        
        # Get regional data for the country
        regions_response = get_api_data('/spatial/regions', {'country': country_name, 'limit': 20})
        regions = regions_response.get('data', [])
        
        # Get temporal data for the country
        temporal_response = get_api_data('/temporal/data', {'country': country_name, 'limit': 100})
        temporal_data = temporal_response.get('data', [])
        
        return render_template(
            'country.html',
            country=country_name,
            yearly_data=yearly_data,
            regions=regions,
            temporal_data=temporal_data,
            api_status=yearly_response.get('status', 'error')
        )
    except Exception as e:
        return render_template('error.html', error=str(e))

@app.route('/api/proxy/<path:endpoint>')
def api_proxy(endpoint):
    """Proxy API requests to backend API service"""
    params = {k: v for k, v in request.args.items()}
    response = get_api_data(f'/{endpoint}', params)
    return jsonify(response)

@app.route('/health')
def health():
    """Health check endpoint"""
    try:
        # Check API health
        api_health = get_api_data('/health')
        return jsonify({
            "status": "healthy",
            "api_status": api_health.get('status', 'error'),
            "api_connection": "ok" if api_health.get('status') == "healthy" else "error"
        })
    except Exception as e:
        return jsonify({
            "status": "unhealthy",
            "message": str(e)
        }), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)