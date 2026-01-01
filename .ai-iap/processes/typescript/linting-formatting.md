# Linting & Formatting Setup (TypeScript)

> **Goal**: Establish automated code linting and formatting in existing TypeScript projects

## Phase 1: Choose Linting & Formatting Tools

> **ALWAYS**: Use a linter (code quality) + formatter (code style)
> **ALWAYS**: Run linter/formatter in CI/CD pipeline
> **NEVER**: Mix multiple formatters (choose one)
> **NEVER**: Skip pre-commit hooks

### Recommended Tools

| Tool | Type | Use Case | Setup |
|------|------|----------|-------|
| **ESLint** ⭐ | Linter | Code quality, errors | `npm install --save-dev eslint` |
| **Prettier** ⭐ | Formatter | Code style | `npm install --save-dev prettier` |
| **TypeScript Compiler** | Type checker | Type safety | Built-in (`tsc`) |
| **Biome** | Linter + Formatter | All-in-one | `npm install --save-dev @biomejs/biome` |

---

## Phase 2: Linter Configuration

### ESLint Setup

```bash
# Install
npm install --save-dev eslint @typescript-eslint/parser @typescript-eslint/eslint-plugin

# Initialize
npx eslint --init
```

**Configuration** (`.eslintrc.json`):
```json
{
  "parser": "@typescript-eslint/parser",
  "parserOptions": {
    "ecmaVersion": "latest",
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
    "@typescript-eslint/no-unused-vars": "error",
    "@typescript-eslint/no-explicit-any": "warn",
    "@typescript-eslint/explicit-function-return-type": "off",
    "no-console": "warn"
  },
  "ignorePatterns": ["dist/", "build/", "node_modules/"]
}
```

---

## Phase 3: Formatter Configuration

### Prettier Setup

```bash
# Install
npm install --save-dev prettier

# Create config
echo {} > .prettierrc.json
```

**Configuration** (`.prettierrc.json`):
```json
{
  "semi": true,
  "trailingComma": "es5",
  "singleQuote": true,
  "printWidth": 100,
  "tabWidth": 2,
  "useTabs": false,
  "arrowParens": "always",
  "endOfLine": "lf"
}
```

**Ignore** (`.prettierignore`):
```
dist
build
node_modules
coverage
*.md
```

### ESLint + Prettier Integration

```bash
# Install integration
npm install --save-dev eslint-config-prettier eslint-plugin-prettier
```

**Update** (`.eslintrc.json`):
```json
{
  "extends": [
    "eslint:recommended",
    "plugin:@typescript-eslint/recommended",
    "plugin:prettier/recommended"
  ]
}
```

---

## Phase 4: IDE Integration & Pre-commit Hooks

### VS Code Setup

**Extensions** (`.vscode/extensions.json`):
```json
{
  "recommendations": [
    "dbaeumer.vscode-eslint",
    "esbenp.prettier-vscode"
  ]
}
```

**Settings** (`.vscode/settings.json`):
```json
{
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": true
  },
  "eslint.validate": ["javascript", "typescript"]
}
```

### Pre-commit Hooks (Husky + lint-staged)

```bash
# Install
npm install --save-dev husky lint-staged
npx husky init
```

**Configuration** (`package.json`):
```json
{
  "scripts": {
    "lint": "eslint . --ext .ts,.tsx",
    "lint:fix": "eslint . --ext .ts,.tsx --fix",
    "format": "prettier --write \"src/**/*.{ts,tsx,json,md}\"",
    "format:check": "prettier --check \"src/**/*.{ts,tsx,json,md}\""
  },
  "lint-staged": {
    "*.{ts,tsx}": [
      "eslint --fix",
      "prettier --write"
    ]
  }
}
```

**Husky Hook** (`.husky/pre-commit`):
```bash
#!/usr/bin/env sh
npx lint-staged
```

---

## Phase 5: CI/CD Integration

### GitHub Actions

```yaml
# .github/workflows/lint.yml
name: Lint & Format Check

on:
  push:
    branches: [main, develop]
  pull_request:

jobs:
  lint:
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
      
      - name: Run ESLint
        run: npm run lint
      
      - name: Run Prettier Check
        run: npm run format:check
      
      - name: Run TypeScript Compiler
        run: npx tsc --noEmit
```

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| **ESLint slow** | Use `--cache` flag, exclude `node_modules` |
| **Prettier conflicts** | Use `eslint-config-prettier` to disable style rules |
| **TypeScript errors in tests** | Add separate `tsconfig.spec.json` |
| **Husky hooks not running** | Run `npx husky install` after clone |

---

## Best Practices

> **ALWAYS**: Format code before commit (pre-commit hooks)
> **ALWAYS**: Run linter in CI/CD
> **ALWAYS**: Fix all linter errors before merge
> **ALWAYS**: Use consistent style across team (.editorconfig)
> **NEVER**: Disable linter rules without team discussion
> **NEVER**: Commit code with linter errors
> **NEVER**: Mix tabs and spaces

---

## AI Self-Check

- [ ] ESLint configured with TypeScript support?
- [ ] Prettier configured with consistent style?
- [ ] ESLint + Prettier integrated (no conflicts)?
- [ ] Pre-commit hooks installed (Husky + lint-staged)?
- [ ] VS Code extensions configured?
- [ ] CI/CD runs linter and formatter checks?
- [ ] All linter errors fixed?
- [ ] TypeScript compiler (`tsc --noEmit`) passing?
- [ ] `.editorconfig` file present?
- [ ] Team trained on linting/formatting standards?

---

## Tools Comparison

| Tool | Type | Speed | Extensibility | Best For |
|------|------|-------|---------------|----------|
| ESLint | Linter | Medium | ⭐⭐⭐ | Code quality |
| Prettier | Formatter | Fast | ⭐ | Code style |
| TypeScript | Type checker | Medium | N/A | Type safety |
| Biome | Both | Very Fast | ⭐⭐ | All-in-one |

