# Android Clean Architecture

> **Scope**: This structure extends the Android framework rules. When selected, use this folder organization instead of the default.

## Project Structure
```
app/src/main/java/com/company/myapp/
├── domain/                         # Business logic (pure Java)
│   ├── model/
│   │   ├── User.java
│   │   └── Order.java
│   ├── repository/                 # Interfaces
│   │   ├── UserRepository.java
│   │   └── OrderRepository.java
│   └── usecase/
│       ├── GetUserUseCase.java
│       ├── CreateUserUseCase.java
│       └── UpdateUserUseCase.java
├── data/                           # Data layer
│   ├── repository/                 # Implementations
│   │   ├── UserRepositoryImpl.java
│   │   └── OrderRepositoryImpl.java
│   ├── local/
│   │   ├── database/
│   │   │   ├── AppDatabase.java
│   │   │   └── dao/
│   │   └── entity/
│   │       └── UserEntity.java
│   ├── remote/
│   │   ├── ApiService.java
│   │   └── dto/
│   │       └── UserDto.java
│   └── mapper/
│       └── UserMapper.java         # Entity ↔ Domain mapping
├── presentation/                   # UI layer
│   ├── users/
│   │   ├── UserActivity.java
│   │   ├── UserViewModel.java
│   │   └── UserAdapter.java
│   └── orders/
│       ├── OrderActivity.java
│       └── OrderViewModel.java
└── di/
    └── AppModule.java
```

## Layer Dependencies
```
Presentation → Domain ← Data
```

## Example: Use Case
```java
// domain/usecase/GetUserUseCase.java
public class GetUserUseCase {
    private final UserRepository repository;
    
    public GetUserUseCase(UserRepository repository) {
        this.repository = repository;
    }
    
    public User execute(long userId) {
        return repository.getUserById(userId);
    }
}

// ViewModel uses UseCase
public class UserViewModel extends ViewModel {
    private final GetUserUseCase getUserUseCase;
    private final MutableLiveData<User> user = new MutableLiveData<>();
    
    public void loadUser(long userId) {
        // Execute use case in background
        new Thread(() -> {
            User result = getUserUseCase.execute(userId);
            user.postValue(result);
        }).start();
    }
}
```

## Rules
- **Domain Independence**: Domain layer has NO Android dependencies
- **Dependency Rule**: Dependencies point toward domain
- **Use Cases**: All business logic in use cases
- **Interfaces in Domain**: Define repositories in domain, implement in data

## When to Use
- Large, complex Android apps
- Long-term projects
- Need for framework independence
- Teams experienced with Clean Architecture
- Potential for sharing domain logic across platforms

