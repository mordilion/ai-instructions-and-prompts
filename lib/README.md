# AI Instructions & Prompts

**Consistent AI coding standards for Claude Code across all your projects.**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20macOS%20%7C%20Linux-blue.svg)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](../CONTRIBUTING.md)

---

## The Problem

AI coding assistants need configuration to produce consistent, high-quality code. Without it, you end up with:
- Inconsistent code quality between projects
- No standard for architecture and code style
- Copy-pasting the same rules everywhere

## The Solution

**AI Instructions & Prompts** is a portable collection of coding rules. Define your standards once, generate Claude Code configurations automatically.

```
Your Rules (one source) → /ai-iap:setup → Claude Code Configured
```

---

## ✨ Features

- **🧠 Role-Based Adaptive AI** – AI detects your expertise level (Product Manager, Software Engineer, DevOps, Junior) and adapts its questions accordingly – eliminates assumptions and provides role-appropriate guidance
- **✅ Rule Compliance** – AI must follow all applicable rules; nothing is optional unless explicitly marked
- **🌍 Multi-Language** – Kotlin, JavaScript, TypeScript, HTML, CSS, Sass/SCSS, Less, PostCSS, Stylus, YAML, JSON, dotenv (.env), Dockerfile, SQL, Java, Python, Dart/Flutter, .NET/C#, PHP, Swift, Node.js, Bash, PowerShell
- **📦 Framework-Specific** – React, Next.js, NestJS, AdonisJS, Laravel, ASP.NET Core, Spring Boot, Django, FastAPI,
  Tailwind CSS, Bootstrap, and 52+ more
- **🏗️ Structure Templates** – Clean Architecture, Vertical Slices, Feature-First, Modular, MVVM, MVI, DDD, and more
- **🎨 UI/Design Rules** – Reusable component-first UI guidance (variants, states, accessibility, tokens)
- **🔒 Security Rules** – OWASP Top 10 coverage for all languages (token-optimized, 80% more efficient)
- **📚 Documentation Standards** – Optional code, project, and API documentation standards with smart suggestions
- **🔄 Process Guides** – CI/CD, Testing, Logging, Docker, Auth, Migrations, API Docs (78 files across core application languages, token-optimized)
- **🎨 Extension System** – Add company standards, override rules, custom processes without modifying core (update-safe)
- **⚡ Interactive Setup** – Wizard guides you through configuration with context-aware suggestions
- **🎯 Recommended Defaults** – Best practices marked with `⭐`
- **✅ Quality Verified** – Conflict-free system verified across the repository (95% confidence)

---

## 🧠 Role-Based Adaptive AI (New!)

The AI assistant now **intelligently adapts** its behavior based on your role and expertise level, **eliminating assumptions** and providing appropriate guidance.

### How It Works

**On first interaction**, the AI will ask:
- "What's your role?" (Product Manager, Software Engineer, DevOps, etc.)
- "What's your technical expertise level?" (Beginner, Intermediate, Expert)

### Adaptive Behavior

| Your Role | AI Decides | AI Asks You About |
|-----------|------------|-------------------|
| **Product/Project Manager** | ✅ Design patterns<br>✅ Architecture<br>✅ Tech stack | ❓ Business logic<br>❓ Requirements<br>❓ User flows |
| **Software Engineer** | ✅ Code structure (standard) | ❓ Design patterns<br>❓ Architecture decisions<br>❓ Tech preferences |
| **DevOps/SysAdmin** | ✅ Deployment (standard) | ❓ Infrastructure<br>❓ CI/CD tools<br>❓ Monitoring |
| **Junior/Beginner** | ✅ Best practices<br>✅ Architecture | ❓ Learning goals<br>❓ Feature requirements |

### Example Interaction

**Product Manager**:
```
User: "Add authentication"
AI: "I'll implement secure JWT authentication with refresh tokens.
     Do you need social login (Google/GitHub)?"
```

**Software Engineer**:
```
User: "Add authentication"
AI: "Let's discuss the technical approach:
     1. JWT or session-based?
     2. Storage: Redis, database, in-memory?
     3. OAuth providers needed?
     4. Specific design pattern preference?"
```

**Result**: No more assumptions, appropriate questions for your expertise level!

### Rule Compliance

All rules loaded into the AI context are **mandatory**. AIs must follow all applicable rules and **must not** treat any rule as optional unless explicitly marked optional.

---

## 🚀 Quick Start

### 1. Install the Plugin

Install the **AI Instructions & Prompts** Claude Code plugin (from the marketplace, git submodule, or your team’s distribution). Open your project in Claude Code so the plugin’s skills are available.

### 2. Run Setup

In Claude Code, run:

```
/ai-iap:setup
```

### Scope: Project vs Global

When you run setup, you choose where to apply the configuration:

- **This project** – Generated files go into the current directory (e.g. `.claude/`). State is stored in `.ai-iap-state.json` in the project. Use for version-controlled, per-repo setup.
- **Global (user)** – Generated files go to your home directory (e.g. `~/.claude/`). State is stored in `~/.ai-iap-state.json`. Use for personal defaults across all projects.

### Setup split: Rules vs Agents

Setup is driven by the plugin’s **setup skill** (`skills/setup/SKILL.md` in this repo). Use the slash command that matches what you want to configure:

