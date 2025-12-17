# .NET Code Style

> **Scope**: Apply these rules ONLY when working with `.cs`, `.csproj`, or `.razor` files. These extend the general code style guidelines.

## 1. Core Principles
- **Version**: C# 12+ / .NET 8+ features required.
- **Type Safety**: `#nullable enable` in all files. Strict null checking.
- **Immutability**: Use `readonly`, `init`, and `record` types.

## 2. Structure
- **Files**: One public class per file. File-scoped `namespace X;`.
- **Imports**: Group: System → Microsoft → Third-party → Project. Blank line between groups.
- **Member Order**:
  1. Constants / Static fields
  2. Private fields
  3. Constructor
  4. Public properties
  5. Public methods
  6. Private methods

## 3. Naming
- **Files**: `PascalCase.cs` (matches class name).
- **Classes/Methods**: `PascalCase`.
- **Variables/Parameters**: `camelCase`.
- **Private Fields**: `_camelCase` (e.g., `_logger`).
- **Interfaces**: Prefix `I` (e.g., `IUserService`).
- **Async Methods**: Suffix `Async` (e.g., `SaveAsync`).

## 4. Language Features
- **Pattern Matching**: Use `is`, `switch` expressions over `if/else` chains.
  - ✅ Good: `return value switch { > 0 => "pos", < 0 => "neg", _ => "zero" };`
- **LINQ**: Use for collections. New line per operation if >2.
- **Null Handling**: Use `?`, `??`, `?.`. NEVER use `!` without validation.
- **Records**: Use `record` for immutable DTOs.

## 5. Best Practices
- **Async**: ALL I/O methods return `Task<T>`. NEVER block with `.Result` or `.Wait()`.
- **Error Handling**: Throw typed exceptions. NEVER return error codes.
- **DI**: Constructor injection only. NEVER use `new` inside business logic.
- **Properties**: Auto-properties with `{ get; init; }` for immutable data.
