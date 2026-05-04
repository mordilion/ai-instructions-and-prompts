# AI Instructions & Prompts

**A Claude Code plugin for consistent AI coding standards across all your projects.**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20macOS%20%7C%20Linux-blue.svg)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](plugin/lib/README.md#-contributing)

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
/plugin marketplace add mordilion/ai-instructions-and-prompts
/plugin install ai-iap@mordilion
```

### Option B: Test Locally (Development)

```bash
claude --plugin-dir ./path/to/ai-instructions-and-prompts
```

### Run the Setup Wizard

```text
/clear
/ai-iap:setup
```

Run `/clear` first for a clean context, then start the setup wizard. It walks you through
language, framework, and structure selection, then generates your `.claude/rules/` configuration.

## Developing this repository

If you **work on the plugin source** (not only consume it as an end user):

- Maintainer instructions: [`CLAUDE.md`](CLAUDE.md) (includes verification and change propagation).
- Structured notes (ADRs, modules, features): [`docs/memory/README.md`](docs/memory/README.md).
- **Regenerate checked-in Claude Code rules** after changing which languages apply to this repo or after editing `scripts/generate-ai-iap-claude-rules.mjs`:  
  `node scripts/generate-ai-iap-claude-rules.mjs`  
  Selection is stored in [`.ai-iap-state.json`](.ai-iap-state.json); output is [`.claude/rules/`](.claude/rules/).
- Contributing and local checks: [`CONTRIBUTING.md`](CONTRIBUTING.md).

## Plugin Components

| Component | Path | Description |
|-----------|------|-------------|
| Setup skill | `plugin/skills/setup/` | Interactive setup wizard (`/ai-iap:setup`) |
| Validate skill | `plugin/skills/validate/` | Configuration validator (`/ai-iap:validate`) |
| Code reviewer | `plugin/agents/code-reviewer.md` | Reviews code for quality and security |
| Codebase explorer | `plugin/agents/codebase-explorer.md` | Fast read-only code search |
| Test writer | `plugin/agents/test-writer.md` | Writes tests following conventions |
| Docs writer | `plugin/agents/docs-writer.md` | Improves documentation |
| Refactor helper | `plugin/agents/refactor-helper.md` | Refactors without changing behavior |
| Session hook | `plugin/hooks/hooks.json` | Suggests setup on new projects |
| Rule regen (maintainers) | `scripts/generate-ai-iap-claude-rules.mjs` | Rebuilds `.claude/rules/` from `plugin/lib/rules/` (same layout as setup) |

## Fork & Customize

Want to add your own rules, frameworks, or processes? **Fork the repo** and use the
built-in custom extensions layer:

```
plugin/custom/
  config.extend.json        # Add languages, frameworks, processes
  rules/                    # Your custom rules (override or extend base)
  processes/                # Your custom processes
  claude-subagents.extend.json  # Your agent templates
```

Your customizations live in `plugin/custom/` which upstream never modifies — pull
updates without merge conflicts. See [Custom Extensions Guide](plugin/custom/README.md)
for details.

## Documentation

**[Full Documentation](plugin/lib/README.md)**

- [Languages & Frameworks](plugin/lib/README.md#-supported-languages--frameworks)
- [Project Structures](plugin/lib/README.md#-project-structure-options)
- [Fork & Customize](plugin/lib/README.md#-fork--customize-custom-extensions)
- [Token Costs](plugin/lib/README.md#-token-cost-analysis)
- [Configuration](plugin/lib/README.md#-configuration)
- [**Team Adoption Guide**](TEAM_ADOPTION_GUIDE.md) -- For engineering teams evaluating this project
- [Troubleshooting](TROUBLESHOOTING.md)
- [Contributing](CONTRIBUTING.md) (root) — maintainer workflow and checks
- [Contributing (details)](plugin/lib/README.md#-contributing) — style and extending the library

## License

MIT License -- Free to use in personal and commercial projects.

---

<p align="center">
  <b>Stop copying rules between projects. Install once, configure everywhere.</b>
</p>
