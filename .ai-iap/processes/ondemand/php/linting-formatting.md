# PHP Linting & Formatting - Copy This Prompt

> **Type**: One-time setup process  
> **When to use**: Setting up linting and code formatting  
> **Instructions**: Copy the complete prompt below and paste into your AI tool

---

## 📋 Complete Self-Contained Prompt

```
========================================
PHP LINTING & FORMATTING
========================================

CONTEXT:
You are setting up linting and code formatting for a PHP project.

CRITICAL REQUIREMENTS:
- ALWAYS use PHP CS Fixer + PHPStan
- NEVER ignore errors without justification
- Use .editorconfig for consistency
- Enforce in CI pipeline

========================================
PHASE 1 - PHP CS FIXER
========================================

Install:
```bash
composer require --dev friendsofphp/php-cs-fixer
```

Create .php-cs-fixer.php:
```php
<?php
$finder = PhpCsFixer\Finder::create()
    ->in(__DIR__)
    ->exclude('vendor')
    ->exclude('storage')
    ->exclude('bootstrap/cache');

return (new PhpCsFixer\Config())
    ->setRules([
        '@PSR12' => true,
        'array_syntax' => ['syntax' => 'short'],
        'ordered_imports' => ['sort_algorithm' => 'alpha'],
        'no_unused_imports' => true,
        'trailing_comma_in_multiline' => true,
    ])
    ->setFinder($finder);
```

Run:
```bash
vendor/bin/php-cs-fixer fix --dry-run --diff
vendor/bin/php-cs-fixer fix
```

Deliverable: PHP CS Fixer configured

========================================
PHASE 2 - PHPSTAN
========================================

Install:
```bash
composer require --dev phpstan/phpstan
```

Create phpstan.neon:
```neon
parameters:
    level: 8
    paths:
        - src
        - tests
    excludePaths:
        - vendor
    ignoreErrors:
        # Add specific ignores if needed
```

Run:
```bash
vendor/bin/phpstan analyse
```

Deliverable: Static analysis enabled

========================================
PHASE 3 - CI INTEGRATION
========================================

Add to .github/workflows/ci.yml:
```yaml
- name: PHP CS Fixer
  run: vendor/bin/php-cs-fixer fix --dry-run --diff

- name: PHPStan
  run: vendor/bin/phpstan analyse --error-format=github
```

Deliverable: Automated checks in CI

========================================
PHASE 4 - PRE-COMMIT HOOKS
========================================

Install:
```bash
composer require --dev brainmaestro/composer-git-hooks
```

Add to composer.json:
```json
{
  "extra": {
    "hooks": {
      "pre-commit": [
        "vendor/bin/php-cs-fixer fix --dry-run",
        "vendor/bin/phpstan analyse"
      ]
    }
  },
  "scripts": {
    "post-install-cmd": "vendor/bin/cghooks add",
    "post-update-cmd": "vendor/bin/cghooks update"
  }
}
```

Deliverable: Pre-commit checks enabled

========================================
BEST PRACTICES
========================================

- Use PHP CS Fixer for formatting
- Use PHPStan at level 8
- Follow PSR-12 standard
- Add pre-commit hooks
- Fail CI on violations
- Exclude vendor directory

========================================
EXECUTION
========================================

START: Add PHP CS Fixer (Phase 1)
CONTINUE: Add PHPStan (Phase 2)
CONTINUE: Add CI checks (Phase 3)
OPTIONAL: Add pre-commit hooks (Phase 4)
REMEMBER: PSR-12, level 8, enforce in CI
```

---

## Quick Reference

**What you get**: Complete linting and formatting setup  
**Time**: 30 minutes  
**Output**: PHP CS Fixer, PHPStan, CI integration
