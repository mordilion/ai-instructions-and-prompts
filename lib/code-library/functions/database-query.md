---
title: Database Query Patterns
category: Data Access
difficulty: intermediate
purpose: Safely query and manipulate data with proper ORM usage, parameterization, and SQL injection prevention
when_to_use:
  - CRUD operations
  - Complex queries with joins
  - Pagination
  - Transactions
  - Data migrations
  - Raw SQL queries
languages:
  typescript:
    - name: Prisma
      library: "@prisma/client"
      recommended: true
    - name: TypeORM
      library: typeorm
    - name: Knex.js
      library: knex
    - name: pg (PostgreSQL)
      library: pg
    - name: AdonisJS Lucid ORM
      library: "@adonisjs/lucid"
    - name: NestJS (TypeORM)
      library: "@nestjs/typeorm"
  python:
    - name: SQLAlchemy
      library: sqlalchemy
      recommended: true
    - name: Django ORM
      library: django
    - name: asyncpg
      library: asyncpg
  java:
    - name: Spring Data JPA
      library: org.springframework.boot:spring-boot-starter-data-jpa
      recommended: true
    - name: Hibernate
      library: org.hibernate:hibernate-core
    - name: JDBC
      library: java.sql (built-in)
  csharp:
    - name: Entity Framework Core
      library: Microsoft.EntityFrameworkCore
      recommended: true
    - name: Dapper
      library: Dapper
    - name: ADO.NET
      library: System.Data.SqlClient (built-in)
  php:
    - name: Laravel Eloquent
      library: laravel/framework
      recommended: true
    - name: Doctrine
      library: doctrine/orm
    - name: Symfony + Doctrine
      library: symfony/framework-bundle
    - name: PDO
      library: PDO (built-in)
    - name: WordPress $wpdb
      library: wordpress
    - name: Laminas Db Adapter
      library: laminas/laminas-db
  kotlin:
    - name: Exposed
      library: org.jetbrains.exposed:exposed-core
      recommended: true
    - name: Room (Android)
      library: androidx.room:room-runtime
  swift:
    - name: CoreData
      library: CoreData (built-in)
      recommended: true
    - name: Vapor Fluent ORM
      library: vapor/fluent
  dart:
    - name: Drift
      library: drift
      recommended: true
    - name: sqflite
      library: sqflite
security_rules:
  - Always use parameterized queries or ORM methods
  - Never concatenate user input into SQL strings
  - Escape special characters if raw SQL is required
  - Use prepared statements for JDBC/PDO
  - Validate input before querying
  - Use least privilege database accounts
best_practices:
  do:
    - Use ORM methods for type safety
    - Paginate large result sets
    - Use transactions for multi-step operations
    - Index frequently queried columns
    - Use connection pooling
    - Log slow queries
  dont:
    - Use `SELECT *` in production
    - Fetch entire tables without limits
    - Store sensitive data in plain text
    - Leave transactions open indefinitely
    - Use string concatenation for queries
related_functions:
  - input-validation.md
  - error-handling.md
  - async-operations.md
tags: [database, sql, orm, queries, transactions, sql-injection]
updated: 2026-01-09
---

## TypeScript

### Prisma - Basic CRUD
```typescript
import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();

const user = await prisma.user.create({
  data: {
    email: 'user@example.com',
    name: 'John Doe',
  },
});

const users = await prisma.user.findMany({
  where: { active: true },
  orderBy: { createdAt: 'desc' },
  take: 10,
  skip: 0,
});

const user = await prisma.user.findUnique({
  where: { id: userId },
  include: { posts: true },
});

await prisma.user.update({
  where: { id: userId },
  data: { name: 'Jane Doe' },
});

await prisma.user.delete({
  where: { id: userId },
});
```

### Prisma - Transactions
```typescript
await prisma.$transaction(async (tx) => {
  const user = await tx.user.create({ data: { email, name } });
  await tx.profile.create({ data: { userId: user.id, bio } });
  return user;
});
```

### TypeORM - Basic CRUD
```typescript
import { getRepository } from 'typeorm';

const userRepo = getRepository(User);

const user = await userRepo.save({ email, name });

const users = await userRepo.find({
  where: { active: true },
  order: { createdAt: 'DESC' },
  take: 10,
  skip: 0,
});

const user = await userRepo.findOne({
  where: { id: userId },
  relations: ['posts'],
});

await userRepo.update(userId, { name: 'Jane Doe' });
await userRepo.delete(userId);
```

