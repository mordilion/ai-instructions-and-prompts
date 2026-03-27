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

```python
# Application Factory
def create_app(config='default'):
    app = Flask(__name__)
    app.config.from_object(f'config.{config}')
    db.init_app(app)
    app.register_blueprint(users_bp, url_prefix='/users')
    return app

# Blueprint
users_bp = Blueprint('users', __name__)

@users_bp.route('', methods=['GET'])
def list_users():
    return jsonify([user.to_dict() for user in User.query.all()])

# Model
class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    email = db.Column(db.String(120), unique=True, nullable=False)
    posts = db.relationship('Post', backref='user')
    
    def to_dict(self):
        return {'id': self.id, 'email': self.email}

# Error Handling
@app.errorhandler(404)
def not_found(error):
    return jsonify({'error': 'Not found'}), 404

# Configuration
class Config:
    SECRET_KEY = os.environ.get('SECRET_KEY', 'dev-secret')
    SQLALCHEMY_DATABASE_URI = os.environ.get('DATABASE_URL')
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
