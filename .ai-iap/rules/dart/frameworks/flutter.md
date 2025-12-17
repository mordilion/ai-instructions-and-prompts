# Flutter Framework

> **Scope**: Apply these rules when working with Flutter projects (`.dart` files with Flutter imports).

## 1. Widget Structure
- **Composition over Inheritance**: Build complex UIs by composing small widgets.
- **Const Constructors**: ALWAYS use `const` for stateless widgets to optimize rebuilds.
- **Keys**: Use `Key` for widgets in lists or when preserving state across rebuilds.

```dart
// ✅ Good
const UserAvatar(name: 'John');

// ❌ Bad
UserAvatar(name: 'John');  // Missing const
```

## 2. State Management
- **BLoC/Cubit**: For complex business logic with multiple events.
- **Riverpod**: For dependency injection + state management.
- **Provider**: For simpler state needs.
- **Local State**: Use `StatefulWidget` only for UI-local state (animations, form fields).

## 3. Navigation
- **GoRouter** or **AutoRoute**: For declarative routing.
- **Named Routes**: NEVER use `Navigator.push()` with MaterialPageRoute directly.
- **Deep Linking**: Structure routes for deep link support.

```dart
// ✅ Good
context.go('/users/${user.id}');

// ❌ Bad
Navigator.push(context, MaterialPageRoute(builder: (_) => UserPage()));
```

## 4. Dependency Injection
- **GetIt** or **Riverpod**: Register dependencies at app startup.
- **Never** instantiate services inside widgets.

```dart
// ✅ Good
final userRepo = getIt<UserRepository>();

// ❌ Bad
final userRepo = UserRepositoryImpl(ApiClient());  // Inside widget
```

## 5. Forms & Validation
- **Form + TextFormField**: Use Flutter's built-in form handling.
- **Validation**: Validate in the form, not in BLoC/Cubit.
- **Controllers**: Dispose controllers in `dispose()`.

## 6. Performance
- **const Widgets**: Use everywhere possible.
- **ListView.builder**: For long lists (never `Column` with `List.map`).
- **RepaintBoundary**: Isolate frequently updating widgets.
- **Avoid**: `setState` in loops, rebuilding entire trees.

