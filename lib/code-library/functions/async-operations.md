---
title: Async Operations Patterns
category: Concurrency & Performance
difficulty: intermediate
purpose: Handle asynchronous code with proper awaiting, parallel execution, timeouts, retry logic, and error handling
when_to_use:
  - API calls
  - Database queries
  - File I/O
  - Multiple parallel operations
  - Long-running tasks
  - Rate-limited operations
  - Background processing
languages:
  typescript:
    - name: Native async/await (Built-in)
      library: javascript-core
      recommended: true
    - name: Promise.all / Promise.allSettled (Built-in)
      library: javascript-core
    - name: p-limit (Concurrency control)
      library: p-limit
    - name: p-retry (Retry logic)
      library: p-retry
  python:
    - name: asyncio (Built-in)
      library: python-core
      recommended: true
    - name: aiohttp (Async HTTP)
      library: aiohttp
    - name: tenacity (Retry logic)
      library: tenacity
  java:
    - name: CompletableFuture (Built-in)
      library: java-core
      recommended: true
    - name: Project Reactor
      library: io.projectreactor:reactor-core
    - name: RxJava
      library: io.reactivex.rxjava3:rxjava
  csharp:
    - name: Task / async-await (Built-in)
      library: dotnet-core
      recommended: true
    - name: Polly (Retry & resilience)
      library: Polly
  php:
    - name: ReactPHP
      library: react/promise
    - name: Guzzle Promises
      library: guzzlehttp/promises
    - name: Amp
      library: amphp/amp
  kotlin:
    - name: Coroutines (Built-in)
      library: kotlinx-coroutines-core
      recommended: true
    - name: Flow (Reactive streams)
      library: kotlinx-coroutines-core
  swift:
    - name: async/await (Built-in)
      library: swift-stdlib
      recommended: true
    - name: Combine
      library: Combine (built-in)
  dart:
    - name: Future / async-await (Built-in)
      library: dart-core
      recommended: true
    - name: Stream (Reactive)
      library: dart-core
common_patterns:
  - Sequential async operations (await one after another)
  - Parallel async operations (Promise.all, asyncio.gather)
  - Timeout handling (Promise.race, asyncio.wait_for)
  - Retry logic with exponential backoff
  - Debounce / Throttle for rate limiting
  - Queue processing (task queues, worker pools)
best_practices:
  do:
    - Always await or catch promises
    - Use Promise.all for parallel operations
    - Set timeouts for external calls
    - Implement retry logic with exponential backoff
    - Cancel long-running operations when component unmounts
    - Use AbortController for fetch requests
  dont:
    - Block the event loop with CPU-intensive work
    - Forget error handling in async functions
    - Create "fire-and-forget" promises without catching
    - Await inside loops unless sequential is required
    - Use infinite retries without backoff
related_functions:
  - http-requests.md
  - error-handling.md
  - database-query.md
tags: [async, promises, futures, coroutines, concurrency, parallel, timeout, retry]
updated: 2026-01-09
---

## TypeScript

### Basic async/await
```typescript
async function fetchUser(userId: string): Promise<User> {
  const response = await fetch(`/api/users/${userId}`);
  if (!response.ok) throw new Error('User not found');
  return response.json();
}

try {
  const user = await fetchUser('123');
  console.log(user);
} catch (error) {
  console.error('Failed to fetch user:', error);
}
```

### Parallel Execution - Promise.all
```typescript
const [user, posts, comments] = await Promise.all([
  fetchUser(userId),
  fetchPosts(userId),
  fetchComments(userId),
]);
```

### Promise.allSettled (Continue on failure)
```typescript
const results = await Promise.allSettled([
  fetchUser('1'),
  fetchUser('2'),
  fetchUser('3'),
]);

results.forEach((result, index) => {
  if (result.status === 'fulfilled') {
    console.log(`User ${index}:`, result.value);
  } else {
    console.error(`User ${index} failed:`, result.reason);
  }
});
```

### Timeout Handling - Promise.race
```typescript
function withTimeout<T>(promise: Promise<T>, ms: number): Promise<T> {
  const timeout = new Promise<never>((_, reject) =>
    setTimeout(() => reject(new Error('Timeout')), ms)
  );
  return Promise.race([promise, timeout]);
}

const user = await withTimeout(fetchUser('123'), 5000);
```

