# BLoC Pattern (Business Logic Component)

> **Scope**: Apply these rules when using BLoC/Cubit for state management in Flutter.

## Overview

BLoC (Business Logic Component) separates business logic from UI using streams and events. It follows reactive programming principles with clear separation of concerns.

**Key Capabilities**:
- **Event-Driven**: UI dispatches events, BLoC emits states
- **Testable**: Pure business logic easy to test
- **Predictable**: Finite states, clear transitions
- **Reactive**: Streams for async state changes

## Best Practices

**MUST**:
- Use sealed classes for events and states (Dart 3+)
- Emit states in event handlers (NO direct UI updates)
- Use Cubit for simple state (BLoC for complex)
- Close BLoCs in dispose()
- Use BlocProvider for dependency injection

**SHOULD**:
- Use descriptive event names (LoginRequested)
- Model finite states (Initial, Loading, Success, Failure)
- Use BlocBuilder for UI updates
- Use BlocListener for side effects (navigation, snackbars)
- Extract business logic to repositories

**AVOID**:
- Logic in UI (use BLoC/Cubit)
- Mutable state classes
- Multiple BLoCs for simple state
- Missing error states
- Direct BLoC instantiation (use BlocProvider)

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

