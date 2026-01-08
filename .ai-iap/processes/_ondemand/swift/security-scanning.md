# Security Scanning Setup (Swift)

> **Goal**: Establish automated security vulnerability scanning in existing Swift projects using SAST/DAST tools

## Phase 1: Choose Security Scanning Tools

> **ALWAYS**: Use at least one SAST (Static) tool
> **ALWAYS**: Run security scans in CI/CD pipeline
> **NEVER**: Skip dependency vulnerability scanning
> **NEVER**: Ignore high/critical vulnerabilities

### Recommended Tools

| Tool | Type | Use Case | Setup |
|------|------|----------|-------|
| **Snyk** ⭐ | SAST + Dependencies | Free for open-source | CLI or Xcode plugin |
| **SwiftLint Security** ⭐ | SAST | Code patterns | CocoaPods/SPM |
| **MobSF** | Dynamic | iOS app analysis | Docker |
| **SonarQube/SonarCloud** | SAST | Comprehensive | Cloud or self-hosted |
| **Semgrep** | SAST | Custom rules | `pip install semgrep` |

---

## Phase 2: Dependency Scanning Setup

### Snyk Setup

```bash
# Install
npm install -g snyk

# Authenticate
snyk auth

# Test Swift Package Manager project
snyk test --file=Package.swift

# Test CocoaPods project
snyk test --file=Podfile

# Monitor (CI/CD)
snyk monitor
```

**Configuration** (`.snyk`):
```yaml
version: v1.25.0
ignore:
  SNYK-SWIFT-SWIFT-12345:
    - '*':
        reason: 'Not exploitable in our use case'
        expires: '2025-12-31'
```

### Manual Dependency Audit

```bash
# Check for outdated Swift packages
swift package update --dry-run

# List dependencies
swift package show-dependencies

# CocoaPods outdated check
pod outdated
```

---

## Phase 3: SAST Configuration

### SwiftLint with Security Rules

```ruby
# Podfile
pod 'SwiftLint'
```

**Configuration** (`.swiftlint.yml`):
```yaml
opt_in_rules:
  - force_unwrapping
  - implicitly_unwrapped_optional
  - weak_delegate
  - unowned_variable_capture
  
disabled_rules:
  - line_length  # Adjust as needed

excluded:
  - Pods
  - Tests

force_unwrapping:
  severity: error

weak_delegate:
  severity: warning
```

### Semgrep

```bash
# Install
pip install semgrep

# Run with Swift security rules
semgrep --config=p/swift src/

# CI mode
semgrep ci
```

**Configuration** (`.semgrep.yml`):
```yaml
rules:
  - id: hardcoded-api-key
    pattern: let apiKey = "..."
    message: Hardcoded API key detected
    severity: ERROR
    languages: [swift]
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
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Xcode
        uses: maxim-lobanov/setup-xcode@v1
        with:
          xcode-version-file: '.xcode-version'
      
      - name: Install SwiftLint
        run: brew install swiftlint
      
      - name: Run SwiftLint
        run: swiftlint lint --reporter json > swiftlint-report.json
        continue-on-error: true
      
      - name: Run Snyk
        run: |
          npm install -g snyk
          snyk auth ${{ secrets.SNYK_TOKEN }}
          snyk test --file=Package.swift --severity-threshold=high
        continue-on-error: true
      
      - name: Check for sensitive data
        run: |
          # Search for potential secrets
          grep -r "api.*key" --include="*.swift" . || true
          grep -r "password.*=" --include="*.swift" . || true
      
      - name: Upload SwiftLint report
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: swiftlint-report
          path: swiftlint-report.json
```

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| **SwiftLint false positives** | Add to `.swiftlint.yml` disabled_rules or excluded paths |
| **Snyk authentication fails** | Use `snyk auth` or set `SNYK_TOKEN` |
| **Xcode version mismatch** | Pin Xcode version in `.xcode-version` |
| **CI fails on vulnerabilities** | Use `continue-on-error: true` initially, then enforce |

---

## Best Practices

> **ALWAYS**: Scan dependencies before every release
> **ALWAYS**: Fix high/critical vulnerabilities within 7 days
> **ALWAYS**: Use latest stable Swift version
> **ALWAYS**: Update dependencies monthly
> **NEVER**: Commit secrets (use Keychain, environment variables)
> **NEVER**: Force unwrap optionals without validation
> **NEVER**: Use outdated dependencies in production

---

## AI Self-Check

- [ ] Snyk or equivalent dependency scanner configured?
- [ ] SwiftLint with security rules installed?
- [ ] Security scanning in CI/CD pipeline?
- [ ] High/critical vulnerabilities addressed?
- [ ] No hardcoded secrets in codebase?
- [ ] Weekly/monthly security scans scheduled?
- [ ] Optional unwrapping enforced?
- [ ] Team trained on vulnerability triage?
- [ ] Swift version up-to-date?
- [ ] Dependencies updated regularly?

---

## Security Checklist

**Dependencies:**
- [ ] Snyk test passing
- [ ] All dependencies up-to-date (within 6 months)
- [ ] CocoaPods/SPM vulnerabilities addressed

**Code:**
- [ ] SwiftLint security rules enabled
- [ ] No hardcoded secrets (API keys, tokens)
- [ ] Input validation on all user inputs
- [ ] Safe optional handling (guard, if let, nil coalescing)
- [ ] Keychain used for sensitive data storage

**CI/CD:**
- [ ] Security scans on every PR
- [ ] Weekly scheduled scans
- [ ] Fail build on high/critical issues

---

## Tools Comparison

| Tool | Cost | Coverage | CI/CD | Best For |
|------|------|----------|-------|----------|
| Snyk | Free/Paid | Deps + Code | ✅ | Comprehensive |
| SwiftLint | Free | Code patterns | ✅ | Static analysis |
| MobSF | Free | iOS app | ⚠️ | Dynamic testing |
| SonarQube | Free/Paid | Comprehensive | ✅ | Enterprise |
| Semgrep | Free/Paid | Custom rules | ✅ | Advanced |


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
