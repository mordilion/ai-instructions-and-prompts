# Flutter Framework

> **Scope**: Apply these rules when working with Flutter projects (`.dart` files with Flutter imports).

## Overview

Flutter is Google's UI framework for building natively compiled applications from a single codebase for mobile, web, and desktop.

**Key Capabilities**:
- **Hot Reload**: Instant UI updates
- **Widget Composition**: Everything is a widget
- **Native Performance**: Compiled to native code
- **Rich Widgets**: Material and Cupertino designs
- **Cross-Platform**: iOS, Android, Web, Desktop

## Best Practices

**MUST**:
- Use const constructors (performance optimization)
- Use StatelessWidget when possible
- Dispose controllers in dispose()
- Use ListView.builder for long lists
- Use keys for stateful widgets in lists

**SHOULD**:
- Use BLoC/Riverpod for state management
- Use GoRouter for navigation
- Use dependency injection (GetIt/Riverpod)
- Extract widgets (keep build methods small)
- Use MediaQuery.of(context) sparingly

**AVOID**:
- setState in loops
- Direct Navigator.push (use named routes)
- Services instantiated in widgets
- Column with List.map (use ListView.builder)
- Missing const on stateless widgets

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

