# AI Instructions & Prompts

**A Claude Code plugin for consistent AI coding standards across all your projects.**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20macOS%20%7C%20Linux-blue.svg)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](lib/README.md#-contributing)

---

Install the plugin, run `/ai-iap:setup`, and get modular rules, project instructions,
and optional agents — configured for your project in seconds.

## Features

- **Claude Code Plugin** -- Install once, use across all projects via `/ai-iap:setup`
- **5 Built-in Agents** -- Code reviewer, codebase explorer, test writer, docs writer, refactor helper
- **Role-Based Adaptive AI** -- Detects your expertise level and adapts accordingly
- **20+ Languages** -- Swift, Kotlin, Java, Python, JavaScript, TypeScript, HTML, CSS,
  Sass/SCSS, Less, PostCSS, Stylus, YAML, JSON, dotenv, Dockerfile, SQL,
  Dart/Flutter, .NET/C#, PHP, Node.js, Bash, PowerShell
- **52+ Frameworks** -- React, Next.js, NestJS, AdonisJS, Spring Boot, Django, FastAPI,
  Laravel, iOS, Android, Tailwind CSS, Bootstrap, and more
- **Structure Templates** -- Clean Architecture, MVVM, MVI, Vertical Slices, Feature-First,
  DDD, Modular
- **Security Rules** -- OWASP Top 10 coverage for all languages (token-optimized)
- **Process Guides** -- CI/CD, Testing, Logging, Docker, Authentication, Migrations,
  API Documentation
- **Code Library** -- 17 implementation patterns + 15 design patterns across 8 languages
- **Quality Verified** -- 95%+ compliant, understandability-first

## Quick Start

### Option A: Install from GitHub

Add the marketplace and install the plugin:

```text
/plugin marketplace add HenningHuncke/ai-instructions-and-prompts
/plugin install ai-iap@ai-iap-marketplace
```

### Option B: Test Locally (Development)

```bash
claude --plugin-dir ./path/to/ai-instructions-and-prompts
```

### Run the Setup Wizard

```text
/ai-iap:setup
```

The AI-driven setup wizard walks you through language, framework, and structure selection,
then generates your `.claude/rules/` configuration.

## Plugin Components

| Component | Path | Description |
|-----------|------|-------------|
| Setup skill | `skills/setup/` | Interactive setup wizard (`/ai-iap:setup`) |
| Validate skill | `skills/validate/` | Configuration validator (`/ai-iap:validate`) |
| Code reviewer | `agents/code-reviewer.md` | Reviews code for quality and security |
| Codebase explorer | `agents/codebase-explorer.md` | Fast read-only code search |
| Test writer | `agents/test-writer.md` | Writes tests following conventions |
| Docs writer | `agents/docs-writer.md` | Improves documentation |
| Refactor helper | `agents/refactor-helper.md` | Refactors without changing behavior |
| Session hook | `hooks/hooks.json` | Suggests setup on new projects |

## Documentation

**[Full Documentation](lib/README.md)**

- [Languages & Frameworks](lib/README.md#-supported-languages--frameworks)
- [Project Structures](lib/README.md#-project-structure-options)
- [Token Costs](lib/README.md#-token-cost-analysis)
- [Configuration](lib/README.md#-configuration)
- [**Team Adoption Guide**](TEAM_ADOPTION_GUIDE.md) -- For engineering teams evaluating this project
- [Troubleshooting](TROUBLESHOOTING.md)
- [Contributing](lib/README.md#-contributing)

## License

MIT License -- Free to use in personal and commercial projects.

---

<p align="center">
  <b>Stop copying rules between projects. Install once, configure everywhere.</b>
</p>
