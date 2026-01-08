# Linting & Formatting Setup (PHP)

> **Goal**: Establish automated code linting and formatting in existing PHP projects

## Phase 1: Choose Linting & Formatting Tools

> **ALWAYS**: Use a linter (code quality) + formatter (code style)
> **ALWAYS**: Run linter/formatter in CI/CD pipeline
> **NEVER**: Mix multiple formatters (choose one)
> **NEVER**: Skip pre-commit hooks

### Recommended Tools

| Tool | Type | Use Case | Setup |
|------|------|----------|-------|
| **PHP_CodeSniffer** ⭐ | Linter | PSR-12 compliance | `composer require --dev squizlabs/php_codesniffer` |
| **PHP-CS-Fixer** ⭐ | Formatter | Auto-fix style | `composer require --dev friendsofphp/php-cs-fixer` |
| **PHPStan** | Linter | Static analysis | `composer require --dev phpstan/phpstan` |
| **Psalm** | Linter | Type safety | `composer require --dev vimeo/psalm` |

---

## Phase 2: Linter Configuration

### PHP_CodeSniffer Setup

```bash
# Install
composer require --dev squizlabs/php_codesniffer

# Check
./vendor/bin/phpcs

# Auto-fix
./vendor/bin/phpcbf
```

**Configuration** (`phpcs.xml`):
```xml
<?xml version="1.0"?>
<ruleset name="Custom">
    <description>Custom PHP CodeSniffer ruleset</description>
    
    <file>src/</file>
    <file>tests/</file>
    
    <exclude-pattern>*/vendor/*</exclude-pattern>
    <exclude-pattern>*/cache/*</exclude-pattern>
    
    <arg name="colors"/>
    <arg value="sp"/>
    
    <rule ref="PSR12"/>
    
    <rule ref="Generic.Files.LineLength">
        <properties>
            <property name="lineLimit" value="120"/>
            <property name="absoluteLineLimit" value="150"/>
        </properties>
    </rule>
</ruleset>
```

### PHPStan Setup

```bash
# Install
composer require --dev phpstan/phpstan

# Run
./vendor/bin/phpstan analyse src tests

# Generate baseline
./vendor/bin/phpstan analyse --generate-baseline
```

**Configuration** (`phpstan.neon`):
```neon
parameters:
    level: 8
    paths:
        - src
        - tests
    excludePaths:
        - src/migrations
    ignoreErrors:
        - '#Call to an undefined method#'
    checkMissingIterableValueType: false
```

---

## Phase 3: Formatter Configuration

### PHP-CS-Fixer Setup

```bash
# Install
composer require --dev friendsofphp/php-cs-fixer

# Format
./vendor/bin/php-cs-fixer fix

# Check formatting
./vendor/bin/php-cs-fixer fix --dry-run --diff
```

**Configuration** (`.php-cs-fixer.php`):
```php
<?php

$finder = PhpCsFixer\Finder::create()
    ->in(__DIR__ . '/src')
    ->in(__DIR__ . '/tests')
    ->exclude('vendor')
    ->exclude('cache');

$config = new PhpCsFixer\Config();
return $config
    ->setRules([
        '@PSR12' => true,
        'array_syntax' => ['syntax' => 'short'],
        'no_unused_imports' => true,
        'ordered_imports' => ['sort_algorithm' => 'alpha'],
        'single_quote' => true,
        'trailing_comma_in_multiline' => true,
        'whitespace_after_comma_in_array' => true,
        'blank_line_before_statement' => [
            'statements' => ['return'],
        ],
    ])
    ->setFinder($finder);
```

---

## Phase 4: IDE Integration & Pre-commit Hooks

### VS Code Setup

**Extensions** (`.vscode/extensions.json`):
```json
{
  "recommendations": [
    "bmewburn.vscode-intelephense-client",
    "junstyle.php-cs-fixer"
  ]
}
```

**Settings** (`.vscode/settings.json`):
```json
{
  "editor.formatOnSave": true,
  "[php]": {
    "editor.defaultFormatter": "junstyle.php-cs-fixer"
  },
  "php-cs-fixer.executablePath": "${workspaceFolder}/vendor/bin/php-cs-fixer",
  "php-cs-fixer.onsave": true
}
```

### Pre-commit Hooks (pre-commit framework)

