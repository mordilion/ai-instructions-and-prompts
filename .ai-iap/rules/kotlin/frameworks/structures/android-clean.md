# Android Clean Architecture

## Overview
Clean Architecture enforces strict separation between layers with dependency inversion, making the codebase highly testable and maintainable.

## Directory Structure

```
app/src/main/
├── kotlin/com/app/
│   ├── core/                     # Shared core components
│   │   ├── di/                  # Dependency injection
│   │   ├── error/              # Error handling
│   │   ├── network/            # Network config
│   │   └── util/               # Utilities
│   ├── feature/                # Feature modules
│   │   ├── user/
│   │   │   ├── domain/         # Business logic (no Android deps)
│   │   │   │   ├── model/
│   │   │   │   │   └── User.kt
│   │   │   │   ├── repository/
│   │   │   │   │   └── UserRepository.kt  # Interface
│   │   │   │   └── usecase/
│   │   │   │       ├── GetUserUseCase.kt
│   │   │   │       ├── SaveUserUseCase.kt
│   │   │   │       └── DeleteUserUseCase.kt
│   │   │   ├── data/          # Data sources & implementations
│   │   │   │   ├── repository/
│   │   │   │   │   └── UserRepositoryImpl.kt
│   │   │   │   ├── source/
│   │   │   │   │   ├── local/
│   │   │   │   │   │   ├── UserDao.kt
│   │   │   │   │   │   └── UserEntity.kt
│   │   │   │   │   └── remote/
│   │   │   │   │       ├── UserApi.kt
│   │   │   │   │       └── UserDto.kt
│   │   │   │   └── mapper/
│   │   │   │       ├── UserEntityMapper.kt
│   │   │   │       └── UserDtoMapper.kt
│   │   │   ├── presentation/ # UI layer
│   │   │   │   ├── list/
│   │   │   │   │   ├── UserListScreen.kt
│   │   │   │   │   ├── UserListViewModel.kt
│   │   │   │   │   └── UserListState.kt
│   │   │   │   └── detail/
│   │   │   │       ├── UserDetailScreen.kt
│   │   │   │       ├── UserDetailViewModel.kt
│   │   │   │       └── UserDetailState.kt
│   │   │   └── di/
│   │   │       └── UserModule.kt
│   │   └── auth/
│   │       ├── domain/
│   │       ├── data/
│   │       ├── presentation/
│   │       └── di/
│   └── MyApplication.kt
└── res/
```

## Layer Dependencies

```
Presentation -> Domain <- Data
     ↓           ↓         ↓
   Android    Pure Kt   Android/Network
```

## Implementation

### Domain Layer (Pure Kotlin)

#### Model
```kotlin
// feature/user/domain/model/User.kt
data class User(
    val id: Long,
    val name: String,
    val email: String,
    val createdAt: Instant
)
```

#### Repository Interface
```kotlin
// feature/user/domain/repository/UserRepository.kt
interface UserRepository {
    suspend fun getUsers(): Result<List<User>>
    suspend fun getUser(id: Long): Result<User>
    suspend fun saveUser(user: User): Result<User>
    suspend fun deleteUser(id: Long): Result<Unit>
}
```

#### Use Case
```kotlin
// feature/user/domain/usecase/GetUserUseCase.kt
class GetUserUseCase(
    private val repository: UserRepository
) {
    suspend operator fun invoke(id: Long): Result<User> =
        repository.getUser(id)
}

// feature/user/domain/usecase/SaveUserUseCase.kt
class SaveUserUseCase(
    private val repository: UserRepository
) {
    suspend operator fun invoke(user: User): Result<User> {
        // Business validation
        require(user.name.isNotBlank()) { "Name cannot be blank" }
        require(user.email.contains("@")) { "Invalid email" }
        
        return repository.saveUser(user)
    }
}
```

### Data Layer

#### Local Data Source
```kotlin
// feature/user/data/source/local/UserEntity.kt
@Entity(tableName = "users")
data class UserEntity(
    @PrimaryKey val id: Long,
    @ColumnInfo(name = "name") val name: String,
    @ColumnInfo(name = "email") val email: String,
    @ColumnInfo(name = "created_at") val createdAt: Long
)

// feature/user/data/source/local/UserDao.kt
@Dao
interface UserDao {
    @Query("SELECT * FROM users")
    suspend fun getAll(): List<UserEntity>
    
    @Query("SELECT * FROM users WHERE id = :id")
    suspend fun getById(id: Long): UserEntity?
    
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(user: UserEntity)
    
    @Delete
    suspend fun delete(user: UserEntity)
}
```

