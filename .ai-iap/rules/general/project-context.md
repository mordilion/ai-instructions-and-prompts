# [Project Name] — Project Context

> **NOTE:** Fill in all sections marked `<!-- FILL IN -->` to give the AI accurate project context.
> Delete sections that don't apply to this project.

---

## Hard Rules (violations cause bugs)
- Follow all applicable rules and rule precedence.
- Ask 2-5 targeted questions if outcomes or constraints are unclear.
- Validate all external input before use (type, format, bounds).
- Never log or store secrets; redact sensitive values in logs.
- Use code library patterns instead of inventing new ones.
- Do not introduce fixed versions; read from project config files.
- Prefer smallest change that satisfies requirements.
- Keep outputs concise and unambiguous across AI tools.

---

## Workflow & Quality Assurance

### Planning
- For tasks with 3+ steps or architecture decisions: plan before writing code.
- If an implementation is going in the wrong direction: stop immediately and re-plan.
- Clarify specifications upfront to reduce ambiguity.

### Verification
- Never complete a task without verification: run tests, check logs, demonstrate correctness.
- For relevant changes: verify diff against previous behavior.
- Effort proportional to complexity — simple fixes don't need elaborate verification.

### Bug Fixing
- Analyze and fix independently — use logs, error messages, and tests as starting points.
- Find the root cause. No temporary workarounds.
- Fix failing CI tests independently.

### Core Principles
- **Simplicity First:** Every change as simple as possible. Touch minimal code.
- **Minimal Impact:** Only change what's necessary. Don't introduce new bugs.
- **Root Cause:** Find causes, don't treat symptoms.

---

## Project Overview

<!-- FILL IN: tech stack, key directories -->

| Layer | Stack | Directory |
|-------|-------|-----------|
| Backend | | |
| Frontend | | |
| Infra | | |

---

## Quick Start

<!-- FILL IN: commands to set up and run the project locally -->

```bash
# Setup
# Start dev server
# Run tests
```

---

## Language & Locale

<!-- FILL IN: UI and code language -->

- **UI Language:** English
- **Code Language:** English (variables, functions, types)
- **API Fields:** English

---

## Architecture

<!-- FILL IN: patterns, key modules, data flow, multi-tenancy, auth, etc. -->

---

## Conventions

<!-- FILL IN: naming patterns, file organization, rules not enforced by linters -->

---

## Architecture Decisions (ADRs)

<!-- FILL IN: key decisions with reasoning; extend over time -->

| ADR | Decision | Reasoning |
|-----|----------|-----------|
| 001 | | |

---

## Build & Verification

<!-- FILL IN: type-check, build, and test commands -->

```bash
# Type-Check
# Build
# Tests
```

---

## Change Guidelines

<!-- FILL IN: step-by-step for common change types in this project -->

1. **New Entity:** ...
2. **New UI Component:** ...
3. **New View/Route:** ...
4. **New Feature:** ...
