# app/app.py

from flask import Flask, jsonify, request
app = Flask(__name__)

@app.route('/')
def home():
    return jsonify(message="Welcome to the Flask app!")

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=80)