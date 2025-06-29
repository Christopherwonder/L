#!/bin/bash
# Filename: create_backend.sh

echo "Creating backend directory structure..."
mkdir -p backend/app/api/v1 backend/app/services backend/app/utils backend/migrations/versions

echo "Generating all backend files..."

# --- Filename: backend/Dockerfile ---
cat << 'EOF' > backend/Dockerfile
FROM python:3.9-slim
WORKDIR /usr/src/app
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
RUN apt-get update && apt-get install -y --no-install-recommends gcc && rm -rf /var/lib/apt/lists/*
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
EXPOSE 5000
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "run:app"]
EOF

# --- Filename: backend/requirements.txt ---
cat << 'EOF' > backend/requirements.txt
Flask==2.2.2
python-dotenv==0.21.0
psycopg2-binary==2.9.5
Flask-SQLAlchemy==3.0.2
Flask-Migrate==4.0.0
Flask-Bcrypt==1.0.1
PyJWT==2.6.0
requests==2.28.1
gunicorn==20.1.0
Flask-Cors==3.0.10
pydantic==1.10.2
EOF

# --- Filename: backend/config.py ---
cat << 'EOF' > backend/config.py
import os
from dotenv import load_dotenv

dotenv_path = os.path.join(os.path.dirname(__file__), '..', '.env')
load_dotenv(dotenv_path=dotenv_path)

class Config:
    SECRET_KEY = os.getenv('SECRET_KEY')
    JWT_SECRET_KEY = os.getenv('JWT_SECRET_KEY')
    SQLALCHEMY_DATABASE_URI = os.getenv('DATABASE_URL')
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    ASTRA_API_KEY = os.getenv('ASTRA_API_KEY')

class DevelopmentConfig(Config):
    DEBUG = True
    SQLALCHEMY_ECHO = False

class ProductionConfig(Config):
    DEBUG = False
    SQLALCHEMY_ECHO = False

config_by_name = {
    'development': DevelopmentConfig,
    'production': ProductionConfig,
}
EOF

# --- Filename: backend/run.py ---
cat << 'EOF' > backend/run.py
import os
from app import create_app

env_name = os.getenv('FLASK_ENV', 'development')
app = create_app(env_name)

if __name__ == '__main__':
    app.run()
EOF

# --- Filename: backend/app/__init__.py ---
cat << 'EOF' > backend/app/__init__.py
from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_bcrypt import Bcrypt
from flask_migrate import Migrate
from flask_cors import CORS
from .config import config_by_name

db = SQLAlchemy()
bcrypt = Bcrypt()

def create_app(config_name):
    app = Flask(__name__)
    app.config.from_object(config_by_name[config_name])
    
    db.init_app(app)
    bcrypt.init_app(app)
    Migrate(app, db)
    CORS(app)

    with app.app_context():
        from .api.v1 import auth, users, freelancers, payments, ratings
        app.register_blueprint(auth.bp, url_prefix='/api/v1/auth')
        app.register_blueprint(users.bp, url_prefix='/api/v1/users')
        app.register_blueprint(freelancers.bp, url_prefix='/api/v1/freelancers')
        app.register_blueprint(payments.bp, url_prefix='/api/v1/payments')
        app.register_blueprint(ratings.bp, url_prefix='/api/v1/ratings')
    
    return app
EOF

# --- Filename: backend/app/models.py ---
cat << 'EOF' > backend/app/models.py
import datetime
from sqlalchemy.dialects.postgresql import JSONB
from . import db, bcrypt

class User(db.Model):
    __tablename__ = 'users'
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password_hash = db.Column(db.String(128), nullable=False)
    
    def __init__(self, username, email, password):
        self.username = username
        self.email = email
        self.password_hash = bcrypt.generate_password_hash(password).decode('utf-8')
    def check_password(self, password):
        return bcrypt.check_password_hash(self.password_hash, password)
EOF

# --- Filename: backend/app/utils/decorators.py ---
cat << 'EOF' > backend/app/utils/decorators.py
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
        except Exception as e:
            return jsonify({'message': 'Token is invalid!', 'error': str(e)}), 401
        return f(current_user, *args, **kwargs)
    return decorated
EOF

# --- Filename: backend/app/api/v1/auth.py ---
cat << 'EOF' > backend/app/api/v1/auth.py
import jwt
import datetime
from flask import Blueprint, request, jsonify, current_app
from app.models import User
from app import db, bcrypt

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
EOF

# --- Create empty but valid blueprint files ---
cat << 'EOF' > backend/app/api/v1/users.py
from flask import Blueprint
bp = Blueprint('users', __name__)
EOF

cat << 'EOF' > backend/app/api/v1/freelancers.py
from flask import Blueprint
bp = Blueprint('freelancers', __name__)
EOF

cat << 'EOF' > backend/app/api/v1/payments.py
from flask import Blueprint
bp = Blueprint('payments', __name__)
EOF

cat << 'EOF' > backend/app/api/v1/ratings.py
from flask import Blueprint
bp = Blueprint('ratings', __name__)
EOF

echo "Backend generation complete."
chmod +x backend/run.py
EOF

# --- Make script executable ---
chmod +x create_backend.sh
echo "create_backend.sh has been created."

