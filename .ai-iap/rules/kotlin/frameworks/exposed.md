# Exposed ORM Framework

## Overview
Exposed is a lightweight SQL library for Kotlin that offers two APIs: DSL (type-safe SQL queries) and DAO (Object-Relational Mapping).

## Database Configuration

### Setup
```kotlin
// ✅ Good - database configuration
object DatabaseFactory {
    
    fun init() {
        val driverClassName = "org.postgresql.Driver"
        val jdbcURL = "jdbc:postgresql://localhost:5432/mydb"
        val user = "user"
        val password = "password"
        
        Database.connect(
            url = jdbcURL,
            driver = driverClassName,
            user = user,
            password = password
        )
        
        transaction {
            // Create tables
            SchemaUtils.create(Users, Orders)
        }
    }
}

// With HikariCP connection pool
fun hikariConfig() = HikariConfig().apply {
    driverClassName = "org.postgresql.Driver"
    jdbcUrl = "jdbc:postgresql://localhost:5432/mydb"
    username = "user"
    password = "password"
    maximumPoolSize = 10
    isAutoCommit = false
    transactionIsolation = "TRANSACTION_REPEATABLE_READ"
    validate()
}

fun initDatabase() {
    val dataSource = HikariDataSource(hikariConfig())
    Database.connect(dataSource)
}
```

## Table Definitions

### DSL Tables
```kotlin
// ✅ Good - table definition with DSL
object Users : Table("users") {
    val id = long("id").autoIncrement()
    val name = varchar("name", 100)
    val email = varchar("email", 100).uniqueIndex()
    val age = integer("age").nullable()
    val createdAt = timestamp("created_at").defaultExpression(CurrentTimestamp())
    val updatedAt = timestamp("updated_at").defaultExpression(CurrentTimestamp())
    
    override val primaryKey = PrimaryKey(id)
}

object Orders : Table("orders") {
    val id = long("id").autoIncrement()
    val userId = long("user_id").references(Users.id, onDelete = ReferenceOption.CASCADE)
    val total = decimal("total", 10, 2)
    val status = enumerationByName<OrderStatus>("status", 20)
    val createdAt = timestamp("created_at").defaultExpression(CurrentTimestamp())
    
    override val primaryKey = PrimaryKey(id)
}

enum class OrderStatus {
    PENDING, PROCESSING, COMPLETED, CANCELLED
}
```

### Many-to-Many Relationships
```kotlin
// ✅ Good - junction table
object Tags : Table("tags") {
    val id = long("id").autoIncrement()
    val name = varchar("name", 50)
    
    override val primaryKey = PrimaryKey(id)
}

object UserTags : Table("user_tags") {
    val userId = long("user_id").references(Users.id, onDelete = ReferenceOption.CASCADE)
    val tagId = long("tag_id").references(Tags.id, onDelete = ReferenceOption.CASCADE)
    
    override val primaryKey = PrimaryKey(userId, tagId)
}
```

## DSL Queries

### Basic CRUD Operations
```kotlin
// ✅ Good - type-safe DSL queries
class UserRepository {
    
    suspend fun findAll(): List<User> = dbQuery {
        Users.selectAll()
            .map { toUser(it) }
    }
    
    suspend fun findById(id: Long): User? = dbQuery {
        Users.select { Users.id eq id }
            .map { toUser(it) }
            .singleOrNull()
    }
    
    suspend fun findByEmail(email: String): User? = dbQuery {
        Users.select { Users.email eq email }
            .map { toUser(it) }
            .singleOrNull()
    }
    
    suspend fun create(user: User): User = dbQuery {
        val id = Users.insert {
            it[name] = user.name
            it[email] = user.email
            it[age] = user.age
        } get Users.id
        
        user.copy(id = id)
    }
    
    suspend fun update(id: Long, user: User): Int = dbQuery {
        Users.update({ Users.id eq id }) {
            it[name] = user.name
            it[email] = user.email
            it[age] = user.age
            it[updatedAt] = Instant.now()
        }
    }
    
    suspend fun delete(id: Long): Int = dbQuery {
        Users.deleteWhere { Users.id eq id }
    }
    
    private fun toUser(row: ResultRow): User = User(
        id = row[Users.id],
        name = row[Users.name],
        email = row[Users.email],
        age = row[Users.age],
        createdAt = row[Users.createdAt],
        updatedAt = row[Users.updatedAt]
    )
}

// Database query helper
suspend fun <T> dbQuery(block: suspend () -> T): T =
    newSuspendedTransaction(Dispatchers.IO) { block() }
```

