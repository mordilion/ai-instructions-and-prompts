---
title: Async Operations Patterns
category: Concurrency
difficulty: intermediate
languages: [typescript, python, java, csharp, php, kotlin, swift, dart]
tags: [async, await, promises, concurrency, parallel, timeout]
updated: 2026-01-09
---

# Async Operations Patterns

> API calls, database queries, file I/O, parallel execution, timeouts

---

## TypeScript

### Native async/await
```typescript
async function fetchUser(id: string): Promise<User> {
  const response = await fetch(`/api/users/${id}`);
  if (!response.ok) throw new Error('User not found');
  return response.json();
}

// Sequential
const user = await fetchUser(id);
const profile = await fetchProfile(user.profileId);
const posts = await fetchPosts(user.id);

// Parallel execution
const [users, posts, comments] = await Promise.all([
  fetchUsers(),
  fetchPosts(),
  fetchComments()
]);

// With timeout
function withTimeout<T>(promise: Promise<T>, ms: number): Promise<T> {
  return Promise.race([
    promise,
    new Promise<T>((_, reject) =>
      setTimeout(() => reject(new Error('Timeout')), ms)
    )
  ]);
}

const user = await withTimeout(fetchUser(id), 5000);
```

### p-queue (Concurrency Control)
```typescript
import PQueue from 'p-queue';

const queue = new PQueue({ concurrency: 2 });

const results = await Promise.all([
  queue.add(() => fetchUser('1')),
  queue.add(() => fetchUser('2')),
  queue.add(() => fetchUser('3'))
]);
```

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

---

## Python

### Native asyncio
```python
import asyncio

async def fetch_user(user_id: str) -> User:
    async with aiohttp.ClientSession() as session:
        async with session.get(f'/api/users/{user_id}') as response:
            if response.status != 200:
                raise ValueError('User not found')
            return await response.json()

# Sequential
user = await fetch_user(user_id)
profile = await fetch_profile(user.profile_id)
posts = await fetch_posts(user.id)

# Parallel execution
users, posts, comments = await asyncio.gather(
    fetch_users(),
    fetch_posts(),
    fetch_comments()
)

# With timeout
try:
    return await asyncio.wait_for(fetch_user(user_id), timeout=5.0)
except asyncio.TimeoutError:
    raise TimeoutError('Operation exceeded 5s')
```

### Retry with tenacity
```python
from tenacity import retry, stop_after_attempt, wait_exponential

@retry(
    stop=stop_after_attempt(3),
    wait=wait_exponential(multiplier=1, min=1, max=10)
)
async def fetch_with_retry(url: str) -> dict:
    async with aiohttp.ClientSession() as session:
        async with session.get(url) as response:
            response.raise_for_status()
            return await response.json()
```

---

## Java

### CompletableFuture
```java
CompletableFuture<User> fetchUser(String id) {
    return CompletableFuture.supplyAsync(() -> {
        Response response = httpClient.get("/api/users/" + id);
        if (!response.isSuccessful()) {
            throw new NotFoundException("User not found");
        }
        return response.body(User.class);
    });
}

// Sequential
CompletableFuture<Dashboard> fetchDashboard(String userId) {
    return fetchUser(userId)
        .thenCompose(user -> fetchProfile(user.getProfileId())
            .thenApply(profile -> new Dashboard(user, profile)));
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
        logger.error("Timeout", ex);
        return getDefaultUser();
    });
```

### Reactor (Spring WebFlux)
```java
import reactor.core.publisher.Mono;

Mono<User> fetchUser(String id) {
    return webClient.get()
        .uri("/api/users/{id}", id)
        .retrieve()
        .bodyToMono(User.class)
        .timeout(Duration.ofSeconds(5))
        .retry(3);
}

// Parallel execution
Mono.zip(fetchUser("1"), fetchProfile("1"))
    .map(tuple -> new UserProfile(tuple.getT1(), tuple.getT2()));
```

---

## C#

### Native async/await
```csharp
async Task<User> FetchUserAsync(string id)
{
    var response = await _httpClient.GetAsync($"/api/users/{id}");
    response.EnsureSuccessStatusCode();
    return await response.Content.ReadAsAsync<User>();
}

// Sequential
var user = await FetchUserAsync(userId);
var profile = await FetchProfileAsync(user.ProfileId);
var posts = await FetchPostsAsync(user.Id);

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

// With timeout
using var cts = new CancellationTokenSource(TimeSpan.FromSeconds(5));
try
{
    var user = await FetchUserAsync(id, cts.Token);
} catch (OperationCanceledException)
{
    throw new TimeoutException("Request exceeded 5 seconds");
}
```

### Polly (Retry & Resilience)
```csharp
using Polly;

var retryPolicy = Policy
    .Handle<HttpRequestException>()
    .WaitAndRetryAsync(
        3,
        retryAttempt => TimeSpan.FromSeconds(Math.pow(2, retryAttempt))
    );

var user = await retryPolicy.ExecuteAsync(() => FetchUserAsync(id));
```

