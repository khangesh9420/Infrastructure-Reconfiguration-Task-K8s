from flask import Flask, request, jsonify, send_from_directory
import requests

app = Flask(__name__)

# Internal Kubernetes DNS
REGISTRATION_SERVICE_URL = 'http://user-service.default.svc.cluster.local'

@app.route('/')
def index():
    return send_from_directory('.', 'index.html')

@app.route('/register', methods=['POST'])
def register():
    try:
        response = requests.post(f'{REGISTRATION_SERVICE_URL}/register', json=request.json)
        return jsonify(response.json()), response.status_code
    except requests.exceptions.RequestException as e:
        return jsonify({'error': 'Registration service unreachable', 'details': str(e)}), 503

@app.route('/registrants', methods=['GET'])
def get_registrants():
    try:
        response = requests.get(f'{REGISTRATION_SERVICE_URL}/registrants')
        return jsonify(response.json())
    except requests.exceptions.RequestException as e:
        return jsonify({'error': 'Registration service unreachable', 'details': str(e)}), 503

@app.errorhandler(404)
def not_found(e):
    return jsonify({'error': 'Not Found'}), 404

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
