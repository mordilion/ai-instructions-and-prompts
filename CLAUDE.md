# AI Instructions & Prompts — CLAUDE.md

> Project-level instructions for working on **this repository** (the Claude Code plugin source).  
> Detailed plugin documentation: [`plugin/lib/README.md`](plugin/lib/README.md). Contributor workflow: [`CONTRIBUTING.md`](CONTRIBUTING.md).

---

## Hard Rules (violations cause bugs or broken installs)

- Follow all applicable rules and rule precedence (this file, `.cursor/rules/` when using Cursor, and generated `.claude/rules/` when testing setup).
- Ask targeted questions if outcomes, scope, or constraints are unclear.
- **Change propagation:** Any change to rules, processes, functions, config, skills, hooks, or agents **must** be checked against dependent files (see [Change Guidelines](#change-guidelines)).
- **Plugin SemVer:** Any change that ships as part of the plugin (rules, processes, functions, `plugin/lib/config.json`, skills, hooks, agents, manifests, or other user-visible behavior) **must** bump the plugin version. Choose **independently** which segment to increment: **MAJOR** for incompatible or breaking changes, **MINOR** for backward-compatible features or meaningful additions, **PATCH** for fixes and small compatible adjustments. Keep **`plugin/.claude-plugin/plugin.json`**, **`.claude-plugin/marketplace.json`**, and **`plugin/lib/config.json`** (`version` field) **in lockstep** on every such change.
- **Before** adding error handling, validation, async, HTTP, DB patterns in examples: check [`plugin/lib/code-library/functions/INDEX.md`](plugin/lib/code-library/functions/INDEX.md) and use the pattern file — do not invent variants.
- Validate all external input in **example** code and in tooling that consumes untrusted data.
- Never log or store secrets; redact sensitive values in logs and docs.
- Do not introduce **fixed** runtime/library versions in rules; read versions from the user’s project files (`package.json`, `composer.json`, etc.).
- Prefer the **smallest** change that satisfies the request; avoid drive-by refactors.
- **Rerunnable setup:** Generated files must remain safe to regenerate; only remove outputs marked `aiIapManaged: true` during cleanup (see setup skill).
- Keep outputs concise and unambiguous across AI tools.

---

## Interpreting rules and processes (any assistant)

Instructions in this project are written to be **model-neutral**: any LLM should resolve them without product-specific subtext. The same reading contract appears under **Universal interpretation (any LLM)** in [`.cursor/rules/general.mdc`](.cursor/rules/general.mdc) and in [`plugin/lib/README.md`](plugin/lib/README.md) (*Interpreting these rules*).

| Signal | Meaning |
|--------|---------|
| **ALWAYS** / **NEVER** / MUST | Hard requirement unless explicitly marked optional |
| Scope line (`> **Scope**`) | Jurisdiction of that file; narrower rules override broader ones |
| AI Self-Check | Verify each item before final output |
| ⭐ / “recommended” | Default when the user gave no preference |
| Code in fences | Illustrative—adapt to the target project’s stack and detected versions |

**Paths (three contexts):**

| Context | Rules | Code library |
|--------|-------|--------------|
| **This repository** | Authoring: `plugin/lib/rules/**` | `plugin/lib/code-library/**` |
| **Installed plugin** (`CLAUDE_PLUGIN_ROOT`) | `lib/rules/**` | `lib/code-library/functions/INDEX.md` |
| **User project after `/ai-iap:setup`** | **Generated:** `.claude/rules/core/**`, `.claude/rules/structures/**`, `.claude/rules/processes/**` | Loaded from the plugin’s `lib/code-library/` when the assistant uses the plugin |

**Cross-references:** Links from one rule to another **in content that is emitted to users** must resolve inside **`.claude/rules/`** (layout from the setup skill). Do not link to `plugin/lib/…` in generated rule bodies — that path is only valid in this meta-repository.

---

## Self-Maintenance — Keep CLAUDE.md & Memory Up to Date

**IMPORTANT:** This CLAUDE.md is a living document. It MUST be updated as the project evolves.

### Update CLAUDE.md when

- New tech stack is added (e.g. new framework, new database)
- New architecture decisions are made (extend ADR table)
- New conventions are established (coding rules, naming, etc.)
- New modules/features change the project scope
- Build/deploy commands change
- New directories or structural changes are introduced
- **This plugin repo:** layout under `plugin/` changes (skills, agents, hooks, `plugin/lib/`); `plugin/lib/config.json` or `plugin/lib/config.schema.json` semantics change; setup/validate skills change; CI validation steps change (see [Build & Verification](#build--verification))
- This file and [`README.md`](README.md) / [`plugin/lib/README.md`](plugin/lib/README.md) should stay accurate together
- Cross-model “how to read rules” or **path context** (meta-repo vs `.claude/rules/` after setup) changes — keep [`.cursor/rules/general.mdc`](.cursor/rules/general.mdc), [`plugin/lib/README.md`](plugin/lib/README.md) (*Interpreting these rules*), and this section aligned

### Build Context Memory when

- The project has no `docs/memory/` yet → **build initial memory**
- Architecture decisions are made → `architecture-decisions.md`
- Entity relationships change → `entity-model.md`
- New patterns are established → `frontend-patterns.md` / `backend-patterns.md`
- Bugs are fixed with non-obvious root cause → `bugs-and-fixes.md`
- Deployment/infra configuration changes → `deployment.md`
- Features are added, removed, or significantly changed → `features.md` index + `features/<name>.md`

---

## Workflow & Quality Assurance

### Planning

- For tasks with 3+ steps or architecture decisions: use Plan Mode before writing code.
- If an implementation is going in the wrong direction: stop immediately and re-plan — don't push through.
- Clarify specifications upfront to reduce ambiguity.

### Verification

- Never complete a task without verification: run tests, check logs, demonstrate correctness.
- For relevant changes: verify diff against previous behavior.
- Simple fixes don't need elaborate verification — effort proportional to complexity.
- **This plugin repo:** run checks from [Build & Verification](#build--verification) when your change warrants it.

### Bug fixing

- On bug reports: analyze and fix independently — use logs, error messages, and tests as starting points.
- Find the root cause. No temporary workarounds. Don't expect hand-holding from the user.
- Fix failing CI tests independently.

### Learning Loop & Context Memory

- After corrections from the user: capture learnings in the memory system so the same mistake is not repeated.
- Only store stable, repeatable patterns — not one-off decisions.
- **Context Memory:** `docs/memory/` contains structured project knowledge.
  - **Before each task:** Load the relevant memory file(s) (not all — only those matching the task).
  - **After significant changes:** Update the affected memory file.
  - See [`docs/memory/README.md`](docs/memory/README.md) for file structure and loading rules.

### Core principles

- **Simplicity First:** Every change as simple as possible. Touch minimal code.
- **Minimal Impact:** Only change what's necessary. Don't introduce new bugs.
- **Root Cause:** Find causes, don't treat symptoms.

---

## Context Memory System

### File Structure

| File | Content | When to load |
|------|---------|-------------|
| `README.md` | Index with loading rules | Always (it's short) |
| `architecture-decisions.md` | ADRs with reasoning and context | For architecture/design questions |
| `entity-model.md` | Entity relationships, tenant-awareness, specifics | For entity/DB changes |
| `frontend-patterns.md` | Established frontend patterns and conventions | For frontend work |
| `backend-patterns.md` | Backend patterns (services, processors, etc.) | For backend work |
| `deployment.md` | Server, env files, CI/CD, gotchas | For deploy/infra topics |
| `module-status.md` | Status and specifics per module/feature | For feature-specific work |
| `features.md` | Feature index — short description + link per feature | To find the right feature file |
| `features/<name>.md` | Per-feature detail (decisions, critical info, gotchas) | When working on that specific feature |
| `bugs-and-fixes.md` | Root cause analyses of solved bugs | For bug fixing |

### Feature Memory

Each feature gets its own file under `docs/memory/features/`. The index `docs/memory/features.md` links to them.

**Index file (`features.md`):**
```markdown
| Feature | Description | File |
|---------|-------------|------|
| Authentication | Login, registration, password reset, 2FA | [auth.md](features/auth.md) |
| User Management | Team members, roles, permissions | [users.md](features/users.md) |
```

**Feature file (`features/<name>.md`)** contains:

- Entities, views, controllers involved
- Architecture decisions specific to this feature
- Critical business rules and compliance requirements
- Known gotchas and edge cases
- Integration points with other features

Only load the specific feature file when working on that feature — never all of them.

**When features change:**

- **New feature added:** Create `features/<name>.md` with entities, decisions, gotchas. Add entry to `features.md` index.
- **Feature removed:** Delete the feature file. Remove entry from `features.md` index.
- **Feature significantly changed:** Update the feature file with new decisions, entities, or gotchas.

### Rules

- **Loading:** Only load files relevant to the current task, not all of them
- **Updating:** After every significant change, update the affected memory file
- **Format:** Fact-based, bullet points with concrete file paths/values — no prose
- **No duplication:** Don't store anything derivable from code or git — only decisions, context, gotchas
- **Not everything:** Only create memory files that are relevant to the project. A small frontend project doesn't need `deployment.md`

---

## Project Overview

| Area | What it is | Primary paths |
|------|------------|----------------|
| **Plugin manifest** | Claude Code plugin identity | [`plugin/.claude-plugin/plugin.json`](plugin/.claude-plugin/plugin.json), [`.claude-plugin/marketplace.json`](.claude-plugin/marketplace.json) |
| **Skills** | `/ai-iap:setup`, `/ai-iap:validate` | [`plugin/skills/setup/SKILL.md`](plugin/skills/setup/SKILL.md), [`plugin/skills/validate/SKILL.md`](plugin/skills/validate/SKILL.md) |
| **Rule & process library** | Generated into user projects from here | [`plugin/lib/rules/`](plugin/lib/rules/), [`plugin/lib/processes/`](plugin/lib/processes/) |
| **Code library** | Shared implementation / design patterns | [`plugin/lib/code-library/`](plugin/lib/code-library/) |
| **Configuration** | Languages, frameworks, mappings | [`plugin/lib/config.json`](plugin/lib/config.json), [`plugin/lib/config.schema.json`](plugin/lib/config.schema.json) |
| **Agents** | Built-in agent templates | [`plugin/agents/`](plugin/agents/), [`plugin/lib/claude-subagents.json`](plugin/lib/claude-subagents.json) |
| **Hooks** | e.g. session start | [`plugin/hooks/hooks.json`](plugin/hooks/hooks.json) |
| **Custom extensions** | Fork overrides | [`plugin/custom/`](plugin/custom/) (see README) |
| **Generated rules (this repo)** | Claude Code rules copied from `plugin/lib/rules/` | [`.claude/rules/`](.claude/rules/) — regenerate via [`scripts/generate-ai-iap-claude-rules.mjs`](scripts/generate-ai-iap-claude-rules.mjs); selection mirror [`.ai-iap-state.json`](.ai-iap-state.json) |

---

## Quick Start (maintainers)

- **Use the plugin from this repo locally:**  
  `claude --plugin-dir ./path/to/ai-instructions-and-prompts`
- **Run setup inside a test project** (not required just to edit sources): `/ai-iap:setup`
- **Validate plugin integrity** after substantive edits: `/ai-iap:validate` in Claude Code with this plugin loaded.
- **Refresh checked-in `.claude/rules/`** when rule sources or language selection for this repo changes:  
  `node scripts/generate-ai-iap-claude-rules.mjs`

---

## Language & Locale

- **Documentation & rule text:** English (this repository’s standard).
- **User-facing generated rules:** English unless the project explicitly ships localized variants.

---

## Conventions

- **Commits:** Conventional Commits — see [`CONTRIBUTING.md`](CONTRIBUTING.md) and [`.cursor/rules/commit-standards.mdc`](.cursor/rules/commit-standards.mdc) if present.
- **Rule/process authoring:** Explicit `> **ALWAYS**` / `> **NEVER**`, tables where they clarify, AI Self-Check sections where used elsewhere.
- **Cursor-specific meta-rules:** [`.cursor/rules/general.mdc`](.cursor/rules/general.mdc) (if present) — align changes so Claude Code and Cursor guidance do not contradict.

---

## Build & Verification

**In Claude Code (recommended after edits that affect validation):**

```text
/ai-iap:validate
```

**CI parity (see [`.github/workflows/validate.yml`](.github/workflows/validate.yml)):**

- Valid JSON: `plugin/lib/config.json`, `plugin/lib/config.schema.json`, `plugin/lib/claude-subagents.json`, `plugin/.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`
- Plugin directory layout (skills, hooks, agents, `plugin/lib/rules`, etc.)
- Rule files referenced from `config.json` exist under `plugin/lib/rules/`
- Contributor docs also mention **markdownlint** on `*.md` — run locally if you touch many markdown files

**Optional:** Workflow **Claude Code Tests** (`.github/workflows/ai-compatibility-tests.yml`) exercises AI-driven checks when secrets and schedule allow.

**Maintainers:** After edits under `plugin/lib/rules/` that affect files emitted into `.claude/rules/`, run `node scripts/generate-ai-iap-claude-rules.mjs` and commit the diff so the repo stays self-consistent.

---

## Change Guidelines

When you change something in this meta-project, **propagate** as needed:

1. **New or renamed rule file:** `plugin/lib/config.json` (and schema if structure changes); setup/validate skills if discovery paths change; README if user-visible.
2. **New language/framework/process:** `config.json` + schema; add files under `plugin/lib/rules/` or `plugin/lib/processes/`; document in `plugin/lib/README.md` if behavior is non-obvious.
3. **Setup merge behavior or output paths:** `plugin/skills/setup/SKILL.md`; validate skill if invariants change.
4. **Functions / code library:** Update the relevant `INDEX.md`; follow `_TEMPLATE.md` for new files.
5. **Plugin version or marketplace metadata:** Bump SemVer in all three places together: `plugin/.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`, and `plugin/lib/config.json` (`version`). Decide MAJOR / MINOR / PATCH per the [Hard Rules](#hard-rules-violations-cause-bugs-or-broken-installs) SemVer bullet; follow team changelog/release practice if documented.
6. **Breaking or behavioral changes to generated output:** Update any quoted examples in root `README.md`, `CONTRIBUTING.md`, or `TROUBLESHOOTING.md`.
7. **Changes to checked-in `.claude/rules/`:** Regenerate with `scripts/generate-ai-iap-claude-rules.mjs`; update `docs/memory/` if module or feature boundaries shift.

---

## What we deliberately **did not** copy from the generic template

- **Initial Setup — Auto-Discovery:** One-off wizard text for **consumer** projects; maintainers use this repo’s README and CONTRIBUTING instead.
- **Placeholder-only sections** (`<!-- AUTO-FILLED -->`, Backend/Frontend/Infra grid): replaced by the **Project Overview** table above.

---

## Knowledge map (read selectively)

| Need | Start here |
|------|------------|
| Context memory (index, ADRs, modules, features) | [`docs/memory/README.md`](docs/memory/README.md) — populated for this repo |
| Plugin capabilities & setup UX | [`README.md`](README.md), [`plugin/lib/README.md`](plugin/lib/README.md) |
| Contributing & PR expectations | [`CONTRIBUTING.md`](CONTRIBUTING.md) |
| Adoption / team rollout | [`TEAM_ADOPTION_GUIDE.md`](TEAM_ADOPTION_GUIDE.md) |
| Operational issues | [`TROUBLESHOOTING.md`](TROUBLESHOOTING.md) |
