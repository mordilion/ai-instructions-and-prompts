# PHP Security Scanning - Copy This Prompt

> **Type**: One-time setup process  
> **When to use**: Setting up security scanning for PHP project  
> **Instructions**: Copy the complete prompt below and paste into your AI tool

---

## 📋 Complete Self-Contained Prompt

```
========================================
PHP SECURITY SCANNING
========================================

CONTEXT:
You are implementing security scanning for a PHP project.

CRITICAL REQUIREMENTS:
- ALWAYS scan dependencies for vulnerabilities (composer audit)
- ALWAYS integrate security checks in CI
- NEVER ignore critical vulnerabilities
- Use SAST tools (Psalm/PHPStan + Snyk)

========================================
CATCH-UP: READ EXISTING DOCUMENTATION
========================================

BEFORE starting, check for existing documentation:
1. Read PROJECT-MEMORY.md, LOGIC-ANOMALIES.md, SECURITY-SETUP.md if they exist

Use this to continue from where work stopped. If no docs: Start fresh.

========================================
PHASE 1 - DEPENDENCY SCANNING
========================================

Use built-in Composer audit:

```bash
# Check for vulnerabilities
composer audit

# Check for outdated packages
composer outdated
```

Add to .github/workflows/security.yml:
```yaml
name: Security Scan

on:
  schedule:
    - cron: '0 0 * * 1'
  push:
    branches: [ main ]

jobs:
  security:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - uses: shivammathur/setup-php@v2
      with:
        php-version: '8.2'
    
    - name: Install dependencies
      run: composer install
    
    - name: Security audit
      run: composer audit || exit 1
```

Deliverable: Dependency scanning active

========================================
PHASE 2 - SAST SCANNING
========================================

Install Psalm or PHPStan:

```bash
composer require --dev vimeo/psalm
# OR
composer require --dev phpstan/phpstan
```

Configure psalm.xml:
```xml
<?xml version="1.0"?>
<psalm
    totallyTyped="false"
    resolveFromConfigFile="true"
>
    <projectFiles>
        <directory name="src" />
        <directory name="app" />
        <ignoreFiles>
            <directory name="vendor" />
        </ignoreFiles>
    </projectFiles>
</psalm>
```

Or phpstan.neon:
```neon
parameters:
    level: 8
    paths:
        - src
        - app
```

Use Snyk:
```yaml
    - name: Run Snyk
      uses: snyk/actions/php@master
      env:
        SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
      with:
        args: --severity-threshold=high
```

Deliverable: SAST scanning configured

========================================
PHASE 3 - SECRETS DETECTION
========================================

Add to GitHub Actions:

```yaml
    - name: Scan for secrets
      uses: trufflesecurity/trufflehog@main
      with:
        path: ./
        base: main
        head: HEAD
```

Deliverable: Secrets scanning active

========================================
PHASE 4 - CODE SECURITY BEST PRACTICES
========================================

Implement security best practices:

```php
// Use parameterized queries
$stmt = $pdo->prepare('SELECT * FROM users WHERE email = :email');
$stmt->execute(['email' => $email]);

// Validate input
use Symfony\Component\Validator\Constraints as Assert;

class User
{
    #[Assert\NotBlank]
    #[Assert\Length(min: 3, max: 50)]
    #[Assert\Regex('/^[a-zA-Z0-9]+$/')]
    private string $username;
}

// Hash passwords
$hashedPassword = password_hash($password, PASSWORD_ARGON2ID);

// Verify password
if (password_verify($inputPassword, $hashedPassword)) {
    // Valid
}

// Prevent XSS
echo htmlspecialchars($userInput, ENT_QUOTES, 'UTF-8');

// Use CSRF protection (Laravel)
@csrf

// Sanitize input
$clean = filter_var($input, FILTER_SANITIZE_EMAIL);

// Use HTTPS
if ($_SERVER['HTTPS'] !== 'on') {
    header('Location: https://' . $_SERVER['HTTP_HOST'] . $_SERVER['REQUEST_URI']);
    exit;
}
```

Deliverable: Security best practices implemented

========================================
BEST PRACTICES
========================================

- Run composer audit regularly
- Use Psalm or PHPStan for static analysis
- Scan with Snyk for vulnerabilities
- Use parameterized queries (PDO/Eloquent)
- Validate input properly
- Hash passwords with Argon2id or Bcrypt
- Escape output to prevent XSS
- Use CSRF protection
- Enforce HTTPS
- Keep dependencies up to date

========================================
DOCUMENTATION
========================================

Create/update: PROJECT-MEMORY.md, LOGIC-ANOMALIES.md, SECURITY-SETUP.md

========================================
EXECUTION
========================================

START: Read existing docs (CATCH-UP section)
CONTINUE: Set up composer audit (Phase 1)
CONTINUE: Add Psalm/PHPStan (Phase 2)
CONTINUE: Add secrets detection (Phase 3)
CONTINUE: Implement security practices (Phase 4)
FINISH: Update all documentation files
REMEMBER: Never ignore critical vulnerabilities, document for catch-up
```

---

## Quick Reference

**What you get**: Automated security scanning with composer audit  
**Time**: 2 hours  
**Output**: Security CI workflow, SAST integration, best practices