### Complex Queries
```kotlin
// ✅ Good - joins, aggregations, filtering
class OrderRepository {
    
    suspend fun findUserOrders(userId: Long): List<OrderWithUser> = dbQuery {
        (Orders innerJoin Users)
            .select { Orders.userId eq userId }
            .map { toOrderWithUser(it) }
    }
    
    suspend fun findOrdersByStatus(status: OrderStatus): List<Order> = dbQuery {
        Orders.select { Orders.status eq status }
            .orderBy(Orders.createdAt to SortOrder.DESC)
            .map { toOrder(it) }
    }
    
    suspend fun countOrdersByUser(userId: Long): Long = dbQuery {
        Orders.select { Orders.userId eq userId }
            .count()
    }
    
    suspend fun getTotalSales(): BigDecimal = dbQuery {
        Orders.slice(Orders.total.sum())
            .selectAll()
            .firstOrNull()
            ?.get(Orders.total.sum())
            ?: BigDecimal.ZERO
    }
    
    suspend fun searchOrders(
        status: OrderStatus? = null,
        minTotal: BigDecimal? = null,
        maxTotal: BigDecimal? = null
    ): List<Order> = dbQuery {
        Orders.selectAll()
            .apply {
                status?.let { andWhere { Orders.status eq it } }
                minTotal?.let { andWhere { Orders.total greaterEq it } }
                maxTotal?.let { andWhere { Orders.total lessEq it } }
            }
            .map { toOrder(it) }
    }
}
```

## DAO API

### Entity Classes
```kotlin
// ✅ Good - DAO entities
class UserEntity(id: EntityID<Long>) : LongEntity(id) {
    companion object : LongEntityClass<UserEntity>(Users)
    
    var name by Users.name
    var email by Users.email
    var age by Users.age
    var createdAt by Users.createdAt
    var updatedAt by Users.updatedAt
    
    val orders by OrderEntity referrersOn Orders.userId
    
    fun toModel() = User(
        id = id.value,
        name = name,
        email = email,
        age = age,
        createdAt = createdAt,
        updatedAt = updatedAt
    )
}

class OrderEntity(id: EntityID<Long>) : LongEntity(id) {
    companion object : LongEntityClass<OrderEntity>(Orders)
    
    var user by UserEntity referencedOn Orders.userId
    var total by Orders.total
    var status by Orders.status
    var createdAt by Orders.createdAt
    
    fun toModel() = Order(
        id = id.value,
        userId = user.id.value,
        total = total,
        status = status,
        createdAt = createdAt
    )
}
```

### DAO Repository
```kotlin
// ✅ Good - repository using DAO API
class UserDaoRepository {
    
    suspend fun findAll(): List<User> = dbQuery {
        UserEntity.all().map { it.toModel() }
    }
    
    suspend fun findById(id: Long): User? = dbQuery {
        UserEntity.findById(id)?.toModel()
    }
    
    suspend fun create(user: User): User = dbQuery {
        UserEntity.new {
            name = user.name
            email = user.email
            age = user.age
        }.toModel()
    }
    
    suspend fun update(id: Long, user: User): User? = dbQuery {
        UserEntity.findById(id)?.apply {
            name = user.name
            email = user.email
            age = user.age
            updatedAt = Instant.now()
        }?.toModel()
    }
    
    suspend fun delete(id: Long): Boolean = dbQuery {
        UserEntity.findById(id)?.delete() != null
    }
}
```

## Transactions

### Transaction Management
```kotlin
// ✅ Good - transaction handling
suspend fun <T> dbTransaction(block: suspend Transaction.() -> T): T =
    newSuspendedTransaction(Dispatchers.IO) {
        block()
    }

// Usage - multiple operations in one transaction
suspend fun transferOrder(orderId: Long, newUserId: Long) = dbTransaction {
    val order = OrderEntity.findById(orderId)
        ?: throw NotFoundException("Order not found")
    
    val newUser = UserEntity.findById(newUserId)
        ?: throw NotFoundException("User not found")
    
    order.user = newUser
    order.updatedAt = Instant.now()
    
    // Both operations succeed or fail together
    order.toModel()
}
```

