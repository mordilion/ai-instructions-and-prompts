# .NET Security Scanning - Copy This Prompt

> **Type**: One-time setup process  
> **When to use**: Setting up security scanning for .NET project  
> **Instructions**: Copy the complete prompt below and paste into your AI tool

---

## 📋 Complete Self-Contained Prompt

```
========================================
.NET SECURITY SCANNING
========================================

CONTEXT:
You are implementing security scanning for a .NET project.

CRITICAL REQUIREMENTS:
- ALWAYS scan dependencies for vulnerabilities
- ALWAYS integrate security checks in CI
- NEVER ignore critical vulnerabilities
- Use SAST tools (dotnet list package --vulnerable + Security Code Scan)

========================================
CATCH-UP: READ EXISTING DOCUMENTATION
========================================

BEFORE starting, check for existing documentation:
1. Read PROJECT-MEMORY.md, LOGIC-ANOMALIES.md, SECURITY-SETUP.md if they exist

Use this to continue from where work stopped. If no docs: Start fresh.

========================================
PHASE 1 - DEPENDENCY SCANNING
========================================

Use built-in .NET tools:

```bash
# Check for vulnerable packages
dotnet list package --vulnerable

# Check for deprecated packages
dotnet list package --deprecated

# Check for outdated packages
dotnet list package --outdated
```

Add to .github/workflows/security.yml:
```yaml
name: Security Scan

on:
  schedule:
    - cron: '0 0 * * 1'
  push:
    branches: [ main ]

jobs:
  security:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - uses: actions/setup-dotnet@v3
      with:
        dotnet-version: '8.0.x'
    
    - name: Restore
      run: dotnet restore
    
    - name: Check vulnerabilities
      run: dotnet list package --vulnerable --include-transitive || exit 1
```

Deliverable: Dependency scanning active

========================================
PHASE 2 - SAST SCANNING
========================================

Install Security Code Scan:

```bash
dotnet add package SecurityCodeScan.VS2019
```

Or use Snyk:
```bash
npm install -g snyk
snyk auth
snyk test --all-projects
```

Add to GitHub Actions:
```yaml
    - name: Run Snyk
      uses: snyk/actions/dotnet@master
      env:
        SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
      with:
        args: --severity-threshold=high
```

Use SonarQube/SonarCloud:
```yaml
    - name: SonarCloud Scan
      uses: SonarSource/sonarcloud-github-action@master
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
```

Deliverable: SAST scanning configured

========================================
PHASE 3 - SECRETS DETECTION
========================================

Use TruffleHog:

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

```csharp
// Use Data Protection API
services.AddDataProtection()
    .PersistKeysToFileSystem(new DirectoryInfo(@"./keys"))
    .ProtectKeysWithCertificate(cert);

// Validate input
public class UserInput
{
    [Required]
    [StringLength(100, MinimumLength = 3)]
    [RegularExpression(@"^[a-zA-Z0-9]+$")]
    public string Username { get; set; }
}

// Use parameterized queries (EF Core does this automatically)
var user = await _context.Users
    .Where(u => u.Email == email)
    .FirstOrDefaultAsync();

// Secure password hashing
using Microsoft.AspNetCore.Identity;
var hasher = new PasswordHasher<User>();
var hash = hasher.HashPassword(user, password);

// Use HTTPS
services.AddHttpsRedirection(options =>
{
    options.RedirectStatusCode = StatusCodes.Status308PermanentRedirect;
    options.HttpsPort = 443;
});

// Add security headers
app.UseHsts();
app.UseHttpsRedirection();
```

Deliverable: Security best practices implemented

========================================
BEST PRACTICES
========================================

- Run dotnet list package --vulnerable regularly
- Use Security Code Scan or Snyk
- Scan for secrets in commits
- Use Data Protection API for sensitive data
- Validate and sanitize all input
- Use parameterized queries (EF Core)
- Hash passwords with Identity
- Enable HTTPS and security headers
- Keep dependencies up to date

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

**What you get**: Automated security scanning with NuGet vulnerability checks  
**Time**: 2 hours  
**Output**: Security CI workflow, SAST integration, best practices
