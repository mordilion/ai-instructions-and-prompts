# Customization Guide

This guide explains how to extend or override AI instructions without modifying core files,
ensuring safe updates from the main repository.

---

## 📋 Table of Contents

- [Overview](#overview)
- [Directory Structure](#directory-structure)
- [Configuration](#configuration)
- [Adding Custom Rules](#adding-custom-rules)
- [Adding Custom Processes](#adding-custom-processes)
- [Adding Custom Functions](#adding-custom-functions)
- [Adding Custom Frameworks](#adding-custom-frameworks)
- [Overriding Core Files](#overriding-core-files)
- [Update Strategies](#update-strategies)
- [Examples](#examples)
- [Troubleshooting](#troubleshooting)

---

## Overview

The `.ai-iap-custom/` directory allows you to:

- ✅ **Extend** core configurations with company-specific standards
- ✅ **Override** core rules with team preferences
- ✅ **Add** custom processes for internal tools/platforms
- ✅ **Add** custom functions for company-specific code patterns
- ✅ **Pull updates** from main repo without merge conflicts
- ✅ **Share** customizations across your team (optional)

### How It Works

1. Core files live in `.ai-iap/` (never modify these)
2. Custom files live in `.ai-iap-custom/` (yours to manage)
3. Setup scripts merge custom config with core config
4. Custom rules files can override core files by matching paths
5. You can safely pull updates to `.ai-iap/` without conflicts

---

## Directory Structure

```text
.ai-iap-custom/
├── README.md                           # Quick reference
├── config.json                         # Custom configuration
├── rules/                              # Custom or override rules
│   ├── general/
│   │   └── company-security.md
│   ├── typescript/
│   │   ├── company-standards.md        # Additional rule
│   │   └── code-style.md               # Overrides core code-style.md
│   └── python/
│       └── ml-standards.md
├── processes/                          # Custom processes
│   ├── typescript/
│   │   └── deploy-internal.md
│   └── python/
│       └── deploy-sagemaker.md
└── functions/                          # Custom function patterns (NEW)
    ├── custom-auth-flow.md             # Company-specific auth pattern
    ├── custom-logging.md               # Internal logging service
    └── custom-cache.md                 # Company cache implementation
```

---

## Configuration

### config.json Structure

```json
{
  "version": "1.0.0-custom",
  "description": "Custom configuration for [Your Company]",
  "languages": {
    "typescript": {
      "customFiles": ["company-standards"],
      "customProcesses": {
        "deploy-internal": {
          "name": "Deploy to Internal Platform",
          "file": "deploy-internal",
          "description": "Deploy to company Kubernetes",
          "loadIntoAI": true
        }
      },
      "customFrameworks": {
        "remix": {
          "name": "Remix",
          "file": "remix",
          "category": "Full-Stack Framework",
          "description": "Company Remix standards",
          "recommended": true
        }
      }
    }
  },
  "customFunctions": {
    "custom-auth-flow": {
      "title": "Company SSO Authentication Flow",
      "file": "custom-auth-flow",
      "category": "Authentication",
      "languages": ["typescript", "python", "java", "csharp"],
      "description": "Authenticate with company SSO service",
      "tags": ["auth", "sso", "company-specific"]
    },
    "custom-logging": {
      "title": "Company Logging Service",
      "file": "custom-logging",
      "category": "Observability",
      "languages": ["typescript", "python"],
      "description": "Send logs to company DataDog instance",
      "tags": ["logging", "observability"]
    }
  }
}
```

### Configuration Properties

| Property          | Type   | Purpose                             | Example                     |
| ----------------- | ------ | ----------------------------------- | --------------------------- |
| `customFiles`     | array  | Additional rules to include         | `["company-standards"]`     |
| `customProcesses` | object | Custom implementation processes     | Deploy to internal platform |
| `customFrameworks`| object | Beta or company-specific frameworks | Internal UI framework       |

---

## Adding Custom Rules

Custom rules **extend** core rules without replacing them.

### Step 1: Create the Rule File

`.ai-iap-custom/rules/typescript/company-standards.md`:

```markdown
# TypeScript Company Standards

> **Scope**: All TypeScript projects at [Company]

## Import Organization

> **ALWAYS** organize imports:

1. External dependencies
2. Internal shared libraries (@company/...)
3. Relative imports

## Company Logger

> **ALWAYS** use company logger:

\`\`\`typescript
import { Logger } from '@company/logger';

const logger = new Logger('ServiceName');
logger.info('User created', { userId });
\`\`\`
```

### Step 2: Register in config.json

```json
{
  "languages": {
    "typescript": {
      "customFiles": ["company-standards"]
    }
  }
}
```

### Step 3: Run Setup

```bash
# Linux/Mac
./ai-iap/setup.sh

# Windows
.\.ai-iap\setup.ps1
```

The rule will be included alongside core TypeScript rules.

---

## Adding Custom Processes

Custom processes add company-specific implementation guides.

### Understanding Process Types

The system has two types of processes:

**📌 Permanent Processes** (in `.ai-iap/processes/permanent/`)

- Loaded into AI automatically during setup
- Used repeatedly throughout project lifecycle
- Example: `database-migrations.md`

**📋 On-Demand Processes** (in `.ai-iap/processes/ondemand/`)

- NOT loaded into AI automatically
- User copies prompt when ready to implement
- Examples: test-implementation, ci-cd, docker, logging, auth, etc.
- 85% token savings

### Custom Process Recommendations

For custom processes, consider:

- **Permanent**: Processes used repeatedly (e.g., internal deployment patterns)
- **On-Demand**: One-time setup processes (e.g., initial platform configuration)

### Step 1: Create the Process File

`.ai-iap-custom/processes/typescript/deploy-internal.md`:

```markdown
# Deploy to Internal Platform

> **Scope**: TypeScript/Node.js backend services

## Phase 1: Prepare Application

### 1.1: Create Dockerfile

\`\`\`dockerfile
FROM harbor.company.com/base/node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY dist/ ./dist/
CMD ["node", "dist/main.js"]
\`\`\`

## Phase 2: Deploy to Kubernetes

\`\`\`bash
kubectl apply -f deployment.yaml
\`\`\`

## AI Self-Check

- [ ] Uses company base image
- [ ] Health endpoints implemented
- [ ] Deployed to staging successfully
- [ ] Documentation updated
```

### Step 2: Register in config.json

```json
{
  "languages": {
    "typescript": {
      "customProcesses": {
        "deploy-internal": {
          "name": "Deploy to Internal Platform",
          "file": "deploy-internal",
          "description": "Deploy to company Kubernetes with Helm"
        }
      }
    }
  }
}
```

**Note about `loadIntoAI` flag**

- `true` = Permanent process (loaded into AI automatically, for recurring tasks)
- `false` or omitted = On-demand process (user copies prompt when needed, for one-time setups)

### Step 3: Run Setup

During setup, select your custom process when prompted.

---

## Adding Custom Functions

Custom functions add **company-specific implementation patterns** that your team uses frequently.
These are short (5-20 line) code patterns for common tasks.

### When to Add Custom Functions

✅ **Good use cases**:

- Company-specific authentication flows
- Internal logging service integration
- Company cache/Redis patterns
- Internal API client patterns
- Company-specific error reporting (Sentry, Datadog, etc.)
- Internal message queue patterns (RabbitMQ, Kafka, etc.)

❌ **Don't create custom functions for**:

- One-off implementations (use processes instead)
- Language-specific syntax (belongs in rules)
- Complete features (use processes instead)

### Step 1: Create Function File

`.ai-iap-custom/functions/custom-auth-flow.md`:

```markdown
---
title: Company SSO Authentication Flow
category: Authentication
difficulty: intermediate
languages:
  - typescript
  - python
  - java
  - csharp
tags:
  - auth
  - sso
  - company-specific
updated: 2026-01-09
---

# Company SSO Authentication Flow

> **Purpose**: Authenticate users with company SSO service
>
> **When to use**: All internal applications requiring user authentication

---

## TypeScript / JavaScript

### 📦 Dependencies

| Approach | Library | Installation | Use Case |
|----------|---------|--------------|----------|
| **Company Auth SDK** ⭐ | `@company/auth-sdk` | `npm install @company/auth-sdk` | Official company SDK |
| **Manual OAuth** | `oauth2` | `npm install oauth2` | Custom OAuth flow |

### Company Auth SDK (Recommended)

\`\`\`typescript
// Install: npm install @company/auth-sdk
import { CompanyAuth } from '@company/auth-sdk';

const auth = new CompanyAuth({
  clientId: process.env.COMPANY_CLIENT_ID,
  clientSecret: process.env.COMPANY_CLIENT_SECRET,
  redirectUri: 'https://app.example.com/callback'
});

// Login flow
async function login(email: string) {
  const authUrl = auth.getAuthorizationUrl({
    scope: ['profile', 'email'],
    state: generateState()
  });
  
  return { redirectUrl: authUrl };
}

// Callback handler
async function handleCallback(code: string) {
  const tokens = await auth.exchangeCodeForTokens(code);
  const user = await auth.getUserInfo(tokens.accessToken);
  
  return { user, tokens };
}
\`\`\`

---

## Python

### 📦 Dependencies

| Approach | Library | Installation | Use Case |
|----------|---------|--------------|----------|
| **Company Auth SDK** ⭐ | `company-auth-sdk` | `pip install company-auth-sdk` | Official company SDK |

### Company Auth SDK (Recommended)

\`\`\`python
# Install: pip install company-auth-sdk
from company_auth import CompanyAuth

auth = CompanyAuth(
    client_id=os.getenv('COMPANY_CLIENT_ID'),
    client_secret=os.getenv('COMPANY_CLIENT_SECRET'),
    redirect_uri='https://app.example.com/callback'
)

# Login flow
def login(email: str):
    auth_url = auth.get_authorization_url(
        scope=['profile', 'email'],
        state=generate_state()
    )
    return {'redirect_url': auth_url}

# Callback handler
async def handle_callback(code: str):
    tokens = await auth.exchange_code_for_tokens(code)
    user = await auth.get_user_info(tokens['access_token'])
    return {'user': user, 'tokens': tokens}
\`\`\`

---

## Best Practices

✅ **DO**:
- Store tokens securely (httpOnly cookies)
- Validate state parameter (CSRF protection)
- Refresh tokens before expiry
- Log authentication events

❌ **DON'T**:
- Store tokens in localStorage (XSS risk)
- Expose client secret in frontend
- Skip token validation
```

### Step 2: Register in config.json

Add to `.ai-iap-custom/config.json`:

```json
{
  "customFunctions": {
    "custom-auth-flow": {
      "title": "Company SSO Authentication Flow",
      "file": "custom-auth-flow",
      "category": "Authentication",
      "languages": ["typescript", "python", "java", "csharp"],
      "description": "Authenticate with company SSO service",
      "tags": ["auth", "sso", "company-specific"]
    },
    "custom-logging": {
      "title": "Company Logging Service",
      "file": "custom-logging",
      "category": "Observability",
      "languages": ["typescript", "python"],
      "description": "Send logs to company DataDog instance",
      "tags": ["logging", "observability"]
    }
  }
}
```

### Step 3: Update Custom INDEX

Create `.ai-iap-custom/functions/INDEX.md`:

```markdown
# Custom Functions Index

Company-specific implementation patterns.

## Available Custom Functions

| Function | Description | Languages | File |
|----------|-------------|-----------|------|
| **Company SSO Auth** | Company SSO authentication flow | TypeScript, Python, Java, C# | [custom-auth-flow.md](custom-auth-flow.md) |
| **Company Logging** | DataDog logging integration | TypeScript, Python | [custom-logging.md](custom-logging.md) |
| **Company Cache** | Redis cache patterns | All 8 | [custom-cache.md](custom-cache.md) |

## How to Use

1. Check this INDEX for company-specific patterns
2. Use core functions (`.ai-iap/functions/`) for generic patterns
3. Open relevant custom function file
4. Copy implementation with company credentials handling
```

### Step 4: Run Setup

The setup script will automatically merge your custom functions with core functions.

### Function File Structure

All function files (core and custom) should follow this structure:

```markdown
---
title: [Pattern Name]
category: [Category]
difficulty: [beginner|intermediate|advanced]
languages: [list of languages]
tags: [relevant, tags]
updated: YYYY-MM-DD
---

# [Pattern Name]

> **Purpose**: Brief description
> **When to use**: Use case description

---

## [Language 1]

### 📦 Dependencies

| Approach | Library | Installation | Use Case |
|----------|---------|--------------|----------|
| **Approach 1** ⭐ | `library` | `install command` | When to use |

### Code Implementation

\`\`\`language
// 5-20 lines of code
\`\`\`

---

## Best Practices

✅ **DO**: [list]
❌ **DON'T**: [list]
```

---

## Adding Custom Frameworks

Add beta frameworks or internal tools before they're in core.

### Step 1: Create Framework Rule

`.ai-iap-custom/rules/typescript/frameworks/remix.md`:

```markdown
# Remix Framework Standards

> **Scope**: TypeScript + Remix applications

## Project Structure

\`\`\`
app/
├── routes/           # File-based routing
├── components/       # Reusable UI components
└── utils/            # Helper functions
\`\`\`

## Route Conventions

> **ALWAYS** use loaders for data fetching:

\`\`\`typescript
export const loader = async ({ request }: LoaderArgs) => {
  return json({ data: await fetchData() });
};
\`\`\`
```

### Step 2: Register in config.json

```json
{
  "languages": {
    "typescript": {
      "customFrameworks": {
        "remix": {
          "name": "Remix",
          "file": "remix",
          "category": "Full-Stack Framework",
          "description": "React framework with nested routing",
          "recommended": true
        }
      }
    }
  }
}
```

### Step 3: Run Setup

Select Remix when choosing frameworks.

---

## Overriding Core Files

Override core files by creating a file with the **exact same path**.

### Example: Override TypeScript Code Style

**Core file** (don't modify):

```text
.ai-iap/rules/typescript/code-style.md
```

**Your override** (will be used instead):

```text
.ai-iap-custom/rules/typescript/code-style.md
```

Create your version:

```markdown
# TypeScript Code Style (Company Version)

> **NOTE**: This overrides the core code-style.md

## Company-Specific Rules

> **ALWAYS** use 4 spaces for indentation (not 2)

> **ALWAYS** use single quotes for strings

\`\`\`typescript
// Good
const greeting = 'Hello, world!';

// Bad
const greeting = "Hello, world!";
\`\`\`
```

When setup runs, your file will be used instead of the core file.

---

## Update Strategies

### Strategy A: Local Customizations (Default)

**Setup**: `.ai-iap-custom/` is git-ignored

```bash
# Pull updates safely
git pull origin main

# Your customizations remain untouched
# Re-run setup to regenerate with updates
./ai-iap/setup.sh
```

**Best for**: Individual developers or small teams

---

### Strategy B: Team Sharing

**Setup**: Commit `.ai-iap-custom/` to your repository

```bash
# Add to git
git add .ai-iap-custom/
git commit -m "chore: add company AI standards"
git push

# Team members get customizations automatically
# Everyone runs setup after pull
```

**Best for**: Teams with shared standards

---

### Strategy C: Separate Repository

**Setup**: Maintain `.ai-iap-custom/` as a separate repo

```bash
# Initialize as submodule or separate repo
cd .ai-iap-custom
git init
git remote add origin https://github.com/company/ai-standards

# Company-wide standards managed independently
# Can be shared across multiple projects
```

**Best for**: Large organizations with centralized standards

---

## Examples

### Example 1: Add Company Security Rules

**File**: `.ai-iap-custom/rules/general/company-security.md`

```markdown
# Company Security Standards

> **ALWAYS** follow OWASP Top 10

> **NEVER** commit secrets to git

> **ALWAYS** use company vault for credentials:

\`\`\`typescript
import { getSecret } from '@company/vault';

const apiKey = await getSecret('API_KEY');
\`\`\`
```

**Config**: `.ai-iap-custom/config.json`

```json
{
  "languages": {
    "general": {
      "customFiles": ["company-security"]
    }
  }
}
```

---

### Example 2: AWS SageMaker Deployment

**File**: `.ai-iap-custom/processes/python/deploy-sagemaker.md`

```markdown
# Deploy ML Model to SageMaker

## Phase 1: Prepare Model

\`\`\`python
import sagemaker
from sagemaker.sklearn import SKLearnModel

model = SKLearnModel(
    model_data='s3://bucket/model.tar.gz',
    role=role,
    entry_point='inference.py'
)
\`\`\`

## Phase 2: Deploy Endpoint

\`\`\`python
predictor = model.deploy(
    instance_type='ml.t2.medium',
    initial_instance_count=1
)
\`\`\`
```

**Config**:

```json
{
  "languages": {
    "python": {
      "customProcesses": {
        "deploy-sagemaker": {
          "name": "Deploy to SageMaker",
          "file": "deploy-sagemaker",
          "description": "Deploy ML models to AWS SageMaker"
        }
      }
    }
  }
}
```

---

### Example 3: Internal React Component Library

**File**: `.ai-iap-custom/rules/typescript/frameworks/company-ui.md`

```markdown
# Company UI Component Library

> **ALWAYS** use company design system components

\`\`\`typescript
import { Button, Card } from '@company/ui';

function MyComponent() {
  return (
    <Card>
      <Button variant="primary">Submit</Button>
    </Card>
  );
}
\`\`\`
```

**Config**:

```json
{
  "languages": {
    "typescript": {
      "customFrameworks": {
        "company-ui": {
          "name": "Company UI Library",
          "file": "company-ui",
          "category": "Component Library",
          "description": "Internal design system components"
        }
      }
    }
  }
}
```

---

### Example 4: Custom Function - Company Cache Pattern

**File**: `.ai-iap-custom/functions/custom-cache.md`

```markdown
---
title: Company Redis Cache Pattern
category: Performance
difficulty: intermediate
languages: [typescript, python, java, csharp]
tags: [cache, redis, performance, company-specific]
updated: 2026-01-09
---

# Company Redis Cache Pattern

> **Purpose**: Cache data using company Redis cluster
>
> **When to use**: Frequently accessed data, API responses, session storage

---

## TypeScript

### 📦 Dependencies

| Approach | Library | Installation | Use Case |
|----------|---------|--------------|----------|
| **Company Redis SDK** ⭐ | `@company/redis` | `npm install @company/redis` | Company Redis cluster |

\`\`\`typescript
import { CompanyRedis } from '@company/redis';

const redis = CompanyRedis.connect({
  cluster: process.env.REDIS_CLUSTER // company-prod, company-staging
});

// Cache with TTL
async function cacheUser(userId: string, userData: User) {
  await redis.setex(
    `user:${userId}`,
    3600, // 1 hour TTL
    JSON.stringify(userData)
  );
}

// Get from cache
async function getUser(userId: string): Promise<User | null> {
  const cached = await redis.get(`user:${userId}`);
  return cached ? JSON.parse(cached) : null;
}

// Cache-aside pattern
async function getUserWithCache(userId: string): Promise<User> {
  const cached = await getUser(userId);
  if (cached) return cached;
  
  const user = await database.getUser(userId);
  await cacheUser(userId, user);
  return user;
}
\`\`\`
```

**Config**: `.ai-iap-custom/config.json`

```json
{
  "customFunctions": {
    "custom-cache": {
      "title": "Company Redis Cache Pattern",
      "file": "custom-cache",
      "category": "Performance",
      "languages": ["typescript", "python", "java", "csharp"],
      "description": "Cache using company Redis cluster",
      "tags": ["cache", "redis", "performance"]
    }
  }
}
```

**Custom INDEX**: `.ai-iap-custom/functions/INDEX.md`

```markdown
# Custom Functions Index

| Function | Description | Languages | File |
|----------|-------------|-----------|------|
| **Company Cache** | Redis cache patterns | TypeScript, Python, Java, C# | [custom-cache.md](custom-cache.md) |
| **Company Auth** | SSO authentication | TypeScript, Python | [custom-auth-flow.md](custom-auth-flow.md) |
```

---

## Troubleshooting

### Custom Files Not Appearing

**Problem**: Custom rules/processes don't show up after running setup

**Solutions**:

1. Validate JSON: `jq empty .ai-iap-custom/config.json`
2. Check file paths match exactly
3. Ensure file extensions are `.md`
4. Re-run setup script

---

### JSON Validation Errors

**Problem**: "Custom config file contains invalid JSON"

**Solutions**:

1. Use a JSON validator: [jsonlint.com](https://jsonlint.com)
2. Common issues:
   - Missing commas between properties
   - Trailing commas (not allowed in JSON)
   - Unmatched brackets `{}`
   - Missing quotes around strings
3. Copy from `config.example.json` as a starting point

---

### Override Not Working

**Problem**: Core file still being used instead of custom file

**Solutions**:

1. Verify exact path match:

   ```text
   Core:   .ai-iap/rules/typescript/code-style.md
   Custom: .ai-iap-custom/rules/typescript/code-style.md  ✓
   ```

2. Check file is not empty
3. Ensure `.md` extension
4. Re-run setup script

---

### Merge Conflicts When Pulling

**Problem**: Git conflicts in `.ai-iap/` when pulling updates

**Solution**: You should NEVER modify core files. If you have conflicts:

```bash
# Reset core files to upstream
git checkout origin/main -- .ai-iap/

# Keep your customizations separate
# They live in .ai-iap-custom/ (no conflicts)

# Re-run setup
./ai-iap/setup.sh
```

---

### Custom Process Not Selectable

**Problem**: Custom process doesn't appear in selection menu

**Solutions**:

1. Check `customProcesses` is under correct language
2. Verify process file exists at specified path
3. Ensure `file` property matches filename (without `.md`)
4. Process files go in `processes/`, not `rules/`

---

## Best Practices

### ✅ DO

- Keep customizations in `.ai-iap-custom/`
- Use descriptive names for custom files
- Include company name in custom rules
- Document internal tools and processes
- Share examples with your team
- Version control your customizations (optional)
- Test after pulling updates

### ❌ DON'T

- Modify files in `.ai-iap/` directory
- Duplicate core content in custom files
- Hardcode credentials in custom files
- Skip validation after changes
- Forget to re-run setup after updates

---

## Testing & Verification

### Verify Extension System

Before or after making changes, verify the extension system is working:

```bash
# Linux/Mac
./.ai-iap/verify-extension.sh

# Windows
.\.ai-iap\verify-extension.ps1
```

The verification script tests:

- File structure (example files exist)
- Git configuration (proper ignores)
- Documentation completeness
- Script integration (merge functions)
- Config structure validity

**Result**: 15 tests should pass with 0 failures.

### Automated Testing

The extension system is tested automatically:

- ✅ On every commit via GitHub Actions
- ✅ On every pull request
- ✅ Cross-platform (Linux + Windows)

Check the Actions tab on GitHub to see test results.

---

## Additional Resources

- **Main README**: [README.md](README.md)
- **Custom Examples**: [.ai-iap-custom/README.md](.ai-iap-custom/README.md)
- **Configuration Schema**: [.ai-iap-custom/config.example.json](.ai-iap-custom/config.example.json)
- **Troubleshooting**: See above or file an issue

---

## Questions?

Having trouble with customizations? Check:

1. Example files in `.ai-iap-custom/`
2. This guide's troubleshooting section
3. Main project README
4. Open an issue on GitHub

**Remember**: The goal is to customize without modifying core files, ensuring safe updates! 🎯
