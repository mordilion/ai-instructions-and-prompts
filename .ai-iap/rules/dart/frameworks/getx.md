# GetX Framework

> **Scope**: State management, routing, and DI for Flutter  
> **Applies to**: Dart files using GetX in Flutter
> **Extends**: dart/architecture.md, dart/code-style.md

## CRITICAL REQUIREMENTS

> **ALWAYS**: Use GetxController (NOT StatefulWidget)
> **ALWAYS**: Use .obs for reactive variables
> **ALWAYS**: Use bindings for DI
> **ALWAYS**: Use Get.find() to access controllers
> **ALWAYS**: Dispose in onClose()
> 
> **NEVER**: Instantiate controllers directly
> **NEVER**: Use StatefulWidget with GetX
> **NEVER**: Skip onClose() cleanup
> **NEVER**: Overuse Get.find()
> **NEVER**: Create global state unless needed

## Core Patterns

```dart
// Controller
class UserController extends GetxController {
  final users = <User>[].obs;
  final isLoading = false.obs;
  
  @override
  void onInit() { super.onInit(); loadUsers(); }
  
  Future<void> loadUsers() async {
    isLoading.value = true;
    users.value = await _repository.getUsers();
    isLoading.value = false;
  }
}

// View (GetView preferred)
class UserListView extends GetView<UserController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() => controller.isLoading.value
      ? CircularProgressIndicator()
      : ListView.builder(itemCount: controller.users.length, itemBuilder: (_, i) => UserTile(controller.users[i])));
  }
}

// Bindings (DI)
class UserBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => UserController(Get.find()));
  }
}

// Navigation
Get.to(() => DetailView());  // Navigate
Get.toNamed('/details', arguments: userId);  // Named
Get.back();  // Back

// Dialogs
Get.snackbar('Success', 'User created');
Get.defaultDialog(title: 'Confirm', onConfirm: () => controller.delete());
```

## Common AI Mistakes

| Mistake | ❌ Wrong | ✅ Correct |
|---------|---------|-----------|
| **Direct Instantiation** | `UserController()` | `Get.find<UserController>()` |
| **StatefulWidget** | With GetX | Use GetxController |
| **No onClose** | Missing cleanup | Implement onClose() |
| **Overuse Get.find** | Everywhere | Use GetView |

## AI Self-Check

- [ ] Using GetxController?
- [ ] .obs for reactive vars?
- [ ] Bindings for DI?
- [ ] Get.find() for access?
- [ ] onClose() cleanup?
- [ ] No direct instantiation?
- [ ] No StatefulWidget?
- [ ] GetView where appropriate?

## Key Features

| Feature | Purpose |
|---------|---------|
| GetxController | State management |
| .obs | Reactive variables |
| Obx | UI rebuild |
| Bindings | DI |
| Get.to() | Navigation |

## Best Practices

**MUST**: GetxController, .obs, bindings, onClose(), Get.find()
**SHOULD**: GetView, lazy loading, named routes
**AVOID**: Direct instantiation, StatefulWidget, overuse Get.find(), global state
