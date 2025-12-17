# Riverpod State Management

> **Scope**: Apply these rules when using Riverpod for state management in Flutter.

## 1. Provider Types
| Provider | Use Case |
|----------|----------|
| `Provider` | Computed values, services |
| `StateProvider` | Simple mutable state |
| `StateNotifierProvider` | Complex state with methods |
| `FutureProvider` | Async data (one-time fetch) |
| `StreamProvider` | Real-time data streams |
| `NotifierProvider` | Modern alternative to StateNotifier (Riverpod 2.0+) |

## 2. Project Structure
```
lib/
├── providers/
│   ├── auth_provider.dart
│   └── user_provider.dart
├── models/
├── repositories/
└── features/
    └── auth/
        ├── auth_notifier.dart
        └── auth_state.dart
```

## 3. Provider Declaration
- **Top-level**: Declare providers as global final variables.
- **Naming**: Use descriptive names ending with `Provider`.
- **Code Generation**: Prefer `@riverpod` annotation (riverpod_generator).

```dart
// ✅ Good - With code generation
@riverpod
class Auth extends _$Auth {
  @override
  AuthState build() => const AuthState.initial();

  Future<void> login(String email, String password) async {
    state = const AuthState.loading();
    try {
      final user = await ref.read(authRepositoryProvider).login(email, password);
      state = AuthState.authenticated(user);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }
}

// ✅ Good - Without code generation
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authRepositoryProvider));
});
```

## 4. State Classes
- **Freezed**: Use freezed for immutable state classes.
- **Union Types**: Model different states as union types.

```dart
@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated(User user) = _Authenticated;
  const factory AuthState.error(String message) = _Error;
}
```

## 5. Reading Providers
- **ref.watch**: In build methods (rebuilds on change).
- **ref.read**: For one-time reads (in callbacks, methods).
- **ref.listen**: For side effects.

```dart
// ✅ Good
class LoginPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);  // Rebuilds on change

    return authState.when(
      initial: () => LoginForm(
        onSubmit: (email, password) {
          ref.read(authProvider.notifier).login(email, password);  // One-time read
        },
      ),
      loading: () => const CircularProgressIndicator(),
      authenticated: (user) => Text('Welcome, ${user.name}'),
      error: (message) => Text('Error: $message'),
    );
  }
}
```

## 6. Provider Dependencies
- **ref.watch in Provider**: For derived state.
- **Auto-dispose**: Use `.autoDispose` for cleanup.

```dart
@riverpod
Future<List<Post>> userPosts(UserPostsRef ref) async {
  final user = ref.watch(authProvider).maybeWhen(
    authenticated: (user) => user,
    orElse: () => null,
  );
  if (user == null) return [];
  return ref.read(postRepositoryProvider).getPostsByUser(user.id);
}
```

## 7. Family Providers
- Use `.family` for parameterized providers.

```dart
@riverpod
Future<User> user(UserRef ref, String userId) async {
  return ref.read(userRepositoryProvider).getUser(userId);
}

// Usage
final user = ref.watch(userProvider('user-123'));
```

## 8. Best Practices
- **ProviderScope**: Wrap app at root.
- **ConsumerWidget/ConsumerStatefulWidget**: For widgets that need providers.
- **Avoid**: Watching providers in initState, creating providers in build.

