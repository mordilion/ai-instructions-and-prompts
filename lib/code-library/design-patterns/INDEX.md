# Design Patterns Index

> **Purpose**: Comprehensive library of software design patterns across all supported languages

---

## 🚨 FOR AI ASSISTANTS: READ THIS FIRST

**BEFORE** implementing **ANY** design pattern, **CHECK THIS INDEX**:

- ✅ **DO** check custom patterns first (if they exist):
  - `.ai-iap-custom/code-library/design-patterns/creational/` for company creational patterns
  - `.ai-iap-custom/code-library/design-patterns/structural/` for company structural patterns
  - `.ai-iap-custom/code-library/design-patterns/behavioral/` for company behavioral patterns
- ✅ **DO** then check `lib/code-library/design-patterns/` (this location) for core patterns
- ❌ **DON'T** implement design patterns (Singleton, Factory, Observer, etc.) from memory
- ❌ **DON'T** generate pattern implementations from scratch
- ❌ **DON'T** mix pattern concepts incorrectly

- ✅ **DO** check this INDEX before implementing any design pattern
- ✅ **DO** open the pattern file and read YAML metadata for framework options
- ✅ **DO** use exact code patterns from pattern files
- ✅ **DO** choose appropriate variant for your language/framework
- ✅ **DO** save 70-80% of tokens by using proven patterns

**This is MANDATORY to reduce token waste and ensure consistent, secure code.**

---

## Design Patterns by Category

### Creational Patterns

Patterns for object creation mechanisms:

| Pattern | Difficulty | When to Use | File |
|---------|------------|-------------|------|
| **Singleton** | Beginner | Database connections, configuration managers, loggers, cache managers | [creational/singleton.md](creational/singleton.md) |
| **Factory Method** | Beginner | Multiple payment providers, notification systems, document parsers, authentication strategies | [creational/factory-method.md](creational/factory-method.md) |
| **Abstract Factory** | Intermediate | Multi-cloud providers (AWS/Azure/GCP), cross-platform UI, database driver families, theme systems | [creational/abstract-factory.md](creational/abstract-factory.md) |
| **Builder** | Intermediate | Complex objects with many optional parameters, query builders, test data builders | [creational/builder.md](creational/builder.md) |

---

### Structural Patterns

Patterns for assembling objects and classes into larger structures:

| Pattern | Difficulty | When to Use | File |
|---------|------------|-------------|------|
| **Adapter** | Beginner | Third-party library integration, legacy system integration, API version compatibility | [structural/adapter.md](structural/adapter.md) |
| **Decorator** | Intermediate | Adding logging, authentication wrappers, caching layers, compression/encryption | [structural/decorator.md](structural/decorator.md) |
| **Facade** | Beginner | Simplifying complex APIs, unified interfaces for multiple systems, SDK wrappers | [structural/facade.md](structural/facade.md) |
| **Proxy** | Intermediate | Lazy initialization, access control, remote service calls, caching | [structural/proxy.md](structural/proxy.md) |
| **Composite** | Intermediate | UI component trees (React/Vue/Flutter), file systems, organization hierarchies | [structural/composite.md](structural/composite.md) |

---

### Behavioral Patterns

Patterns for algorithms and assignment of responsibilities between objects:

| Pattern | Difficulty | When to Use | File |
|---------|------------|-------------|------|
| **Observer** | Intermediate | Event handling, pub/sub messaging, model-view updates, real-time data updates | [behavioral/observer.md](behavioral/observer.md) |
| **Strategy** | Beginner | Multiple payment methods, sorting algorithms, validation strategies, pricing calculations | [behavioral/strategy.md](behavioral/strategy.md) |
| **Command** | Intermediate | Undo/redo functionality, transaction systems, task queues, macro recording | [behavioral/command.md](behavioral/command.md) |
| **Template Method** | Beginner | Testing frameworks (setup/teardown), data processing pipelines, game loops | [behavioral/template-method.md](behavioral/template-method.md) |
| **Chain of Responsibility** | Intermediate | HTTP middleware (Express/ASP.NET/Laravel), validation chains, authentication flows | [behavioral/chain-of-responsibility.md](behavioral/chain-of-responsibility.md) |
| **State** | Intermediate | Workflow engines, order processing states, document states, connection states | [behavioral/state.md](behavioral/state.md) |

---

## Language Coverage

All design patterns cover these 8 languages:

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

Each design pattern file contains:

### YAML Frontmatter (Metadata Header)
- **title**: Pattern name
- **category**: Pattern type (Creational/Structural/Behavioral)
- **difficulty**: beginner | intermediate | advanced
- **purpose**: What problem this pattern solves
- **when_to_use**: List of real-world use cases
- **languages**: All 8 languages with framework variants
  - Multiple implementations per language where applicable
  - Marks recommended approach for each language
  - Includes library names for quick lookup
- **common_patterns**: Key pattern concepts
- **best_practices**: DO/DON'T lists
- **related_functions**: Links to related patterns
- **tags**: Search keywords
- **updated**: Last modification date

### Code Examples (After Metadata)
- Complete, working implementations
- Organized by language, then by framework variant
- 20-100 lines per example (patterns are more complex than functions)
- Real-world, production-ready examples
- Multiple use case examples where applicable

---

## How to Use

1. **Identify your need** - What problem are you solving?
2. **Browse by category** - Creational, Structural, or Behavioral
3. **Select pattern** - Based on use case in the table
4. **Open pattern file** - Click the file link
5. **Read YAML metadata** - Understand the pattern and when to use it
6. **Find your language** - Scroll to your language section
7. **Copy implementation** - Use the exact code pattern

**Example workflow**:
- Need: State machine for order workflow
- Category: Behavioral patterns
- Pattern: State
- Open: `behavioral/state.md`
- Read: Use cases confirm this is right
- Find: TypeScript section
- Copy: State machine implementation

---

## Quick Pattern Selector

### Need to create objects?
- **Single instance only?** → Singleton
- **Factory for one product type?** → Factory Method
- **Factory for product families?** → Abstract Factory
- **Complex object with many options?** → Builder

### Need to adapt interfaces?
- **Incompatible interfaces?** → Adapter
- **Add behavior dynamically?** → Decorator
- **Simplify complex subsystem?** → Facade
- **Control access or lazy load?** → Proxy
- **Tree structures?** → Composite

### Need to manage behavior?
- **Notify multiple objects of changes?** → Observer
- **Swap algorithms at runtime?** → Strategy
- **Undo/redo operations?** → Command
- **Algorithm skeleton with variable steps?** → Template Method
- **Pass request through handlers?** → Chain of Responsibility
- **Behavior changes with state?** → State

---

## Implementation Patterns

Looking for smaller, tactical code snippets (error handling, async operations, etc.)?

**See**: [../functions/INDEX.md](../functions/INDEX.md)

---

## Adding Custom Patterns

If your team maintains custom design patterns:
1. **Start from the template**: [_TEMPLATE.md](_TEMPLATE.md)
2. Create `.ai-iap-custom/code-library/design-patterns/` structure
3. Mirror the folder organization (creational/structural/behavioral)
4. Follow the same YAML frontmatter structure
5. Include complete, working implementations (20-100 lines per example)
6. Add usage examples for each language
7. AIs will check custom patterns first

---

**Last Updated**: 2026-01-20
**Total Patterns**: 15 (4 Creational, 5 Structural, 6 Behavioral)
**Languages Covered**: 8
