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
└── processes/                          # Custom processes
    ├── typescript/
    │   └── deploy-internal.md
    └── python/
        └── deploy-sagemaker.md
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
          "description": "Deploy to company Kubernetes"
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

### Step 3: Run Setup

During setup, select your custom process when prompted.

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

**Result**: 16 tests should pass with 0 failures.

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
