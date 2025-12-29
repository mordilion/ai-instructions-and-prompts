# CI/CD Implementation Process - Swift

> **Purpose**: Establish comprehensive CI/CD pipeline with GitHub Actions for Swift applications (iOS, macOS, Server)

---

## Prerequisites

> **BEFORE starting**:
> - Working Swift application (5.7+ recommended)
> - Git repository with remote (GitHub)
> - Xcode project or Package.swift (SPM)
> - Tests exist (XCTest)

---

## Phase 1: Basic CI Pipeline

### Branch Strategy
```
main → ci/basic-pipeline
```

### 1.1 Create Workflow Directory

> **ALWAYS**:
> - Create `.github/workflows/` directory
> - Name workflow file `swift.yml` or `ios.yml`

### 1.2 Basic Build & Test Workflow

> **ALWAYS include**:
> - macOS runner (macos-13, macos-14)
> - Xcode version selection (xcode-select)
> - Build for specific scheme/destination
> - Run tests with xcodebuild or swift test
> - Collect coverage with xcov or xccov

> **NEVER**:
> - Skip code signing setup for iOS
> - Use outdated Xcode versions
> - Ignore SwiftLint warnings
> - Run without specifying destination

**Key Workflow Structure**:
- Trigger: push (main/develop), pull_request
- Runner: macos-latest
- Jobs: lint → test → build
- Xcode: actions/setup-xcode or xcode-select

### 1.3 Coverage Reporting

> **ALWAYS**:
> - Use xccov (built-in) or xcov gem
> - Generate XML/HTML reports
> - Upload to Codecov/Coveralls
> - Set minimum coverage threshold (80%+)

**Coverage Commands**:
```bash
# Xcode project
xcodebuild test -scheme YourScheme -destination 'platform=iOS Simulator,name=iPhone 14' -enableCodeCoverage YES

# Extract coverage
xcrun xccov view --report --json DerivedData/Logs/Test/*.xcresult > coverage.json
```

### 1.4 Commit & Verify

> **Git workflow**:
> ```
> git add .github/workflows/
> git commit -m "ci: add basic Swift build and test pipeline"
> git push origin ci/basic-pipeline
> ```

> **Verify**:
> - Pipeline runs on push
> - Builds succeed on macOS runner
> - Tests execute with results
> - Coverage report generated
> - Build artifacts created

---

## Phase 2: Code Quality & Security

### Branch Strategy
```
main → ci/quality-security
```

### 2.1 Code Quality Analysis

> **ALWAYS include**:
> - SwiftLint for linting and style
> - SwiftFormat (optional but recommended)
> - Fail build on violations

> **NEVER**:
> - Disable SwiftLint rules globally
> - Skip linter configuration
> - Allow warnings in new code

**SwiftLint Configuration**:
```yaml
# .swiftlint.yml
disabled_rules:
  - trailing_whitespace
opt_in_rules:
  - force_unwrapping
  - implicitly_unwrapped_optional
line_length: 120
```

### 2.2 Dependency Security Scanning

> **ALWAYS include**:
> - Dependabot configuration (`.github/dependabot.yml`)
> - Swift Package Manager dependencies only
> - Fail on known vulnerabilities

> **Dependabot Config**:
> - Package ecosystem: swift
> - Schedule: weekly
> - Open PR limit: 5

### 2.3 Static Analysis (SAST)

> **ALWAYS**:
> - Add CodeQL analysis (`.github/workflows/codeql.yml`)
> - Configure language: swift
> - Run on schedule (weekly) + push to main
> - Review alerts in GitHub Security tab

> **Optional but recommended**:
> - SonarCloud integration (with sonar-swift)
> - Periphery for unused code detection

### 2.4 Commit & Verify

> **Git workflow**:
> ```
> git add .github/dependabot.yml .github/workflows/codeql.yml .swiftlint.yml
> git commit -m "ci: add code quality and security scanning"
> git push origin ci/quality-security
> ```

> **Verify**:
> - SwiftLint runs during CI
> - Violations cause build failures
> - Dependabot creates update PRs
> - CodeQL scan completes
> - Vulnerabilities reported

---

## Phase 3: Deployment Pipeline

### Branch Strategy
```
main → ci/deployment
```

### 3.1 Environment Configuration

