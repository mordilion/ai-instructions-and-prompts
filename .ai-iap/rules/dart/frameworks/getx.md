# GetX Framework

> **Scope**: State management, routing, and DI for Flutter with GetX
> **Applies to**: Dart files using GetX in Flutter
> **Extends**: dart/architecture.md, dart/code-style.md

## CRITICAL REQUIREMENTS (AI: Verify ALL before generating code)

> **ALWAYS**: Use GetxController (NOT StatefulWidget)
> **ALWAYS**: Use .obs for reactive variables
> **ALWAYS**: Use bindings for dependency injection
> **ALWAYS**: Use Get.find() to access controllers
> **ALWAYS**: Dispose in onClose()
> 
> **NEVER**: Instantiate controllers directly (use Get.put/Get.lazyPut)
> **NEVER**: Use StatefulWidget with GetX
> **NEVER**: Skip onClose() cleanup
> **NEVER**: Overuse Get.find() (use GetView)
> **NEVER**: Create global state unless needed

## Core Patterns

### Controller (GetxController)

```dart
class UserController extends GetxController {
  final UserRepository _repository;
  UserController(this._repository);
  
  final users = <User>[].obs;
  final isLoading = false.obs;
  final error = Rxn<String>();
  
  @override
  void onInit() {
    super.onInit();
    loadUsers();
  }
  
  Future<void> loadUsers() async {
    try {
      isLoading.value = true;
      error.value = null;
      users.value = await _repository.getUsers();
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
  
  @override
  void onClose() {
    // Clean up resources
    super.onClose();
  }
}
```

### View (GetView)

```dart
class UserView extends GetView<UserController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Users')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        
        if (controller.error.value != null) {
          return Center(child: Text('Error: ${controller.error.value}'));
        }
        
        return ListView.builder(
          itemCount: controller.users.length,
          itemBuilder: (context, index) {
            final user = controller.users[index];
            return ListTile(
              title: Text(user.name),
              subtitle: Text(user.email),
            );
          },
        );
      }),
    );
  }
}
```

### Bindings (Dependency Injection)

```dart
class UserBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserRepository>(() => UserRepositoryImpl());
    Get.lazyPut<UserController>(() => UserController(Get.find()));
  }
}
```

### Routes

```dart
class AppPages {
  static const HOME = '/home';
  static const USER_DETAILS = '/user/:id';
  
  static final routes = [
    GetPage(
      name: HOME,
      page: () => HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: USER_DETAILS,
      page: () => UserDetailsView(),
      binding: UserDetailsBinding(),
    ),
  ];
}

// Navigation
Get.toNamed(AppPages.USER_DETAILS, arguments: {'id': userId});
Get.back();
```

### App Setup

```dart
void main() {
  runApp(GetMaterialApp(
    title: 'My App',
    initialRoute: AppPages.HOME,
    getPages: AppPages.routes,
    initialBinding: InitialBinding(),
  ));
}
```

## Common AI Mistakes (DO NOT MAKE THESE ERRORS)

| Mistake | ❌ Wrong | ✅ Correct | Why Critical |
|---------|---------|-----------|--------------|
| **Direct Instantiation** | `UserController()` | `Get.put(UserController())` | Lifecycle management |
| **StatefulWidget** | `StatefulWidget` + GetX | `GetView<Controller>` | Redundant state |
| **No onClose** | Skip cleanup | Implement `onClose()` | Memory leak |
| **Manual Rebuild** | `setState()` | `.obs` + `Obx()` | GetX pattern |

### Anti-Pattern: Direct Controller Instantiation (LIFECYCLE DISASTER)

```dart
// ❌ WRONG: Direct instantiation
class UserView extends StatelessWidget {
  final controller = UserController();  // Wrong lifecycle!
}

// ✅ CORRECT: GetView + Binding
class UserView extends GetView<UserController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() => Text(controller.count.toString()));
  }
}
```

## AI Self-Check (Verify BEFORE generating GetX code)

- [ ] Using GetxController?
- [ ] .obs for reactive variables?
- [ ] Bindings for DI?
- [ ] GetView for widgets?
- [ ] Obx() for reactive UI?
- [ ] onClose() cleanup implemented?
- [ ] Get.toNamed() for navigation?
- [ ] Get.lazyPut() in bindings?
- [ ] GetMaterialApp as root?
- [ ] No StatefulWidget with GetX?

## Key Features

| Feature | Purpose | Keywords |
|---------|---------|----------|
| **GetxController** | State management | `.obs`, `update()` |
| **Obx()** | Reactive widgets | Auto-rebuild |
| **Bindings** | Dependency injection | `Get.put()`, `Get.lazyPut()` |
| **Get.toNamed()** | Navigation | Named routes |
| **GetView** | Controller access | No Get.find() calls |

## Best Practices

**MUST**:
- GetxController for state
- .obs for reactivity
- Bindings for DI
- Get.find() or GetView
- onClose() cleanup

**SHOULD**:
- GetView over StatelessWidget
- Get.toNamed() for navigation
- Feature-based modules
- GetMaterialApp root

**AVOID**:
- Direct controller instantiation
- StatefulWidget
- Missing onClose()
- Overusing Get.find()
- Global state
