# Python Security

> **Scope**: Python-specific security (Django, FastAPI, Flask)
> **Extends**: general/security.md
> **Applies to**: *.py files

## 1. Django Security

### Settings
- **ALWAYS**: `DEBUG = False` in production.
- **ALWAYS**: `SECRET_KEY` from environment. NEVER hardcode.
- **ALWAYS**: `ALLOWED_HOSTS` with specific domains (NEVER `['*']`).
- **ALWAYS**: Security middleware enabled (Security, CSRF, Clickjacking, XSS).
- **ALWAYS**: `SECURE_SSL_REDIRECT = True`, `SESSION_COOKIE_SECURE = True`, `CSRF_COOKIE_SECURE = True`.
- **ALWAYS**: `SESSION_COOKIE_HTTPONLY = True`, `SESSION_COOKIE_SAMESITE = 'Strict'`.
- **ALWAYS**: Password validators (min 12 chars, complexity, common password check).

### Authentication
- **ALWAYS**: Django's built-in auth (`authenticate()`, `login()`).
- **ALWAYS**: `@login_required` decorator for protected views.
- **ALWAYS**: `@csrf_protect` on forms. NEVER disable CSRF.

### SQL Injection Prevention
- **ALWAYS**: Django ORM (`.filter()`, `.get()`). Parameterized queries.
- **Raw SQL**: Use parameterized (`User.objects.raw('SELECT * FROM users WHERE email = %s', [email])`).
- **NEVER**: f-strings or `%` formatting in raw SQL.

### XSS Prevention
- **ALWAYS**: Django templates auto-escape by default.
- **NEVER**: `|safe` filter without sanitization (use `bleach` library if needed).

## 2. FastAPI Security

### Input Validation
- **ALWAYS**: Pydantic models with validators (`EmailStr`, `constr(min_length=12)`).
- **ALWAYS**: Custom validators (`@validator`) for complex rules.
- **ALWAYS**: Dependency injection for validation.

### Authentication
- **ALWAYS**: `passlib.context.CryptContext` with `bcrypt` scheme for passwords.
- **ALWAYS**: `python-jose` for JWT with `expiresIn`.
- **ALWAYS**: `HTTPBearer` dependency for token validation.
- **ALWAYS**: Validate JWT on every protected route (`Depends(get_current_user)`).

### SQL Injection Prevention
- **ALWAYS**: SQLAlchemy ORM or parameterized queries (`text()` with bound params).
- **NEVER**: f-strings in SQL (`text(f"SELECT * FROM users WHERE id = {id}")`).

### CORS
- **ALWAYS**: `CORSMiddleware` with specific origins. NEVER `allow_origins=["*"]` with credentials.

## 3. Flask Security

### Configuration
- **ALWAYS**: `SECRET_KEY` from environment.
- **ALWAYS**: `CSRFProtect(app)` for CSRF protection.
- **ALWAYS**: `Talisman(app)` for security headers (HTTPS, HSTS, CSP).
- **ALWAYS**: Secure session cookies (`SESSION_COOKIE_SECURE = True`, `SESSION_COOKIE_HTTPONLY = True`).

### Authentication
- **ALWAYS**: `Flask-Login` for session management.
- **ALWAYS**: `werkzeug.security.generate_password_hash()` / `check_password_hash()`.

## 4. General Python Security

### Dangerous Functions
- **NEVER**: `eval()` or `exec()` with user input (code injection risk).
- **NEVER**: `pickle.loads()` on untrusted data (code execution risk). Use `json.loads()`.
- **NEVER**: `yaml.load()` without `Loader=yaml.SafeLoader`.

### File Operations
- **ALWAYS**: `werkzeug.utils.secure_filename()` for uploads.
- **ALWAYS**: Validate file type (magic bytes), size limit.
- **ALWAYS**: Generate UUID filenames. Store outside webroot.

### Environment Variables
- **ALWAYS**: Validate with Pydantic `BaseSettings` at startup.
- **ALWAYS**: Fail fast if critical vars missing.

### Rate Limiting
- **Flask**: `flask-limiter` with IP-based limits.
- **FastAPI**: `slowapi` with endpoint-specific limits.
- **Config**: Strict on auth endpoints (5/15min).

## 5. Error Handling

- **ALWAYS**: Generic error messages to clients. Log details server-side.
- **NEVER**: Return exception details, stack traces, or SQL errors to clients.
- **Django**: `DEBUG = False` and custom error views.
- **FastAPI**: `@app.exception_handler(Exception)` with generic responses.

## 6. Dependency Security

- **ALWAYS**: `pip-audit`, `safety` for CVE scanning.
- **ALWAYS**: Keep dependencies up-to-date.

## AI Self-Check

Before generating Python code:
- [ ] Django ORM or SQLAlchemy (no f-strings in SQL)?
- [ ] `bcrypt` / `passlib` for passwords?
- [ ] Pydantic validation (FastAPI) or Django forms?
- [ ] HTTPS + secure cookies?
- [ ] CSRF protection enabled?
- [ ] No `eval()`, `exec()`, `pickle.loads()` with user input?
- [ ] `secure_filename()` for uploads?
- [ ] Environment variables validated at startup?
- [ ] CORS specific origins?
- [ ] Rate limiting configured?
