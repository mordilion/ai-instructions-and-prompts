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

```dart
// ✅ Good - Sealed classes (Dart 3+)
sealed class AuthEvent {}

final class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  LoginRequested({required this.email, required this.password});
}

final class LogoutRequested extends AuthEvent {}
```

## 3. States
- **Finite States**: Define explicit states (Initial, Loading, Success, Failure).
- **Data in States**: Success states hold the result data.
- **Error Messages**: Failure states hold error information.

```dart
// ✅ Good
sealed class AuthState {}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class AuthSuccess extends AuthState {
  final User user;
  AuthSuccess(this.user);
}

final class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);
}
```

## 4. BLoC Implementation
- **Constructor Injection**: Inject repositories via constructor.
- **Event Handlers**: One handler per event type.
- **Emit States**: Always emit loading before async operations.

```dart
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.login(event.email, event.password);
      emit(AuthSuccess(user));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }
}
```

## 5. Cubit (Simplified BLoC)
- Use Cubit for simple state without complex events.
- Methods instead of events.

```dart
// ✅ Good - Cubit for simple cases
class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  void increment() => emit(state + 1);
  void decrement() => emit(state - 1);
}
```

## 6. UI Integration
- **BlocProvider**: Provide BLoC at the appropriate level.
- **BlocBuilder**: Rebuild UI based on state.
- **BlocListener**: Side effects (navigation, snackbars).
- **BlocConsumer**: When you need both.

```dart
// ✅ Good
BlocConsumer<AuthBloc, AuthState>(
  listener: (context, state) {
    if (state is AuthSuccess) {
      Navigator.pushReplacementNamed(context, '/home');
    } else if (state is AuthFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  },
  builder: (context, state) {
    if (state is AuthLoading) {
      return const CircularProgressIndicator();
    }
    return LoginForm();
  },
)
```

## 7. Testing
- **bloc_test**: Use for testing BLoCs.
- **Mock Repositories**: Inject mocks for unit tests.

```dart
blocTest<AuthBloc, AuthState>(
  'emits [AuthLoading, AuthSuccess] when login succeeds',
  build: () => AuthBloc(mockAuthRepository),
  act: (bloc) => bloc.add(LoginRequested(email: 'test@test.com', password: '123')),
  expect: () => [AuthLoading(), isA<AuthSuccess>()],
);
```

