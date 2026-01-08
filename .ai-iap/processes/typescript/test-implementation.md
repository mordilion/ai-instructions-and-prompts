# TypeScript/Node.js Testing Implementation Process

> **Purpose**: Establish comprehensive testing infrastructure for TypeScript/Node.js projects

## Critical Requirements

> **ALWAYS**: Detect Node.js version from `package.json` engines or `.nvmrc`
> **ALWAYS**: Match detected version in Docker images, pipelines, and CI/CD  
> **ALWAYS**: Use your team's workflow for branching and commits  
> **NEVER**: Fix production code bugs found during testing (log only)

## Workflow Adaptation

> **IMPORTANT**: This guide focuses on OBJECTIVES, not specific workflows.  
> **Your team's conventions take precedence** for:
> - Branch naming (feature/, PROJ-123/, or trunk-based)
> - Commit patterns (conventional commits, JIRA format, etc.)
> - Docker usage (skip if using serverless/PaaS)
> - CI/CD platform (adapt GitHub Actions examples)

## Tech Stack

**Required**:
- **Test Framework**: Jest or Vitest (detect existing or choose based on project type)
- **Assertions**: Built-in (Jest/Vitest) or Chai
- **Mocking**: Built-in (jest.mock/vi.mock)
- **Coverage**: Built-in (--coverage flag)
- **Runtime**: Match detected Node.js version

**Framework Selection**:
- Vite projects → Vitest (recommended)
- Next.js/React → Jest
- Node.js APIs → Jest or Vitest

## Infrastructure Templates

> **Docker is OPTIONAL**. Skip this section if you're using:
> - Serverless platforms (Vercel, Netlify, AWS Lambda)
> - PaaS (Heroku, Fly.io, Railway)
> - Your organization's existing containers

> **IF using Docker**: Replace `{NODE_VERSION}` with detected version before creating files

**File**: `docker/Dockerfile.tests` (optional)
```dockerfile
FROM node:{NODE_VERSION}-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .

FROM build AS test
WORKDIR /app
RUN mkdir -p /test-results /coverage
```

**File**: `docker/docker-compose.tests.yml`
```yaml
services:
  tests:
    build:
      context: ..
      dockerfile: docker/Dockerfile.tests
    command: npm test -- --coverage --ci --reporters=default --reporters=jest-junit
    environment:
      - JEST_JUNIT_OUTPUT_DIR=/test-results
    volumes:
      - ../test-results:/test-results
      - ../coverage:/coverage
```

**CI/CD Integration**:

> **NEVER**: Overwrite existing pipeline. Merge this step only.

**GitHub Actions**:
```yaml
- name: Run Tests
  run: |
    npm ci
    npm test -- --coverage --ci
  env:
    NODE_VERSION: {NODE_VERSION}
```

**GitLab CI**:
```yaml
test:
  image: node:{NODE_VERSION}-alpine
  script:
    - npm ci
    - npm test -- --coverage --ci
  artifacts:
    reports:
      junit: test-results/junit.xml
      coverage_report:
        coverage_format: cobertura
        path: coverage/cobertura-coverage.xml
```

## Implementation Phases

> **For each phase**: Use your team's workflow

### Phase 1: Analysis

**Objective**: Understand project structure and choose test framework

1. Detect Node.js version from `package.json` or `.nvmrc`
2. Detect project type (Vite/Next.js/Express/etc.)
3. Choose test framework (Jest for Next.js/React, Vitest for Vite, either for Node.js)
4. Analyze existing test setup (if any)
5. Document decisions

**Deliverable**: Testing strategy documented, framework chosen

### Phase 2: Infrastructure (Optional)

**Objective**: Set up test infrastructure (skip if using serverless/PaaS)

1. Create Docker test files (if using Docker)
2. Add/update CI/CD pipeline test step
3. Configure test reporting

**Deliverable**: Tests can run in CI/CD

### Phase 3: Framework Setup

**Objective**: Install and configure test framework

1. Install test framework:
   - Jest: `npm install --save-dev jest @types/jest ts-jest jest-junit`
   - Vitest: `npm install --save-dev vitest @vitest/ui @vitest/coverage-v8`
2. Create config file:
   - `jest.config.ts` or `vitest.config.ts`
3. Add test scripts to `package.json`:
   ```json
   {
     "scripts": {
       "test": "jest",
       "test:watch": "jest --watch",
       "test:coverage": "jest --coverage"
     }
   }
   ```

**Deliverable**: Framework installed, basic test runs

### Phase 4: Test Structure

**Objective**: Establish test directory organization and shared utilities

1. Create test directory structure:
   ```
   src/
   ├── __tests__/          # Unit tests
   ├── components/
   │   └── __tests__/      # Component tests
   tests/
   ├── integration/        # Integration tests
   ├── e2e/               # E2E tests
   └── helpers/           # Test utilities
   ```
2. Create shared test utilities:
   - `tests/helpers/testHelpers.ts` - Common test functions
   - `tests/helpers/mockData.ts` - Reusable mock data
   - `tests/helpers/setup.ts` - Test environment setup

**Deliverable**: Test structure in place, helpers available

### Phase 5: Test Implementation (Iterative)

**Objective**: Write tests for all components

**For each component**:
1. Understand component behavior and requirements
2. Write tests following patterns (see below):
   - Unit tests: `{filename}.test.ts`
   - Integration tests: `tests/integration/{feature}.test.ts`
3. Run tests locally → Ensure all pass
4. If bugs found → Log only (don't fix production code)

**Continue until**: All critical components tested

## Test Patterns

### Unit Test Pattern
```typescript
import { describe, it, expect, vi } from 'vitest'; // or from '@jest/globals'
import { MyService } from './MyService';

describe('MyService', () => {
  it('should handle success case', () => {
    const service = new MyService();
    const result = service.doSomething('input');
    expect(result).toBe('expected');
  });

  it('should handle error case', () => {
    const service = new MyService();
    expect(() => service.doSomething('')).toThrow();
  });
});
```

### React Component Test Pattern
```typescript
import { render, screen } from '@testing-library/react';
import { MyComponent } from './MyComponent';

describe('MyComponent', () => {
  it('should render correctly', () => {
    render(<MyComponent title="Test" />);
    expect(screen.getByText('Test')).toBeInTheDocument();
  });
});
```

### API Integration Test Pattern
```typescript
import request from 'supertest';
import { app } from '../src/app';

describe('API Endpoints', () => {
  it('GET /api/users should return users', async () => {
    const response = await request(app).get('/api/users');
    expect(response.status).toBe(200);
    expect(response.body).toHaveProperty('users');
  });
});
```

## Documentation (`process-docs/`)

- **STATUS-DETAILS.md**: Component test checklist
- **PROJECT_MEMORY.md**: Detected Node.js version + test framework choice + lessons learned
- **LOGIC_ANOMALIES.md**: Found bugs (audit only, don't fix)

## Usage

**Initial**:
```
Act as Senior SDET. Start TypeScript testing implementation.
Phase 1: Create branch `poc/test-establishing/init-analysis`, detect Node version, choose test framework, initialize docs.
```

**Continue**:
```
Act as Senior SDET. Check STATUS-DETAILS.md for next phase/component. Execute and propose commit.
```

