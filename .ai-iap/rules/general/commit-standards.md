# Commit Message Standards

> **Reference**: [Conventional Commits v1.0.0](https://www.conventionalcommits.org/en/v1.0.0/)

---

## Commit Message Format

> **ALWAYS** follow this structure:

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

---

## Required Types

> **ALWAYS** use one of these commit types:

### Primary Types (REQUIRED)

| Type | Purpose | Semantic Version |
|------|---------|------------------|
| `feat` | New feature | MINOR bump |
| `fix` | Bug fix | PATCH bump |

### Additional Types (RECOMMENDED)

| Type | Purpose |
|------|---------|
| `docs` | Documentation only changes |
| `style` | Code style changes (formatting, missing semicolons, etc.) |
| `refactor` | Code refactoring (neither fixes bug nor adds feature) |
| `perf` | Performance improvements |
| `test` | Adding or updating tests |
| `build` | Build system or external dependencies |
| `ci` | CI configuration files and scripts |
| `chore` | Maintenance tasks, tooling updates |
| `revert` | Revert a previous commit |

---

## Commit Type Rules

### feat (Feature)

> **ALWAYS**: Use `feat:` when adding new functionality  
> **Example**: `feat(auth): add OAuth 2.0 support`

### fix (Bug Fix)

> **ALWAYS**: Use `fix:` when correcting a bug  
> **Example**: `fix(api): handle null user response correctly`

### docs (Documentation)

> **ALWAYS**: Use `docs:` for documentation-only changes  
> **Example**: `docs: update installation instructions`

### refactor (Code Refactoring)

> **ALWAYS**: Use `refactor:` when restructuring code without changing behavior  
> **Example**: `refactor(user-service): extract validation logic`

### test (Tests)

> **ALWAYS**: Use `test:` when adding or updating tests  
> **Example**: `test(auth): add integration tests for login flow`

### ci (Continuous Integration)

> **ALWAYS**: Use `ci:` for CI/CD configuration changes  
> **Example**: `ci: add GitHub Actions workflow for testing`

### chore (Maintenance)

> **ALWAYS**: Use `chore:` for maintenance tasks  
> **Example**: `chore: update dependencies to latest versions`

---

## Scope (Optional but Recommended)

> **ALWAYS**: Add scope in parentheses after type for context  
> **Format**: `type(scope): description`

### Scope Examples

| Scope | Usage |
|-------|-------|
| `(api)` | API changes |
| `(auth)` | Authentication module |
| `(db)` | Database changes |
| `(ui)` | User interface |
| `(docs)` | Documentation |
| `(deps)` | Dependencies |
| `(config)` | Configuration |

**Examples**:
```
feat(api): add user endpoint
fix(auth): resolve token expiry issue
docs(readme): add troubleshooting section
```

---

## Description Rules

> **ALWAYS**: Write description in imperative mood ("add" not "added")  
> **ALWAYS**: Start with lowercase letter  
> **ALWAYS**: No period at the end  
> **ALWAYS**: Keep under 72 characters  
> **NEVER**: Use past tense ("added", "fixed")  
> **NEVER**: Capitalize first letter

### Good Examples ✅
```
feat: add user authentication
fix: resolve memory leak in parser
docs: update API documentation
refactor: simplify error handling
```

### Bad Examples ❌
```
feat: Added user authentication          # Past tense
fix: Resolve memory leak                 # Capitalized
docs: update API documentation.          # Period at end
refactor: This commit simplifies error   # Not imperative
```

---

## Breaking Changes

> **ALWAYS**: Indicate breaking changes with `!` or `BREAKING CHANGE:` footer  
> **Format**: `type!: description` OR footer with `BREAKING CHANGE:`

### Method 1: Using `!`

```
feat!: remove support for Node 6

This change drops Node 6 compatibility to use modern JavaScript features.
```

### Method 2: Using Footer

```
feat: allow config object to extend others

BREAKING CHANGE: `extends` key in config file is now used for extending other config files
```

### Method 3: Both (Maximum Visibility)

```
chore!: drop support for Node 6

BREAKING CHANGE: use JavaScript features not available in Node 6
```

> **ALWAYS**: Use `BREAKING CHANGE:` for API changes that require user action  
> **ALWAYS**: Explain the breaking change in the footer  
> **NEVER**: Make breaking changes without explicit indication

---

## Commit Body (Optional)

> **Body Starts**: One blank line after description  
> **Format**: Free-form text, multiple paragraphs allowed

### When to Use Body

> **ALWAYS** add body when:
- Change needs additional context
- Fix requires explanation of root cause
- Multiple related changes in one commit
- Migration or upgrade steps needed

### Body Structure

```
feat(api): add pagination support

Implement cursor-based pagination for user list endpoint to improve
performance with large datasets.

The implementation uses base64-encoded cursors to maintain position
across requests. This approach is more efficient than offset-based
pagination for large tables.
```

---

## Commit Footer (Optional)

> **Footer Starts**: One blank line after body  
> **Format**: `Token: value` or `Token #value`

### Common Footers

| Footer | Purpose | Example |
|--------|---------|---------|
| `BREAKING CHANGE:` | Breaking API change | `BREAKING CHANGE: remove deprecated API` |
| `Refs:` | Reference issue/PR | `Refs: #123, #456` |
| `Closes:` | Close issue | `Closes #789` |
| `Fixes:` | Fix issue | `Fixes #101` |
| `Reviewed-by:` | Reviewer | `Reviewed-by: Jane Doe` |
| `Co-authored-by:` | Co-author | `Co-authored-by: John Smith <john@example.com>` |

### Footer Examples

```
fix: prevent race condition in requests

Introduce request ID tracking to dismiss stale responses.

Refs: #123
Reviewed-by: Jane Doe
```

```
feat: add user export feature

Closes #456
Co-authored-by: John Smith <john@example.com>
```

---

## Complete Examples

### Simple Commit (Description Only)

```
docs: correct spelling of CHANGELOG
```

### Commit with Scope

```
feat(lang): add Polish language
```

### Commit with Body

```
fix: prevent racing of requests

Introduce a request id and a reference to latest request. Dismiss
incoming responses other than from latest request.

Remove timeouts which were used to mitigate the racing issue but are
obsolete now.
```

### Commit with Multiple Footers

```
fix: resolve authentication timeout

Update token refresh logic to prevent premature session expiry.
The previous implementation had a timing issue where tokens would
expire before the refresh completed.

Fixes: #234
Reviewed-by: Security Team
Refs: #235, #236
```

### Breaking Change with Full Context

```
feat(api)!: change user response format

Standardize all API responses to include metadata wrapper.

User endpoints now return:
{
  "data": { ...user object... },
  "meta": { "version": "2.0" }
}

BREAKING CHANGE: All user API endpoints now return wrapped responses.
Clients must access user data via response.data instead of root object.

Migration: Update all API clients to use response.data
Refs: #789
```

---

## Revert Commits

> **Type**: Use `revert:` type  
> **Reference**: Include commit SHAs in footer

```
revert: let us never again speak of the noodle incident

Refs: 676104e, a215868
```

---

## Multi-Change Commits

> **NEVER**: Combine unrelated changes in one commit  
> **ALWAYS**: Split into multiple commits when possible

### Bad (Multiple Unrelated Changes) ❌
```
feat: add user auth and update docs and fix bug
```

### Good (Separate Commits) ✅
```
feat(auth): add user authentication
docs: update authentication guide
fix(auth): resolve token refresh issue
```

---

## AI Self-Check for Commit Messages

Before committing, verify:

- [ ] Type is valid (`feat`, `fix`, `docs`, etc.)
- [ ] Scope is provided (when applicable)
- [ ] Description is in imperative mood
- [ ] Description starts with lowercase
- [ ] Description has no period at end
- [ ] Description is under 72 characters
- [ ] Breaking changes marked with `!` or `BREAKING CHANGE:` footer
- [ ] Body has blank line after description (if present)
- [ ] Footer has blank line after body (if present)
- [ ] Issue references use `Refs:`, `Closes:`, or `Fixes:`
- [ ] Commit focuses on one logical change
- [ ] Past tense NOT used ("added" → "add")

---

## Common AI Mistakes

### ❌ WRONG: Past Tense
```
feat: added user authentication
fix: resolved memory leak
```

### ✅ CORRECT: Imperative Mood
```
feat: add user authentication
fix: resolve memory leak
```

---

### ❌ WRONG: Capitalized Description
```
feat: Add user authentication
fix: Resolve memory leak
```

### ✅ CORRECT: Lowercase
```
feat: add user authentication
fix: resolve memory leak
```

---

### ❌ WRONG: Period at End
```
feat: add user authentication.
fix: resolve memory leak.
```

### ✅ CORRECT: No Period
```
feat: add user authentication
fix: resolve memory leak
```

---

### ❌ WRONG: Missing Breaking Change Indicator
```
feat: change API response format

This changes all endpoints to return wrapped responses.
```

### ✅ CORRECT: Breaking Change Marked
```
feat!: change API response format

BREAKING CHANGE: All endpoints now return wrapped responses
```

---

### ❌ WRONG: Multiple Unrelated Changes
```
feat: add auth, update docs, fix bugs
```

### ✅ CORRECT: Separate Commits
```
feat(auth): add user authentication
docs: update authentication guide
fix(auth): resolve token validation
```

---

### ❌ WRONG: Vague Description
```
fix: fix bug
feat: update code
```

### ✅ CORRECT: Specific Description
```
fix(auth): resolve token refresh race condition
feat(api): add pagination to user list endpoint
```

---

## Benefits of Conventional Commits

✅ **Automated CHANGELOG generation**  
✅ **Semantic versioning automation**  
✅ **Clear change communication**  
✅ **Easier to explore history**  
✅ **Trigger CI/CD processes**  
✅ **Structured contribution workflow**

---

## Tools Integration

### Commitlint

Enforce commit conventions with [commitlint](https://commitlint.js.org/):

```bash
npm install --save-dev @commitlint/cli @commitlint/config-conventional
```

### Semantic Release

Automate versioning with [semantic-release](https://semantic-release.gitbook.io/):

```bash
npm install --save-dev semantic-release
```

### Conventional Changelog

Generate CHANGELOG with [conventional-changelog](https://github.com/conventional-changelog/conventional-changelog):

```bash
npm install --save-dev conventional-changelog-cli
```

---

## Quick Reference Card

```
Commit Types:
  feat      → New feature (MINOR)
  fix       → Bug fix (PATCH)
  docs      → Documentation
  style     → Formatting
  refactor  → Code restructuring
  perf      → Performance
  test      → Tests
  build     → Build system
  ci        → CI configuration
  chore     → Maintenance
  revert    → Revert commit

Breaking Changes:
  type!: description
  OR
  BREAKING CHANGE: description in footer

Format:
  <type>[scope]: <description>
  
  [body]
  
  [footer]

Rules:
  ✅ Imperative mood ("add" not "added")
  ✅ Lowercase description
  ✅ No period at end
  ✅ Under 72 characters
  ✅ One logical change per commit
```

