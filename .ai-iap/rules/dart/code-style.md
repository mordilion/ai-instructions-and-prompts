# Dart Code Style

## General Rules

- **Dart 3.0+**
- **Null safety** enabled
- **`dart format`** for formatting
- **`dart analyze`** for linting

## Naming Conventions

```dart
// PascalCase for classes, enums
class UserService {}
enum UserRole { admin, user }

// camelCase for variables, methods
final userName = 'John';
void getUser() {}

// lowerCamelCase for constants
const maxAttempts = 3;

// Prefix private with underscore
final _privateVar = 10;
```

## Type Annotations

```dart
// Explicit for public APIs
String getUser(int id) => users[id];

// Infer for locals
final count = 10;
var name = 'John';
```

## Functions

```dart
// Arrow syntax for single expressions
int double(int x) => x * 2;

// Block for complex logic
Future<User> getUser(int id) async {
  final user = await repository.findById(id);
  if (user == null) throw Exception();
  return user;
}
```

## Null Safety

```dart
// Nullable types
String? findName(int id) => users[id];

// Null-aware operators
final email = user?.profile?.email ?? 'default';

// Assertion operator (use sparingly)
final name = user!.name;
```

## Best Practices

```dart
// Use const constructors
const user = User(id: 1, name: 'John');

// Use records (Dart 3.0+)
(int, String) getUserInfo() => (1, 'John');

// Use pattern matching
switch (result) {
  case Success(data: var data):
    print(data);
  case Failure(error: var error):
    print(error);
}

// Cascade notation
final user = User()
  ..id = 1
  ..name = 'John';
```