- **Rules** – Run **`/ai-iap:setup`** (languages, frameworks, structures, processes, then generates `.claude/rules/**/*.md` and `CLAUDE.md`).
- **Agents** – Run **`/ai-iap:setup agents`** (define Claude Code agents, then generates `.claude/agents/*.md`).

You can also run **`/ai-iap:setup`** and choose **Rules only** or **Agents only** when the wizard prompts you.

### Re-running Setup (Add/Remove Languages)

You can safely run setup multiple times.

- The setup skill stores your last choices in `.ai-iap-state.json` (project) or `~/.ai-iap-state.json` (global)
- On rerun, you can **reuse**, **modify**, or **clean up** previously generated outputs
- Cleanup is **safe by default**: only files marked `aiIapManaged: true` (in YAML frontmatter) are removed

When you choose **Modify selection**, the wizard will show your previous selection and use it as the default:

- Press **Enter** to keep the previous selection at each step
- Enter a new list of numbers to **add/remove** items
- Use **`s`** (skip) on optional steps (documentation/frameworks/processes/structures) to remove previously selected items

### Generated Outputs

Setup generates the following Claude Code outputs into your chosen **output root** (project directory or home directory for global scope):

| Output | Description |
|--------|-------------|
| `.claude/rules/**/*.md` | Modular rule files with YAML frontmatter (`aiIapManaged: true`, optional `paths:` globs) |
| `CLAUDE.md` | Project rules file (generated from `rules/general/claude-project-rules.md`) |
| `.claude/agents/*.md` | Optional subagents (via `setup-agents`) |

### 3. Follow the Wizard

The setup wizard will guide you through:

**Step 1: Where to apply (scope)**
Choose **This project** or **Global (user)**. When running **`/ai-iap:setup`**, choose **Rules only** or **Agents only** (or use **`/ai-iap:setup agents`** to go straight to agents).

**Step 2: Select Languages**
```
Select language instructions to include:
  1. Dart/Flutter
  2. JavaScript
  3. TypeScript
  ...
```

**Step 3: Select Documentation Standards** (Optional)
```
Select documentation standards to include:
(Choose based on your project type)

  1. Code Documentation ⭐
      Inline comments, docstrings, JSDoc, XML docs
  2. Project Documentation ⭐
      README, CHANGELOG, CONTRIBUTING, LICENSE
  3. API Documentation ⭐ (backend/fullstack)
      REST APIs, OpenAPI/Swagger, SDK documentation

  ⭐ = recommended
  a. All documentation
  s. Skip (no documentation standards)

Suggestion for frontend-only project: 1 2 (code + project)

Enter choices: 1 2
```

**Step 4: Commit Standards** (Optional)
```
Enable commit standards (Conventional Commits) rules?
Enable commit standards? (y/N):
```

**Step 5: Select Frameworks, Structures & Processes** (if applicable)

**Claude Code agents** (run **`/ai-iap:setup agents`**)

Agents are always defined by you: no presets. **One agent = one specialisation.** You choose how many agents and for each:

