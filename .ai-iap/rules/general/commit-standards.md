# Commit Message Standards

> **Reference**: [Conventional Commits v1.0.0](https://www.conventionalcommits.org/en/v1.0.0/)

---

## 🚨 When the user asks you to commit (MANDATORY)

> **NEVER** create a commit unless the user explicitly asks (e.g., "commit", "make a commit", "create a commit").
>
> When asked to commit, **ALWAYS**:
> - Review changes (`git status`, staged + unstaged diffs)
> - Ensure no secrets/credentials are included (e.g., `.env`, tokens, private keys)
> - Stage only files for **one logical change**
> - Write the message using the rules below
> - Commit, then re-run `git status` to verify
>
> If there are **no changes**, say so and **do not** create an empty commit.

---

## Format

> **ALWAYS** follow this structure:

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

---

## Commit Types

| Type | Purpose | Semantic Version |
|------|---------|------------------|
| `feat` | New feature | MINOR |
| `fix` | Bug fix | PATCH |
| `docs` | Documentation only | - |
| `style` | Formatting, whitespace | - |
| `refactor` | Code restructuring | - |
| `perf` | Performance improvement | - |
| `test` | Add/update tests | - |
| `build` | Build system, dependencies | - |
| `ci` | CI configuration | - |
| `chore` | Maintenance, tooling | - |
| `revert` | Revert previous commit | - |

---

## Description Rules

> **ALWAYS**: Imperative mood ("add" NOT "added")  
> **ALWAYS**: Lowercase start  
> **ALWAYS**: No period at end  
> **ALWAYS**: Under 72 characters  
> **NEVER**: Past tense  
> **NEVER**: Capitalize first letter

**Examples**:
```
feat(auth): add OAuth 2.0 support
fix(api): handle null response
docs: update installation guide
```

---

## Scope (Optional)

> **Format**: `type(scope): description`

Common scopes: `api`, `auth`, `db`, `ui`, `docs`, `deps`, `config`

---

## Breaking Changes

> **ALWAYS**: Mark with `!` or `BREAKING CHANGE:` footer

**Method 1** (Exclamation):
```
feat!: remove Node 6 support
```

**Method 2** (Footer):
```
feat: change API format

BREAKING CHANGE: response structure changed
```

---

## Body (Optional)

> **When**: Additional context needed  
> **Format**: One blank line after description

### Body Rules

> **ALWAYS**: Use imperative mood (same as description)  
> **ALWAYS**: Write prose paragraphs (2-3 sentences max per paragraph)  
> **ALWAYS**: Focus on WHAT and WHY, not detailed HOW  
> **NEVER**: Use bullet points, dashes, or numbered lists  
> **NEVER**: Use section headers ("Changes:", "Details:", etc.)  
> **NEVER**: Include code snippets or file lists

**Example**: `feat(api): add pagination\n\nImplement cursor-based pagination for better performance. This replaces offset-based pagination.`

---

## Footer (Optional)

| Footer | Usage |
|--------|-------|
| `BREAKING CHANGE:` | Breaking changes |
| `Refs:` | Reference issues |
| `Closes:` | Close issues |
| `Fixes:` | Fix issues |
| `Reviewed-by:` | Reviewer name |

**Example**:
```
fix: resolve timeout issue

Refs: #123
Reviewed-by: Jane Doe
```

---

## Common Mistakes

| ❌ Wrong | ✅ Correct |
|----------|-----------|
| `feat: Added auth` | `feat: add auth` |
| `fix: Resolve bug` | `fix: resolve bug` |
| `docs: update.` | `docs: update` |
| `feat: add auth, update docs` | Separate commits |
| Body with bullet lists | Body with prose paragraphs |
| Body with section headers | Body without sections |

## AI Self-Check

- [ ] Valid type (`feat`, `fix`, `docs`, etc.)
- [ ] Imperative mood in description ("add" not "added")
- [ ] Lowercase start, no period in description
- [ ] Description under 72 characters
- [ ] Body uses prose paragraphs (NO bullets/lists)
- [ ] Body has NO section headers (NO "Changes:", etc.)
- [ ] Body uses imperative mood throughout
- [ ] Breaking changes marked (`!` or footer)
- [ ] One logical change per commit
- [ ] Scope provided when applicable

---

## Tools

**commitlint** (enforce standards), **semantic-release** (automate versioning), **conventional-changelog** (generate CHANGELOG)
