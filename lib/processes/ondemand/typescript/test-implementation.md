# TypeScript Testing Implementation - Copy This Prompt

> **Type**: One-time setup process  
> **When to use**: Setting up testing infrastructure in a TypeScript/Node.js project  
> **Instructions**: Copy the complete prompt below and paste into your AI tool

---

## 📋 Complete Self-Contained Prompt

```
========================================
TYPESCRIPT TESTING IMPLEMENTATION
========================================

CONTEXT:
You are implementing comprehensive testing infrastructure for a TypeScript project.

CRITICAL REQUIREMENTS:
- ALWAYS detect Node.js version from package.json engines or .nvmrc
- ALWAYS match detected version in Docker/CI/CD
- NEVER fix production code bugs (log in LOGIC_ANOMALIES.md only)
- Use team's Git workflow

========================================
TECH STACK
========================================

Test Framework: Jest ⭐ (recommended) / Vitest / Mocha + Chai
Assertions: Jest matchers ⭐ (recommended) / Chai / Vitest expect
Mocking: Jest mocks ⭐ (recommended) / Sinon / ts-mockito

========================================
CATCH-UP: READ EXISTING DOCUMENTATION
========================================

BEFORE starting, check for existing documentation:

1. Read PROJECT-MEMORY.md if it exists:
   - Node.js version used
   - Test framework chosen
   - Key decisions made
   - Lessons learned

2. Read LOGIC-ANOMALIES.md if it exists:
   - Bugs found but not fixed
   - Code smells discovered
   - Areas needing refactoring

3. Read TESTING-SETUP.md if it exists:
   - Current test configuration
   - Components already tested
   - Mock strategies in use

Use this information to:
- Continue from where previous work stopped
- Maintain consistency with existing decisions
- Avoid re-testing already covered components
- Build upon existing test infrastructure

If no docs exist: Start fresh and create them.

========================================
PHASE 1 - ANALYSIS
========================================

1. Detect Node.js version from package.json engines or .nvmrc
2. Document in PROJECT-MEMORY.md
3. Choose test framework (Jest recommended for TS)
4. Report findings

Deliverable: Testing strategy documented

========================================
PHASE 2 - INFRASTRUCTURE (Optional)
========================================

Create Dockerfile.tests:
```dockerfile
FROM node:{VERSION}-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm test
```

Add to CI/CD:
```yaml
- name: Test
  run: |
    npm ci
    npm test -- --coverage
```

Deliverable: Tests run in CI/CD

========================================
PHASE 3 - TEST PROJECT SETUP
========================================

1. Install dependencies:
```bash
npm install --save-dev jest @types/jest ts-jest
```

2. Configure jest.config.ts:
```typescript
export default {
  preset: 'ts-jest',
  testEnvironment: 'node',
  coverageDirectory: 'coverage',
  collectCoverageFrom: ['src/**/*.ts']
};
```

3. Create test structure:
   src/__tests__/ or tests/

4. Add test script to package.json:
```json
"scripts": {
  "test": "jest",
  "test:watch": "jest --watch"
}
```

Deliverable: Test infrastructure ready

========================================
PHASE 4 - WRITE TESTS (Iterative)
========================================

For each component:

1. Write unit tests:
```typescript
describe('MyService', () => {
  it('should handle success case', () => {
    // Given
    const service = new MyService();
    
    // When
    const result = service.process('input');
    
    // Then
    expect(result).toBe('expected');
  });
});
```

2. Mock dependencies:
```typescript
jest.mock('./repository');

it('should call repository', () => {
  const mockRepo = {
    find: jest.fn().mockResolvedValue(data)
  };
  const service = new Service(mockRepo);
  
  await service.process(1);
  
  expect(mockRepo.find).toHaveBeenCalledWith(1);
});
```

3. Test async code:
```typescript
it('should fetch data', async () => {
  const result = await service.fetchData();
  expect(result).toBeDefined();
});
```

4. Run tests: npm test (must pass)
5. If bugs found: Log to LOGIC-ANOMALIES.md
6. Update TESTING-SETUP.md with progress
7. Propose commit
8. Repeat

Deliverable: All components tested

========================================
DOCUMENTATION
========================================

Create/update these files for team catch-up:

**PROJECT-MEMORY.md** (Universal - all processes use):
```markdown
# Testing Implementation Memory

## Detected Versions
- Node.js: {version from .nvmrc or package.json}
- npm/yarn: {version}

## Framework Choices
- Test Framework: Jest v{version}
- Why: {reason for choosing Jest}

## Key Decisions
- Test location: src/__tests__/
- Mocking strategy: Jest mocks
- Coverage target: 80%+

## Lessons Learned
- {Any challenges encountered}
- {Solutions that worked well}
```

**LOGIC-ANOMALIES.md** (Universal - all processes use):
```markdown
# Logic Anomalies Found

## Bugs Discovered (Not Fixed)
1. **File**: path/to/file.ts
   **Issue**: Description of bug
   **Impact**: Severity level
   **Note**: Logged only, not fixed during setup

## Code Smells
- {Areas that need refactoring}

## Missing Tests
- {Components that need test coverage}
```

**TESTING-SETUP.md** (Process-specific):
```markdown
# Testing Setup Guide

## Quick Start
\```bash
npm test              # Run all tests
npm test -- --watch   # Watch mode
npm test -- --coverage # With coverage
\```

## Configuration
- Framework: Jest v{version}
- Config: jest.config.ts
- Coverage: 80%+ target

## Test Structure
- Unit: src/__tests__/**/*.test.ts
- Integration: tests/integration/**
- Utils: tests/utils/**

## Mocking Strategy
- External APIs: Jest mocks
- Database: In-memory or test DB
- Time: jest.useFakeTimers()

## Components Tested
- [ ] Component A
- [ ] Component B
- [x] Component C (completed)

## Coverage Status
- Current: {percentage}%
- Target: 80%
- Reports: coverage/lcov-report/index.html

## Troubleshooting
- **Timeout errors**: Increase jest.setTimeout()
- **Mock not working**: Check import paths
- **Low coverage**: Review coverage/index.html

## Maintenance
- Update snapshots: npm test -- -u
- Clear cache: npm test -- --clearCache
- Add test: Copy existing test pattern
\```

========================================
EXECUTION
========================================

START: Read existing docs (CATCH-UP section)
CONTINUE: Execute Phase 1 - detect Node version, choose frameworks
CONTINUE: Execute phases 2-4 iteratively
FINISH: Update all documentation files
REMEMBER: Use Jest mocks, don't fix bugs, iterate, document for catch-up
```

---

## Quick Reference

**What you get**: Complete test infrastructure with Jest, mocking, coverage  
**Time**: 4-8 hours depending on project size  
**Output**: Comprehensive test coverage with Jest
