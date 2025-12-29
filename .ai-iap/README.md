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

- **🔧 Multi-Tool Support** – Cursor, Claude CLI, GitHub Copilot, Windsurf, Aider
- **🌍 Multi-Language** – Kotlin, JavaScript, TypeScript, Java, Python, Dart/Flutter, .NET/C#, PHP, Swift, Node.js
- **📦 Framework-Specific** – React, Next.js, NestJS, AdonisJS, Laravel, ASP.NET Core, Spring Boot, Django, FastAPI, and 50+ more
- **🏗️ Structure Templates** – Clean Architecture, Vertical Slices, Feature-First, Modular, MVVM, MVI, DDD, and more
- **🔒 Security Rules** – OWASP Top 10 coverage for all languages (token-optimized, 80% more efficient)
- **🔄 Process Guides** – Step-by-step testing implementation workflows for existing projects (all languages)
- **⚡ Interactive Setup** – Wizard guides you through configuration
- **🎯 Recommended Defaults** – Best practices marked with `⭐`

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

```
Select AI tools to configure:

  1. Cursor *
  2. Claude CLI *
  3. GitHub Copilot
  4. Windsurf
  5. Aider

  * = recommended
  a. All tools

Enter choices: 1 2
```

That's it! Your AI tools are now configured with consistent coding standards.

---

## 📋 Supported AI Tools

| Tool | Output | Description |
|------|--------|-------------|
| **Cursor** | `.cursor/rules/*.mdc` | Separate rule files with glob patterns |
| **Claude CLI** | `CLAUDE.md` | Single concatenated file |
| **GitHub Copilot** | `.github/copilot-instructions.md` | Repository-level instructions |
| **Windsurf** | `.windsurfrules` | Single concatenated file |
| **Aider** | `CONVENTIONS.md` | Convention file for Aider |

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
│   │   └── security.md         # Security best practices (OWASP Top 10)
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
├── processes/                  # Step-by-step workflow guides
│   ├── dotnet/                 # .NET processes
│   │   └── test-implementation.md  # NUnit testing setup
│   ├── typescript/             # TypeScript processes
│   │   └── test-implementation.md  # Jest/Vitest setup
│   ├── java/                   # Java processes
│   │   └── test-implementation.md  # JUnit 5 setup
│   ├── python/                 # Python processes
│   │   └── test-implementation.md  # pytest setup
│   ├── kotlin/                 # Kotlin processes
│   │   └── test-implementation.md  # JUnit 5/Kotest setup
│   ├── swift/                  # Swift processes
│   │   └── test-implementation.md  # XCTest setup
│   ├── php/                    # PHP processes
│   │   └── test-implementation.md  # PHPUnit setup
│   └── dart/                   # Dart processes
│       └── test-implementation.md  # flutter_test setup
├── config.json                 # Tool & language definitions
├── setup.ps1                   # Windows setup script
├── setup.sh                    # macOS/Linux setup script
└── README.md
```

---

## 🔄 Process Guides

In addition to coding rules, this system includes **step-by-step workflow guides** for common development tasks. These are optimized for AI assistants to follow and implement.

### Available Processes

| Language | Process | Framework | Description |
|----------|---------|-----------|-------------|
| **.NET** | `test-implementation` | NUnit | Establish NUnit testing in existing projects |
| **TypeScript** | `test-implementation` | Jest/Vitest | Establish Jest or Vitest testing with React Testing Library |
| **Java** | `test-implementation` | JUnit 5 | Establish JUnit 5, AssertJ, Mockito testing |
| **Python** | `test-implementation` | pytest | Establish pytest with pytest-mock and pytest-cov |
| **Kotlin** | `test-implementation` | JUnit 5/Kotest | Establish JUnit 5 or Kotest with MockK |
| **Swift** | `test-implementation` | XCTest | Establish XCTest with ViewInspector for SwiftUI |
| **PHP** | `test-implementation` | PHPUnit | Establish PHPUnit with Mockery |
| **Dart** | `test-implementation` | flutter_test | Establish Flutter testing with mockito/mocktail |

### How Processes Work

1. **Phase-Based**: Each process is divided into clear phases (e.g., Setup, Unit Tests, Integration Tests)
2. **Git Workflow**: One branch per phase, atomic commits for AI trackability
3. **Token-Efficient**: 35-40% shorter than traditional documentation
4. **AI-Optimized**: Explicit directives (ALWAYS/NEVER), self-check lists
5. **Bug Handling**: Log bugs only, never fix production code during testing setup

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

| Language | Base (+Security) | Frameworks | Structures | Processes (Optimized) | Total |
|----------|------------------|------------|------------|-----------------------|-------|
| **General** (always loaded) | 1,075 + 1,200 | – | – | – | **2,275** |
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
| **Grand Total** | | | | | **~177,000** |

> **Process Files**: Token-optimized (6.7% reduction). Files standardized to 195-285 lines each with Git Workflow reference pattern, consolidated tables, and streamlined AI Self-Check (10-12 items). CI/CD files reduced 38%, Logging files standardized, API Documentation expanded with security & CI/CD integration.

> **Security Rules**: Token-optimized (80% reduction from code examples). Each language includes concise security guidance (~1,000-1,200 tokens) covering OWASP Top 10, authentication, SQL injection prevention, and framework-specific patterns.

### Typical Selection Examples

| Stack | Components | Tokens |
|-------|------------|--------|
| **React (TS)** | General + TypeScript + React + Modular | ~3,070 |
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

- **Select only what you need** – Don't include unused frameworks
- **Choose one structure** – Pick the best fit, not all options
- **Node.js is shared** – Using Express with both JS/TS adds it only once
- **Processes are optional** – Only select testing implementation if you need it
- **Processes are token-efficient** – ~1,650-1,900 tokens each (35-40% smaller than traditional docs)
- **Security rules optimized** – Refactored for 80% token reduction (concise directives vs verbose code examples)

---

## 🔧 Extending

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
- Add AI Self-Check lists
- Keep token-efficient (aim for 35-40% reduction vs verbose docs)
- Include Git workflow guidance (one branch per phase)
- Never fix production bugs during infrastructure setup

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
