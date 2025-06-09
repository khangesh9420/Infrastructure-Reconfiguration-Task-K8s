from flask import Flask, request, jsonify

app = Flask(__name__)
books = []

@app.route('/books', methods=['GET'])
def get_books():
    return jsonify(books)

@app.route('/books', methods=['POST'])
def add_book():
    data = request.json
    books.append(data)
    return jsonify({'message': 'Book added'}), 201

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
