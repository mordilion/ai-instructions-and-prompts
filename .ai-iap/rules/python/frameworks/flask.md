# Flask Framework

> **Scope**: Flask applications  
> **Applies to**: Python files in Flask projects
> **Extends**: python/architecture.md, python/code-style.md

## CRITICAL REQUIREMENTS

> **ALWAYS**: Use blueprints for route organization
> **ALWAYS**: Use application factory pattern
> **ALWAYS**: Use Flask-SQLAlchemy or similar ORM
> **ALWAYS**: Use environment variables for config
> **ALWAYS**: Use proper error handlers
> 
> **NEVER**: Put routes in main app file
> **NEVER**: Use global app instance
> **NEVER**: Hard-code configuration
> **NEVER**: Return raw dictionaries
> **NEVER**: Skip CSRF protection

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

### Blueprint

```python
# app/users/routes.py
from flask import Blueprint, jsonify, request

users_bp = Blueprint('users', __name__)

@users_bp.route('', methods=['GET'])
def list_users():
    users = User.query.all()
    return jsonify([user.to_dict() for user in users])

@users_bp.route('', methods=['POST'])
def create_user():
    data = request.get_json()
    user = User(**data)
    db.session.add(user)
    db.session.commit()
    return jsonify(user.to_dict()), 201
```

### Model

```python
from app import db
from datetime import datetime

class User(db.Model):
    __tablename__ = 'users'
    
    id = db.Column(db.Integer, primary_key=True)
    email = db.Column(db.String(120), unique=True, nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    posts = db.relationship('Post', backref='user', lazy='dynamic')
    
    def to_dict(self):
        return {
            'id': self.id,
            'email': self.email,
            'created_at': self.created_at.isoformat()
        }
```

### Error Handling

```python
@app.errorhandler(404)
def not_found(error):
    return jsonify({'error': 'Not found'}), 404

@app.errorhandler(500)
def internal_error(error):
    db.session.rollback()
    return jsonify({'error': 'Internal server error'}), 500
```

### Configuration

```python
# config.py
import os

class Config:
    SECRET_KEY = os.environ.get('SECRET_KEY') or 'dev-secret'
    SQLALCHEMY_DATABASE_URI = os.environ.get('DATABASE_URL')
    SQLALCHEMY_TRACK_MODIFICATIONS = False

class DevelopmentConfig(Config):
    DEBUG = True

class ProductionConfig(Config):
    DEBUG = False
```

## Common AI Mistakes

| Mistake | ❌ Wrong | ✅ Correct |
|---------|---------|-----------|
| **Global App** | `app = Flask()` at module level | `create_app()` |
| **No Blueprints** | All routes in main | Blueprint per module |
| **Hard-coded Config** | `SECRET_KEY = '123'` | Environment variables |
| **Raw Dict** | `return {'data': x}` | `jsonify()` |

## AI Self-Check

- [ ] Using blueprints?
- [ ] Application factory?
- [ ] Flask-SQLAlchemy?
- [ ] Environment variables?
- [ ] Error handlers?
- [ ] No global app?
- [ ] Using jsonify()?
- [ ] CSRF protection?
- [ ] Database migrations?

## Key Features

| Feature | Purpose |
|---------|---------|
| Application Factory | Testability |
| Blueprints | Route organization |
| Flask-SQLAlchemy | ORM |
| Flask-Migrate | Migrations |
| Error Handlers | Error responses |

## Best Practices

**MUST**: Application factory, blueprints, Flask-SQLAlchemy, env vars, error handlers
**SHOULD**: Flask-Migrate, CSRF protection, Flask-Login, Flask-Marshmallow
**AVOID**: Global app, hard-coded config, raw dict returns, monolithic structure
