# Flask Framework

> **Scope**: Apply these rules when working with Flask applications.

## 1. Application Factory
- **Factory Pattern**: Use application factory for flexibility.
- **Blueprints**: Organize routes with blueprints.
- **Configuration**: Load config from environment or files.

```python
# app/__init__.py
from flask import Flask
from .config import Config

def create_app(config_class=Config):
    app = Flask(__name__)
    app.config.from_object(config_class)
    
    from .users import bp as users_bp
    app.register_blueprint(users_bp, url_prefix='/users')
    
    from .posts import bp as posts_bp
    app.register_blueprint(posts_bp, url_prefix='/posts')
    
    return app
```

## 2. Blueprints
- **Modular Routes**: Group related routes in blueprints.
- **URL Prefixes**: Use prefixes for organization.
- **Blueprint Structure**: Each blueprint in its own module.

```python
# app/users/routes.py
from flask import Blueprint, jsonify, request
from .services import UserService

bp = Blueprint('users', __name__)
user_service = UserService()

@bp.route('/', methods=['GET'])
def list_users():
    users = user_service.get_all_users()
    return jsonify([user.to_dict() for user in users])

@bp.route('/', methods=['POST'])
def create_user():
    data = request.get_json()
    user = user_service.create_user(data)
    return jsonify(user.to_dict()), 201
```

## 3. Request Handling
- **Request Object**: Access data via `request.get_json()`, `request.args`, `request.form`.
- **Validation**: Validate input data before processing.
- **Error Handling**: Use error handlers for consistent responses.

```python
from flask import request, jsonify
from marshmallow import ValidationError

@bp.route('/users/', methods=['POST'])
def create_user():
    try:
        data = request.get_json()
        user = user_service.create_user(data)
        return jsonify(user.to_dict()), 201
    except ValidationError as e:
        return jsonify({'errors': e.messages}), 400
    except ValueError as e:
        return jsonify({'error': str(e)}), 400
```

## 4. Serialization (Marshmallow)
- **Schemas**: Use Marshmallow for serialization/validation.
- **Nested Schemas**: For related objects.
- **Validation**: Define validation rules in schemas.

```python
from marshmallow import Schema, fields, validate, ValidationError

class UserSchema(Schema):
    id = fields.Int(dump_only=True)
    email = fields.Email(required=True)
    full_name = fields.Str(required=True, validate=validate.Length(min=1, max=100))
    password = fields.Str(load_only=True, required=True, validate=validate.Length(min=8))
    is_active = fields.Bool(dump_only=True)
    created_at = fields.DateTime(dump_only=True)

user_schema = UserSchema()
users_schema = UserSchema(many=True)

# Usage
@bp.route('/', methods=['POST'])
def create_user():
    try:
        data = user_schema.load(request.get_json())
        user = user_service.create_user(data)
        return user_schema.dump(user), 201
    except ValidationError as e:
        return {'errors': e.messages}, 400
```

## 5. Database (Flask-SQLAlchemy)
- **ORM**: Use Flask-SQLAlchemy for database operations.
- **Models**: Define models with SQLAlchemy.
- **Sessions**: Use `db.session` for transactions.
- **Migrations**: Use Flask-Migrate (Alembic) for migrations.

```python
# app/models.py
from app import db
from datetime import datetime

class User(db.Model):
    __tablename__ = 'users'
    
    id = db.Column(db.Integer, primary_key=True)
    email = db.Column(db.String(120), unique=True, nullable=False)
    full_name = db.Column(db.String(100), nullable=False)
    hashed_password = db.Column(db.String(255), nullable=False)
    is_active = db.Column(db.Boolean, default=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    def to_dict(self):
        return {
            'id': self.id,
            'email': self.email,
            'full_name': self.full_name,
            'is_active': self.is_active,
            'created_at': self.created_at.isoformat()
        }
```

