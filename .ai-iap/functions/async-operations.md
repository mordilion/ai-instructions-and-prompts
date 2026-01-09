# Async Operations Patterns

> **Purpose**: Handle asynchronous operations consistently
>
> **When to use**: API calls, database queries, file I/O, any operation that takes time

---

## TypeScript / JavaScript

```typescript
// Basic async/await
async function fetchUser(id: string): Promise<User> {
  const response = await fetch(`/api/users/${id}`);
  if (!response.ok) throw new Error('User not found');
  return response.json();
}

// Parallel execution
const [users, posts, comments] = await Promise.all([
  fetchUsers(),
  fetchPosts(),
  fetchComments()
]);

// Sequential with error handling
try {
  const user = await fetchUser(id);
  const profile = await fetchProfile(user.profileId);
  return { user, profile };
} catch (error) {
  logger.error('Failed to fetch data', error);
  throw error;
}

// Timeout wrapper
function withTimeout<T>(promise: Promise<T>, ms: number): Promise<T> {
  return Promise.race([
    promise,
    new Promise<T>((_, reject) =>
      setTimeout(() => reject(new Error('Timeout')), ms)
    )
  ]);
}
```

---

## Python

```python
import asyncio

# Basic async/await
async def fetch_user(user_id: str) -> User:
    async with aiohttp.ClientSession() as session:
        async with session.get(f'/api/users/{user_id}') as response:
            if response.status != 200:
                raise ValueError('User not found')
            return await response.json()

# Parallel execution
users, posts, comments = await asyncio.gather(
    fetch_users(),
    fetch_posts(),
    fetch_comments()
)

# Sequential with error handling
try:
    user = await fetch_user(user_id)
    profile = await fetch_profile(user.profile_id)
    return {'user': user, 'profile': profile}
except Exception as e:
    logger.error(f'Failed to fetch data: {e}')
    raise

# Timeout
async def fetch_with_timeout(coro, seconds):
    try:
        return await asyncio.wait_for(coro, timeout=seconds)
    except asyncio.TimeoutError:
        raise TimeoutError(f'Operation exceeded {seconds}s')
```

---

## Java

```java
// CompletableFuture
CompletableFuture<User> fetchUser(String id) {
    return CompletableFuture.supplyAsync(() -> {
        Response response = httpClient.get("/api/users/" + id);
        if (!response.isSuccessful()) {
            throw new NotFoundException("User not found");
        }
        return response.body(User.class);
    });
}

// Parallel execution
CompletableFuture<List<User>> users = fetchUsers();
CompletableFuture<List<Post>> posts = fetchPosts();
CompletableFuture<List<Comment>> comments = fetchComments();

CompletableFuture.allOf(users, posts, comments)
    .thenApply(v -> new Dashboard(
        users.join(),
        posts.join(),
        comments.join()
    ));

// With timeout
user.orTimeout(5, TimeUnit.SECONDS)
    .exceptionally(ex -> {
        logger.error("Timeout fetching user", ex);
        return getDefaultUser();
    });
```

---

## C# (.NET)

```csharp
// Basic async/await
async Task<User> FetchUserAsync(string id)
{
    var response = await _httpClient.GetAsync($"/api/users/{id}");
    response.EnsureSuccessStatusCode();
    return await response.Content.ReadAsAsync<User>();
}

// Parallel execution
var (users, posts, comments) = await (
    FetchUsersAsync(),
    FetchPostsAsync(),
    FetchCommentsAsync()
);

// Or with Task.WhenAll
var tasks = new[] {
    FetchUsersAsync(),
    FetchPostsAsync(),
    FetchCommentsAsync()
};
await Task.WhenAll(tasks);

// With timeout and cancellation
using var cts = new CancellationTokenSource(TimeSpan.FromSeconds(5));
try
{
    var user = await FetchUserAsync(id, cts.Token);
    return user;
}
catch (OperationCanceledException)
{
    throw new TimeoutException("Request exceeded 5 seconds");
}
```

---

## PHP

```php
// Promises (with ReactPHP or Guzzle)
$promise = $httpClient->getAsync('/api/users/' . $id);
$promise->then(
    function ($response) {
        return json_decode($response->getBody(), true);
    },
    function ($exception) {
        throw new NotFoundException('User not found');
    }
);

// Parallel execution (Guzzle)
$promises = [
    'users' => $client->getAsync('/api/users'),
    'posts' => $client->getAsync('/api/posts'),
    'comments' => $client->getAsync('/api/comments'),
];

$results = Promise\Utils::unwrap($promises);

// With timeout
$client->request('GET', '/api/users/' . $id, [
    'timeout' => 5.0,
    'connect_timeout' => 2.0
]);
```

