from flask import Flask, request, jsonify, send_from_directory
import requests

app = Flask(__name__)
books = []

# Internal URL for user-service (Kubernetes service name)
USER_SERVICE_URL = 'http://user-service.default.svc.cluster.local'

@app.route('/')
def index():
    return send_from_directory('.', 'index.html')

@app.route('/books', methods=['GET'])
def get_books():
    return jsonify(books)

@app.route('/books', methods=['POST'])
def add_book():
    data = request.get_json(force=True)
    user_id = data.get('user_id')

    # Validate user existence via user-service
    try:
        response = requests.get(f'{USER_SERVICE_URL}/users/{user_id}')
        if response.status_code != 200:
            return jsonify({'error': 'User not found'}), 404
    except requests.exceptions.RequestException as e:
        return jsonify({'error': 'User service unreachable', 'details': str(e)}), 503

    books.append(data)
    return jsonify({'message': 'Book added'}), 201

# Proxy users GET/POST to user-service
@app.route('/users', methods=['GET'])
def get_users():
    try:
        response = requests.get(f'{USER_SERVICE_URL}/users')
        return jsonify(response.json())
    except requests.exceptions.RequestException as e:
        return jsonify({'error': 'User service unreachable', 'details': str(e)}), 503

@app.route('/users', methods=['POST'])
def add_user():
    try:
        response = requests.post(f'{USER_SERVICE_URL}/users', json=request.json)
        return jsonify(response.json()), response.status_code
    except requests.exceptions.RequestException as e:
        return jsonify({'error': 'User service unreachable', 'details': str(e)}), 503

# Optional: JSON fallback for 404s
@app.errorhandler(404)
def not_found(e):
    return jsonify({'error': 'Not Found'}), 404

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
