# BLoC Pattern (Business Logic Component)

> **Scope**: BLoC/Cubit state management in Flutter  
> **Applies to**: *.dart files using BLoC/Cubit  
> **Extends**: dart/architecture.md, dart/frameworks/flutter.md

## CRITICAL REQUIREMENTS

> **ALWAYS**: Use sealed classes for events and states (Dart 3+)
> **ALWAYS**: Emit states in event handlers (not direct UI updates)
> **ALWAYS**: Close BLoCs in dispose()
> **ALWAYS**: Use BlocProvider for dependency injection
> **ALWAYS**: Model finite states (Initial, Loading, Success, Failure)
> 
> **NEVER**: Put business logic in UI (use BLoC/Cubit)
> **NEVER**: Use mutable state classes
> **NEVER**: Instantiate BLoCs directly (use BlocProvider)
> **NEVER**: Missing error states
> **NEVER**: Multiple BLoCs for simple state (use Cubit)

## 1. BLoC Structure
```
lib/features/auth/
├── bloc/
│   ├── auth_bloc.dart      # BLoC class
│   ├── auth_event.dart     # Events
│   └── auth_state.dart     # States
├── data/
│   └── auth_repository.dart
└── presentation/
    └── login_page.dart
```

## 2. Events
- **Immutable**: Use `@immutable` or `sealed class`.
- **Descriptive Names**: `LoginRequested`, `LogoutRequested`, not `Login`, `Logout`.
- **Carry Data**: Events hold input data needed for the operation.

**Pattern**: `sealed class Event/State {}` + `final class Specific extends Event/State {}`

## 3. States
**Pattern**: Initial → Loading → Success(data) / Failure(error)

## 4. BLoC Implementation
**Pattern**: `Bloc<Event, State>` + constructor injection + `on<Event>(_handler)` + `emit(state)`

## 5. Cubit (Simplified)
**Use For**: Simple state without complex events (methods instead of events)

**Pattern**: `Cubit<State>` + methods call `emit(newState)`

## 6. UI Integration
| Widget | Purpose |
|--------|---------|
| **BlocProvider** | Dependency injection |
| **BlocBuilder** | Rebuild on state change |
| **BlocListener** | Side effects (navigation, snackbars) |
| **BlocConsumer** | Builder + Listener combined |

## 7. Testing
**Tools**: `bloc_test` package + mock repositories for unit tests

```dart
blocTest<AuthBloc, AuthState>(
  'emits [AuthLoading, AuthSuccess] when login succeeds',
  build: () => AuthBloc(mockAuthRepository),
  act: (bloc) => bloc.add(LoginRequested(email: 'test@test.com', password: '123')),
  expect: () => [AuthLoading(), isA<AuthSuccess>()],
);
```

## AI Self-Check

- [ ] Using sealed classes for events and states?
- [ ] States emitted in event handlers (not UI)?
- [ ] BLoCs closed in dispose()?
- [ ] BlocProvider for dependency injection?
- [ ] Finite states modeled (Initial, Loading, Success, Failure)?
- [ ] Error states included?
- [ ] Business logic in BLoC/Cubit (not UI)?
- [ ] Immutable state classes (copyWith pattern)?
- [ ] BlocBuilder for UI updates?
- [ ] BlocListener for side effects?
- [ ] Cubit for simple state, BLoC for complex?
- [ ] bloc_test for testing?

