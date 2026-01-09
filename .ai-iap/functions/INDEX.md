# Functions Index - Cross-Language Implementation Patterns

> **Purpose**: Quick reference for common coding patterns across all supported languages
>
> **Usage**: Find the function you need, check language availability, use exact patterns to reduce AI guessing

---

## How to Use This Index

1. **Find your pattern** in the table below
2. **Check language support** for your project
3. **Open the function file** for complete implementation
4. **Copy the pattern** - don't let AI guess, use proven implementations

---

## Available Functions

| Function | Description | Languages | When to Use | File |
|----------|-------------|-----------|-------------|------|
| **Error Handling** | Exception handling, error propagation, custom errors | All 8 | When handling failures, validation errors, external API errors | [error-handling.md](error-handling.md) |
| **Async Operations** | Async/await, promises, concurrent execution | All 8 | When dealing with I/O, API calls, database queries | [async-operations.md](async-operations.md) |
| **Input Validation** | Data validation, sanitization, type checking | All 8 | When accepting user input, API requests, form data | [input-validation.md](input-validation.md) |
| **Database Queries** | Safe queries, parameterization, connection management | All 8 | When querying databases, preventing SQL injection | [database-query.md](database-query.md) |
| **HTTP Requests** | API calls, retry logic, timeout handling | All 8 | When consuming external APIs, microservice communication | [http-requests.md](http-requests.md) |

---

## Language Coverage

All functions cover these 8 languages:

- **TypeScript** / **JavaScript** (Node.js)
- **Python**
- **Java**
- **C# (.NET)**
- **PHP**
- **Kotlin**
- **Swift**
- **Dart** (Flutter)

---

## Quick Selection Guide

### By Use Case

**Building APIs?**
→ Start with: Error Handling, Input Validation, Database Queries

**Frontend Applications?**
→ Start with: Async Operations, HTTP Requests, Input Validation

**Backend Services?**
→ Start with: Database Queries, Error Handling, HTTP Requests

**Mobile Apps?**
→ Start with: Async Operations, HTTP Requests, Error Handling

---

## Pattern Benefits

✅ **Consistency**: Same pattern across all your projects
✅ **Security**: Validated, safe implementations
✅ **Performance**: Optimized for each language
✅ **Maintainability**: Well-documented, proven patterns
✅ **Reduced Errors**: Less guessing = fewer bugs

---

## How Functions Differ from Processes

| Aspect | Functions | Processes |
|--------|-----------|-----------|
| **Scope** | Single coding pattern | Complete workflow |
| **Size** | 5-20 lines of code | Multi-step implementation |
| **Languages** | All in one file | Separate file per language |
| **Usage** | Copy exact pattern | Follow step-by-step guide |
| **Example** | "How to handle errors" | "How to implement testing" |

---

## Adding Custom Functions

To add your own function patterns:

1. Create `custom-pattern.md` in `.ai-iap/functions/`
2. Follow existing file structure
3. Include all languages your team uses
4. Add entry to this INDEX
5. Update `.cursor/rules/` to reference it

---

## Quick Reference Checklist

Before implementing ANY function, ask:

- [ ] Is there a pattern in `/functions/` for this?
- [ ] Have I checked the INDEX?
- [ ] Am I using the exact pattern (not guessing)?
- [ ] Have I checked for language-specific variations?

**Remember**: Copy patterns = Consistent code. Guessing = Inconsistent code.

---

**Last Updated**: 2026-01-09
**Total Functions**: 5
**Languages Covered**: 8
