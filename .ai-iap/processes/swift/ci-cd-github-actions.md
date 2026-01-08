# CI/CD Implementation Process - Swift (GitHub Actions)

> **Purpose**: Establish comprehensive CI/CD pipeline with GitHub Actions for Swift applications (iOS, macOS, Server/Vapor)

> **Platform**: This guide is for **GitHub Actions**. For GitLab CI, Azure DevOps, CircleCI, Bitrise, or Codemagic, adapt the workflow syntax accordingly.

---

## Prerequisites

> **BEFORE starting**:
> - Working Swift application (iOS, macOS, or Vapor)
> - Git repository with remote (GitHub)
> - Xcode project or Swift Package configured
> - Tests exist (XCTest)
> - Swift/Xcode version defined in .xcode-version or .swift-version

---

## Workflow Adaptation

> **IMPORTANT**: Phases below focus on OBJECTIVES. Use your team's workflow.

---

## Phase 1: Basic CI Pipeline

**Objective**: Establish foundational CI pipeline with build, lint, and test automation

### 1.1 Basic Build & Test Workflow

> **ALWAYS include**:
> - Swift/Xcode version (read from `.xcode-version` or `.swift-version`)
> - iOS: Use macos-latest runner
> - Server (Vapor): Can use ubuntu-latest with Swift Docker
> - Build: `xcodebuild` or `swift build`
> - Run tests: `xcodebuild test` or `swift test`
> - Collect coverage: Xcode Code Coverage or llvm-cov

> **Version Strategy**:
> - **Best**: Use `.xcode-version` file for Xcode version
> - **Good**: Specify in workflow with `xcode-version` parameter
> - **iOS**: Match minimum deployment target in project

> **NEVER**:
> - Hardcode Xcode version without project config
> - Skip code signing setup for iOS builds
> - Run tests without simulator selection (iOS)
> - Ignore compiler warnings

**Key Workflow Structure**:
- Trigger: push (main/develop), pull_request
- Runner: macos-latest (iOS/macOS) or ubuntu-latest (Vapor)
- Jobs: lint → test → build
- Cache: Swift Package Manager dependencies

### 1.2 Coverage Reporting

> **ALWAYS**:
> - Enable code coverage in scheme (Xcode)
> - Generate coverage reports
> - Upload to Codecov/Coveralls
> - Set minimum coverage threshold (80%+)

**Coverage Commands**:
```bash
# Xcode
xcodebuild test -scheme MyApp -enableCodeCoverage YES -resultBundlePath ./TestResults

# Vapor/SPM
swift test --enable-code-coverage
```

**Verify**: Pipeline runs, builds succeed, tests pass, coverage generated, dependencies cached

---

## Phase 2: Code Quality & Security

**Objective**: Add code quality and security scanning to CI pipeline

### 2.1 Code Quality & Security

> **ALWAYS**: SwiftLint, SwiftFormat, Dependabot (Swift Package Manager), CodeQL (swift), fail on lint errors
> **NEVER**: Suppress warnings globally, allow force unwrapping without justification

```yaml
# .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: "swift"
    directory: "/"
    schedule: { interval: "weekly" }
```

**Verify**: SwiftLint passes, SwiftFormat applied, Dependabot creates PRs, CodeQL completes

---

## Phase 3: Deployment Pipeline

**Objective**: Automate app deployment to relevant environments/platforms

### 3.1 Environment Configuration

> **ALWAYS**:
> - Define environments: development, staging, production
> - Use GitHub Environments with protection rules
> - Store secrets: certificates, provisioning profiles, API keys
> - Use Xcode configurations for environment-specific builds

**Protection Rules**: Production (require approval, restrict to main), Staging (auto-deploy to TestFlight), Development (internal distribution)

### 3.2 Code Signing, Build & Deployment

**Code Signing**: Store certificates/profiles as secrets, fastlane match, decode+import to keychain  
**Archive**: `xcodebuild archive` + `exportArchive`, version with build number  
**Platforms**: App Store Connect/TestFlight (fastlane), Firebase App Distribution, Vapor (Docker/AWS)  
**Smoke Tests**: Health check (Vapor), UI tests on TestFlight (iOS/macOS)  
**NEVER**: Include dev certificates in production, ship with debug symbols

**Verify**: Code signing works, archive succeeds, TestFlight upload succeeds, smoke tests pass

---

## Phase 4: Advanced Features

**Objective**: Add advanced CI/CD capabilities (integration tests, release automation)

### 4.1 Advanced Testing & Automation

**UI Testing**: Separate workflow, simulators (multiple iOS versions), run nightly  
**Performance**: XCTest measureBlock, track launch time/memory, fail if regresses >10%  
**Release**: fastlane increment_build_number, release notes, GitHub Releases, App Store submission

### 4.2 Notifications

> **ALWAYS**: Slack webhook on build/deploy success/failure, Email for TestFlight uploads

**Verify**: UI tests run on schedule, performance tracked, releases automated, notifications received

---

## Platform-Specific Notes

| Platform | Notes |
|----------|-------|
| **iOS App** | Code sign with certificates; Upload to App Store Connect; Use fastlane for automation |
| **macOS App** | Notarize with Apple; Code sign with Developer ID; Distribute via DMG or Mac App Store |
| **Vapor (Server)** | Build on Linux (ubuntu-latest); Deploy to AWS/Heroku; Use Docker for consistency |
| **Swift Package** | Build with `swift build`; Test with `swift test`; Publish to Swift Package Index |

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| **Code signing fails in CI** | Verify certificates base64-encoded correctly, check keychain password, ensure provisioning profile matches bundle ID |
| **Tests fail only in CI** | Check simulator availability, ensure Xcode version matches, verify test scheme settings |
| **Archive export fails** | Validate ExportOptions.plist, check entitlements, verify provisioning profile type |
| **Slow builds in CI** | Enable caching for DerivedData and SPM, use incremental builds |
| **Want to use Bitrise / Codemagic** | Bitrise/Codemagic: Specialized for mobile, better simulator support, simpler code signing - core concepts remain same |

---

## AI Self-Check

- [ ] CI pipeline runs on push and PR
- [ ] Xcode/Swift version pinned
- [ ] SwiftLint passes
- [ ] All tests pass with coverage ≥80%
- [ ] Code signing configured (iOS/macOS)
- [ ] Archive builds successfully
- [ ] Upload to TestFlight/App Store works (iOS)
- [ ] Deployment succeeds (Vapor/server)
- [ ] Performance tests tracked
- [ ] UI tests run on schedule (iOS/macOS)

---

## Documentation Updates

> **AFTER all phases complete**:
> - Update README.md with CI/CD badges
> - Document deployment process
> - Add runbook for common issues
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
