# Android Development with Kotlin

## Overview
Kotlin: Google's recommended language for Android development since 2019, offering null safety, concise syntax, and coroutines.
Interoperable with Java, but provides modern language features that prevent common Android bugs (null pointer exceptions).
Best for all new Android projects and when modernizing Java Android apps.

## Core Components

## Pattern Selection

### ViewBinding Patterns
**Activities: Use `lateinit`**
- ViewBinding initialized in onCreate, never null after
- No cleanup needed (Activity destroyed = binding destroyed)

**Fragments: Use nullable + cleanup**
- Fragment view can be destroyed while Fragment lives (memory leak risk)
- MUST set to null in onDestroyView

### State Management
**Use StateFlow when**:
- Building new apps (modern, Kotlin-first)
- Need coroutine support
- Want cold streams (no initial value needed)

**Use LiveData when**:
- Working with Java code
- Need lifecycle awareness out of the box
- Existing codebase uses LiveData

### Activities
```kotlin
// Activity: lateinit is safe (onCreate always runs before access)
class MainActivity : AppCompatActivity() {
    private lateinit var binding: ActivityMainBinding  // lateinit: initialized in onCreate
    private val viewModel: MainViewModel by viewModels()  // Lazy delegate: survives rotation
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)  // Must initialize before use
        setContentView(binding.root)
        setupObservers()
    }
    
    private fun setupObservers() {
        viewModel.state.observe(this) { state ->  // 'this' = LifecycleOwner (auto cleanup)
            when (state) {
                is UiState.Loading -> showLoading()
                is UiState.Success -> showData(state.data)
                is UiState.Error -> showError(state.message)
            }
        }
    }
}
```

### Fragments
```kotlin
// Fragment: MUST use nullable binding pattern (memory leak prevention)
class UserFragment : Fragment(R.layout.fragment_user) {
    private var _binding: FragmentUserBinding? = null  // Nullable: view destroyed before fragment
    private val binding get() = _binding!!  // Safe: only accessed between onCreateView-onDestroyView
    private val viewModel: UserViewModel by viewModels()
    
    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        _binding = FragmentUserBinding.bind(view)  // Create binding
        setupUI()
    }
    
    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null  // CRITICAL: Release view reference to prevent memory leak
        // Fragment instance may live, but view is destroyed (e.g., in ViewPager, back stack)
    }
}
```

### ViewModels
```kotlin
// ViewModel: Survives configuration changes (rotation, etc.)
class UserViewModel(private val repository: UserRepository) : ViewModel() {
    // Backing property pattern: private mutable, public immutable
    private val _state = MutableStateFlow<UiState<User>>(UiState.Loading)
    val state: StateFlow<UiState<User>> = _state.asStateFlow()  // Read-only for UI
    
    fun loadUser() {
        viewModelScope.launch {  // Cancelled when ViewModel cleared
            _state.value = UiState.Loading
            repository.getUser()
                .onSuccess { _state.value = UiState.Success(it) }
                .onFailure { _state.value = UiState.Error(it.message ?: "") }
        }
    }
}

// Sealed class: Type-safe state representation (exhaustive when expressions)
sealed class UiState<out T> {
    data object Loading : UiState<Nothing>()
    data class Success<T>(val data: T) : UiState<T>()
    data class Error(val message: String) : UiState<Nothing>()
}
```

## Jetpack Compose

### Composables
```kotlin
@Composable
fun UserScreen(viewModel: UserViewModel = viewModel()) {
    val state by viewModel.state.collectAsStateWithLifecycle()
    
    when (state) {
        is UiState.Loading -> LoadingIndicator()
        is UiState.Success -> UserDetails((state as UiState.Success).data)
        is UiState.Error -> ErrorView((state as UiState.Error).message)
    }
}

@Composable
private fun UserDetails(user: User) {
    Column(Modifier.padding(16.dp)) {
        Text(user.name, style = MaterialTheme.typography.headlineMedium)
        Text(user.email, style = MaterialTheme.typography.bodyMedium)
    }
}
```

### State Management
```kotlin
@Composable
fun SearchScreen() {
    var query by remember { mutableStateOf("") }
    val results by viewModel.results.collectAsStateWithLifecycle()
    
    LaunchedEffect(query) {
        if (query.isNotEmpty()) viewModel.search(query)
    }
    
    Column {
        SearchBar(query = query, onQueryChange = { query = it })
        LazyColumn {
            items(results) { SearchResultItem(it) }
        }
    }
}
```

## Room Database

### Entity & DAO
```kotlin
@Entity(tableName = "users")
data class UserEntity(
    @PrimaryKey val id: Long,
    @ColumnInfo(name = "name") val name: String,
    @ColumnInfo(name = "email") val email: String
)

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

### Database
```kotlin
@Database(entities = [UserEntity::class], version = 1)
abstract class AppDatabase : RoomDatabase() {
    abstract fun userDao(): UserDao
    
    companion object {
        @Volatile
        private var INSTANCE: AppDatabase? = null
        
        fun getInstance(context: Context): AppDatabase =
            INSTANCE ?: synchronized(this) {
                INSTANCE ?: Room.databaseBuilder(
                    context.applicationContext,
                    AppDatabase::class.java,
                    "app_database"
                ).build().also { INSTANCE = it }
            }
    }
}
```

## Dependency Injection (Hilt)

### Setup
```kotlin
@HiltAndroidApp
class MyApplication : Application()

@Module
@InstallIn(SingletonComponent::class)
object AppModule {
    @Provides
    @Singleton
    fun provideDatabase(@ApplicationContext context: Context) =
        AppDatabase.getInstance(context)
    
    @Provides
    fun provideUserDao(db: AppDatabase) = db.userDao()
}

