# Code Coverage Setup (TypeScript)

> **Goal**: Establish automated code coverage tracking in existing TypeScript projects

## Phase 1: Choose Code Coverage Tools

> **ALWAYS**: Track line, branch, and function coverage
> **ALWAYS**: Set minimum coverage thresholds
> **NEVER**: Aim for 100% coverage (diminishing returns)
> **NEVER**: Skip uncovered critical paths

### Recommended Tools

| Tool | Type | Use Case | Setup |
|------|------|----------|-------|
| **Jest (built-in)** ⭐ | Test runner + coverage | All-in-one | `npm install --save-dev jest` |
| **nyc (Istanbul)** | Coverage tool | Any test runner | `npm install --save-dev nyc` |
| **c8** | Coverage tool | Native V8 coverage | `npm install --save-dev c8` |
| **Codecov** | Reporting | CI/CD integration | Cloud service |

---

## Phase 2: Coverage Tool Configuration

### Jest with Coverage

```bash
# Install
npm install --save-dev jest @types/jest ts-jest

# Run tests with coverage
npm test -- --coverage

# Watch mode with coverage
npm test -- --coverage --watchAll
```

**Configuration** (`jest.config.js`):
```javascript
module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  roots: ['<rootDir>/src', '<rootDir>/tests'],
  testMatch: ['**/__tests__/**/*.ts', '**/?(*.)+(spec|test).ts'],
  collectCoverage: true,
  collectCoverageFrom: [
    'src/**/*.{ts,tsx}',
    '!src/**/*.d.ts',
    '!src/**/*.interface.ts',
    '!src/**/index.ts',
  ],
  coverageDirectory: 'coverage',
  coverageReporters: ['text', 'lcov', 'html', 'json-summary'],
};
```

### nyc (Istanbul) Configuration

```bash
# Install
npm install --save-dev nyc

# Run with nyc
nyc npm test
```

**Configuration** (`.nycrc.json`):
```json
{
  "all": true,
  "include": ["src/**/*.ts"],
  "exclude": [
    "**/*.d.ts",
    "**/*.interface.ts",
    "**/*.test.ts",
    "**/*.spec.ts"
  ],
  "reporter": ["text", "lcov", "html"],
  "report-dir": "coverage",
  "check-coverage": true,
  "lines": 80,
  "statements": 80,
  "functions": 80,
  "branches": 75
}
```

---

## Phase 3: Coverage Thresholds & Reporting

### Jest Thresholds

**Configuration** (`jest.config.js`):
```javascript
module.exports = {
  // ... other config
  coverageThreshold: {
    global: {
      lines: 80,
      branches: 75,
      functions: 80,
      statements: 80,
    },
    './src/critical/**/*.ts': {
      lines: 90,
      branches: 85,
      functions: 90,
      statements: 90,
    },
  },
};
```

### Scripts Configuration

**Configuration** (`package.json`):
```json
{
  "scripts": {
    "test": "jest",
    "test:watch": "jest --watch",
    "test:coverage": "jest --coverage",
    "test:coverage:watch": "jest --coverage --watchAll",
    "test:ci": "jest --coverage --ci --maxWorkers=2"
  }
}
```

---

## Phase 4: CI/CD Integration

### GitHub Actions

```yaml
# .github/workflows/test.yml
name: Test & Coverage

on:
  push:
    branches: [main, develop]
  pull_request:

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version-file: '.nvmrc'
          cache: 'npm'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Run tests with coverage
        run: npm run test:ci
      
      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v4
        with:
          token: ${{ secrets.CODECOV_TOKEN }}
          files: ./coverage/lcov.info
          fail_ci_if_error: true
      
      - name: Archive coverage report
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: coverage-report
          path: coverage/
```

---

## Phase 5: Coverage Analysis & Improvement

### Identify Uncovered Code

```bash
# Generate HTML report
npm run test:coverage

# Open report (macOS)
open coverage/lcov-report/index.html

# Open report (Windows)
start coverage/lcov-report/index.html
```

### Prioritize Critical Paths

**Coverage priorities (high to low)**:
1. Business logic (services, utilities)
2. Data validation (input/output)
3. Error handling
4. API endpoints
5. UI components (visual tests)

### Incremental Improvement

```javascript
// jest.config.js - Ratcheting approach
coverageThreshold: {
  global: {
    lines: 80,    // Start at current coverage
    // Increase by 5% every sprint
  },
};
```

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| **Coverage reports missing** | Check `collectCoverageFrom` paths in config |
| **Slow test runs** | Use `--maxWorkers=50%` or `--runInBand` |
| **False low coverage** | Exclude test files, types, interfaces |
| **CI fails on threshold** | Review uncovered code, add tests or adjust threshold |

---

## Best Practices

> **ALWAYS**: Set realistic thresholds (70-85% is good)
> **ALWAYS**: Prioritize critical business logic
> **ALWAYS**: Review coverage reports before merge
> **ALWAYS**: Track coverage trends over time
> **NEVER**: Aim for 100% (diminishing returns)
> **NEVER**: Write tests just to increase coverage
> **NEVER**: Skip edge cases and error paths

---

## AI Self-Check

- [ ] Jest or nyc configured for coverage?
- [ ] Coverage thresholds set (80% line, 75% branch)?
- [ ] Critical paths have higher thresholds (90%)?
- [ ] CI/CD runs coverage and fails on threshold violation?
- [ ] Coverage reports uploaded to Codecov/Coveralls?
- [ ] Test files excluded from coverage?
- [ ] HTML reports generated for local review?
- [ ] Team reviews coverage reports?
- [ ] Coverage trends tracked over time?
- [ ] Uncovered critical code identified and tested?

---

## Coverage Metrics Explained

| Metric | Definition | Target |
|--------|------------|--------|
| **Line Coverage** | % of lines executed | 80-85% |
| **Branch Coverage** | % of if/else branches executed | 75-80% |
| **Function Coverage** | % of functions called | 80-85% |
| **Statement Coverage** | % of statements executed | 80-85% |

---

## Tools Comparison

| Tool | Speed | Setup | CI/CD | Best For |
|------|-------|-------|-------|----------|
| Jest | Fast | Easy | ✅ | All-in-one |
| nyc | Medium | Medium | ✅ | Mocha/AVA |
| c8 | Fast | Easy | ✅ | Native V8 |
| Codecov | N/A | Easy | ✅ | Reporting |


## Usage - Copy This Complete Prompt

> **Type**: One-time setup process (simple)  
> **When to use**: When configuring code coverage tracking and reporting

### Complete Implementation Prompt

```
CONTEXT:
You are configuring code coverage tracking for this project.

CRITICAL REQUIREMENTS:
- ALWAYS detect language version from project files
- ALWAYS configure coverage thresholds (recommended: 80% line, 75% branch)
- ALWAYS integrate with CI/CD pipeline
- NEVER lower coverage thresholds without justification

IMPLEMENTATION STEPS:

1. DETECT VERSION:
   Scan project files for language/framework version

2. CHOOSE COVERAGE TOOL:
   Select appropriate tool for the language (see Tech Stack section above)

3. CONFIGURE TOOL:
   Add coverage configuration to project
   Set thresholds (line, branch, function)

4. INTEGRATE WITH CI/CD:
   Add coverage step to pipeline
   Configure to fail build if below thresholds

5. CONFIGURE REPORTING:
   Generate coverage reports (HTML, XML, lcov)
   Optional: Upload to coverage service (Codecov, Coveralls)

DELIVERABLE:
- Coverage tool configured
- Thresholds enforced in CI/CD
- Coverage reports generated

START: Detect language version and configure coverage tool.
```
