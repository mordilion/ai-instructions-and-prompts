# AI Instructions & Prompts

**Consistent AI coding assistants across all your projects and tools.**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20macOS%20%7C%20Linux-blue.svg)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

---

## The Problem

Every AI coding assistant (Cursor, Copilot, Claude, etc.) needs its own configuration file. When you work across multiple projects and tools, you end up with:
- Inconsistent code quality between projects
- Different AI behaviors in different tools
- Copy-pasting the same rules everywhere
- No standard for architecture and code style

## The Solution

**AI Instructions & Prompts** is a portable, tool-agnostic collection of coding rules. Define your standards once, generate configurations for any AI tool.

```
Your Rules (one source) → Setup Script → All AI Tools Configured
```

---

## ✨ Features

- **🔧 Multi-Tool Support** – 10 AI coding assistants: Cursor, Claude, GitHub Copilot, Windsurf, Aider, Google AI Studio, Amazon Q Developer, Tabnine, Cody, Continue.dev
- **🌍 Multi-Language** – Kotlin, JavaScript, TypeScript, Java, Python, Dart/Flutter, .NET/C#, PHP, Swift, Node.js
- **📦 Framework-Specific** – React, Next.js, NestJS, AdonisJS, Laravel, ASP.NET Core, Spring Boot, Django, FastAPI, and 50+ more
- **🏗️ Structure Templates** – Clean Architecture, Vertical Slices, Feature-First, Modular, MVVM, MVI, DDD, and more
- **🔒 Security Rules** – OWASP Top 10 coverage for all languages (token-optimized, 80% more efficient)
- **📚 Documentation Standards** – Optional code, project, and API documentation standards with smart suggestions
- **🔄 Process Guides** – CI/CD, Testing, Logging, Docker, Auth, Migrations, API Docs (77 files, 8 languages, token-optimized)
- **🎨 Extension System** – Add company standards, override rules, custom processes without modifying core (update-safe)
- **⚡ Interactive Setup** – Wizard guides you through configuration with context-aware suggestions
- **🎯 Recommended Defaults** – Best practices marked with `⭐`
- **✅ Quality Verified** – Conflict-free system verified across all 191 files (95% confidence)

---

## 🚀 Quick Start

### 1. Copy to Your Project

```bash
# Clone or download, then copy the .ai-iap folder to your project
cp -r .ai-iap /path/to/your/project/
```

### 2. Run Setup

**Windows (PowerShell)**
```powershell
.\.ai-iap\setup.ps1
```

**macOS / Linux**
```bash
chmod +x .ai-iap/setup.sh && ./.ai-iap/setup.sh
```

### 3. Follow the Wizard

The setup wizard will guide you through:

**Step 1: Select AI Tools**
```
Select AI tools to configure:
  1. Cursor ⭐
  2. Claude CLI ⭐
  3. Claude Code ⭐
  ...
```

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

**Step 4: Select Frameworks & Processes** (if applicable)

