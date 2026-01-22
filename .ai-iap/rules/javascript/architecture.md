# JavaScript Architecture

> **Scope**: JavaScript architectural patterns (`.js`, `.jsx`, `.mjs`, `.cjs`)  
> **Applies to**: JavaScript files and sections in component files (`.vue`, `.svelte`)  
> **Extends**: General architecture guidelines

## CRITICAL REQUIREMENTS

> **ALWAYS**: Use ES Modules (import/export)
> **ALWAYS**: Feature-first structure (not by type)
> **ALWAYS**: Named exports (not default)
> **ALWAYS**: Async/await for async operations
> **ALWAYS**: Error boundaries for React/component frameworks
> 
> **NEVER**: Pollute global scope
> **NEVER**: Use CommonJS in new code
> **NEVER**: Create circular imports
> **NEVER**: Use callback hell (use async/await)
> **NEVER**: Create God components (>200 lines)

## 1. Core Patterns
- **Modularity**: Small files (<200 lines). ES Modules preferred
- **Unidirectional Flow**: Data flows down, events bubble up
- **Progressive Enhancement**: Core functionality works without JavaScript

## 2. Project Structure
- **Feature-First**: Organize by feature/module, NOT by type (controllers/, services/).
- **Shared Code**: Common utilities in `shared/` or `common/` folder.
- **Types via JSDoc**: Document types with JSDoc comments for IDE support.
- **Note**: See structure files for specific folder layouts (React, Vue, etc.).

## 3. Naming Conventions
- **Files**: `kebab-case.js` (e.g., `user-profile.js`).
- **Classes/Constructors**: `PascalCase`.
- **Functions/Variables**: `camelCase`.
- **Constants**: `UPPER_SNAKE_CASE` for true constants.

## 4. Design Patterns
- **Container/Presenter**: Separate logic from rendering.
- **Factory Functions**: Prefer over classes for object creation.
- **Module Pattern**: Use ES Modules for encapsulation.

## 5. Module System
- **ES Modules**: `import`/`export` preferred over CommonJS.
- **Named Exports**: Prefer over default exports for tree-shaking.
- **Barrel Files**: Use `index.js` sparingly to avoid circular imports.

## 6. Anti-Patterns (MUST avoid)
- **Circular Imports**: Use `madge` to detect. Restructure if found.
- **Global Variables**: NEVER pollute global scope. Use modules.
- **Callback Hell**: Use Promises or async/await.
- **God Components**: Components >200 lines = split into smaller ones.

## Example: Feature-First Structure

```javascript
// features/user/userService.js
export async function getUser(id) {
  const response = await fetch(`/api/users/${id}`);
  return response.json();
}

// features/user/index.js
export { getUser } from './userService';
export { UserCard } from './UserCard';
```

## AI Self-Check

- [ ] Using ES Modules (import/export)?
- [ ] Feature-first structure (not by type)?
- [ ] Named exports (not default)?
- [ ] async/await for async operations?
- [ ] Files <200 lines?
- [ ] No global scope pollution?
- [ ] No CommonJS in new code?
- [ ] No circular imports?
- [ ] No callback hell?
- [ ] No God components?
- [ ] JSDoc for public functions?
- [ ] madge for circular dependency detection?

