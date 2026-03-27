# Claude Code Rules Index

<!-- Last updated: 2026-03-13 -->

## Overview

These rules are automatically applied based on file glob patterns. Each rule file contains coding standards, patterns, and anti-patterns for specific technologies.

## Rule Files

| File | Glob Pattern | When Applied | Key Points |
|------|--------------|--------------|------------|
| **dotnet.md** | `**/*.cs`, `**/*.csproj`, `**/Program.cs`, `**/Startup.cs`, `**/*DbContext*.cs`, `**/*Repository*.cs`, `**/Migrations/**`, `**/EntityConfigurations/**` | .NET/C# projects | SOLID, DI, async/await, EF Core, Result pattern |
| **dotnet-testing.md** | `**/*Tests.cs`, `**/*Test*.cs`, `**/*.Tests/**` | .NET unit tests | NUnit, Moq, AAA pattern, async testing |
| **mysql.md** | `**/*.sql`, `**/Migrations/**`, `**/*Repository*.cs`, `**/*Query*.cs` | Database queries | Parameterized queries, indexes, JOINs, pagination |
| **vue.md** | `**/*.vue`, `**/*.ts`, `**/*.tsx`, `**/vite.config.*`, `**/composables/**` | Vue 3 projects | Script setup, TypeScript, composables, PrimeVue, Pinia |
| **ia-vue.md** | `**/bep-2-backend-pharmacy/**/*.vue`, `**/bep-2-backend-pharmacy/**/*.ts`, `**/ia-*/**/*.vue`, `**/ia-*/**/*.ts` | IA Vue projects | Store usage (no destructuring), inline props, naming |
| **accessibility.md** | `**/*.vue`, `**/*.html`, `**/*.tsx` | All frontend | Semantic HTML, ARIA, keyboard nav, focus management |
| **primevue.md** | `**/*.vue` | Vue + PrimeVue projects | v3 vs v4, pt system, Dialog/Toast/DataTable patterns, pitfalls |
| **i18n.md** | `**/locales/**`, `**/*.vue`, `**/i18n/**`, `**/*.json` | All frontend | German + English translations, key naming |
| **css.md** | `**/*.vue`, `**/*.css`, `**/*.scss` | All frontend | Tailwind v4, positioning validation, responsive patterns, dark mode, state variants |
| **claude-api.md** | `**/anthropic*`, `**/claude-api*`, `**/ai-service*` | Claude API integration | SDK patterns, streaming, tool use, error handling |

## Hierarchy

1. **Global** (`~/.claude/CLAUDE.md`) - Identity, critical rules, preferences
2. **Workspace** (`~/projects/CLAUDE.md`) - Project inventory, tools, MCP servers
3. **Project** (e.g., `~/projects/IA/CLAUDE.md`) - Project-specific commands, workflows
4. **Rules** (this folder) - Technology-specific coding standards

## Adding New Rules

1. Create `{technology}.md` in this folder
2. Add frontmatter with glob patterns:
   ```yaml
   ---
   globs: ["**/*.ext"]
   alwaysApply: false
   ---
   ```
3. Structure with XML-like tags for sections: `<section>`, `</section>`
4. Include: checklist, patterns, examples, anti-patterns
