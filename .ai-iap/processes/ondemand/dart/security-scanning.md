# Security Scanning Setup (Dart/Flutter)

> **Goal**: Establish automated security vulnerability scanning in existing Dart/Flutter projects using SAST/DAST tools

## Phase 1: Choose Security Scanning Tools

> **ALWAYS**: Use at least one SAST (Static) tool
> **ALWAYS**: Run security scans in CI/CD pipeline
> **NEVER**: Skip dependency vulnerability scanning
> **NEVER**: Ignore high/critical vulnerabilities

### Recommended Tools

| Tool | Type | Use Case | Setup |
|------|------|----------|-------|
| **dart pub outdated** ⭐ | Dependency | Built-in, free | `dart pub outdated` |
| **Snyk** ⭐ | SAST + Dependencies | Free for open-source | CLI or plugin |
| **dart analyze** ⭐ | SAST | Built-in linter | `dart analyze` |
| **flutter analyze** | SAST | Flutter-specific | `flutter analyze` |
| **SonarQube/SonarCloud** | SAST | Comprehensive | Cloud or self-hosted |

---

## Phase 2: Dependency Scanning Setup

### Dart Pub Outdated

```bash
# Check for outdated dependencies
dart pub outdated

# Check for security advisories (Flutter 3.3+)
dart pub outdated --show-all

# CI/CD check
dart pub outdated --json
```

### Snyk Setup

```bash
# Install
npm install -g snyk

# Authenticate
snyk auth

# Test Dart project
snyk test --file=pubspec.yaml

# Test Flutter project
snyk test --file=pubspec.yaml --exclude-app-vulns

# Monitor (CI/CD)
snyk monitor
```

**Configuration** (`.snyk`):
```yaml
version: v1.25.0
ignore:
  SNYK-DART-12345:
    - '*':
        reason: 'Not exploitable in our use case'
        expires: '2025-12-31'
```

---

## Phase 3: SAST Configuration

### dart analyze

```bash
# Run analysis
dart analyze

# Run with strict mode
dart analyze --fatal-infos --fatal-warnings

# CI/CD format
dart analyze --format=machine
```

**Configuration** (`analysis_options.yaml`):
```yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
  
  errors:
    missing_required_param: error
    missing_return: error
    todo: ignore
  
  strong-mode:
    implicit-casts: false
    implicit-dynamic: false

linter:
  rules:
    - always_use_package_imports
    - avoid_print
    - avoid_web_libraries_in_flutter
    - cancel_subscriptions
    - close_sinks
    - no_adjacent_strings_in_list
    - prefer_const_constructors
    - prefer_final_fields
    - use_key_in_widget_constructors
    - unsafe_html
```

### Flutter Analyze

```bash
# Run Flutter analysis
flutter analyze

# CI/CD
flutter analyze --no-pub
```

---

## Phase 4: CI/CD Integration

### GitHub Actions

```yaml
# .github/workflows/security.yml
name: Security Scanning

on:
  push:
    branches: [main, develop]
  pull_request:
  schedule:
    - cron: '0 0 * * 1' # Weekly

jobs:
  security-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version-file: '.fvmrc'
          cache: true
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Check for outdated dependencies
        run: dart pub outdated --show-all
        continue-on-error: true
      
      - name: Run dart analyze
        run: dart analyze --fatal-infos --fatal-warnings
      
      - name: Run flutter analyze
        run: flutter analyze
      
      - name: Run Snyk
        run: |
          npm install -g snyk
          snyk auth ${{ secrets.SNYK_TOKEN }}
          snyk test --file=pubspec.yaml --severity-threshold=high
        continue-on-error: true
      
      - name: Check for sensitive data
        run: |
          # Search for potential secrets
          grep -r "api.*key" --include="*.dart" lib/ || true
          grep -r "password" --include="*.dart" lib/ || true
```

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| **dart analyze slow** | Exclude generated files in `analysis_options.yaml` |
| **flutter analyze false positives** | Disable specific rules or add `// ignore` comments |
| **Snyk authentication fails** | Use `snyk auth` or set `SNYK_TOKEN` |
| **CI fails on vulnerabilities** | Use `continue-on-error: true` initially, then enforce |

