# Swift CI/CD with GitHub Actions - Copy This Prompt

> **Type**: One-time setup process  
> **When to use**: Setting up CI/CD pipeline for Swift project  
> **Instructions**: Copy the complete prompt below and paste into your AI tool

---

## 📋 Complete Self-Contained Prompt

```
========================================
SWIFT CI/CD - GITHUB ACTIONS
========================================

CONTEXT:
You are implementing CI/CD pipeline with GitHub Actions for a Swift project.

CRITICAL REQUIREMENTS:
- ALWAYS detect Swift version from .swift-version
- ALWAYS use SPM or CocoaPods caching
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
  test:
    runs-on: macos-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Setup Xcode
      uses: maxim-lobanov/setup-xcode@v1
      with:
        xcode-version: '15.0'
    
    - name: Cache SPM
      uses: actions/cache@v3
      with:
        path: .build
        key: ${{ runner.os }}-spm-${{ hashFiles('**/Package.resolved') }}
    
    - name: Build
      run: swift build
    
    - name: Test
      run: swift test --enable-code-coverage
    
    - name: Coverage
      run: |
        xcrun llvm-cov export -format="lcov" \
          .build/debug/*PackageTests.xctest/Contents/MacOS/*PackageTests \
          -instr-profile .build/debug/codecov/default.profdata > coverage.lcov
    
    - name: Upload coverage
      uses: codecov/codecov-action@v3
      with:
        files: coverage.lcov
```

For iOS projects with Xcode:
```yaml
    - name: Build and Test
      run: |
        xcodebuild test \
          -scheme YourApp \
          -destination 'platform=iOS Simulator,name=iPhone 14' \
          -enableCodeCoverage YES
```

Deliverable: Basic CI pipeline running

========================================
PHASE 2 - CODE QUALITY
========================================

Add to workflow:

```yaml
    - name: SwiftLint
      run: |
        brew install swiftlint
        swiftlint
    
    - name: SwiftFormat
      run: |
        brew install swiftformat
        swiftformat --lint .
```

Deliverable: Automated code quality checks

========================================
PHASE 3 - DEPLOYMENT (Optional)
========================================

Add deployment to TestFlight:

```yaml
  deploy:
    needs: test
    runs-on: macos-latest
    if: github.ref == 'refs/heads/main'
    
    steps:
    - uses: actions/checkout@v4
    - name: Build Archive
      run: |
        xcodebuild archive \
          -scheme YourApp \
          -archivePath build/YourApp.xcarchive
    - name: Export IPA
      run: |
        xcodebuild -exportArchive \
          -archivePath build/YourApp.xcarchive \
          -exportPath build \
          -exportOptionsPlist ExportOptions.plist
    - name: Upload to TestFlight
      uses: apple-actions/upload-testflight-build@v1
      with:
        app-path: build/YourApp.ipa
        issuer-id: ${{ secrets.APPSTORE_ISSUER_ID }}
        api-key-id: ${{ secrets.APPSTORE_KEY_ID }}
        api-private-key: ${{ secrets.APPSTORE_PRIVATE_KEY }}
```

Deliverable: Automated deployment

========================================
BEST PRACTICES
========================================

- Cache SPM/CocoaPods dependencies
- Use SwiftLint for code quality
- Run tests on iOS Simulator
- Collect code coverage
- Use fastlane for deployment
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

**What you get**: Complete CI/CD pipeline with Xcode and Swift tooling  
**Time**: 1-2 hours  
**Output**: .github/workflows/ci.yml
