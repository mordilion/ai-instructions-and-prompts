# Customization Guide

This guide explains how to extend or override AI instructions without modifying core files,
ensuring safe updates from the main repository.

---

## 📋 Table of Contents

- [Overview](#overview)
- [Directory Structure](#directory-structure)
- [Configuration](#configuration)
- [Adding Custom Rules](#adding-custom-rules)
- [Adding Custom Claude Code Agents](#adding-custom-claude-code-agents)
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

1. Core files live in the plugin's `lib/` directory (never modify these)
2. Custom files live in `.ai-iap-custom/` in your project (yours to manage)
3. The `/ai-iap:setup` skill merges custom config with core config
4. Custom rules files can override core files by matching paths
5. Plugin updates don't affect your customizations

---

## Directory Structure

```text
.ai-iap-custom/
├── README.md                           # Quick reference
├── config.json                         # Custom configuration
├── claude-agents.json                  # Optional: custom Claude Code agents (rule-bound)
├── rules/                              # Custom or override rules
│   ├── general/
│   │   └── compliance-standards.md      # Optional override of core compliance rule
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

```text
/ai-iap:setup
```

The rule will be included alongside core TypeScript rules.

---

## Adding Custom Claude Code Agents

When you use **Claude Code** and run setup, you can choose **role-based agents** that get **project rules
injected** (e.g. iOS Developer, PHP Developer, Vue.js Developer, SEO Specialist, UI/UX Designer). You can
also **define your own agents** so they use your chosen languages and frameworks.

### Built-in vs custom

- **Built-in**: `lib/claude-subagents.json (plugin)` defines generic subagents (code-reviewer, test-writer, …) and
  **agentTemplates** (ios-developer, php-developer, vue-developer, seo-specialist, ui-ux-designer). Templates use
  `ruleBindings` to inject rules from this repo.
- **Custom**: Create `.ai-iap-custom/claude-agents.json` with the same shape as `agentTemplates`. Setup merges them
  into the agent list; when you select them, it generates `.claude/agents/<name>.md` with the injected rules.

### Custom agents file format

Create `.ai-iap-custom/claude-agents.json`:

```json
{
  "description": "Optional description",
  "agents": [
    {
      "id": "my-role",
      "name": "my-role",
      "description": "When Claude should use this agent (e.g. iOS development with Swift).",
      "ruleBindings": { "general": [], "swift": ["ios", "swiftui"] },
      "personaSpecialization": "software",
      "tools": "Read, Glob, Grep, Write, Edit, Bash",
      "model": "sonnet"
    }
  ]
}
```

- **ruleBindings**: Object. Keys = language IDs from `config.json` (e.g. `general`, `swift`, `php`, `typescript`,
  `html`, `css`). Values = array of framework IDs for that language (e.g. `["laravel"]`, `["vue"]`, `["tailwind"]`).
  Use `[]` for language-only rules.
- **personaSpecialization**: Optional. One agent = one specialisation. Values: `software` (iOS/PHP/Vue/backend/frontend
  developer), `seo` (discoverability, meta, structured data), `ui-ux` (design system, components, accessibility),
  `testing` (test strategy, QA, automation), `devops` (CI/CD, infra, SRE), `generic` (full adaptive persona that asks
  about user role). Default: `software`. When set, the agent gets **persona-core** + **persona-specialist-{value}**
  instead of the full multi-role persona.
- **tools**: Comma-separated Claude Code tool names (e.g. `Read, Grep, Glob, Write, Edit, Bash`).
- **model**: `sonnet`, `opus`, `haiku`, or `inherit`.

### Persona split (one agent, one specialisation)

Rules under `lib/rules/general/` include a **persona** that defines how the AI behaves. For agents, the setup can
inject a **split persona** so each agent has a single specialisation:

- **persona-core.md** – Shared rules (defensive programming, clarification gate, code library lookup, self-check).
  No multi-role table.
- **persona-specialist-software.md** – Senior Software Engineer: decides technical approach; asks about requirements
  and scope.
- **persona-specialist-seo.md** – SEO specialist: focuses on meta, structured data, discoverability; asks about
  business goals and content strategy.
- **persona-specialist-ui-ux.md** – UI/UX and design system: focuses on components, accessibility, layout; asks about
  brand and user flows.
- **persona-specialist-testing.md** – Testing/QA: test strategy, unit/integration/e2e, automation; asks about
  acceptance criteria and coverage goals.
- **persona-specialist-devops.md** – DevOps/SRE: CI/CD, infra, deployment, observability; asks about environments and
  deployment strategy.

When `personaSpecialization` is `software`, `seo`, `ui-ux`, `testing`, or `devops`, the agent prompt uses
**persona-core** + the matching specialist file. When `generic` or omitted, the full **persona.md** (with
role-adaptive behavior) is used.

Example: an **iOS Developer**, **PHP Developer**, **Vue.js Developer (TypeScript)**, **SEO Specialist**, and
**UI/UX Designer** are in `lib/examples/claude-agents.example.json`.
Copy that file to `.ai-iap-custom/claude-agents.json`, run setup,
select Claude Code and then “Set up Claude Code agents?”, and pick the roles you want.
Generated agents in `.claude/agents/` will contain the injected project rules.

---

## Adding Custom Processes

Custom processes add company-specific implementation guides.

### Understanding Process Types

The system has two types of processes:

**📌 Permanent Processes** (in `lib/processes/permanent/`)

- Loaded into AI automatically during setup
- Used repeatedly throughout project lifecycle
- Example: `database-migrations.md`

**📋 On-Demand Processes** (in `lib/processes/ondemand/`)

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

Custom functions are **company-specific implementation patterns** your team uses repeatedly.
They live in `.ai-iap-custom/code-library/functions/` so they stay **update-safe** when the plugin updates.

### When to Add Custom Functions

✅ **Good use cases**:

- Company-specific auth flows or permission checks
- Internal API client wrappers
- Company logging/redaction conventions
- Standard cache key patterns and invalidation helpers
- Webhook signature verification for internal systems

❌ **Don't create custom functions for**:

- One-off implementations (use processes instead)
- Language syntax/style rules (belongs in rules)
- Full workflows (use processes instead)

### Step 1: Create the Function File (Template-based)

- Copy `lib/code-library/functions/_TEMPLATE.md` to:
  - `.ai-iap-custom/code-library/functions/<your-function>.md`
- Replace the YAML frontmatter values.
- Keep **only code examples** after the YAML header.
- **No installation commands** inside function files.

### Step 2 (Optional): Add a Custom Functions INDEX

If you create multiple custom functions, add:

- `.ai-iap-custom/code-library/functions/INDEX.md`

This helps AIs find company patterns faster.

### Step 3: Ensure AIs Search Custom Patterns First

In your project’s AI rules, add a small directive like:

- Check `.ai-iap-custom/code-library/functions/` (if it exists) for custom implementation patterns
- Check `.ai-iap-custom/code-library/design-patterns/` (if it exists) for custom design patterns
- Then check `lib/code-library/` for core patterns

---

### Example Custom Function

Create `.ai-iap-custom/code-library/functions/company-auth-header.md`:

```markdown
---
title: Company Auth Header Patterns
category: Security
difficulty: beginner
purpose: Add the company auth header consistently for internal API calls
when_to_use:
  - Calling internal APIs
  - Service-to-service requests
  - Mobile app API requests
languages:
  typescript:
    - name: fetch header (Built-in)
      library: javascript-core
      recommended: true
    - name: axios interceptor
      library: axios
  python:
    - name: httpx client header
      library: httpx
      recommended: true
    - name: requests session header
      library: requests
  csharp:
    - name: HttpClient default header
      library: System.Net.Http
      recommended: true
best_practices:
  do:
    - Read tokens from environment or secure storage
    - Use a single shared client per service
  dont:
    - Hardcode tokens in source code
    - Log tokens or headers containing secrets
tags: [auth, headers, internal-api]
updated: 2026-01-09
---

## TypeScript

### fetch header (Built-in)
```typescript
const response = await fetch(url, {
  headers: { Authorization: `Bearer ${token}` },
});
```

### axios interceptor

```typescript
import axios from 'axios';

const client = axios.create();
client.interceptors.request.use((config) => {
  config.headers = config.headers ?? {};
  config.headers.Authorization = `Bearer ${token}`;
  return config;
});
```

---

## Python

### httpx client header

```python
import httpx

client = httpx.Client(headers={"Authorization": f"Bearer {token}"})
resp = client.get(url)
```

### requests session header

```python
import requests

session = requests.Session()
session.headers["Authorization"] = f"Bearer {token}"
resp = session.get(url)
```

---

## C\#

### HttpClient default header

```csharp
using System.Net.Http.Headers;

httpClient.DefaultRequestHeaders.Authorization =
    new AuthenticationHeaderValue("Bearer", token);
```

### Function File Structure Rules

- Start from `lib/code-library/functions/_TEMPLATE.md`
- Put all metadata in YAML frontmatter
- After the YAML header: **code examples only**
- Keep examples short and copy-paste ready

---

## Adding Custom Design Patterns

Custom design patterns are **company-specific architectural implementations** that extend or
specialize the core design patterns library.

### When to Add Custom Design Patterns

✅ **Good use cases**:

- Company-specific architectural patterns unique to your domain
- Industry-specific pattern implementations (e.g., financial, healthcare, e-commerce)
- Custom framework integrations for standard patterns (e.g., Singleton with company DI container)
- Team-preferred pattern variants with company conventions

❌ **Don't create custom patterns for**:

- Standard Gang of Four patterns without customization (use core library)
- Patterns that work universally across all companies
- One-off implementations (document in code comments instead)

### Step 1: Start from Template

Copy the design pattern template:

```bash
cp lib/code-library/design-patterns/_TEMPLATE.md \
   .ai-iap-custom/code-library/design-patterns/[category]/your-pattern.md
```

Choose category: `creational`, `structural`, or `behavioral`

### Step 2: Implement for All Languages

Update the template with:

- Pattern name and purpose
- Company-specific use cases
- Complete implementations (20-100 lines) for all 8 languages
- Usage examples showing real-world application
- Related patterns and functions

### Step 3: Update Custom Index

Add entry to `.ai-iap-custom/code-library/design-patterns/INDEX.md` (create if doesn't exist):

```markdown
## Company Design Patterns

| Pattern | Category | When to Use | File |
|---------|----------|-------------|------|
| **Company Service Locator** | Creational | Internal DI container integration | [creational/service-locator.md](creational/service-locator.md) |
```

### Step 4: Verify AI Priority

AIs automatically check:

1. `.ai-iap-custom/code-library/design-patterns/` first ← **Your patterns**
2. Then `lib/code-library/design-patterns/` ← Core patterns

### Example: Company Singleton with DI

Create `.ai-iap-custom/code-library/design-patterns/creational/di-singleton.md`:

```markdown
---
title: DI Container Singleton Pattern
category: Creational Design Pattern
difficulty: beginner
purpose: Integrate company DI container with singleton pattern for service registration
when_to_use:
  - Company microservices requiring DI container registration
  - Internal API clients that need singleton + DI
  - Logger instances with DI container
  - Cache managers with company DI conventions
# ... rest of YAML frontmatter
---

## TypeScript

### NestJS Singleton Provider (Recommended)

\`\`\`typescript
import { Injectable } from '@nestjs/common';

@Injectable()
export class ConfigService {
  private static instance: ConfigService;
  
  constructor() {
    if (ConfigService.instance) {
      return ConfigService.instance;
    }
    ConfigService.instance = this;
  }
  
  // Company-specific config methods
}
\`\`\`

**Usage Example:**
\`\`\`typescript
// Automatically registered as singleton via @Injectable
const config = app.get(ConfigService);
\`\`\`
```

### Design Pattern File Structure

- Start from `lib/code-library/design-patterns/_TEMPLATE.md`
- Put all metadata in YAML frontmatter
- After the YAML header: **complete implementations** (20-100 lines)
- Include usage examples for each language
- Show real-world patterns from your codebase

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
lib/rules/typescript/code-style.md
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

### Strategy A: Team Sharing (Recommended)

**Setup**: Commit `.ai-iap-custom/` so your team shares the same:

- rules overrides
- custom processes
- custom function patterns

```bash
# Pull updates safely
git pull origin main

# Re-run setup to regenerate outputs with the shared customizations
.//ai-iap:setup
```

**Best for**: Teams (recommended when using shared functions/custom patterns)

---

### Strategy B: Local-Only Customizations (Advanced)

**Setup**: Keep `.ai-iap-custom/` local and do NOT commit it

```bash
# Keep customizations private to your machine/user
# (not recommended if you want shared function patterns)
```

**Best for**: Individual developers experimenting locally (NOT recommended if you want shared custom function patterns)

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

### Example 1: Override Compliance Standards (Optional)

**Use case**: You want to replace the core compliance guidance with your org’s policy details.

**File**: `.ai-iap-custom/rules/general/compliance-standards.md` (same path as core rule)

```markdown
# Compliance Standards (Company / Project)

> **ALWAYS** follow your compliance policy for this repo (data classification, retention, access)

> **NEVER** store or log secrets/credentials in source control

> **ALWAYS** ensure audit logs exist for privileged actions and data export
```

**Config**: No config changes required for overrides (custom file wins automatically).

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

**File**: `.ai-iap-custom/code-library/functions/custom-cache.md`

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

**Custom INDEX**: `.ai-iap-custom/code-library/functions/INDEX.md`

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
   Core:   lib/rules/typescript/code-style.md
   Custom: .ai-iap-custom/rules/typescript/code-style.md  ✓
   ```

2. Check file is not empty
3. Ensure `.md` extension
4. Re-run setup script

---

### Plugin Update Issues

**Problem**: Behavior changes after plugin update

**Solution**: The plugin's core files (`lib/`) update automatically. Your customizations
in `.ai-iap-custom/` are unaffected. Re-run `/ai-iap:setup` to regenerate rules with
the latest plugin version.

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

- Modify files in the plugin's `lib/` directory
- Duplicate core content in custom files
- Hardcode credentials in custom files
- Skip validation after changes
- Forget to re-run setup after updates

---

## Testing & Verification

### Verify Extension System

Before or after making changes, verify the extension system is working:

```text
/ai-iap:validate
```

The validation skill checks:

- Plugin structure and manifest
- Config file validity and completeness
- All referenced rule files exist
- Custom config structure validity
- Documentation completeness

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
