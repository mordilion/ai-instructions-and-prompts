# Code Library - Implementation Patterns & Design Patterns

> **Purpose**: Comprehensive library of reusable code patterns across all supported languages

---

## 🚨 FOR AI ASSISTANTS: READ THIS FIRST

**BEFORE** implementing **ANY** code patterns or design patterns, **CHECK THIS LIBRARY**:

- ✅ **DO** check custom patterns first (if they exist):
  - `.ai-iap-custom/code-library/functions/` for company implementation patterns
  - `.ai-iap-custom/code-library/design-patterns/` for company design patterns
- ✅ **DO** then check `.ai-iap/code-library/` (this location) for core patterns
- ❌ **DON'T** generate code from scratch without checking here first
- ❌ **DON'T** implement design patterns (Singleton, Factory, Observer, etc.) from memory
- ❌ **DON'T** guess implementations for error handling, async operations, validation, etc.

- ✅ **DO** use exact code patterns from the library files
- ✅ **DO** choose appropriate framework version for the project
- ✅ **DO** save 70-80% of tokens by using proven patterns

**This is MANDATORY to reduce token waste and ensure consistent, secure code.**

---

## Library Contents

### [Implementation Patterns](functions/INDEX.md) (17 patterns)

Tactical, small-scope code snippets for common programming tasks:

| Category | Patterns | When to Use |
|----------|----------|-------------|
| **Error Management** | Exception handling, custom errors | Handling failures, validation errors |
| **Async & I/O** | Async/await, promises, concurrent execution | API calls, database queries |
| **Data Safety** | Input validation, database queries, webhooks | User input, SQL injection prevention |
| **External Communication** | HTTP requests, rate limiting | API consumption, abuse protection |
| **Infrastructure** | Logging, caching, config/secrets | Observability, performance, configuration |
| **Business Logic** | Auth/authorization, money/decimals | Security, financial calculations |
| **File Management** | Upload, download, streaming, deletion | File handling, storage |
| **Data Presentation** | Pagination, search/filtering | Large datasets, API responses |
| **Async Processing** | Background jobs, email sending | Non-blocking operations, notifications |

**Browse**: [functions/INDEX.md](functions/INDEX.md)

---

### [Design Patterns](design-patterns/INDEX.md) (15 patterns)

Strategic, architectural patterns for object-oriented design:

| Category | Count | Examples |
|----------|-------|----------|
| **[Creational](design-patterns/INDEX.md#creational-patterns)** | 4 | Singleton, Factory Method, Abstract Factory, Builder |
| **[Structural](design-patterns/INDEX.md#structural-patterns)** | 5 | Adapter, Decorator, Facade, Proxy, Composite |
| **[Behavioral](design-patterns/INDEX.md#behavioral-patterns)** | 6 | Observer, Strategy, Command, Template Method, Chain of Responsibility, State |

**Browse**: [design-patterns/INDEX.md](design-patterns/INDEX.md)

---

## Language Coverage

All patterns cover these 8 languages:

- **TypeScript** / **JavaScript** (Node.js)
- **Python**
- **Java**
- **C# (.NET)**
- **PHP**
- **Kotlin**
- **Swift**
- **Dart** (Flutter)

---

## Pattern File Structure

Each pattern file contains:

### YAML Frontmatter (Metadata)
- **title**: Pattern name
- **category**: Classification
- **difficulty**: beginner | intermediate | advanced
- **purpose**: What this pattern solves
- **when_to_use**: List of use cases
- **languages**: All 8 languages with framework variants
  - Multiple implementations per language (Native, Framework A, Framework B, etc.)
  - Marks recommended approach for each language
  - Includes library names for quick lookup
- **common_patterns**: Quick reference
- **best_practices**: DO/DON'T lists
- **related_functions**: Links to related patterns
- **tags**: Search keywords
- **updated**: Last modification date

### Code Examples
- Pure code only, no explanations
- Organized by language, then by framework variant
- 5-50 lines per example (design patterns may be longer)
- Real-world, copy-paste ready

---

## Quick Start Guide

### For Implementation Patterns
1. Check [functions/INDEX.md](functions/INDEX.md)
2. Open relevant file (e.g., `error-handling.md`)
3. Read YAML metadata for framework options
4. Find your language section
5. Copy the appropriate framework variant

### For Design Patterns
1. Check [design-patterns/INDEX.md](design-patterns/INDEX.md)
2. Browse by category (Creational/Structural/Behavioral)
3. Open pattern file (e.g., `creational/singleton.md`)
4. Find your language section
5. Copy the implementation

---

## Adding Custom Patterns

If your team maintains custom patterns:
1. Create `.ai-iap-custom/code-library/` structure
2. Mirror the folder organization
3. Create custom INDEX.md files
4. AIs will check custom patterns first

---

**Last Updated**: 2026-01-20
**Total Implementation Patterns**: 17
**Total Design Patterns**: 15 (4 Creational, 5 Structural, 6 Behavioral)
**Languages Covered**: 8
