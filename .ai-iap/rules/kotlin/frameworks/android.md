# Android Development with Kotlin

## Overview
Kotlin is the recommended language for Android development, offering null safety, concise syntax, and excellent tooling support.

## Core Components

### Activities
```kotlin
// ✅ Good - lifecycle-aware, use ViewBinding
class MainActivity : AppCompatActivity() {
    private lateinit var binding: ActivityMainBinding
    private val viewModel: MainViewModel by viewModels()
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)
        
        setupObservers()
        setupListeners()
    }
    
    private fun setupObservers() {
        viewModel.state.observe(this) { state ->
            when (state) {
                is UiState.Loading -> showLoading()
                is UiState.Success -> showData(state.data)
                is UiState.Error -> showError(state.message)
            }
        }
    }
    
    private fun setupListeners() {
        binding.button.setOnClickListener {
            viewModel.onButtonClicked()
        }
    }
}
```

### Fragments
```kotlin
// ✅ Good - use Fragment KTX, ViewBinding
class UserFragment : Fragment(R.layout.fragment_user) {
    private var _binding: FragmentUserBinding? = null
    private val binding get() = _binding!!
    
    private val viewModel: UserViewModel by viewModels()
    
    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        _binding = FragmentUserBinding.bind(view)
        
        setupUI()
        observeViewModel()
    }
    
    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null  // Prevent memory leaks
    }
    
    private fun setupUI() {
        binding.recyclerView.apply {
            layoutManager = LinearLayoutManager(context)
            adapter = UserAdapter()
        }
    }
}
```

### ViewModels
```kotlin
// ✅ Good - use StateFlow, handle loading states
class UserViewModel(
    private val repository: UserRepository
) : ViewModel() {
    
    private val _state = MutableStateFlow<UiState<User>>(UiState.Loading)
    val state: StateFlow<UiState<User>> = _state.asStateFlow()
    
    private val _events = MutableSharedFlow<UserEvent>()
    val events: SharedFlow<UserEvent> = _events.asSharedFlow()
    
    init {
        loadUser()
    }
    
    fun loadUser() {
        viewModelScope.launch {
            _state.value = UiState.Loading
            repository.getUser()
                .onSuccess { user ->
                    _state.value = UiState.Success(user)
                }
                .onFailure { error ->
                    _state.value = UiState.Error(error.message ?: "Unknown error")
                    _events.emit(UserEvent.ShowError)
                }
        }
    }
    
    fun onRetryClicked() {
        loadUser()
    }
}

// UI State
sealed class UiState<out T> {
    data object Loading : UiState<Nothing>()
    data class Success<T>(val data: T) : UiState<T>()
    data class Error(val message: String) : UiState<Nothing>()
}

// Events
sealed class UserEvent {
    data object ShowError : UserEvent()
    data object NavigateBack : UserEvent()
}
```

## Jetpack Compose

### Composables
```kotlin
// ✅ Good - composable functions, state hoisting
@Composable
fun UserScreen(
    viewModel: UserViewModel = viewModel()
) {
    val state by viewModel.state.collectAsStateWithLifecycle()
    
    UserScreenContent(
        state = state,
        onRetry = viewModel::onRetryClicked
    )
}

@Composable
private fun UserScreenContent(
    state: UiState<User>,
    onRetry: () -> Unit
) {
    when (state) {
        is UiState.Loading -> LoadingIndicator()
        is UiState.Success -> UserDetails(user = state.data)
        is UiState.Error -> ErrorView(
            message = state.message,
            onRetry = onRetry
        )
    }
}

@Composable
private fun UserDetails(user: User) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp)
    ) {
        Text(
            text = user.name,
            style = MaterialTheme.typography.headlineMedium
        )
        Spacer(modifier = Modifier.height(8.dp))
        Text(
            text = user.email,
            style = MaterialTheme.typography.bodyMedium
        )
    }
}
```

