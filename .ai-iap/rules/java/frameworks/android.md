# Android Framework

> **Scope**: Apply these rules when working with Android applications.

## 1. Activities & Fragments
- **Single Responsibility**: One screen = one Activity/Fragment.
- **ViewBinding**: Use View Binding, NOT `findViewById()`.
- **Lifecycle Awareness**: Handle lifecycle properly with `ViewModel` and `LiveData`.

```java
// ✅ Good - Activity with ViewBinding and ViewModel
public class UserActivity extends AppCompatActivity {
    private ActivityUserBinding binding;
    private UserViewModel viewModel;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = ActivityUserBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());
        
        viewModel = new ViewModelProvider(this).get(UserViewModel.class);
        
        observeViewModel();
        setupListeners();
    }
    
    private void observeViewModel() {
        viewModel.getUser().observe(this, user -> {
            binding.userName.setText(user.getName());
            binding.userEmail.setText(user.getEmail());
        });
    }
    
    @Override
    protected void onDestroy() {
        super.onDestroy();
        binding = null;
    }
}

// ❌ Bad - findViewById and business logic in Activity
public class UserActivity extends AppCompatActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_user);
        
        TextView name = findViewById(R.id.user_name);  // Bad: findViewById
        User user = database.getUser(1);  // Bad: Direct DB access
        name.setText(user.getName());
    }
}
```

## 2. ViewModel
- **UI Logic**: ViewModel holds UI state and business logic.
- **Lifecycle Independent**: ViewModel survives configuration changes.
- **No Android Framework**: ViewModel should NOT reference View/Activity/Fragment.

```java
public class UserViewModel extends ViewModel {
    private final UserRepository repository;
    private final MutableLiveData<User> user = new MutableLiveData<>();
    private final MutableLiveData<Boolean> loading = new MutableLiveData<>();
    
    public UserViewModel(final UserRepository repository) {
        this.repository = repository;
    }
    
    public LiveData<User> getUser() {
        return user;
    }
    
    public LiveData<Boolean> isLoading() {
        return loading;
    }
    
    public void loadUser(final long userId) {
        loading.setValue(true);
        repository.getUser(userId, new Callback<User>() {
            @Override
            public void onSuccess(User result) {
                user.setValue(result);
                loading.setValue(false);
            }
            
            @Override
            public void onError(Exception e) {
                loading.setValue(false);
                // Handle error
            }
        });
    }
}
```

## 3. Repository Pattern
- **Data Source Abstraction**: Repository abstracts data sources (API, Database, Cache).
- **Single Source of Truth**: Coordinate between remote and local data.

```java
public class UserRepository {
    private final UserApiService apiService;
    private final UserDao userDao;
    
    public UserRepository(UserApiService apiService, UserDao userDao) {
        this.apiService = apiService;
        this.userDao = userDao;
    }
    
    public LiveData<User> getUser(long userId) {
        // Return cached data immediately
        LiveData<User> cached = userDao.getUserById(userId);
        
        // Fetch fresh data in background
        apiService.getUser(userId).enqueue(new Callback<User>() {
            @Override
            public void onResponse(Call<User> call, Response<User> response) {
                if (response.isSuccessful() && response.body() != null) {
                    userDao.insert(response.body());  // Update cache
                }
            }
            
            @Override
            public void onFailure(Call<User> call, Throwable t) {
                // Handle error
            }
        });
        
        return cached;
    }
}
```

## 4. Room Database
- **Entities**: Define database tables.
- **DAO**: Data Access Objects for queries.
- **Database**: Database holder and main access point.

```java
// Entity
@Entity(tableName = "users")
public class User {
    @PrimaryKey
    @NonNull
    public long id;
    
    @ColumnInfo(name = "email")
    public String email;
    
    public String name;
}

// DAO
@Dao
public interface UserDao {
    @Query("SELECT * FROM users WHERE id = :userId")
    LiveData<User> getUserById(long userId);
    
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    void insert(User user);
    
    @Query("DELETE FROM users WHERE id = :userId")
    void deleteById(long userId);
}

// Database
@Database(entities = {User.class}, version = 1)
public abstract class AppDatabase extends RoomDatabase {
    public abstract UserDao userDao();
    
    private static volatile AppDatabase INSTANCE;
    
    public static AppDatabase getDatabase(final Context context) {
        if (INSTANCE == null) {
            synchronized (AppDatabase.class) {
                if (INSTANCE == null) {
                    INSTANCE = Room.databaseBuilder(
                        context.getApplicationContext(),
                        AppDatabase.class,
                        "app_database"
                    ).build();
                }
            }
        }
        return INSTANCE;
    }
}
```

