# Android MVVM Structure

> **Scope**: Model-View-ViewModel pattern for Android apps
> **Use When**: Standard Android apps with clear separation of concerns

## CRITICAL REQUIREMENTS

> **ALWAYS**: Separate into data, domain, and presentation layers
> **ALWAYS**: ViewModels for business logic, Views for UI
> **ALWAYS**: Repository pattern for data access
> **ALWAYS**: Use cases for complex business logic
> **ALWAYS**: StateFlow or LiveData for reactive UI
> 
> **NEVER**: Put business logic in Views
> **NEVER**: Access data sources directly from ViewModels
> **NEVER**: Skip Repository pattern
> **NEVER**: Use ViewModels without lifecycle awareness

## Directory Structure

```
app/src/main/kotlin/com/app/
├── data/                # Data layer
│   ├── local/          # Room, SharedPreferences
│   │   ├── dao/
│   │   └── entity/
│   ├── remote/         # Retrofit, API
│   │   ├── api/
│   │   └── dto/
│   └── repository/     # Repository implementations
├── domain/             # Business logic
│   ├── model/         # Domain models
│   ├── repository/    # Repository interfaces
│   └── usecase/       # Use cases
├── presentation/       # UI layer
│   ├── ui/
│   │   ├── home/
│   │   │   ├── HomeFragment.kt
│   │   │   ├── HomeViewModel.kt
│   │   │   └── HomeState.kt
│   │   └── profile/
│   │       ├── ProfileFragment.kt
│   │       └── ProfileViewModel.kt
│   └── adapter/       # RecyclerView adapters
├── di/                # Dependency injection (Hilt)
└── util/              # Utilities
```

## Core Patterns

### ViewModel

```kotlin
@HiltViewModel
class HomeViewModel @Inject constructor(
    private val getUsersUseCase: GetUsersUseCase
) : ViewModel() {
    
    private val _state = MutableStateFlow<UiState<List<User>>>(UiState.Loading)
    val state: StateFlow<UiState<List<User>>> = _state.asStateFlow()
    
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
```

### Fragment (View)

```kotlin
@AndroidEntryPoint
class HomeFragment : Fragment(R.layout.fragment_home) {
    private var _binding: FragmentHomeBinding? = null
    private val binding get() = _binding!!
    private val viewModel: HomeViewModel by viewModels()
    
    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        _binding = FragmentHomeBinding.bind(view)
        
        viewLifecycleOwner.lifecycleScope.launch {
            viewModel.state.collect { renderState(it) }
        }
    }
    
    private fun renderState(state: UiState<List<User>>) {
        when (state) {
            is UiState.Loading -> showLoading()
            is UiState.Success -> showUsers(state.data)
            is UiState.Error -> showError(state.message)
        }
    }
    
    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
```

### Repository

```kotlin
class UserRepositoryImpl @Inject constructor(
    private val userApi: UserApi,
    private val userDao: UserDao
) : UserRepository {
    
    override suspend fun getUsers(): Result<List<User>> = try {
        val response = userApi.getUsers()
        val users = response.map { it.toDomain() }
        userDao.insertAll(users.map { it.toEntity() })
        Result.success(users)
    } catch (e: Exception) {
        val cached = userDao.getAll().map { it.toDomain() }
        if (cached.isNotEmpty()) Result.success(cached)
        else Result.failure(e)
    }
}
```

### Use Case

```kotlin
class GetUsersUseCase @Inject constructor(
    private val userRepository: UserRepository
) {
    suspend operator fun invoke(): Result<List<User>> {
        return userRepository.getUsers()
    }
}
```

## Common AI Mistakes (DO NOT MAKE THESE ERRORS)

| Mistake | ❌ Wrong | ✅ Correct | Why Critical |
|---------|---------|-----------|--------------|
| **Logic in View** | Business logic in Fragment | ViewModel | Separation of concerns |
| **Direct Data Access** | API call in ViewModel | Repository | Abstraction |
| **No Repository** | ViewModel → API directly | Repository pattern | Testability |
| **No UseCase** | Complex logic in ViewModel | Use Case | Single responsibility |

## AI Self-Check (Verify BEFORE generating MVVM code)

- [ ] Three-layer architecture (data/domain/presentation)?
- [ ] ViewModels for business logic?
- [ ] Repository pattern for data access?
- [ ] Use cases for complex operations?
- [ ] StateFlow/LiveData for state?
- [ ] Hilt for dependency injection?
- [ ] Fragment nullable binding pattern?
- [ ] lifecycleScope for coroutines?
- [ ] No business logic in Fragments?
- [ ] Domain models separate from DTOs/Entities?

## Benefits

- ✅ Clear separation of concerns
- ✅ Testable (mock repositories, use cases)
- ✅ Lifecycle-aware
- ✅ Reusable business logic
- ✅ Easy to maintain

## When to Use

- ✅ Standard Android apps
- ✅ Clear business logic
- ✅ Teams familiar with MVVM
- ✅ Long-term maintainability
- ❌ Very simple apps (use simpler patterns)
