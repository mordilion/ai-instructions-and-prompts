# Swift Code Coverage - Copy This Prompt

> **Type**: One-time setup process  
> **When to use**: Setting up code coverage for Swift project  
> **Instructions**: Copy the complete prompt below and paste into your AI tool

---

## 📋 Complete Self-Contained Prompt

```
========================================
SWIFT CODE COVERAGE - XCODE/SLATHER
========================================

CONTEXT:
You are implementing code coverage measurement for a Swift project using Xcode and Slather.

CRITICAL REQUIREMENTS:
- ALWAYS enable code coverage in Xcode scheme
- NEVER commit coverage reports to Git
- Target 80%+ coverage for critical paths
- Exclude UI code and generated files

========================================
PHASE 1 - LOCAL COVERAGE
========================================

Enable coverage in Xcode:
1. Edit Scheme → Test → Options
2. Check "Gather coverage for: All targets"
3. Run tests (Cmd+U)

View coverage in Xcode:
- Show Report Navigator (Cmd+9)
- Select Coverage tab
- Click on files to see line-by-line coverage

For SPM projects:
```bash
swift test --enable-code-coverage

# Generate lcov report
xcrun llvm-cov export \
  .build/debug/*PackageTests.xctest/Contents/MacOS/*PackageTests \
  -instr-profile .build/debug/codecov/default.profdata \
  --format="lcov" > coverage.lcov
```

Update .gitignore:
```
*.xcresult
coverage/
coverage.lcov
```

Deliverable: Local coverage report

========================================
PHASE 2 - CONFIGURE EXCLUSIONS
========================================

For Xcode projects, install Slather:
```bash
gem install slather
```

Create .slather.yml:
```yaml
coverage_service: cobertura_xml
xcodeproj: YourApp.xcodeproj
scheme: YourApp
source_directory: YourApp
output_directory: coverage
ignore:
  - Tests/*
  - YourApp/Generated/*
  - Pods/*
  - "*/AppDelegate.swift"
  - "*/SceneDelegate.swift"
```

Run:
```bash
slather coverage --scheme YourApp YourApp.xcodeproj
```

Deliverable: Proper file exclusions

========================================
PHASE 3 - CI INTEGRATION
========================================

Add to .github/workflows/ci.yml:

For SPM:
```yaml
    - name: Test with coverage
      run: swift test --enable-code-coverage
    
    - name: Generate lcov
      run: |
        xcrun llvm-cov export \
          .build/debug/*PackageTests.xctest/Contents/MacOS/*PackageTests \
          -instr-profile .build/debug/codecov/default.profdata \
          --format="lcov" > coverage.lcov
    
    - name: Upload to Codecov
      uses: codecov/codecov-action@v3
      with:
        files: coverage.lcov
        fail_ci_if_error: true
```

For Xcode:
```yaml
    - name: Test with coverage
      run: |
        xcodebuild test \
          -scheme YourApp \
          -destination 'platform=iOS Simulator,name=iPhone 14' \
          -enableCodeCoverage YES
    
    - name: Generate coverage
      run: slather coverage --cobertura-xml --output-directory . --scheme YourApp YourApp.xcodeproj
    
    - name: Upload to Codecov
      uses: codecov/codecov-action@v3
      with:
        files: cobertura.xml
```

Deliverable: CI coverage reporting

========================================
PHASE 4 - COVERAGE ENFORCEMENT
========================================

Use Codecov for enforcement via PR comments.

Or create custom script:
```bash
#!/bin/bash
COVERAGE=$(slather coverage --json YourApp.xcodeproj | jq '.coverage')
THRESHOLD=80.0

if (( $(echo "$COVERAGE < $THRESHOLD" | bc -l) )); then
    echo "Coverage $COVERAGE% is below threshold $THRESHOLD%"
    exit 1
fi
```

Deliverable: Automated coverage enforcement

========================================
BEST PRACTICES
========================================

- Enable coverage in Xcode scheme
- Use Slather for better reports
- Exclude AppDelegate and UI code
- Focus on business logic and models
- Set minimum thresholds (80%+)
- Review coverage in PRs

========================================
EXECUTION
========================================

START: Enable Xcode coverage (Phase 1)
CONTINUE: Configure Slather (Phase 2)
CONTINUE: Add CI integration (Phase 3)
OPTIONAL: Add enforcement (Phase 4)
REMEMBER: Exclude UI code, use Slather
```

---

## Quick Reference

**What you get**: Complete code coverage setup with Xcode/Slather  
**Time**: 1-2 hours  
**Output**: Coverage reports in CI and locally