**Configuration** (`.pre-commit-config.yaml`):
```yaml
repos:
  - repo: local
    hooks:
      - id: php-cs-fixer
        name: PHP CS Fixer
        entry: ./vendor/bin/php-cs-fixer fix --diff
        language: system
        types: [php]
        pass_filenames: false
      
      - id: phpcs
        name: PHP CodeSniffer
        entry: ./vendor/bin/phpcs
        language: system
        types: [php]
      
      - id: phpstan
        name: PHPStan
        entry: ./vendor/bin/phpstan analyse
        language: system
        types: [php]
        pass_filenames: false
```

---

## Phase 5: CI/CD Integration

### GitHub Actions

```yaml
# .github/workflows/lint.yml
name: Lint & Format Check

on:
  push:
    branches: [main, develop]
  pull_request:

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup PHP
        uses: shivammathur/setup-php@v2
        with:
          php-version-file: 'composer.json'
          tools: composer
          coverage: none
      
      - name: Install dependencies
        run: composer install --prefer-dist --no-progress
      
      - name: Run PHP CodeSniffer
        run: ./vendor/bin/phpcs
      
      - name: Run PHP-CS-Fixer Check
        run: ./vendor/bin/php-cs-fixer fix --dry-run --diff
      
      - name: Run PHPStan
        run: ./vendor/bin/phpstan analyse
```

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| **PHPCS fails on existing code** | Run `./vendor/bin/phpcbf` to auto-fix |
| **PHP-CS-Fixer memory limit** | Increase: `php -d memory_limit=1G vendor/bin/php-cs-fixer` |
| **PHPStan false positives** | Add to `ignoreErrors` in `phpstan.neon` or use `@phpstan-ignore-next-line` |
| **CI fails on formatting** | Run `./vendor/bin/php-cs-fixer fix` locally before commit |

---

## Best Practices

> **ALWAYS**: Format code before commit (pre-commit hooks)
> **ALWAYS**: Run linter in CI/CD
> **ALWAYS**: Follow PSR-12 coding standards
> **ALWAYS**: Fix all linter violations before merge
> **NEVER**: Disable linter rules without team discussion
> **NEVER**: Commit code with violations
> **NEVER**: Mix tabs and spaces (use spaces)

---

## AI Self-Check

- [ ] PHP_CodeSniffer configured (PSR-12)?
- [ ] PHP-CS-Fixer installed and configured?
- [ ] PHPStan or Psalm installed?
- [ ] Pre-commit hooks installed?
- [ ] VS Code extensions configured?
- [ ] CI/CD runs linter and formatter checks?
- [ ] All violations fixed?
- [ ] Baseline file used for existing issues?
- [ ] Team trained on PSR-12 standards?
- [ ] Type hints added to functions?

---

## Tools Comparison

| Tool | Type | Speed | Extensibility | Best For |
|------|------|-------|---------------|----------|
| PHP_CodeSniffer | Linter | Medium | ⭐⭐⭐ | PSR compliance |
| PHP-CS-Fixer | Formatter | Fast | ⭐⭐ | Auto-fix |
| PHPStan | Linter | Medium | ⭐⭐⭐ | Static analysis |
| Psalm | Linter | Medium | ⭐⭐⭐ | Type safety |


## Usage - Copy This Complete Prompt

> **Type**: One-time setup process (simple)  
> **When to use**: When setting up code linting and formatting tools

### Complete Implementation Prompt

```
CONTEXT:
You are configuring code linting and formatting for this project.

CRITICAL REQUIREMENTS:
- ALWAYS configure both linting (quality) and formatting (style)
- ALWAYS integrate with pre-commit hooks
- ALWAYS add to CI/CD pipeline
- ALWAYS use consistent configuration across team

IMPLEMENTATION STEPS:

1. CHOOSE TOOLS:
   Select appropriate linter and formatter for the language (see Tech Stack section)

2. CONFIGURE LINTER:
   Create configuration file (.eslintrc, ruff.toml, etc.)
   Set rules (recommended: start with recommended preset)

3. CONFIGURE FORMATTER:
   Create configuration file (if separate from linter)
   Set style rules (indentation, line length, etc.)

4. INTEGRATE WITH EDITOR:
   Configure IDE/editor plugins
   Enable format-on-save

5. ADD PRE-COMMIT HOOKS:
   Install pre-commit hooks (husky, pre-commit, etc.)
   Configure to run linter and formatter

6. ADD TO CI/CD:
   Add linting step to pipeline
   Fail build on linting errors

DELIVERABLE:
- Linter and formatter configured
- Pre-commit hooks active
- CI/CD integration complete

START: Choose tools and create configuration files.
```
