# Java CI/CD with GitHub Actions - Copy This Prompt

> **Type**: One-time setup process  
> **When to use**: Setting up CI/CD pipeline for Java project  
> **Instructions**: Copy the complete prompt below and paste into your AI tool

---

## 📋 Complete Self-Contained Prompt

```
========================================
JAVA CI/CD - GITHUB ACTIONS
========================================

CONTEXT:
You are implementing CI/CD pipeline with GitHub Actions for a Java project.

CRITICAL REQUIREMENTS:
- ALWAYS detect Java version from pom.xml or build.gradle
- ALWAYS use caching for Maven/Gradle
- NEVER hardcode secrets in workflows
- Use team's Git workflow

========================================
PHASE 1 - BASIC CI PIPELINE
========================================

Create .github/workflows/ci.yml:

For Maven:
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
        java-version: '17'  # Detect from pom.xml
        distribution: 'temurin'
        cache: 'maven'
    
    - name: Build
      run: mvn clean install -DskipTests
    
    - name: Test
      run: mvn test
    
    - name: Coverage
      run: mvn jacoco:report
    
    - name: Upload coverage
      uses: codecov/codecov-action@v3
      with:
        files: target/site/jacoco/jacoco.xml
```

For Gradle:
```yaml
    - name: Setup Gradle
      uses: gradle/gradle-build-action@v2
    
    - name: Build and Test
      run: ./gradlew build test jacocoTestReport
```

Deliverable: Basic CI pipeline running

========================================
PHASE 2 - CODE QUALITY
========================================

Add to workflow:

```yaml
    - name: Checkstyle
      run: mvn checkstyle:check
    
    - name: SpotBugs
      run: mvn spotbugs:check
    
    - name: Dependency Check
      run: mvn dependency-check:check
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
    - name: Build JAR
      run: mvn clean package -DskipTests
    - name: Deploy
      run: |
        # Deploy to your target environment
```

Deliverable: Automated deployment

========================================
BEST PRACTICES
========================================

- Cache Maven/Gradle dependencies
- Use matrix for multi-version testing
- Collect code coverage with JaCoCo
- Run static analysis tools
- Use semantic versioning
- Set up branch protection

========================================
EXECUTION
========================================

START: Create basic CI pipeline (Phase 1)
CONTINUE: Add quality checks (Phase 2)
OPTIONAL: Add deployment (Phase 3)
REMEMBER: Detect version, use caching
```

---

## Quick Reference

**What you get**: Complete CI/CD pipeline with Maven/Gradle  
**Time**: 1-2 hours  
**Output**: .github/workflows/ci.yml
