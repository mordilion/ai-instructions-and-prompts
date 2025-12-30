# Android Development with Java

> **Scope**: Android apps using Java
> **Applies to**: Java files in Android projects
> **Extends**: java/architecture.md, java/code-style.md

## CRITICAL REQUIREMENTS

> **ALWAYS**: Use ViewBinding (NOT findViewById)
> **ALWAYS**: Use ViewModel with LiveData
> **ALWAYS**: Clean up Fragment bindings in onDestroyView
> **ALWAYS**: Use lifecycle-aware components
> **ALWAYS**: Handle null safely
> 
> **NEVER**: Use findViewById (use ViewBinding)
> **NEVER**: Skip Fragment binding cleanup
> **NEVER**: Use AsyncTask (deprecated)
> **NEVER**: Block main thread
> **NEVER**: Leak context references

## Core Patterns

### Activity

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
        viewModel.getUsers().observe(this, users -> updateUI(users));
    }
}
```

### Fragment (Memory Leak Prevention)

```java
public class UserFragment extends Fragment {
    private FragmentUserBinding binding;
    private UserViewModel viewModel;
    
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle state) {
        binding = FragmentUserBinding.inflate(inflater, container, false);
        return binding.getRoot();
    }
    
    @Override
    public void onViewCreated(View view, Bundle state) {
        super.onViewCreated(view, state);
        viewModel = new ViewModelProvider(this).get(UserViewModel.class);
    }
    
    @Override
    public void onDestroyView() {
        super.onDestroyView();
        binding = null;  // CRITICAL: Prevent memory leak
    }
}
```

### ViewModel

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
        repository.getUsers(users::postValue);
    }
}
```

### RecyclerView Adapter

```java
public class UserAdapter extends RecyclerView.Adapter<UserAdapter.ViewHolder> {
    private List<User> users = new ArrayList<>();
    
    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        ItemUserBinding binding = ItemUserBinding.inflate(
            LayoutInflater.from(parent.getContext()), parent, false);
        return new ViewHolder(binding);
    }
    
    @Override
    public void onBindViewHolder(ViewHolder holder, int position) {
        holder.bind(users.get(position));
    }
    
    @Override
    public int getItemCount() {
        return users.size();
    }
    
    static class ViewHolder extends RecyclerView.ViewHolder {
        private final ItemUserBinding binding;
        
        ViewHolder(ItemUserBinding binding) {
            super(binding.getRoot());
            this.binding = binding;
        }
        
        void bind(User user) {
            binding.textName.setText(user.getName());
        }
    }
}
```

## Common AI Mistakes

| Mistake | ❌ Wrong | ✅ Correct |
|---------|---------|-----------|
| **findViewById** | Manual view lookup | ViewBinding |
| **No Binding Cleanup** | Keep Fragment binding | Set to null in onDestroyView |
| **AsyncTask** | Deprecated API | Executors or coroutines |
| **Context Leak** | Store Activity reference | Use Application context |

### Anti-Pattern: No Binding Cleanup (MEMORY LEAK)

```java
// ❌ WRONG
public class UserFragment extends Fragment {
    private FragmentUserBinding binding;  // Never cleaned up!
}

// ✅ CORRECT
public class UserFragment extends Fragment {
    private FragmentUserBinding binding;
    
    @Override
    public void onDestroyView() {
        super.onDestroyView();
        binding = null;  // Release reference
    }
}
```

## AI Self-Check

- [ ] ViewBinding (not findViewById)?
- [ ] ViewModel for business logic?
- [ ] LiveData for reactive UI?
- [ ] Fragment binding cleanup?
- [ ] Lifecycle-aware components?
- [ ] No AsyncTask?
- [ ] No context leaks?
- [ ] No main thread blocking?
- [ ] Proper null handling?
- [ ] RecyclerView with ViewHolder?

## Key Components

| Component | Purpose |
|-----------|---------|
| ViewBinding | Type-safe view access |
| ViewModel | Survive configuration changes |
| LiveData | Observable data |
| Repository | Data abstraction |
| Room | Local database |
| Retrofit | Networking |

## Best Practices

**MUST**: ViewBinding, ViewModel, LiveData, Fragment cleanup
**SHOULD**: Repository pattern, Room, Retrofit, Hilt DI
**AVOID**: findViewById, AsyncTask, context leaks, main thread blocking
