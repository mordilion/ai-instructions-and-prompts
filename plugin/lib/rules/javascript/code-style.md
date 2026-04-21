# JavaScript Code Style

> **Scope**: JavaScript formatting (`.js`, `.jsx`, `.mjs`, `.cjs`)  
> **Applies to**: JavaScript files and sections in component files  
> **Extends**: General code style guidelines

## CRITICAL REQUIREMENTS

> **ALWAYS**: Use ES2022+ features (modern syntax)
> **ALWAYS**: JSDoc for public functions
> **ALWAYS**: const by default (not let/var)
> **ALWAYS**: Named exports (not default)
> **ALWAYS**: ESLint + Prettier for formatting
> **ALWAYS**: Use `??` (nullish coalescing) for null/undefined fallbacks
> **ALWAYS**: Use `||` only when any falsy value (`''`, `0`, `false`) should trigger the fallback
>
> **NEVER**: Use var (use const/let)
> **NEVER**: Use default exports
> **NEVER**: Skip JSDoc for public APIs
> **NEVER**: Mutate const objects without reason
> **NEVER**: Use == (use ===)
> **NEVER**: Call the same method twice in one expression (extract to const)
> **NEVER**: Use `||` when only `null`/`undefined` should trigger the fallback (use `??`)

## 1. Core Patterns
- **Version**: ES2022+ features
- **Documentation**: JSDoc for all public functions
- **Immutability**: const by default

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

## 6. Reduce Method Calls (Extract Const + `??` / `||`)

> **ALWAYS**: Extract repeated method calls into a `const`.
> **ALWAYS**: Collapse fallback ternaries into `??` or `||` when possible.

```javascript
// ❌ BAD: customer.getCompanyName() called 3 times
const displayName =
  customer.getCompanyName() !== null && customer.getCompanyName() !== ''
    ? customer.getCompanyName()
    : customer.getContactPerson();

// ✅ GOOD: single call, falsy fallback (empty string also falls through)
const displayName = customer.getCompanyName() || customer.getContactPerson();

// ✅ GOOD (null-only fallback): extract then `??`
const companyName = customer.getCompanyName();
const displayName = companyName !== '' ? (companyName ?? customer.getContactPerson()) : customer.getContactPerson();
```

**Operator cheat sheet**:

| Operator | Falls through on | Use when |
|---|---|---|
| `??` | only `null` / `undefined` | Nullable value, `0` / `''` are valid |
| `\|\|` | any falsy (`0`, `''`, `false`, `null`, `undefined`, `NaN`) | Empty-ish values should trigger fallback |
| `?.` | chain stops on `null` / `undefined` | Traversing nullable object chains |

## 7. Best Practices
- **Async**: `async/await` ONLY. NEVER use `.then()` chains.
- **Error Handling**: Throw errors. NEVER `console.log` and return null.
  - ✅ Good: `throw new Error('User not found');`
  - ❌ Bad: `console.log('Error:', error); return null;`
- **No Magic Numbers**: Use named constants.
- **Components** (React/Vue): Functional preferred. Use hooks/composables.

## AI Self-Check

- [ ] Using ES2022+ features?
- [ ] JSDoc for public functions?
- [ ] const by default (not let/var)?
- [ ] Named exports (not default)?
- [ ] ESLint + Prettier configured?
- [ ] No var usage?
- [ ] No default exports?
- [ ] === (not ==)?
- [ ] async/await (not .then() chains)?
- [ ] Throwing errors (not console.log + return null)?
- [ ] kebab-case for files?
- [ ] camelCase for functions/variables?
- [ ] No method called twice in the same expression (extracted to const)?
- [ ] `??` used for null/undefined fallback, `||` for any-falsy fallback?

