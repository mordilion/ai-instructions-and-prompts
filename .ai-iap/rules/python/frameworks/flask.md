# Flask Framework

## Overview
Flask: lightweight, flexible Python web microframework with minimalist core.
Philosophy: provide basics (routing, requests), you choose extensions (database, auth, etc.).
Best for small to medium applications, APIs, and when you need maximum flexibility.

## Basic Application

```python
from flask import Flask, request, jsonify
from werkzeug.exceptions import NotFound

app = Flask(__name__)

@app.route("/users", methods=["GET"])
def get_users():
    users = user_service.get_all()
    return jsonify([user.to_dict() for user in users])

@app.route("/users/<int:user_id>", methods=["GET"])
def get_user(user_id):
    user = user_service.get_by_id(user_id)
    if not user:
        raise NotFound("User not found")
    return jsonify(user.to_dict())

@app.route("/users", methods=["POST"])
def create_user():
    data = request.get_json()
    user = user_service.create(data)
    return jsonify(user.to_dict()), 201

if __name__ == "__main__":
    app.run(debug=True)
```

## Flask-SQLAlchemy

```python
from flask_sqlalchemy import SQLAlchemy
from datetime import datetime

db = SQLAlchemy()

class User(db.Model):
    __tablename__ = "users"
    
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    email = db.Column(db.String(100), unique=True, nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    posts = db.relationship("Post", backref="user", lazy="dynamic")
    
    def to_dict(self):
        return {
            "id": self.id,
            "name": self.name,
            "email": self.email
        }

# Initialize
app.config["SQLALCHEMY_DATABASE_URI"] = "postgresql://user:pass@localhost/db"
db.init_app(app)

with app.app_context():
    db.create_all()
```

## Blueprints

```python
from flask import Blueprint

users_bp = Blueprint("users", __name__, url_prefix="/api/users")

@users_bp.route("", methods=["GET"])
def get_users():
    return jsonify([])

@users_bp.route("/<int:user_id>", methods=["GET"])
def get_user(user_id):
    return jsonify({})

# Register
app.register_blueprint(users_bp)
```

## Request Validation (Marshmallow)

```python
from marshmallow import Schema, fields, validate, ValidationError

class UserSchema(Schema):
    id = fields.Int(dump_only=True)
    name = fields.Str(required=True, validate=validate.Length(min=2, max=100))
    email = fields.Email(required=True)

user_schema = UserSchema()
users_schema = UserSchema(many=True)

@app.route("/users", methods=["POST"])
def create_user():
    try:
        data = user_schema.load(request.get_json())
    except ValidationError as err:
        return jsonify(err.messages), 400
    
    user = user_service.create(data)
    return jsonify(user_schema.dump(user)), 201
```

## Error Handling

```python
from werkzeug.exceptions import HTTPException

class UserNotFoundException(Exception):
    pass

@app.errorhandler(UserNotFoundException)
def handle_user_not_found(e):
    return jsonify({"error": str(e)}), 404

@app.errorhandler(ValidationError)
def handle_validation_error(e):
    return jsonify({"errors": e.messages}), 400

@app.errorhandler(HTTPException)
def handle_http_exception(e):
    return jsonify({"error": e.description}), e.code
```

## Authentication (Flask-JWT-Extended)

```python
from flask_jwt_extended import (
    JWTManager, create_access_token,
    jwt_required, get_jwt_identity
)

app.config["JWT_SECRET_KEY"] = "secret"
jwt = JWTManager(app)

@app.route("/login", methods=["POST"])
def login():
    data = request.get_json()
    user = user_service.authenticate(data["email"], data["password"])
    if not user:
        return jsonify({"error": "Invalid credentials"}), 401
    
    access_token = create_access_token(identity=user.id)
    return jsonify({"access_token": access_token})

@app.route("/profile", methods=["GET"])
@jwt_required()
def profile():
    user_id = get_jwt_identity()
    user = user_service.get_by_id(user_id)
    return jsonify(user_schema.dump(user))
```

## Configuration

```python
class Config:
    SECRET_KEY = os.getenv("SECRET_KEY", "dev")
    SQLALCHEMY_DATABASE_URI = os.getenv("DATABASE_URL")
    SQLALCHEMY_TRACK_MODIFICATIONS = False

app.config.from_object(Config)

# Or from file
app.config.from_pyfile("config.py")
```

## Middleware

```python
@app.before_request
def log_request():
    app.logger.info(f"{request.method} {request.path}")

@app.after_request
def add_header(response):
    response.headers["X-Custom-Header"] = "value"
    return response
```

## Testing

```python
import pytest

@pytest.fixture
def client():
    app.config["TESTING"] = True
    with app.test_client() as client:
        yield client

def test_get_users(client):
    response = client.get("/users")
    assert response.status_code == 200
    assert isinstance(response.get_json(), list)

def test_create_user(client):
    response = client.post("/users", json={
        "name": "John",
        "email": "john@test.com"
    })
    assert response.status_code == 201
```

## Best Practices

**MUST**:
- Use Blueprints for applications with 3+ routes (modularity)
- Use Flask-SQLAlchemy for database operations
- Validate ALL input (use Marshmallow or Pydantic)
- Use application factory pattern for testing/multiple configs
- Register error handlers for consistent error responses

**SHOULD**:
- Use Flask-JWT-Extended for authentication (NOT custom JWT)
- Use `current_app` instead of global `app` in modules
- Use `g` object for request-scoped data
- Use environment variables for config (`.env` file)
- Use context managers for database sessions

**AVOID**:
- Global state (use application factory)
- Manual SQL queries (use ORM)
- Returning different error formats (use error handlers)
- Storing secrets in code (use environment variables)
- Direct access to `request.form` without validation

## Pattern Selection

### Function-Based vs Class-Based Views
**Use function-based views when**:
- Simple logic (< 30 lines)
- Single endpoint
- Quick prototypes

**Use class-based views (MethodView) when**:
- Multiple HTTP methods
- Shared logic between methods
- Need inheritance

```python
# Function-based (simple)
@app.route('/users', methods=['GET'])
def get_users():
    return jsonify(User.query.all())

# Class-based (multiple methods)
from flask.views import MethodView

class UserAPI(MethodView):
    def get(self, user_id):
        return jsonify(User.query.get_or_404(user_id))
    
    def put(self, user_id):
        user = User.query.get_or_404(user_id)
        user.name = request.json['name']
        db.session.commit()
        return jsonify(user)

app.add_url_rule('/users/<int:user_id>', view_func=UserAPI.as_view('user_api'))
```

## Application Factory Pattern

```python
# app/__init__.py
def create_app(config_name='default'):
    app = Flask(__name__)
    app.config.from_object(config[config_name])  # Load config
    
    # Initialize extensions
    db.init_app(app)
    jwt.init_app(app)
    
    # Register blueprints
    from .api import api_bp
    app.register_blueprint(api_bp, url_prefix='/api')
    
    # Register error handlers
    register_error_handlers(app)
    
    return app

# Usage
app = create_app(os.getenv('FLASK_ENV', 'development'))
```

## Common Patterns

### Request Lifecycle
```python
@app.before_request
def before_request():
    g.start_time = time.time()  # Store in request context
    g.user = get_current_user()  # Auth check

@app.after_request
def after_request(response):
    duration = time.time() - g.start_time
    response.headers['X-Process-Time'] = str(duration)
    return response

@app.teardown_appcontext
def teardown_db(exception):
    db = g.pop('db', None)  # Clean up database connection
    if db is not None:
        db.close()
```
