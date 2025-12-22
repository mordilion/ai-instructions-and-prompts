# Flutter Feature-First Structure

> Organize Flutter app by feature/domain with all related files co-located. Best for medium to large apps with clear feature boundaries.

## Directory Structure

```
lib/features/user/
├── models/user.dart
├── repositories/user_repository.dart
├── services/user_service.dart
├── widgets/
│   ├── user_list.dart
│   └── user_detail.dart
└── screens/
    ├── user_list_screen.dart
    └── user_detail_screen.dart
```

## Implementation

```dart
// models/user.dart
class User {
  final int id;
  final String name;
  
  User({required this.id, required this.name});
}

// repositories/user_repository.dart
abstract class UserRepository {
  Future<List<User>> getUsers();
}

// widgets/user_list.dart
class UserList extends StatelessWidget {
  final List<User> users;
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        return ListTile(title: Text(users[index].name));
      },
    );
  }
}
```

## When to Use
- Medium to large Flutter apps
- Feature-focused development