### Knex.js - Query Builder
```typescript
import knex from 'knex';
const db = knex({ client: 'pg', connection: connectionString });

await db('users').insert({ email, name });

const users = await db('users')
  .where({ active: true })
  .orderBy('created_at', 'desc')
  .limit(10)
  .offset(0);

await db('users').where({ id: userId }).update({ name: 'Jane Doe' });
await db('users').where({ id: userId }).del();
```

### pg - Raw SQL (PostgreSQL)
```typescript
import { Pool } from 'pg';
const pool = new Pool({ connectionString });

const result = await pool.query(
  'SELECT * FROM users WHERE email = $1',
  [email]
);
const user = result.rows[0];

await pool.query(
  'INSERT INTO users (email, name) VALUES ($1, $2)',
  [email, name]
);
```

### NestJS (TypeORM)
```typescript
import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';

@Injectable()
export class UsersRepo {
  constructor(@InjectRepository(User) private readonly repo: Repository<User>) {}

  findActive() {
    return this.repo.find({ where: { active: true }, take: 10 });
  }
}
```

### AdonisJS Lucid ORM
```typescript
import User from '#models/user';

const user = await User.findOrFail(userId);
const users = await User.query().where('active', true).orderBy('createdAt', 'desc').limit(10);
```

---

## Python

### SQLAlchemy - Basic CRUD
```python
from sqlalchemy import create_engine, select
from sqlalchemy.orm import sessionmaker

engine = create_engine(database_url)
Session = sessionmaker(bind=engine)
session = Session()

user = User(email=email, name=name)
session.add(user)
session.commit()

users = session.query(User).filter(User.active == True).order_by(User.created_at.desc()).limit(10).all()

user = session.query(User).filter(User.id == user_id).first()

user.name = 'Jane Doe'
session.commit()

session.delete(user)
session.commit()
```

### SQLAlchemy - Transactions
```python
from sqlalchemy.orm import Session

with Session(engine) as session:
    with session.begin():
        user = User(email=email, name=name)
        session.add(user)
        profile = Profile(user_id=user.id, bio=bio)
        session.add(profile)
```

### Django ORM
```python
from myapp.models import User

user = User.objects.create(email=email, name=name)

users = User.objects.filter(active=True).order_by('-created_at')[:10]

user = User.objects.get(id=user_id)
user = User.objects.select_related('profile').get(id=user_id)

User.objects.filter(id=user_id).update(name='Jane Doe')

User.objects.filter(id=user_id).delete()
```

### asyncpg - Async PostgreSQL
```python
import asyncpg

conn = await asyncpg.connect(database_url)

await conn.execute(
    'INSERT INTO users (email, name) VALUES ($1, $2)',
    email, name
)

users = await conn.fetch(
    'SELECT * FROM users WHERE active = $1 ORDER BY created_at DESC LIMIT 10',
    True
)

await conn.close()
```

---

## Java

### Spring Data JPA - Repository
```java
public interface UserRepository extends JpaRepository<User, Long> {
    List<User> findByActiveTrue();
    
    @Query("SELECT u FROM User u WHERE u.email = :email")
    Optional<User> findByEmail(@Param("email") String email);
}

@Service
public class UserService {
    @Autowired
    private UserRepository userRepository;
    
    public User createUser(String email, String name) {
        User user = new User(email, name);
        return userRepository.save(user);
    }
    
    public List<User> getActiveUsers() {
        return userRepository.findByActiveTrue();
    }
}
```

### Spring Data JPA - Transactions
```java
@Transactional
public User createUserWithProfile(String email, String name, String bio) {
    User user = new User(email, name);
    userRepository.save(user);
    
    Profile profile = new Profile(user.getId(), bio);
    profileRepository.save(profile);
    
    return user;
}
```

### Hibernate - EntityManager
```java
EntityManagerFactory emf = Persistence.createEntityManagerFactory("my-pu");
EntityManager em = emf.createEntityManager();

em.getTransaction().begin();
User user = new User(email, name);
em.persist(user);
em.getTransaction().commit();

TypedQuery<User> query = em.createQuery(
    "SELECT u FROM User u WHERE u.active = :active", User.class);
query.setParameter("active", true);
List<User> users = query.getResultList();

em.close();
```

