# CI/CD Implementation Process - PHP

> **Purpose**: Establish comprehensive CI/CD pipeline with GitHub Actions for PHP applications

---

## Prerequisites

> **BEFORE starting**:
> - Working PHP application (8.1+ recommended)
> - Git repository with remote (GitHub)
> - Composer configured (composer.json)
> - Tests exist (PHPUnit, Pest)

---

## Phase 1: Basic CI Pipeline

### Branch Strategy
```
main → ci/basic-pipeline
```

### 1.1 Create Workflow Directory

> **ALWAYS**:
> - Create `.github/workflows/` directory
> - Name workflow file `php.yml` or `laravel.yml`

### 1.2 Basic Build & Test Workflow

> **ALWAYS include**:
> - PHP version matrix (8.1, 8.2, 8.3)
> - Setup with shivammathur/setup-php@v2
> - Composer caching (~/.composer/cache)
> - Install dependencies (`composer install --prefer-dist --no-progress`)
> - Run linter (PHP_CodeSniffer, PHP CS Fixer)
> - Run tests with PHPUnit/Pest
> - Collect coverage with Xdebug or PCOV

> **NEVER**:
> - Use `composer install` without `--no-dev` in production
> - Skip autoloader optimization (`--optimize-autoloader`)
> - Ignore PSR standards
> - Run without specifying PHP extensions

**Key Workflow Structure**:
- Trigger: push (main/develop), pull_request
- Jobs: lint → test → build
- Setup: shivammathur/setup-php with extensions
- Cache: Composer dependencies

### 1.3 Coverage Reporting

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

### 1.4 Commit & Verify

> **Git workflow**:
> ```
> git add .github/workflows/
> git commit -m "ci: add basic PHP build and test pipeline"
> git push origin ci/basic-pipeline
> ```

> **Verify**:
> - Pipeline runs on push
> - Builds succeed across PHP versions
> - Tests execute with results
> - Coverage report generated
> - Composer cache working

---

## Phase 2: Code Quality & Security

### Branch Strategy
```
main → ci/quality-security
```

### 2.1 Code Quality Analysis

> **ALWAYS include**:
> - PHP_CodeSniffer (phpcs) with PSR-12 standard
> - PHP CS Fixer for auto-formatting
> - PHPStan or Psalm for static analysis
> - Fail build on violations

> **NEVER**:
> - Suppress errors globally
> - Skip static analysis
> - Allow critical issues in new code

**PHP_CodeSniffer Configuration**:
```xml
<!-- phpcs.xml -->
<?xml version="1.0"?>
<ruleset name="Project">
    <rule ref="PSR12"/>
    <file>src/</file>
    <file>tests/</file>
</ruleset>
```

**PHPStan Configuration**:
```neon
# phpstan.neon
parameters:
    level: 8
    paths:
        - src
        - tests
```

### 2.2 Dependency Security Scanning

> **ALWAYS include**:
> - Dependabot configuration (`.github/dependabot.yml`)
> - Composer audit (`composer audit`)
> - Fail on known vulnerabilities

> **Dependabot Config**:
> - Package ecosystem: composer
> - Schedule: weekly
> - Open PR limit: 5

**Security Commands**:
```bash
composer audit
# Or: local-php-security-checker
```

### 2.3 Static Analysis (SAST)

> **ALWAYS**:
> - Add CodeQL analysis (`.github/workflows/codeql.yml`)
> - Configure language: php (javascript if includes frontend)
> - Run on schedule (weekly) + push to main
> - Review alerts in GitHub Security tab

> **Optional but recommended**:
> - SonarCloud/SonarQube integration
> - Snyk for vulnerability scanning

### 2.4 Commit & Verify

> **Git workflow**:
> ```
> git add .github/dependabot.yml .github/workflows/codeql.yml phpcs.xml phpstan.neon
> git commit -m "ci: add code quality and security scanning"
> git push origin ci/quality-security
> ```

> **Verify**:
> - phpcs, PHPStan run during CI
> - Violations cause build failures
> - Dependabot creates update PRs
> - CodeQL scan completes
> - Vulnerabilities reported

---

## Phase 3: Deployment Pipeline

