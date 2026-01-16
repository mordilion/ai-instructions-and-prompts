# Functions Index - Cross-Language Implementation Patterns

> **Purpose**: Quick reference for common coding patterns across all supported languages

---

## 🚨 FOR AI ASSISTANTS: READ THIS FIRST

**BEFORE** implementing **ANY** of these patterns, **CHECK THIS INDEX**:

- ✅ **DO** check for a **custom/company functions index** first (if one exists in this project)
- ❌ **DON'T** generate error handling code from scratch
- ❌ **DON'T** guess async/await implementations
- ❌ **DON'T** create validation logic without checking here first
- ❌ **DON'T** write database queries without using provided patterns
- ❌ **DON'T** implement HTTP clients without checking available options

- ✅ **DO** check this INDEX before implementing any covered function pattern
- ✅ **DO** open the function file and read YAML metadata for framework options
- ✅ **DO** use exact code patterns from function files
- ✅ **DO** choose appropriate framework version (Native, ORM, Library, etc.)
- ✅ **DO** save 70-80% of tokens by using proven patterns

**This is MANDATORY to reduce token waste and ensure consistent, secure code.**

---

## Available Functions

| Function | Description | Languages | When to Use | File |
|----------|-------------|-----------|-------------|------|
| **Error Handling** | Exception handling, error propagation, custom errors | All 8 | When handling failures, validation errors, external API errors | [error-handling.md](error-handling.md) |
| **Async Operations** | Async/await, promises, concurrent execution | All 8 | When dealing with I/O, API calls, database queries | [async-operations.md](async-operations.md) |
| **Input Validation** | Data validation, sanitization, type checking | All 8 | When accepting user input, API requests, form data | [input-validation.md](input-validation.md) |
| **Database Queries** | Safe queries, parameterization, connection management | All 8 | When querying databases, preventing SQL injection | [database-query.md](database-query.md) |
| **HTTP Requests** | API calls, retry logic, timeout handling | All 8 | When consuming external APIs, microservice communication | [http-requests.md](http-requests.md) |
| **Logging** | Structured logs, correlation IDs, redaction | All 8 | When adding observability and debugging production issues | [logging.md](logging.md) |
| **Caching** | TTL caches, invalidation, distributed caching | All 8 | When reducing load and speeding up hot reads | [caching.md](caching.md) |
| **Config & Secrets** | Env/config loading, fail-fast validation, redaction | All 8 | When loading runtime configuration safely | [config-secrets.md](config-secrets.md) |
| **Auth & Authorization** | JWT/session auth, RBAC/policy checks | All 8 | When protecting endpoints and enforcing permissions | [auth-authorization.md](auth-authorization.md) |
| **Rate Limiting** | Throttling, 429 handling, abuse protection | All 8 | When protecting public endpoints and auth flows | [rate-limiting.md](rate-limiting.md) |
| **Webhooks** | Signature verification, idempotency basics | All 8 | When receiving third-party events securely | [webhooks.md](webhooks.md) |
| **Money & Decimals** | Minor units, decimal math, rounding rules | All 8 | When dealing with prices, totals, tax, and currency | [money-decimal.md](money-decimal.md) |

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

## Function File Structure

Each function file contains:

### YAML Frontmatter (Metadata Header)
- **title**: Function name
- **category**: Classification (Security, Performance, etc.)
- **difficulty**: beginner | intermediate | advanced
- **purpose**: What this pattern solves
- **when_to_use**: List of use cases
- **languages**: All 8 languages with framework variants
  - Each language lists 2-4 implementations (Native, Framework A, Framework B, etc.)
  - Marks recommended approach for each language
  - Includes library names for quick lookup
- **common_patterns** / **common_regex**: Quick reference tables
- **best_practices**: DO/DON'T lists
- **related_functions**: Links to related patterns
- **tags**: Search keywords
- **updated**: Last modification date

### Code Examples (After Metadata)
- Pure code only, no explanations
- Organized by language, then by framework variant
- 5-20 lines per example
- Real-world, copy-paste ready

**No installation commands** - check project's existing dependencies first

---

## How to Use

1. **Find your pattern** in the table above
2. **Open the function file** (e.g., `error-handling.md`)
3. **Read YAML metadata** to see all framework options for your language
4. **Scroll to your language section**
5. **Choose framework variant** that matches your project
6. **Copy exact code pattern**

**Example workflow**:
- Need: Database query in PHP
- Open: `database-query.md`
- Check YAML: See options → Plain PDO, Doctrine, Laravel Eloquent
- Find: PHP section in file
- Copy: Laravel Eloquent pattern (if using Laravel)

---

## Framework Variants Available

Each function provides **multiple implementations** per language:

**Database Queries**: Plain (native drivers), ORM frameworks, query builders
**Error Handling**: Native try-catch, Result types, Framework error boundaries
**Async Operations**: Native async/await, Reactive libraries, Concurrency tools
**Input Validation**: Manual validation, Schema validators, Framework validators
**HTTP Requests**: Native HTTP clients, Popular libraries, Framework HTTP clients

**Check YAML metadata in each file for complete framework list per language.**

---

## Adding Custom Functions

If your team maintains custom function patterns, keep them in a separate, update-safe location and ensure AIs check them before these core patterns.

---

**Last Updated**: 2026-01-16
**Total Functions**: 12
**Languages Covered**: 8
