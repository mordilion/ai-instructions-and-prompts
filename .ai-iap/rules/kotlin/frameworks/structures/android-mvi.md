# Android MVI Structure

## Overview
Model-View-Intent (MVI) is a unidirectional data flow pattern where user intents trigger state changes.

## Directory Structure

```
app/src/main/
├── kotlin/com/app/
│   ├── data/                     # Data layer (same as MVVM)
│   │   ├── repository/
│   │   ├── local/
│   │   └── remote/
│   ├── domain/                   # Business logic
│   │   ├── model/
│   │   └── usecase/
│   ├── presentation/             # UI layer
│   │   ├── home/
│   │   │   ├── HomeScreen.kt    # Composable
│   │   │   ├── HomeViewModel.kt
│   │   │   ├── HomeIntent.kt    # User intents
│   │   │   ├── HomeState.kt     # UI state
│   │   │   └── HomeEffect.kt    # Side effects
│   │   └── profile/
│   │       ├── ProfileScreen.kt
│   │       ├── ProfileViewModel.kt
│   │       ├── ProfileIntent.kt
│   │       ├── ProfileState.kt
│   │       └── ProfileEffect.kt
│   ├── di/
│   └── util/
└── res/
```

## Implementation

### Intent
```kotlin
// presentation/home/HomeIntent.kt
sealed class HomeIntent {
    data object LoadUsers : HomeIntent()
    data class SelectUser(val userId: Long) : HomeIntent()
    data object RetryLoading : HomeIntent()
    data class SearchUsers(val query: String) : HomeIntent()
}
```

### State
```kotlin
// presentation/home/HomeState.kt
data class HomeState(
    val isLoading: Boolean = false,
    val users: List<User> = emptyList(),
    val selectedUserId: Long? = null,
    val searchQuery: String = "",
    val error: String? = null
) {
    val filteredUsers: List<User>
        get() = if (searchQuery.isEmpty()) {
            users
        } else {
            users.filter { it.name.contains(searchQuery, ignoreCase = true) }
        }
}
```

### Effect
```kotlin
// presentation/home/HomeEffect.kt
sealed class HomeEffect {
    data class NavigateToDetail(val userId: Long) : HomeEffect()
    data class ShowToast(val message: String) : HomeEffect()
    data object NavigateBack : HomeEffect()
}
```

### ViewModel
```kotlin
// presentation/home/HomeViewModel.kt
@HiltViewModel
class HomeViewModel @Inject constructor(
    private val getUsersUseCase: GetUsersUseCase
) : ViewModel() {
    
    private val _state = MutableStateFlow(HomeState())
    val state: StateFlow<HomeState> = _state.asStateFlow()
    
    private val _effect = MutableSharedFlow<HomeEffect>()
    val effect: SharedFlow<HomeEffect> = _effect.asSharedFlow()
    
    init {
        processIntent(HomeIntent.LoadUsers)
    }
    
    fun processIntent(intent: HomeIntent) {
        when (intent) {
            is HomeIntent.LoadUsers -> loadUsers()
            is HomeIntent.SelectUser -> selectUser(intent.userId)
            is HomeIntent.RetryLoading -> loadUsers()
            is HomeIntent.SearchUsers -> searchUsers(intent.query)
        }
    }
    
    private fun loadUsers() {
        viewModelScope.launch {
            _state.update { it.copy(isLoading = true, error = null) }
            
            getUsersUseCase()
                .onSuccess { users ->
                    _state.update {
                        it.copy(
                            isLoading = false,
                            users = users,
                            error = null
                        )
                    }
                }
                .onFailure { error ->
                    _state.update {
                        it.copy(
                            isLoading = false,
                            error = error.message
                        )
                    }
                    _effect.emit(HomeEffect.ShowToast("Failed to load users"))
                }
        }
    }
    
    private fun selectUser(userId: Long) {
        viewModelScope.launch {
            _state.update { it.copy(selectedUserId = userId) }
            _effect.emit(HomeEffect.NavigateToDetail(userId))
        }
    }
    
    private fun searchUsers(query: String) {
        _state.update { it.copy(searchQuery = query) }
    }
}
```

