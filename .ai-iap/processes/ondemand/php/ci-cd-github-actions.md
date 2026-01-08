# PHP CI/CD with GitHub Actions - Copy This Prompt

> **Type**: One-time setup process  
> **When to use**: Setting up CI/CD pipeline for PHP project  
> **Instructions**: Copy the complete prompt below and paste into your AI tool

---

## 📋 Complete Self-Contained Prompt

```
========================================
PHP CI/CD - GITHUB ACTIONS
========================================

CONTEXT:
You are implementing CI/CD pipeline with GitHub Actions for a PHP project.

CRITICAL REQUIREMENTS:
- ALWAYS detect PHP version from composer.json
- ALWAYS use caching for Composer
- NEVER hardcode secrets in workflows
- Use team's Git workflow

========================================
PHASE 1 - BASIC CI PIPELINE
========================================

Create .github/workflows/ci.yml:

```yaml
name: CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Setup PHP
      uses: shivammathur/setup-php@v2
      with:
        php-version: '8.2'  # Detect from composer.json
        extensions: mbstring, xml, ctype, json
        coverage: xdebug
    
    - name: Cache Composer
      uses: actions/cache@v3
      with:
        path: vendor
        key: ${{ runner.os }}-composer-${{ hashFiles('**/composer.lock') }}
    
    - name: Install dependencies
      run: composer install --prefer-dist --no-progress
    
    - name: Test
      run: vendor/bin/phpunit --coverage-clover coverage.xml
    
    - name: Upload coverage
      uses: codecov/codecov-action@v3
      with:
        files: coverage.xml
```

Deliverable: Basic CI pipeline running

========================================
PHASE 2 - CODE QUALITY
========================================

Add to workflow:

```yaml
    - name: PHP CS Fixer
      run: vendor/bin/php-cs-fixer fix --dry-run --diff
    
    - name: PHPStan
      run: vendor/bin/phpstan analyse src tests --level max
    
    - name: Security check
      run: composer audit
```

Deliverable: Automated code quality checks

========================================
PHASE 3 - DEPLOYMENT (Optional)
========================================

Add deployment:

```yaml
  deploy:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    steps:
    - uses: actions/checkout@v4
    - name: Deploy
      uses: appleboy/ssh-action@v0.1.10
      with:
        host: ${{ secrets.HOST }}
        username: ${{ secrets.USERNAME }}
        key: ${{ secrets.SSH_KEY }}
        script: |
          cd /var/www/html
          git pull origin main
          composer install --no-dev --optimize-autoloader
```

Deliverable: Automated deployment

========================================
BEST PRACTICES
========================================

- Cache Composer dependencies
- Use PHPUnit for testing
- Run PHP CS Fixer and PHPStan
- Check for security vulnerabilities
- Use matrix for multi-version testing
- Set up branch protection

========================================
EXECUTION
========================================

START: Create basic CI pipeline (Phase 1)
CONTINUE: Add quality checks (Phase 2)
OPTIONAL: Add deployment (Phase 3)
REMEMBER: Detect version, use caching
```

---

## Quick Reference

**What you get**: Complete CI/CD pipeline with Composer and PHP tooling  
**Time**: 1-2 hours  
**Output**: .github/workflows/ci.yml
