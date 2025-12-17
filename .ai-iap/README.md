# AI Instructions & Prompts

**Consistent AI coding assistants across all your projects and tools.**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20macOS%20%7C%20Linux-blue.svg)]()
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
- **🌍 Multi-Language** – Dart/Flutter, .NET/C#, TypeScript, PHP
- **📦 Framework-Specific** – React, Next.js, Laravel, ASP.NET Core, and 20+ more
- **🏗️ Structure Templates** – Clean Architecture, Vertical Slices, Feature-First, and more
- **⚡ Interactive Setup** – Wizard guides you through configuration
- **🎯 Recommended Defaults** – Best practices marked with `*`

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

### TypeScript
| Category | Frameworks |
|----------|------------|
| UI Framework | React ⭐, Vue.js, Angular |
| Full-Stack | Next.js ⭐, Svelte/SvelteKit |
| Backend | NestJS ⭐, Express.js |
| ORM | Prisma ⭐ |

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
| **React** | Modular ⭐, Layered, Atomic Design |
| **Angular** | Modular, Standalone ⭐ |
| **NestJS** | Modular ⭐, Layered |
| **ASP.NET Core** | Clean Architecture ⭐, Vertical Slices, N-Tier |
| **Laravel** | Modular ⭐, Traditional, DDD |

---

## 📁 What's Inside

```
.ai-iap/
├── rules/                      # Coding rules (the source of truth)
│   ├── general/                # Always applied
│   │   ├── persona.md          # AI behavior & personality
│   │   ├── architecture.md     # Code structure guidelines
│   │   └── code-style.md       # Coding conventions
│   ├── dart/                   # Dart-specific rules
│   ├── dotnet/                 # .NET-specific rules
│   ├── typescript/             # TypeScript-specific rules
│   └── php/                    # PHP-specific rules
├── processes/                  # Step-by-step workflow guides
├── config.json                 # Tool & language definitions
├── setup.ps1                   # Windows setup script
├── setup.sh                    # macOS/Linux setup script
└── README.md
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

---

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

- **Add frameworks** – Support for more frameworks and libraries
- **Add languages** – Go, Rust, Java, Python, etc.
- **Improve rules** – Better patterns, clearer guidelines
- **Fix bugs** – Issues with setup scripts or configurations

Please read the existing rules to understand the style and format before contributing.

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