#### Remote Data Source
```kotlin
// feature/user/data/source/remote/UserDto.kt
@Serializable
data class UserDto(
    val id: Long,
    val name: String,
    val email: String,
    @SerialName("created_at") val createdAt: String
)

// feature/user/data/source/remote/UserApi.kt
interface UserApi {
    @GET("users")
    suspend fun getUsers(): List<UserDto>
    
    @GET("users/{id}")
    suspend fun getUser(@Path("id") id: Long): UserDto
    
    @POST("users")
    suspend fun createUser(@Body user: UserDto): UserDto
}
```

#### Mappers
```kotlin
// feature/user/data/mapper/UserEntityMapper.kt
class UserEntityMapper {
    
    fun toDomain(entity: UserEntity): User = User(
        id = entity.id,
        name = entity.name,
        email = entity.email,
        createdAt = Instant.ofEpochMilli(entity.createdAt)
    )
    
    fun fromDomain(user: User): UserEntity = UserEntity(
        id = user.id,
        name = user.name,
        email = user.email,
        createdAt = user.createdAt.toEpochMilli()
    )
}

// feature/user/data/mapper/UserDtoMapper.kt
class UserDtoMapper {
    
    fun toDomain(dto: UserDto): User = User(
        id = dto.id,
        name = dto.name,
        email = dto.email,
        createdAt = Instant.parse(dto.createdAt)
    )
    
    fun fromDomain(user: User): UserDto = UserDto(
        id = user.id,
        name = user.name,
        email = user.email,
        createdAt = user.createdAt.toString()
    )
}
```

#### Repository Implementation
```kotlin
// feature/user/data/repository/UserRepositoryImpl.kt
class UserRepositoryImpl(
    private val api: UserApi,
    private val dao: UserDao,
    private val entityMapper: UserEntityMapper,
    private val dtoMapper: UserDtoMapper
) : UserRepository {
    
    override suspend fun getUsers(): Result<List<User>> = withContext(Dispatchers.IO) {
        try {
            // Fetch from network
            val dtos = api.getUsers()
            val users = dtos.map { dtoMapper.toDomain(it) }
            
            // Cache locally
            val entities = users.map { entityMapper.fromDomain(it) }
            entities.forEach { dao.insert(it) }
            
            Result.success(users)
        } catch (e: Exception) {
            // Fallback to cache
            val cachedEntities = dao.getAll()
            if (cachedEntities.isNotEmpty()) {
                val users = cachedEntities.map { entityMapper.toDomain(it) }
                Result.success(users)
            } else {
                Result.failure(e)
            }
        }
    }
    
    override suspend fun getUser(id: Long): Result<User> = withContext(Dispatchers.IO) {
        try {
            val dto = api.getUser(id)
            val user = dtoMapper.toDomain(dto)
            
            // Cache
            dao.insert(entityMapper.fromDomain(user))
            
            Result.success(user)
        } catch (e: Exception) {
            // Fallback to cache
            val entity = dao.getById(id)
            if (entity != null) {
                Result.success(entityMapper.toDomain(entity))
            } else {
                Result.failure(e)
            }
        }
    }
    
    override suspend fun saveUser(user: User): Result<User> = withContext(Dispatchers.IO) {
        try {
            val dto = dtoMapper.fromDomain(user)
            val created = api.createUser(dto)
            val savedUser = dtoMapper.toDomain(created)
            
            // Cache
            dao.insert(entityMapper.fromDomain(savedUser))
            
            Result.success(savedUser)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
    
    override suspend fun deleteUser(id: Long): Result<Unit> = withContext(Dispatchers.IO) {
        try {
            val entity = dao.getById(id) ?: return@withContext Result.failure(
                IllegalStateException("User not found")
            )
            dao.delete(entity)
            Result.success(Unit)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
}
```

### Presentation Layer

#### ViewModel
```kotlin
// feature/user/presentation/list/UserListViewModel.kt
@HiltViewModel
class UserListViewModel @Inject constructor(
    private val getUsersUseCase: GetUsersUseCase,
    private val deleteUserUseCase: DeleteUserUseCase
) : ViewModel() {
    
    private val _state = MutableStateFlow<UserListState>(UserListState.Loading)
    val state: StateFlow<UserListState> = _state.asStateFlow()
    
    init {
        loadUsers()
    }
    
    fun loadUsers() {
        viewModelScope.launch {
            _state.value = UserListState.Loading
            getUsersUseCase()
                .onSuccess { users ->
                    _state.value = UserListState.Success(users)
                }
                .onFailure { error ->
                    _state.value = UserListState.Error(error.message ?: "Unknown error")
                }
        }
    }
    
    fun deleteUser(userId: Long) {
        viewModelScope.launch {
            deleteUserUseCase(userId)
                .onSuccess {
                    loadUsers()  // Refresh list
                }
                .onFailure { error ->
                    _state.value = UserListState.Error(error.message ?: "Delete failed")
                }
        }
    }
}

// feature/user/presentation/list/UserListState.kt
sealed class UserListState {
    data object Loading : UserListState()
    data class Success(val users: List<User>) : UserListState()
    data class Error(val message: String) : UserListState()
}
```

