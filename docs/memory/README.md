# Context memory (`docs/memory/`)

Structured project knowledge for the **ai-iap plugin source** (not an application domain). **Do not** load every file for every task — use [CLAUDE.md](../../CLAUDE.md) *Context Memory System* for the canonical file list.

Contributor workflow (checks, regen `.claude/rules/`): [CONTRIBUTING.md](../../CONTRIBUTING.md).

## Loading rules

- **Before each task:** load only the memory file(s) that match the current task.
- **After significant changes:** update the affected memory file.
- **Format:** fact-based bullets with concrete file paths and values; avoid long prose.
- **No duplication:** do not restate what is obvious from the repository or git history; capture decisions, context, and gotchas.

## Core files (maintained)

| File | When to load |
|------|----------------|
| [`architecture-decisions.md`](architecture-decisions.md) | ADRs, design constraints |
| [`entity-model.md`](entity-model.md) | `config.json` hierarchy & references (no DB) |
| [`frontend-patterns.md`](frontend-patterns.md) | Rule authoring / UI framework snippets (no app UI here) |
| [`backend-patterns.md`](backend-patterns.md) | Backend-oriented rules/processes authoring |
| [`deployment.md`](deployment.md) | CI, marketplace, versioning |
| [`module-status.md`](module-status.md) | Where things live; fragile areas |
| [`bugs-and-fixes.md`](bugs-and-fixes.md) | Recurring failures; validate/CI issues |

## Features index

| File | When to load |
|------|----------------|
| [`features.md`](features.md) | Pick a subsystem |
| [`features/setup-wizard.md`](features/setup-wizard.md) | `/ai-iap:setup`, merge, state |
| [`features/validate.md`](features/validate.md) | `/ai-iap:validate` |
| [`features/config-and-schema.md`](features/config-and-schema.md) | `config.json` / schema edits |
| [`features/code-library.md`](features/code-library.md) | Functions & design patterns |
| [`features/agents-and-subagents.md`](features/agents-and-subagents.md) | Agents, templates |
| [`features/hooks.md`](features/hooks.md) | SessionStart hook |
| [`features/custom-extensions.md`](features/custom-extensions.md) | `plugin/custom/` |
