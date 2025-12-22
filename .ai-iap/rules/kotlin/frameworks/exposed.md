# Exposed ORM Framework

## Overview
Exposed: lightweight SQL library for Kotlin with DSL and DAO APIs.

## Database Configuration

```kotlin
object DatabaseFactory {
    fun init() {
        Database.connect(
            url = "jdbc:postgresql://localhost:5432/db",
            driver = "org.postgresql.Driver",
            user = "user",
            password = "password"
        )
        transaction { SchemaUtils.create(Users) }
    }
}

// With HikariCP
fun initDatabase() {
    val config = HikariConfig().apply {
        jdbcUrl = "jdbc:postgresql://localhost:5432/db"
        maximumPoolSize = 10
    }
    Database.connect(HikariDataSource(config))
}
```

## Table Definitions

### DSL Tables
```kotlin
object Users : Table("users") {
    val id = long("id").autoIncrement()
    val name = varchar("name", 100)
    val email = varchar("email", 100).uniqueIndex()
    val createdAt = timestamp("created_at").defaultExpression(CurrentTimestamp())
    override val primaryKey = PrimaryKey(id)
}

object Orders : Table("orders") {
    val id = long("id").autoIncrement()
    val userId = long("user_id").references(Users.id, onDelete = ReferenceOption.CASCADE)
    val total = decimal("total", 10, 2)
    override val primaryKey = PrimaryKey(id)
}
```

## DSL Queries

### CRUD Operations
```kotlin
class UserRepository {
    suspend fun findAll(): List<User> = dbQuery {
        Users.selectAll().map { toUser(it) }
    }
    
    suspend fun findById(id: Long): User? = dbQuery {
        Users.select { Users.id eq id }.map { toUser(it) }.singleOrNull()
    }
    
    suspend fun create(user: User): User = dbQuery {
        val id = Users.insert {
            it[name] = user.name
            it[email] = user.email
        } get Users.id
        user.copy(id = id)
    }
    
    suspend fun update(id: Long, user: User): Int = dbQuery {
        Users.update({ Users.id eq id }) {
            it[name] = user.name
            it[email] = user.email
        }
    }
    
    suspend fun delete(id: Long): Int = dbQuery {
        Users.deleteWhere { Users.id eq id }
    }
}

suspend fun <T> dbQuery(block: suspend () -> T): T =
    newSuspendedTransaction(Dispatchers.IO) { block() }
```

### Complex Queries
```kotlin
suspend fun findUserOrders(userId: Long): List<OrderWithUser> = dbQuery {
    (Orders innerJoin Users)
        .select { Orders.userId eq userId }
        .map { toOrderWithUser(it) }
}

suspend fun searchOrders(
    status: OrderStatus? = null,
    minTotal: BigDecimal? = null
): List<Order> = dbQuery {
    Orders.selectAll()
        .apply {
            status?.let { andWhere { Orders.status eq it } }
            minTotal?.let { andWhere { Orders.total greaterEq it } }
        }
        .map { toOrder(it) }
}
```

## DAO API

### Entity Classes
```kotlin
class UserEntity(id: EntityID<Long>) : LongEntity(id) {
    companion object : LongEntityClass<UserEntity>(Users)
    
    var name by Users.name
    var email by Users.email
    val orders by OrderEntity referrersOn Orders.userId
    
    fun toModel() = User(id.value, name, email)
}

class UserDaoRepository {
    suspend fun findAll(): List<User> = dbQuery {
        UserEntity.all().map { it.toModel() }
    }
    
    suspend fun create(user: User): User = dbQuery {
        UserEntity.new {
            name = user.name
            email = user.email
        }.toModel()
    }
}
```

## Transactions

```kotlin
suspend fun <T> dbTransaction(block: suspend Transaction.() -> T): T =
    newSuspendedTransaction(Dispatchers.IO) { block() }

suspend fun transferOrder(orderId: Long, newUserId: Long) = dbTransaction {
    val order = OrderEntity.findById(orderId) ?: throw NotFoundException()
    val newUser = UserEntity.findById(newUserId) ?: throw NotFoundException()
    order.user = newUser
    order.toModel()
}
```

## Migrations

```kotlin
object DatabaseMigrations {
    fun runMigrations() {
        transaction {
            SchemaUtils.create(Users, Orders)
            exec("CREATE INDEX idx_users_email ON users(email);")
        }
    }
}
```

## Best Practices

**MUST**:
- Use `newSuspendedTransaction` for async code (Ktor, coroutines)
- Use `transaction` for blocking code only
- Define table schema with proper indices
- Use HikariCP for connection pooling in production
- Close/dispose database connections properly

**SHOULD**:
- Use DSL API for flexibility (NOT DAO unless needed)
- Use batch operations for multiple inserts/updates
- Define foreign keys with proper cascade behavior
- Use SchemaUtils for development (migrations for production)
- Add indices to frequently queried columns

**AVOID**:
- Running queries outside transactions
- N+1 query problems (no automatic eager loading)
- Using DAO API unless you need object mapping
- Forgetting to configure connection pool
- Direct SQL strings (use DSL for type safety)

## Common Patterns

### Connection Pooling (Production)
```kotlin
// ✅ GOOD: HikariCP configuration
val config = HikariConfig().apply {
    jdbcUrl = "jdbc:postgresql://localhost/db"
    driverClassName = "org.postgresql.Driver"
    username = "user"
    password = "password"
    maximumPoolSize = 10
    minimumIdle = 2
    connectionTimeout = 30000
}
Database.connect(HikariDataSource(config))

// ❌ BAD: No pooling (development only)
Database.connect(
    url = "jdbc:postgresql://localhost/db",
    driver = "org.postgresql.Driver"
)
```

### Batch Operations
```kotlin
// ✅ GOOD: Batch insert (single query)
suspend fun createMany(users: List<User>): List<Long> = dbQuery {
    Users.batchInsert(users) { user ->
        this[Users.name] = user.name
        this[Users.email] = user.email
    }.map { it[Users.id] }
}

// ❌ BAD: Multiple individual inserts
suspend fun createMany(users: List<User>) = dbQuery {
    users.forEach { user ->
        Users.insert {  // Separate query each time!
            it[name] = user.name
            it[email] = user.email
        }
    }
}
```

### Index Definition
```kotlin
// ✅ GOOD: Proper indices
object Users : Table("users") {
    val id = long("id").autoIncrement()
    val email = varchar("email", 100).uniqueIndex()  // Unique + indexed
    val name = varchar("name", 100).index()  // Regular index for searches
    val createdAt = timestamp("created_at").index()  // Index for sorting
    override val primaryKey = PrimaryKey(id)
}

// ❌ BAD: No indices (slow queries)
object Users : Table("users") {
    val id = long("id").autoIncrement()
    val email = varchar("email", 100)  // No index! Slow lookups
    val name = varchar("name", 100)
}
```