### Retry Logic
```typescript
async function retry<T>(
  fn: () => Promise<T>,
  retries = 3,
  delay = 1000
): Promise<T> {
  try {
    return await fn();
  } catch (error) {
    if (retries === 0) throw error;
    await new Promise(resolve => setTimeout(resolve, delay));
    return retry(fn, retries - 1, delay * 2);
  }
}

const user = await retry(() => fetchUser('123'), 3, 1000);
```

### Debounce
```typescript
function debounce<T extends (...args: any[]) => any>(
  fn: T,
  delay: number
): (...args: Parameters<T>) => void {
  let timeoutId: NodeJS.Timeout;
  return (...args) => {
    clearTimeout(timeoutId);
    timeoutId = setTimeout(() => fn(...args), delay);
  };
}

const debouncedSearch = debounce(searchAPI, 300);
```

### Concurrent Queue (p-limit)
```typescript
import pLimit from 'p-limit';

const limit = pLimit(3); // Max 3 concurrent operations

const userIds = ['1', '2', '3', '4', '5'];
const users = await Promise.all(
  userIds.map(id => limit(() => fetchUser(id)))
);
```

---

## Python

### Basic async/await
```python
import asyncio

async def fetch_user(user_id: str) -> dict:
    await asyncio.sleep(1)  # Simulate API call
    return {"id": user_id, "name": "John"}

async def main():
    user = await fetch_user("123")
    print(user)

asyncio.run(main())
```

### Parallel Execution - asyncio.gather
```python
user, posts, comments = await asyncio.gather(
    fetch_user(user_id),
    fetch_posts(user_id),
    fetch_comments(user_id),
)
```

### Return Exceptions (Continue on failure)
```python
results = await asyncio.gather(
    fetch_user("1"),
    fetch_user("2"),
    fetch_user("3"),
    return_exceptions=True,
)

for i, result in enumerate(results):
    if isinstance(result, Exception):
        print(f"User {i} failed: {result}")
    else:
        print(f"User {i}: {result}")
```

### Timeout Handling
```python
try:
    user = await asyncio.wait_for(fetch_user("123"), timeout=5.0)
except asyncio.TimeoutError:
    print("Request timed out")
```

### Retry Logic (tenacity)
```python
from tenacity import retry, stop_after_attempt, wait_exponential

@retry(stop=stop_after_attempt(3), wait=wait_exponential(multiplier=1, min=1, max=10))
async def fetch_user_with_retry(user_id: str):
    return await fetch_user(user_id)

user = await fetch_user_with_retry("123")
```

### Task Cancellation
```python
task = asyncio.create_task(fetch_user("123"))

await asyncio.sleep(1)
task.cancel()

try:
    await task
except asyncio.CancelledError:
    print("Task was cancelled")
```

### Semaphore (Concurrency Limit)
```python
semaphore = asyncio.Semaphore(3)

async def fetch_with_limit(user_id: str):
    async with semaphore:
        return await fetch_user(user_id)

user_ids = ["1", "2", "3", "4", "5"]
users = await asyncio.gather(*[fetch_with_limit(id) for id in user_ids])
```

---

## Java

### CompletableFuture - Basic
```java
CompletableFuture<User> future = CompletableFuture.supplyAsync(() -> {
    return fetchUser("123");
});

User user = future.get();
```

### Exception Handling
```java
CompletableFuture<User> future = CompletableFuture
    .supplyAsync(() -> fetchUser("123"))
    .exceptionally(ex -> {
        logger.error("Failed to fetch user", ex);
        return defaultUser;
    });
```

### Chaining Async Operations
```java
CompletableFuture<String> result = CompletableFuture
    .supplyAsync(() -> fetchUser("123"))
    .thenApply(user -> user.getName())
    .thenApply(name -> name.toUpperCase());
```

