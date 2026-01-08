# TypeScript Linting & Formatting - Copy This Prompt

> **Type**: One-time setup process  
> **When to use**: Setting up linting and code formatting  
> **Instructions**: Copy the complete prompt below and paste into your AI tool

---

## 📋 Complete Self-Contained Prompt

```
========================================
TYPESCRIPT LINTING & FORMATTING
========================================

CONTEXT:
You are setting up linting and code formatting for a TypeScript/Node.js project.

CRITICAL REQUIREMENTS:
- ALWAYS use ESLint + Prettier
- NEVER ignore errors without justification
- Use .eslintrc and .prettierrc for configuration
- Enforce in CI pipeline

========================================
PHASE 1 - ESLINT
========================================

Install:
```bash
npm install --save-dev eslint @typescript-eslint/parser @typescript-eslint/eslint-plugin
```

Create .eslintrc.json:
```json
{
  "parser": "@typescript-eslint/parser",
  "parserOptions": {
    "ecmaVersion": 2022,
    "sourceType": "module",
    "project": "./tsconfig.json"
  },
  "plugins": ["@typescript-eslint"],
  "extends": [
    "eslint:recommended",
    "plugin:@typescript-eslint/recommended",
    "plugin:@typescript-eslint/recommended-requiring-type-checking"
  ],
  "rules": {
    "@typescript-eslint/no-unused-vars": ["error", { "argsIgnorePattern": "^_" }],
    "@typescript-eslint/explicit-function-return-type": "warn",
    "@typescript-eslint/no-explicit-any": "error"
  },
  "ignorePatterns": ["dist/", "node_modules/", "*.js"]
}
```

Add scripts to package.json:
```json
{
  "scripts": {
    "lint": "eslint . --ext .ts",
    "lint:fix": "eslint . --ext .ts --fix"
  }
}
```

Deliverable: ESLint configured

========================================
PHASE 2 - PRETTIER
========================================

Install:
```bash
npm install --save-dev prettier eslint-config-prettier
```

Create .prettierrc:
```json
{
  "semi": true,
  "trailingComma": "es5",
  "singleQuote": true,
  "printWidth": 100,
  "tabWidth": 2,
  "useTabs": false
}
```

Update .eslintrc.json:
```json
{
  "extends": [
    "eslint:recommended",
    "plugin:@typescript-eslint/recommended",
    "prettier"
  ]
}
```

Add scripts:
```json
{
  "scripts": {
    "format": "prettier --write \"src/**/*.ts\"",
    "format:check": "prettier --check \"src/**/*.ts\""
  }
}
```

Deliverable: Prettier configured

========================================
PHASE 3 - CI INTEGRATION
========================================

Add to .github/workflows/ci.yml:
```yaml
- name: Lint
  run: npm run lint

- name: Format check
  run: npm run format:check

- name: Type check
  run: npm run type-check
```

Add to package.json:
```json
{
  "scripts": {
    "type-check": "tsc --noEmit"
  }
}
```

Deliverable: Automated checks in CI

========================================
PHASE 4 - PRE-COMMIT HOOKS
========================================

Install husky and lint-staged:
```bash
npm install --save-dev husky lint-staged
npx husky init
```

Update package.json:
```json
{
  "lint-staged": {
    "*.ts": [
      "eslint --fix",
      "prettier --write"
    ]
  }
}
```

Create .husky/pre-commit:
```bash
#!/usr/bin/env sh
. "$(dirname -- "$0")/_/husky.sh"

npx lint-staged
```

Deliverable: Pre-commit hooks enabled

========================================
BEST PRACTICES
========================================

- Use ESLint + Prettier
- Disable conflicting rules (eslint-config-prettier)
- Enable strict TypeScript rules
- Add pre-commit hooks
- Fail CI on violations
- Exclude dist and node_modules

========================================
EXECUTION
========================================

START: Configure ESLint (Phase 1)
CONTINUE: Configure Prettier (Phase 2)
CONTINUE: Add CI checks (Phase 3)
OPTIONAL: Add pre-commit hooks (Phase 4)
REMEMBER: Strict rules, enforce in CI
```

---

## Quick Reference

**What you get**: Complete linting and formatting setup  
**Time**: 30 minutes  
**Output**: ESLint, Prettier, husky, lint-staged, CI integration
