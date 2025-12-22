# Android Clean Architecture

## Overview
Clean Architecture with strict layer separation and dependency inversion for highly testable Android apps.

## Directory Structure

```
app/src/main/kotlin/com/app/
├── core/
│   ├── di/
│   ├── error/
│   └── network/
├── feature/
│   └── user/
│       ├── domain/
│       │   ├── model/User.kt
│       │   ├── repository/UserRepository.kt
│       │   └── usecase/
│       ├── data/
│       │   ├── repository/UserRepositoryImpl.kt
│       │   ├── source/local/
│       │   ├── source/remote/
│       │   └── mapper/
│       └── presentation/
│           ├── list/UserListScreen.kt
│           └── detail/UserDetailScreen.kt
```

## Implementation

### Domain Layer (Pure Kotlin)
```kotlin
data class User(val id: Long, val name: String, val email: String)

interface UserRepository {
    suspend fun getUsers(): Result<List<User>>
    suspend fun getUser(id: Long): Result<User>
}

class GetUserUseCase(private val repository: UserRepository) {
    suspend operator fun invoke(id: Long): Result<User> = repository.getUser(id)
}
```

### Data Layer
```kotlin
@Entity(tableName = "users")
data class UserEntity(
    @PrimaryKey val id: Long,
    val name: String,
    val email: String
)

@Dao
interface UserDao {
    @Query("SELECT * FROM users")
    suspend fun getAll(): List<UserEntity>
}

interface UserApi {
    @GET("users")
    suspend fun getUsers(): List<UserDto>
}

class UserRepositoryImpl(
    private val api: UserApi,
    private val dao: UserDao
) : UserRepository {
    override suspend fun getUsers(): Result<List<User>> = withContext(Dispatchers.IO) {
        try {
            val users = api.getUsers().map { it.toDomain() }
            dao.insertAll(users.map { it.toEntity() })
            Result.success(users)
        } catch (e: Exception) {
            val cached = dao.getAll().map { it.toDomain() }
            if (cached.isNotEmpty()) Result.success(cached) else Result.failure(e)
        }
    }
}
```

### Presentation Layer
```kotlin
@HiltViewModel
class UserListViewModel @Inject constructor(
    private val getUsersUseCase: GetUsersUseCase
) : ViewModel() {
    private val _state = MutableStateFlow<UiState<User>>(UiState.Loading)
    val state: StateFlow<UiState<User>> = _state.asStateFlow()
    
    init {
        loadUsers()
    }
    
    fun loadUsers() {
        viewModelScope.launch {
            _state.value = UiState.Loading
            getUsersUseCase()
                .onSuccess { _state.value = UiState.Success(it) }
                .onFailure { _state.value = UiState.Error(it.message ?: "") }
        }
    }
}

@Composable
fun UserListScreen(viewModel: UserListViewModel = hiltViewModel()) {
    val state by viewModel.state.collectAsStateWithLifecycle()
    
    when (state) {
        is UiState.Loading -> ProgressView()
        is UiState.Success -> UserList((state as UiState.Success).data)
        is UiState.Error -> ErrorView((state as UiState.Error).message)
    }
}
```

### Dependency Injection
```kotlin
@Module
@InstallIn(SingletonComponent::class)
object UserModule {
    @Provides
    @Singleton
    fun provideUserApi(retrofit: Retrofit): UserApi = retrofit.create()
    
    @Provides
    fun provideGetUsersUseCase(repo: UserRepository) = GetUsersUseCase(repo)
}
```

## Benefits
- Framework-independent business logic
- Highly testable (domain has no Android deps)
- Easy to replace implementations

## When to Use
- Large, complex applications
- Long-term projects
- Multi-platform projects