---

## Kotlin

```kotlin
// Coroutines
suspend fun fetchUser(id: String): User {
    return withContext(Dispatchers.IO) {
        val response = httpClient.get("/api/users/$id")
        if (!response.status.isSuccess()) {
            throw NotFoundException("User not found")
        }
        response.body()
    }
}

// Parallel execution
val (users, posts, comments) = coroutineScope {
    val usersDeferred = async { fetchUsers() }
    val postsDeferred = async { fetchPosts() }
    val commentsDeferred = async { fetchComments() }
    
    Triple(
        usersDeferred.await(),
        postsDeferred.await(),
        commentsDeferred.await()
    )
}

// With timeout
withTimeout(5000) {
    fetchUser(id)
}
```

---

## Swift

```swift
// Async/await (iOS 15+)
func fetchUser(id: String) async throws -> User {
    let url = URL(string: "/api/users/\(id)")!
    let (data, response) = try await URLSession.shared.data(from: url)
    
    guard let httpResponse = response as? HTTPURLResponse,
          httpResponse.statusCode == 200 else {
        throw AppError.notFound(resource: "User")
    }
    
    return try JSONDecoder().decode(User.self, from: data)
}

// Parallel execution
async let users = fetchUsers()
async let posts = fetchPosts()
async let comments = fetchComments()

let dashboard = try await Dashboard(
    users: users,
    posts: posts,
    comments: comments
)

// With timeout
try await withTimeout(seconds: 5) {
    try await fetchUser(id: id)
}
```

---

## Dart (Flutter)

```dart
// Basic async/await
Future<User> fetchUser(String id) async {
  final response = await http.get(Uri.parse('/api/users/$id'));
  
  if (response.statusCode != 200) {
    throw NotFoundException('User not found');
  }
  
  return User.fromJson(jsonDecode(response.body));
}

// Parallel execution
final results = await Future.wait([
  fetchUsers(),
  fetchPosts(),
  fetchComments(),
]);

final users = results[0] as List<User>;
final posts = results[1] as List<Post>;
final comments = results[2] as List<Comment>;

// With timeout
try {
  final user = await fetchUser(id).timeout(
    Duration(seconds: 5),
    onTimeout: () => throw TimeoutException('Request exceeded 5s'),
  );
  return user;
} catch (e) {
  logger.error('Failed to fetch user: $e');
  rethrow;
}

// Stream handling
Stream<User> watchUsers() async* {
  await for (final user in database.watchUsers()) {
    yield user;
  }
}
```

---

## Best Practices

✅ **DO**:
- Always handle errors in async operations
- Use timeout to prevent hanging
- Run independent operations in parallel
- Cancel operations when no longer needed
- Use structured concurrency (scoped async)

❌ **DON'T**:
- Block the main thread
- Forget to await promises/futures
- Run sequential operations when parallel works
- Ignore cancellation tokens
- Mix async and sync patterns

---

## Common Patterns

### Retry Logic
```typescript
async function fetchWithRetry<T>(
  fn: () => Promise<T>,
  retries = 3
): Promise<T> {
  for (let i = 0; i < retries; i++) {
    try {
      return await fn();
    } catch (error) {
      if (i === retries - 1) throw error;
      await delay(Math.pow(2, i) * 1000); // Exponential backoff
    }
  }
  throw new Error('Max retries exceeded');
}
```

### Debounce/Throttle
```typescript
function debounce<T extends (...args: any[]) => any>(
  fn: T,
  ms: number
): (...args: Parameters<T>) => Promise<ReturnType<T>> {
  let timeoutId: NodeJS.Timeout;
  return (...args) => {
    return new Promise((resolve) => {
      clearTimeout(timeoutId);
      timeoutId = setTimeout(() => resolve(fn(...args)), ms);
    });
  };
}
```

### Queue
```typescript
class AsyncQueue {
  private queue: Array<() => Promise<any>> = [];
  private running = 0;
  
  constructor(private concurrency = 1) {}
  
  async add<T>(fn: () => Promise<T>): Promise<T> {
    while (this.running >= this.concurrency) {
      await new Promise(resolve => setTimeout(resolve, 100));
    }
    
    this.running++;
    try {
      return await fn();
    } finally {
      this.running--;
    }
  }
}
```