### JDBC - Raw SQL
```java
String sql = "SELECT * FROM users WHERE email = ?";
try (PreparedStatement stmt = connection.prepareStatement(sql)) {
    stmt.setString(1, email);
    ResultSet rs = stmt.executeQuery();
    
    while (rs.next()) {
        String name = rs.getString("name");
        System.out.println(name);
    }
}
```

---

## C#

### Entity Framework Core - DbContext
```csharp
public class AppDbContext : DbContext
{
    public DbSet<User> Users { get; set; }
}

await using var db = new AppDbContext();

var user = new User { Email = email, Name = name };
db.Users.Add(user);
await db.SaveChangesAsync();

var users = await db.Users
    .Where(u => u.Active)
    .OrderByDescending(u => u.CreatedAt)
    .Take(10)
    .ToListAsync();

var user = await db.Users
    .Include(u => u.Posts)
    .FirstOrDefaultAsync(u => u.Id == userId);

user.Name = "Jane Doe";
await db.SaveChangesAsync();

db.Users.Remove(user);
await db.SaveChangesAsync();
```

### EF Core - Transactions
```csharp
using var transaction = await db.Database.BeginTransactionAsync();
try
{
    var user = new User { Email = email, Name = name };
    db.Users.Add(user);
    await db.SaveChangesAsync();
    
    var profile = new Profile { UserId = user.Id, Bio = bio };
    db.Profiles.Add(profile);
    await db.SaveChangesAsync();
    
    await transaction.CommitAsync();
}
catch
{
    await transaction.RollbackAsync();
    throw;
}
```

### Dapper - Micro ORM
```csharp
using Dapper;

var user = await connection.QueryFirstOrDefaultAsync<User>(
    "SELECT * FROM users WHERE email = @Email",
    new { Email = email }
);

var users = await connection.QueryAsync<User>(
    "SELECT * FROM users WHERE active = @Active ORDER BY created_at DESC LIMIT 10",
    new { Active = true }
);

await connection.ExecuteAsync(
    "INSERT INTO users (email, name) VALUES (@Email, @Name)",
    new { Email = email, Name = name }
);
```

### ADO.NET - Raw SQL
```csharp
using var connection = new SqlConnection(connectionString);
await connection.OpenAsync();

using var command = new SqlCommand(
    "SELECT * FROM users WHERE email = @Email", connection);
command.Parameters.AddWithValue("@Email", email);

using var reader = await command.ExecuteReaderAsync();
while (await reader.ReadAsync())
{
    var name = reader.GetString(reader.GetOrdinal("name"));
}
```

---

## PHP

### Laravel Eloquent
```php
use App\Models\User;

$user = User::create([
    'email' => $email,
    'name' => $name,
]);

$users = User::where('active', true)
    ->orderBy('created_at', 'desc')
    ->limit(10)
    ->get();

$user = User::with('posts')->find($userId);

User::where('id', $userId)->update(['name' => 'Jane Doe']);

User::destroy($userId);
```

### Laravel - Transactions
```php
DB::transaction(function () use ($email, $name, $bio) {
    $user = User::create(['email' => $email, 'name' => $name]);
    
    Profile::create([
        'user_id' => $user->id,
        'bio' => $bio,
    ]);
});
```

### Doctrine ORM
```php
use Doctrine\ORM\EntityManager;

$user = new User();
$user->setEmail($email);
$user->setName($name);

$entityManager->persist($user);
$entityManager->flush();

$users = $entityManager->getRepository(User::class)
    ->findBy(['active' => true], ['createdAt' => 'DESC'], 10);

$user = $entityManager->find(User::class, $userId);

$user->setName('Jane Doe');
$entityManager->flush();

$entityManager->remove($user);
$entityManager->flush();
```

### Symfony + Doctrine
```php
<?php

use Doctrine\Persistence\ManagerRegistry;

$em = $doctrine->getManager();
$user = $em->getRepository(User::class)->find($userId);
```

### PDO - Raw SQL
```php
$pdo = new PDO($dsn, $username, $password);

$stmt = $pdo->prepare('SELECT * FROM users WHERE email = :email');
$stmt->execute(['email' => $email]);
$user = $stmt->fetch(PDO::FETCH_ASSOC);

$stmt = $pdo->prepare('INSERT INTO users (email, name) VALUES (:email, :name)');
$stmt->execute(['email' => $email, 'name' => $name]);
```

### Laminas Db Adapter
```php
<?php

use Laminas\Db\Adapter\Adapter;

$db = new Adapter(['driver' => 'Pdo_Pgsql', 'dsn' => $dsn, 'username' => $username, 'password' => $password]);
$result = $db->query('SELECT * FROM users WHERE email = ?', [$email]);
```

