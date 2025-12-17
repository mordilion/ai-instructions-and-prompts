# GetX Framework

> **Scope**: Apply these rules when using GetX for state management, routing, and DI in Flutter.

## 1. Project Structure
```
lib/
├── app/
│   ├── bindings/           # Dependency injection
│   ├── routes/             # Route definitions
│   └── translations/       # i18n
├── data/
│   ├── models/
│   ├── providers/          # API clients
│   └── repositories/
└── modules/
    └── auth/
        ├── bindings/auth_binding.dart
        ├── controllers/auth_controller.dart
        └── views/login_view.dart
```

## 2. Controllers
- **GetxController**: For reactive state management.
- **.obs**: Make variables observable.
- **onInit/onClose**: Lifecycle methods.

```dart
class AuthController extends GetxController {
  final AuthRepository _authRepository;
  AuthController(this._authRepository);

  // Observable state
  final Rx<User?> user = Rx<User?>(null);
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  // Getters
  bool get isLoggedIn => user.value != null;

  @override
  void onInit() {
    super.onInit();
    ever(user, _onUserChanged);  // React to user changes
  }

  void _onUserChanged(User? user) {
    if (user != null) {
      Get.offAllNamed('/home');
    }
  }

  Future<void> login(String email, String password) async {
    isLoading.value = true;
    error.value = '';
    try {
      user.value = await _authRepository.login(email, password);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
```

## 3. Bindings
- **Binding Classes**: Register dependencies per route.
- **Lazy Injection**: Use `Get.lazyPut` for lazy loading.

```dart
class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AuthRepository(Get.find()));
    Get.lazyPut(() => AuthController(Get.find()));
  }
}

// Global bindings
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ApiClient(), permanent: true);
    Get.put(StorageService(), permanent: true);
  }
}
```

## 4. Routing
- **GetPage**: Define routes with bindings.
- **Named Routes**: Always use named routes.
- **Middleware**: For auth guards.

```dart
class AppRoutes {
  static const home = '/home';
  static const login = '/login';

  static final routes = [
    GetPage(
      name: login,
      page: () => LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: home,
      page: () => HomeView(),
      binding: HomeBinding(),
      middlewares: [AuthMiddleware()],
    ),
  ];
}

// Middleware
class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authController = Get.find<AuthController>();
    return authController.isLoggedIn ? null : const RouteSettings(name: '/login');
  }
}
```

## 5. UI Integration
- **GetBuilder**: Manual updates (update()).
- **Obx**: Automatic reactive rebuilds.
- **GetX**: Named reactive widget.

```dart
// ✅ Good - Obx for reactive
class LoginView extends GetView<AuthController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return const CircularProgressIndicator();
        }
        return Column(
          children: [
            if (controller.error.value.isNotEmpty)
              Text(controller.error.value, style: TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: () => controller.login(email, password),
              child: const Text('Login'),
            ),
          ],
        );
      }),
    );
  }
}
```

## 6. Dialogs, Snackbars, Navigation
```dart
// Navigation
Get.toNamed('/home');
Get.offAllNamed('/login');
Get.back();

// Dialogs
Get.dialog(AlertDialog(title: Text('Confirm')));
Get.defaultDialog(title: 'Alert', middleText: 'Message');

// Snackbar
Get.snackbar('Title', 'Message');

// Bottom Sheet
Get.bottomSheet(Container());
```

## 7. Best Practices
- **GetView**: Extend for widgets with a single controller.
- **Avoid**: Global state pollution, too many `Get.put()` calls.
- **Prefer**: Bindings over manual `Get.put()`.
- **Testing**: Use `Get.testMode = true` in tests.

