# Kotlin Code Style

> **Scope**: Apply these code style rules to all Kotlin files
> **Applies to**: *.kt files across all Kotlin projects
> **Precedence**: Language-specific style rules

## CRITICAL REQUIREMENTS (AI: Verify ALL before generating code)

> **ALWAYS**: Use `val` for immutable variables (default)
> **ALWAYS**: Use data classes for DTOs and value objects
> **ALWAYS**: Use named arguments for functions with 3+ parameters
> **ALWAYS**: Use expression body for single-expression functions
> **ALWAYS**: Use null-safety operators (`?.`, `?:`, `!!`)
> 
> **NEVER**: Use `var` unless mutation is required
> **NEVER**: Use `!!` (force unwrap) without justification
> **NEVER**: Ignore null-safety (Kotlin's main feature)
> **NEVER**: Use Java-style getters/setters (use properties)
> **NEVER**: Use semicolons (not required in Kotlin)

## Core Patterns

| Pattern | Use When | Keywords |
|---------|----------|----------|
| `val` | Immutable (default) | Read-only, cannot reassign |
| `var` | Mutable (when needed) | Can reassign |
| Data classes | DTOs, value objects | `data class`, auto-generates equals/hashCode |
| Sealed classes | Type hierarchies | Exhaustive when expressions |
| Extension functions | Add functionality | `fun String.toTitleCase()` |

## Naming Conventions

```kotlin
// Classes: PascalCase
class UserService
data class User(val id: Int, val name: String)
sealed class Result<T>

// Functions/variables: camelCase
fun calculateTotal(items: List<Item>): BigDecimal
val userName: String
var isActive: Boolean

// Constants: UPPER_SNAKE_CASE
const val MAX_RETRY_ATTEMPTS = 3
const val API_BASE_URL = "https://api.example.com"

// Private properties: leading underscore (optional)
private val _users = mutableListOf<User>()
val users: List<User> get() = _users.toList()
```

## Variables & Properties

```kotlin
// ✅ CORRECT - Immutable by default
val name = "John"
val age = 30
val items = listOf(1, 2, 3)

// ✅ CORRECT - Mutable when needed
var count = 0
count++

// ✅ CORRECT - Type inference
val user = User(id = 1, name = "John")

// ✅ CORRECT - Explicit type when needed
val users: List<User> = repository.findAll()

// ❌ WRONG - Mutable by default
var name = "John"  // Should be val if not mutated
```

## Functions

```kotlin
// ✅ CORRECT - Expression body for single expression
fun double(x: Int): Int = x * 2
fun isValid(user: User): Boolean = user.age >= 18

// ✅ CORRECT - Block body for complex logic
fun processUser(user: User): Result {
    validateUser(user)
    saveToDatabase(user)
    return Result.Success(user)
}

// ✅ CORRECT - Named arguments for readability
fun createUser(
    name: String,
    email: String,
    age: Int,
    isActive: Boolean = true
)

createUser(
    name = "John",
    email = "john@example.com",
    age = 30
)

// ✅ CORRECT - Default parameters
fun retry(times: Int = 3, delay: Long = 1000)
```

## Data Classes

```kotlin
// ✅ CORRECT - Data class for DTOs
data class User(
    val id: Int,
    val name: String,
    val email: String,
    val createdAt: LocalDateTime = LocalDateTime.now()
)

// Auto-generates: equals(), hashCode(), toString(), copy()
val user1 = User(1, "John", "john@example.com")
val user2 = user1.copy(name = "Jane")  // Copy with modifications
```

## Null Safety

```kotlin
// ✅ CORRECT - Safe call operator
val length = name?.length

// ✅ CORRECT - Elvis operator
val length = name?.length ?: 0

// ✅ CORRECT - Safe cast
val user = obj as? User

// ✅ CORRECT - let for null checks
name?.let { println("Name: $it") }

// ⚠️ USE SPARINGLY - Force unwrap (only when certain)
val length = name!!.length  // Crashes if null - justify in comments
```

## Collections

```kotlin
// ✅ CORRECT - Immutable collections (default)
val items = listOf(1, 2, 3)
val map = mapOf("a" to 1, "b" to 2)
val set = setOf(1, 2, 3)

// ✅ CORRECT - Mutable when needed
val mutableItems = mutableListOf(1, 2, 3)
mutableItems.add(4)

// ✅ CORRECT - Collection operations
val doubled = items.map { it * 2 }
val filtered = items.filter { it > 1 }
val sum = items.reduce { acc, i -> acc + i }
```

## When Expression

```kotlin
// ✅ CORRECT - When as expression
val result = when (x) {
    0 -> "zero"
    in 1..10 -> "small"
    else -> "large"
}

// ✅ CORRECT - Sealed class with when
sealed class Result {
    data class Success(val data: String) : Result()
    data class Error(val message: String) : Result()
}

fun handle(result: Result) = when (result) {
    is Result.Success -> println(result.data)
    is Result.Error -> println(result.message)
}  // Exhaustive, no else needed
```

## Extension Functions

```kotlin
// ✅ CORRECT - Extension function
fun String.toTitleCase(): String =
    split(" ").joinToString(" ") { it.capitalize() }

val title = "hello world".toTitleCase()  // "Hello World"

// ✅ CORRECT - Extension property
val String.isEmail: Boolean
    get() = contains("@") && contains(".")
```

## Scope Functions

```kotlin
// let - null safety
name?.let { println(it) }

// apply - configure object
val user = User().apply {
    name = "John"
    email = "john@example.com"
}

// also - side effects
val user = createUser().also {
    logger.info("Created user: ${it.id}")
}

// run - execute block
val result = user.run {
    validateEmail()
    save()
}

// with - multiple operations
with(user) {
    println(name)
    println(email)
}
```

## Common Mistakes

| Mistake | ❌ Wrong | ✅ Correct |
|---------|---------|-----------|
| **Overusing var** | `var name = "John"` | `val name = "John"` |
| **Force unwrap** | `name!!.length` everywhere | `name?.length`, `?:` |
| **Java style** | `getName()`, `setName()` | Properties `name` |
| **Verbose null checks** | `if (x != null) { x.method() }` | `x?.method()` |
| **Mutable by default** | `val items = mutableListOf()` | `val items = listOf()` |

## AI Self-Check

- [ ] Using `val` by default, `var` only when needed?
- [ ] Data classes for DTOs?
- [ ] Named arguments for functions with 3+ params?
- [ ] Expression body for single-expression functions?
- [ ] Null-safety operators (`?.`, `?:`) instead of `!!`?
- [ ] Immutable collections by default?
- [ ] When expressions for conditionals?
- [ ] Extension functions where appropriate?
- [ ] Following Kotlin naming conventions?
- [ ] No semicolons?

## Formatting

- Indentation: 4 spaces
- Line length: 120 characters max
- Import order: Android, third-party, Kotlin/Java stdlib
- No wildcard imports

## Key Principles

- **Immutability First**: `val` over `var`
- **Null Safety**: Leverage Kotlin's type system
- **Expressiveness**: Concise, readable code
- **Functional Style**: map, filter, reduce over loops
- **Data Classes**: For value objects