### Parallel Execution - allOf
```java
CompletableFuture<User> userFuture = CompletableFuture.supplyAsync(() -> fetchUser(userId));
CompletableFuture<List<Post>> postsFuture = CompletableFuture.supplyAsync(() -> fetchPosts(userId));
CompletableFuture<List<Comment>> commentsFuture = CompletableFuture.supplyAsync(() -> fetchComments(userId));

CompletableFuture.allOf(userFuture, postsFuture, commentsFuture).join();

User user = userFuture.get();
List<Post> posts = postsFuture.get();
List<Comment> comments = commentsFuture.get();
```

### Timeout Handling
```java
try {
    User user = future.get(5, TimeUnit.SECONDS);
} catch (TimeoutException e) {
    logger.error("Request timed out");
}
```

### Reactor - Mono/Flux
```java
Mono<User> userMono = Mono.fromCallable(() -> fetchUser("123"))
    .timeout(Duration.ofSeconds(5))
    .retry(3)
    .onErrorReturn(defaultUser);

User user = userMono.block();
```

---

## C#

### Basic async/await
```csharp
public async Task<User> FetchUserAsync(string userId)
{
    var response = await _httpClient.GetAsync($"/api/users/{userId}");
    response.EnsureSuccessStatusCode();
    return await response.Content.ReadFromJsonAsync<User>();
}

try
{
    var user = await FetchUserAsync("123");
    Console.WriteLine(user);
}
catch (Exception ex)
{
    Console.Error.WriteLine($"Failed to fetch user: {ex.Message}");
}
```

### Parallel Execution - Task.WhenAll
```csharp
var userTask = FetchUserAsync(userId);
var postsTask = FetchPostsAsync(userId);
var commentsTask = FetchCommentsAsync(userId);

await Task.WhenAll(userTask, postsTask, commentsTask);

var user = await userTask;
var posts = await postsTask;
var comments = await commentsTask;
```

### Timeout Handling
```csharp
using var cts = new CancellationTokenSource(TimeSpan.FromSeconds(5));

try
{
    var user = await FetchUserAsync("123", cts.Token);
}
catch (OperationCanceledException)
{
    Console.WriteLine("Request timed out");
}
```

### Retry Logic (Polly)
```csharp
using Polly;

var retryPolicy = Policy
    .Handle<HttpRequestException>()
    .WaitAndRetryAsync(3, attempt => TimeSpan.FromSeconds(Math.Pow(2, attempt)));

var user = await retryPolicy.ExecuteAsync(async () => 
    await FetchUserAsync("123")
);
```

### Parallel with Limit
```csharp
var semaphore = new SemaphoreSlim(3);

var tasks = userIds.Select(async id =>
{
    await semaphore.WaitAsync();
    try
    {
        return await FetchUserAsync(id);
    }
    finally
    {
        semaphore.Release();
    }
});

var users = await Task.WhenAll(tasks);
```

---

## PHP

### ReactPHP - Promises
```php
use React\Promise\Promise;

$promise = new Promise(function ($resolve, $reject) {
    $user = fetchUser('123');
    if ($user) {
        $resolve($user);
    } else {
        $reject(new Exception('User not found'));
    }
});

$promise->then(
    function ($user) {
        echo "User: " . $user['name'];
    },
    function ($error) {
        echo "Error: " . $error->getMessage();
    }
);
```

### Guzzle Promises - Parallel
```php
use GuzzleHttp\Promise;

$promises = [
    'user' => $client->getAsync('/api/users/123'),
    'posts' => $client->getAsync('/api/posts?userId=123'),
];

$results = Promise\Utils::unwrap($promises);

$user = json_decode($results['user']->getBody(), true);
$posts = json_decode($results['posts']->getBody(), true);
```

### Amp - Async/Await
```php
use Amp\Loop;

Loop::run(function () {
    $user = yield fetchUser('123');
    echo "User: " . $user['name'];
});
```

---

## Kotlin

### Coroutines - Basic
```kotlin
import kotlinx.coroutines.*

suspend fun fetchUser(userId: String): User {
    delay(1000) // Simulate API call
    return User(userId, "John")
}

fun main() = runBlocking {
    val user = fetchUser("123")
    println(user)
}
```

### Parallel Execution - async/await
```kotlin
val user = async { fetchUser(userId) }
val posts = async { fetchPosts(userId) }
val comments = async { fetchComments(userId) }

val userData = user.await()
val postsData = posts.await()
val commentsData = comments.await()
```

