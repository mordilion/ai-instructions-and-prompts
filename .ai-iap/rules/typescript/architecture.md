# TypeScript Architecture

> **Scope**: TypeScript architectural patterns and principles
> **Applies to**: *.ts, *.tsx, *.mts, *.cts, *.vue, *.svelte files
> **Extends**: General architecture rules
> **Precedence**: Structure > Framework > Language > General

## CRITICAL REQUIREMENTS

> **ALWAYS**: Enable `strict: true` in tsconfig.json
> **ALWAYS**: Use interfaces for objects, types for unions/primitives
> **ALWAYS**: Prefer `unknown` over `any`
> **ALWAYS**: Use dependency injection (constructor)
> **ALWAYS**: Explicit return types for public methods
> 
> **NEVER**: Use `any` (use `unknown` + type guards)
> **NEVER**: Export everything (explicit exports only)
> **NEVER**: Mutate readonly types
> **NEVER**: Ignore TypeScript errors with `@ts-ignore`
> **NEVER**: Use enums for strings (use union types)

## Rule Precedence Matrix

When rules conflict across multiple files, use this priority order:

| Your Context | Winning Rule File | Overrides |
|-------------|-------------------|-----------|
| React component structure | react.md → react-modular.md | TypeScript + General rules |
| Next.js Server Component | nextjs.md | React + TypeScript rules |
| Angular service | angular.md | TypeScript + General rules |
| Generic TypeScript class | **This file** | General rules only |
| NestJS controller | nestjs.md | TypeScript + General rules |

**Rule**: MOST SPECIFIC FILE ALWAYS WINS.

### Example Conflict Resolution

```
Context: React TypeScript component naming
Question: Should it be camelCase or PascalCase?

Precedence check:
1. Structure rules (react-modular.md)? → No naming guidance
2. Framework rules (react.md)? → "PascalCase for components" ← USE THIS
3. Language rules (this file)? → "camelCase for functions" ← IGNORE
4. General rules? → "camelCase" ← IGNORE

Answer: PascalCase (Framework rule wins over language rule)
```

```
Context: Generic TypeScript utility function
Question: How to structure error handling?

Precedence check:
1. Structure rules? → Not applicable (no structure selected)
2. Framework rules? → Not applicable (not framework-specific)
3. Language rules (this file)? → Use Result<T, E> type ← USE THIS
4. General rules? → Throw exceptions ← IGNORE (language rule more specific)

Answer: Use Result<T, E> (Language rule wins over general rule)
```

## Overview
Type-safe architecture with clean separation, modularity, and maintainability.

## Core Principles

| Principle | Pattern |
|-----------|---------|
| **Type Safety** | `interface` + `Pick/Omit/Partial`, avoid `any` |
| **Immutability** | `Readonly<T>` + spread operators `{...obj}` |
| **Error Handling** | `Result<T, E>` pattern or `try/catch` |

## Dependency Management

| Pattern | Implementation |
|---------|---------------|
| **Dependency Injection** | Constructor injection with interfaces |
| **Interface Segregation** | Split interfaces (Readable, Writable) + combine with `&` |

## Modularity

### Feature Modules
```typescript
// user/index.ts
export { UserService } from './UserService';
export type { User } from './types';

// app.ts
import { UserService } from './user';
```

### Barrel Exports
```typescript
// features/index.ts
export * from './user';
export * from './post';
```

## Best Practices

| Practice | Pattern |
|----------|---------|
| **Strict Mode** | Enable `strict: true` in tsconfig |
| **Enums/Unions** | `type Role = 'admin' \| 'user'` or `enum Status` |
| **Utility Types** | `Partial<T>`, `Required<T>`, `Readonly<T>`, `Pick<T, K>`, `Omit<T, K>` |

## AI Self-Check

- [ ] `strict: true` enabled in tsconfig.json?
- [ ] Using interfaces for objects, types for unions?
- [ ] Preferring `unknown` over `any`?
- [ ] Dependency injection via constructor?
- [ ] Explicit return types for public methods?
- [ ] No `any` usage (using `unknown` + type guards)?
- [ ] Explicit exports only (no export *)?
- [ ] No mutations of readonly types?
- [ ] No `@ts-ignore` (using `@ts-expect-error` if needed)?
- [ ] Union types instead of string enums?
- [ ] Feature-first module structure?
- [ ] Barrel exports for public API?
