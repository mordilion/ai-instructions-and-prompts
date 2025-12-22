# Android MVVM Structure

## Overview
Model-View-ViewModel pattern separates UI logic from business logic, with ViewModel acting as a bridge.

## Directory Structure

```
app/src/main/
├── kotlin/com/app/
│   ├── data/                      # Data layer
│   │   ├── local/
│   │   │   ├── dao/              # Room DAOs
│   │   │   ├── entity/           # Room entities
│   │   │   └── database/         # Database class
│   │   ├── remote/
│   │   │   ├── api/              # Retrofit APIs
│   │   │   └── dto/              # Network DTOs
│   │   └── repository/           # Repository implementations
│   │       └── UserRepositoryImpl.kt
│   ├── domain/                   # Business logic
│   │   ├── model/               # Domain models
│   │   │   └── User.kt
│   │   ├── repository/          # Repository interfaces
│   │   │   └── UserRepository.kt
│   │   └── usecase/             # Use cases
│   │       ├── GetUserUseCase.kt
│   │       └── SaveUserUseCase.kt
│   ├── presentation/            # UI layer
│   │   ├── ui/
│   │   │   ├── home/
│   │   │   │   ├── HomeFragment.kt
│   │   │   │   ├── HomeViewModel.kt
│   │   │   │   └── HomeState.kt
│   │   │   ├── profile/
│   │   │   │   ├── ProfileFragment.kt
│   │   │   │   ├── ProfileViewModel.kt
│   │   │   │   └── ProfileState.kt
│   │   │   └── main/
│   │   │       └── MainActivity.kt
│   │   ├── adapter/            # RecyclerView adapters
│   │   │   └── UserAdapter.kt
│   │   └── common/             # Shared UI components
│   │       └── LoadingView.kt
│   ├── di/                     # Dependency injection
│   │   ├── AppModule.kt
│   │   ├── DatabaseModule.kt
│   │   └── NetworkModule.kt
│   └── util/                   # Utilities
│       ├── Resource.kt         # Sealed class for results
│       └── Extensions.kt
└── res/                        # Resources
    ├── layout/
    ├── values/
    └── navigation/
```

## Implementation

### ViewModel
```kotlin
// presentation/ui/home/HomeViewModel.kt
@HiltViewModel
class HomeViewModel @Inject constructor(
    private val getUserUseCase: GetUserUseCase
) : ViewModel() {
    
    private val _state = MutableStateFlow<HomeState>(HomeState.Loading)
    val state: StateFlow<HomeState> = _state.asStateFlow()
    
    init {
        loadUsers()
    }
    
    fun loadUsers() {
        viewModelScope.launch {
            _state.value = HomeState.Loading
            getUserUseCase()
                .onSuccess { users ->
                    _state.value = HomeState.Success(users)
                }
                .onFailure { error ->
                    _state.value = HomeState.Error(error.message ?: "Unknown error")
                }
        }
    }
    
    fun onUserClicked(userId: Long) {
        viewModelScope.launch {
            // Navigate or perform action
        }
    }
}
```

### State
```kotlin
// presentation/ui/home/HomeState.kt
sealed class HomeState {
    data object Loading : HomeState()
    data class Success(val users: List<User>) : HomeState()
    data class Error(val message: String) : HomeState()
}
```

### Fragment
```kotlin
// presentation/ui/home/HomeFragment.kt
@AndroidEntryPoint
class HomeFragment : Fragment(R.layout.fragment_home) {
    
    private var _binding: FragmentHomeBinding? = null
    private val binding get() = _binding!!
    
    private val viewModel: HomeViewModel by viewModels()
    private val adapter = UserAdapter { userId ->
        viewModel.onUserClicked(userId)
    }
    
    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        _binding = FragmentHomeBinding.bind(view)
        
        setupRecyclerView()
        observeState()
    }
    
    private fun setupRecyclerView() {
        binding.recyclerView.apply {
            layoutManager = LinearLayoutManager(context)
            adapter = this@HomeFragment.adapter
        }
    }
    
    private fun observeState() {
        viewLifecycleOwner.lifecycleScope.launch {
            viewModel.state.collect { state ->
                when (state) {
                    is HomeState.Loading -> showLoading()
                    is HomeState.Success -> showUsers(state.users)
                    is HomeState.Error -> showError(state.message)
                }
            }
        }
    }
    
    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
```

### UseCase
```kotlin
// domain/usecase/GetUserUseCase.kt
class GetUserUseCase @Inject constructor(
    private val repository: UserRepository
) {
    suspend operator fun invoke(): Result<List<User>> =
        repository.getUsers()
}
```

### Repository
```kotlin
// domain/repository/UserRepository.kt
interface UserRepository {
    suspend fun getUsers(): Result<List<User>>
    suspend fun getUser(id: Long): Result<User>
    suspend fun saveUser(user: User): Result<User>
}

// data/repository/UserRepositoryImpl.kt
class UserRepositoryImpl @Inject constructor(
    private val api: UserApi,
    private val dao: UserDao
) : UserRepository {
    
    override suspend fun getUsers(): Result<List<User>> = withContext(Dispatchers.IO) {
        try {
            val users = api.getUsers().map { it.toDomain() }
            dao.insertAll(users.map { it.toEntity() })
            Result.success(users)
        } catch (e: Exception) {
            // Fallback to local data
            val cachedUsers = dao.getAll().map { it.toDomain() }
            if (cachedUsers.isNotEmpty()) {
                Result.success(cachedUsers)
            } else {
                Result.failure(e)
            }
        }
    }
}
```

## Benefits
- Clear separation of concerns
- Testable ViewModels
- Lifecycle-aware data
- Reactive UI updates

## When to Use
- Standard Android apps
- Apps with moderate complexity
- When following Google's recommended architecture