### Branch Strategy
```
main → ci/deployment
```

### 3.1 Environment Configuration

> **ALWAYS**:
> - Define environments: development, staging, production
> - Use GitHub Environments with protection rules
> - Store secrets per environment (.env files as secrets)
> - Never commit .env files

> **Protection Rules**:
> - Production: require approval, restrict to main branch
> - Staging: auto-deploy on merge to develop
> - Development: auto-deploy on feature branches

### 3.2 Build & Optimize

> **ALWAYS**:
> - Install with `composer install --no-dev --optimize-autoloader`
> - Cache config/routes (Laravel: php artisan config:cache)
> - Compile assets (npm run build)
> - Version with Git SHA or semantic version

> **NEVER**:
> - Include vendor/ directory in git
> - Deploy without autoloader optimization
> - Ship development dependencies
> - Forget to clear old caches

**Build Commands**:
```bash
composer install --no-dev --optimize-autoloader --no-interaction
php artisan config:cache # Laravel
php artisan route:cache # Laravel
npm run build # If frontend assets
```

### 3.3 Deployment Jobs

> **Platform-specific** (choose one or more):

**Shared Hosting (FTP/SFTP)**:
- Use SamKirkland/FTP-Deploy-Action
- Upload via SFTP with SSH keys
- Exclude .git, .env, tests/

**VPS / Dedicated Server**:
- SSH deploy with rsync or scp
- Run deployment script (composer install, migrations)
- Reload PHP-FPM or restart Apache/Nginx

**AWS (Elastic Beanstalk / ECS / Lambda)**:
- Use aws-actions/configure-aws-credentials
- Package application as ZIP or Docker
- Deploy to Elastic Beanstalk or ECS

**Azure (App Service)**:
- Use azure/webapps-deploy@v2
- Upload via FTP or Azure CLI
- Configure PHP version in portal

**Heroku**:
- Use Procfile: `web: vendor/bin/heroku-php-apache2 public/`
- Deploy with Heroku CLI or GitHub integration

**Laravel Forge / Envoyer**:
- Trigger deployment via webhook
- Use Forge/Envoyer API

**Docker Registry**:
- Build Dockerfile (multi-stage: Composer → PHP-FPM/Apache)
- Push to Docker Hub, GHCR
- Deploy to Kubernetes, Docker Swarm

### 3.4 Database Migrations

> **ALWAYS**:
> - Run migrations before app deployment (Laravel: php artisan migrate)
> - Use database versioning (Phinx, Doctrine Migrations, or framework migrations)
> - Test migrations in staging first
> - Create rollback migrations

> **NEVER**:
> - Run migrations on app boot in production
> - Skip migration testing
> - Deploy app before migrations complete

**Migration Commands**:
```bash
# Laravel
php artisan migrate --force

# Doctrine
vendor/bin/doctrine migrations:migrate --no-interaction

# Phinx
vendor/bin/phinx migrate
```

### 3.5 Smoke Tests Post-Deploy

> **ALWAYS include**:
> - Health check endpoint (`/health` or `/api/health`)
> - Database connectivity check
> - Cache (Redis/Memcached) connectivity
> - External API integration check

> **NEVER**:
> - Run full E2E tests in deployment job
> - Block rollback on smoke test failures

### 3.6 Commit & Verify

> **Git workflow**:
> ```
> git add .github/workflows/deploy*.yml
> git commit -m "ci: add deployment pipeline with database migrations"
> git push origin ci/deployment
> ```

> **Verify**:
> - Manual trigger works (workflow_dispatch)
> - Environment secrets accessible
> - Build optimized correctly
> - Deployment succeeds to staging
> - Migrations applied
> - Smoke tests pass
> - Rollback procedure tested

---

## Phase 4: Advanced Features

### Branch Strategy
```
main → ci/advanced
```

### 4.1 Performance Testing

> **ALWAYS**:
> - Load testing with k6, Apache Bench, or Gatling
> - Track response times and memory usage
> - Fail if performance degrades >10%
> - Profile with Blackfire or Xdebug

### 4.2 Integration Testing

