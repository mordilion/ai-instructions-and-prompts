# Kotlin Architecture Guidelines

## Core Principles

### 1. Package by Feature
- Organize code by business domain/feature rather than technical layer
- Keep related functionality together for better cohesion
- Example: `com.app.user`, `com.app.order`, `com.app.payment`

### 2. Dependency Injection
- Use constructor injection as the primary DI mechanism
- Leverage frameworks like Koin or Dagger/Hilt for Android
- Keep dependencies explicit and testable

### 3. Repository Pattern
- Separate data access logic from business logic
- Use interfaces for repositories to enable easy testing
- Repositories handle data sources (network, database, cache)

### 4. Use Case / Interactor Pattern
- Encapsulate single business operations in dedicated classes
- Keep use cases small and focused (Single Responsibility)
- Use cases orchestrate between repositories and other services

### 5. Sealed Classes for State
- Use sealed classes/interfaces to represent finite states
- Enable exhaustive when expressions for compile-time safety
- Perfect for UI states, network results, navigation events

### 6. Coroutines for Async
- Use coroutines instead of callbacks or RxJava
- Leverage structured concurrency for lifecycle management
- Use Flow for reactive streams

## Architecture Patterns

### Clean Architecture (Recommended)
```
src/
├── domain/              # Business logic (pure Kotlin)
│   ├── model/          # Domain entities
│   ├── repository/     # Repository interfaces
│   └── usecase/        # Business use cases
├── data/               # Data layer
│   ├── repository/     # Repository implementations
│   ├── source/         # Data sources
│   └── mapper/         # Data <-> Domain mappers
└── presentation/       # UI layer
    ├── viewmodel/      # ViewModels (Android)
    └── ui/             # UI components
```

### MVVM (Android)
- Model-View-ViewModel separation
- ViewModel holds UI state and business logic
- Use StateFlow/SharedFlow for state management
- Lifecycle-aware components

## Anti-Patterns

### ❌ Avoid
- Mutable global state
- God classes with too many responsibilities
- Platform-specific code in domain layer
- Nullable types when not necessary
- var when val is sufficient
- !! (non-null assertion) - use safe calls or let instead

### ✅ Prefer
- Immutable data structures (val, data classes with val)
- Small, focused classes
- Interface-based dependencies
- Null safety (?, ?:, let, etc.)
- Extension functions for utility operations
- Sealed classes for exhaustive state handling