### State Management in Compose
```kotlin
// ✅ Good - remember state, side effects
@Composable
fun SearchScreen() {
    var query by remember { mutableStateOf("") }
    val results by viewModel.searchResults.collectAsStateWithLifecycle()
    
    // Side effect for analytics
    LaunchedEffect(query) {
        if (query.isNotEmpty()) {
            analyticsTracker.trackSearch(query)
        }
    }
    
    Column {
        SearchBar(
            query = query,
            onQueryChange = { query = it }
        )
        
        LazyColumn {
            items(results) { item ->
                SearchResultItem(item)
            }
        }
    }
}
```

## Room Database

### Entity
```kotlin
// ✅ Good - immutable entity, proper annotations
@Entity(tableName = "users")
data class UserEntity(
    @PrimaryKey val id: Long,
    @ColumnInfo(name = "name") val name: String,
    @ColumnInfo(name = "email") val email: String,
    @ColumnInfo(name = "created_at") val createdAt: Long
)
```

### DAO
```kotlin
// ✅ Good - suspend functions, Flow for observation
@Dao
interface UserDao {
    @Query("SELECT * FROM users WHERE id = :id")
    suspend fun getUserById(id: Long): UserEntity?
    
    @Query("SELECT * FROM users ORDER BY name ASC")
    fun observeUsers(): Flow<List<UserEntity>>
    
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertUser(user: UserEntity)
    
    @Update
    suspend fun updateUser(user: UserEntity)
    
    @Delete
    suspend fun deleteUser(user: UserEntity)
    
    @Query("DELETE FROM users WHERE id = :id")
    suspend fun deleteUserById(id: Long)
}
```

### Database
```kotlin
// ✅ Good - singleton pattern, migration
@Database(
    entities = [UserEntity::class],
    version = 1,
    exportSchema = true
)
abstract class AppDatabase : RoomDatabase() {
    abstract fun userDao(): UserDao
    
    companion object {
        @Volatile
        private var INSTANCE: AppDatabase? = null
        
        fun getInstance(context: Context): AppDatabase {
            return INSTANCE ?: synchronized(this) {
                INSTANCE ?: buildDatabase(context).also { INSTANCE = it }
            }
        }
        
        private fun buildDatabase(context: Context): AppDatabase {
            return Room.databaseBuilder(
                context.applicationContext,
                AppDatabase::class.java,
                "app_database"
            )
                .addMigrations(MIGRATION_1_2)
                .build()
        }
        
        private val MIGRATION_1_2 = object : Migration(1, 2) {
            override fun migrate(database: SupportSQLiteDatabase) {
                database.execSQL("ALTER TABLE users ADD COLUMN age INTEGER DEFAULT 0 NOT NULL")
            }
        }
    }
}
```

## Dependency Injection (Hilt)

### Application
```kotlin
// ✅ Good - Hilt application
@HiltAndroidApp
class MyApplication : Application()
```

### Module
```kotlin
// ✅ Good - provide dependencies
@Module
@InstallIn(SingletonComponent::class)
object DatabaseModule {
    
    @Provides
    @Singleton
    fun provideDatabase(
        @ApplicationContext context: Context
    ): AppDatabase = AppDatabase.getInstance(context)
    
    @Provides
    fun provideUserDao(database: AppDatabase): UserDao =
        database.userDao()
}

@Module
@InstallIn(SingletonComponent::class)
object NetworkModule {
    
    @Provides
    @Singleton
    fun provideRetrofit(): Retrofit {
        return Retrofit.Builder()
            .baseUrl("https://api.example.com")
            .addConverterFactory(GsonConverterFactory.create())
            .build()
    }
    
    @Provides
    @Singleton
    fun provideUserApi(retrofit: Retrofit): UserApi =
        retrofit.create(UserApi::class.java)
}
```

### ViewModel Injection
```kotlin
// ✅ Good - constructor injection
@HiltViewModel
class UserViewModel @Inject constructor(
    private val repository: UserRepository,
    private val analyticsTracker: AnalyticsTracker
) : ViewModel() {
    // ...
}
```

## Navigation

