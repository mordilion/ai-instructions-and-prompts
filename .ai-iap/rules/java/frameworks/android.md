# Android Development with Java

## Overview
Android development with Java: Google's original Android development language before Kotlin.
While Kotlin is now recommended, Java remains widely used in legacy apps and enterprise projects.
Use for maintaining existing Java Android apps or when team expertise is primarily in Java.

## Activities

```java
public class MainActivity extends AppCompatActivity {
    private ActivityMainBinding binding;
    private UserViewModel viewModel;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = ActivityMainBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());
        
        viewModel = new ViewModelProvider(this).get(UserViewModel.class);
        setupObservers();
    }
    
    private void setupObservers() {
        viewModel.getUsers().observe(this, users -> {
            // Update UI
        });
    }
}
```

## Fragments

```java
public class UserFragment extends Fragment {
    private FragmentUserBinding binding;
    private UserViewModel viewModel;
    
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        binding = FragmentUserBinding.inflate(inflater, container, false);
        return binding.getRoot();
    }
    
    @Override
    public void onViewCreated(@NonNull View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        viewModel = new ViewModelProvider(requireActivity()).get(UserViewModel.class);
        setupRecyclerView();
    }
    
    @Override
    public void onDestroyView() {
        super.onDestroyView();
        binding = null;
    }
}
```

## ViewModels

```java
public class UserViewModel extends ViewModel {
    private final MutableLiveData<List<User>> users = new MutableLiveData<>();
    private final UserRepository repository;
    
    public UserViewModel(UserRepository repository) {
        this.repository = repository;
    }
    
    public LiveData<List<User>> getUsers() {
        return users;
    }
    
    public void loadUsers() {
        repository.getUsers(new Callback<List<User>>() {
            @Override
            public void onSuccess(List<User> result) {
                users.postValue(result);
            }
            
            @Override
            public void onError(Exception e) {
                // Handle error
            }
        });
    }
}
```

## Room Database

```java
@Entity(tableName = "users")
public class UserEntity {
    @PrimaryKey(autoGenerate = true)
    private long id;
    
    @ColumnInfo(name = "name")
    @NonNull
    private String name;
    
    @ColumnInfo(name = "email")
    @NonNull
    private String email;
}

@Dao
public interface UserDao {
    @Query("SELECT * FROM users")
    LiveData<List<UserEntity>> getAll();
    
    @Query("SELECT * FROM users WHERE id = :id")
    UserEntity getById(long id);
    
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    void insert(UserEntity user);
    
    @Delete
    void delete(UserEntity user);
}

@Database(entities = {UserEntity.class}, version = 1)
public abstract class AppDatabase extends RoomDatabase {
    public abstract UserDao userDao();
    
    private static volatile AppDatabase INSTANCE;
    
    public static AppDatabase getInstance(Context context) {
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

## Dependency Injection (Dagger Hilt)

```java
@HiltAndroidApp
public class MyApplication extends Application {
}

@Module
@InstallIn(SingletonComponent.class)
public class AppModule {
    @Provides
    @Singleton
    public AppDatabase provideDatabase(@ApplicationContext Context context) {
        return AppDatabase.getInstance(context);
    }
    
    @Provides
    public UserDao provideUserDao(AppDatabase database) {
        return database.userDao();
    }
}

@HiltViewModel
public class UserViewModel extends ViewModel {
    @Inject
    public UserViewModel(UserRepository repository) {
        // ...
    }
}
```

## RecyclerView

```java
public class UserAdapter extends RecyclerView.Adapter<UserAdapter.ViewHolder> {
    private final List<User> users;
    private final OnUserClickListener listener;
    
    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        ItemUserBinding binding = ItemUserBinding.inflate(
            LayoutInflater.from(parent.getContext()), parent, false
        );
        return new ViewHolder(binding);
    }
    
    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        holder.bind(users.get(position));
    }
    
    @Override
    public int getItemCount() {
        return users.size();
    }
    
    class ViewHolder extends RecyclerView.ViewHolder {
        private final ItemUserBinding binding;
        
        ViewHolder(ItemUserBinding binding) {
            super(binding.getRoot());
            this.binding = binding;
        }
        
        void bind(User user) {
            binding.textName.setText(user.getName());
            binding.getRoot().setOnClickListener(v -> listener.onUserClick(user));
        }
    }
}
```

## Navigation

```java
// Navigation Component
@Override
public void onUserClick(User user) {
    Bundle bundle = new Bundle();
    bundle.putLong("userId", user.getId());
    NavHostFragment.findNavController(this)
        .navigate(R.id.action_list_to_detail, bundle);
}
```

## Testing

```java
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
    public void loadUsers_Success_UpdatesLiveData() {
        List<User> users = Arrays.asList(new User(1, "John", "john@test.com"));
        when(repository.getUsers()).thenReturn(users);
        
        viewModel.loadUsers();
        
        assertEquals(users, viewModel.getUsers().getValue());
    }
}
```

## Pattern Selection

### ViewBinding vs DataBinding
**Use ViewBinding (RECOMMENDED)**:
- Type-safe view access
- Null-safe
- Faster compile time than DataBinding

**Use DataBinding when**:
- Need two-way binding
- Complex UI logic in XML
- Legacy codebase already uses it

## Best Practices

**MUST**:
- Use ViewBinding (NOT findViewById)
- Use ViewModel for UI data (survives configuration changes)
- Use LiveData or StateFlow for observable data
- Clean up observers in onDestroy()
- Use @NonNull and @Nullable annotations everywhere

**SHOULD**:
- Use Room for local persistence (NOT raw SQLite)
- Use Hilt for dependency injection (NOT manual DI)
- Use Jetpack Navigation for multi-screen apps
- Use coroutines for async operations (NOT AsyncTask)

**AVOID**:
- findViewById() (use ViewBinding)
- Storing data in Activity/Fragment (use ViewModel)
- Memory leaks from observers (clean up properly)
- AsyncTask (deprecated - use coroutines or RxJava)
- Manual lifecycle management (use lifecycle-aware components)

## Common Patterns

### ViewModel Lifecycle
```java
// ✅ GOOD: ViewModel survives configuration changes
public class UserViewModel extends ViewModel {
    private final MutableLiveData<List<User>> users = new MutableLiveData<>();
    
    public void loadUsers() {
        // Data persists through rotation
        repository.getUsers(new Callback<List<User>>() {
            @Override
            public void onSuccess(List<User> result) {
                users.postValue(result);
            }
        });
    }
}

// ❌ BAD: Storing data in Activity
public class UserActivity extends AppCompatActivity {
    private List<User> users;  // LOST on rotation!
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        loadUsers();  // Re-fetches on every rotation
    }
}
```

### Memory Leak Prevention
```java
// ❌ BAD: Observer not cleaned up
public class UserActivity extends AppCompatActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        viewModel.getUsers().observe(this, users -> {
            // Observer lives forever if Activity destroyed abnormally
        });
    }
}

// ✅ GOOD: Lifecycle-aware observation
public class UserActivity extends AppCompatActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        // 'this' as LifecycleOwner - auto cleanup
        viewModel.getUsers().observe(this, users -> {
            updateUI(users);
        });
    }
}
```