## 6. Service Layer
- **Business Logic**: Move complex logic to service classes.
- **Thin Routes**: Routes should validate and delegate to services.
- **Transactions**: Use context managers for transactions.

```python
# app/users/services.py
from app import db
from app.models import User
from werkzeug.security import generate_password_hash

class UserService:
    def create_user(self, data: dict) -> User:
        user = User(
            email=data['email'],
            full_name=data['full_name'],
            hashed_password=generate_password_hash(data['password'])
        )
        db.session.add(user)
        db.session.commit()
        return user
    
    def get_user(self, user_id: int) -> User | None:
        return User.query.get(user_id)
    
    def get_all_users(self) -> list[User]:
        return User.query.filter_by(is_active=True).all()
```

## 7. Error Handling
- **Error Handlers**: Register global error handlers.
- **Custom Exceptions**: Create domain-specific exceptions.
- **Consistent Responses**: Return consistent error format.

```python
# app/__init__.py
@app.errorhandler(404)
def not_found(error):
    return jsonify({'error': 'Resource not found'}), 404

@app.errorhandler(500)
def internal_error(error):
    db.session.rollback()
    return jsonify({'error': 'Internal server error'}), 500

# Custom exception
class UserNotFoundException(Exception):
    pass

@app.errorhandler(UserNotFoundException)
def handle_user_not_found(error):
    return jsonify({'error': str(error)}), 404
```

## 8. Configuration
- **Config Classes**: Use classes for different environments.
- **Environment Variables**: Load sensitive data from env vars.
- **Config Object**: Access via `app.config`.

```python
# app/config.py
import os

class Config:
    SECRET_KEY = os.environ.get('SECRET_KEY') or 'dev-secret-key'
    SQLALCHEMY_DATABASE_URI = os.environ.get('DATABASE_URL')
    SQLALCHEMY_TRACK_MODIFICATIONS = False

class DevelopmentConfig(Config):
    DEBUG = True

class ProductionConfig(Config):
    DEBUG = False
```

## 9. Authentication (Flask-JWT-Extended)
- **JWT Tokens**: Use Flask-JWT-Extended for auth.
- **Protected Routes**: Use `@jwt_required()` decorator.
- **Current User**: Access via `get_jwt_identity()`.

```python
from flask_jwt_extended import JWTManager, create_access_token, jwt_required, get_jwt_identity

jwt = JWTManager(app)

@bp.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    user = user_service.authenticate(data['email'], data['password'])
    if not user:
        return {'error': 'Invalid credentials'}, 401
    
    access_token = create_access_token(identity=user.id)
    return {'access_token': access_token}, 200

@bp.route('/profile', methods=['GET'])
@jwt_required()
def get_profile():
    user_id = get_jwt_identity()
    user = user_service.get_user(user_id)
    return user_schema.dump(user)
```

## 10. Testing
- **Test Client**: Use Flask's test client.
- **Fixtures**: Use pytest fixtures for setup.
- **Database**: Use separate test database.

```python
# tests/test_users.py
import pytest
from app import create_app, db
from app.models import User

@pytest.fixture
def client():
    app = create_app('testing')
    with app.test_client() as client:
        with app.app_context():
            db.create_all()
            yield client
            db.drop_all()

def test_create_user(client):
    response = client.post('/users/', json={
        'email': 'test@example.com',
        'password': 'Secure123',
        'full_name': 'Test User'
    })
    assert response.status_code == 201
    assert response.json['email'] == 'test@example.com'
```

## 11. Anti-Patterns (MUST avoid)
- **Logic in Routes**: Keep routes thin, move logic to services.
  - ❌ Bad: `@bp.route('/') def index(): user = User(...); db.session.add(user); ...`
  - ✅ Good: `@bp.route('/') def index(): return user_service.create_user(data)`
- **Global DB Session**: Use `db.session`, not global sessions.
- **Missing Validation**: Always validate input data.
- **Hardcoded Config**: Use environment variables for secrets.