## 5. Dependency Injection (Hilt/Dagger)
- **@Inject**: Constructor injection for dependencies.
- **Modules**: Provide dependencies that can't be constructor-injected.

```java
// Application class
@HiltAndroidApp
public class MyApplication extends Application {}

// Activity
@AndroidEntryPoint
public class UserActivity extends AppCompatActivity {
    @Inject
    UserViewModel.Factory viewModelFactory;
    
    private UserViewModel viewModel;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        viewModel = new ViewModelProvider(this, viewModelFactory)
            .get(UserViewModel.class);
    }
}

// Module
@Module
@InstallIn(SingletonComponent.class)
public class DatabaseModule {
    
    @Provides
    @Singleton
    public AppDatabase provideDatabase(@ApplicationContext Context context) {
        return Room.databaseBuilder(context, AppDatabase.class, "app_db").build();
    }
    
    @Provides
    public UserDao provideUserDao(AppDatabase database) {
        return database.userDao();
    }
}
```

## 6. RecyclerView & Adapters
- **ViewHolder Pattern**: Use ViewHolder for efficient scrolling.
- **DiffUtil**: Use DiffUtil for efficient list updates.

```java
public class UserAdapter extends RecyclerView.Adapter<UserAdapter.UserViewHolder> {
    private List<User> users = new ArrayList<>();
    private final OnUserClickListener listener;
    
    public void submitList(List<User> newUsers) {
        DiffUtil.DiffResult diffResult = DiffUtil.calculateDiff(
            new UserDiffCallback(users, newUsers)
        );
        users = newUsers;
        diffResult.dispatchUpdatesTo(this);
    }
    
    @Override
    public UserViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        ItemUserBinding binding = ItemUserBinding.inflate(
            LayoutInflater.from(parent.getContext()), parent, false
        );
        return new UserViewHolder(binding);
    }
    
    @Override
    public void onBindViewHolder(UserViewHolder holder, int position) {
        holder.bind(users.get(position));
    }
    
    class UserViewHolder extends RecyclerView.ViewHolder {
        private final ItemUserBinding binding;
        
        UserViewHolder(ItemUserBinding binding) {
            super(binding.getRoot());
            this.binding = binding;
        }
        
        void bind(User user) {
            binding.userName.setText(user.getName());
            binding.userEmail.setText(user.getEmail());
            binding.getRoot().setOnClickListener(v -> listener.onUserClick(user));
        }
    }
}
```

## 7. Coroutines (Kotlin interop)
- For Java projects using Kotlin coroutines, handle properly.

## 8. Testing
- **Unit Tests**: Test ViewModels and business logic.
- **UI Tests**: Use Espresso for UI testing.

```java
// ViewModel test
@ExtendWith(MockitoExtension.class)
public class UserViewModelTest {
    @Mock
    private UserRepository repository;
    
    private UserViewModel viewModel;
    
    @Before
    public void setup() {
        viewModel = new UserViewModel(repository);
    }
    
    @Test
    public void loadUser_success_updatesLiveData() {
        // Given
        User user = new User(1, "test@example.com", "Test");
        when(repository.getUser(1)).thenReturn(LiveDataTestUtil.getValue(user));
        
        // When
        viewModel.loadUser(1);
        
        // Then
        assertEquals(user, viewModel.getUser().getValue());
    }
}
```

## 9. Anti-Patterns (MUST avoid)
- **findViewById**: Use View Binding or Data Binding.
- **Business Logic in Activity/Fragment**: Use ViewModel.
- **Memory Leaks**: Avoid holding Activity/Context references in background tasks.
- **Main Thread Network**: NEVER do network calls on main thread.
  - ❌ Bad: `User user = apiService.getUser(1).execute().body();`
  - ✅ Good: Use Repository with LiveData or Coroutines

