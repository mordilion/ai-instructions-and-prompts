---
title: Database Query Patterns
category: Data Access
difficulty: intermediate
languages: [typescript, python, java, csharp, php, kotlin, swift, dart]
tags: [database, sql, orm, sql-injection, security]
updated: 2026-01-09
---

# Database Query Patterns

> Safe queries, prevent SQL injection, parameterized statements

---

## TypeScript

### Prisma (Type-safe ORM)
```typescript
import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();

// Query
const user = await prisma.user.findUnique({
  where: { id: userId },
  include: { posts: true }
});

// Insert
const newUser = await prisma.user.create({
  data: {
    email: 'user@example.com',
    name: 'John Doe'
  }
});

// Raw query (parameterized)
const users = await prisma.$queryRaw`
  SELECT * FROM users WHERE age > ${minAge} AND status = ${status}
`;
```

### TypeORM
```typescript
import { Repository } from 'typeorm';

const user = await userRepository.findOne({
  where: { id: userId },
  relations: ['posts']
});

const users = await userRepository
  .createQueryBuilder('user')
  .where('user.age > :age', { age: minAge })
  .andWhere('user.status = :status', { status })
  .getMany();
```

### Knex.js (Query Builder)
```typescript
import knex from 'knex';
const db = knex({ client: 'pg', connection: process.env.DATABASE_URL });

const user = await db('users').where({ id: userId }).first();

const [id] = await db('users')
  .insert({ email: 'user@example.com', name: 'John Doe' })
  .returning('id');
```

### Plain PostgreSQL (pg)
```typescript
import { Pool } from 'pg';
const pool = new Pool({ connectionString: process.env.DATABASE_URL });

// ✅ ALWAYS parameterized
const query = 'SELECT * FROM users WHERE email = $1 AND status = $2';
const result = await pool.query(query, [email, status]);

// ❌ NEVER string concatenation
const badQuery = `SELECT * FROM users WHERE email = '${email}'`; // SQL INJECTION!
```

---

## Python

### SQLAlchemy ORM
```python
from sqlalchemy import create_engine, select
from sqlalchemy.orm import Session

engine = create_engine('postgresql://user:pass@localhost/db')

with Session(engine) as session:
    user = session.query(User).filter_by(id=user_id).first()
    
    # Or with select
    stmt = select(User).where(User.id == user_id)
    user = session.execute(stmt).scalar_one()

# Insert
with Session(engine) as session:
    new_user = User(email='user@example.com', name='John Doe')
    session.add(new_user)
    session.commit()

# Parameterized raw query
from sqlalchemy import text
stmt = text("SELECT * FROM users WHERE age > :age AND status = :status")
users = session.execute(stmt, {"age": min_age, "status": status}).all()
```

### Django ORM
```python
user = User.objects.get(id=user_id)
users = User.objects.filter(age__gt=min_age, status=status)

# Insert
user = User.objects.create(email='user@example.com', name='John Doe')

# Raw query (parameterized)
users = User.objects.raw(
    "SELECT * FROM users WHERE email = %s AND status = %s",
    [email, status]
)
```

### asyncpg (Async PostgreSQL)
```python
import asyncpg

conn = await asyncpg.connect('postgresql://user:pass@localhost/db')

users = await conn.fetch(
    'SELECT * FROM users WHERE age > $1 AND status = $2',
    min_age, status
)

user_id = await conn.fetchval(
    'INSERT INTO users (email, name) VALUES ($1, $2) RETURNING id',
    email, name
)
```

---

## Java

### Spring Data JPA
```java
@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmail(String email);
    List<User> findByAgeGreaterThan(int age);
    
    @Query("SELECT u FROM User u WHERE u.status = :status")
    List<User> findByStatus(@Param("status") String status);
    
    @Query(value = "SELECT * FROM users WHERE age > ?1 AND status = ?2", 
           nativeQuery = true)
    List<User> findByAgeAndStatus(int age, String status);
}
```

### JPA/Hibernate
```java
@Repository
public class UserRepository {
    @PersistenceContext
    private EntityManager em;
    
    public User findById(Long id) {
        return em.find(User.class, id);
    }
    
    public List<User> findByAge(int minAge) {
        return em.createQuery(
            "SELECT u FROM User u WHERE u.age > :minAge",
            User.class
        )
        .setParameter("minAge", minAge)
        .getResultList();
    }
}
```

