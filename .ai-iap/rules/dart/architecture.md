# Dart & Flutter Architecture

> **Scope**: Apply these rules ONLY when working with `.dart` files. These extend the general architecture guidelines.

## 1. Core Principles
- **Separation of Concerns**: UI (Widgets) must be "dumb". Logic belongs in State Management layers (BLoC, Cubit, Providers).
- **Unidirectional Data Flow**: State flows down, Events/Callbacks flow up.

## 2. Project Structure
```
features/
└── auth/
    ├── presentation/   # Widgets, Pages, State Managers (Blocs)
    ├── domain/         # Entities, Repository Interfaces, Usecases
    └── data/           # Repository Implementations, Data Sources, DTOs
```
- **Feature-First**: Organize by feature, NOT by type.

## 3. Naming Conventions
- **State Management**: `UserBloc`, `AuthCubit`, `ThemeNotifier` (suffix with pattern).
- **Repositories**: `UserRepository` (Interface) → `UserRepositoryImpl` (Implementation).
- **DTOs**: Suffix with `Dto` or `Model` (e.g., `UserDto`).

## 4. Design Patterns
- **Repository Pattern**: Isolate data fetching from business logic.
- **Dependency Injection**: Use `GetIt` or `Provider/Riverpod`. NEVER instantiate services inside Widgets.

## 5. DTOs & Mapping
- NEVER expose data layer models to UI. Always map to domain entities.
- Use `freezed` or `json_serializable` for DTOs.

## 6. Anti-Patterns (MUST avoid)
- **God Build Methods**: `build()` method >50 lines = refactor into smaller widgets.
- **Logic in UI**: NEVER make HTTP/DB calls inside Widgets.
- **Prop Drilling**: >2 layers of passing props = use Provider/InheritedWidget.
