# Dart/Flutter Security Scanning - Copy This Prompt

> **Type**: One-time setup process  
> **When to use**: Setting up security scanning for Dart/Flutter project  
> **Instructions**: Copy the complete prompt below and paste into your AI tool

---

## 📋 Complete Self-Contained Prompt

```
========================================
DART/FLUTTER SECURITY SCANNING
========================================

CONTEXT:
You are implementing security scanning for a Dart/Flutter project.

CRITICAL REQUIREMENTS:
- ALWAYS scan dependencies for vulnerabilities
- ALWAYS integrate security checks in CI
- NEVER ignore critical vulnerabilities
- Use SAST tools (built-in dart analyze + Snyk/SonarQube)

========================================
CATCH-UP: READ EXISTING DOCUMENTATION
========================================

BEFORE starting, check for existing documentation:
1. Read PROJECT-MEMORY.md, LOGIC-ANOMALIES.md, SECURITY-SETUP.md if they exist

Use this to continue from where work stopped. If no docs: Start fresh.

========================================
PHASE 1 - DEPENDENCY SCANNING
========================================

Use built-in Dart tools:

```bash
# Check for outdated/vulnerable packages
dart pub outdated

# Check for security advisories
dart pub audit  # Available in Dart 2.19+
```

Add to .github/workflows/security.yml:
```yaml
name: Security Scan

on:
  schedule:
    - cron: '0 0 * * 1'  # Weekly
  push:
    branches: [ main ]

jobs:
  security:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - uses: dart-lang/setup-dart@v1
    
    - name: Install dependencies
      run: dart pub get
    
    - name: Check for vulnerabilities
      run: dart pub audit
```

Deliverable: Dependency scanning active

========================================
PHASE 2 - SAST SCANNING
========================================

Use Snyk for comprehensive scanning:

```bash
# Install Snyk CLI
npm install -g snyk

# Authenticate
snyk auth

# Test for vulnerabilities
snyk test

# Monitor project
snyk monitor
```

Add to GitHub Actions:
```yaml
    - name: Run Snyk
      uses: snyk/actions/dart@master
      env:
        SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
      with:
        args: --severity-threshold=high
```

Alternative: Use dart analyze with security rules:
```yaml
# analysis_options.yaml
analyzer:
  errors:
    avoid_print: error
    avoid_web_libraries_in_flutter: error
  
linter:
  rules:
    - avoid_dynamic_calls
    - avoid_web_libraries_in_flutter
    - secure_pubspec_urls
```

Deliverable: SAST scanning configured

========================================
PHASE 3 - SECRETS DETECTION
========================================

Use git-secrets or TruffleHog:

```bash
# Install TruffleHog
pip install trufflehog3

# Scan repository
trufflehog3 .
```

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

```dart
// Use secure random for sensitive data
import 'dart:math';
final random = Random.secure();

// Sanitize user input
String sanitize(String input) {
  return input.replaceAll(RegExp(r'[<>]'), '');
}

// Use HTTPS only
final client = http.Client();
// Verify URLs start with https://

// Secure storage (Flutter)
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
final storage = FlutterSecureStorage();
await storage.write(key: 'token', value: token);
```

Add security dependencies:
```yaml
dependencies:
  flutter_secure_storage: ^9.0.0
  crypto: ^3.0.3
```

Deliverable: Security best practices implemented

========================================
BEST PRACTICES
========================================

- Run dart pub audit regularly
- Use Snyk for vulnerability detection
- Scan for secrets in commits
- Use flutter_secure_storage for sensitive data
- Validate and sanitize all user input
- Use HTTPS for all network requests
- Keep dependencies up to date
- Review security scan results weekly

========================================
DOCUMENTATION
========================================

Create/update: PROJECT-MEMORY.md, LOGIC-ANOMALIES.md, SECURITY-SETUP.md

========================================
EXECUTION
========================================

START: Read existing docs (CATCH-UP section)
CONTINUE: Set up dependency scanning (Phase 1)
CONTINUE: Add SAST scanning (Phase 2)
CONTINUE: Add secrets detection (Phase 3)
CONTINUE: Implement security practices (Phase 4)
FINISH: Update all documentation files
REMEMBER: Never ignore critical vulnerabilities, document for catch-up
```

---

## Quick Reference

**What you get**: Automated security scanning with dependency checks  
**Time**: 2 hours  
**Output**: Security CI workflow, Snyk integration, best practices
