from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_bcrypt import Bcrypt
from flask_migrate import Migrate
from flask_cors import CORS
from config import config_by_name

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
