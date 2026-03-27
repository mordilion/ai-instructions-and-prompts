# Code Documentation Standards

> **Scope**: Inline comments, docstrings, JSDoc, XML docs, etc.

## CRITICAL REQUIREMENTS

> **ALWAYS**: Write self-documenting code first (clear names, simple logic)
> **ALWAYS**: Document WHY, not WHAT
> **ALWAYS**: Keep comments synchronized with code changes
> **ALWAYS**: Document all public functions/methods
> **ALWAYS**: Include parameters, return values, exceptions
> 
> **NEVER**: State the obvious ("increment i" for `i++`)
> **NEVER**: Comment out code (use git instead)
> **NEVER**: Write misleading or outdated comments
> **NEVER**: Skip documentation for complex algorithms

---

## When to Document

| Scenario | Action | Example |
|----------|--------|---------|
| Complex algorithm | **Required** | `// Boyer-Moore for O(n) search` |
| Non-obvious logic | **Required** | `// Retry 3x due to API rate limit` |
| Workaround/hack | **Required** | `// TODO: Remove after API v2 release` |
| Public API | **Required** | Full docstring with params/returns |
| Self-explanatory code | **Skip** | `const total = price * quantity` |
| Variable declaration | **Skip** | `let count = 0 // Initialize count` ❌ |

---

## Function/Method Documentation

> **ALWAYS**: Document all public functions/methods  
> **ALWAYS**: Include parameters, return values, exceptions  
> **ALWAYS**: Provide usage examples for complex functions  
> **NEVER**: Document private/internal functions unless complex

### Format

**Structure**: Description + Parameters (@param) + Return (@return/@returns) + Exceptions (@throws/@raises)  
**Tools**: Python docstrings, JSDoc, Javadoc, XML comments (.NET), RDoc (Ruby)

---

## Inline Comments

> **ALWAYS**: Place comments above the code they describe  
> **ALWAYS**: Use complete sentences with proper punctuation  
> **ALWAYS**: Keep comments concise (1-2 lines preferred)

**✅ Good**:
```typescript
// Batch requests to avoid rate limiting (max 100/min)
const batches = chunkArray(requests, 100);

// User timezone required for accurate scheduling
const timezone = user.timezone || 'UTC';
```

**❌ Bad**:
```typescript
const batches = chunkArray(requests, 100); // create batches

// timezone
const timezone = user.timezone || 'UTC';
```

---

## TODO/FIXME/HACK Comments

> **Format**: `// TAG(author): Description [ticket]`

| Tag | Purpose | Priority | Example |
|-----|---------|----------|---------|
| `TODO` | Future improvement | Medium | `// TODO(john): Add caching [#123]` |
| `FIXME` | Known bug | High | `// FIXME(jane): Race condition [#456]` |
| `HACK` | Temporary workaround | Review | `// HACK(bob): Remove after v2 [#789]` |
| `NOTE` | Important context | Info | `// NOTE: API changed in v3.0` |

---

## Class/Module Documentation

> **ALWAYS**: Document purpose and responsibilities at top of file  
> **ALWAYS**: Include usage examples for complex classes  
> **ALWAYS**: Document public interfaces and contracts

**Example**:
```python
"""User authentication service.

Handles JWT token generation, validation, and refresh.
Integrates with OAuth providers (Google, GitHub).

Usage:
    auth = AuthService(config)
    token = auth.generate_token(user_id)
    user = auth.validate_token(token)
"""
```

---

## Documentation Anti-Patterns

| ❌ Bad Practice | ✅ Better Approach |
|----------------|-------------------|
| Redundant comments | Self-documenting code |
| Commented-out code | Delete and use git history |
| Outdated comments | Update or remove |
| Implementation details in public docs | Move to internal comments |
| Version history in comments | Use git log |

---

## Language-Specific Tools

| Language | Tool ⭐ | Alternative | Format |
|----------|---------|-------------|--------|
| Python | Sphinx ⭐ | pdoc3 | reStructuredText |
| TypeScript | TSDoc ⭐ | TypeDoc | JSDoc tags |
| Java | Javadoc ⭐ | - | HTML |
| C# | XML Docs ⭐ | DocFX | XML |
| PHP | PHPDoc ⭐ | phpDocumentor | PHPDoc tags |
| Go | godoc ⭐ | - | Plain text |
| Rust | rustdoc ⭐ | - | Markdown |

---

## AI Self-Check

- [ ] All public functions have complete documentation
- [ ] Comments explain WHY, not WHAT
- [ ] No commented-out code blocks
- [ ] No obvious or redundant comments
- [ ] All TODO/FIXME tags include author and context
- [ ] Docstrings follow language conventions
- [ ] Complex algorithms have explanatory comments
- [ ] All parameters and return values documented
- [ ] Exception/error cases documented
- [ ] Documentation is up-to-date with code
- [ ] Usage examples provided for complex functions
- [ ] No misleading or outdated comments
