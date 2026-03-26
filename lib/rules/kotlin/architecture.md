# Kotlin Architecture Guidelines

> **Scope**: Kotlin architectural patterns and principles  
> **Applies to**: *.kt files  
> **Extends**: General architecture rules

## CRITICAL REQUIREMENTS

> **ALWAYS**: Package by feature (not layer)
> **ALWAYS**: Use constructor injection for DI
> **ALWAYS**: Use sealed classes for finite states
> **ALWAYS**: Use coroutines for async (not callbacks)
> **ALWAYS**: Use Flow for reactive streams
> 
> **NEVER**: Use callbacks (use coroutines)
> **NEVER**: Use field injection
> **NEVER**: Expose mutable state
> **NEVER**: Use GlobalScope (use structured concurrency)
> **NEVER**: Block coroutine dispatcher

## Core Patterns

### 1. Package by Feature
- Organize by business domain/feature rather than layer
- Example: `com.app.user`, `com.app.order`, `com.app.payment`

### 2. Dependency Injection
- Constructor injection as primary DI mechanism
- Use Koin or Dagger/Hilt for Android

### 3. Repository Pattern
- Separate data access logic from business logic
- Use interfaces for repositories (testing)

### 4. Use Case / Interactor Pattern
- Encapsulate single business operations
- Keep use cases small and focused

### 5. Sealed Classes for State
- Represent finite states with sealed classes
- Enable exhaustive when expressions

### 6. Coroutines for Async
- Use coroutines instead of callbacks/RxJava
- Leverage structured concurrency
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

## AI Self-Check

- [ ] Package by feature (not layer)?
- [ ] Using constructor injection for DI?
- [ ] Sealed classes for finite states?
- [ ] Coroutines for async (not callbacks)?
- [ ] Flow for reactive streams?
- [ ] Repository pattern for data access?
- [ ] Use cases for business operations?
- [ ] Immutable data structures (val, data classes)?
- [ ] No GlobalScope (using structured concurrency)?
- [ ] No !! (non-null assertion)?
- [ ] No mutable global state?
- [ ] Null safety (?, ?:, let)?