> **ALWAYS**:
> - Define environments: development, staging, production
> - Use GitHub Environments with protection rules
> - Store secrets (certificates, provisioning profiles, API keys)
> - Use xcconfig files for build configuration

> **Protection Rules**:
> - Production: require approval, restrict to main branch
> - Staging: auto-deploy on merge to develop
> - Development: auto-deploy on feature branches

### 3.2 Code Signing (iOS/macOS)

> **ALWAYS**:
> - Store certificates in GitHub Secrets (base64 encoded)
> - Store provisioning profiles in GitHub Secrets
> - Use Fastlane Match (recommended) or manual cert management
> - Create keychain in CI for signing

> **NEVER**:
> - Commit certificates or profiles to repo
> - Use developer certificates in CI
> - Skip automatic code signing configuration

**Code Signing Setup**:
```bash
# Create keychain
security create-keychain -p "$KEYCHAIN_PASSWORD" build.keychain
security default-keychain -s build.keychain
security unlock-keychain -p "$KEYCHAIN_PASSWORD" build.keychain

# Import certificate
echo "$CERTIFICATE_BASE64" | base64 --decode > certificate.p12
security import certificate.p12 -k build.keychain -P "$CERTIFICATE_PASSWORD" -T /usr/bin/codesign

# Install provisioning profile
mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles
echo "$PROVISIONING_PROFILE_BASE64" | base64 --decode > ~/Library/MobileDevice/Provisioning\ Profiles/profile.mobileprovision
```

### 3.3 Build & Archive

> **ALWAYS**:
> - Archive with xcodebuild archive
> - Export IPA with exportOptionsPlist
> - Version with agvtool or Info.plist
> - Upload artifacts with retention policy

> **NEVER**:
> - Archive without proper code signing
> - Skip build number increment
> - Export without proper export method (app-store, ad-hoc, enterprise)

**Archive Commands**:
```bash
# iOS
xcodebuild archive -scheme YourScheme -archivePath build/App.xcarchive -configuration Release

# Export IPA
xcodebuild -exportArchive -archivePath build/App.xcarchive -exportPath build -exportOptionsPlist ExportOptions.plist
```

### 3.4 Deployment Jobs

> **Platform-specific** (choose one or more):

**App Store (iOS/macOS)**:
- Use Fastlane for deployment
- Actions: deliver, pilot (TestFlight)
- Upload IPA with altool or Transporter
- Submit for review (optional automation)

**TestFlight (Beta)**:
- Use xcrun altool or Fastlane pilot
- Upload IPA: `xcrun altool --upload-app -f App.ipa`
- Set beta review info
- Notify testers automatically

**Vapor Server (Linux)**:
- Build for Linux (Docker or GitHub runner ubuntu-latest with Swift)
- Package as executable
- Deploy to AWS, Azure, GCP, or Heroku

**Docker Registry (Vapor)**:
- Build multi-stage Dockerfile
- Push to Docker Hub, GHCR
- Tag with git SHA + semver

### 3.5 Smoke Tests Post-Deploy

> **ALWAYS include** (server-side):
> - Health check endpoint (`/health`)
> - Database connectivity check
> - External API integration check

> **iOS/macOS**:
> - Automated UI tests on TestFlight builds (optional)
> - Manual QA checklist

> **NEVER**:
> - Run full UI tests in deployment job (too slow)
> - Block TestFlight upload on test failures

### 3.6 Commit & Verify

> **Git workflow**:
> ```
> git add .github/workflows/deploy*.yml fastlane/
> git commit -m "ci: add deployment pipeline with code signing"
> git push origin ci/deployment
> ```

> **Verify**:
> - Manual trigger works (workflow_dispatch)
> - Secrets accessible (certificates, profiles)
> - Archive succeeds
> - IPA exported correctly
> - Upload to TestFlight/App Store works
> - Rollback procedure documented

---

## Phase 4: Advanced Features

### Branch Strategy
```
main → ci/advanced
```

### 4.1 Performance Testing

> **ALWAYS**:
> - XCTest performance tests (measure blocks)
> - Track launch time, memory usage
> - Fail if performance degrades >10%
> - Use Instruments for profiling (optional)

### 4.2 UI Testing