### JDBC (PreparedStatement)
```java
// ✅ ALWAYS use PreparedStatement
String sql = "SELECT * FROM users WHERE email = ? AND status = ?";
try (PreparedStatement stmt = conn.prepareStatement(sql)) {
    stmt.setString(1, email);
    stmt.setString(2, status);
    
    ResultSet rs = stmt.executeQuery();
    while (rs.next()) {
        // Process results
    }
}

// ❌ NEVER string concatenation
String badQuery = "SELECT * FROM users WHERE email = '" + email + "'"; // SQL INJECTION!
```

---

## C#

### Entity Framework Core
```csharp
var user = await _context.Users
    .Include(u => u.Posts)
    .FirstOrDefaultAsync(u => u.Id == userId);

var users = await _context.Users
    .Where(u => u.Age > minAge && u.Status == status)
    .ToListAsync();

// Insert
var newUser = new User { Email = "user@example.com", Name = "John Doe" };
_context.Users.Add(newUser);
await _context.SaveChangesAsync();

// Raw SQL (parameterized)
var users = await _context.Users
    .FromSqlRaw(
        "SELECT * FROM Users WHERE Age > {0} AND Status = {1}",
        minAge, status
    )
    .ToListAsync();
```

### Dapper (Micro ORM)
```csharp
using Dapper;

using (var connection = new SqlConnection(connectionString))
{
    var user = await connection.QueryFirstOrDefaultAsync<User>(
        "SELECT * FROM Users WHERE Email = @Email",
        new { Email = email }
    );
    
    var users = await connection.QueryAsync<User>(
        "SELECT * FROM Users WHERE Age > @MinAge AND Status = @Status",
        new { MinAge = minAge, Status = status }
    );
}
```

### ADO.NET (Plain)
```csharp
using (var connection = new SqlConnection(connectionString))
using (var command = new SqlCommand())
{
    command.Connection = connection;
    command.CommandText = "SELECT * FROM Users WHERE Email = @Email AND Status = @Status";
    command.Parameters.AddWithValue("@Email", email);
    command.Parameters.AddWithValue("@Status", status);
    
    await connection.OpenAsync();
    using var reader = await command.ExecuteReaderAsync();
    
    while (await reader.ReadAsync())
    {
        // Process results
    }
}
```

---

## PHP

### Laravel Eloquent
```php
$user = User::where('email', $email)->first();
$users = User::where('age', '>', $minAge)
    ->where('status', $status)
    ->get();

// Insert
$user = User::create([
    'email' => 'user@example.com',
    'name' => 'John Doe',
]);

// Raw query (parameterized)
$users = DB::select(
    'SELECT * FROM users WHERE age > ? AND status = ?',
    [$minAge, $status]
);

// Query builder
$users = DB::table('users')
    ->where('age', '>', $minAge)
    ->where('status', $status)
    ->get();
```

### Doctrine ORM
```php
$user = $entityManager->find(User::class, $userId);

$users = $entityManager->createQuery(
    'SELECT u FROM App\Entity\User u WHERE u.age > :age AND u.status = :status'
)
->setParameter('age', $minAge)
->setParameter('status', $status)
->getResult();

// Insert
$user = new User();
$user->setEmail('user@example.com');
$user->setName('John Doe');

$entityManager->persist($user);
$entityManager->flush();
```

### PDO (Plain PHP)
```php
// ✅ ALWAYS prepared statements
$stmt = $pdo->prepare('SELECT * FROM users WHERE email = :email AND status = :status');
$stmt->execute(['email' => $email, 'status' => $status]);
$users = $stmt->fetchAll(PDO::FETCH_ASSOC);

// Insert
$stmt = $pdo->prepare('INSERT INTO users (email, name) VALUES (:email, :name)');
$stmt->execute(['email' => $email, 'name' => $name]);
$userId = $pdo->lastInsertId();

// ❌ NEVER string concatenation
$badQuery = "SELECT * FROM users WHERE email = '$email'"; // SQL INJECTION!
```

---

## Kotlin

### Exposed (SQL DSL)
```kotlin
import org.jetbrains.exposed.sql.*

object Users : Table() {
    val id = integer("id").autoIncrement()
    val email = varchar("email", 255)
    val name = varchar("name", 100)
    override val primaryKey = PrimaryKey(id)
}

val user = transaction {
    Users.select { Users.id eq userId }.singleOrNull()
}

val users = transaction {
    Users.select {
        (Users.age greater minAge) and (Users.status eq status)
    }.toList()
}

// Insert
val userId = transaction {
    Users.insert {
        it[email] = "user@example.com"
        it[name] = "John Doe"
    } get Users.id
}
```

