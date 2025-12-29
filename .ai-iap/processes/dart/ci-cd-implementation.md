# CI/CD Implementation Process - Dart/Flutter

> **Purpose**: Establish comprehensive CI/CD pipeline with GitHub Actions for Dart/Flutter applications

---

## Prerequisites

> **BEFORE starting**:
> - Working Dart/Flutter application (3.0+ recommended)
> - Git repository with remote (GitHub)
> - pubspec.yaml configured
> - Tests exist (flutter_test, mocktail)

---

## Phase 1: Basic CI Pipeline

### Branch Strategy
```
main → ci/basic-pipeline
```

### 1.1 Create Workflow Directory

> **ALWAYS**:
> - Create `.github/workflows/` directory
> - Name workflow file `flutter.yml` or `dart.yml`

### 1.2 Basic Build & Test Workflow

> **ALWAYS include**:
> - Flutter version pinning (stable, beta channels)
> - Setup with subosito/flutter-action@v2
> - Dependency caching (~/.pub-cache)
> - Install dependencies (`flutter pub get`)
> - Run analyzer (`flutter analyze`)
> - Run tests (`flutter test`)
> - Collect coverage with lcov

> **NEVER**:
> - Skip `flutter pub get` before tests
> - Use outdated Flutter SDK
> - Ignore analyzer warnings
> - Run without specifying Flutter channel

**Key Workflow Structure**:
- Trigger: push (main/develop), pull_request
- Jobs: analyze → test → build
- Setup: subosito/flutter-action@v2
- Cache: pub cache by pubspec.lock

### 1.3 Coverage Reporting

> **ALWAYS**:
> - Use `flutter test --coverage`
> - Generate lcov.info report
> - Upload to Codecov/Coveralls
> - Set minimum coverage threshold (80%+)

**Coverage Commands**:
```bash
flutter test --coverage
# Convert to HTML: genhtml coverage/lcov.info -o coverage/html
```

### 1.4 Commit & Verify

> **Git workflow**:
> ```
> git add .github/workflows/
> git commit -m "ci: add basic Flutter build and test pipeline"
> git push origin ci/basic-pipeline
> ```

> **Verify**:
> - Pipeline runs on push
> - Builds succeed on Ubuntu runner
> - Tests execute with results
> - Coverage report generated
> - Pub cache working

---

## Phase 2: Code Quality & Security

### Branch Strategy
```
main → ci/quality-security
```

### 2.1 Code Quality Analysis

> **ALWAYS include**:
> - Dart analyzer with strict analysis_options.yaml
> - dart format for formatting checks
> - Fail build on analyzer errors

> **NEVER**:
> - Ignore analyzer errors globally
> - Skip formatter configuration
> - Allow warnings in new code

**analysis_options.yaml**:
```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    - always_declare_return_types
    - avoid_print
    - prefer_const_constructors
    - use_key_in_widget_constructors

analyzer:
  errors:
    invalid_annotation_target: ignore
```

### 2.2 Dependency Security Scanning

> **ALWAYS include**:
> - Dependabot configuration (`.github/dependabot.yml`)
> - `flutter pub outdated` to check updates
> - Fail on known vulnerabilities (if tool available)

> **Dependabot Config**:
> - Package ecosystem: pub
> - Schedule: weekly
> - Open PR limit: 5

### 2.3 Static Analysis (SAST)

> **ALWAYS**:
> - Add CodeQL analysis (`.github/workflows/codeql.yml`)
> - Configure language: dart (or javascript if web)
> - Run on schedule (weekly) + push to main
> - Review alerts in GitHub Security tab

> **Optional but recommended**:
> - SonarCloud integration
> - DCM (Dart Code Metrics) for advanced analysis

### 2.4 Commit & Verify

> **Git workflow**:
> ```
> git add .github/dependabot.yml .github/workflows/codeql.yml analysis_options.yaml
> git commit -m "ci: add code quality and security scanning"
> git push origin ci/quality-security
> ```

> **Verify**:
> - Analyzer runs during CI
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
> - Store secrets per environment (API keys, signing keys)
> - Use dart-define for build-time constants

> **Protection Rules**:
> - Production: require approval, restrict to main branch
> - Staging: auto-deploy on merge to develop
> - Development: auto-deploy on feature branches

### 3.2 Build Artifacts

> **ALWAYS**:
> - Build release artifacts (APK, AAB, IPA, web)
> - Version with pubspec.yaml (version: 1.0.0+1)
> - Upload artifacts with retention policy
> - Sign Android/iOS apps with keystore/certificates

> **NEVER**:
> - Include .env files in builds
> - Ship debug builds to production
> - Skip obfuscation for release builds

**Build Commands**:

**Android**:
```bash
flutter build apk --release
flutter build appbundle --release
# With obfuscation: --obfuscate --split-debug-info=build/app/outputs/symbols
```

**iOS**:
```bash
flutter build ipa --release --export-options-plist=ios/ExportOptions.plist
```

**Web**:
```bash
flutter build web --release
```

### 3.3 Code Signing

**Android**:
> **ALWAYS**:
> - Store keystore.jks in GitHub Secrets (base64)
> - Store key.properties values as secrets
> - Configure signing in android/app/build.gradle

**iOS**:
> **ALWAYS**:
> - Store certificates in GitHub Secrets (base64)
> - Store provisioning profiles in GitHub Secrets
> - Use Fastlane Match or manual cert management

### 3.4 Deployment Jobs

> **Platform-specific** (choose one or more):

