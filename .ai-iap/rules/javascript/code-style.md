# JavaScript Code Style

> **Scope**: Apply these rules ONLY when working with JavaScript files (`.js`, `.jsx`, `.mjs`, `.cjs`) and JavaScript sections in component files (e.g. `.vue`, `.svelte`). These extend the general code style guidelines.

## 1. Core Principles
- **Version**: ES2022+ features. Use modern syntax.
- **Documentation**: JSDoc for all public functions and complex types.
- **Immutability**: `const` by default. Mutate only when necessary.

## 2. Structure
- **Files**: One exported item per file preferred.
- **Imports**: Group: Built-in → External → Internal. Blank line between groups.
- **Exports**: Named exports ONLY. No default exports.
- **Member Order**:
  1. JSDoc type definitions
  2. Constants
  3. Factory functions / Classes
  4. Public functions
  5. Private functions (prefix `_` or use module scope)

## 3. Naming
- **Files**: `kebab-case.js` (e.g., `user-profile.service.js`).
- **Classes/Constructors**: `PascalCase`.
- **Variables/Functions**: `camelCase`.
- **Constants**: `UPPER_SNAKE_CASE` for true constants.
- **Booleans**: Prefix `is`, `has`, `should`, `can`.
- **Private**: Prefix with `_` or keep module-scoped.

## 4. JSDoc Types
- **Document types** for IDE support and documentation.
- Use `@typedef` for complex types.
- Use `@param` and `@returns` for functions.

```javascript
/**
 * @typedef {Object} User
 * @property {string} id
 * @property {string} name
 * @property {string} email
 */

/**
 * Fetches a user by ID
 * @param {string} id - The user ID
 * @returns {Promise<User>} The user object
 */
async function fetchUser(id) {
  const response = await fetch(`/api/users/${id}`);
  return response.json();
}
```

## 5. Language Features
- **Iteration**: `map`, `filter`, `reduce` over `for` loops.
- **Null Handling**: Use `??` (nullish coalescing), `?.` (optional chaining).
- **Destructuring**: Use for objects and arrays when it improves clarity.
- **Spread Operator**: Prefer over `Object.assign()`.

## 6. Best Practices
- **Async**: `async/await` ONLY. NEVER use `.then()` chains.
- **Error Handling**: Throw errors. NEVER `console.log` and return null.
  - ✅ Good: `throw new Error('User not found');`
  - ❌ Bad: `console.log('Error:', error); return null;`
- **No Magic Numbers**: Use named constants.
- **Components** (React/Vue): Functional preferred. Use hooks/composables.

