# Flask Framework

> **Scope**: Apply these rules when working with Flask applications
> **Applies to**: Python files in Flask projects
> **Extends**: python/architecture.md, python/code-style.md
> **Precedence**: Framework rules OVERRIDE Python rules for Flask-specific patterns

## CRITICAL REQUIREMENTS (AI: Verify ALL before generating code)

> **ALWAYS**: Use blueprints for route organization
> **ALWAYS**: Use application factory pattern
> **ALWAYS**: Use Flask-SQLAlchemy or similar ORM
> **ALWAYS**: Use environment variables for configuration
> **ALWAYS**: Use proper error handlers
> 
> **NEVER**: Put routes in main app file (use blueprints)
> **NEVER**: Use global app instance (use app factory)
> **NEVER**: Hard-code configuration (use config objects)
> **NEVER**: Return raw dictionaries (use jsonify)
> **NEVER**: Skip CSRF protection for forms

## Pattern Selection

| Pattern | Use When | Keywords |
|---------|----------|----------|
| Application Factory | Always | `create_app()` function |
| Blueprints | Route organization | `Blueprint()`, modular |
| Flask-SQLAlchemy | Database ORM | `db.Model`, migrations |
| Flask-Marshmallow | Serialization | Schema validation |
| Flask-Login | Authentication | User session management |

## Core Patterns

### Application Factory
```python
# app/__init__.py
from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate

db = SQLAlchemy()
migrate = Migrate()

def create_app(config_name='default'):
    app = Flask(__name__)
    app.config.from_object(f'config.{config_name}')
    
    db.init_app(app)
    migrate.init_app(app, db)
    
    from app.users import users_bp
    app.register_blueprint(users_bp, url_prefix='/users')
    
    return app
```

### Blueprint Organization
```python
# app/users/routes.py
from flask import Blueprint, jsonify, request
from app.models import User
from app import db

users_bp = Blueprint('users', __name__)

@users_bp.route('/', methods=['GET'])
def get_users():
    users = User.query.all()
    return jsonify([user.to_dict() for user in users])

@users_bp.route('/', methods=['POST'])
def create_user():
    data = request.get_json()
    user = User(name=data['name'], email=data['email'])
    db.session.add(user)
    db.session.commit()
    return jsonify(user.to_dict()), 201

@users_bp.route('/<int:id>', methods=['GET'])
def get_user(id):
    user = User.query.get_or_404(id)
    return jsonify(user.to_dict())
```

### Model with SQLAlchemy
```python
# app/models.py
from app import db
from datetime import datetime

class User(db.Model):
    __tablename__ = 'users'
    
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    posts = db.relationship('Post', backref='author', lazy='dynamic')
    
    def to_dict(self):
        return {
            'id': self.id,
            'name': self.name,
            'email': self.email,
            'created_at': self.created_at.isoformat()
        }
```

### Configuration
```python
# config.py
import os

class Config:
    SECRET_KEY = os.environ.get('SECRET_KEY') or 'dev-secret-key'
    SQLALCHEMY_DATABASE_URI = os.environ.get('DATABASE_URL')
    SQLALCHEMY_TRACK_MODIFICATIONS = False

class DevelopmentConfig(Config):
    DEBUG = True

class ProductionConfig(Config):
    DEBUG = False

config = {
    'development': DevelopmentConfig,
    'production': ProductionConfig,
    'default': DevelopmentConfig
}
```

## Common AI Mistakes (DO NOT MAKE THESE ERRORS)

| Mistake | ❌ Wrong | ✅ Correct | Why Critical |
|---------|---------|-----------|--------------|
| **No App Factory** | Global `app = Flask(__name__)` | `create_app()` function | Not testable, inflexible |
| **No Blueprints** | All routes in one file | Blueprints per module | Unmaintainable |
| **Raw Dicts** | `return {'data': users}` | `return jsonify({'data': users})` | Wrong content-type |
| **Hard-coded Config** | `app.config['KEY'] = 'value'` | Environment variables | Security risk |
| **No Error Handlers** | Default Flask errors | Custom error handlers | Poor UX |

### Anti-Pattern: No Application Factory (NOT TESTABLE)
```python
# ❌ WRONG - Global app instance
from flask import Flask

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://...'  # Hard-coded!

@app.route('/users')
def get_users():
    return {'users': []}

# ✅ CORRECT - Application factory
def create_app(config_name='default'):
    app = Flask(__name__)
    app.config.from_object(config[config_name])
    
    from app.users import users_bp
    app.register_blueprint(users_bp)
    
    return app
```

### Anti-Pattern: No Blueprints (UNMAINTAINABLE)
```python
# ❌ WRONG - All routes in one file
@app.route('/users')
def get_users(): pass

@app.route('/posts')
def get_posts(): pass

@app.route('/comments')
def get_comments(): pass
# ... 50 more routes

# ✅ CORRECT - Blueprints
# users/routes.py
users_bp = Blueprint('users', __name__)
@users_bp.route('/')
def get_users(): pass

# posts/routes.py
posts_bp = Blueprint('posts', __name__)
@posts_bp.route('/')
def get_posts(): pass
```

## AI Self-Check (Verify BEFORE generating Flask code)

- [ ] Using application factory pattern?
- [ ] Blueprints for route organization?
- [ ] Configuration from environment variables?
- [ ] Using Flask-SQLAlchemy for database?
- [ ] Using jsonify for JSON responses?
- [ ] Error handlers defined?
- [ ] CSRF protection enabled?
- [ ] Type hints on functions?
- [ ] Proper status codes (200, 201, 404, etc.)?
- [ ] Following Flask best practices?

## Error Handling

```python
from flask import jsonify

@app.errorhandler(404)
def not_found(error):
    return jsonify({'error': 'Not found'}), 404

@app.errorhandler(500)
def internal_error(error):
    db.session.rollback()
    return jsonify({'error': 'Internal server error'}), 500
```

## Migrations

```bash
# Initialize migrations
flask db init

# Create migration
flask db migrate -m "Add users table"

# Apply migration
flask db upgrade
```

## Key Extensions

| Extension | Purpose | Keywords |
|-----------|---------|----------|
| Flask-SQLAlchemy | ORM | `db.Model`, `db.session` |
| Flask-Migrate | Migrations | `flask db migrate/upgrade` |
| Flask-Login | Authentication | `login_required`, `current_user` |
| Flask-Marshmallow | Serialization | Schema validation |
| Flask-CORS | CORS support | Cross-origin requests |

## Key Features

- **Blueprints**: Modular applications
- **Jinja2**: Template engine
- **Werkzeug**: WSGI toolkit
- **Click**: CLI commands
- **Development Server**: Built-in server
