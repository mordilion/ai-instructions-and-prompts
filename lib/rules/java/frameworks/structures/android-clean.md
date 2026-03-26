# Android Clean Architecture

> **Scope**: Clean Architecture structure for Android  
> **Applies to**: Android projects with Clean Architecture  
> **Extends**: java/frameworks/android.md

## CRITICAL REQUIREMENTS

> **ALWAYS**: Domain layer has no Android dependencies
> **ALWAYS**: UseCase classes for business operations
> **ALWAYS**: Repository interfaces in Domain
> **ALWAYS**: Repository implementations in Data
> **ALWAYS**: Dependency flow: Presentation → Domain ← Data
> 
> **NEVER**: Android imports in Domain layer
> **NEVER**: Presentation depends on Data directly
> **NEVER**: Domain depends on Data or Presentation
> **NEVER**: Skip UseCase pattern
> **NEVER**: Expose entities outside Domain

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

## AI Self-Check

- [ ] Domain layer has no Android dependencies?
- [ ] UseCase classes for business operations?
- [ ] Repository interfaces in Domain?
- [ ] Repository implementations in Data?
- [ ] Dependency flow: Presentation → Domain ← Data?
- [ ] No Android imports in Domain?
- [ ] No Presentation → Data direct dependency?
- [ ] No Domain → Presentation/Data dependency?
- [ ] UseCases encapsulate business logic?
- [ ] Entities in Domain layer?

