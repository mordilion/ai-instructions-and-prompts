# CI/CD Implementation Process - Dart/Flutter (GitHub Actions)

> **Purpose**: Establish comprehensive CI/CD pipeline with GitHub Actions for Dart/Flutter applications

> **Platform**: This guide is for **GitHub Actions**. For GitLab CI, Bitrise, Codemagic, or CircleCI, adapt the workflow syntax accordingly.

---

## Prerequisites

> **BEFORE starting**:
> - Working Dart/Flutter application
> - Git repository with remote (GitHub)
> - pubspec.yaml configured
> - Tests exist (flutter test, dart test)
> - Flutter/Dart version defined in pubspec.yaml or .fvmrc

---

## Workflow Adaptation

> **IMPORTANT**: Phases below focus on OBJECTIVES. Use your team's workflow.

---

## Phase 1: Basic CI Pipeline

**Objective**: Establish foundational CI pipeline with build, lint, and test automation

### 1.1 Basic Build & Test Workflow

> **ALWAYS include**:
> - Flutter/Dart version from project (read from `.fvmrc`, `pubspec.yaml`, or use stable channel)
> - Setup with subosito/flutter-action@v2
> - Dependency caching (pub cache)
> - Get dependencies: `flutter pub get`
> - Run linter/analyzer: `flutter analyze` or `dart analyze`
> - Run tests: `flutter test` or `dart test`
> - Collect coverage: `flutter test --coverage`

> **Version Strategy**:
> - **Best**: Use `.fvmrc` to pin Flutter version (if using FVM)
> - **Good**: Specify in workflow with `flutter-version` parameter
> - **Matrix**: Test against multiple versions (stable, beta) if package

> **NEVER**:
> - Skip dependency installation
> - Ignore analyzer warnings
> - Run tests without proper device/emulator setup (for integration tests)
> - Hardcode Flutter version without project config

**Key Workflow Structure**:
- Trigger: push (main/develop), pull_request
- Jobs: analyze → test → build
- Cache: Flutter SDK and pub cache
- Platform-specific jobs: Android, iOS, Web, Desktop

### 1.2 Coverage Reporting

> **ALWAYS**:
> - Generate coverage with `flutter test --coverage`
> - Upload coverage/lcov.info to Codecov/Coveralls
> - Set minimum coverage threshold (80%+)

**Coverage Commands**:
```bash
flutter test --coverage
# Generate HTML report: genhtml coverage/lcov.info -o coverage/html
```

**Verify**: Pipeline runs, analyzer passes, all tests pass, coverage report generated, dependencies cached

---

## Phase 2: Code Quality & Security

**Objective**: Add code quality and security scanning to CI pipeline

### 2.1 Code Quality & Security

> **ALWAYS**: flutter analyze, dart format check, custom lint rules, Dependabot, pub outdated
> **NEVER**: Suppress all lints, ignore type safety

```yaml
# analysis_options.yaml
include: package:flutter_lints/flutter.yaml
linter:
  rules: [prefer_const_constructors, prefer_final_fields, avoid_print]

# .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: "pub"
    directory: "/"
    schedule: { interval: "weekly" }
```

**Verify**: Analyze passes, formatting correct, Dependabot creates PRs

---

## Phase 3: Deployment Pipeline

**Objective**: Automate app deployment to relevant stores/platforms

### 3.1 Environment Configuration

> **ALWAYS**:
> - Define environments: development, staging, production
> - Use GitHub Environments with protection rules
> - Store secrets: Android keystore, iOS certificates, API keys
> - Use flavor-specific configurations (--flavor prod)

**Protection Rules**: Production (require approval, restrict to main), Staging (auto-deploy to internal testing), Development (ad-hoc builds)

### 3.2 Platform Builds

> **Android**: `flutter build appbundle --release`, sign with keystore (GitHub Secrets), ProGuard/R8
> **iOS**: `flutter build ipa --release`, fastlane, import certificates to keychain
> **Web**: `flutter build web --release --base-href /`, deploy to Firebase/Netlify/Pages
> **NEVER**: Commit keystore, use debug keys in production

### 3.3 Deployment & Verification

**Tools**: fastlane (Play Store/App Store), Firebase App Distribution, GitHub Pages  
**Smoke Tests**: Health check, API connectivity, Firebase Test Lab (mobile UI tests)

**Verify**: Builds succeed, uploads work, smoke tests pass

---

## Phase 4: Advanced Features

**Objective**: Add advanced CI/CD capabilities (integration tests, release automation)

### 4.1 Advanced Testing & Automation

**Integration**: Separate workflow, emulators/simulators, `integration_test` package  
**Performance**: Track startup time, frame rendering, memory usage, fail if degrades >10%  
**NEVER**: Run integration tests on every PR (too slow)

### 4.2 Release Automation

> **Semantic Versioning**:
> - Update pubspec.yaml version automatically
> - Generate release notes from commits
> - Create GitHub Releases
> - Publish to pub.dev (if package)

### 4.4 pub.dev Publishing

> **If creating package**:
> - Validate with `flutter pub publish --dry-run`
> - Publish with `flutter pub publish`
> - Use pub-dev-publish GitHub Action
> - Follow pub.dev package guidelines

> **ALWAYS**: Set name, description, version in pubspec.yaml; Include README.md, CHANGELOG.md, LICENSE; Follow semantic versioning; Add example/

### 4.5 Notifications

> **ALWAYS**: Slack webhook on build success/failure, Email for store uploads

**Verify**: Integration tests run on schedule, performance tracked, releases automated, pub.dev publish works (if applicable), notifications received

---

## Platform-Specific Notes

| Platform | Notes |
|-----------|-------|
| **Android** | Sign with keystore; Upload AAB to Play Console; Use fastlane for automation; Enable R8 shrinking |
| **iOS** | Sign with certificates and provisioning profiles; Upload to TestFlight; Use fastlane; Enable bitcode if required |
| **Web** | Build with `flutter build web`; Deploy to Firebase Hosting, Netlify, GitHub Pages; Configure routing |
| **Desktop (Windows/macOS/Linux)** | Build with `flutter build windows/macos/linux`; Package as installer; Code sign for distribution |
| **Dart Package** | Build with `dart pub get`; Test with `dart test`; Publish to pub.dev |

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| **Flutter doctor shows issues** | Ensure all required tools installed (Android SDK, Xcode), run flutter doctor --android-licenses |
| **Tests fail only in CI** | Check Flutter version match, ensure assets included, verify environment variables |
| **Android signing fails** | Verify keystore decoded correctly, check key.properties path, ensure passwords correct |
| **iOS signing fails** | Check certificate validity, verify provisioning profile matches bundle ID, ensure keychain unlocked |
| **Web build missing assets** | Verify assets declared in pubspec.yaml, check pubspec.yaml indentation |
| **Want to use Codemagic / Bitrise** | Codemagic/Bitrise: Specialized for Flutter, better device support, simpler setup - core concepts remain same |

---

## AI Self-Check

- [ ] CI pipeline runs on push and PR
- [ ] Flutter/Dart version pinned or specified
- [ ] flutter analyze passes with no warnings
- [ ] All tests pass with coverage ≥80%
- [ ] Code formatting enforced (dart format)
- [ ] Android build succeeds and signs correctly
- [ ] iOS build succeeds and signs correctly (if iOS app)
- [ ] Web build succeeds (if web app)
- [ ] Upload to stores works (Android/iOS)
- [ ] Integration tests run on schedule

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
