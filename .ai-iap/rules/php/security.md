# PHP Security

> **Scope**: PHP-specific security (Laravel, Symfony, WordPress)
> **Extends**: General security rules
> **Applies to**: *.php files

## 0. Embedded SQL (when SQL appears inside PHP)
- **ALWAYS**: Use parameterized queries / prepared statements (or a safe ORM). This applies to any SQL you embed in PHP code.
- **NEVER**: Concatenate or interpolate untrusted input into SQL.
- **If** you must select dynamic table/column names: use strict allowlists (do not pass user input through).

## 1. Laravel Security

### Configuration
- **ALWAYS**: `APP_ENV=production`, `APP_DEBUG=false` in production.
- **ALWAYS**: `APP_KEY` generated via `php artisan key:generate`.
- **ALWAYS**: `SESSION_SECURE_COOKIE=true`, `SESSION_HTTP_ONLY=true`, `SESSION_SAME_SITE=strict`.
- **ALWAYS**: Secrets in `.env` (NEVER commit). Use environment vars in production.

### Authentication
- **ALWAYS**: Laravel's built-in auth (`Auth::attempt()`, `Auth::user()`).
- **ALWAYS**: `password_hash(PASSWORD_BCRYPT)` or Laravel's `Hash::make()`.
- **ALWAYS**: Middleware (`auth`, `verified`) for protected routes.

### SQL Injection Prevention
- **ALWAYS**: Eloquent ORM or Query Builder (parameterized).
- **Raw SQL**: `DB::select('SELECT * FROM users WHERE email = ?', [$email])`.
- **NEVER**: String concatenation or interpolation in SQL.

### XSS Prevention
- **ALWAYS**: Blade templates auto-escape (`{{ $variable }}`).
- **NEVER**: `{!! $variable !!}` without sanitization (use HTMLPurifier).

### CSRF Protection
- **ALWAYS**: `@csrf` directive in forms. NEVER disable middleware.

## 2. Symfony Security

### Configuration
- **ALWAYS**: `security.yaml` with encoders (bcrypt/argon2), firewalls, access control.
- **ALWAYS**: `IS_AUTHENTICATED_FULLY` or role-based access control.

### SQL Injection Prevention
- **ALWAYS**: Doctrine ORM or DQL with parameterized queries.
- **NEVER**: String concatenation in queries.

## 3. WordPress Security

### Authentication
- **ALWAYS**: `wp_verify_nonce()` for form submissions.
- **ALWAYS**: `current_user_can()` for capability checks.
- **ALWAYS**: `wp_hash_password()` for password hashing.

### SQL Injection Prevention
- **ALWAYS**: `$wpdb->prepare()` for database queries.
- **NEVER**: Direct `$wpdb->query()` with variables.

### XSS Prevention
- **ALWAYS**: `esc_html()`, `esc_attr()`, `esc_url()` for output.
- **NEVER**: Echo raw user input.

## 4. General PHP Security

### Input Validation
- **ALWAYS**: `filter_var()` with `FILTER_VALIDATE_EMAIL`, `FILTER_VALIDATE_URL`, etc.
- **ALWAYS**: Type declarations (`string`, `int`, `array`) in function signatures.
- **ALWAYS**: Validate and sanitize `$_GET`, `$_POST`, `$_COOKIE`, `$_FILES`.

### File Uploads
- **ALWAYS**: Validate MIME type (`finfo_file()`), extension, size.
- **ALWAYS**: Generate unique filenames (`uniqid()`, `bin2hex(random_bytes())`).
- **ALWAYS**: Store outside webroot or serve via PHP script.

### Session Security
- **ALWAYS**: `session_regenerate_id()` after login.
- **ALWAYS**: Secure session settings (HttpOnly, Secure, SameSite).

### Error Handling
- **ALWAYS**: `display_errors = Off` in production.
- **ALWAYS**: Log errors (`error_log()`). NEVER display to users.

## 5. Dependency Security

- **ALWAYS**: Composer package scanning (`composer audit`).
- **ALWAYS**: Keep dependencies up-to-date.

## AI Self-Check

Before generating PHP code:
- [ ] Prepared statements / ORM (no string concatenation)?
- [ ] `password_hash()` / Laravel `Hash::make()`?
- [ ] Input validation on all user data?
- [ ] CSRF tokens enabled?
- [ ] Blade/Twig auto-escaping (no raw output)?
- [ ] File uploads validated (MIME, size)?
- [ ] HTTPS enforced?
- [ ] Error display disabled in production?
- [ ] Secrets in `.env` (not committed)?
