# Android MVVM Structure

> **Scope**: Model-View-ViewModel pattern for Android  
> **Use When**: Standard Android apps, clear separation

## CRITICAL REQUIREMENTS

> **ALWAYS**: Separate data, domain, presentation layers
> **ALWAYS**: ViewModels for business logic
> **ALWAYS**: Repository pattern for data access
> **ALWAYS**: Use cases for complex logic
> **ALWAYS**: StateFlow or LiveData for reactive UI
> 
> **NEVER**: Put business logic in Views
> **NEVER**: Access data sources directly from ViewModels
> **NEVER**: Skip Repository pattern
> **NEVER**: Use ViewModels without lifecycle

## Structure

```
app/src/main/kotlin/com/app/
├── data/                # Data layer
│   ├── local/          # Room, SharedPreferences
│   ├── remote/         # Retrofit, API
│   └── repository/     # Implementations
├── domain/             # Business logic
│   ├── model/         # Domain models
│   ├── repository/    # Interfaces
│   └── usecase/       # Use cases
└── presentation/       # UI layer
    └── ui/home/
        ├── HomeFragment.kt
        ├── HomeViewModel.kt
        └── HomeState.kt
```

## Core Patterns

### ViewModel

```kotlin
class HomeViewModel(private val getUsersUseCase: GetUsersUseCase) : ViewModel() {
    private val _state = MutableStateFlow<UiState>(UiState.Loading)
    val state: StateFlow<UiState> = _state.asStateFlow()
    
    fun loadUsers() {
        viewModelScope.launch {
            _state.value = UiState.Loading
            getUsersUseCase().fold(
                onSuccess = { users -> _state.value = UiState.Success(users) },
                onFailure = { e -> _state.value = UiState.Error(e.message) }
            )
        }
    }
}
```

### Fragment/Activity

```kotlin
class HomeFragment : Fragment() {
    private var _binding: FragmentHomeBinding? = null
    private val binding get() = _binding!!
    private val viewModel: HomeViewModel by viewModels()
    
    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        lifecycleScope.launch {
            viewModel.state.collect { state ->
                when (state) {
                    is UiState.Loading -> showLoading()
                    is UiState.Success -> showData(state.data)
                    is UiState.Error -> showError(state.message)
                }
            }
        }
    }
}
```

### Repository

```kotlin
class UserRepositoryImpl(
    private val remoteDataSource: UserRemoteDataSource,
    private val localDataSource: UserLocalDataSource
) : UserRepository {
    
    override suspend fun getUsers(): Result<List<User>> = try {
        val users = remoteDataSource.fetchUsers()
        localDataSource.saveUsers(users)
        Result.success(users)
    } catch (e: Exception) {
        Result.failure(e)
    }
}
```

### Use Case

```kotlin
class GetUsersUseCase(private val repository: UserRepository) {
    suspend operator fun invoke(): Result<List<User>> {
        return repository.getUsers()
    }
}
```

## Common AI Mistakes

| Mistake | ❌ Wrong | ✅ Correct |
|---------|---------|-----------|
| **Logic in View** | Business rules | ViewModel |
| **Direct Data Access** | ViewModel → API | Repository |
| **No Repository** | Direct database | Repository pattern |
| **No Lifecycle** | GlobalScope | viewModelScope |

## AI Self-Check

- [ ] Data, domain, presentation layers?
- [ ] ViewModels for logic?
- [ ] Repository pattern?
- [ ] Use cases?
- [ ] StateFlow/LiveData?
- [ ] No logic in Views?
- [ ] No direct data access?
- [ ] Lifecycle awareness?

## Benefits

- ✅ Clear separation
- ✅ Testable
- ✅ Maintainable
- ✅ Scalable

## When to Use

- ✅ Standard Android apps
- ✅ Clear layers
- ✅ Team structure aligns
- ❌ Very simple apps