@HiltViewModel
class UserViewModel @Inject constructor(
    private val repository: UserRepository
) : ViewModel()
```

## Navigation

### Navigation Component
```kotlin
@Composable
fun AppNavigation(navController: NavHostController) {
    NavHost(navController, startDestination = "home") {
        composable("home") {
            HomeScreen(onNavigateToDetail = { id ->
                navController.navigate("detail/$id")
            })
        }
        composable("detail/{userId}") { backStackEntry ->
            val userId = backStackEntry.arguments?.getLong("userId")
            DetailScreen(userId)
        }
    }
}
```

## RecyclerView

### Adapter with DiffUtil
```kotlin
class UserAdapter(
    private val onItemClick: (User) -> Unit
) : ListAdapter<User, UserAdapter.ViewHolder>(DiffCallback()) {
    
    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int) =
        ViewHolder(ItemUserBinding.inflate(LayoutInflater.from(parent.context), parent, false))
    
    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        holder.bind(getItem(position))
    }
    
    inner class ViewHolder(private val binding: ItemUserBinding) : 
        RecyclerView.ViewHolder(binding.root) {
        fun bind(user: User) {
            binding.textName.text = user.name
            binding.root.setOnClickListener { onItemClick(user) }
        }
    }
    
    class DiffCallback : DiffUtil.ItemCallback<User>() {
        override fun areItemsTheSame(old: User, new: User) = old.id == new.id
        override fun areContentsTheSame(old: User, new: User) = old == new
    }
}
```

## Testing

### Unit Tests
```kotlin
@ExperimentalCoroutinesApi
class UserViewModelTest {
    @get:Rule
    val mainDispatcherRule = MainDispatcherRule()
    
    private lateinit var repository: FakeUserRepository
    private lateinit var viewModel: UserViewModel
    
    @Before
    fun setup() {
        repository = FakeUserRepository()
        viewModel = UserViewModel(repository)
    }
    
    @Test
    fun `loadUser succeeds updates state`() = runTest {
        repository.setUser(User(1, "John", "john@test.com"))
        viewModel.loadUser()
        advanceUntilIdle()
        
        val state = viewModel.state.value
        assertThat(state).isInstanceOf(UiState.Success::class.java)
    }
}
```

### UI Tests (Compose)
```kotlin
class UserScreenTest {
    @get:Rule
    val composeTestRule = createComposeRule()
    
    @Test
    fun whenSuccess_showsUserDetails() {
        composeTestRule.setContent {
            UserScreenContent(state = UiState.Success(User(1, "John", "john@test.com")))
        }
        
        composeTestRule.onNodeWithText("John").assertIsDisplayed()
        composeTestRule.onNodeWithText("john@test.com").assertIsDisplayed()
    }
}
```

## Best Practices

**MUST**:
- Use ViewBinding (NOT findViewById or Kotlin synthetics)
- Use `by viewModels()` delegation (NOT manual ViewModelProvider)
- Clean up Fragment bindings in `onDestroyView` (memory leak prevention)
- Use `lifecycleScope` for coroutines in UI components (auto-cancellation)
- Use StateFlow or LiveData for reactive UI updates

**SHOULD**:
- Use Hilt for dependency injection
- Use Room for local database
- Use Jetpack Navigation for multi-screen apps
- Use sealed classes for state representation
- Use data classes for models

**AVOID**:
- `lateinit` in Fragments for ViewBinding (causes memory leaks)
- Manual ViewModel creation (use delegation)
- `findViewById()` (use ViewBinding)
- Leaked observers (use lifecycle-aware observation)
- Blocking operations on main thread

## Common Patterns

### Memory Leak Prevention
```kotlin
// ❌ BAD: Memory leak in Fragment
class UserFragment : Fragment() {
    private lateinit var binding: FragmentUserBinding  // WRONG for Fragments!
    // Problem: Fragment kept in memory when view destroyed (ViewPager, back stack)
}

// ✅ GOOD: Proper cleanup
class UserFragment : Fragment() {
    private var _binding: FragmentUserBinding? = null
    private val binding get() = _binding!!
    
    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null  // Release view reference
    }
}
```

### ViewModel Scope Selection
```kotlin
// ❌ WRONG: Activity-scoped ViewModel in Fragment (unless sharing data)
private val viewModel: MainViewModel by activityViewModels()  // Shares with Activity

// ✅ CORRECT: Fragment-scoped ViewModel
private val viewModel: UserViewModel by viewModels()  // Scoped to this Fragment

// ✅ CORRECT: Shared between Fragments
private val sharedViewModel: SharedViewModel by activityViewModels()  // Explicit sharing
```

### Lifecycle-Aware Coroutines
```kotlin
// ❌ BAD: Not lifecycle-aware
GlobalScope.launch {  // Never cancelled!
    val data = fetchData()
    updateUI(data)  // Crash if Activity destroyed
}

// ✅ GOOD: Lifecycle-aware
lifecycleScope.launch {  // Cancelled when lifecycle destroyed
    val data = fetchData()
    updateUI(data)  // Safe: cancelled if Activity destroyed
}

// ✅ GOOD: Collect flows safely
viewLifecycleOwner.lifecycleScope.launch {  // Use viewLifecycleOwner in Fragments
    viewModel.state.collect { state ->
        updateUI(state)
    }
}
```

### Kotlin Extensions (Use Sparingly)
```kotlin
// ✅ GOOD: Useful extension
fun Fragment.showToast(message: String) {
    Toast.makeText(requireContext(), message, Toast.LENGTH_SHORT).show()
}

// ❌ AVOID: Too generic (pollution)
fun Any.log() { println(this) }  // Adds to every class!
```