> **ALWAYS**:
> - Separate workflow (`integration-tests.yml`)
> - Use Docker containers for database/Redis
> - Run on schedule (nightly) + release tags
> - Separate test database

> **NEVER**:
> - Use real production databases
> - Skip cleanup after tests
> - Run on every PR (too slow)

### 4.3 Release Automation

> **Semantic Versioning**:
> - Use semantic-release or manual tags
> - Generate CHANGELOG from conventional commits
> - Create GitHub Releases with notes
> - Publish to Packagist (if library)

### 4.4 Packagist Publishing

> **If creating Composer package**:
> - Register on Packagist.org
> - Auto-update via GitHub webhook
> - Include README.md, LICENSE
> - Follow semver strictly

> **ALWAYS**:
> - Set name, description, license in composer.json
> - Include autoload configuration
> - Tag releases with semantic version

### 4.5 Notifications

> **ALWAYS**:
> - Slack/Teams webhook on deploy success/failure
> - GitHub Status Checks for PR reviews
> - Email notifications for security alerts

> **NEVER**:
> - Expose webhook URLs in public repos
> - Spam notifications for every commit

### 4.6 Commit & Verify

> **Git workflow**:
> ```
> git add .github/workflows/
> git commit -m "ci: add performance tests, integration tests, and release automation"
> git push origin ci/advanced
> ```

> **Verify**:
> - Performance tests run and tracked
> - Integration tests pass in isolation
> - Releases created automatically
> - Packagist auto-updates (if applicable)
> - Notifications received

---

## Framework-Specific Notes

### Laravel
- Cache: `php artisan config:cache`, `php artisan route:cache`, `php artisan view:cache`
- Queue: `php artisan queue:work` (use Supervisor)
- Migrations: `php artisan migrate --force`
- Health: Laravel built-in health checks or custom route

### Symfony
- Cache: `php bin/console cache:clear --env=prod`
- Assets: `php bin/console assets:install --env=prod`
- Migrations: `php bin/console doctrine:migrations:migrate --no-interaction`
- Health: FOSHealthCheckBundle or custom route

### WordPress
- Use Composer for plugin/theme dependencies
- Deploy with wp-cli for updates
- Use WP-CLI for cache clearing
- Avoid committing wp-content/uploads/

---

## Common Issues & Solutions

### Issue: Composer install fails with memory limit
- **Solution**: Increase memory: `php -d memory_limit=-1 $(which composer) install`

### Issue: Tests pass locally but fail in CI
- **Solution**: Check .env.testing, database config, file permissions

### Issue: Coverage not collected
- **Solution**: Install Xdebug or PCOV, verify phpunit.xml coverage config

### Issue: Deployment fails with permission error
- **Solution**: Set correct ownership (www-data), chmod storage/ and bootstrap/cache/

### Issue: Migrations fail with timeout
- **Solution**: Increase timeout, optimize migrations, check database connection

---

## AI Self-Check

Before completing this process, verify:

- [ ] CI pipeline runs on push and PR
- [ ] PHP version pinned
- [ ] Composer dependencies cached
- [ ] All tests pass with coverage ≥80%
- [ ] Code quality tools enabled (phpcs, PHPStan)
- [ ] Security scanning enabled (CodeQL, Dependabot, composer audit)
- [ ] Dependencies up to date
- [ ] Build optimized (--no-dev, --optimize-autoloader)
- [ ] Deployment to at least one environment works
- [ ] Database migrations tested and automated
- [ ] Environment secrets properly configured
- [ ] Smoke tests validate deployment health
- [ ] Rollback procedure documented
- [ ] Performance tests tracked (if applicable)
- [ ] Notifications configured
- [ ] All workflows have timeout limits
- [ ] Documentation updated (README.md)

---

## Bug Logging

> **ALWAYS log bugs found during CI setup**:
> - Create ticket/issue for each bug
> - Tag with `bug`, `ci`, `infrastructure`
> - **NEVER fix production code during CI setup**
> - Link bug to CI implementation branch

---

## Documentation Updates

> **AFTER all phases complete**:
> - Update README.md with CI/CD badges
> - Document deployment process
> - Add runbook for common issues
> - Link to workflow files
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

