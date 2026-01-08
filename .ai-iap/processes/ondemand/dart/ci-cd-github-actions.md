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
CATCH-UP: READ EXISTING DOCUMENTATION
========================================

BEFORE starting, check for existing documentation:

1. Read PROJECT-MEMORY.md if it exists:
   - Dart/Flutter version used
   - CI/CD setup decisions
   - Deployment target
   - Lessons learned

2. Read LOGIC-ANOMALIES.md if it exists:
   - Build/deployment issues found
   - Configuration problems
   - Areas needing attention

3. Read CI-CD-SETUP.md if it exists:
   - Current pipeline configuration
   - Workflows already set up
   - Secrets configured

Use this information to:
- Continue from where previous work stopped
- Maintain consistency with existing setup
- Avoid recreating existing workflows
- Build upon existing pipelines

If no docs exist: Start fresh and create them.

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
DOCUMENTATION
========================================

Create/update these files for team catch-up:

**PROJECT-MEMORY.md** (Universal):
```markdown
# CI/CD Implementation Memory

## Detected Versions
- Dart/Flutter: {version from pubspec.yaml}

## Pipeline Choices
- CI Tool: GitHub Actions
- Runners: ubuntu-latest
- Why: {reasons}

## Key Decisions
- Workflows: .github/workflows/
- Caching: pub cache
- Deployment: {target if any}

## Lessons Learned
- {Challenges}
- {Solutions}
\```

**LOGIC-ANOMALIES.md** (Universal):
```markdown
# Logic Anomalies Found

## Build/Deploy Issues
1. **File**: {workflow file}
   **Issue**: Description
   **Impact**: Severity
   **Note**: Logged for resolution

## Configuration Problems
- {Areas needing attention}
\```

**CI-CD-SETUP.md** (Process-specific):
```markdown
# CI/CD Setup Guide

## Quick Start
\```bash
# Test workflow locally (if using act)
act push

# Trigger manually
gh workflow run ci.yml
\```

## Pipeline Configuration
- Main workflow: .github/workflows/ci.yml
- Dart/Flutter version: {version}
- Cache: pub dependencies

## Workflows
- **ci.yml**: Analyze, test, build

## Secrets Required
- None for basic CI
- Add if deploying:
  - DEPLOY_KEY
  - FIREBASE_TOKEN (if using Firebase)

## Troubleshooting
- **Flutter version mismatch**: Check pubspec.yaml
- **Cache issues**: Clear cache in Actions UI
- **Build fails**: Test locally first

## Maintenance
- Update Flutter: Edit pubspec.yaml and workflow
- Monitor runs: Actions tab in GitHub
\```

========================================
EXECUTION
========================================

START: Read existing docs (CATCH-UP section)
CONTINUE: Create basic CI pipeline (Phase 1)
CONTINUE: Add quality checks (Phase 2)
OPTIONAL: Add builds (Phase 3)
FINISH: Update all documentation files
REMEMBER: Detect version from pubspec.yaml, use caching, document for catch-up
```

---

## Quick Reference

**What you get**: Complete CI/CD pipeline with testing, analysis, and builds  
**Time**: 1-2 hours  
**Output**: .github/workflows/ci.yml with automated checks
