# Dapper Micro ORM

> **Scope**: Apply these rules when using Dapper for database access in .NET.

## 1. Connection Factory
```csharp
public class DapperContext
{
    private readonly string _connectionString;
    public DapperContext(IConfiguration config) => _connectionString = config.GetConnectionString("Default")!;
    public IDbConnection CreateConnection() => new SqlConnection(_connectionString);
}
```

## 2. Repository Pattern
```csharp
public class UserRepository : IUserRepository
{
    private readonly DapperContext _context;
    public UserRepository(DapperContext context) => _context = context;

    public async Task<User?> GetByIdAsync(int id)
    {
        using var conn = _context.CreateConnection();
        return await conn.QuerySingleOrDefaultAsync<User>(
            "SELECT Id, Email, Name FROM Users WHERE Id = @Id", new { Id = id });
    }

    public async Task<IEnumerable<User>> GetAllAsync()
    {
        using var conn = _context.CreateConnection();
        return await conn.QueryAsync<User>("SELECT Id, Email, Name FROM Users");
    }

    public async Task<int> CreateAsync(User user)
    {
        using var conn = _context.CreateConnection();
        return await conn.ExecuteScalarAsync<int>(
            "INSERT INTO Users (Email, Name) VALUES (@Email, @Name); SELECT SCOPE_IDENTITY()", user);
    }
}
```

## 3. Complex Queries (Joins)
```csharp
public async Task<User?> GetUserWithPostsAsync(int userId)
{
    using var conn = _context.CreateConnection();
    var userDict = new Dictionary<int, User>();
    
    await conn.QueryAsync<User, Post, User>(
        "SELECT u.*, p.* FROM Users u LEFT JOIN Posts p ON u.Id = p.AuthorId WHERE u.Id = @Id",
        (user, post) => {
            if (!userDict.TryGetValue(user.Id, out var u)) { u = user; u.Posts = new(); userDict[user.Id] = u; }
            if (post != null) u.Posts.Add(post);
            return u;
        }, new { Id = userId }, splitOn: "Id");
    
    return userDict.Values.FirstOrDefault();
}
```

## 4. Transactions
```csharp
using var conn = _context.CreateConnection();
conn.Open();
using var tx = conn.BeginTransaction();
try {
    await conn.ExecuteAsync("UPDATE Accounts SET Balance = Balance - @Amount WHERE Id = @Id", new { Amount, Id = fromId }, tx);
    await conn.ExecuteAsync("UPDATE Accounts SET Balance = Balance + @Amount WHERE Id = @Id", new { Amount, Id = toId }, tx);
    tx.Commit();
} catch { tx.Rollback(); throw; }
```

## 5. Stored Procedures
```csharp
var users = await conn.QueryAsync<User>("sp_GetActiveUsers", new { DaysActive = 30 }, commandType: CommandType.StoredProcedure);
```

## 6. Best Practices
- **Parameterized Queries**: Always use parameters (SQL injection prevention)
- **Using Statements**: Always dispose connections
- **Async**: Use async methods for all DB operations
- **Mapping**: Use conventions or `[Column]` for custom mapping
