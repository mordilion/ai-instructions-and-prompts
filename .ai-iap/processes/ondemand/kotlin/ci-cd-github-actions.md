# Kotlin CI/CD with GitHub Actions - Copy This Prompt

> **Type**: One-time setup process  
> **When to use**: Setting up CI/CD pipeline for Kotlin project  
> **Instructions**: Copy the complete prompt below and paste into your AI tool

---

## 📋 Complete Self-Contained Prompt

```
========================================
KOTLIN CI/CD - GITHUB ACTIONS
========================================

CONTEXT:
You are implementing CI/CD pipeline with GitHub Actions for a Kotlin project.

CRITICAL REQUIREMENTS:
- ALWAYS detect Kotlin/Java versions from build.gradle.kts
- ALWAYS use caching for Gradle
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
  build:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Set up JDK
      uses: actions/setup-java@v3
      with:
        java-version: '17'  # Detect from build.gradle.kts
        distribution: 'temurin'
    
    - name: Setup Gradle
      uses: gradle/gradle-build-action@v2
    
    - name: Build
      run: ./gradlew build -x test
    
    - name: Test
      run: ./gradlew test
    
    - name: Coverage
      run: ./gradlew koverXmlReport
    
    - name: Upload coverage
      uses: codecov/codecov-action@v3
      with:
        files: build/reports/kover/report.xml
```

Deliverable: Basic CI pipeline running

========================================
PHASE 2 - CODE QUALITY
========================================

Add to workflow:

```yaml
    - name: Lint
      run: ./gradlew ktlintCheck
    
    - name: Detekt
      run: ./gradlew detekt
```

Deliverable: Automated code quality checks

========================================
PHASE 3 - DEPLOYMENT (Optional)
========================================

Add deployment:

```yaml
  deploy:
    needs: build
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    steps:
    - uses: actions/checkout@v4
    - uses: actions/setup-java@v3
      with:
        java-version: '17'
        distribution: 'temurin'
    - run: ./gradlew shadowJar
    - name: Deploy
      run: |
        # Deploy JAR to target environment
```

Deliverable: Automated deployment

========================================
BEST PRACTICES
========================================

- Cache Gradle dependencies
- Use Kover for coverage
- Run ktlint and detekt
- Use matrix for multi-version testing
- Set up branch protection

========================================
EXECUTION
========================================

START: Create basic CI pipeline (Phase 1)
CONTINUE: Add quality checks (Phase 2)
OPTIONAL: Add deployment (Phase 3)
REMEMBER: Detect versions, use caching
```

---

## Quick Reference

**What you get**: Complete CI/CD pipeline with Gradle and Kotlin tooling  
**Time**: 1-2 hours  
**Output**: .github/workflows/ci.yml
