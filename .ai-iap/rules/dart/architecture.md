# Dart Architecture

## Overview
Clean, maintainable Dart with null safety and immutability.

## Core Principles

### Null Safety
```dart
String? findUser(int id) {
  return users[id]; // May return null
}

String getUser(int id) {
  return users[id]!; // Throws if null
}

// Null-aware operators
final name = user?.name ?? 'Anonymous';
```

### Immutability
```dart
@immutable
class User {
  const User({required this.id, required this.name});
  
  final int id;
  final String name;
  
  User copyWith({int? id, String? name}) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }
}
```

### Dependency Injection
```dart
abstract class UserRepository {
  Future<User?> findById(int id);
  Future<void> save(User user);
}

class UserService {
  UserService(this._repository);
  
  final UserRepository _repository;
  
  Future<User> getUser(int id) async {
    final user = await _repository.findById(id);
    if (user == null) throw UserNotFoundException(id);
    return user;
  }
}
```

## Error Handling

```dart
class UserNotFoundException implements Exception {
  UserNotFoundException(this.id);
  final int id;
  
  @override
  String toString() => 'User $id not found';
}

try {
  final user = await service.getUser(id);
} on UserNotFoundException catch (e) {
  // Handle
}
```

## Best Practices

### Use Extension Methods
```dart
extension StringExtensions on String {
  String capitalize() => '${this[0].toUpperCase()}${substring(1)}';
}
```

### Enums
```dart
enum UserRole {
  admin,
  user,
  guest;
  
  bool get isAdmin => this == UserRole.admin;
}
```

### Sealed Classes (Dart 3.0+)
```dart
sealed class Result<T> {}
class Success<T> extends Result<T> {
  Success(this.data);
  final T data;
}
class Failure<T> extends Result<T> {
  Failure(this.error);
  final String error;
}
```
