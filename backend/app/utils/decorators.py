from functools import wraps
import jwt
from flask import request, jsonify, current_app
from app.models import User

def token_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        auth_header = request.headers.get('Authorization')
        if not auth_header or not auth_header.startswith('Bearer '):
            return jsonify({'message': 'Authorization header is missing or invalid!'}), 401
        
        token = auth_header.split(" ")[1]
        try:
            data = jwt.decode(token, current_app.config['JWT_SECRET_KEY'], algorithms=["HS256"])
            current_user = User.query.get(data['user_id'])
            if not current_user:
                return jsonify({'message': 'User not found!'}), 401
            return f(current_user, *args, **kwargs)
        except Exception as e:
            return jsonify({'message': 'Token is invalid!', 'error': str(e)}), 401
    return decorated
