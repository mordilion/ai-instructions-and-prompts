# PHP Code Coverage - Copy This Prompt

> **Type**: One-time setup process  
> **When to use**: Setting up code coverage for PHP project  
> **Instructions**: Copy the complete prompt below and paste into your AI tool

---

## 📋 Complete Self-Contained Prompt

```
========================================
PHP CODE COVERAGE - XDEBUG/PCOV
========================================

CONTEXT:
You are implementing code coverage measurement for a PHP project using Xdebug or PCOV.

CRITICAL REQUIREMENTS:
- ALWAYS use Xdebug or PCOV for coverage
- NEVER commit coverage reports to Git
- Target 80%+ coverage for critical paths
- Exclude vendor and generated files

========================================
PHASE 1 - LOCAL COVERAGE
========================================

Install coverage driver:
```bash
# Option 1: Xdebug (full-featured)
pecl install xdebug

# Option 2: PCOV (faster, coverage only)
pecl install pcov
```

Add to php.ini:
```ini
; For Xdebug 3
xdebug.mode=coverage

; For PCOV
pcov.enabled=1
```

Update composer.json:
```json
{
  "require-dev": {
    "phpunit/phpunit": "^10.0"
  }
}
```

Run tests with coverage:
```bash
vendor/bin/phpunit --coverage-html coverage
open coverage/index.html
```

Update .gitignore:
```
coverage/
.phpunit.cache/
```

Deliverable: Local coverage report

========================================
PHASE 2 - CONFIGURE EXCLUSIONS
========================================

Create/update phpunit.xml:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<phpunit>
  <coverage>
    <include>
      <directory suffix=".php">src</directory>
    </include>
    <exclude>
      <directory>vendor</directory>
      <directory>src/migrations</directory>
      <file>src/bootstrap.php</file>
    </exclude>
  </coverage>
</phpunit>
```

Deliverable: Proper file exclusions

========================================
PHASE 3 - CI INTEGRATION
========================================

Add to .github/workflows/ci.yml:

```yaml
    - name: Setup PHP with Xdebug
      uses: shivammathur/setup-php@v2
      with:
        php-version: '8.2'
        coverage: xdebug
    
    - name: Test with coverage
      run: vendor/bin/phpunit --coverage-clover coverage.xml
    
    - name: Upload to Codecov
      uses: codecov/codecov-action@v3
      with:
        files: coverage.xml
        fail_ci_if_error: true
```

Deliverable: CI coverage reporting

========================================
PHASE 4 - COVERAGE ENFORCEMENT
========================================

Update phpunit.xml:
```xml
<coverage>
  <report>
    <clover outputFile="coverage.xml"/>
  </report>
</coverage>
```

Add script to composer.json:
```json
{
  "scripts": {
    "test:coverage": [
      "phpunit --coverage-text --coverage-clover=coverage.xml",
      "@php -r \"$xml = simplexml_load_file('coverage.xml'); $metrics = $xml->project->metrics; $coverage = ($metrics['coveredstatements'] / $metrics['statements']) * 100; if ($coverage < 80) { echo 'Coverage is ' . number_format($coverage, 2) . '%, minimum is 80%' . PHP_EOL; exit(1); }\""
    ]
  }
}
```

Deliverable: Automated coverage enforcement

========================================
BEST PRACTICES
========================================

- Use PCOV for faster CI (Xdebug for local)
- Exclude vendor and migrations
- Focus on application logic
- Test error handling
- Set minimum thresholds (80%+)
- Review coverage in PRs

========================================
EXECUTION
========================================

START: Install coverage driver (Phase 1)
CONTINUE: Configure exclusions (Phase 2)
CONTINUE: Add CI integration (Phase 3)
OPTIONAL: Add enforcement (Phase 4)
REMEMBER: Exclude vendor, use PCOV for CI
```

---

## Quick Reference

**What you get**: Complete code coverage setup with Xdebug/PCOV  
**Time**: 1 hour  
**Output**: Coverage reports in CI and locally
