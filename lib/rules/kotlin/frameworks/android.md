# Android Development with Kotlin

> **Scope**: Android apps using Kotlin  
> **Applies to**: Kotlin files in Android projects
> **Extends**: kotlin/architecture.md, kotlin/code-style.md

## CRITICAL REQUIREMENTS

> **ALWAYS**: Use ViewBinding (NOT findViewById)
> **ALWAYS**: Use `by viewModels()` delegation
> **ALWAYS**: Clean up Fragment bindings in onDestroyView
> **ALWAYS**: Use lifecycleScope for coroutines
> **ALWAYS**: Use StateFlow or LiveData for reactive UI
> 
> **NEVER**: Use lateinit for ViewBinding in Fragments
> **NEVER**: Use manual ViewModel creation
> **NEVER**: Use findViewById()
> **NEVER**: Use GlobalScope
> **NEVER**: Block main thread

## Core Patterns

### Activity

```kotlin
class MainActivity : AppCompatActivity() {
    private lateinit var binding: ActivityMainBinding
    private val viewModel: MainViewModel by viewModels()
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)
        
        viewModel.state.observe(this) { state ->
            when (state) {
                is UiState.Loading -> showLoading()
                is UiState.Success -> showData(state.data)
                is UiState.Error -> showError(state.message)
            }
        }
    }
}
```

### Fragment

```kotlin
class UserFragment : Fragment() {
    private var _binding: FragmentUserBinding? = null
    private val binding get() = _binding!!
    private val viewModel: UserViewModel by viewModels()
    
    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
        _binding = FragmentUserBinding.inflate(inflater, container, false)
        return binding.root
    }
    
    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        
        lifecycleScope.launch {
            viewModel.state.collect { state -> /* Update UI */ }
        }
    }
    
    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null  // Prevent leak
    }
}
```

### ViewModel

```kotlin
class UserViewModel : ViewModel() {
    private val _state = MutableStateFlow<UiState>(UiState.Loading)
    val state: StateFlow<UiState> = _state.asStateFlow()
    
    fun loadUsers() {
        viewModelScope.launch {
            _state.value = UiState.Loading
            try {
                val users = repository.getUsers()
                _state.value = UiState.Success(users)
            } catch (e: Exception) {
                _state.value = UiState.Error(e.message ?: "Unknown")
            }
        }
    }
}
```

### RecyclerView Adapter

```kotlin
class UserAdapter(private val onClick: (User) -> Unit) : ListAdapter<User, UserViewHolder>(DiffCallback) {
    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): UserViewHolder {
        val binding = ItemUserBinding.inflate(LayoutInflater.from(parent.context), parent, false)
        return UserViewHolder(binding)
    }
    
    override fun onBindViewHolder(holder: UserViewHolder, position: Int) {
        holder.bind(getItem(position), onClick)
    }
    
    object DiffCallback : DiffUtil.ItemCallback<User>() {
        override fun areItemsTheSame(old: User, new: User) = old.id == new.id
        override fun areContentsTheSame(old: User, new: User) = old == new
    }
}
```

## Common AI Mistakes

| Mistake | ❌ Wrong | ✅ Correct |
|---------|---------|-----------|
| **Fragment Binding** | `lateinit` | Nullable `var _binding` |
| **Manual ViewModel** | `ViewModelProvider()` | `by viewModels()` |
| **findViewById** | `findViewById<TextView>()` | ViewBinding |
| **GlobalScope** | `GlobalScope.launch` | `lifecycleScope` |

## AI Self-Check

- [ ] Using ViewBinding?
- [ ] by viewModels() delegation?
- [ ] Fragment binding cleanup?
- [ ] lifecycleScope for coroutines?
- [ ] StateFlow/LiveData?
- [ ] No lateinit in Fragments?
- [ ] No findViewById?
- [ ] No GlobalScope?
- [ ] Main thread not blocked?

## Key Features

| Feature | Purpose |
|---------|---------|
| ViewBinding | Type-safe views |
| ViewModel | Survives rotation |
| StateFlow/LiveData | Reactive UI |
| lifecycleScope | Auto-cancel |
| ListAdapter | Efficient lists |

## Best Practices

**MUST**: ViewBinding, by viewModels(), lifecycleScope, StateFlow/LiveData
**SHOULD**: ListAdapter, DiffUtil, coroutines, navigation component
**AVOID**: findViewById, manual ViewModel, GlobalScope, main thread blocking
