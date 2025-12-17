# Dart & Flutter Code Style

> **Scope**: Apply these rules ONLY when working with `.dart` files. These extend the general code style guidelines.

## 1. Core Principles
- **Version**: Dart 3.0+ features. Sound Null Safety required.
- **Type Safety**: Avoid `dynamic` unless interacting with untyped JSON.
- **Immutability**: Use `final` by default. `const` for compile-time constants.

## 2. Structure
- **Files**: One public class per file.
- **Imports**: Group: dart → package → relative. Blank line between groups.
- **Member Order**:
  1. Constants / Statics
  2. Final Fields (Parameters)
  3. Constructor
  4. Lifecycle Methods (`initState`, `dispose`)
  5. `build()` method
  6. Private helper methods

## 3. Naming
- **Files**: `snake_case.dart`.
- **Classes/Enums**: `PascalCase`.
- **Variables/Methods**: `camelCase`.
- **Private**: Prefix with `_` (e.g., `_isLoading`).
- **Booleans**: Prefix `is`, `has`, `should`, `can`.
- **Interfaces**: NO `I` prefix. Use `UserRepository` (abstract) → `UserRepositoryImpl` (implementation).

## 4. Language Features
- **Const**: Use `const` for immutable widgets and values.
- **Null Handling**: Use `?`, `??`, `?.`. Avoid `!` unless guard clause immediately before.
- **Formatting**: ALWAYS use trailing commas for multi-line arguments.
- **Arrows**: `=>` for one-liners only. Block bodies `{}` for complex logic.

## 5. Best Practices
- **Async**: Use `async/await`. NEVER use raw `.then()` chains.
- **Error Handling**: Catch specific exceptions, not generic `Object` or `Exception`.
- **Widget Splitting**: Split widgets >50 lines. NEVER use helper methods like `_buildHeader()`.
- **Performance**: Prioritize `const` constructors to reduce rebuilds.
