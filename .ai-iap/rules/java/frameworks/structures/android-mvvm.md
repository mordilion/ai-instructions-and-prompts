# Android MVVM Structure

> **Scope**: MVVM structure for Android  
> **Applies to**: Android projects with MVVM  
> **Extends**: java/frameworks/android.md

## CRITICAL REQUIREMENTS

> **ALWAYS**: ViewModel for UI logic
> **ALWAYS**: LiveData/StateFlow for observability
> **ALWAYS**: Repository pattern for data access
> **ALWAYS**: Room for local database
> **ALWAYS**: Hilt/Dagger for DI
> 
> **NEVER**: Business logic in Activities/Fragments
> **NEVER**: Direct database access from UI
> **NEVER**: ViewModels reference Activities/Fragments
> **NEVER**: Static state in ViewModels
> **NEVER**: Skip repository pattern

## Project Structure
```
app/src/main/java/com/company/myapp/
├── ui/
│   ├── users/
│   │   ├── UserActivity.java
│   │   ├── UserViewModel.java
│   │   ├── UserAdapter.java
│   │   └── UserFragment.java
│   ├── orders/
│   │   ├── OrderActivity.java
│   │   ├── OrderViewModel.java
│   │   └── OrderAdapter.java
│   └── common/
│       └── BaseActivity.java
├── data/
│   ├── repository/
│   │   ├── UserRepository.java
│   │   └── OrderRepository.java
│   ├── local/
│   │   ├── database/
│   │   │   ├── AppDatabase.java
│   │   │   └── dao/
│   │   │       ├── UserDao.java
│   │   │       └── OrderDao.java
│   │   └── entity/
│   │       ├── UserEntity.java
│   │       └── OrderEntity.java
│   ├── remote/
│   │   ├── ApiService.java
│   │   └── dto/
│   │       ├── UserDto.java
│   │       └── OrderDto.java
│   └── model/
│       ├── User.java
│       └── Order.java
├── di/
│   ├── AppModule.java
│   ├── DatabaseModule.java
│   └── NetworkModule.java
└── util/
    ├── Constants.java
    └── DateUtils.java
```

## Rules
- **Model-View-ViewModel**: Clear separation between UI and business logic
- **LiveData/StateFlow**: Reactive UI updates
- **Repository Pattern**: Single source of truth for data
- **ViewBinding**: No findViewById

## When to Use
- Standard Android apps
- Teams familiar with MVVM
- Reactive UI with LiveData/Flow
- Recommended for most Android projects

## AI Self-Check

- [ ] ViewModel for UI logic?
- [ ] LiveData/StateFlow for observability?
- [ ] Repository pattern for data access?
- [ ] Room for local database?
- [ ] Hilt/Dagger for DI?
- [ ] No business logic in Activities/Fragments?
- [ ] No direct database access from UI?
- [ ] ViewModels don't reference Activities/Fragments?
- [ ] No static state in ViewModels?
- [ ] Repository pattern not skipped?

