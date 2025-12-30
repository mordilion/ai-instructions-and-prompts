# Android MVI Structure

> **Scope**: Model-View-Intent pattern  
> **Use When**: Complex UI state, predictable state management

## CRITICAL REQUIREMENTS

> **ALWAYS**: Define Intent, State, Effect as sealed classes
> **ALWAYS**: Unidirectional flow (Intent → State → View)
> **ALWAYS**: Use StateFlow for state, SharedFlow for effects
> **ALWAYS**: Process intents through single function
> **ALWAYS**: Immutable state (data class with copy())
> 
> **NEVER**: Mutate state directly
> **NEVER**: Mix state and effects
> **NEVER**: Process intents outside ViewModel
> **NEVER**: Skip effect handling

## Structure

```
presentation/home/
├── HomeScreen.kt       # Composable
├── HomeViewModel.kt    # Intent processor
├── HomeIntent.kt       # User actions
├── HomeState.kt        # UI state
└── HomeEffect.kt       # Side effects
```

## Core Components

### Intent (User Actions)

```kotlin
sealed class HomeIntent {
    data object LoadUsers : HomeIntent()
    data class SelectUser(val userId: Long) : HomeIntent()
    data object RetryLoading : HomeIntent()
}
```

### State (UI State)

```kotlin
data class HomeState(
    val users: List<User> = emptyList(),
    val isLoading: Boolean = false,
    val error: String? = null,
    val selectedUserId: Long? = null
)
```

### Effect (One-Time Events)

```kotlin
sealed class HomeEffect {
    data class ShowToast(val message: String) : HomeEffect()
    data class NavigateToDetail(val userId: Long) : HomeEffect()
}
```

### ViewModel

```kotlin
class HomeViewModel(private val getUsersUseCase: GetUsersUseCase) : ViewModel() {
    private val _state = MutableStateFlow(HomeState())
    val state: StateFlow<HomeState> = _state.asStateFlow()
    
    private val _effect = MutableSharedFlow<HomeEffect>()
    val effect: SharedFlow<HomeEffect> = _effect.asSharedFlow()
    
    fun processIntent(intent: HomeIntent) {
        when (intent) {
            is HomeIntent.LoadUsers -> loadUsers()
            is HomeIntent.SelectUser -> selectUser(intent.userId)
            is HomeIntent.RetryLoading -> loadUsers()
        }
    }
    
    private fun loadUsers() {
        viewModelScope.launch {
            _state.update { it.copy(isLoading = true, error = null) }
            getUsersUseCase().fold(
                onSuccess = { users -> _state.update { it.copy(users = users, isLoading = false) } },
                onFailure = { e -> _state.update { it.copy(error = e.message, isLoading = false) } }
            )
        }
    }
    
    private fun selectUser(userId: Long) {
        _state.update { it.copy(selectedUserId = userId) }
        viewModelScope.launch {
            _effect.emit(HomeEffect.NavigateToDetail(userId))
        }
    }
}
```

### Screen (Composable)

```kotlin
@Composable
fun HomeScreen(viewModel: HomeViewModel = hiltViewModel()) {
    val state by viewModel.state.collectAsState()
    
    LaunchedEffect(Unit) {
        viewModel.processIntent(HomeIntent.LoadUsers)
        viewModel.effect.collect { effect ->
            when (effect) {
                is HomeEffect.ShowToast -> { /* Show toast */ }
                is HomeEffect.NavigateToDetail -> { /* Navigate */ }
            }
        }
    }
    
    when {
        state.isLoading -> LoadingView()
        state.error != null -> ErrorView(onRetry = { viewModel.processIntent(HomeIntent.RetryLoading) })
        else -> UserList(users = state.users, onClick = { viewModel.processIntent(HomeIntent.SelectUser(it)) })
    }
}
```

## Common AI Mistakes

| Mistake | ❌ Wrong | ✅ Correct |
|---------|---------|-----------|
| **Direct Mutation** | `_state.value.users.add()` | `_state.update { it.copy() }` |
| **Mixed Concerns** | Navigation in state | Effect for navigation |
| **Multiple Processors** | Many intent handlers | Single `processIntent()` |
| **Missing Effect Handling** | Ignore effects | Collect and handle |

## AI Self-Check

- [ ] Intent, State, Effect sealed classes?
- [ ] Unidirectional flow?
- [ ] StateFlow for state?
- [ ] SharedFlow for effects?
- [ ] Single processIntent()?
- [ ] Immutable state with copy()?
- [ ] No direct mutation?
- [ ] Effects collected in UI?

## Benefits

- ✅ Predictable state changes
- ✅ Time-travel debugging
- ✅ Easy testing
- ✅ Clear data flow

## When to Use

- ✅ Complex UI state
- ✅ Debugging important
- ✅ Team consistency
- ❌ Simple screens
