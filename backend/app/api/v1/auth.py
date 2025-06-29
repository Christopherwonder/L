import jwt
import datetime
from flask import Blueprint, request, jsonify, current_app
from app.models import User
from app import db

bp = Blueprint('auth', __name__)

@bp.route('/register', methods=['POST'])
def register():
    data = request.get_json()
    if not all(k in data for k in ('email', 'password', 'username')):
        return jsonify({'message': 'Missing required fields'}), 400
    if User.query.filter((User.email == data['email']) | (User.username == data['username'])).first():
        return jsonify({'message': 'User with that email or username already exists'}), 409
    
    new_user = User(username=data['username'], email=data['email'], password=data['password'])
    db.session.add(new_user)
    db.session.commit()
    return jsonify({'message': 'User registered successfully'}), 201

@bp.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    user = User.query.filter_by(email=data.get('email')).first()
    if user and user.check_password(data.get('password')):
        token = jwt.encode({
            'user_id': user.id,
            'exp': datetime.datetime.utcnow() + datetime.timedelta(hours=24)
        }, current_app.config['JWT_SECRET_KEY'], algorithm="HS256")
        return jsonify({
            'token': token, 
            'user': {'id': user.id, 'username': user.username, 'email': user.email}
        }), 200
    return jsonify({'message': 'Invalid credentials'}), 401