#### Composable
```kotlin
// feature/user/presentation/list/UserListScreen.kt
@Composable
fun UserListScreen(
    viewModel: UserListViewModel = hiltViewModel(),
    onUserClick: (Long) -> Unit
) {
    val state by viewModel.state.collectAsStateWithLifecycle()
    
    UserListContent(
        state = state,
        onUserClick = onUserClick,
        onRetry = viewModel::loadUsers,
        onDeleteUser = viewModel::deleteUser
    )
}

@Composable
private fun UserListContent(
    state: UserListState,
    onUserClick: (Long) -> Unit,
    onRetry: () -> Unit,
    onDeleteUser: (Long) -> Unit
) {
    when (state) {
        is UserListState.Loading -> {
            Box(
                modifier = Modifier.fillMaxSize(),
                contentAlignment = Alignment.Center
            ) {
                CircularProgressIndicator()
            }
        }
        is UserListState.Success -> {
            LazyColumn {
                items(state.users) { user ->
                    UserItem(
                        user = user,
                        onClick = { onUserClick(user.id) },
                        onDelete = { onDeleteUser(user.id) }
                    )
                }
            }
        }
        is UserListState.Error -> {
            ErrorView(
                message = state.message,
                onRetry = onRetry
            )
        }
    }
}
```

### Dependency Injection

```kotlin
// feature/user/di/UserModule.kt
@Module
@InstallIn(SingletonComponent::class)
object UserModule {
    
    @Provides
    @Singleton
    fun provideUserApi(retrofit: Retrofit): UserApi =
        retrofit.create(UserApi::class.java)
    
    @Provides
    @Singleton
    fun provideUserDao(database: AppDatabase): UserDao =
        database.userDao()
    
    @Provides
    @Singleton
    fun provideUserEntityMapper(): UserEntityMapper =
        UserEntityMapper()
    
    @Provides
    @Singleton
    fun provideUserDtoMapper(): UserDtoMapper =
        UserDtoMapper()
    
    @Provides
    @Singleton
    fun provideUserRepository(
        api: UserApi,
        dao: UserDao,
        entityMapper: UserEntityMapper,
        dtoMapper: UserDtoMapper
    ): UserRepository = UserRepositoryImpl(api, dao, entityMapper, dtoMapper)
    
    @Provides
    fun provideGetUsersUseCase(repository: UserRepository): GetUsersUseCase =
        GetUsersUseCase(repository)
    
    @Provides
    fun provideSaveUserUseCase(repository: UserRepository): SaveUserUseCase =
        SaveUserUseCase(repository)
    
    @Provides
    fun provideDeleteUserUseCase(repository: UserRepository): DeleteUserUseCase =
        DeleteUserUseCase(repository)
}
```

## Testing

### Domain Layer Tests (No Android Dependencies)
```kotlin
class GetUserUseCaseTest {
    
    private lateinit var repository: UserRepository
    private lateinit var useCase: GetUserUseCase
    
    @BeforeEach
    fun setup() {
        repository = mockk()
        useCase = GetUserUseCase(repository)
    }
    
    @Test
    fun `invoke returns user from repository`() = runTest {
        // Given
        val user = User(1, "John", "john@example.com", Instant.now())
        coEvery { repository.getUser(1) } returns Result.success(user)
        
        // When
        val result = useCase(1)
        
        // Then
        assertTrue(result.isSuccess)
        assertEquals(user, result.getOrNull())
    }
}
```

### Data Layer Tests
```kotlin
class UserRepositoryImplTest {
    
    private lateinit var api: UserApi
    private lateinit var dao: UserDao
    private lateinit var entityMapper: UserEntityMapper
    private lateinit var dtoMapper: UserDtoMapper
    private lateinit var repository: UserRepositoryImpl
    
    @BeforeEach
    fun setup() {
        api = mockk()
        dao = mockk()
        entityMapper = UserEntityMapper()
        dtoMapper = UserDtoMapper()
        repository = UserRepositoryImpl(api, dao, entityMapper, dtoMapper)
    }
    
    @Test
    fun `getUsers returns from network and caches`() = runTest {
        // Given
        val dto = UserDto(1, "John", "john@example.com", Instant.now().toString())
        coEvery { api.getUsers() } returns listOf(dto)
        coEvery { dao.insert(any()) } just Runs
        
        // When
        val result = repository.getUsers()
        
        // Then
        assertTrue(result.isSuccess)
        coVerify { dao.insert(any()) }
    }
}
```

## Benefits
- Strict separation of concerns
- Framework-independent business logic
- Highly testable (no Android in domain)
- Easy to replace implementations
- Scalable for large projects

## When to Use
- Large, complex applications
- Long-term projects
- When testability is crucial
- Multi-platform projects (domain is pure Kotlin)

