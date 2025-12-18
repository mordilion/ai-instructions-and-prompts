# JavaScript Architecture

> **Scope**: Apply these rules ONLY when working with `.js`, `.mjs`, or `.cjs` files. These extend the general architecture guidelines.

## 1. Core Principles
- **Modularity**: Small files (<200 lines). ES Modules preferred over CommonJS.
- **Unidirectional Flow**: Data flows down, events bubble up.
- **Progressive Enhancement**: Core functionality works without JavaScript.

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