### Navigation Component
```kotlin
// ✅ Good - type-safe navigation with Kotlin DSL
@Composable
fun AppNavigation(navController: NavHostController) {
    NavHost(
        navController = navController,
        startDestination = "home"
    ) {
        composable("home") {
            HomeScreen(
                onNavigateToDetail = { userId ->
                    navController.navigate("detail/$userId")
                }
            )
        }
        
        composable(
            route = "detail/{userId}",
            arguments = listOf(
                navArgument("userId") { type = NavType.LongType }
            )
        ) { backStackEntry ->
            val userId = backStackEntry.arguments?.getLong("userId")
            DetailScreen(userId = userId)
        }
    }
}
```

## RecyclerView (View System)

### Adapter
```kotlin
// ✅ Good - ListAdapter with DiffUtil
class UserAdapter(
    private val onItemClick: (User) -> Unit
) : ListAdapter<User, UserAdapter.ViewHolder>(UserDiffCallback()) {
    
    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val binding = ItemUserBinding.inflate(
            LayoutInflater.from(parent.context),
            parent,
            false
        )
        return ViewHolder(binding, onItemClick)
    }
    
    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        holder.bind(getItem(position))
    }
    
    class ViewHolder(
        private val binding: ItemUserBinding,
        private val onItemClick: (User) -> Unit
    ) : RecyclerView.ViewHolder(binding.root) {
        
        fun bind(user: User) {
            binding.apply {
                textName.text = user.name
                textEmail.text = user.email
                root.setOnClickListener { onItemClick(user) }
            }
        }
    }
    
    private class UserDiffCallback : DiffUtil.ItemCallback<User>() {
        override fun areItemsTheSame(oldItem: User, newItem: User): Boolean =
            oldItem.id == newItem.id
        
        override fun areContentsTheSame(oldItem: User, newItem: User): Boolean =
            oldItem == newItem
    }
}
```

## WorkManager

### Worker
```kotlin
// ✅ Good - coroutine worker
class DataSyncWorker(
    context: Context,
    params: WorkerParameters,
    private val repository: DataRepository
) : CoroutineWorker(context, params) {
    
    override suspend fun doWork(): Result {
        return try {
            val data = inputData.getString(KEY_DATA_ID)
            requireNotNull(data) { "Data ID is required" }
            
            repository.syncData(data)
            
            Result.success()
        } catch (e: Exception) {
            if (runAttemptCount < MAX_RETRIES) {
                Result.retry()
            } else {
                Result.failure()
            }
        }
    }
    
    companion object {
        private const val KEY_DATA_ID = "data_id"
        private const val MAX_RETRIES = 3
    }
}

// Schedule work
fun scheduleDataSync(context: Context, dataId: String) {
    val inputData = workDataOf(KEY_DATA_ID to dataId)
    
    val request = OneTimeWorkRequestBuilder<DataSyncWorker>()
        .setInputData(inputData)
        .setConstraints(
            Constraints.Builder()
                .setRequiredNetworkType(NetworkType.CONNECTED)
                .build()
        )
        .build()
    
    WorkManager.getInstance(context).enqueue(request)
}
```

## Testing

### Unit Tests
```kotlin
// ✅ Good - coroutine test, mock dependencies
@ExperimentalCoroutinesApi
class UserViewModelTest {
    
    @get:Rule
    val instantExecutorRule = InstantTaskExecutorRule()
    
    @get:Rule
    val mainDispatcherRule = MainDispatcherRule()
    
    private lateinit var viewModel: UserViewModel
    private lateinit var repository: FakeUserRepository
    
    @Before
    fun setup() {
        repository = FakeUserRepository()
        viewModel = UserViewModel(repository)
    }
    
    @Test
    fun `when loadUser succeeds, state is Success`() = runTest {
        // Given
        val user = User(id = 1, name = "John", email = "john@example.com")
        repository.setUser(user)
        
        // When
        viewModel.loadUser()
        advanceUntilIdle()
        
        // Then
        val state = viewModel.state.value
        assertThat(state).isInstanceOf(UiState.Success::class.java)
        assertThat((state as UiState.Success).data).isEqualTo(user)
    }
    
    @Test
    fun `when loadUser fails, state is Error`() = runTest {
        // Given
        repository.setShouldFail(true)
        
        // When
        viewModel.loadUser()
        advanceUntilIdle()
        
        // Then
        assertThat(viewModel.state.value).isInstanceOf(UiState.Error::class.java)
    }
}
```

