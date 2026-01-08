# TypeScript/Node.js Testing Implementation Process

> **ALWAYS**: Follow phases sequentially. One branch per phase. Atomic commits only.

## Critical Requirements

> **ALWAYS**: Detect Node.js version from `package.json` engines or `.nvmrc`
> **ALWAYS**: Match detected version in Docker images, pipelines, and CI/CD
> **ALWAYS**: Create new branch for each phase (adapt naming to your workflow - see [Git Workflow Adaptation](../_templates/git-workflow-adaptation.md))
> **NEVER**: Combine multiple phases in one commit
> **NEVER**: Fix production code bugs found during testing (log only)

## Workflow Adaptation

> **Important**: This guide uses example branch names (`poc/test-establishing/{phase-name}`).  
> **Your team's Git conventions take precedence**.  
> See [Git Workflow Adaptation Guide](../_templates/git-workflow-adaptation.md) for adapting to:
> - JIRA/Linear integration
> - Trunk-based development
> - GitFlow, GitHub Flow
> - Your custom naming conventions

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

### Phase 1: Analysis
**Branch**: `poc/test-establishing/init-analysis`

1. Initialize `process-docs/` (STATUS-DETAILS.md, PROJECT_MEMORY.md, LOGIC_ANOMALIES.md)
2. Detect Node.js version from `package.json` or `.nvmrc` → Document in PROJECT_MEMORY.md
3. Detect if Vite/Next.js/Express → Choose Jest or Vitest
4. Analyze existing test setup
5. Propose commit → Wait for user

### Phase 2: Infrastructure
**Branch**: `poc/test-establishing/docker-infra`

1. Create `docker/Dockerfile.tests` with detected version
2. Create `docker/docker-compose.tests.yml`
3. Merge CI/CD pipeline step (don't overwrite)
4. Propose commit → Wait for user

### Phase 3: Framework Setup
**Branch**: `poc/test-establishing/framework-setup`

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
4. Propose commit → Wait for user

### Phase 4: Test Structure
**Branch**: `poc/test-establishing/project-skeleton`

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
2. Implement base patterns:
   - `tests/helpers/testHelpers.ts`
   - `tests/helpers/mockData.ts`
   - `tests/helpers/setup.ts`
3. Configure test setup files
4. Propose commit → Wait for user

### Phase 5: Test Implementation (Loop)
**Branch**: `poc/test-establishing/test-{component}` (new branch per component)

1. Read next untested component from STATUS-DETAILS.md
2. Understand intent and behavior
3. Write tests following patterns:
   - Unit tests: `{filename}.test.ts` or `__tests__/{filename}.test.ts`
   - Integration tests: `tests/integration/{feature}.test.ts`
4. Run tests locally → Must pass
5. If bugs found → Log to LOGIC_ANOMALIES.md (DON'T fix code)
6. Update STATUS-DETAILS.md
7. Propose commit: `feat(test): add tests for {Component}`
8. Wait for user confirmation → Repeat for next component

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

