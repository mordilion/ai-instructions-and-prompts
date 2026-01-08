# CI/CD Implementation Process - PHP (GitHub Actions)

> **Purpose**: Establish comprehensive CI/CD pipeline with GitHub Actions for PHP applications

> **Platform**: This guide is for **GitHub Actions**. For GitLab CI, Azure DevOps, CircleCI, or Jenkins, adapt the workflow syntax accordingly.

---

## Prerequisites

> **BEFORE starting**:
> - Working PHP application
> - Git repository with remote (GitHub)
> - Composer configured (composer.json)
> - Tests exist (PHPUnit, Pest)
> - PHP version defined in composer.json

---

## Workflow Adaptation

> **IMPORTANT**: Phases below focus on OBJECTIVES. Use your team's workflow.

---

## Phase 1: Basic CI Pipeline

**Objective**: Establish foundational CI pipeline with build, lint, and test automation

### 1.1 Basic Build & Test Workflow

> **ALWAYS include**:
> - PHP version from project (read from composer.json `require.php` or `platform.php`)
> - Setup with shivammathur/setup-php@v2
> - Composer caching (~/.composer/cache)
> - Install dependencies: `composer install --prefer-dist --no-progress`
> - Run linter (PHP_CodeSniffer, PHP CS Fixer)
> - Run tests with PHPUnit/Pest
> - Collect coverage with Xdebug or PCOV

> **Version Strategy**:
> - **Best**: Use composer.json `require.php` constraint (e.g., "php": "^8.2")
> - **Good**: Use composer.json `platform.php` for CI consistency
> - **Matrix**: Test against multiple versions (8.1, 8.2, 8.3) if library

> **NEVER**:
> - Use `composer install` without `--no-dev` in production
> - Skip autoloader optimization (`--optimize-autoloader`)
> - Ignore PSR standards
> - Run without specifying PHP extensions

**Key Workflow Structure**:
- Trigger: push (main/develop), pull_request
- Jobs: lint → test → build
- Setup: shivammathur/setup-php with extensions (mbstring, xml, ctype, iconv, pdo, etc.)
- Cache: Composer dependencies

### 1.2 Coverage Reporting

> **ALWAYS**:
> - Use PHPUnit with Xdebug or PCOV
> - Generate XML/HTML reports
> - Upload to Codecov/Coveralls
> - Set minimum coverage threshold (80%+)

**Coverage Commands**:
```bash
vendor/bin/phpunit --coverage-text --coverage-clover=coverage.xml
# Or with PCOV: php -d pcov.enabled=1 vendor/bin/phpunit --coverage-xml=coverage
```

**Verify**: Pipeline runs, builds succeed across PHP versions, tests execute with results, coverage report generated, Composer cache working

---

## Phase 2: Code Quality & Security

**Objective**: Add code quality and security scanning to CI pipeline

### 2.1 Code Quality & Security

> **ALWAYS**: phpcs (PSR-12), PHP CS Fixer, PHPStan/Psalm (level 8+), Dependabot, `composer audit`, CodeQL (php), fail on violations
> **NEVER**: Suppress errors globally

```yaml
# .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: "composer"
    directory: "/"
    schedule: { interval: "weekly" }
```

**Verify**: phpcs/PHPStan pass, Dependabot creates PRs, CodeQL completes

---

## Phase 3: Deployment Pipeline

**Objective**: Automate app deployment to relevant environments/platforms

### 3.1 Environment Configuration

> **ALWAYS**:
> - Define environments: development, staging, production
> - Use GitHub Environments with protection rules
> - Store secrets per environment (.env files as secrets)
> - Never commit .env files

**Protection Rules**: Production (require approval, restrict to main), Staging (auto-deploy on merge to develop), Development (auto-deploy on feature branches)

### 3.2 Build & Optimize

> **ALWAYS**:
> - Install with `composer install --no-dev --optimize-autoloader`
> - Cache config/routes (Laravel: php artisan config:cache)
> - Compile assets (npm run build)
> - Version with Git SHA or semantic version

