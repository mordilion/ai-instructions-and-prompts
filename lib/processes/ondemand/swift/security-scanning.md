# Swift Security Scanning - Copy This Prompt

> **Type**: One-time setup process  
> **When to use**: Setting up security scanning for Swift project  
> **Instructions**: Copy the complete prompt below and paste into your AI tool

---

## 📋 Complete Self-Contained Prompt

```
========================================
SWIFT SECURITY SCANNING
========================================

CONTEXT:
You are implementing security scanning for a Swift project.

CRITICAL REQUIREMENTS:
- ALWAYS scan dependencies for vulnerabilities
- ALWAYS integrate security checks in CI
- NEVER ignore critical vulnerabilities
- Use SAST tools (SwiftLint + Snyk)

========================================
CATCH-UP: READ EXISTING DOCUMENTATION
========================================

BEFORE starting, check for existing documentation:
1. Read PROJECT-MEMORY.md, LOGIC-ANOMALIES.md, SECURITY-SETUP.md if they exist

Use this to continue from where work stopped. If no docs: Start fresh.

========================================
PHASE 1 - DEPENDENCY SCANNING
========================================

For CocoaPods projects:

```bash
# Install cocoapods-check
gem install cocoapods-check

# Check for vulnerabilities
pod check
```

For SPM projects, use Snyk:
```bash
snyk test --all-projects
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
    runs-on: macos-latest
    steps:
    - uses: actions/checkout@v4
    
    - name: Install Snyk
      run: npm install -g snyk
    
    - name: Authenticate Snyk
      run: snyk auth ${{ secrets.SNYK_TOKEN }}
    
    - name: Scan dependencies
      run: snyk test --all-projects --severity-threshold=high
```

Deliverable: Dependency scanning active

========================================
PHASE 2 - SAST SCANNING
========================================

Configure SwiftLint with security rules:

Create .swiftlint.yml:
```yaml
opt_in_rules:
  - force_unwrapping
  - implicitly_unwrapped_optional
  - weak_delegate

excluded:
  - Pods
  - Build

force_unwrapping:
  severity: error

implicitly_unwrapped_optional:
  severity: warning
```

Add to Xcode Run Script:
```bash
if which swiftlint >/dev/null; then
  swiftlint --strict
else
  echo "error: SwiftLint not installed"
  exit 1
fi
```

Use Snyk Code for SAST:
```yaml
    - name: Run Snyk Code
      uses: snyk/actions/swift@master
      env:
        SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
      with:
        args: --severity-threshold=high
```

Deliverable: SAST scanning configured

========================================
PHASE 3 - SECRETS DETECTION
========================================

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

```swift
// Use Keychain for sensitive data
import Security

func saveToKeychain(key: String, data: Data) {
    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: key,
        kSecValueData as String: data
    ]
    SecItemAdd(query as CFDictionary, nil)
}

// Validate input
func validateUsername(_ username: String) -> Bool {
    let pattern = "^[a-zA-Z0-9]{3,50}$"
    let regex = try? NSRegularExpression(pattern: pattern)
    return regex?.firstMatch(in: username, range: NSRange(username.startIndex..., in: username)) != nil
}

// Use CryptoKit for hashing
import CryptoKit

let hash = SHA256.hash(data: data)

// Prevent force unwrapping
guard let user = user else { return }

// Use HTTPS only
let url = URL(string: "https://api.example.com")!

// Certificate pinning
let session = URLSession(configuration: .default, 
                        delegate: self, 
                        delegateQueue: nil)

// Implement URLSessionDelegate
func urlSession(_ session: URLSession, 
               didReceive challenge: URLAuthenticationChallenge,
               completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
    // Implement certificate pinning
}
```

Deliverable: Security best practices implemented

========================================
BEST PRACTICES
========================================

- Use Snyk for dependency scanning
- Configure SwiftLint with security rules
- Scan for secrets in commits
- Use Keychain for sensitive data
- Validate all user input
- Use CryptoKit for cryptography
- Avoid force unwrapping
- Implement certificate pinning
- Use HTTPS only
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
CONTINUE: Configure SwiftLint (Phase 2)
CONTINUE: Add secrets detection (Phase 3)
CONTINUE: Implement security practices (Phase 4)
FINISH: Update all documentation files
REMEMBER: Never ignore critical vulnerabilities, document for catch-up
```

---

## Quick Reference

**What you get**: Automated security scanning with Snyk and SwiftLint  
**Time**: 2 hours  
**Output**: Security CI workflow, SAST integration, best practices
