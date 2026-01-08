# Security Scanning Setup (.NET)

> **Goal**: Establish automated security vulnerability scanning in existing .NET projects using SAST/DAST tools

## Phase 1: Choose Security Scanning Tools

> **ALWAYS**: Use at least one SAST (Static) tool
> **ALWAYS**: Run security scans in CI/CD pipeline
> **NEVER**: Skip dependency vulnerability scanning
> **NEVER**: Ignore high/critical vulnerabilities

### Recommended Tools

| Tool | Type | Use Case | Setup |
|------|------|----------|-------|
| **dotnet list package --vulnerable** ⭐ | Dependency | Built-in, free | Built-in CLI |
| **Snyk** ⭐ | SAST + Dependencies | Free for open-source | `dotnet tool install -g snyk` |
| **SonarQube/SonarCloud** | SAST | Comprehensive | Cloud or self-hosted |
| **Security Code Scan** | SAST | Roslyn analyzer | NuGet package |
| **OWASP Dependency-Check** | Dependencies | Multi-language | CLI tool |
| **Semgrep** | SAST | Custom rules | `pip install semgrep` |

---

## Phase 2: Dependency Scanning Setup

### Built-in .NET CLI

```bash
# Check for vulnerable packages
dotnet list package --vulnerable

# Check for outdated packages
dotnet list package --outdated

# Update packages
dotnet add package PackageName
```

**Configuration** (`Directory.Build.props`):
```xml
<Project>
  <PropertyGroup>
    <!-- Enable NuGet audit -->
    <NuGetAudit>true</NuGetAudit>
    <NuGetAuditMode>all</NuGetAuditMode>
    <NuGetAuditLevel>moderate</NuGetAuditLevel>
  </PropertyGroup>
</Project>
```

### Snyk Setup

```bash
# Install
dotnet tool install -g snyk

# Authenticate
snyk auth

# Test project
snyk test --file=MyProject.csproj

# Monitor (CI/CD)
snyk monitor
```

---

## Phase 3: SAST Configuration

### Security Code Scan (Roslyn Analyzer)

```bash
dotnet add package SecurityCodeScan.VS2019
```

**Configuration** (`.editorconfig`):
```ini
[*.{cs,vb}]

# Security Code Scan rules
dotnet_diagnostic.SCS0001.severity = error # Command Injection
dotnet_diagnostic.SCS0002.severity = error # SQL Injection
dotnet_diagnostic.SCS0003.severity = error # XPath Injection
dotnet_diagnostic.SCS0004.severity = error # Certificate Validation
dotnet_diagnostic.SCS0005.severity = error # Weak Random
dotnet_diagnostic.SCS0006.severity = error # Weak Hashing
dotnet_diagnostic.SCS0007.severity = error # XML External Entity
dotnet_diagnostic.SCS0008.severity = error # Cookie without HttpOnly
dotnet_diagnostic.SCS0009.severity = error # Cookie without Secure
dotnet_diagnostic.SCS0010.severity = error # Weak Cipher
dotnet_diagnostic.SCS0011.severity = error # Weak CBC Mode
dotnet_diagnostic.SCS0012.severity = error # Controller Method Security
dotnet_diagnostic.SCS0013.severity = error # CSRF Token Validation
dotnet_diagnostic.SCS0014.severity = error # SQL Injection (Entity Framework)
dotnet_diagnostic.SCS0015.severity = error # Hardcoded Password
dotnet_diagnostic.SCS0016.severity = error # Controller Authorization
dotnet_diagnostic.SCS0017.severity = error # Request Validation
dotnet_diagnostic.SCS0018.severity = error # Path Traversal
dotnet_diagnostic.SCS0019.severity = error # OutputCache Conflict
dotnet_diagnostic.SCS0020.severity = error # SQL Injection (OleDb)
```

### SonarQube Setup (Optional)

```xml
<!-- Directory.Build.props -->
<PropertyGroup>
  <SonarQubeExclude>**/Migrations/**</SonarQubeExclude>
</PropertyGroup>
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
      
      - name: Setup .NET
        uses: actions/setup-dotnet@v4
        with:
          dotnet-version: | 
            ${{ steps.read-version.outputs.version }}
        id: setup-dotnet
      
      - name: Read .NET version from global.json
        id: read-version
        run: echo "version=$(jq -r '.sdk.version' global.json)" >> $GITHUB_OUTPUT
      
      - name: Restore dependencies
        run: dotnet restore
      
      - name: Check for vulnerable packages
        run: dotnet list package --vulnerable --include-transitive
        continue-on-error: true
      
      - name: Run Snyk
        uses: snyk/actions/dotnet@master
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
        with:
          args: --severity-threshold=high
      
      - name: Build with Security analyzers
        run: dotnet build --no-restore --configuration Release
```

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| **NuGet audit not working** | Check .NET SDK version (6.0.300+), enable in Directory.Build.props |
| **Snyk authentication fails** | Use `snyk auth` or set `SNYK_TOKEN` environment variable |
| **Security Code Scan warnings** | Review and fix, or suppress with justification |
| **CI fails on vulnerabilities** | Use `continue-on-error: true` initially, then enforce |

---

## Best Practices

> **ALWAYS**: Scan dependencies before every release
> **ALWAYS**: Fix high/critical vulnerabilities within 7 days
> **ALWAYS**: Use latest stable .NET SDK
> **ALWAYS**: Enable NuGet audit in Directory.Build.props
> **NEVER**: Commit secrets (use User Secrets, Azure Key Vault)
> **NEVER**: Disable security analyzers without documentation
> **NEVER**: Use outdated packages in production

---

## AI Self-Check

- [ ] NuGet audit enabled in Directory.Build.props?
- [ ] Security Code Scan analyzer installed?
- [ ] Snyk or equivalent SAST tool configured?
- [ ] Security scanning in CI/CD pipeline?
- [ ] High/critical vulnerabilities addressed?
- [ ] Secrets in User Secrets or Key Vault?
- [ ] Weekly/monthly security scans scheduled?
- [ ] False positives documented?
- [ ] Team trained on vulnerability triage?
- [ ] .NET SDK up-to-date?

---

## Security Checklist

**Dependencies:**
- [ ] `dotnet list package --vulnerable` passing
- [ ] Snyk test passing
- [ ] All packages up-to-date (within 6 months)

**Code:**
- [ ] Security Code Scan enabled
- [ ] No hardcoded secrets
- [ ] Input validation on all user inputs
- [ ] SQL injection prevention (parameterized queries, EF Core)
- [ ] XSS prevention (Razor encoding, Content Security Policy)

**CI/CD:**
- [ ] Security scans on every PR
- [ ] Weekly scheduled scans
- [ ] Fail build on high/critical issues

---

## Tools Comparison

| Tool | Cost | Coverage | CI/CD | Best For |
|------|------|----------|-------|----------|
| dotnet CLI | Free | Dependencies | ✅ | Basic scanning |
| Snyk | Free/Paid | Deps + Code | ✅ | Comprehensive |
| Security Code Scan | Free | Code patterns | ✅ | Roslyn integration |
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
