# Code Style & Philosophy (General)

> **Scope**: These are baseline rules for ALL languages. Language-specific rules (when present) take precedence.

## 1. Core Principles
- **SOLID**: Apply strictly. When SRP conflicts with locality, prioritize: code <50 lines per unit > perfect SRP.
- **DRY**: Abstract after 3 repetitions (Rule of Three).
- **YAGNI**: NEVER implement features "for later".
- **KISS**: Simplest working solution wins.

## 2. Structure
- **Order**: Constants → Fields → Constructor → Public Methods → Private Methods.
- **Grouping**: By feature, NOT alphabetically. Getter/Setter adjacent.
- **Method Size**: Target 20-30 lines. MUST refactor if >50 lines. Split when description requires "and".

## 3. Naming
- **Language**: English only (code, comments, commits).
- **Clarity**: Full words (`index` not `i`), except loop counters (`i`, `j`, `k` allowed).
- **Intent**: Name describes WHAT, not HOW.

## 4. Control Flow
- **Guard Clauses**: Return early. Avoid `else`.
  - ✅ Good: `if (!valid) return; processData();`
  - ❌ Bad: `if (valid) { processData(); } else { return; }`
- **Happy Path**: Main logic at lowest indentation.

## 5. Best Practices
- **Comments**: Explain WHY, never WHAT. Code MUST be self-documenting.
- **Refactoring**: ONLY change touched lines. Do NOT reformat unrelated code.
- **Testability**: Write code that can be tested. Inject dependencies, avoid static state.

