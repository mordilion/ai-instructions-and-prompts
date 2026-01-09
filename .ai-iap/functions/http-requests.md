# HTTP Request Patterns

> **Purpose**: Safe and reliable HTTP client requests with error handling and retries
>
> **When to use**: API calls, microservice communication, external service integration

---

## TypeScript / JavaScript

```typescript
// Fetch with error handling
async function fetchUser(id: string): Promise<User> {
  const response = await fetch(`/api/users/${id}`, {
    method: 'GET',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${token}`
    },
    signal: AbortSignal.timeout(5000) // 5s timeout
  });
  
  if (!response.ok) {
    throw new HttpError(response.status, await response.text());
  }
  
  return response.json();
}

// Axios with interceptors
import axios from 'axios';

const api = axios.create({
  baseURL: 'https://api.example.com',
  timeout: 5000,
  headers: { 'Content-Type': 'application/json' }
});

// Request interceptor
api.interceptors.request.use(
  (config) => {
    const token = getAuthToken();
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

// Response interceptor
api.interceptors.response.use(
  (response) => response.data,
  async (error) => {
    if (error.response?.status === 401) {
      await refreshToken();
      return api.request(error.config);
    }
    return Promise.reject(error);
  }
);

// Retry logic with exponential backoff
async function fetchWithRetry<T>(
  fn: () => Promise<T>,
  maxRetries = 3
): Promise<T> {
  for (let i = 0; i < maxRetries; i++) {
    try {
      return await fn();
    } catch (error) {
      if (i === maxRetries - 1 || !isRetryableError(error)) {
        throw error;
      }
      await delay(Math.pow(2, i) * 1000); // 1s, 2s, 4s
    }
  }
  throw new Error('Max retries exceeded');
}

function isRetryableError(error: any): boolean {
  return error.code === 'ETIMEDOUT' ||
         error.response?.status >= 500;
}
```

---

## Python

```python
import httpx
from tenacity import retry, stop_after_attempt, wait_exponential

# httpx (async client)
async def fetch_user(user_id: str) -> dict:
    async with httpx.AsyncClient(timeout=5.0) as client:
        response = await client.get(
            f'/api/users/{user_id}',
            headers={
                'Authorization': f'Bearer {token}',
                'Content-Type': 'application/json'
            }
        )
        response.raise_for_status()
        return response.json()

# requests (sync client)
import requests

def fetch_user_sync(user_id: str) -> dict:
    response = requests.get(
        f'/api/users/{user_id}',
        headers={'Authorization': f'Bearer {token}'},
        timeout=5
    )
    response.raise_for_status()
    return response.json()

# Retry with tenacity
@retry(
    stop=stop_after_attempt(3),
    wait=wait_exponential(multiplier=1, min=1, max=10)
)
async def fetch_with_retry(url: str) -> dict:
    async with httpx.AsyncClient() as client:
        response = await client.get(url)
        response.raise_for_status()
        return response.json()

# Session with retry (requests)
from requests.adapters import HTTPAdapter
from requests.packages.urllib3.util.retry import Retry

session = requests.Session()
retry_strategy = Retry(
    total=3,
    backoff_factor=1,
    status_forcelist=[429, 500, 502, 503, 504]
)
adapter = HTTPAdapter(max_retries=retry_strategy)
session.mount("http://", adapter)
session.mount("https://", adapter)
```

---

## Java

```java
// HttpClient (Java 11+)
import java.net.http.*;

HttpClient client = HttpClient.newBuilder()
    .connectTimeout(Duration.ofSeconds(5))
    .build();

HttpRequest request = HttpRequest.newBuilder()
    .uri(URI.create("/api/users/" + userId))
    .header("Authorization", "Bearer " + token)
    .header("Content-Type", "application/json")
    .GET()
    .build();

HttpResponse<String> response = client.send(
    request,
    HttpResponse.BodyHandlers.ofString()
);

if (response.statusCode() != 200) {
    throw new HttpException(response.statusCode(), response.body());
}

User user = objectMapper.readValue(response.body(), User.class);

// POST request
String requestBody = objectMapper.writeValueAsString(userData);

HttpRequest postRequest = HttpRequest.newBuilder()
    .uri(URI.create("/api/users"))
    .header("Content-Type", "application/json")
    .POST(HttpRequest.BodyPublishers.ofString(requestBody))
    .build();

// RestTemplate (Spring)
@Service
public class UserService {
    private final RestTemplate restTemplate;
    
    public User fetchUser(String id) {
        return restTemplate.getForObject(
            "/api/users/{id}",
            User.class,
            id
        );
    }
    
    public User createUser(UserCreateDto dto) {
        return restTemplate.postForObject(
            "/api/users",
            dto,
            User.class
        );
    }
}

// WebClient (Spring WebFlux - reactive)
@Service
public class UserService {
    private final WebClient webClient;
    
    public Mono<User> fetchUser(String id) {
        return webClient.get()
            .uri("/api/users/{id}", id)
            .retrieve()
            .bodyToMono(User.class)
            .timeout(Duration.ofSeconds(5))
            .retry(3);
    }
}
```

---

## C# (.NET)

```csharp
// HttpClient
private readonly HttpClient _httpClient;

public async Task<User> FetchUserAsync(string id)
{
    var request = new HttpRequestMessage(
        HttpMethod.Get,
        $"/api/users/{id}"
    );
    request.Headers.Authorization = new AuthenticationHeaderValue(
        "Bearer",
        token
    );
    
    using var cts = new CancellationTokenSource(TimeSpan.FromSeconds(5));
    var response = await _httpClient.SendAsync(request, cts.Token);
    
    response.EnsureSuccessStatusCode();
    
    return await response.Content.ReadAsAsync<User>();
}

// POST request
public async Task<User> CreateUserAsync(UserCreateDto dto)
{
    var content = new StringContent(
        JsonSerializer.Serialize(dto),
        Encoding.UTF8,
        "application/json"
    );
    
    var response = await _httpClient.PostAsync("/api/users", content);
    response.EnsureSuccessStatusCode();
    
    return await response.Content.ReadAsAsync<User>();
}

// Retry with Polly
using Polly;
using Polly.Extensions.Http;

var retryPolicy = HttpPolicyExtensions
    .HandleTransientHttpError()
    .OrResult(msg => msg.StatusCode == HttpStatusCode.TooManyRequests)
    .WaitAndRetryAsync(
        3,
        retryAttempt => TimeSpan.FromSeconds(Math.Pow(2, retryAttempt))
    );

services.AddHttpClient("api")
    .AddPolicyHandler(retryPolicy);

// Refit (typed client)
public interface IUserApi
{
    [Get("/users/{id}")]
    Task<User> GetUserAsync(string id);
    
    [Post("/users")]
    Task<User> CreateUserAsync([Body] UserCreateDto dto);
}
```

---

## PHP

```php
// Guzzle
use GuzzleHttp\Client;

$client = new Client([
    'base_uri' => 'https://api.example.com',
    'timeout' => 5.0,
    'headers' => [
        'Authorization' => 'Bearer ' . $token,
        'Content-Type' => 'application/json'
    ]
]);

try {
    $response = $client->get('/api/users/' . $userId);
    $user = json_decode($response->getBody(), true);
} catch (RequestException $e) {
    if ($e->hasResponse()) {
        $statusCode = $e->getResponse()->getStatusCode();
        throw new HttpException($statusCode, $e->getMessage());
    }
    throw $e;
}

// POST request
$response = $client->post('/api/users', [
    'json' => [
        'email' => 'user@example.com',
        'name' => 'John Doe'
    ]
]);

// Retry middleware
use GuzzleHttp\HandlerStack;
use GuzzleHttp\Middleware;

$stack = HandlerStack::create();
$stack->push(Middleware::retry(
    function ($retries, $request, $response, $exception) {
        if ($retries >= 3) return false;
        if ($response && $response->getStatusCode() >= 500) return true;
        return $exception instanceof ConnectException;
    },
    function ($retries) {
        return 1000 * pow(2, $retries); // Exponential backoff
    }
));

$client = new Client(['handler' => $stack]);

// Laravel HTTP client
use Illuminate\Support\Facades\Http;

$response = Http::withToken($token)
    ->timeout(5)
    ->retry(3, 1000)
    ->get('/api/users/' . $userId);

$user = $response->json();
```

---

## Kotlin

```kotlin
// OkHttp
val client = OkHttpClient.Builder()
    .connectTimeout(5, TimeUnit.SECONDS)
    .addInterceptor { chain ->
        val request = chain.request().newBuilder()
            .addHeader("Authorization", "Bearer $token")
            .build()
        chain.proceed(request)
    }
    .build()

val request = Request.Builder()
    .url("/api/users/$userId")
    .get()
    .build()

client.newCall(request).execute().use { response ->
    if (!response.isSuccessful) {
        throw HttpException(response.code, response.message)
    }
    val user = gson.fromJson(response.body?.string(), User::class.java)
}

// Retrofit
interface UserApi {
    @GET("users/{id}")
    suspend fun getUser(@Path("id") id: String): User
    
    @POST("users")
    suspend fun createUser(@Body user: UserCreateDto): User
}

val retrofit = Retrofit.Builder()
    .baseUrl("https://api.example.com")
    .client(client)
    .addConverterFactory(GsonConverterFactory.create())
    .build()

val api = retrofit.create(UserApi::class.java)

// Usage with coroutines
suspend fun fetchUser(id: String): User {
    return withContext(Dispatchers.IO) {
        try {
            api.getUser(id)
        } catch (e: IOException) {
            throw NetworkException("Network error", e)
        }
    }
}

// Ktor Client
val client = HttpClient {
    install(HttpTimeout) {
        requestTimeoutMillis = 5000
    }
    install(HttpRequestRetry) {
        retryOnServerErrors(maxRetries = 3)
        exponentialDelay()
    }
}

suspend fun fetchUser(id: String): User {
    return client.get("/api/users/$id") {
        header("Authorization", "Bearer $token")
    }.body()
}
```

---

## Swift

```swift
// URLSession
func fetchUser(id: String) async throws -> User {
    var request = URLRequest(url: URL(string: "/api/users/\(id)")!)
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    request.timeoutInterval = 5
    
    let (data, response) = try await URLSession.shared.data(for: request)
    
    guard let httpResponse = response as? HTTPURLResponse,
          (200...299).contains(httpResponse.statusCode) else {
        throw HttpError.invalidResponse
    }
    
    return try JSONDecoder().decode(User.self, from: data)
}

// POST request
func createUser(dto: UserCreateDto) async throws -> User {
    var request = URLRequest(url: URL(string: "/api/users")!)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = try JSONEncoder().encode(dto)
    
    let (data, _) = try await URLSession.shared.data(for: request)
    return try JSONDecoder().decode(User.self, from: data)
}

// Retry logic
func fetchWithRetry<T: Decodable>(
    _ request: URLRequest,
    maxRetries: Int = 3
) async throws -> T {
    for attempt in 0..<maxRetries {
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            if attempt == maxRetries - 1 {
                throw error
            }
            try await Task.sleep(nanoseconds: UInt64(pow(2.0, Double(attempt))) * 1_000_000_000)
        }
    }
    fatalError("Unreachable")
}

// Alamofire
import Alamofire

AF.request("/api/users/\(id)", headers: [
    "Authorization": "Bearer \(token)"
])
.validate()
.responseDecodable(of: User.self) { response in
    switch response.result {
    case .success(let user):
        print(user)
    case .failure(let error):
        print("Error: \(error)")
    }
}
```

---

## Dart (Flutter)

```dart
import 'package:http/http.dart' as http;

// Basic request
Future<User> fetchUser(String id) async {
  final response = await http.get(
    Uri.parse('/api/users/$id'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  ).timeout(Duration(seconds: 5));
  
  if (response.statusCode != 200) {
    throw HttpException(response.statusCode, response.body);
  }
  
  return User.fromJson(jsonDecode(response.body));
}

// POST request
Future<User> createUser(UserCreateDto dto) async {
  final response = await http.post(
    Uri.parse('/api/users'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(dto.toJson()),
  );
  
  if (response.statusCode != 201) {
    throw HttpException(response.statusCode, response.body);
  }
  
  return User.fromJson(jsonDecode(response.body));
}

// Dio (advanced client)
import 'package:dio/dio.dart';

final dio = Dio(BaseOptions(
  baseUrl: 'https://api.example.com',
  connectTimeout: Duration(seconds: 5),
  headers: {'Authorization': 'Bearer $token'},
));

// Interceptor for retry
dio.interceptors.add(RetryInterceptor(
  dio: dio,
  logPrint: print,
  retries: 3,
  retryDelays: [
    Duration(seconds: 1),
    Duration(seconds: 2),
    Duration(seconds: 4),
  ],
));

// Usage
Future<User> fetchUser(String id) async {
  try {
    final response = await dio.get('/users/$id');
    return User.fromJson(response.data);
  } on DioError catch (e) {
    if (e.response?.statusCode == 404) {
      throw NotFoundException('User not found');
    }
    rethrow;
  }
}
```

---

## Best Practices

✅ **DO**:
- Set timeouts (connect + read)
- Retry transient errors (500s, network)
- Use exponential backoff
- Log request/response details
- Handle rate limiting (429)
- Validate SSL certificates
- Use connection pooling
- Cancel requests when not needed

❌ **DON'T**:
- Ignore timeouts (infinite wait)
- Retry non-idempotent requests blindly
- Expose auth tokens in logs
- Trust server certificates without validation
- Create new clients per request
- Retry immediately without backoff
- Ignore response status codes

---

## Common Status Codes

| Code | Meaning | Action |
|------|---------|--------|
| 200 | Success | Process response |
| 201 | Created | Process new resource |
| 400 | Bad Request | Fix request, don't retry |
| 401 | Unauthorized | Refresh token, retry |
| 403 | Forbidden | Don't retry, show error |
| 404 | Not Found | Don't retry, handle missing |
| 429 | Rate Limited | Retry after delay |
| 500 | Server Error | Retry with backoff |
| 502/503 | Service Unavailable | Retry with backoff |
| 504 | Gateway Timeout | Retry with backoff |

---

## Security Checklist

- [ ] HTTPS only (no HTTP)
- [ ] Validate SSL certificates
- [ ] Auth tokens in headers (not URL)
- [ ] Sensitive data encrypted
- [ ] Timeout set on all requests
- [ ] Input validated before sending
- [ ] Responses validated before using
- [ ] Tokens not logged
- [ ] API keys not in code (use env)
