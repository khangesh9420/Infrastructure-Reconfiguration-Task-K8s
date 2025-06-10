from flask import Flask, request, jsonify
import requests

app = Flask(__name__)
books = []

@app.route('/books', methods=['GET'])
def get_books():
    return jsonify(books)

@app.route('/books', methods=['POST'])
def add_book():
    data = request.json
    user_id = data.get('user_id')
    
    # Validate user via user-service
    try:
        resp = requests.get(f'http://user-service.default.svc.cluster.local:5001/users/{user_id}')
        if resp.status_code != 200:
            return jsonify({'error': 'User not found'}), 404
    except requests.exceptions.RequestException:
        return jsonify({'error': 'User service unreachable'}), 503

    books.append(data)
    return jsonify({'message': 'Book added'}), 201

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
