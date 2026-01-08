# Swift Linting & Formatting - Copy This Prompt

> **Type**: One-time setup process  
> **When to use**: Setting up linting and code formatting  
> **Instructions**: Copy the complete prompt below and paste into your AI tool

---

## 📋 Complete Self-Contained Prompt

```
========================================
SWIFT LINTING & FORMATTING
========================================

CONTEXT:
You are setting up linting and code formatting for a Swift project.

CRITICAL REQUIREMENTS:
- ALWAYS use SwiftLint + SwiftFormat
- NEVER ignore warnings without justification
- Use .swiftlint.yml for configuration
- Enforce in CI pipeline

========================================
PHASE 1 - SWIFTLINT
========================================

Install via Homebrew:
```bash
brew install swiftlint
```

Or via CocoaPods:
```ruby
pod 'SwiftLint'
```

Create .swiftlint.yml:
```yaml
disabled_rules:
  - trailing_whitespace
opt_in_rules:
  - empty_count
  - closure_spacing
  - contains_over_first_not_nil

excluded:
  - Pods
  - Build
  - .build

line_length:
  warning: 120
  error: 200

identifier_name:
  min_length: 2
  max_length: 50
```

For Xcode, add Run Script Phase:
```bash
if which swiftlint >/dev/null; then
  swiftlint
else
  echo "warning: SwiftLint not installed"
fi
```

Run manually:
```bash
swiftlint

# Auto-fix
swiftlint --fix
```

Deliverable: SwiftLint configured

========================================
PHASE 2 - SWIFTFORMAT
========================================

Install via Homebrew:
```bash
brew install swiftformat
```

Create .swiftformat:
```
--swiftversion 5.9
--indent 4
--maxwidth 120
--wraparguments before-first
--wrapcollections before-first
--semicolons never
--trimwhitespace always
```

Run:
```bash
swiftformat .

# Check without modifying
swiftformat --lint .
```

Deliverable: SwiftFormat configured

========================================
PHASE 3 - CI INTEGRATION
========================================

Add to .github/workflows/ci.yml:
```yaml
- name: Install SwiftLint
  run: brew install swiftlint

- name: Lint
  run: swiftlint --strict

- name: Install SwiftFormat
  run: brew install swiftformat

- name: Format check
  run: swiftformat --lint .
```

Deliverable: Automated checks in CI

========================================
PHASE 4 - XCODE INTEGRATION
========================================

Add SwiftFormat Run Script Phase:
```bash
if which swiftformat >/dev/null; then
  swiftformat --lint "$SRCROOT"
else
  echo "warning: SwiftFormat not installed"
fi
```

Deliverable: Xcode integration

========================================
BEST PRACTICES
========================================

- Use SwiftLint for linting
- Use SwiftFormat for formatting
- Configure .swiftlint.yml
- Exclude generated files
- Run in Xcode build phase
- Fail CI on violations

========================================
EXECUTION
========================================

START: Install SwiftLint (Phase 1)
CONTINUE: Install SwiftFormat (Phase 2)
CONTINUE: Add CI checks (Phase 3)
OPTIONAL: Add Xcode integration (Phase 4)
REMEMBER: Exclude generated files, enforce in CI
```

---

## Quick Reference

**What you get**: Complete linting and formatting setup  
**Time**: 30 minutes  
**Output**: SwiftLint, SwiftFormat, CI integration
