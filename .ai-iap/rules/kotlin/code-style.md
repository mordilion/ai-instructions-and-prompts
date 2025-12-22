# Kotlin Code Style Guidelines

## Language Version
- **Kotlin 1.9+** (2.0 recommended for latest features)
- Enable explicit API mode for libraries
- Use latest language features and stdlib

## Naming Conventions

### Classes & Interfaces
```kotlin
// PascalCase for classes
class UserRepository { }
data class User(val id: Long, val name: String)
sealed class Result<out T>

// Interfaces without 'I' prefix
interface Repository { }
interface DataSource { }
```

### Functions & Properties
```kotlin
// camelCase for functions and properties
fun getUserById(id: Long): User?
val userName: String
var isLoading: Boolean = false

// Boolean properties with 'is' prefix
val isValid: Boolean
val hasPermission: Boolean
```

### Constants
```kotlin
// UPPER_SNAKE_CASE for constants
const val MAX_RETRY_COUNT = 3
const val API_BASE_URL = "https://api.example.com"

// Companion object for class-level constants
class Config {
    companion object {
        const val TIMEOUT_MS = 5000
    }
}
```

## Immutability

### Prefer val over var
```kotlin
// ✅ Good - immutable
val user = User(id = 1, name = "John")
val items = listOf(1, 2, 3)

// ❌ Avoid - mutable when not needed
var user = User(id = 1, name = "John")  // Never reassigned
```

### Use Immutable Collections
```kotlin
// ✅ Good - immutable lists
val items: List<String> = listOf("a", "b", "c")
val map: Map<String, Int> = mapOf("a" to 1)

// ❌ Avoid - mutable when not needed
val items: MutableList<String> = mutableListOf("a", "b", "c")
```

## Null Safety

### Use Safe Calls and Elvis Operator
```kotlin
// ✅ Good - safe handling
val length = text?.length ?: 0
user?.name?.let { println(it) }

// ❌ Avoid - non-null assertion
val length = text!!.length  // Can crash!
```

### Prefer Non-Nullable Types
```kotlin
// ✅ Good - non-nullable when possible
data class User(
    val id: Long,
    val name: String,
    val email: String? = null  // Only nullable if truly optional
)

// ❌ Avoid - unnecessary nullability
data class User(
    val id: Long?,  // ID should never be null
    val name: String?  // Name should never be null
)
```

## Functions

### Use Expression Bodies
```kotlin
// ✅ Good - concise expression body
fun double(x: Int): Int = x * 2
fun isValid(user: User): Boolean = user.email.isNotEmpty()

// ✅ Also good for single-line functions
fun getFullName() = "$firstName $lastName"
```

### Named Arguments for Clarity
```kotlin
// ✅ Good - clear intent
createUser(
    name = "John Doe",
    email = "john@example.com",
    age = 30
)

// ❌ Avoid - unclear what values mean
createUser("John Doe", "john@example.com", 30)
```

### Default Parameters Instead of Overloads
```kotlin
// ✅ Good - single function with defaults
fun fetchData(
    url: String,
    timeout: Long = 5000,
    retryCount: Int = 3
) { }

// ❌ Avoid - multiple overloads
fun fetchData(url: String) { }
fun fetchData(url: String, timeout: Long) { }
fun fetchData(url: String, timeout: Long, retryCount: Int) { }
```

## Data Classes

### Use data classes for DTOs
```kotlin
// ✅ Good - automatic equals, hashCode, toString, copy
data class User(
    val id: Long,
    val name: String,
    val email: String
)

// Usage
val updated = user.copy(name = "Jane Doe")
```

### Avoid data classes for behavior-rich entities
```kotlin
// ✅ Good - regular class with behavior
class Order(
    val id: Long,
    private val items: List<OrderItem>
) {
    fun calculateTotal(): Money = items.sumOf { it.price }
    fun canBeCancelled(): Boolean = status == OrderStatus.PENDING
}
```

## Sealed Classes

