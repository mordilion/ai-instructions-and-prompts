# TypeScript Code Style

> **Scope**: Apply these rules ONLY when working with `.ts` or `.tsx` files. These extend the general code style guidelines.

## 1. Core Principles
- **Version**: ES2022+ / TypeScript 5+ features required.
- **Type Safety**: NEVER use `any`. Use `unknown` with type guards.
- **Immutability**: `const` by default. Mutate only when necessary.

## 2. Structure
- **Files**: One exported item per file preferred.
- **Imports**: Group: Built-in → External → Internal. Blank line between groups.
- **Exports**: Named exports ONLY. No default exports.
- **Member Order**:
  1. Type definitions
  2. Constants
  3. Constructor / Factory
  4. Public methods
  5. Private methods

## 3. Naming
- **Files**: `kebab-case.ts` (e.g., `user-profile.service.ts`).
- **Classes/Interfaces/Types**: `PascalCase`.
- **Variables/Functions**: `camelCase`.
- **Constants**: `UPPER_SNAKE_CASE` for true constants.
- **Booleans**: Prefix `is`, `has`, `should`, `can`.
- **Interfaces**: NO `I` prefix (e.g., `User`, not `IUser`).

## 4. Language Features
- **Types**: `interface` for objects. `type` for unions/intersections.
- **Iteration**: `map`, `filter`, `reduce` over `for` loops.
- **Null Handling**: Use `?`, `??`, `?.`. Enable `strictNullChecks`.
- **Destructuring**: Use for objects and arrays when it improves clarity.

## 5. Best Practices
- **Async**: `async/await` ONLY. NEVER use `.then()` chains.
- **Error Handling**: Throw typed errors. NEVER `console.log` errors and return null.
  - ✅ Good: `throw new NotFoundError('User not found');`
  - ❌ Bad: `console.log('Error:', error); return null;`
- **DI**: Constructor injection. Avoid global state.
- **Components** (React): Functional only. Use hooks. No class components.
