# Riverpod State Management

> **Scope**: Apply these rules when using Riverpod for state management in Flutter.

## Overview

Riverpod is a reactive caching and data-binding framework for Flutter and Dart. It's a complete rewrite of Provider with improved safety, testability, and features.

**Key Capabilities**:
- **Compile-Safe**: No BuildContext required
- **Testable**: Easy to mock and test
- **Code Generation**: Type-safe providers (@riverpod)
- **Auto-Dispose**: Automatic cleanup
- **Dev Tools**: State inspection and time travel

## Best Practices

**MUST**:
- Use @riverpod code generation (NOT manual providers)
- Use ref.watch in build (NO ref.read)
- Use ref.read for event handlers/callbacks
- Use AsyncValue for async operations
- Wrap app with ProviderScope

**SHOULD**:
- Use Notifier/AsyncNotifier (Riverpod 2.0+)
- Use freezed for state classes
- Use family for parameterized providers
- Use autoDispose for temporary state
- Keep providers small and focused

**AVOID**:
- Provider hell (too many providers)
- ref.read in build methods
- Manual StateNotifier (use code generation)
- Mutable state
- Global state when not needed

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
**Pattern**: Top-level `final` + `@riverpod` annotation (code generation) or manual `StateNotifierProvider`

## 4. State Classes
**Pattern**: `@freezed` + union types for different states (initial/loading/success/error)

## 5. Reading Providers
| Method | When | Usage |
|--------|------|-------|
| **ref.watch** | Build methods | Rebuilds on change |
| **ref.read** | Callbacks/methods | One-time read |
| **ref.listen** | Side effects | Listen for changes |

**Pattern**: `ConsumerWidget` + `ref.watch(provider)` + `.when()` for pattern matching
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