### Use for exhaustive state handling
```kotlin
// ✅ Good - compile-time exhaustive checks
sealed class Result<out T> {
    data class Success<T>(val data: T) : Result<T>()
    data class Error(val exception: Throwable) : Result<Nothing>()
    data object Loading : Result<Nothing>()
}

// Usage - compiler ensures all cases handled
when (result) {
    is Result.Success -> showData(result.data)
    is Result.Error -> showError(result.exception)
    is Result.Loading -> showLoading()
}
```

## Extension Functions

### Use extensions for utility operations
```kotlin
// ✅ Good - extend existing types
fun String.isValidEmail(): Boolean =
    matches(Regex("[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}"))

fun <T> List<T>.second(): T = this[1]

// Usage
val email = "test@example.com"
if (email.isValidEmail()) { }
```

### Don't overuse extensions
```kotlin
// ❌ Avoid - should be a method or function
fun User.save() { repository.save(this) }  // Side effects

// ✅ Good - repository method instead
class UserRepository {
    fun save(user: User) { }
}
```

## Coroutines

### Use structured concurrency
```kotlin
// ✅ Good - structured concurrency
class UserViewModel(
    private val repository: UserRepository
) : ViewModel() {
    fun loadUser(id: Long) {
        viewModelScope.launch {
            val user = repository.getUser(id)
            _state.value = UserState.Success(user)
        }
    }
}
```

### Use Flow for streams
```kotlin
// ✅ Good - reactive stream
fun observeUsers(): Flow<List<User>> = flow {
    val users = repository.getUsers()
    emit(users)
}.flowOn(Dispatchers.IO)
```

## Type Inference

### Let compiler infer types when obvious
```kotlin
// ✅ Good - type obvious from initializer
val name = "John"  // String
val count = 42  // Int
val items = listOf(1, 2, 3)  // List<Int>

// ✅ Good - explicit type when not obvious
val users: List<User> = emptyList()
val callback: (String) -> Unit = { println(it) }
```

## Scope Functions

### Use appropriate scope function
```kotlin
// let - null safety and transform
val length = text?.let { it.length } ?: 0

// apply - object configuration
val user = User().apply {
    name = "John"
    email = "john@example.com"
}

// also - side effects
val user = createUser().also { 
    logger.info("Created user: ${it.id}")
}

// run - execute block and return result
val result = run {
    val a = compute()
    val b = compute()
    a + b
}

// with - multiple calls on same object
with(user) {
    println(name)
    println(email)
}
```

## Best Practices

### 1. Use when Instead of if-else Chains
```kotlin
// ✅ Good
when (status) {
    Status.PENDING -> handlePending()
    Status.PROCESSING -> handleProcessing()
    Status.COMPLETED -> handleCompleted()
    Status.FAILED -> handleFailed()
}

// ❌ Avoid
if (status == Status.PENDING) {
    handlePending()
} else if (status == Status.PROCESSING) {
    handleProcessing()
} // ...
```

### 2. Use require/check/assert
```kotlin
// ✅ Good - explicit preconditions
fun processUser(user: User?) {
    requireNotNull(user) { "User cannot be null" }
    require(user.age >= 18) { "User must be 18 or older" }
    check(isInitialized) { "Service not initialized" }
}
```

### 3. Avoid Platform Types
```kotlin
// ❌ Avoid - Java interop without null annotations
val name = javaObject.getName()  // String! (platform type)

// ✅ Good - explicit nullability
val name: String = javaObject.getName() ?: "Unknown"
```

### 4. Use Delegation
```kotlin
// ✅ Good - property delegation
class User {
    val name: String by lazy {
        fetchNameFromDatabase()
    }
}

// ✅ Good - interface delegation
class Repository(
    private val cache: Cache
) : Cache by cache {
    // Only override what's needed
    override fun get(key: String): String? {
        return cache.get(key) ?: fetchFromNetwork(key)
    }
}
```

### 5. Destructuring Declarations
```kotlin
// ✅ Good - cleaner code
val (name, email) = user
val (first, second) = list

// Map iteration
for ((key, value) in map) {
    println("$key: $value")
}
```

