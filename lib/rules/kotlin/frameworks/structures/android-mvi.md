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

```kotlin
// Intent (User Actions)
sealed class HomeIntent {
    data object LoadUsers : HomeIntent()
    data class SelectUser(val userId: Long) : HomeIntent()
}

// State (UI State)
data class HomeState(
    val users: List<User> = emptyList(),
    val isLoading: Boolean = false,
    val error: String? = null
)

// Effect (One-Time Events)
sealed class HomeEffect {
    data class NavigateToDetail(val userId: Long) : HomeEffect()
}

// ViewModel
class HomeViewModel(private val useCase: GetUsersUseCase) : ViewModel() {
    private val _state = MutableStateFlow(HomeState())
    val state = _state.asStateFlow()
    
    private val _effect = MutableSharedFlow<HomeEffect>()
    val effect = _effect.asSharedFlow()
    
    fun processIntent(intent: HomeIntent) {
        when (intent) {
            is HomeIntent.LoadUsers -> viewModelScope.launch {
                _state.update { it.copy(isLoading = true) }
                useCase().fold(
                    { users -> _state.update { it.copy(users = users, isLoading = false) } },
                    { e -> _state.update { it.copy(error = e.message, isLoading = false) } }
                )
            }
            is HomeIntent.SelectUser -> viewModelScope.launch { _effect.emit(HomeEffect.NavigateToDetail(intent.userId)) }
        }
    }
}

// Screen
@Composable
fun HomeScreen(vm: HomeViewModel = hiltViewModel()) {
    val state by vm.state.collectAsState()
    LaunchedEffect(Unit) {
        vm.processIntent(HomeIntent.LoadUsers)
        vm.effect.collect { when (it) { is HomeEffect.NavigateToDetail -> navigate(it.userId) } }
    }
    when { state.isLoading -> LoadingView(); else -> UserList(state.users) }
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
