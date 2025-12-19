# Android MVVM Structure

> **Scope**: This structure extends the Android framework rules. When selected, use this folder organization instead of the default.

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