### Rollback on Exception
```kotlin
// ✅ Good - automatic rollback
suspend fun createUserWithOrders(
    user: User,
    orders: List<Order>
): User = dbTransaction {
    val created = UserEntity.new {
        name = user.name
        email = user.email
    }
    
    orders.forEach { order ->
        OrderEntity.new {
            this.user = created
            total = order.total
            status = order.status
        }
    }
    
    // If any order creation fails, user creation is rolled back
    created.toModel()
}
```

## Migrations

### Schema Changes
```kotlin
// ✅ Good - migration management
object DatabaseMigrations {
    
    fun runMigrations() {
        transaction {
            exec("CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\";")
            
            // Migration 1: Initial schema
            SchemaUtils.create(Users, Orders)
            
            // Migration 2: Add indexes
            exec("CREATE INDEX idx_users_email ON users(email);")
            exec("CREATE INDEX idx_orders_user_id ON orders(user_id);")
            exec("CREATE INDEX idx_orders_status ON orders(status);")
        }
    }
    
    fun addColumn() {
        transaction {
            // Add new column if doesn't exist
            exec("""
                ALTER TABLE users 
                ADD COLUMN IF NOT EXISTS phone VARCHAR(20);
            """.trimIndent())
        }
    }
}
```

## Testing

### Repository Tests
```kotlin
// ✅ Good - repository testing with H2
class UserRepositoryTest {
    
    @BeforeEach
    fun setup() {
        Database.connect(
            url = "jdbc:h2:mem:test;DB_CLOSE_DELAY=-1;",
            driver = "org.h2.Driver"
        )
        
        transaction {
            SchemaUtils.create(Users)
        }
    }
    
    @AfterEach
    fun tearDown() {
        transaction {
            SchemaUtils.drop(Users)
        }
    }
    
    @Test
    fun `create and find user`() = runTest {
        // Given
        val user = User(
            name = "John Doe",
            email = "john@example.com"
        )
        
        // When
        val created = repository.create(user)
        val found = repository.findById(created.id)
        
        // Then
        assertNotNull(found)
        assertEquals("John Doe", found?.name)
        assertEquals("john@example.com", found?.email)
    }
    
    @Test
    fun `update user changes name`() = runTest {
        // Given
        val user = User(name = "John", email = "john@example.com")
        val created = repository.create(user)
        
        // When
        val updated = user.copy(id = created.id, name = "Jane")
        repository.update(created.id, updated)
        val found = repository.findById(created.id)
        
        // Then
        assertEquals("Jane", found?.name)
    }
    
    @Test
    fun `delete user removes from database`() = runTest {
        // Given
        val user = User(name = "John", email = "john@example.com")
        val created = repository.create(user)
        
        // When
        repository.delete(created.id)
        val found = repository.findById(created.id)
        
        // Then
        assertNull(found)
    }
}
```

## Best Practices

### 1. Use Connection Pooling
```kotlin
// ✅ Good - HikariCP for production
val config = HikariConfig().apply {
    jdbcUrl = "jdbc:postgresql://localhost:5432/mydb"
    username = "user"
    password = "password"
    maximumPoolSize = 10
    minimumIdle = 2
    idleTimeout = 600000
    maxLifetime = 1800000
}

Database.connect(HikariDataSource(config))
```

### 2. Use Batch Operations
```kotlin
// ✅ Good - batch inserts
suspend fun createMany(users: List<User>): List<Long> = dbQuery {
    Users.batchInsert(users) { user ->
        this[Users.name] = user.name
        this[Users.email] = user.email
        this[Users.age] = user.age
    }.map { it[Users.id] }
}
```

### 3. Use Database Indices
```kotlin
// ✅ Good - define indices
object Users : Table("users") {
    val id = long("id").autoIncrement()
    val email = varchar("email", 100).uniqueIndex()  // Unique index
    val name = varchar("name", 100).index()  // Regular index
    
    override val primaryKey = PrimaryKey(id)
}
```

### 4. Handle NULL Values
```kotlin
// ✅ Good - explicit null handling
val age = row[Users.age]  // Int?
val nonNullAge = row[Users.age] ?: 0
```

### 5. Use Prepared Statements
```kotlin
// ✅ Good - Exposed automatically uses prepared statements
// Protects against SQL injection
val email = "user@example.com"
Users.select { Users.email eq email }  // Safe
```

