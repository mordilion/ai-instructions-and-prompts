# Flutter Clean Architecture

> **Scope**: Use this structure for Flutter apps with strict clean architecture.
> **Precedence**: When loaded, this structure overrides any default folder organization from the base Flutter rules.

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