---

## PHP

### Guzzle Promises
```php
use GuzzleHttp\Client;
use GuzzleHttp\Promise;

$client = new Client();

// Parallel requests
$promises = [
    'users' => $client->getAsync('/api/users'),
    'posts' => $client->getAsync('/api/posts'),
    'comments' => $client->getAsync('/api/comments'),
];

// Wait for all
$results = Promise\Utils::unwrap($promises);
$users = json_decode($results['users']->getBody(), true);

// With timeout
$response = $client->request('GET', '/api/users/' . $id, [
    'timeout' => 5.0,
    'connect_timeout' => 2.0
]);
```

### ReactPHP (Event Loop)
```php
use React\EventLoop\Loop;
use React\Promise\Promise;

Loop::addTimer(0.5, function () {
    echo "Timer fired\n";
});

$promise = new Promise(function ($resolve, $reject) {
    // Async operation
    $resolve($result);
});

$promise->then(
    function ($value) {
        echo "Success: $value\n";
    },
    function ($error) {
        echo "Error: $error\n";
    }
);
```

---

## Kotlin

### Coroutines
```kotlin
import kotlinx.coroutines.*

suspend fun fetchUser(id: String): User {
    return withContext(Dispatchers.IO) {
        val response = httpClient.get("/api/users/$id")
        if (!response.status.isSuccess()) {
            throw NotFoundException("User not found")
        }
        response.body()
    }
}

// Sequential
val user = fetchUser(userId)
val profile = fetchProfile(user.profileId)
val posts = fetchPosts(user.id)

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

// Retry logic
suspend fun <T> retry(
    times: Int = 3,
    initialDelay: Long = 100,
    factor: Double = 2.0,
    block: suspend () -> T
): T {
    var currentDelay = initialDelay
    repeat(times - 1) {
        try {
            return block()
        } catch (e: Exception) {
            delay(currentDelay)
            currentDelay = (currentDelay * factor).toLong()
        }
    }
    return block()
}
```

---

## Swift

### Native async/await (iOS 15+)
```swift
func fetchUser(id: String) async throws -> User {
    let url = URL(string: "/api/users/\(id)")!
    let (data, response) = try await URLSession.shared.data(from: url)
    
    guard let httpResponse = response as? HTTPURLResponse,
          httpResponse.statusCode == 200 else {
        throw AppError.notFound(resource: "User")
    }
    
    return try JSONDecoder().decode(User.self, from: data)
}

// Sequential
let user = try await fetchUser(id: userId)
let profile = try await fetchProfile(id: user.profileId)
let posts = try await fetchPosts(userId: userId)

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

### Combine (Reactive)
```swift
import Combine

var cancellables = Set<AnyCancellable>()

URLSession.shared.dataTaskPublisher(for: url)
    .map(\.data)
    .decode(type: User.self, decoder: JSONDecoder())
    .receive(on: DispatchQueue.main)
    .sink(
        receiveCompletion: { completion in
            if case .failure(let error) = completion {
                print("Error: \(error)")
            }
        },
        receiveValue: { user in
            print("User: \(user)")
        }
    )
    .store(in: &cancellables)

// Parallel execution
Publishers.Zip(usersPublisher, postsPublisher)
    .sink { users, posts in
        print("Got \(users.count) users and \(posts.count) posts")
    }
    .store(in: &cancellables)
```

---

## Dart

### Native async/await
```dart
Future<User> fetchUser(String id) async {
  final response = await http.get(Uri.parse('/api/users/$id'));
  
  if (response.statusCode != 200) {
    throw NotFoundException('User not found');
  }
  
  return User.fromJson(jsonDecode(response.body));
}

// Sequential
final user = await fetchUser(userId);
final profile = await fetchProfile(user.profileId);
final posts = await fetchPosts(user.id);

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
} catch (e) {
  logger.error('Failed: $e');
  rethrow;
}

// Retry logic
Future<T> retry<T>(
  Future<T> Function() fn, {
  int maxAttempts = 3,
  Duration delay = const Duration(seconds: 1),
}) async {
  int attempt = 0;
  while (true) {
    try {
      return await fn();
    } catch (e) {
      attempt++;
      if (attempt >= maxAttempts) rethrow;
      await Future.delayed(delay * attempt);
    }
  }
}
```

### Streams
```dart
Stream<User> watchUsers() async* {
  await for (final user in database.watchUsers()) {
    yield user;
  }
}

// Transform stream
stream
  .where((user) => user.age > 18)
  .map((user) => user.name)
  .listen((name) => print(name));
```

---

## Common Patterns

### Debounce
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

---

## Quick Rules

✅ Handle errors in async operations
✅ Use timeout to prevent hanging
✅ Run independent operations in parallel
✅ Cancel operations when not needed
✅ Use structured concurrency
✅ Log async operation failures

❌ Block the main/UI thread
❌ Forget to await promises/futures
❌ Run sequential when parallel works
❌ Ignore cancellation tokens
❌ Create unbounded concurrent operations
