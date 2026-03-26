# Flutter Clean Architecture

> **Scope**: Clean Architecture structure for Flutter  
> **Applies to**: Flutter projects with clean architecture  
> **Extends**: dart/frameworks/flutter.md

## CRITICAL REQUIREMENTS

> **ALWAYS**: Domain layer has no Flutter imports
> **ALWAYS**: Data layer implements Domain interfaces
> **ALWAYS**: Presentation layer uses BLoC/Riverpod
> **ALWAYS**: UseCase classes for business operations
> **ALWAYS**: Repository pattern for data access
> 
> **NEVER**: Flutter imports in Domain layer
> **NEVER**: Presentation depends on Data directly
> **NEVER**: Domain depends on Data or Presentation
> **NEVER**: Skip error handling (Failure classes)
> **NEVER**: Mix concerns across layers

## Project Structure
```
lib/
├── core/                       # Cross-cutting concerns
│   ├── error/
│   │   ├── failures.dart
│   │   └── exceptions.dart
│   ├── network/
│   │   └── network_info.dart
│   ├── usecases/
│   │   └── usecase.dart        # Base UseCase class
│   └── utils/
├── features/
│   └── auth/
│       ├── data/               # Data layer
│       │   ├── datasources/
│       │   │   ├── auth_remote_datasource.dart
│       │   │   └── auth_local_datasource.dart
│       │   ├── models/
│       │   │   └── user_model.dart
│       │   └── repositories/
│       │       └── auth_repository_impl.dart
│       ├── domain/             # Domain layer (no Flutter imports!)
│       │   ├── entities/
│       │   │   └── user.dart
│       │   ├── repositories/
│       │   │   └── auth_repository.dart  # Abstract
│       │   └── usecases/
│       │       ├── login.dart
│       │       └── logout.dart
│       └── presentation/       # Presentation layer
│           ├── bloc/
│           │   ├── auth_bloc.dart
│           │   ├── auth_event.dart
│           │   └── auth_state.dart
│           ├── pages/
│           └── widgets/
├── injection_container.dart    # Dependency injection
└── main.dart
```

## Dependency Rule
```
Presentation → Domain ← Data
```
- Domain has NO external dependencies (no Flutter, no packages)
- Data implements Domain interfaces
- Presentation only knows Domain

## UseCase Pattern
```dart
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class Login implements UseCase<User, LoginParams> {
  final AuthRepository repository;
  
  Future<Either<Failure, User>> call(LoginParams params) {
    return repository.login(params.email, params.password);
  }
}
```

## When to Use
- Large enterprise applications
- Long-lived projects
- Teams practicing DDD
- Need for high testability

## AI Self-Check

- [ ] Domain layer has no Flutter imports?
- [ ] Data layer implements Domain interfaces?
- [ ] Presentation uses BLoC/Riverpod?
- [ ] UseCase classes for business operations?
- [ ] Repository pattern for data access?
- [ ] Dependency flow: Presentation → Domain ← Data?
- [ ] Failure classes for error handling?
- [ ] No Flutter imports in Domain?
- [ ] No Presentation → Data direct dependency?
- [ ] Features organized by business domain?

