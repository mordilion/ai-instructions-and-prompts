# Code Style & Philosophy (General)

> **Scope**: These are baseline rules for ALL languages. Language-specific rules (when present) take precedence.

## CRITICAL REQUIREMENTS

> **ALWAYS**: Apply SOLID principles
> **ALWAYS**: English only (code, comments, commits)
> **ALWAYS**: Self-documenting code (comments explain WHY)
> **ALWAYS**: Refactor methods >50 lines
> **ALWAYS**: Avoid else (use early returns)
> 
> **NEVER**: Implement features "for later" (YAGNI)
> **NEVER**: Abstract before 3 repetitions (DRY)
> **NEVER**: Use else/else if (use early returns/switch)
> **NEVER**: Magic numbers (use named constants)
> **NEVER**: Reformat unrelated code

## 1. Core Principles
- **SOLID**: Apply strictly
- **DRY**: Abstract after 3 repetitions (Rule of Three)
- **YAGNI**: NEVER implement features "for later"
- **KISS**: Simplest working solution wins

## 2. Structure
- **Order**: Constants → Fields → Constructor → Public Methods → Private Methods.
- **Grouping**: By feature, NOT alphabetically. Getter/Setter adjacent.
- **Method Size**: Target 20-30 lines. MUST refactor if >50 lines. Split when description requires "and".

## 3. Naming
- **Language**: English only (code, comments, commits).
- **Clarity**: Full words (`index` not `i`), except loop counters (`i`, `j`, `k` allowed).
- **Intent**: Name describes WHAT, not HOW.

## 4. Control Flow

> **ALWAYS**: Prefer early returns over else. Keep happy path at lowest indentation.

```typescript
// ❌ BAD: Nested else chains
function getDiscount(user: User): number {
  if (user.isPremium) {
    if (user.years > 5) {
      return 0.3;
    } else {
      return 0.15;
    }
  } else {
    return 0;
  }
}

// ✅ GOOD: Guard clauses, flat logic
function getDiscount(user: User): number {
  if (!user.isPremium) return 0;
  if (user.years > 5) return 0.3;
  return 0.15;
}
```

- **Multiple branches**: Use `switch` / pattern matching instead of `else if` chains.
- **Template languages**: If markup requires `else` (Razor `@if/else`, Svelte `{:else}`), prefer extracted components or enum-driven rendering.

## 5. Best Practices
- **Comments**: Explain WHY, never WHAT. Code MUST be self-documenting.
- **Refactoring**: ONLY change touched lines. Do NOT reformat unrelated code.
- **Testability**: Write code that can be tested. Inject dependencies, avoid static state.

## AI Self-Check

- [ ] SOLID principles applied?
- [ ] English only (code, comments, commits)?
- [ ] Comments explain WHY (not WHAT)?
- [ ] Methods refactored if >50 lines?
- [ ] Avoiding else (using early returns)?
- [ ] DRY after 3 repetitions (not before)?
- [ ] No features "for later" (YAGNI)?
- [ ] No magic numbers (using named constants)?
- [ ] No reformatting unrelated code?
- [ ] Full words in names (except i, j, k)?
- [ ] Code self-documenting?
- [ ] Happy path at lowest indentation?

