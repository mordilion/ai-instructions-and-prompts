# Database Query Patterns

> **Purpose**: Safe database queries that prevent SQL injection and ensure data integrity
>
> **When to use**: Any database interaction - SELECT, INSERT, UPDATE, DELETE

---

## TypeScript / JavaScript

```typescript
// Prisma (Type-safe ORM)
const user = await prisma.user.findUnique({
  where: { id: userId },
  include: { posts: true }
});

const newUser = await prisma.user.create({
  data: {
    email: 'user@example.com',
    name: 'John Doe',
    posts: {
      create: [{ title: 'First Post', content: '...' }]
    }
  }
});

// TypeORM
const user = await userRepository.findOne({
  where: { id: userId },
  relations: ['posts']
});

// Raw query with parameterization
const users = await prisma.$queryRaw`
  SELECT * FROM users
  WHERE age > ${minAge}
  AND status = ${status}
`;

// ❌ NEVER DO THIS (SQL Injection)
const query = `SELECT * FROM users WHERE email = '${email}'`;

// ✅ ALWAYS DO THIS
const query = 'SELECT * FROM users WHERE email = $1';
const users = await db.query(query, [email]);
```

---

## Python

```python
# SQLAlchemy (ORM)
from sqlalchemy import select

user = session.query(User).filter_by(id=user_id).first()

# Or with select
stmt = select(User).where(User.id == user_id)
user = session.execute(stmt).scalar_one()

# Insert
new_user = User(email='user@example.com', name='John Doe')
session.add(new_user)
session.commit()

# Raw query with parameters
from sqlalchemy import text

stmt = text("SELECT * FROM users WHERE age > :age AND status = :status")
users = session.execute(stmt, {"age": min_age, "status": status}).all()

# Django ORM
user = User.objects.get(id=user_id)
users = User.objects.filter(age__gt=min_age, status=status)

# ❌ NEVER DO THIS (SQL Injection)
query = f"SELECT * FROM users WHERE email = '{email}'"

# ✅ ALWAYS DO THIS
User.objects.raw("SELECT * FROM users WHERE email = %s", [email])
```

---

## Java

```java
// JPA/Hibernate
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

// JDBC with PreparedStatement
String sql = "SELECT * FROM users WHERE email = ? AND status = ?";
try (PreparedStatement stmt = conn.prepareStatement(sql)) {
    stmt.setString(1, email);
    stmt.setString(2, status);
    ResultSet rs = stmt.executeQuery();
    while (rs.next()) {
        // Process results
    }
}

// Spring Data JPA
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmail(String email);
    List<User> findByAgeGreaterThan(int age);
    
    @Query("SELECT u FROM User u WHERE u.status = :status")
    List<User> findByStatus(@Param("status") String status);
}

// ❌ NEVER DO THIS
String query = "SELECT * FROM users WHERE email = '" + email + "'";
Statement stmt = conn.createStatement();
ResultSet rs = stmt.executeQuery(query);
```

---

## C# (.NET)

```csharp
// Entity Framework Core
var user = await _context.Users
    .Include(u => u.Posts)
    .FirstOrDefaultAsync(u => u.Id == userId);

var users = await _context.Users
    .Where(u => u.Age > minAge && u.Status == status)
    .ToListAsync();

// Insert
var newUser = new User {
    Email = "user@example.com",
    Name = "John Doe"
};
_context.Users.Add(newUser);
await _context.SaveChangesAsync();

// Raw SQL with parameters
var users = await _context.Users
    .FromSqlRaw(
        "SELECT * FROM Users WHERE Age > {0} AND Status = {1}",
        minAge,
        status
    )
    .ToListAsync();

// Dapper
using (var connection = new SqlConnection(connectionString))
{
    var user = await connection.QueryFirstOrDefaultAsync<User>(
        "SELECT * FROM Users WHERE Email = @Email",
        new { Email = email }
    );
    
    var users = await connection.QueryAsync<User>(
        "SELECT * FROM Users WHERE Age > @MinAge",
        new { MinAge = minAge }
    );
}

// ❌ NEVER DO THIS
var query = $"SELECT * FROM Users WHERE Email = '{email}'";
```

---

## PHP

```php
// PDO with prepared statements
$stmt = $pdo->prepare('SELECT * FROM users WHERE email = :email AND status = :status');
$stmt->execute(['email' => $email, 'status' => $status]);
$users = $stmt->fetchAll(PDO::FETCH_ASSOC);

// Insert
$stmt = $pdo->prepare('INSERT INTO users (email, name) VALUES (:email, :name)');
$stmt->execute([
    'email' => $email,
    'name' => $name
]);
$userId = $pdo->lastInsertId();

// Laravel Eloquent
$user = User::where('email', $email)->first();
$users = User::where('age', '>', $minAge)
    ->where('status', $status)
    ->get();

// Query Builder
$users = DB::table('users')
    ->where('age', '>', $minAge)
    ->where('status', $status)
    ->get();

// Raw with bindings
$users = DB::select('SELECT * FROM users WHERE age > ? AND status = ?', [$minAge, $status]);

// ❌ NEVER DO THIS
$query = "SELECT * FROM users WHERE email = '$email'";
$result = mysqli_query($conn, $query);
```