---

## Best Practices

> **ALWAYS**: Scan dependencies before every release
> **ALWAYS**: Fix high/critical vulnerabilities within 7 days
> **ALWAYS**: Use latest stable Flutter/Dart version
> **ALWAYS**: Update dependencies monthly
> **NEVER**: Commit secrets (use .env, flutter_dotenv)
> **NEVER**: Disable security checks without documentation
> **NEVER**: Use outdated dependencies in production
> **NEVER**: Use `avoid_print` in production (use logging)

---

## AI Self-Check

- [ ] `dart pub outdated` configured in CI/CD?
- [ ] `dart analyze` with strict rules enabled?
- [ ] `flutter analyze` passing?
- [ ] Snyk or equivalent scanner configured?
- [ ] High/critical vulnerabilities addressed?
- [ ] `analysis_options.yaml` with security rules?
- [ ] Secrets excluded from repository?
- [ ] Weekly/monthly security scans scheduled?
- [ ] Flutter/Dart version up-to-date?
- [ ] Dependencies updated regularly?

---

## Security Checklist

**Dependencies:**
- [ ] `dart pub outdated` shows no critical updates
- [ ] Snyk test passing
- [ ] All dependencies up-to-date (within 6 months)

**Code:**
- [ ] `dart analyze` passing (no warnings)
- [ ] No hardcoded secrets (API keys, tokens)
- [ ] Input validation on all user inputs
- [ ] Secure storage for sensitive data (flutter_secure_storage)
- [ ] HTTPS enforced for network requests

**CI/CD:**
- [ ] Security scans on every PR
- [ ] Weekly scheduled scans
- [ ] Fail build on high/critical issues

---

## Tools Comparison

| Tool | Cost | Coverage | CI/CD | Best For |
|------|------|----------|-------|----------|
| dart pub outdated | Free | Dependencies | ✅ | Basic scanning |
| dart analyze | Free | Code patterns | ✅ | Static analysis |
| flutter analyze | Free | Flutter-specific | ✅ | Flutter apps |
| Snyk | Free/Paid | Deps + Code | ✅ | Comprehensive |
| SonarQube | Free/Paid | Comprehensive | ✅ | Enterprise |


## Usage - Copy This Complete Prompt

> **Type**: One-time setup process (simple)  
> **When to use**: When setting up security vulnerability scanning

### Complete Implementation Prompt

```
CONTEXT:
You are configuring security vulnerability scanning for this project.

CRITICAL REQUIREMENTS:
- ALWAYS scan dependencies for known vulnerabilities
- ALWAYS integrate with CI/CD pipeline
- ALWAYS configure to fail on high/critical vulnerabilities
- ALWAYS keep scanning tools updated

IMPLEMENTATION STEPS:

1. CHOOSE SCANNING TOOLS:
   Select tools for the language (see Tech Stack section):
   - Dependency scanning (npm audit, safety, etc.)
   - SAST (CodeQL, Snyk, SonarQube)
   - Container scanning (Trivy, Grype)

2. CONFIGURE DEPENDENCY SCANNING:
   Enable dependency vulnerability scanning
   Set severity thresholds
   Configure auto-fix for known vulnerabilities

3. CONFIGURE SAST:
   Set up static application security testing
   Configure scan rules
   Integrate with CI/CD

4. CONFIGURE CONTAINER SCANNING:
   Scan Docker images for vulnerabilities
   Fail builds on critical issues

5. SET UP MONITORING:
   Configure security alerts
   Set up regular scanning schedule
   Create remediation workflow

DELIVERABLE:
- Dependency scanning active
- SAST integrated
- Container scanning configured
- Security alerts enabled

START: Choose scanning tools and configure dependency scanning.
```
