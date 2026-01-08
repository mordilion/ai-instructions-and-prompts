# TypeScript Code Coverage - Copy This Prompt

> **Type**: One-time setup process  
> **When to use**: Setting up code coverage for TypeScript/Node.js project  
> **Instructions**: Copy the complete prompt below and paste into your AI tool

---

## 📋 Complete Self-Contained Prompt

```
========================================
TYPESCRIPT CODE COVERAGE - JEST/VITEST
========================================

CONTEXT:
You are implementing code coverage measurement for a TypeScript/Node.js project.

CRITICAL REQUIREMENTS:
- ALWAYS use Jest or Vitest for coverage
- NEVER commit coverage reports to Git
- Target 80%+ coverage for critical paths
- Exclude tests and generated files

========================================
PHASE 1 - LOCAL COVERAGE
========================================

For Jest:
```bash
npm install --save-dev jest @types/jest ts-jest
```

Create jest.config.js:
```javascript
module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  collectCoverageFrom: [
    'src/**/*.ts',
    '!src/**/*.d.ts',
    '!src/**/*.test.ts'
  ],
  coverageDirectory: 'coverage',
  coverageReporters: ['html', 'text', 'lcov']
};
```

For Vitest:
```bash
npm install --save-dev vitest @vitest/coverage-v8
```

Update vite.config.ts:
```typescript
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    coverage: {
      provider: 'v8',
      reporter: ['text', 'html', 'lcov'],
      exclude: ['**/*.test.ts', '**/*.d.ts', 'dist/**']
    }
  }
});
```

Run tests with coverage:
```bash
# Jest
npm test -- --coverage

# Vitest
npm run test -- --coverage
```

Update .gitignore:
```
coverage/
.nyc_output/
```

Deliverable: Local coverage report

========================================
PHASE 2 - CONFIGURE EXCLUSIONS
========================================

For Jest, update jest.config.js:
```javascript
module.exports = {
  collectCoverageFrom: [
    'src/**/*.{ts,tsx}',
    '!src/**/*.d.ts',
    '!src/**/*.test.{ts,tsx}',
    '!src/**/*.spec.{ts,tsx}',
    '!src/index.ts',
    '!src/types/**',
    '!src/**/__tests__/**'
  ],
  coveragePathIgnorePatterns: [
    '/node_modules/',
    '/dist/',
    '/coverage/'
  ]
};
```

For Vitest:
```typescript
coverage: {
  exclude: [
    '**/*.test.ts',
    '**/*.spec.ts',
    '**/*.d.ts',
    'dist/**',
    'src/types/**',
    'src/__tests__/**'
  ]
}
```

Deliverable: Proper file exclusions

========================================
PHASE 3 - CI INTEGRATION
========================================

Add to .github/workflows/ci.yml:

```yaml
    - name: Test with coverage
      run: npm test -- --coverage
    
    - name: Upload to Codecov
      uses: codecov/codecov-action@v3
      with:
        files: coverage/lcov.info
        fail_ci_if_error: true
```

Deliverable: CI coverage reporting

========================================
PHASE 4 - COVERAGE ENFORCEMENT
========================================

For Jest, add to jest.config.js:
```javascript
module.exports = {
  coverageThreshold: {
    global: {
      branches: 80,
      functions: 80,
      lines: 80,
      statements: 80
    }
  }
};
```

For Vitest, add to vite.config.ts:
```typescript
coverage: {
  thresholds: {
    lines: 80,
    functions: 80,
    branches: 80,
    statements: 80
  }
}
```

Tests will fail if coverage drops below threshold.

Deliverable: Automated coverage enforcement

========================================
BEST PRACTICES
========================================

- Exclude tests and type definitions
- Use Jest or Vitest consistently
- Focus on business logic
- Test error paths and edge cases
- Set minimum thresholds (80%+)
- Review coverage in PRs

========================================
EXECUTION
========================================

START: Configure Jest/Vitest (Phase 1)
CONTINUE: Configure exclusions (Phase 2)
CONTINUE: Add CI integration (Phase 3)
OPTIONAL: Add enforcement (Phase 4)
REMEMBER: Exclude tests, set thresholds
```

---

## Quick Reference

**What you get**: Complete code coverage setup with Jest/Vitest  
**Time**: 1 hour  
**Output**: Coverage reports in CI and locally
