# PHP Security

> **Scope**: PHP-specific security practices (Laravel, Symfony, WordPress)
> **Extends**: general/security.md
> **Applies to**: *.php files

## CRITICAL REQUIREMENTS

> **ALWAYS**: Use prepared statements (PDO, Eloquent)
> **ALWAYS**: Hash passwords with password_hash()
> **ALWAYS**: Validate and sanitize ALL user input
> **ALWAYS**: Use HTTPS in production
> **ALWAYS**: Enable CSRF protection
> 
> **NEVER**: Use mysqli_query() with concatenated strings
> **NEVER**: Use md5() or sha1() for passwords
> **NEVER**: Trust \, \, \ directly
> **NEVER**: Use eval() with user input
> **NEVER**: Disable error reporting in development

## 1. Laravel Security

### Configuration

```php
// âœ… CORRECT - .env configuration
APP_ENV=production
APP_DEBUG=false
APP_KEY=base64:...  // Generated via php artisan key:generate

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=your_database
DB_USERNAME=your_username
DB_PASSWORD=your_password

SESSION_DRIVER=redis
SESSION_LIFETIME=120
SESSION_SECURE_COOKIE=true
SESSION_HTTP_ONLY=true
SESSION_SAME_SITE=strict

// âŒ WRONG - Insecure settings
APP_DEBUG=true  // Exposes errors in production!
SESSION_SECURE_COOKIE=false  // Allow HTTP!
```

## AI Self-Check

Before generating PHP code, verify:
- [ ] Prepared statements for all queries?
- [ ] password_hash() for passwords?
- [ ] Input validation on all user data?
- [ ] CSRF tokens enabled?
- [ ] HTTPS enforced?
- [ ] XSS prevention (htmlspecialchars)?
- [ ] File uploads validated?
- [ ] Error reporting disabled in production?
- [ ] Dependencies up-to-date?

---

**PHP Security: Use prepared statements, password_hash(), and framework security features.**
