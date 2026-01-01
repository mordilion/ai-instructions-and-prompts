# Code Coverage Setup (PHP)

> **Goal**: Establish automated code coverage tracking in existing PHP projects

## Phase 1: Choose Code Coverage Tools

> **ALWAYS**: Track line, branch, and function coverage
> **ALWAYS**: Set minimum coverage thresholds
> **NEVER**: Aim for 100% coverage (diminishing returns)
> **NEVER**: Skip uncovered critical paths

### Recommended Tools

| Tool | Type | Use Case | Setup |
|------|------|----------|-------|
| **PHPUnit (built-in)** ⭐ | Test runner + coverage | Industry standard | `composer require --dev phpunit/phpunit` |
| **PCOV** ⭐ | Coverage driver | Fast, modern | `pecl install pcov` |
| **Xdebug** | Coverage driver | Feature-rich | `pecl install xdebug` |
| **Codecov** | Reporting | CI/CD integration | Cloud service |

---

## Phase 2: Coverage Tool Configuration

### PHPUnit with PCOV (Recommended)

```bash
# Install PCOV (faster than Xdebug)
pecl install pcov

# Install PHPUnit
composer require --dev phpunit/phpunit

# Run tests with coverage
vendor/bin/phpunit --coverage-html coverage --coverage-clover coverage.xml
```

**Configuration** (`phpunit.xml`):
```xml
<?xml version="1.0" encoding="UTF-8"?>
<phpunit xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:noNamespaceSchemaLocation="vendor/phpunit/phpunit/phpunit.xsd"
         bootstrap="vendor/autoload.php"
         colors="true"
         failOnRisky="true"
         failOnWarning="true">
    <testsuites>
        <testsuite name="Unit">
            <directory>tests/Unit</directory>
        </testsuite>
        <testsuite name="Feature">
            <directory>tests/Feature</directory>
        </testsuite>
    </testsuites>
    
    <coverage processUncoveredFiles="true">
        <include>
            <directory suffix=".php">src</directory>
        </include>
        <exclude>
            <directory suffix=".php">src/Migrations</directory>
            <directory suffix=".php">src/Console</directory>
            <file>src/bootstrap.php</file>
        </exclude>
        <report>
            <html outputDirectory="coverage/html"/>
            <clover outputFile="coverage/clover.xml"/>
            <text outputFile="php://stdout" showUncoveredFiles="false"/>
        </report>
    </coverage>
</phpunit>
```

---

## Phase 3: Coverage Thresholds & Reporting

### PHPUnit Thresholds

**Configuration** (`phpunit.xml`):
```xml
<coverage processUncoveredFiles="true">
    <include>
        <directory suffix=".php">src</directory>
    </include>
    <report>
        <html outputDirectory="coverage/html"/>
        <clover outputFile="coverage/clover.xml"/>
    </report>
    <thresholds>
        <line min="80"/>
        <branch min="75"/>
        <function min="80"/>
    </thresholds>
</coverage>
```

### PCOV Configuration

```ini
; php.ini or .user.ini
pcov.enabled = 1
pcov.directory = /path/to/project/src
pcov.exclude = "~vendor~"
```

### Exclude Code from Coverage

```php
<?php

// Exclude class
/** @codeCoverageIgnore */
class LegacyClass { }

// Exclude method
class MyClass {
    /** @codeCoverageIgnore */
    public function legacyMethod() { }
}

// Exclude lines
// @codeCoverageIgnoreStart
function debug() {
    var_dump('Debug');
}
// @codeCoverageIgnoreEnd
```

---

## Phase 4: CI/CD Integration

### GitHub Actions

```yaml
# .github/workflows/test.yml
name: Test & Coverage

on:
  push:
    branches: [main, develop]
  pull_request:

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup PHP
        uses: shivammathur/setup-php@v2
        with:
          php-version-file: 'composer.json'
          extensions: pcov, mbstring, xml
          coverage: pcov
          tools: composer
      
      - name: Install dependencies
        run: composer install --prefer-dist --no-progress
      
      - name: Run tests with coverage
        run: vendor/bin/phpunit --coverage-clover coverage.xml --coverage-html coverage/html
      
      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v4
        with:
          token: ${{ secrets.CODECOV_TOKEN }}
          files: ./coverage.xml
          fail_ci_if_error: true
      
      - name: Archive coverage report
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: coverage-report
          path: coverage/html/
```

---

## Phase 5: Coverage Analysis & Improvement

### Identify Uncovered Code

```bash
# Generate HTML report
vendor/bin/phpunit --coverage-html coverage/html

# Open report
open coverage/html/index.html
```

### Prioritize Critical Paths

**Coverage priorities (high to low)**:
1. Business logic (services, domain)
2. Data validation (form requests, validators)
3. Error handling
4. API controllers
5. Repositories

### Laravel-Specific Considerations

```php
// Exclude generated code
// phpunit.xml
<exclude>
    <directory suffix=".php">database/migrations</directory>
    <directory suffix=".php">bootstrap/cache</directory>
    <directory suffix=".php">storage</directory>
</exclude>

// Test example with coverage
/** @test */
public function it_validates_user_input()
{
    $service = new UserService();
    $result = $service->validateInput(['email' => 'test@example.com']);
    $this->assertTrue($result);
}
```

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| **Coverage reports empty** | Enable PCOV or Xdebug in `php.ini` |
| **Slow test runs** | Use PCOV instead of Xdebug (3-5x faster) |
| **Memory limit errors** | Increase: `php -d memory_limit=1G vendor/bin/phpunit` |
| **CI fails on threshold** | Review uncovered code, add tests or adjust threshold |

---

## Best Practices

> **ALWAYS**: Set realistic thresholds (70-85% is good)
> **ALWAYS**: Use PCOV for faster coverage (CI/CD)
> **ALWAYS**: Exclude migrations, generated code
> **ALWAYS**: Review coverage reports before merge
> **NEVER**: Aim for 100% (diminishing returns)
> **NEVER**: Write tests just to increase coverage
> **NEVER**: Skip business logic tests

---

## AI Self-Check

- [ ] PHPUnit configured for coverage?
- [ ] PCOV or Xdebug installed?
- [ ] Coverage thresholds set (80% line, 75% branch)?
- [ ] CI/CD runs coverage and fails on threshold violation?
- [ ] Coverage reports uploaded to Codecov/Coveralls?
- [ ] Migrations excluded from coverage?
- [ ] HTML reports generated for local review?
- [ ] Team reviews coverage reports?
- [ ] `@codeCoverageIgnore` used appropriately?
- [ ] Uncovered critical code identified and tested?

---

## Coverage Metrics Explained

| Metric | Definition | Target |
|--------|------------|--------|
| **Line Coverage** | % of lines executed | 80-85% |
| **Branch Coverage** | % of if/else branches executed | 75-80% |
| **Method Coverage** | % of methods called | 80-85% |

---

## Tools Comparison

| Tool | Speed | Setup | CI/CD | Best For |
|------|-------|-------|-------|----------|
| PHPUnit | Medium | Easy | ✅ | Industry standard |
| PCOV | Fast | Easy | ✅ | CI/CD (fast) |
| Xdebug | Slow | Easy | ⚠️ | Local development |
| Codecov | N/A | Easy | ✅ | Reporting |

