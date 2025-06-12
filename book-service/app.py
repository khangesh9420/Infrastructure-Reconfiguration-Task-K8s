from flask import Flask, request, jsonify, send_from_directory
import requests

app = Flask(__name__)
books = []

# Kubernetes DNS for user-service; port 80 is implied
USER_SERVICE_URL = 'http://user-service.default.svc.cluster.local'

@app.route('/')
def index():
    return send_from_directory('.', 'index.html')

@app.route('/books', methods=['GET'])
def get_books():
    return jsonify(books)

@app.route('/books', methods=['POST'])
def add_book():
    data = request.json
    user_id = data.get('user_id')

    # Validate user exists via user-service
    try:
        response = requests.get(f'{USER_SERVICE_URL}/users/{user_id}')
        if response.status_code != 200:
            return jsonify({'error': 'User not found'}), 404
    except requests.exceptions.RequestException:
        return jsonify({'error': 'User service unreachable'}), 503

    books.append(data)
    return jsonify({'message': 'Book added'}), 201

@app.route('/users', methods=['GET'])
def get_users():
    try:
        response = requests.get(f'{USER_SERVICE_URL}/users')
        return jsonify(response.json())
    except requests.exceptions.RequestException:
        return jsonify({'error': 'User service unreachable'}), 503

@app.route('/users', methods=['POST'])
def add_user():
    try:
        response = requests.post(f'{USER_SERVICE_URL}/users', json=request.json)
        return jsonify({'message': 'User added'}), 201
    except requests.exceptions.RequestException:
        return jsonify({'error': 'User service unreachable'}), 503

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