> **NEVER**: Include vendor/ directory in git, deploy without autoloader optimization, ship development dependencies, forget to clear old caches

**Build Commands**:
```bash
composer install --no-dev --optimize-autoloader --no-interaction
php artisan config:cache # Laravel
php artisan route:cache # Laravel
npm run build # If frontend assets
```

### 3.3 Deployment & Verification

**Platforms**: FTP/SFTP, VPS/SSH, AWS, Azure, Heroku, Laravel Forge, Docker  
**Migrations**: Laravel (`php artisan migrate --force`), Doctrine, Phinx, run before deployment  
**Smoke Tests**: Health check, DB/Redis connectivity, external APIs  
**NEVER**: Auto-run migrations on app boot in production

**Verify**: Deployment succeeds, migrations applied, smoke tests pass

---

## Phase 4: Advanced Features

**Objective**: Add advanced CI/CD capabilities (integration tests, release automation)

### 4.1 Advanced Testing & Automation

**Performance**: k6/Apache Bench/Gatling, Xdebug/Blackfire profiling, fail if degrades >10%  
**Integration**: Separate workflow, Docker containers, run nightly  
**Release**: semantic-release/tags, CHANGELOG, GitHub Releases, Packagist (libraries)  
**NEVER**: Use production DBs, run integration on every PR

### 4.2 Notifications

> **ALWAYS**: Slack/Teams webhook on deploy success/failure, GitHub Status Checks for PR reviews, Email notifications for security alerts

**Verify**: Performance tests run and tracked, integration tests pass in isolation, releases created automatically, Packagist auto-updates (if applicable), notifications received

---

## Framework-Specific Notes

| Framework | Notes |
|-----------|-------|
| **Laravel** | Cache: `php artisan config:cache`, `route:cache`, `view:cache`; Queue: `php artisan queue:work` (use Supervisor); Migrations: `php artisan migrate --force`; Health: Laravel built-in health checks |
| **Symfony** | Cache: `php bin/console cache:clear --env=prod`; Assets: `php bin/console assets:install --env=prod`; Migrations: `php bin/console doctrine:migrations:migrate --no-interaction`; Health: FOSHealthCheckBundle |
| **WordPress** | Use Composer for plugin/theme dependencies; Deploy with wp-cli; Use WP-CLI for cache clearing; Avoid committing wp-content/uploads/ |

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| **Composer install fails with memory limit** | Increase memory: `php -d memory_limit=-1 $(which composer) install` |
| **Tests pass locally but fail in CI** | Check .env.testing, database config, file permissions |
| **Coverage not collected** | Install Xdebug or PCOV, verify phpunit.xml coverage config |
| **Deployment fails with permission error** | Set correct ownership (www-data), chmod storage/ and bootstrap/cache/ |
| **Migrations fail with timeout** | Increase timeout, optimize migrations, check database connection |

---

## AI Self-Check

- [ ] CI pipeline runs on push and PR
- [ ] PHP version pinned or matrix tested
- [ ] Composer dependencies cached
- [ ] All tests pass with coverage ≥80%
- [ ] Code quality tools enabled (phpcs, PHPStan)
- [ ] Security scanning enabled (CodeQL, Dependabot, composer audit)
- [ ] Build optimized (--no-dev, --optimize-autoloader)
- [ ] Deployment to at least one environment works
- [ ] Database migrations tested and automated
- [ ] Smoke tests validate deployment health

---

## Documentation Updates

> **AFTER all phases complete**:
> - Update README.md with CI/CD badges
> - Document deployment process
> - Add runbook for common issues
> - Onboarding guide for new developers

---

## Final Commit

```bash
git checkout main
git merge ci/advanced
git tag -a v1.0.0-ci -m "CI/CD pipeline implemented"
git push origin main --tags
```

---

**Process Complete** ✅