### Composable Screen
```kotlin
// presentation/home/HomeScreen.kt
@Composable
fun HomeScreen(
    viewModel: HomeViewModel = hiltViewModel(),
    onNavigateToDetail: (Long) -> Unit
) {
    val state by viewModel.state.collectAsStateWithLifecycle()
    
    // Handle effects
    LaunchedEffect(Unit) {
        viewModel.effect.collect { effect ->
            when (effect) {
                is HomeEffect.NavigateToDetail -> onNavigateToDetail(effect.userId)
                is HomeEffect.ShowToast -> {
                    // Show toast
                }
                is HomeEffect.NavigateBack -> {
                    // Navigate back
                }
            }
        }
    }
    
    HomeContent(
        state = state,
        onIntent = viewModel::processIntent
    )
}

@Composable
private fun HomeContent(
    state: HomeState,
    onIntent: (HomeIntent) -> Unit
) {
    Column(modifier = Modifier.fillMaxSize()) {
        // Search bar
        SearchBar(
            query = state.searchQuery,
            onQueryChange = { query ->
                onIntent(HomeIntent.SearchUsers(query))
            }
        )
        
        when {
            state.isLoading -> LoadingIndicator()
            state.error != null -> ErrorView(
                message = state.error,
                onRetry = { onIntent(HomeIntent.RetryLoading) }
            )
            else -> UserList(
                users = state.filteredUsers,
                onUserClick = { userId ->
                    onIntent(HomeIntent.SelectUser(userId))
                }
            )
        }
    }
}

@Composable
private fun UserList(
    users: List<User>,
    onUserClick: (Long) -> Unit
) {
    LazyColumn {
        items(users) { user ->
            UserItem(
                user = user,
                onClick = { onUserClick(user.id) }
            )
        }
    }
}
```

### Fragment Version (View System)
```kotlin
// presentation/home/HomeFragment.kt
@AndroidEntryPoint
class HomeFragment : Fragment(R.layout.fragment_home) {
    
    private var _binding: FragmentHomeBinding? = null
    private val binding get() = _binding!!
    
    private val viewModel: HomeViewModel by viewModels()
    
    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        _binding = FragmentHomeBinding.bind(view)
        
        setupUI()
        observeState()
        observeEffects()
    }
    
    private fun setupUI() {
        binding.searchView.setOnQueryTextListener(object : SearchView.OnQueryTextListener {
            override fun onQueryTextSubmit(query: String?): Boolean = false
            
            override fun onQueryTextChange(newText: String?): Boolean {
                viewModel.processIntent(HomeIntent.SearchUsers(newText.orEmpty()))
                return true
            }
        })
    }
    
    private fun observeState() {
        viewLifecycleOwner.lifecycleScope.launch {
            viewModel.state.collect { state ->
                renderState(state)
            }
        }
    }
    
    private fun observeEffects() {
        viewLifecycleOwner.lifecycleScope.launch {
            viewModel.effect.collect { effect ->
                handleEffect(effect)
            }
        }
    }
    
    private fun renderState(state: HomeState) {
        binding.progressBar.isVisible = state.isLoading
        binding.errorView.isVisible = state.error != null
        binding.recyclerView.isVisible = !state.isLoading && state.error == null
        
        state.error?.let {
            binding.errorText.text = it
        }
        
        // Update adapter with filtered users
        adapter.submitList(state.filteredUsers)
    }
    
    private fun handleEffect(effect: HomeEffect) {
        when (effect) {
            is HomeEffect.NavigateToDetail -> {
                findNavController().navigate(
                    HomeFragmentDirections.actionHomeToDetail(effect.userId)
                )
            }
            is HomeEffect.ShowToast -> {
                Toast.makeText(context, effect.message, Toast.LENGTH_SHORT).show()
            }
            is HomeEffect.NavigateBack -> {
                findNavController().popBackStack()
            }
        }
    }
    
    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
```

## Testing

### ViewModel Test
```kotlin
class HomeViewModelTest {
    
    @get:Rule
    val mainDispatcherRule = MainDispatcherRule()
    
    private lateinit var getUsersUseCase: GetUsersUseCase
    private lateinit var viewModel: HomeViewModel
    
    @BeforeEach
    fun setup() {
        getUsersUseCase = mockk()
        viewModel = HomeViewModel(getUsersUseCase)
    }
    
    @Test
    fun `LoadUsers intent updates state to loading then success`() = runTest {
        // Given
        val users = listOf(User(1, "John", "john@example.com"))
        coEvery { getUsersUseCase() } returns Result.success(users)
        
        // When
        viewModel.processIntent(HomeIntent.LoadUsers)
        advanceUntilIdle()
        
        // Then
        val state = viewModel.state.value
        assertFalse(state.isLoading)
        assertEquals(users, state.users)
        assertNull(state.error)
    }
    
    @Test
    fun `SelectUser intent emits navigation effect`() = runTest {
        // Given
        val userId = 123L
        val effects = mutableListOf<HomeEffect>()
        val job = launch {
            viewModel.effect.collect { effects.add(it) }
        }
        
        // When
        viewModel.processIntent(HomeIntent.SelectUser(userId))
        advanceUntilIdle()
        
        // Then
        assertTrue(effects.any { it is HomeEffect.NavigateToDetail && it.userId == userId })
        
        job.cancel()
    }
}
```

## Benefits
- Unidirectional data flow
- Predictable state management
- Easy to test and debug
- Clear separation of concerns
- Time-travel debugging possible

## When to Use
- Complex UI state
- Apps requiring predictable state management
- When debugging state changes is important
- Teams familiar with Redux/Elm architecture