### UI Tests (Compose)
```kotlin
// ✅ Good - Compose UI tests
@RunWith(AndroidJUnit4::class)
class UserScreenTest {
    
    @get:Rule
    val composeTestRule = createComposeRule()
    
    @Test
    fun whenLoading_showsLoadingIndicator() {
        composeTestRule.setContent {
            UserScreenContent(
                state = UiState.Loading,
                onRetry = {}
            )
        }
        
        composeTestRule
            .onNodeWithContentDescription("Loading")
            .assertIsDisplayed()
    }
    
    @Test
    fun whenSuccess_showsUserDetails() {
        val user = User(id = 1, name = "John Doe", email = "john@example.com")
        
        composeTestRule.setContent {
            UserScreenContent(
                state = UiState.Success(user),
                onRetry = {}
            )
        }
        
        composeTestRule
            .onNodeWithText("John Doe")
            .assertIsDisplayed()
        
        composeTestRule
            .onNodeWithText("john@example.com")
            .assertIsDisplayed()
    }
    
    @Test
    fun whenError_clickingRetryCallsCallback() {
        var retryClicked = false
        
        composeTestRule.setContent {
            UserScreenContent(
                state = UiState.Error("Network error"),
                onRetry = { retryClicked = true }
            )
        }
        
        composeTestRule
            .onNodeWithText("Retry")
            .performClick()
        
        assertThat(retryClicked).isTrue()
    }
}
```

## Best Practices

### 1. Use Kotlin Extensions
```kotlin
// ✅ Good - Android KTX extensions
fun Fragment.showToast(message: String) {
    Toast.makeText(requireContext(), message, Toast.LENGTH_SHORT).show()
}

// Usage
showToast("User saved")
```

### 2. Lifecycle Awareness
```kotlin
// ✅ Good - use lifecycle-aware components
lifecycleScope.launch {
    viewModel.events.collect { event ->
        handleEvent(event)
    }
}

// ✅ Good - collect with lifecycle
viewLifecycleOwner.lifecycleScope.launch {
    viewModel.state.collectLatest { state ->
        updateUI(state)
    }
}
```

### 3. Resource Management
```kotlin
// ✅ Good - use resources safely
val color = ContextCompat.getColor(context, R.color.primary)
val drawable = ContextCompat.getDrawable(context, R.drawable.icon)
val string = getString(R.string.welcome_message)
```

### 4. Permissions
```kotlin
// ✅ Good - modern permission handling
val requestPermissionLauncher = registerForActivityResult(
    ActivityResultContracts.RequestPermission()
) { isGranted ->
    if (isGranted) {
        performAction()
    } else {
        showPermissionRationale()
    }
}

fun checkAndRequestPermission() {
    when {
        ContextCompat.checkSelfPermission(
            this,
            Manifest.permission.CAMERA
        ) == PackageManager.PERMISSION_GRANTED -> {
            performAction()
        }
        shouldShowRequestPermissionRationale(Manifest.permission.CAMERA) -> {
            showPermissionRationale()
        }
        else -> {
            requestPermissionLauncher.launch(Manifest.permission.CAMERA)
        }
    }
}
```

### 5. Memory Leaks Prevention
```kotlin
// ✅ Good - clean up in fragments
override fun onDestroyView() {
    super.onDestroyView()
    _binding = null  // Prevent memory leak
}

// ✅ Good - cancel jobs in ViewModels
override fun onCleared() {
    super.onCleared()
    // viewModelScope automatically cancels
}
```

