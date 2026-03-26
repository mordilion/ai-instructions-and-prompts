# Exposed ORM Framework

> **Scope**: Lightweight SQL library for Kotlin  
> **Applies to**: Kotlin files using Exposed
> **Extends**: kotlin/architecture.md, kotlin/code-style.md

## CRITICAL REQUIREMENTS

> **ALWAYS**: Use transactions for all database operations
> **ALWAYS**: Use suspend functions with dbQuery { }
> **ALWAYS**: Define tables as objects extending Table
> **ALWAYS**: Use DatabaseFactory.init() to setup
> **ALWAYS**: Use HikariCP for connection pooling
> 
> **NEVER**: Perform operations outside transactions
> **NEVER**: Block threads with synchronous queries
> **NEVER**: Skip table schema creation
> **NEVER**: Use string literals for columns
> **NEVER**: Expose database exceptions to API

## Core Patterns

### Database Setup

```kotlin
object DatabaseFactory {
    fun init() {
        val config = HikariConfig().apply {
            jdbcUrl = "jdbc:postgresql://localhost:5432/db"
            driverClassName = "org.postgresql.Driver"
            username = "user"
            password = "password"
            maximumPoolSize = 10
        }
        Database.connect(HikariDataSource(config))
        transaction { SchemaUtils.create(Users, Orders) }
    }
}

suspend fun <T> dbQuery(block: () -> T): T =
    withContext(Dispatchers.IO) { transaction { block() } }
```

### Table Definition

```kotlin
object Users : IntIdTable("users") {
    val name = varchar("name", 255)
    val email = varchar("email", 255).uniqueIndex()
    val createdAt = datetime("created_at").defaultExpression(CurrentDateTime)
}
```

### CRUD Operations (DSL)

```kotlin
// Create
suspend fun createUser(name: String, email: String): Int = dbQuery {
    Users.insert {
        it[Users.name] = name
        it[Users.email] = email
    } get Users.id
}

// Read
suspend fun getAllUsers(): List<User> = dbQuery {
    Users.selectAll().map { toUser(it) }
}

// Update
suspend fun updateUser(id: Int, name: String) = dbQuery {
    Users.update({ Users.id eq id }) {
        it[Users.name] = name
    }
}

// Delete
suspend fun deleteUser(id: Int) = dbQuery {
    Users.deleteWhere { Users.id eq id }
}
```

### Joins

```kotlin
suspend fun getUsersWithOrders() = dbQuery {
    (Users innerJoin Orders)
        .selectAll()
        .map { row ->
            User(
                id = row[Users.id].value,
                name = row[Users.name],
                orders = listOf(Order(row[Orders.id].value, row[Orders.total]))
            )
        }
}
```

## Common AI Mistakes

| Mistake | ❌ Wrong | ✅ Correct |
|---------|---------|-----------|
| **No Transaction** | Direct query | `transaction { }` |
| **Blocking** | Sync query | `dbQuery { }` |
| **String Literals** | `"name"` | `Users.name` |
| **No Schema** | Missing SchemaUtils | `SchemaUtils.create()` |

## AI Self-Check

- [ ] Using transactions?
- [ ] dbQuery for async?
- [ ] Tables as objects?
- [ ] DatabaseFactory.init()?
- [ ] HikariCP pooling?
- [ ] No operations outside transactions?
- [ ] No blocking queries?
- [ ] Schema creation?
- [ ] No string literals?

## Key Features

| Feature | Purpose |
|---------|---------|
| DSL API | Type-safe SQL |
| Transactions | Data integrity |
| dbQuery | Async operations |
| Hikari CP | Connection pooling |
| SchemaUtils | Schema management |

## Best Practices

**MUST**: Transactions, dbQuery, Tables, DatabaseFactory, HikariCP
**SHOULD**: Joins, indexes, default expressions, migrations
**AVOID**: No transactions, blocking, string literals, missing schema