**Google Play Store (Android)**:
- Use r0adkll/upload-google-play@v1
- Upload AAB to internal/beta/production track
- Configure Service Account JSON as secret
- Automated rollout percentage (optional)

**App Store (iOS)**:
- Use Fastlane deliver or pilot (TestFlight)
- Upload IPA with xcrun altool or Transporter
- Configure App Store Connect API key

**Firebase App Distribution**:
- Use wzieba/Firebase-Distribution-Github-Action
- Distribute to testers
- Upload APK/IPA with release notes

**Web Hosting**:
- Firebase Hosting: `firebase deploy --only hosting`
- Netlify/Vercel: deploy build/web/
- AWS S3 + CloudFront
- GitHub Pages: upload build/web/ to gh-pages branch

### 3.5 Smoke Tests Post-Deploy

> **ALWAYS include** (for web/backend):
> - Health check endpoint test
> - Critical API endpoint validation

> **Mobile**:
> - Automated UI tests with integration_test (optional)
> - Manual QA checklist for store submissions

> **NEVER**:
> - Run full integration tests in deployment job
> - Block upload on test failures

### 3.6 Commit & Verify

> **Git workflow**:
> ```
> git add .github/workflows/deploy*.yml fastlane/
> git commit -m "ci: add deployment pipeline with app signing"
> git push origin ci/deployment
> ```

> **Verify**:
> - Manual trigger works (workflow_dispatch)
> - Secrets accessible (keystores, certificates)
> - Build succeeds (APK/AAB/IPA)
> - Upload to Play Store/TestFlight works
> - Web deployment succeeds
> - Rollback procedure documented

---

## Phase 4: Advanced Features

### Branch Strategy
```
main → ci/advanced
```

### 4.1 Performance Testing

> **ALWAYS**:
> - flutter_driver for performance tests
> - Track frame rendering times
> - Memory usage profiling
> - Fail if performance degrades >10%

### 4.2 Integration Testing

> **ALWAYS**:
> - Separate workflow (`integration-tests.yml`)
> - Use integration_test package
> - Run on emulator/simulator (macos runner for iOS)
> - Record videos/screenshots on failure

> **NEVER**:
> - Run integration tests on every PR (too slow)
> - Skip device farm testing before release

### 4.3 Release Automation

> **Semantic Versioning**:
> - Update pubspec.yaml version field (1.0.0+buildNumber)
> - Generate CHANGELOG from conventional commits
> - Create GitHub Releases with notes
> - Attach APK/AAB/IPA to release

### 4.4 Package Publishing (Pub.dev)

> **If creating Dart/Flutter package**:
> - Publish to pub.dev with `flutter pub publish`
> - Use pana for package analysis score
> - Include README.md, CHANGELOG.md, LICENSE
> - Follow pub.dev best practices

> **ALWAYS**:
> - Set name, description, version in pubspec.yaml
> - Include example/ directory
> - Document public API

### 4.5 Notifications

> **ALWAYS**:
> - Slack/Teams webhook on deploy success/failure
> - GitHub Status Checks for PR reviews
> - Email notifications for store review status

> **NEVER**:
> - Expose webhook URLs in public repos
> - Spam notifications for every commit

### 4.6 Commit & Verify

> **Git workflow**:
> ```
> git add .github/workflows/
> git commit -m "ci: add performance tests, integration tests, and release automation"
> git push origin ci/advanced
> ```

> **Verify**:
> - Performance tests run and tracked
> - Integration tests pass on emulators
> - Releases created automatically
> - Pub.dev package published (if applicable)
> - Notifications received

---

## Platform-Specific Notes

### Flutter (Mobile)
- Build Android: flutter build apk/appbundle
- Build iOS: flutter build ipa
- Integration tests: integration_test package
- Device farms: Firebase Test Lab, AWS Device Farm

### Flutter (Web)
- Build: flutter build web --release
- Hosting: Firebase, Netlify, Vercel, S3
- PWA support: manifest.json, service worker
- CanvasKit vs HTML renderer

### Dart (Server)
- Build: dart compile exe bin/server.dart
- Deploy: Docker, Heroku, Cloud Run
- Health check: custom /health endpoint
- Use shelf, shelf_router for HTTP

---

## Common Issues & Solutions

### Issue: pub get fails with version conflict
- **Solution**: Update dependencies, use `flutter pub outdated`, resolve conflicts in pubspec.yaml

### Issue: Tests pass locally but fail in CI
- **Solution**: Check test environment (network access), mock external dependencies

### Issue: iOS build fails with code signing error
- **Solution**: Verify certificate base64 encoding, provisioning profile, bundle ID

### Issue: Android build fails with Gradle error
- **Solution**: Update Gradle version, check Android SDK, verify keystore config

### Issue: Coverage not collected
- **Solution**: Run `flutter test --coverage`, ensure test files imported correctly

---

## AI Self-Check

Before completing this process, verify:

- [ ] CI pipeline runs on push and PR
- [ ] Flutter SDK version pinned
- [ ] Dependencies cached (pub cache)
- [ ] All tests pass with coverage ≥80%
- [ ] Analyzer enforced (strict analysis_options.yaml)
- [ ] Security scanning enabled (CodeQL, Dependabot)
- [ ] Dependencies up to date
- [ ] Artifacts built with correct versioning
- [ ] Code signing configured (Android keystore, iOS certificates)
- [ ] Deployment to at least one platform works
- [ ] Environment secrets properly configured
- [ ] Smoke tests validate deployment (if applicable)
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

