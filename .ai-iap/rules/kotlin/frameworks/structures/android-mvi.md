# Android MVI Structure

> **Scope**: Model-View-Intent pattern for Android apps with unidirectional data flow
> **Use When**: Complex UI state, predictable state management, debugging state changes important

## CRITICAL REQUIREMENTS

> **ALWAYS**: Define Intent, State, and Effect as sealed classes
> **ALWAYS**: Use unidirectional data flow (Intent → State → View)
> **ALWAYS**: Use StateFlow for state, SharedFlow for one-time effects
> **ALWAYS**: Process intents through single `processIntent()` function
> **ALWAYS**: Make state immutable (use `data class` with `copy()`)
> 
> **NEVER**: Mutate state directly (use `_state.update { it.copy(...) }`)
> **NEVER**: Mix state and effects (separate concerns)
> **NEVER**: Process intents outside ViewModel
> **NEVER**: Skip effect handling in UI layer

## Directory Structure

```
app/src/main/kotlin/com/app/
├── data/               # Repositories, data sources
├── domain/             # Use cases, models
└── presentation/       # UI layer
    ├── home/
    │   ├── HomeScreen.kt       # Composable
    │   ├── HomeViewModel.kt    # Intent processor
    │   ├── HomeIntent.kt       # User actions
    │   ├── HomeState.kt        # UI state
    │   └── HomeEffect.kt       # Side effects
    └── profile/
        ├── ProfileScreen.kt
        ├── ProfileViewModel.kt
        ├── ProfileIntent.kt
        ├── ProfileState.kt
        └── ProfileEffect.kt
```

## Core Components

### Intent (User Actions)

```kotlin
sealed class HomeIntent {
    data object LoadUsers : HomeIntent()
    data class SelectUser(val userId: Long) : HomeIntent()
    data object RetryLoading : HomeIntent()
    data class SearchUsers(val query: String) : HomeIntent()
}
```

### State (UI State)

```kotlin
data class HomeState(
    val isLoading: Boolean = false,
    val users: List<User> = emptyList(),
    val selectedUserId: Long? = null,
    val searchQuery: String = "",
    val error: String? = null
) {
    val filteredUsers: List<User>
        get() = if (searchQuery.isEmpty()) users
                else users.filter { it.name.contains(searchQuery, ignoreCase = true) }
}
```

### Effect (One-Time Events)

```kotlin
sealed class HomeEffect {
    data class NavigateToDetail(val userId: Long) : HomeEffect()
    data class ShowToast(val message: String) : HomeEffect()
    data object NavigateBack : HomeEffect()
}
```

### ViewModel (Intent Processor)

```kotlin
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
                    _state.update { it.copy(isLoading = false, users = users) }
                }
                .onFailure { error ->
                    _state.update { it.copy(isLoading = false, error = error.message) }
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
}
```

## View Layer

### Compose

```kotlin
@Composable
fun HomeScreen(
    viewModel: HomeViewModel = hiltViewModel(),
    onNavigateToDetail: (Long) -> Unit
) {
    val state by viewModel.state.collectAsStateWithLifecycle()
    
    LaunchedEffect(Unit) {
        viewModel.effect.collect { effect ->
            when (effect) {
                is HomeEffect.NavigateToDetail -> onNavigateToDetail(effect.userId)
                is HomeEffect.ShowToast -> { /* Show toast */ }
                is HomeEffect.NavigateBack -> { /* Navigate back */ }
            }
        }
    }
    
    HomeContent(state = state, onIntent = viewModel::processIntent)
}

@Composable
private fun HomeContent(state: HomeState, onIntent: (HomeIntent) -> Unit) {
    Column {
        SearchBar(
            query = state.searchQuery,
            onQueryChange = { onIntent(HomeIntent.SearchUsers(it)) }
        )
        
        when {
            state.isLoading -> LoadingIndicator()
            state.error != null -> ErrorView(
                message = state.error,
                onRetry = { onIntent(HomeIntent.RetryLoading) }
            )
            else -> UserList(
                users = state.filteredUsers,
                onUserClick = { onIntent(HomeIntent.SelectUser(it)) }
            )
        }
    }
}
```

### Fragment (View System)

```kotlin
@AndroidEntryPoint
class HomeFragment : Fragment(R.layout.fragment_home) {
    private var _binding: FragmentHomeBinding? = null
    private val binding get() = _binding!!
    private val viewModel: HomeViewModel by viewModels()
    
    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        _binding = FragmentHomeBinding.bind(view)
        
        observeState()
        observeEffects()
    }
    
    private fun observeState() {
        viewLifecycleOwner.lifecycleScope.launch {
            viewModel.state.collect { renderState(it) }
        }
    }
    
    private fun observeEffects() {
        viewLifecycleOwner.lifecycleScope.launch {
            viewModel.effect.collect { handleEffect(it) }
        }
    }
    
    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
```

## Common AI Mistakes (DO NOT MAKE THESE ERRORS)

| Mistake | ❌ Wrong | ✅ Correct | Why Critical |
|---------|---------|-----------|--------------|
| **Direct State Mutation** | `_state.value.users.add(user)` | `_state.update { it.copy(users = ...) }` | State must be immutable |
| **Mixed State/Effects** | `data class State(val toast: String?)` | Separate `Effect` | Effects are one-time events |
| **No Intent Processing** | Direct ViewModel methods | `processIntent(intent)` | Single entry point |
| **Mutable State Class** | `var users` | `val users` + `copy()` | Predictability |

## AI Self-Check (Verify BEFORE generating MVI code)

- [ ] Intent sealed class for all user actions?
- [ ] State data class (immutable)?
- [ ] Effect sealed class for one-time events?
- [ ] processIntent() as single entry point?
- [ ] StateFlow for state, SharedFlow for effects?
- [ ] Using state.update { it.copy(...) }?
- [ ] Effect handling in UI layer?
- [ ] No direct state mutation?
- [ ] ViewModelScope for coroutines?
- [ ] Following unidirectional data flow?

## Benefits

- ✅ Unidirectional data flow
- ✅ Predictable state management
- ✅ Easy to test and debug
- ✅ Time-travel debugging possible
- ✅ Clear separation of concerns

## When to Use

- ✅ Complex UI state
- ✅ Apps requiring predictable state management
- ✅ Debugging state changes important
- ✅ Teams familiar with Redux/Elm
- ❌ Simple UIs (use MVVM instead)