### WordPress $wpdb
```php
<?php

global $wpdb;
$table = $wpdb->prefix . 'users';

$user = $wpdb->get_row(
  $wpdb->prepare("SELECT * FROM {$table} WHERE email = %s", $email),
  ARRAY_A
);
```

---

## Kotlin

### Exposed - DSL
```kotlin
import org.jetbrains.exposed.sql.*
import org.jetbrains.exposed.sql.transactions.transaction

object Users : Table() {
    val id = integer("id").autoIncrement()
    val email = varchar("email", 255)
    val name = varchar("name", 100)
    override val primaryKey = PrimaryKey(id)
}

transaction {
    Users.insert {
        it[email] = userEmail
        it[name] = userName
    }
    
    val users = Users.selectAll()
        .where { Users.active eq true }
        .orderBy(Users.createdAt to SortOrder.DESC)
        .limit(10)
        .toList()
    
    Users.update({ Users.id eq userId }) {
        it[name] = "Jane Doe"
    }
    
    Users.deleteWhere { Users.id eq userId }
}
```

### Room (Android)
```kotlin
@Dao
interface UserDao {
    @Query("SELECT * FROM users WHERE active = 1 ORDER BY created_at DESC LIMIT 10")
    suspend fun getActiveUsers(): List<User>
    
    @Query("SELECT * FROM users WHERE id = :userId")
    suspend fun getUserById(userId: Int): User?
    
    @Insert
    suspend fun insert(user: User): Long
    
    @Update
    suspend fun update(user: User)
    
    @Delete
    suspend fun delete(user: User)
}

val users = userDao.getActiveUsers()
val userId = userDao.insert(user)
```

---

## Swift

### CoreData
```swift
import CoreData

let context = persistentContainer.viewContext

let user = User(context: context)
user.email = email
user.name = name

try? context.save()

let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
fetchRequest.predicate = NSPredicate(format: "active == %@", NSNumber(value: true))
fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
fetchRequest.fetchLimit = 10

let users = try? context.fetch(fetchRequest)

if let user = users?.first {
    user.name = "Jane Doe"
    try? context.save()
}

context.delete(user)
try? context.save()
```

### CoreData - Transactions
```swift
context.performAndWait {
    let user = User(context: context)
    user.email = email
    user.name = name
    
    let profile = Profile(context: context)
    profile.user = user
    profile.bio = bio
    
    try? context.save()
}
```

### Vapor Fluent ORM
```swift
import Fluent

final class User: Model {
  static let schema = "users"
  @ID var id: UUID?
  @Field(key: "email") var email: String
  init() {}
}

let users = try await User.query(on: db).filter(\.$email == email).all()
```

---

## Dart

### Drift (formerly Moor)
```dart
import 'package:drift/drift.dart';

@DriftDatabase(tables: [Users])
class MyDatabase extends _$MyDatabase {
  MyDatabase() : super(_openConnection());

  Future<int> insertUser(UsersCompanion user) {
    return into(users).insert(user);
  }

  Future<List<User>> getActiveUsers() {
    return (select(users)
          ..where((u) => u.active.equals(true))
          ..orderBy([(u) => OrderingTerm.desc(u.createdAt)])
          ..limit(10))
        .get();
  }

  Future<User?> getUserById(int id) {
    return (select(users)..where((u) => u.id.equals(id)))
        .getSingleOrNull();
  }

  Future<int> updateUser(UsersCompanion user) {
    return update(users).replace(user);
  }

  Future<int> deleteUser(int id) {
    return (delete(users)..where((u) => u.id.equals(id))).go();
  }
}
```

### Drift - Transactions
```dart
await database.transaction(() async {
  final userId = await database.insertUser(user);
  await database.insertProfile(Profile(userId: userId, bio: bio));
});
```

### sqflite
```dart
import 'package:sqflite/sqflite.dart';

final db = await openDatabase('my_db.db');

await db.insert('users', {'email': email, 'name': name});

final users = await db.query(
  'users',
  where: 'active = ?',
  whereArgs: [1],
  orderBy: 'created_at DESC',
  limit: 10,
);

await db.update(
  'users',
  {'name': 'Jane Doe'},
  where: 'id = ?',
  whereArgs: [userId],
);

await db.delete('users', where: 'id = ?', whereArgs: [userId]);
```
