# Kotlin Code Style

> **Scope**: Kotlin formatting and maintainability
> **Applies to**: *.kt, *.kts files
> **Extends**: General code style, kotlin/architecture.md

## CRITICAL REQUIREMENTS

> **ALWAYS**: Use `val` for immutable (default)
> **ALWAYS**: Use data classes for DTOs
> **ALWAYS**: Use named arguments for 3+ parameters
> **ALWAYS**: Use expression body for single expressions
> **ALWAYS**: Use null-safety operators (`?.`, `?:`)
> **ALWAYS**: Use Elvis `?:` instead of verbose null-check ternaries
>
> **NEVER**: Use `var` unless mutation required
> **NEVER**: Use `!!` without justification
> **NEVER**: Ignore null-safety
> **NEVER**: Use Java-style getters/setters
> **NEVER**: Call the same nullable getter twice (extract with `?:` or `let`)

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

## Reduce Method Calls (Elvis `?:` + Extract Variable)

> **ALWAYS**: Replace null-check ternaries with the Elvis operator `?:`.
> **ALWAYS**: Extract repeated calls into a `val` — do NOT call the same getter twice.

```kotlin
// ❌ BAD: getCompanyName() called 3 times
val displayName = if (customer.getCompanyName() != null && customer.getCompanyName() != "")
    customer.getCompanyName()
else
    customer.getContactPerson()

// ✅ GOOD: Elvis + takeIf — single call, intent explicit
val displayName = customer.companyName?.takeIf { it.isNotEmpty() }
    ?: customer.contactPerson

// ✅ ALSO GOOD: extract variable for clarity / reuse
val companyName = customer.companyName
val displayName = companyName?.takeIf { it.isNotEmpty() } ?: customer.contactPerson
```

## Common AI Mistakes

| Mistake | ❌ Wrong | ✅ Correct |
|---------|---------|-----------|
| **Mutable by default** | `var` everywhere | `val` by default |
| **Force unwrap** | `user!!` | `user?.let { }` |
| **No data class** | Manual equals/hashCode | `data class` |
| **Java style** | `getName()` | `name` property |

## Best Practices

**MUST**: `val` default, data classes, null-safety, named arguments
**SHOULD**: Expression body, extension functions, sealed classes
**AVOID**: `var` by default, `!!`, Java patterns, mutable collections

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
- [ ] No nullable getter called twice (extracted or Elvis-collapsed)?
- [ ] Elvis `?:` used instead of null-check ternaries?
