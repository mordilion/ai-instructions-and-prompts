# Kotlin Code Style

> **Scope**: All Kotlin files
> **Applies to**: *.kt, *.kts files

## CRITICAL REQUIREMENTS

> **ALWAYS**: Use `val` for immutable (default)
> **ALWAYS**: Use data classes for DTOs
> **ALWAYS**: Use named arguments for 3+ parameters
> **ALWAYS**: Use expression body for single expressions
> **ALWAYS**: Use null-safety operators (`?.`, `?:`)
> 
> **NEVER**: Use `var` unless mutation required
> **NEVER**: Use `!!` without justification
> **NEVER**: Ignore null-safety
> **NEVER**: Use Java-style getters/setters

## Naming

```kotlin
class UserService                          // PascalCase
fun calculateTotal(): BigDecimal           // camelCase
val userName: String                       // camelCase
const val MAX_ATTEMPTS = 3                 // UPPER_SNAKE_CASE
```

## Core Patterns

| Pattern | Example |
|---------|---------|
| **Variables** | `val name = "John"` (immutable), `var count = 0` (mutable) |
| **Data Classes** | `data class User(val id: Int, val name: String)` |
| **Functions** | `fun add(a: Int, b: Int) = a + b` |
| **Named Args** | `createUser(name = "John", email = "...", age = 30)` |
| **Null Safety** | `name?.length`, `value ?: default`, `user?.let { }` |
| **When** | `when (result) { is Success -> ... is Error -> ... }` |
| **Collections** | `listOf(1, 2)`, `.filter { }.map { }.sorted()` |
| **Extensions** | `fun String.toTitleCase() = lowercase().replaceFirstChar { it.uppercase() }` |

## Scope Functions

| Function | Usage | Returns |
|----------|-------|---------|
| `let` | Transform value | Lambda result |
| `apply` | Configure object | Object |
| `also` | Side effects | Object |
| `run` | Execute block | Lambda result |

```kotlin
user?.let { processUser(it) }
User().apply { name = "John" }
list.also { log(it.size) }
```

## Common AI Mistakes

| Mistake | ❌ Wrong | ✅ Correct |
|---------|---------|-----------|
| **Mutable by default** | `var` everywhere | `val` by default |
| **Force unwrap** | `user!!` | `user?.let { }` |
| **No data class** | Manual equals/hashCode | `data class` |
| **Java style** | `getName()` | `name` property |

## AI Self-Check

- [ ] `val` by default?
- [ ] Data classes for DTOs?
- [ ] Named arguments (3+ params)?
- [ ] Expression body for single expressions?
- [ ] Null-safety operators?
- [ ] No unnecessary `var`?
- [ ] No unjustified `!!`?
- [ ] Properties not getters/setters?
- [ ] Extension functions where appropriate?

## Best Practices

**MUST**: `val` default, data classes, null-safety, named arguments
**SHOULD**: Expression body, extension functions, sealed classes
**AVOID**: `var` by default, `!!`, Java patterns, mutable collections
