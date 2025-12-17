# Architecture Guidelines (General)

> **Scope**: These are baseline rules for ALL languages. Language-specific rules take precedence.

## 1. Core Principles
- **Dependency Rule**: Inner layers (Domain) MUST NOT import from outer layers (DB, UI, Framework).
- **Separation**: Distinct layers: Presentation → Application → Domain → Infrastructure.
- **Loose Coupling**: Interact via interfaces, NEVER concrete implementations.

## 2. Structure
- **Feature-First**: Group business logic by feature (`User/`, `Order/`), NOT by type (`Controllers/`, `Models/`).
- **UI Components**: Frontend UI primitives (Button, Input) may be organized by type or atomic design.
- **Boundaries**: Explicit module boundaries. Zero circular dependencies.

## 3. Naming
- **Suffixes**: `*Repository`, `*Service`, `*Controller`, `*Handler`.
- **Contracts**: Interfaces live in Domain/Application layer.

## 4. Design Patterns
- **Strategy**: Use when >3 conditional branches for same operation.
- **Factory**: Use when object creation requires >3 dependencies or conditional logic.
- **Observer/Event**: Use for side-effects decoupled from main flow (email, logging, audit).

## 5. Error Handling
- **Domain Exceptions**: Create specific exception types for domain errors.
- **Fail Fast**: Validate at boundaries (API input, external data). Throw early.
- **No Silent Failures**: NEVER catch and ignore. Log or rethrow.

## 6. Anti-Patterns (MUST avoid)
- **God Class**: >5 injected dependencies = split the class.
- **Leaky Abstraction**: NEVER expose DB exceptions, SQL, or ORM objects to UI layer.
  - ❌ Bad: `catch (SqlException e) { return Error(e.Message); }`
  - ✅ Good: `catch (SqlException) { throw new DomainException("User not found"); }`

