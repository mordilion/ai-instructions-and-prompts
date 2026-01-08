# Dart/Flutter CI/CD with GitHub Actions - Copy This Prompt

> **Type**: One-time setup process  
> **When to use**: Setting up CI/CD pipeline for Dart/Flutter project  
> **Instructions**: Copy the complete prompt below and paste into your AI tool

---

## 📋 Complete Self-Contained Prompt

```
========================================
DART/FLUTTER CI/CD - GITHUB ACTIONS
========================================

CONTEXT:
You are implementing CI/CD pipeline with GitHub Actions for a Dart/Flutter project.

CRITICAL REQUIREMENTS:
- ALWAYS detect Dart/Flutter version from pubspec.yaml
- ALWAYS use caching for dependencies
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
    
    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.16.0'  # Detect from pubspec.yaml
        channel: 'stable'
    
    - name: Cache dependencies
      uses: actions/cache@v3
      with:
        path: |
          ~/.pub-cache
        key: ${{ runner.os }}-pub-${{ hashFiles('**/pubspec.lock') }}
    
    - name: Install dependencies
      run: flutter pub get
    
    - name: Analyze
      run: flutter analyze
    
    - name: Test
      run: flutter test --coverage
    
    - name: Upload coverage
      uses: codecov/codecov-action@v3
      with:
        files: ./coverage/lcov.info
```

Deliverable: Basic CI pipeline running

========================================
PHASE 2 - CODE QUALITY
========================================

Add to workflow:

```yaml
    - name: Format check
      run: dart format --set-exit-if-changed .
    
    - name: Lint
      run: flutter analyze --fatal-infos
```

Deliverable: Automated code quality checks

========================================
PHASE 3 - BUILD (Optional)
========================================

Add build step for Flutter apps:

```yaml
  build-android:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.16.0'
    - run: flutter build apk --release
    - uses: actions/upload-artifact@v3
      with:
        name: android-apk
        path: build/app/outputs/flutter-apk/app-release.apk
  
  build-ios:
    runs-on: macos-latest
    steps:
    - uses: actions/checkout@v4
    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.16.0'
    - run: flutter build ios --release --no-codesign
```

Deliverable: Automated builds

========================================
BEST PRACTICES
========================================

- Use caching for pub dependencies
- Run tests with coverage
- Fail on analyze warnings
- Use matrix strategy for multiple versions
- Store artifacts for debugging
- Set up branch protection rules

========================================
EXECUTION
========================================

START: Create basic CI pipeline (Phase 1)
CONTINUE: Add quality checks (Phase 2)
OPTIONAL: Add builds (Phase 3)
REMEMBER: Detect version from pubspec.yaml, use caching
```

---

## Quick Reference

**What you get**: Complete CI/CD pipeline with testing, analysis, and builds  
**Time**: 1-2 hours  
**Output**: .github/workflows/ci.yml with automated checks