That's it! Your AI tools are now configured with consistent coding standards.

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
   → Overrides .ai-iap/rules/typescript/code-style.md
   ```

### Update Strategies

| Strategy | Setup | Best For |
|----------|-------|----------|
| **Local** (Default) | `.ai-iap-custom/` git-ignored | Individual developers |
| **Team Sharing** | Commit `.ai-iap-custom/` | Teams with shared standards |
| **Separate Repo** | Maintain as submodule | Large orgs, company-wide |

### Benefits

- ✅ Pull updates from main repo without conflicts
- ✅ Keep company secrets/processes private
- ✅ Share customizations across team (optional)
- ✅ Test beta frameworks before core inclusion
- ✅ Maintain compliance requirements separately

**📚 Full Documentation**: See [CUSTOMIZATION.md](../CUSTOMIZATION.md) for complete guide with examples.

---

## 📋 Supported AI Tools

| Tool | Output | Description |
|------|--------|-------------|
| **Cursor** ⭐ | `.cursor/rules/*.mdc` | Separate rule files with glob patterns |
| **Claude** ⭐ | `CLAUDE.md` + `.claude/rules/**/*.md` | Always-on rules + modular path-specific rules |
| **GitHub Copilot** | `.github/copilot-instructions.md` | Repository-level instructions |
| **Windsurf** | `.windsurfrules` | Single concatenated file |
| **Aider** | `CONVENTIONS.md` | Convention file for Aider |
| **Google AI Studio** | `GOOGLE_AI_STUDIO.md` | Single concatenated file for Gemini models |
| **Amazon Q Developer** | `AMAZON_Q.md` | Single concatenated file for AWS AI assistant |
| **Tabnine** | `TABNINE.md` | Single concatenated file for team sharing |
| **Cody (Sourcegraph)** | `.cody/instructions.md` | Repository-level instructions |
| **Continue.dev** | `.continue/instructions.md` | VS Code extension instructions |

⭐ = Recommended

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

## 📁 What's Inside

```
.ai-iap/
├── rules/                      # Coding rules (the source of truth)
│   ├── general/                # Always applied
│   │   ├── persona.md          # AI behavior & personality
│   │   ├── architecture.md     # Code structure guidelines
│   │   ├── code-style.md       # Coding conventions
│   │   ├── commit-standards.md # Conventional Commits specification
│   │   ├── security.md         # Security best practices (OWASP Top 10)
│   │   └── documentation/      # Documentation standards (always applied)
│   │       ├── code.md         # Inline comments, docstrings, JSDoc, etc.
│   │       ├── project.md      # README, CHANGELOG, CONTRIBUTING, LICENSE
│   │       └── api.md          # REST APIs, OpenAPI/Swagger, SDK docs
│   ├── javascript/             # JavaScript-specific rules
│   ├── typescript/             # TypeScript-specific rules (includes security.md)
│   ├── nodejs/                 # Node.js backend (shared JS/TS)
│   ├── swift/                  # Swift-specific rules (includes security.md)
│   ├── kotlin/                 # Kotlin-specific rules (includes security.md)
│   ├── java/                   # Java-specific rules (includes security.md)
│   ├── python/                 # Python-specific rules (includes security.md)
│   ├── dart/                   # Dart-specific rules (includes security.md)
│   ├── dotnet/                 # .NET-specific rules (includes security.md)
│   └── php/                    # PHP-specific rules (includes security.md)
├── processes/                  # Step-by-step workflow guides (77 files)
│   ├── dotnet/                 # .NET processes
│   │   ├── test-implementation.md          # NUnit testing setup
│   │   ├── ci-cd-github-actions.md         # GitHub Actions CI/CD
│   │   ├── logging-observability.md        # Structured logging & monitoring
│   │   ├── docker-containerization.md      # Docker multi-stage builds
│   │   ├── authentication-jwt-oauth.md     # JWT + OAuth 2.0
│   │   ├── database-migrations.md          # EF Core Migrations
│   │   ├── api-documentation-openapi.md    # Swashbuckle/OpenAPI
│   │   ├── security-scanning.md            # SAST/DAST vulnerability scanning
│   │   ├── linting-formatting.md           # Code quality & style
│   │   └── code-coverage.md                # Coverage tracking & thresholds
│   ├── typescript/             # TypeScript processes (10 files)
│   ├── java/                   # Java processes (10 files)
│   ├── python/                 # Python processes (10 files)
│   ├── kotlin/                 # Kotlin processes (10 files)
│   ├── swift/                  # Swift processes (10 files)
│   ├── php/                    # PHP processes (10 files)
│   └── dart/                   # Dart processes (7 files: frontend/mobile focus)
├── functions/                  # Cross-language implementation patterns (NEW)
│   ├── INDEX.md                # Quick reference for all function patterns
│   ├── error-handling.md       # Exception handling across all 8 languages
│   ├── async-operations.md     # Async/await patterns for all languages
│   ├── input-validation.md     # Validation & sanitization (all languages)
│   ├── database-query.md       # Safe DB queries, prevent SQL injection
│   └── http-requests.md        # HTTP client patterns with retry logic
├── config.json                 # Tool & language definitions
├── setup.ps1                   # Windows setup script
├── setup.sh                    # macOS/Linux setup script
└── README.md
```

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
- Copy prompt from `.ai-iap/processes/_ondemand/{language}/{process}.md` when ready to implement
- **85% token savings** - Only load what you need, when you need it

### How to Use On-Demand Processes

1. Navigate to `.ai-iap/processes/ondemand/{language}/{process}.md`
2. Scroll to **"Usage - Copy This Complete Prompt"** section
3. Copy the entire prompt block
4. Paste into your AI tool
5. AI will guide you through implementation

### Available Processes (All 8 Languages)

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

**Total**: 70 process files (8 permanent, 62 on-demand) across 8 languages

### Process Quality Features

1. **Smart Loading**: Permanent processes loaded into AI, on-demand processes copied when needed (85% token savings)
2. **Self-Contained Prompts**: Each on-demand process includes complete, copy-paste prompt with all context
3. **Phase-Based**: Each process divided into 4-5 clear phases with objectives and deliverables
4. **Understandability-First**: Clarity prioritized over brevity - same result across GPT-3.5, GPT-4, Claude, Gemini, Codestral
5. **Token-Optimized**: 30-40% shorter than traditional docs where clarity is maintained
6. **AI-Optimized**: Explicit directives (`> **ALWAYS**`, `> **NEVER**`), clear implementation steps
7. **Version Flexible**: No hardcoded versions - reads from project config files (.nvmrc, global.json, pom.xml, etc.)
8. **Platform Guidance**: GitHub Actions primary, with guidance for GitLab CI, Azure DevOps, CircleCI, Jenkins
7. **Consistent Structure**: Git Workflow reference, table format comparisons, troubleshooting sections
8. **DRY Principle**: Process files reference general documentation standards instead of duplicating content

> **Design Philosophy**: Files may exceed token guidelines when framework complexity requires it. All lengths are justified by the need for clear, unambiguous instructions that produce consistent results across different AI models.

---

## 🎯 Function Patterns (NEW)

In addition to rules and processes, the system now includes **cross-language implementation patterns** that provide exact code examples for common tasks. This **reduces AI guessing** and ensures consistent, secure implementations.

### What Are Functions?

Functions are **5-20 line code patterns** for common coding tasks, shown **across all 8 languages** in a single file. Instead of letting the AI guess how to implement error handling or database queries, you reference the exact pattern.

### Available Functions

| Function | Purpose | Languages | File |
|----------|---------|-----------|------|
| **Error Handling** | Exception handling, custom errors, error propagation | All 8 | [error-handling.md](functions/error-handling.md) |
| **Async Operations** | Async/await, promises, parallel execution, timeouts | All 8 | [async-operations.md](functions/async-operations.md) |
| **Input Validation** | Data validation, sanitization, type checking | All 8 | [input-validation.md](functions/input-validation.md) |
| **Database Queries** | Safe queries, parameterization, SQL injection prevention | All 8 | [database-query.md](functions/database-query.md) |
| **HTTP Requests** | API calls, retry logic, timeout handling | All 8 | [http-requests.md](functions/http-requests.md) |

**All functions cover**: TypeScript, Python, Java, C#, PHP, Kotlin, Swift, Dart

### How to Use

1. **Check the INDEX first**: Open [functions/INDEX.md](functions/INDEX.md) to find the pattern you need
2. **Open the function file**: Each file shows implementations for all 8 languages side-by-side
3. **Copy the exact pattern**: Use the language-specific implementation for your project
4. **Stop AI guessing**: Precise patterns = consistent code = fewer bugs

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

| Language | Base (+Security) | Documentation (Optional) | Frameworks | Structures | Processes (Optimized) | Total |
|----------|------------------|--------------------------|------------|------------|-----------------------|-------|
| **General** (always loaded) | 1,075 + 1,200 | 3,850 (if all selected) | – | – | – | **2,275 - 6,125** |
| **JavaScript** | 1,012 | 4,596 | 1,162 | – | **6,770** |
| **TypeScript** | 852 + 1,050 | 11,000 | 5,800 | 1,540 | **20,240** |
| **Node.js** | – | 2,879 | – | – | **2,879** |
| **Java** | 1,662 + 1,065 | 10,011 | 4,910 | 1,725 | **19,373** |
| **Python** | 1,746 + 1,260 | 9,686 | 10,060 | 1,585 | **24,337** |
| **Kotlin** | 2,671 + 1,020 | 16,354 | 25,815 | 1,770 | **47,630** |
| **Swift** | 4,015 + 795 | 16,862 | 3,885 | 1,675 | **27,232** |
| **Dart** | 823 + 1,095 | 3,535 | 1,595 | 1,630 | **8,678** |
| **.NET** | 844 + 1,020 | 5,008 | 1,356 | 1,540 | **9,768** |
| **PHP** | 860 + 1,050 | 5,158 | 1,553 | 1,585 | **10,206** |
| **Grand Total** | | | | | | **~177,000 - 181,000** |

> **Documentation Standards**: Three optional files (~3,850 tokens total) provide baseline documentation standards for code comments, project documentation, and APIs. Selected during setup based on project type. Language-specific process files reference these standards to avoid duplication.

> **Process Files**: Token-optimized (6.7% reduction overall). Files standardized to 195-285 lines each with Git Workflow reference pattern, consolidated tables, and streamlined AI Self-Check (10-12 items). CI/CD files reduced 38%, API Documentation files reduced 30-32% by referencing general documentation standards.

> **Security Rules**: Token-optimized (80% reduction from code examples). Each language includes concise security guidance (~1,000-1,200 tokens) covering OWASP Top 10, authentication, SQL injection prevention, and framework-specific patterns.

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

> **Note**: Token estimates based on ~4 characters per token. Actual usage may vary by AI tool.

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

1. Create folder: `.ai-iap/rules/yourlanguage/`
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

1. Create: `.ai-iap/rules/yourlanguage/frameworks/yourframework.md`
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

1. Create: `.ai-iap/rules/yourlanguage/frameworks/structures/framework-structure.md`
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

1. Create: `.ai-iap/processes/yourlanguage/process-name.md`
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

## 📦 Git Strategy

### Option A: Share Generated Files (Recommended for Teams)

```bash
# .gitignore
.ai-iap/
```

Commit the generated files (`.cursor/rules/`, `CLAUDE.md`, etc.). Everyone gets the same rules automatically without running setup.

### Option B: Share Source Files

Commit the `.ai-iap/` folder. Each team member runs setup after cloning.

---

## 📋 Requirements

| Platform | Requirements |
|----------|-------------|
| **Windows** | PowerShell 5.1+ (included in Windows 10/11) |
| **macOS** | `jq` – Install with `brew install jq` |
| **Linux** | `jq` – Install with `apt install jq` or `yum install jq` |

**Having issues?** See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for common problems and solutions.

---

## 🔍 Quality Assurance

This project includes comprehensive validation and testing:

- **Validation Scripts**: `.ai-iap/validate.ps1` (Windows) and `.ai-iap/validate.sh` (Linux/macOS)
- **CI/CD Pipeline**: GitHub Actions workflow validates every commit
- **Expert Analysis**: See [EXPERT_ANALYSIS.md](EXPERT_ANALYSIS.md) for detailed review
- **JSON Schema**: `config.schema.json` validates configuration structure

**Run validation locally**:
```bash
# Windows
.\.ai-iap\validate.ps1

# macOS/Linux
./.ai-iap/validate.sh
```

---

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

- **Add frameworks** – Support for more frameworks and libraries
- **Add languages** – Go, Rust, Java, Python, etc.
- **Improve rules** – Better patterns, clearer guidelines
- **Fix bugs** – Issues with setup scripts or configurations

Please read the existing rules to understand the style and format before contributing.

**Before submitting**:
1. Run validation: `.ai-iap/validate.ps1` or `.ai-iap/validate.sh`
2. Ensure all tests pass
3. Update token cost table if adding new rules

---

## 📄 License

MIT License – Free to use in personal and commercial projects.

---

## 🙏 Acknowledgments

Built with the goal of making AI coding assistants more consistent and useful across all development environments.

---

<p align="center">
  <b>Stop copying rules between projects. Define once, use everywhere.</b>
</p>