### Timeout Handling
```kotlin
try {
    val user = withTimeout(5000) {
        fetchUser("123")
    }
} catch (e: TimeoutCancellationException) {
    println("Request timed out")
}
```

### Retry Logic
```kotlin
suspend fun <T> retry(
    times: Int = 3,
    delay: Long = 1000,
    block: suspend () -> T
): T {
    repeat(times - 1) {
        try {
            return block()
        } catch (e: Exception) {
            delay(delay * (it + 1))
        }
    }
    return block()
}

val user = retry(3) { fetchUser("123") }
```

### Flow - Reactive Streams
```kotlin
import kotlinx.coroutines.flow.*

val userFlow = flow {
    for (id in 1..5) {
        emit(fetchUser(id.toString()))
    }
}

userFlow.collect { user ->
    println(user)
}
```

---

## Swift

### Basic async/await
```swift
func fetchUser(userId: String) async throws -> User {
    let url = URL(string: "https://api.example.com/users/\(userId)")!
    let (data, _) = try await URLSession.shared.data(from: url)
    return try JSONDecoder().decode(User.self, from: data)
}

Task {
    do {
        let user = try await fetchUser(userId: "123")
        print(user)
    } catch {
        print("Failed to fetch user: \(error)")
    }
}
```

### Parallel Execution - async let
```swift
async let user = fetchUser(userId: userId)
async let posts = fetchPosts(userId: userId)
async let comments = fetchComments(userId: userId)

let (userData, postsData, commentsData) = try await (user, posts, comments)
```

### Timeout Handling
```swift
func withTimeout<T>(_ operation: @escaping () async throws -> T, timeout: TimeInterval) async throws -> T {
    try await withThrowingTaskGroup(of: T.self) { group in
        group.addTask {
            try await operation()
        }
        group.addTask {
            try await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
            throw TimeoutError()
        }
        
        let result = try await group.next()!
        group.cancelAll()
        return result
    }
}
```

### Task Cancellation
```swift
let task = Task {
    try await fetchUser(userId: "123")
}

task.cancel()
```

### Combine - Publisher
```swift
import Combine

let cancellable = URLSession.shared.dataTaskPublisher(for: url)
    .map(\.data)
    .decode(type: User.self, decoder: JSONDecoder())
    .retry(3)
    .timeout(.seconds(5), scheduler: DispatchQueue.main)
    .sink(
        receiveCompletion: { completion in
            print("Completed: \(completion)")
        },
        receiveValue: { user in
            print("User: \(user)")
        }
    )
```

---

## Dart

### Basic async/await
```dart
Future<User> fetchUser(String userId) async {
  final response = await http.get(Uri.parse('https://api.example.com/users/$userId'));
  if (response.statusCode != 200) throw Exception('User not found');
  return User.fromJson(jsonDecode(response.body));
}

try {
  final user = await fetchUser('123');
  print(user);
} catch (error) {
  print('Failed to fetch user: $error');
}
```

### Parallel Execution - Future.wait
```dart
final results = await Future.wait([
  fetchUser(userId),
  fetchPosts(userId),
  fetchComments(userId),
]);

final user = results[0];
final posts = results[1];
final comments = results[2];
```

### Timeout Handling
```dart
try {
  final user = await fetchUser('123').timeout(Duration(seconds: 5));
} on TimeoutException {
  print('Request timed out');
}
```

### Stream - Reactive
```dart
Stream<User> fetchUsersStream() async* {
  for (var id in ['1', '2', '3']) {
    yield await fetchUser(id);
  }
}

await for (final user in fetchUsersStream()) {
  print(user);
}
```

### Retry Logic
```dart
Future<T> retry<T>(Future<T> Function() fn, {int retries = 3, Duration delay = const Duration(seconds: 1)}) async {
  for (var i = 0; i < retries; i++) {
    try {
      return await fn();
    } catch (e) {
      if (i == retries - 1) rethrow;
      await Future.delayed(delay * (i + 1));
    }
  }
  throw Exception('Retry failed');
}

final user = await retry(() => fetchUser('123'), retries: 3);
```