### Room (Android)
```kotlin
@Dao
interface UserDao {
    @Query("SELECT * FROM users WHERE id = :userId")
    suspend fun getUserById(userId: Int): User?
    
    @Query("SELECT * FROM users WHERE age > :minAge AND status = :status")
    suspend fun getUsersByAgeAndStatus(minAge: Int, status: String): List<User>
    
    @Insert
    suspend fun insert(user: User): Long
}

// Usage
val user = userDao.getUserById(123)
```

---

## Swift

### CoreData (Apple Platforms)
```swift
import CoreData

let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
fetchRequest.predicate = NSPredicate(
    format: "email == %@ AND status == %@",
    email, status
)

do {
    let users = try context.fetch(fetchRequest)
} catch {
    print("Fetch failed: \(error)")
}

// Insert
let newUser = User(context: context)
newUser.email = "user@example.com"
newUser.name = "John Doe"
try? context.save()
```

### SQLite.swift
```swift
import SQLite

let db = try Connection("path/to/db.sqlite3")
let users = Table("users")
let id = Expression<Int64>("id")
let email = Expression<String>("email")
let age = Expression<Int>("age")

// Query (parameterized)
for user in try db.prepare(users.filter(age > minAge && status == statusValue)) {
    print("User: \(user[email])")
}

// Insert
let insert = users.insert(
    email <- "user@example.com",
    name <- "John Doe"
)
let rowId = try db.run(insert)

// Raw query (parameterized)
let stmt = try db.prepare("SELECT * FROM users WHERE email = ? AND status = ?")
for row in try stmt.bind(email, status) {
    // Process row
}
```

---

## Dart

### Drift (Type-safe SQLite)
```dart
import 'package:drift/drift.dart';

@DriftDatabase(tables: [Users])
class AppDatabase extends _$AppDatabase {
  Future<User?> getUserById(int id) {
    return (select(users)..where((u) => u.id.equals(id))).getSingleOrNull();
  }
  
  Future<List<User>> getUsersOlderThan(int minAge) {
    return (select(users)
      ..where((u) => u.age.isBiggerThanValue(minAge))
      ..where((u) => u.status.equals('active')))
    .get();
  }
  
  Future<int> insertUser(UsersCompanion user) {
    return into(users).insert(user);
  }
}
```

### sqflite (Plain SQLite)
```dart
import 'package:sqflite/sqflite.dart';

final db = await openDatabase('users.db');

// Query (parameterized)
final List<Map<String, dynamic>> maps = await db.query(
  'users',
  where: 'email = ? AND status = ?',
  whereArgs: [email, status],
);

final users = maps.map((map) => User.fromMap(map)).toList();

// Insert
final id = await db.insert(
  'users',
  {
    'email': 'user@example.com',
    'name': 'John Doe',
  },
  conflictAlgorithm: ConflictAlgorithm.replace,
);

// ❌ NEVER string concatenation
final badQuery = "SELECT * FROM users WHERE email = '$email'"; // SQL INJECTION!
```

---

## Transaction Examples

```typescript
// TypeScript (Prisma)
await prisma.$transaction(async (tx) => {
  const user = await tx.user.create({ data: userData });
  await tx.account.create({ data: { userId: user.id } });
});
```

```python
# Python (SQLAlchemy)
with session.begin():
    user = User(**user_data)
    session.add(user)
    account = Account(user_id=user.id)
    session.add(account)
```

```java
// Java (Spring)
@Transactional
public User createUserWithAccount(UserData data) {
    User user = userRepository.save(new User(data));
    accountRepository.save(new Account(user.getId()));
    return user;
}
```

```csharp
// C# (EF Core)
using var transaction = await _context.Database.BeginTransactionAsync();
try {
    var user = new User { ... };
    _context.Users.Add(user);
    await _context.SaveChangesAsync();
    
    var account = new Account { UserId = user.Id };
    _context.Accounts.Add(account);
    await _context.SaveChangesAsync();
    
    await transaction.CommitAsync();
} catch {
    await transaction.RollbackAsync();
    throw;
}
```

---

## Quick Rules

✅ Use parameterized queries ALWAYS
✅ Use ORM for type safety
✅ Close connections properly
✅ Use connection pooling
✅ Use transactions for multi-step operations
✅ Index frequently queried columns

❌ Concatenate user input into queries
❌ Use SELECT * in production
❌ Query in loops (N+1 problem)
❌ Leave connections open
❌ Expose database schema in errors