> **ALWAYS**:
> - Separate workflow (`ui-tests.yml`)
> - Run on simulator farm (BrowserStack, AWS Device Farm)
> - Record videos/screenshots on failure
> - Run on schedule (nightly) + release tags

> **NEVER**:
> - Run UI tests on every PR (too slow)
> - Skip parallelization (use matrix strategy)

### 4.3 Release Automation

> **Semantic Versioning**:
> - Use agvtool for version/build number
> - Generate release notes from commits
> - Create GitHub Releases
> - Upload IPA as release asset

**Version Commands**:
```bash
# Set version
agvtool new-marketing-version 1.2.0

# Increment build number
agvtool next-version -all
```

### 4.4 Swift Package Publishing

> **If creating Swift Package**:
> - Tag release with semantic version
> - Update Package.swift with new version
> - No upload needed (consumed via Git tag)

### 4.5 Notifications

> **ALWAYS**:
> - Slack/Teams webhook on deploy success/failure
> - GitHub Status Checks for PR reviews
> - Email notifications for App Store status changes

> **NEVER**:
> - Expose webhook URLs in public repos
> - Spam notifications for every commit

### 4.6 Commit & Verify

> **Git workflow**:
> ```
> git add .github/workflows/
> git commit -m "ci: add performance tests, UI tests, and release automation"
> git push origin ci/advanced
> ```

> **Verify**:
> - Performance tests run and tracked
> - UI tests pass on simulators
> - Releases created automatically
> - Notifications received

---

## Framework-Specific Notes

### iOS (UIKit/SwiftUI)
- Archive: xcodebuild archive -scheme
- Destination: iOS Simulator or device
- Code signing: certificates + provisioning profiles
- TestFlight: xcrun altool or Fastlane

### macOS
- Archive: xcodebuild archive -scheme
- Notarization: xcrun notarytool (required for Gatekeeper)
- Distribution: Mac App Store or Developer ID

### Vapor (Server)
- Build: swift build -c release
- Run: .build/release/App
- Docker: FROM swift:5.9 as builder
- Health: custom /health endpoint

### Swift Package
- Test: swift test
- Build: swift build
- No deployment (consumed via SPM)

---

## Common Issues & Solutions

### Issue: Code signing fails with "no identity found"
- **Solution**: Verify certificate base64 encoding, keychain import, provisioning profile UUID

### Issue: Tests pass locally but fail in CI
- **Solution**: Check simulator availability, timezone, file paths (use Bundle resources)

### Issue: Archive fails with "no such module"
- **Solution**: Clean build folder, verify SPM dependencies resolved, check scheme build targets

### Issue: TestFlight upload fails
- **Solution**: Verify App Store Connect API key, check IPA export method (app-store), ensure bundle ID matches

### Issue: Coverage not collected
- **Solution**: Enable code coverage in scheme, use xccov to extract from .xcresult

---

## AI Self-Check

Before completing this process, verify:

- [ ] CI pipeline runs on push and PR
- [ ] Xcode version pinned
- [ ] Builds succeed on macOS runner
- [ ] All tests pass with coverage ≥80%
- [ ] SwiftLint enabled and enforced
- [ ] Security scanning enabled (CodeQL, Dependabot)
- [ ] Dependencies up to date (SPM)
- [ ] Code signing configured (certificates, profiles)
- [ ] Archive succeeds with proper signing
- [ ] Deployment to TestFlight/App Store works
- [ ] Environment secrets properly configured
- [ ] Smoke tests validate deployment (for server)
- [ ] Rollback procedure documented
- [ ] Performance tests tracked (if applicable)
- [ ] Notifications configured
- [ ] All workflows have timeout limits
- [ ] Documentation updated (README.md)

---

## Bug Logging

> **ALWAYS log bugs found during CI setup**:
> - Create ticket/issue for each bug
> - Tag with `bug`, `ci`, `infrastructure`
> - **NEVER fix production code during CI setup**
> - Link bug to CI implementation branch

---

## Documentation Updates

> **AFTER all phases complete**:
> - Update README.md with CI/CD badges
> - Document deployment process
> - Add runbook for common issues
> - Link to workflow files
> - Onboarding guide for new developers

---

## Final Commit

```bash
git checkout main
git merge ci/advanced
git tag -a v1.0.0-ci -m "CI/CD pipeline implemented"
git push origin main --tags
```

---

**Process Complete** ✅