---

## Kotlin

```kotlin
// Exposed (SQL DSL)
val user = Users.select { Users.id eq userId }.singleOrNull()

val users = Users.select {
    (Users.age greater minAge) and (Users.status eq status)
}.toList()

// Insert
val userId = Users.insert {
    it[email] = "user@example.com"
    it[name] = "John Doe"
} get Users.id

// Room (Android)
@Dao
interface UserDao {
    @Query("SELECT * FROM users WHERE id = :userId")
    suspend fun getUserById(userId: Int): User?
    
    @Query("SELECT * FROM users WHERE age > :minAge")
    suspend fun getUsersOlderThan(minAge: Int): List<User>
    
    @Insert
    suspend fun insert(user: User): Long
}

// Usage
val user = userDao.getUserById(123)
val users = userDao.getUsersOlderThan(18)

// ❌ NEVER DO THIS
val query = "SELECT * FROM users WHERE email = '$email'"
```

---

## Swift

```swift
// CoreData
let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
fetchRequest.predicate = NSPredicate(format: "email == %@", email)

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

// SQLite.swift
let users = Table("users")
let id = Expression<Int64>("id")
let email = Expression<String>("email")
let age = Expression<Int>("age")

for user in try db.prepare(users.filter(age > minAge)) {
    print("User: \(user[email])")
}

// Insert
let insert = users.insert(
    email <- "user@example.com",
    name <- "John Doe"
)
let rowId = try db.run(insert)

// Raw query with bindings
let stmt = try db.prepare("SELECT * FROM users WHERE email = ?")
for row in try stmt.bind(email) {
    // Process row
}

// ❌ NEVER DO THIS
let query = "SELECT * FROM users WHERE email = '\(email)'"
```

---

## Dart (Flutter)

```dart
// sqflite (SQLite)
final db = await openDatabase('users.db');

// Query
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

// Update
await db.update(
  'users',
  {'status': 'active'},
  where: 'id = ?',
  whereArgs: [userId],
);

// Raw query with parameters
final users = await db.rawQuery(
  'SELECT * FROM users WHERE age > ? AND status = ?',
  [minAge, status],
);

// Moor/Drift (Type-safe)
@DriftDatabase(tables: [Users])
class AppDatabase extends _$AppDatabase {
  Future<User?> getUserById(int id) {
    return (select(users)..where((u) => u.id.equals(id))).getSingleOrNull();
  }
  
  Future<List<User>> getUsersOlderThan(int minAge) {
    return (select(users)..where((u) => u.age.isBiggerThanValue(minAge))).get();
  }
}

// ❌ NEVER DO THIS
final query = "SELECT * FROM users WHERE email = '$email'";
await db.rawQuery(query);
```

---

## Best Practices

✅ **DO**:
- Use parameterized queries ALWAYS
- Use ORM for type safety
- Close connections properly
- Use connection pooling
- Handle errors gracefully
- Use transactions for multi-step operations
- Index frequently queried columns

❌ **DON'T**:
- Concatenate user input into queries
- Trust client-provided SQL
- Leave connections open
- Use SELECT * in production
- Ignore connection limits
- Query in loops (N+1 problem)

---

## Security Checklist

- [ ] All queries use parameters/bindings
- [ ] No string concatenation with user input
- [ ] ORM escapes input automatically
- [ ] Least privilege database user
- [ ] Prepared statements for all queries
- [ ] Input validated before queries
- [ ] Error messages don't expose schema
- [ ] Connection strings secured (not in code)

---

## Performance Tips

```typescript
// ❌ N+1 Problem
for (const user of users) {
  const posts = await fetchPosts(user.id); // Queries in loop!
}

// ✅ Eager Loading
const users = await prisma.user.findMany({
  include: { posts: true } // Single query with JOIN
});

// ✅ Batch Loading
const userIds = users.map(u => u.id);
const posts = await prisma.post.findMany({
  where: { userId: { in: userIds } }
});
```

---

## Transaction Example

```typescript
// TypeScript (Prisma)
await prisma.$transaction(async (tx) => {
  const user = await tx.user.create({ data: userData });
  await tx.account.create({ data: { userId: user.id } });
  return user;
});

// Python (SQLAlchemy)
with session.begin():
    user = User(**user_data)
    session.add(user)
    account = Account(user_id=user.id)
    session.add(account)

// Java (Spring)
@Transactional
public User createUserWithAccount(UserData data) {
    User user = userRepository.save(new User(data));
    accountRepository.save(new Account(user.getId()));
    return user;
}
```
