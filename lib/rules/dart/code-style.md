# Dart Code Style

> **Scope**: Dart formatting and maintainability  
> **Applies to**: *.dart files  
> **Extends**: General code style, dart/architecture.md

## CRITICAL REQUIREMENTS

> **ALWAYS**: Enable null safety (SDK >=3.0)
> **ALWAYS**: Use `dart format` for formatting
> **ALWAYS**: Use `dart analyze` for linting
> **ALWAYS**: Prefer final over var for immutability
> **ALWAYS**: Use const constructors where possible
> 
> **NEVER**: Use ! (null assertion) without justification
> **NEVER**: Use var when final is sufficient
> **NEVER**: Skip type annotations for public APIs
> **NEVER**: Use dynamic unless necessary
> **NEVER**: Mutable collections without reason

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

## AI Self-Check

- [ ] Null safety enabled?
- [ ] `dart format` used for formatting?
- [ ] `dart analyze` passing?
- [ ] Preferring final over var?
- [ ] const constructors where possible?
- [ ] PascalCase for classes/enums?
- [ ] camelCase for variables/methods?
- [ ] No ! (null assertion) without justification?
- [ ] Type annotations for public APIs?
- [ ] No dynamic unless necessary?
- [ ] Arrow functions for single expressions?
- [ ] Trailing commas for collections?