- **Name** (slug, e.g. ios-developer)
- **Description** (when Claude should use this agent)
- **Tech stack** – preset (iOS, Vue.js, PHP Laravel, SEO, UI/UX, SEO & Linguistic) or Custom (pick languages and frameworks from config)
- **Persona specialisation** – Software/Developer (default), SEO, UI/UX, or Generic (full adaptive persona). Each agent gets a focused persona slice so behaviour matches its role (see [CUSTOMIZATION.md](../CUSTOMIZATION.md#persona-split-one-agent-one-specialisation)).

Example: "I need 4 agents: one for iOS, one for Vue.js, one for SEO and Linguistic, one for PHP with Laravel" → run **`/ai-iap:setup agents`**, enter 4, then for each agent set name, description, tech stack, and persona. Generated files go to `.claude/agents/` (or global scope).

That's it! Your Claude Code instance is now configured with consistent coding standards.

---

## 🎨 Customization & Extensions

Want to add company-specific standards, internal processes, or override core rules? Use the **extension system**:

### Create Custom Config

```
.ai-iap-custom/
├── config.json                    # Your customizations
├── rules/
│   └── typescript/
│       └── company-standards.md   # Company-specific rules
└── processes/
    └── typescript/
        └── deploy-internal.md     # Internal deployment guide
```

### Three Ways to Extend

1. **Add Custom Rules** – Extend core rules with company standards
   ```json
   {
     "languages": {
       "typescript": {
         "customFiles": ["company-standards"]
       }
     }
   }
   ```

2. **Add Custom Processes** – Internal tools and platforms
   ```json
   {
     "languages": {
       "typescript": {
         "customProcesses": {
           "deploy-internal": {
             "name": "Deploy to Internal Platform",
             "file": "deploy-internal"
           }
         }
       }
     }
   }
   ```

3. **Override Core Files** – Replace core rules with team preferences
   ```
   .ai-iap-custom/rules/typescript/code-style.md
   → Overrides lib/rules/typescript/code-style.md
   ```

### Update Strategies

| Strategy | Setup | Best For |
|----------|-------|----------|
| **Team Sharing** (Recommended) | Install the same plugin version for everyone; commit `.ai-iap-custom/` and `.ai-iap-state.json` for shared overrides and last-known setup | Teams (shared standards + shared function patterns) |
| **Separate Repo** | Maintain `.ai-iap-custom/` as submodule | Large orgs, company-wide |
| **Local Only** (Advanced) | Keep `.ai-iap-custom/` uncommitted | Individual experimentation |

### Benefits

- ✅ Pull updates from main repo without conflicts
- ✅ Keep company secrets/processes private
- ✅ Share customizations across team (optional)
- ✅ Test beta frameworks before core inclusion
- ✅ Maintain compliance requirements separately

**📚 Full Documentation**: See [CUSTOMIZATION.md](../CUSTOMIZATION.md) for complete guide with examples.

---

## 🌐 Supported Languages & Frameworks

### JavaScript (Browser)
| Category | Frameworks |
|----------|------------|
| UI Framework | React ⭐, Vue.js, Preact |
| Full-Stack | Svelte/SvelteKit |
| Lightweight | Alpine.js |
| Legacy | jQuery |

### TypeScript (Browser & Backend)
| Category | Frameworks |
|----------|------------|
| UI Framework | React ⭐, Vue.js, Angular |
| Full-Stack | Next.js ⭐, Svelte/SvelteKit |
| Backend | NestJS ⭐, AdonisJS ⭐ (TypeScript-first MVC) |
| ORM | Prisma ⭐ |

### Node.js (JS or TS)
| Category | Frameworks |
|----------|------------|
| Backend | Express.js ⭐, Fastify, Koa, Hapi |

### HTML
HTML rules (including guidance for safe JavaScript embedding).

### CSS
| Category | Frameworks |
|----------|------------|
| Utility-First | Tailwind CSS ⭐ |
| Component-Based | Bootstrap |

CSS base rules (including style blocks in component files like `.vue` / `.svelte`).

### Sass/SCSS
Sass/SCSS rules (modules, nesting discipline, tokens, maintainable architecture).

### Less
Less rules (variables, mixins, maintainable structure).

### PostCSS
PostCSS rules (plugin-based CSS processing and supply-chain awareness).

### Stylus
Stylus rules (consistent conventions, maintainable structure).

### YAML
YAML rules (CI/CD pipelines, Kubernetes manifests, Docker Compose, tool configs).

### JSON
JSON rules (tooling configs, manifests like `package.json`, application configs).

### dotenv (.env)
`.env` rules (safe environment configuration, `.env.example`, no secrets in git).

### Dockerfile
Dockerfile rules (secure, reproducible builds; multi-stage; no secrets in images).

### SQL
SQL rules (injection prevention, safe migrations, basic performance hygiene).

### Java
| Category | Frameworks |
|----------|------------|
| Backend | Spring Boot ⭐ |
| Mobile | Android ⭐ |
| ORM | Hibernate/JPA ⭐ |
| Testing | JUnit |

### Swift
| Category | Frameworks |
|----------|------------|
| Mobile | iOS (UIKit) ⭐, SwiftUI ⭐ |
| Backend | Vapor ⭐ |
| Persistence | Core Data ⭐ |
| Reactive | Combine ⭐ |

### Kotlin
| Category | Frameworks |
|----------|------------|
| Mobile | Android ⭐ |
| Backend | Spring Boot ⭐, Ktor ⭐ |
| ORM | Exposed ⭐ |

### Python
| Category | Frameworks |
|----------|------------|
| Full-Stack | Django ⭐ |
| Backend | FastAPI ⭐ |
| Micro Framework | Flask |
| ORM | SQLAlchemy ⭐ |
| Validation | Pydantic ⭐ |

### Dart/Flutter
| Category | Frameworks |
|----------|------------|
| UI Framework | Flutter ⭐ |
| State Management | BLoC ⭐, Riverpod, GetX |

### .NET/C#
| Category | Frameworks |
|----------|------------|
| Web Framework | ASP.NET Core ⭐ |
| UI Framework | Blazor, .NET MAUI |
| ORM | Entity Framework Core ⭐, Dapper |
| Pattern | MediatR ⭐ |

### PHP
| Category | Frameworks |
|----------|------------|
| Full-Stack | Laravel ⭐, Symfony ⭐, Laminas MVC |
| Micro Framework | Slim, Laminas Mezzio |
| CMS | WordPress |
| ORM | Doctrine ⭐ |

### Bash
Shell scripting rules (no frameworks).

### PowerShell
PowerShell scripting rules (no frameworks).

⭐ = Recommended

---

## 🏗️ Project Structure Options

For supported frameworks, choose how you want to organize your code:

| Framework | Available Structures |
|-----------|---------------------|
| **Flutter** | Feature-First ⭐, Layer-First, Clean Architecture |
| **React (JS/TS)** | Modular ⭐, Layered, Atomic Design |
| **Angular** | Modular, Standalone ⭐ |
| **NestJS** | Modular ⭐, Layered |
| **AdonisJS** | Modular/Domain ⭐, MVC/Traditional |
| **ASP.NET Core** | Clean Architecture ⭐, Vertical Slices, N-Tier |
| **Laravel** | Modular ⭐, Traditional, DDD |
| **Django** | Traditional ⭐, Modular, DDD |
| **FastAPI** | Modular ⭐, Layered, Clean Architecture |
| **iOS (UIKit)** | MVVM ⭐, MVI, Clean Architecture |
| **SwiftUI** | MVVM ⭐, MVI, Clean Architecture |
| **Vapor** | Modular ⭐, Layered, Clean Architecture |
| **Spring Boot (Java)** | Clean Architecture ⭐, Modular, Layered |
| **Spring Boot (Kotlin)** | Clean Architecture ⭐, Modular, Layered |
| **Android (Java)** | MVVM ⭐, MVI, Clean Architecture |
| **Android (Kotlin)** | MVVM ⭐, MVI, Clean Architecture |
| **Ktor** | Modular ⭐, Layered, Clean Architecture |

---

## 🔄 Process Guides

In addition to coding rules, this system includes **step-by-step workflow guides** for common development tasks. These are optimized for AI assistants to follow and implement.

### Process Types

**📌 Permanent Processes** (Loaded into AI):
- **Database Migrations** - Used repeatedly throughout project lifecycle
- Automatically loaded during setup
- Always available in AI context

**📋 On-Demand Processes** (Copy when needed):
- **Testing, CI/CD, Docker, Logging, Auth, API Docs, Security, Linting, Coverage**
- One-time setup processes
- Copy prompt from `lib/processes/ondemand/{language}/{process}.md` when ready to implement
- **85% token savings** - Only load what you need, when you need it

### How to Use On-Demand Processes

1. Navigate to `lib/processes/ondemand/{language}/{process}.md`
2. Scroll to **"Usage - Copy This Complete Prompt"** section
3. Copy the entire prompt block
4. Paste into Claude Code
5. AI will guide you through implementation

### Available Processes (All 8 Core Application Languages)

| Process Type | Type | Description | Status |
|--------------|------|-------------|--------|
| **Database Migrations** | 📌 Permanent | Version-controlled schema changes, rollbacks, seed data | ✅ 8 files |
| **Testing Implementation** | 📋 On-Demand | NUnit, Jest, JUnit, pytest, XCTest, PHPUnit, flutter_test | ✅ 8 files |
| **CI/CD (GitHub Actions)** | 📋 On-Demand | Build, test, deploy pipelines with version detection | ✅ 8 files |
| **Logging & Observability** | 📋 On-Demand | Structured logging, metrics, tracing, error tracking | ✅ 8 files |
| **Docker Containerization** | 📋 On-Demand | Multi-stage Dockerfiles, docker-compose, production optimizations | ✅ 8 files |
| **Authentication (JWT + OAuth)** | 📋 On-Demand | JWT auth, OAuth 2.0, RBAC, security hardening | ✅ 7 files |
| **API Documentation (OpenAPI)** | 📋 On-Demand | Swagger/OpenAPI spec generation, auto-documentation | ✅ 7 files |
| **Security Scanning** | 📋 On-Demand | SAST/DAST vulnerability scanning (OWASP, Snyk, etc.) | ✅ 8 files |
| **Linting & Formatting** | 📋 On-Demand | Code quality linting and style formatting | ✅ 8 files |
| **Code Coverage** | 📋 On-Demand | Automated coverage tracking with thresholds | ✅ 8 files |

**Total**: 78 process files (8 permanent, 70 on-demand) across 8 core application languages (not including Bash/PowerShell)

### Process Quality Features

1. **Smart Loading**: Permanent processes loaded into AI, on-demand processes copied when needed (85% token savings)
2. **Self-Contained Prompts**: Each on-demand process includes complete, copy-paste prompt with all context
3. **Phase-Based**: Each process divided into 4-5 clear phases with objectives and deliverables
4. **Understandability-First**: Clarity prioritized over brevity - same result across all AI models
5. **Token-Optimized**: 30-40% shorter than traditional docs where clarity is maintained
6. **AI-Optimized**: Explicit directives (`> **ALWAYS**`, `> **NEVER**`), clear implementation steps
7. **Version Flexible**: No hardcoded versions - reads from project config files (.nvmrc, global.json, pom.xml, etc.)
8. **Platform Guidance**: GitHub Actions primary, with guidance for GitLab CI, Azure DevOps, CircleCI, Jenkins
9. **Consistent Structure**: Git Workflow reference, table format comparisons, troubleshooting sections
10. **DRY Principle**: Process files reference general documentation standards instead of duplicating content

> **Design Philosophy**: Files may exceed token guidelines when framework complexity requires it. All lengths are justified by the need for clear, unambiguous instructions that produce consistent results across different AI models.

---

## 🎯 Code Library (NEW)

In addition to rules and processes, the system now includes a **comprehensive code library** with implementation patterns and design patterns across all 8 core application languages. This **reduces AI guessing by 70-80%** and ensures consistent, secure implementations.

### What's in the Code Library?

The code library contains two types of patterns:

1. **Implementation Patterns** (17 patterns) - Tactical, 5-20 line code snippets for common coding tasks
2. **Design Patterns** (15 patterns) - Strategic, 20-100 line architectural patterns (Creational, Structural, Behavioral)

All patterns are shown **across all 8 core application languages** in a single file with multiple framework variants.

### Implementation Patterns (17)

| Function | Purpose | Languages | File |
|----------|---------|-----------|------|
| **Error Handling** | Exception handling, custom errors, error propagation | All 8 | [error-handling.md](code-library/functions/error-handling.md) |
| **Async Operations** | Async/await, promises, parallel execution, timeouts | All 8 | [async-operations.md](code-library/functions/async-operations.md) |
| **Input Validation** | Data validation, sanitization, type checking | All 8 | [input-validation.md](code-library/functions/input-validation.md) |
| **Database Queries** | Safe queries, parameterization, SQL injection prevention | All 8 | [database-query.md](code-library/functions/database-query.md) |
| **HTTP Requests** | API calls, retry logic, timeout handling | All 8 | [http-requests.md](code-library/functions/http-requests.md) |
| **Logging** | Structured logs, correlation IDs, redaction | All 8 | [logging.md](code-library/functions/logging.md) |
| **Caching** | TTL caches, invalidation, distributed caching | All 8 | [caching.md](code-library/functions/caching.md) |
| **Config & Secrets** | Env/config loading, fail-fast validation, redaction | All 8 | [config-secrets.md](code-library/functions/config-secrets.md) |
| **Auth & Authorization** | JWT/session auth, RBAC/policy checks | All 8 | [auth-authorization.md](code-library/functions/auth-authorization.md) |
| **Rate Limiting** | Throttling, 429 handling, abuse protection | All 8 | [rate-limiting.md](code-library/functions/rate-limiting.md) |
| **Webhooks** | Signature verification, idempotency basics | All 8 | [webhooks.md](code-library/functions/webhooks.md) |
| **Money & Decimals** | Minor units, decimal math, rounding rules | All 8 | [money-decimal.md](code-library/functions/money-decimal.md) |
| **File Operations** | Upload, download, streaming, safe deletion | All 8 | [file-operations.md](code-library/functions/file-operations.md) |
| **Pagination** | Offset, cursor, keyset pagination for APIs | All 8 | [pagination.md](code-library/functions/pagination.md) |
| **Background Jobs** | Task queues, scheduling, async processing | All 8 | [background-jobs.md](code-library/functions/background-jobs.md) |
| **Email Sending** | SMTP, templates, attachments, notifications | All 8 | [email-sending.md](code-library/functions/email-sending.md) |
| **Search & Filtering** | Query building, full-text search, dynamic filters | All 8 | [search-filtering.md](code-library/functions/search-filtering.md) |

### Design Patterns (15)

| Category | Pattern | When to Use | File |
|----------|---------|-------------|------|
| **Creational** | Singleton | Database connections, loggers, cache managers | [singleton.md](code-library/design-patterns/creational/singleton.md) |
| **Creational** | Factory Method | Multiple payment providers, notification systems | [factory-method.md](code-library/design-patterns/creational/factory-method.md) |
| **Creational** | Abstract Factory | Multi-cloud providers (AWS/Azure/GCP) | [abstract-factory.md](code-library/design-patterns/creational/abstract-factory.md) |
| **Creational** | Builder | Complex objects with many optional parameters | [builder.md](code-library/design-patterns/creational/builder.md) |
| **Structural** | Adapter | Third-party library integration, legacy systems | [adapter.md](code-library/design-patterns/structural/adapter.md) |
| **Structural** | Decorator | Adding logging, authentication, caching layers | [decorator.md](code-library/design-patterns/structural/decorator.md) |
| **Structural** | Facade | Simplifying complex APIs, SDK wrappers | [facade.md](code-library/design-patterns/structural/facade.md) |
| **Structural** | Proxy | Lazy initialization, access control, caching | [proxy.md](code-library/design-patterns/structural/proxy.md) |
| **Structural** | Composite | UI component trees, file systems | [composite.md](code-library/design-patterns/structural/composite.md) |
| **Behavioral** | Observer | Event handling, pub/sub messaging | [observer.md](code-library/design-patterns/behavioral/observer.md) |
| **Behavioral** | Strategy | Multiple payment methods, algorithms | [strategy.md](code-library/design-patterns/behavioral/strategy.md) |
| **Behavioral** | Command | Undo/redo functionality, task queues | [command.md](code-library/design-patterns/behavioral/command.md) |
| **Behavioral** | Template Method | Testing frameworks, data processing pipelines | [template-method.md](code-library/design-patterns/behavioral/template-method.md) |
| **Behavioral** | Chain of Responsibility | HTTP middleware, validation chains | [chain-of-responsibility.md](code-library/design-patterns/behavioral/chain-of-responsibility.md) |
| **Behavioral** | State | Workflow engines, order processing states | [state.md](code-library/design-patterns/behavioral/state.md) |

**All patterns cover**: TypeScript, Python, Java, C#, PHP, Kotlin, Swift, Dart

**Browse complete library**: [code-library/INDEX.md](code-library/INDEX.md)

### 🚨 CRITICAL RULE for AI Assistants

**BEFORE** implementing any patterns or design patterns, **ALWAYS CHECK** `code-library/INDEX.md` first:

```
AI Workflow:
1. User asks to implement a pattern (errors/async/validation/DB/HTTP/Singleton/Factory/etc.)
2. AI checks custom patterns first (if they exist):
   - `.ai-iap-custom/code-library/functions/` for custom implementation patterns
   - `.ai-iap-custom/code-library/design-patterns/` for custom design patterns
3. AI then checks `lib/code-library/INDEX.md` ← MANDATORY STEP
4. AI navigates to functions/ or design-patterns/ based on need
5. AI opens relevant pattern file (e.g., error-handling.md, creational/singleton.md)
6. AI chooses appropriate framework version (Plain, Prisma, Laravel, etc.)
7. AI copies exact pattern (no installation commands in pattern files)
8. AI implements with zero guessing
```

**DO NOT** waste tokens generating these patterns from scratch.
**DO NOT** guess implementations when proven patterns exist.

**Benefit**: Saves 70-80% of tokens + ensures consistent, secure code.

---

### How to Use

1. **Check the INDEX first**: Open [code-library/INDEX.md](code-library/INDEX.md) to find the pattern you need
2. **Navigate to the right category**: Implementation patterns in `functions/` or Design patterns in `design-patterns/`
3. **Open the pattern file**: Each file shows implementations for all 8 languages side-by-side
4. **Choose your framework**: Plain (flexibility) or Framework (productivity)
5. **Copy the exact pattern**: Use the language-specific implementation (no installation commands in function files)
6. **Stop AI guessing**: Precise patterns = consistent code = fewer bugs

### Benefits

✅ **Consistency**: Same pattern across all your projects
✅ **Security**: Validated, safe implementations (prevent SQL injection, XSS, etc.)
✅ **Token Efficiency**: AI doesn't waste tokens guessing, uses proven pattern
✅ **Cross-Language**: Easy to compare implementations when switching languages
✅ **Reduced Errors**: Less guessing = fewer bugs

### Functions vs Processes vs Rules

| Aspect | Rules | Processes | Functions |
|--------|-------|-----------|-----------|
| **What** | Principles & standards | Step-by-step workflow | Exact code patterns |
| **Size** | 1-2 pages | 5-15 pages | 5-20 lines of code |
| **Scope** | High-level guidelines | Complete implementation | Single coding task |
| **Example** | "Handle errors gracefully" | "Set up CI/CD pipeline" | "try/catch with custom errors" |
| **Organization** | One file per language | One file per language | All languages in one file |

### Selecting Documentation Standards

During setup, you'll be prompted to select documentation standards:

```
Select documentation standards to include:
(Choose based on your project type)

  1. Code Documentation ⭐
      Inline comments, docstrings, JSDoc, XML docs
  2. Project Documentation ⭐
      README, CHANGELOG, CONTRIBUTING, LICENSE
  3. API Documentation ⭐ (backend/fullstack)
      REST APIs, OpenAPI/Swagger, SDK documentation

  s. Skip (no documentation standards)
  a. All documentation

Enter choices: 1 2
```

**Smart Suggestions:**
- **Frontend-only projects** (Dart/Flutter): `1 2` (code + project)
- **Backend/Fullstack projects**: `a` (all documentation)
- **Libraries**: `1` (code only)

### Selecting Processes

During setup, you'll be prompted to select processes for each language:

```
Select processes for .NET/C#:
(Workflow guides for establishing infrastructure)

  1. Testing Implementation - Establish NUnit testing in existing projects

  s. Skip (no processes)
  a. All processes

Enter choices: 1
```

---

## ⚙️ Configuration

### Rule Priority

When rules are loaded, they're applied in this order (highest to lowest):

1. **Structure rules** – Folder organization (when selected)
2. **Framework rules** – React, Laravel, etc.
3. **Language architecture** – TypeScript, PHP, etc.
4. **Language code style** – Language-specific conventions
5. **General architecture** – Universal structure principles
6. **General code style** – Universal coding conventions

### Optional Rules (Setup Toggles)

In the shipped `lib/config.json`, `languages.general` does **not** define an `optionalRules` object; general rule sources are listed in `languages.general.files` (including `accessibility`, `i18n`, and `commit-standards`). The setup wizard applies toggles in practice—for example, it skips generating `commit-standards` when commit standards are disabled, and documentation rules come from `languages.general.documentation` only when you select them. The `optionalRules` shape exists in `lib/config.schema.json` (and the setup skill describes checking it) as the planned schema for toggle-gated optional rules; it is not yet populated on `languages.general` in the repo’s `config.json`.

### Combining Frameworks

You can select multiple frameworks per language. Common combinations:

```
TypeScript:  React + Prisma
             Next.js + Prisma
             NestJS + Prisma

.NET:        ASP.NET Core + EF Core + MediatR
             Blazor + EF Core

PHP:         Symfony + Doctrine
             Laravel (includes Eloquent)
```

---

## 📊 Token Cost Analysis

Understanding how many tokens your rule selection consumes helps optimize AI context window usage.

### Total Available Tokens by Language

| Language | Base (+Security) | Documentation (Optional) | Frameworks | Structures | Total |
|----------|------------------|--------------------------|------------|------------|-------|
| **General** (always loaded) | 7,068 + 1,186 | 3,585 (if all selected) | – | – | **8,254 - 11,839** |
| **TypeScript** | 1,994 + 1,102 | – | 5,800 | 1,540 | **~12,436** |
| **JavaScript** | 1,563 + 1,058 | – | 1,162 | – | **~6,783** |
| **Java** | 1,746 + 1,097 | – | 4,910 | 1,725 | **~11,478** |
| **Python** | 1,167 + 1,346 | – | 10,060 | 1,585 | **~16,158** |
| **Kotlin** | 1,527 + 1,022 | – | 25,815 | 1,770 | **~32,134** |
| **Swift** | 1,334 + 862 | – | 3,885 | 1,675 | **~9,756** |
| **PHP** | 1,336 + 1,093 | – | 1,553 | 1,585 | **~7,567** |
| **Dart** | 1,354 + 1,029 | – | 1,595 | 1,630 | **~7,608** |
| **.NET/C#** | 1,239 + 1,094 | – | 1,356 | 1,540 | **~7,229** |
| **Bash** | 1,440 + 790 | – | – | – | **2,230** |
| **PowerShell** | 1,392 + 610 | – | – | – | **2,002** |
| **HTML** | 733 + 436 | – | – | – | **1,169** |
| **CSS** | 689 + 240 | – | 3,530 (Tailwind + Bootstrap) | – | **929 - 4,459** |
| **SQL** | 451 + 244 | – | – | – | **695** |
| **YAML** | 440 + 262 | – | – | – | **702** |
| **Dockerfile** | 508 + 268 | – | – | – | **776** |
| **dotenv (.env)** | 337 + 253 | – | – | – | **590** |
| **JSON** | 328 + 133 | – | – | – | **461** |
| **Sass/SCSS** | 281 + 129 | – | – | – | **410** |
| **Less** | 281 + 129 | – | – | – | **410** |
| **PostCSS** | 285 + 130 | – | – | – | **415** |
| **Stylus** | 283 + 130 | – | – | – | **413** |
| **Grand Total** | | | | | **~180,000 - 184,000** |

> **General Rules**: Updated to 8,254 tokens (previously 2,275) due to role-based adaptive behavior in persona.md, which enables AI to detect user expertise and adapt questioning accordingly. General rules also include dedicated **accessibility** and **i18n** rule files, which add to the base token count alongside persona, architecture, code style, design, security, and related core files.

> **CSS Frameworks**: Tailwind CSS (1,552 tokens) and Bootstrap (1,978 tokens) are optional framework selections. CSS base rules are 929 tokens, so selecting both frameworks brings the total to 4,459 tokens.

> **Documentation Standards**: Three optional files (3,585 tokens total) provide baseline documentation standards for code comments, project documentation, and APIs. Selected during setup based on project type. Language-specific process files reference these standards to avoid duplication.

> **Process Files**: Token-optimized (6.7% reduction overall). Files standardized to 195-285 lines each with Git Workflow reference pattern, consolidated tables, and streamlined AI Self-Check (10-12 items). CI/CD files reduced 38%, API Documentation files reduced 30-32% by referencing general documentation standards.

> **Security Rules**: Token-optimized (80% reduction from code examples). Each language includes concise security guidance covering OWASP Top 10, authentication, SQL injection prevention, and framework-specific patterns.

### Typical Selection Examples

| Stack | Components | Tokens |
|-------|------------|--------|
| **React (TS)** | General + TypeScript + React + Modular + Docs (code, project) | ~5,800 |
| **React (TS) with API Docs** | General + TypeScript + React + Modular + All Docs | ~7,000 |
| **React (JS) + Express** | General + JavaScript + React + Node.js Express | ~3,770 |
| **Next.js + Prisma** | General + TypeScript + Next.js + Prisma | ~4,150 |
| **NestJS + Prisma** | General + TypeScript + NestJS + Prisma + Modular | ~5,200 |
| **AdonisJS (Modular)** | General + TypeScript + AdonisJS + Modular | ~3,800 |
| **AdonisJS (MVC)** | General + TypeScript + AdonisJS + MVC | ~4,250 |
| **Spring Boot API (Java)** | General + Java + Spring Boot + Hibernate + Clean | ~5,390 |
| **Android MVVM (Java)** | General + Java + Android + MVVM | ~3,740 |
| **iOS MVVM (UIKit)** | General + Swift + iOS + Core Data + MVVM | ~5,810 |
| **SwiftUI + Combine** | General + Swift + SwiftUI + Combine + MVVM | ~5,665 |
| **Vapor API** | General + Swift + Vapor + Modular | ~5,235 |
| **Spring Boot API (Kotlin)** | General + Kotlin + Spring Boot + Exposed + Clean | ~6,930 |
| **Android MVVM (Kotlin)** | General + Kotlin + Android + MVVM | ~5,530 |
| **Ktor + Exposed** | General + Kotlin + Ktor + Exposed + Modular | ~6,690 |
| **Django REST API** | General + Python + Django + SQLAlchemy + Traditional | ~4,326 |
| **FastAPI + Pydantic** | General + Python + FastAPI + Pydantic + Modular | ~5,854 |
| **.NET Full Stack** | General + .NET + ASP.NET Core + EF Core + MediatR + Clean | ~4,465 |
| **Laravel + Doctrine** | General + PHP + Laravel + Doctrine + DDD | ~3,960 |
| **Flutter + BLoC** | General + Dart + Flutter + BLoC + Feature-First | ~3,510 |

> **Note**: Token estimates based on ~4 characters per token. Actual usage may vary.

### Cost Optimization Tips

- **Select only what you need** – Don't include unused frameworks or processes
- **Choose one structure** – Pick the best fit, not all options
- **Node.js is shared** – Using Express with both JS/TS adds it only once
- **Documentation is optional** – Skip API docs for frontend-only projects (saves ~1,150 tokens)
- **Smart documentation selection**:
  - Frontend-only (Dart/Flutter): Select code + project docs only (~2,700 tokens)
  - Backend/Fullstack: Select all documentation (~3,850 tokens)
  - Libraries: Select code docs only (~1,250 tokens)
- **Processes are optional** – Only select the processes you're actively implementing
- **Processes are token-efficient** – CI/CD files optimized 38%, API docs optimized 30-32%, all ~200-285 lines
- **Security rules optimized** – Refactored for 80% token reduction (concise directives vs verbose code examples)
- **DRY principle** – Process files reference general documentation standards to eliminate duplication

---

## 🔧 Extending

### Documentation Standards (Optional)

The project includes three **optional** documentation rule files in `rules/general/documentation/`:

1. **code.md** (~1,250 tokens) - Inline comments, docstrings, JSDoc, XML docs, PHPDoc
   - Self-documenting code principles
   - Comment types (explanatory, warning, TODOs)
   - Language-specific examples (Python, TypeScript, C#, Java, Swift, PHP)
   - **Recommended for**: All projects

2. **project.md** (~1,450 tokens) - README, CHANGELOG, CONTRIBUTING, LICENSE
   - README structure (12 sections)
   - Keep a Changelog format
   - Contributing guidelines
   - License selection
   - **Recommended for**: All projects

3. **api.md** (~1,150 tokens) - REST APIs, OpenAPI/Swagger, SDK documentation
   - HTTP status codes (standard table)
   - Error response formats
   - Authentication patterns
   - Rate limiting
   - API versioning strategies
   - SDK/client library generation
   - **Recommended for**: Backend and fullstack projects only

During setup, you'll be prompted to select which documentation standards to include. The setup provides smart suggestions based on your selected languages:
- Frontend-only projects → code + project
- Backend/Fullstack projects → all documentation
- Skip entirely if not needed

Language-specific process files reference these standards to avoid duplication.

### Add a New Language

1. Create folder: `lib/rules/yourlanguage/`
2. Add `architecture.md` and `code-style.md`
3. Register in `config.json`:

```json
"yourlanguage": {
  "name": "Your Language",
  "globs": "*.ext",
  "alwaysApply": false,
  "files": ["architecture", "code-style"]
}
```

### Add a New Framework

1. Create: `lib/rules/yourlanguage/frameworks/yourframework.md`
2. Register in `config.json` under the language's `frameworks`:

```json
"yourframework": {
  "name": "Your Framework",
  "file": "yourframework",
  "category": "Web Framework",
  "description": "Short description",
  "recommended": true
}
```

### Add a Project Structure

1. Create: `lib/rules/yourlanguage/frameworks/structures/framework-structure.md`
2. Add to framework's `structures` in `config.json`:

```json
"structures": {
  "modular": {
    "name": "Modular",
    "file": "yourframework-modular",
    "description": "Organized by feature",
    "recommended": true
  }
}
```

### Add a Process Guide

1. Create the file under the correct tier and language folder: `lib/processes/permanent/{language}/process-name.md` (always-loaded migration-style guides) or `lib/processes/ondemand/{language}/process-name.md` (copy-when-needed guides). Match the `type` and `loadIntoAI` fields you add in `config.json`.
2. Add to language's `processes` in `config.json`:

```json
"processes": {
  "process-name": {
    "name": "Process Name",
    "file": "process-name",
    "description": "What this process does"
  }
}
```

**Process Best Practices**:
- Use phase-based structure (Phase 1, Phase 2, etc.)
- Include explicit ALWAYS/NEVER directives
- Add AI Self-Check lists (10-12 items, tailored to language/framework)
- Keep token-efficient (aim for 30-40% reduction vs verbose docs)
- Reference general documentation standards instead of duplicating content
- Include Git workflow guidance (one branch per phase)
- Never fix production bugs during infrastructure setup
- For API documentation, reference `rules/general/documentation/api.md` for HTTP status codes, error formats, and best practices

---

## 📋 Requirements

| Platform | Requirements |
|----------|-------------|
| **Windows** | PowerShell 5.1+ (included in Windows 10/11) |
| **macOS** | `jq` – Install with `brew install jq` |
| **Linux** | `jq` – Install with `apt install jq` or `yum install jq` |

**Having issues?** See [TROUBLESHOOTING.md](../TROUBLESHOOTING.md) for common problems and solutions.

---

## 🔍 Quality Assurance

This project includes comprehensive validation and testing:

- **Local validation**: Run **`/ai-iap:validate`** in Claude Code (`skills/validate/SKILL.md` in this repo)
- **CI/CD Pipeline**: GitHub Actions workflow validates every commit
- **JSON Schema**: `config.schema.json` validates configuration structure

**Run validation locally**:

```
/ai-iap:validate
```

---

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

- **Add frameworks** – Support for more frameworks and libraries
- **Add languages** – Go, Rust, Java, Python, etc.
- **Improve rules** – Better patterns, clearer guidelines
- **Fix bugs** – Issues with setup/validate skills or configurations

Please read the existing rules to understand the style and format before contributing.

**Before submitting**:
1. Run validation: **`/ai-iap:validate`**
2. Ensure all tests pass
3. Update token cost table if adding new rules

---

## 📄 License

MIT License – Free to use in personal and commercial projects.

---

## 🙏 Acknowledgments

Built with the goal of making Claude Code more consistent and useful across all development environments.

---

<p align="center">
  <b>Stop copying rules between projects. Define once, use everywhere.</b>
</p>
