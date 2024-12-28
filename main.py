from flask import Flask, request, jsonify
from flask_jwt_extended import JWTManager, create_access_token, jwt_required, get_jwt_identity
import boto3
import os

app = Flask(__name__)
app.config['JWT_SECRET_KEY'] = 'your_jwt_secret_key'  # Change this to a random secret key
jwt = JWTManager(app)

# In-memory user storage
users = {}

# In-memory reports storage
reports = {
    "user123": [
        {
            "docId": "1",
            "file": "https://example-bucket.s3.amazonaws.com/docs/report1.pdf",
            "userId": "user123",
            "agencyId": "agency123",
            "timestamp": "2023-01-01T12:00:00Z",
            "type": "report",
            "thumbnail_url": "https://example-bucket.s3.amazonaws.com/thumbnails/report1.png"
        },
        {
            "docId": "2",
            "file": "https://example-bucket.s3.amazonaws.com/docs/report2.pdf",
            "userId": "user123",
            "agencyId": "agency124",
            "timestamp": "2023-01-02T12:00:00Z",
            "type": "prescription",
            "thumbnail_url": "https://example-bucket.s3.amazonaws.com/thumbnails/report2.png"
        }
    ]
}

@app.route('/register/user', methods=['POST'])
def register_user():
    data = request.get_json()
    abha_id = data.get('abha_id')
    password = data.get('password')

    if abha_id in users:
        return jsonify({"msg": "User already exists"}), 400

    users[abha_id] = password
    return jsonify({"msg": "User registered successfully"}), 200

@app.route('/login/user', methods=['POST'])
def login_user():
    data = request.get_json()
    abha_id = data.get('abha_id')
    password = data.get('password')

    if abha_id not in users or users[abha_id] != password:
        return jsonify({"msg": "Invalid ABHA ID or password"}), 401

    access_token = create_access_token(identity=abha_id)
    return jsonify({"msg": "Login successful", "access_token": access_token, "user_id": abha_id}), 200

@app.route('/docs/<user_id>/get_all', methods=['GET'])
@jwt_required()
def get_all_docs(user_id):
    current_user = get_jwt_identity()
    print(f"Current user: {current_user}, Requested user: {user_id}")  # Debugging statement
    if current_user != user_id:
        return jsonify({"msg": "Unauthorized"}), 401

    user_reports = reports.get(user_id, [])
    return jsonify(user_reports), 200

if __name__ == "__main__":
    app.run(debug=True, use_reloader=False, threaded=False)
