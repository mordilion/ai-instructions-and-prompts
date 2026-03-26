---
title: Chain of Responsibility Pattern
category: Behavioral Design Pattern
difficulty: intermediate
purpose: Pass requests along a chain of handlers where each handler decides to process or pass to the next handler
when_to_use:
  - HTTP middleware (Express, ASP.NET, Laravel)
  - Request/response processing pipelines
  - Validation chains
  - Error handling chains
  - Authentication/authorization flows
  - Logging and monitoring pipelines
languages:
  typescript:
    - name: Class Chain (Built-in)
      library: javascript-core
      recommended: true
    - name: Function Chain (Built-in)
      library: javascript-core
  python:
    - name: Class Chain (Built-in)
      library: python-core
      recommended: true
    - name: Function Chain (Built-in)
      library: python-core
  java:
    - name: Abstract Handler Chain (Built-in)
      library: java-core
      recommended: true
  csharp:
    - name: Abstract Handler Chain (Built-in)
      library: dotnet-core
      recommended: true
  php:
    - name: Class Chain (Built-in)
      library: php-core
      recommended: true
    - name: Laravel Middleware
      library: laravel/framework
  kotlin:
    - name: Class Chain (Built-in)
      library: kotlin-stdlib
      recommended: true
  swift:
    - name: Protocol Chain (Built-in)
      library: swift-stdlib
      recommended: true
  dart:
    - name: Class Chain (Built-in)
      library: dart-core
      recommended: true
common_patterns:
  - Linear chain (single path)
  - Branching chain (multiple paths)
  - Early termination
  - Request modification
  - Response modification
best_practices:
  do:
    - Keep handlers single-responsibility
    - Allow early termination
    - Make chain order explicit
    - Use for cross-cutting concerns
    - Consider immutable request objects
  dont:
    - Create circular chains
    - Put business logic in handlers
    - Make handlers stateful
    - Create deep chains (hard to debug)
    - Forget to handle unprocessed requests
related_functions:
  - auth-authorization.md
  - input-validation.md
  - logging.md
tags: [chain-of-responsibility, behavioral-pattern, middleware, pipeline, handlers]
updated: 2026-01-20
---

## TypeScript

### Middleware Chain (Web Framework Style)
```typescript
// Request and Response types
interface Request {
  url: string;
  method: string;
  headers: Record<string, string>;
  body?: any;
  user?: { id: string; role: string };
}

interface Response {
  status: number;
  body: any;
}

type NextFunction = () => Promise<Response | void>;
type Middleware = (req: Request, next: NextFunction) => Promise<Response | void>;

// Concrete middleware handlers
const authMiddleware: Middleware = async (req, next) => {
  console.log('Auth middleware');
  
  const token = req.headers['authorization'];
  if (!token) {
    return { status: 401, body: { error: 'Unauthorized' } };
  }
  
  // Simulate token validation
  req.user = { id: '123', role: 'user' };
  return await next();
};

const loggingMiddleware: Middleware = async (req, next) => {
  console.log(`${req.method} ${req.url}`);
  const startTime = Date.now();
  
  const response = await next();
  
  const duration = Date.now() - startTime;
  console.log(`Request took ${duration}ms`);
  return response;
};

const validationMiddleware: Middleware = async (req, next) => {
  console.log('Validation middleware');
  
  if (req.method === 'POST' && !req.body) {
    return { status: 400, body: { error: 'Body required' } };
  }
  
  return await next();
};

const rateLimitMiddleware: Middleware = async (req, next) => {
  console.log('Rate limit middleware');
  
  // Simulate rate limit check
  const allowed = Math.random() > 0.1;
  if (!allowed) {
    return { status: 429, body: { error: 'Too many requests' } };
  }
  
  return await next();
};

// Middleware chain executor
class MiddlewareChain {
  private middlewares: Middleware[] = [];

  use(middleware: Middleware): this {
    this.middlewares.push(middleware);
    return this;
  }

  async execute(req: Request): Promise<Response> {
    let index = 0;

    const next = async (): Promise<Response | void> => {
      if (index >= this.middlewares.length) {
        // End of chain - return final response
        return { status: 200, body: { success: true } };
      }

      const middleware = this.middlewares[index++];
      return await middleware(req, next);
    };

    const response = await next();
    return response || { status: 500, body: { error: 'No response' } };
  }
}

// Usage
const chain = new MiddlewareChain()
  .use(loggingMiddleware)
  .use(authMiddleware)
  .use(rateLimitMiddleware)
  .use(validationMiddleware);

const request: Request = {
  url: '/api/users',
  method: 'GET',
  headers: { authorization: 'Bearer token123' }
};

const response = await chain.execute(request);
console.log(response);
```

### Classic Handler Chain
```typescript
abstract class Handler {
  private nextHandler?: Handler;

  setNext(handler: Handler): Handler {
    this.nextHandler = handler;
    return handler;
  }

  async handle(request: string): Promise<string | null> {
    const result = await this.process(request);
    
    if (result !== null) {
      return result;
    }

    if (this.nextHandler) {
      return await this.nextHandler.handle(request);
    }

    return null;
  }

  protected abstract process(request: string): Promise<string | null>;
}

class AuthHandler extends Handler {
  protected async process(request: string): Promise<string | null> {
    if (request.includes('auth:')) {
      return `AuthHandler: Processed ${request}`;
    }
    return null;
  }
}

class CacheHandler extends Handler {
  protected async process(request: string): Promise<string | null> {
    if (request.includes('cache:')) {
      return `CacheHandler: Processed ${request}`;
    }
    return null;
  }
}

class DatabaseHandler extends Handler {
  protected async process(request: string): Promise<string | null> {
    return `DatabaseHandler: Processed ${request}`;
  }
}

// Usage
const auth = new AuthHandler();
const cache = new CacheHandler();
const db = new DatabaseHandler();

auth.setNext(cache).setNext(db);

console.log(await auth.handle('auth:login')); // AuthHandler processes
console.log(await auth.handle('cache:get')); // CacheHandler processes
console.log(await auth.handle('data:fetch')); // DatabaseHandler processes
```

---

## Python

### Middleware Chain
```python
from abc import ABC, abstractmethod
from typing import Callable, Optional, Any, Awaitable
from dataclasses import dataclass

@dataclass
class Request:
    url: str
    method: str
    headers: dict[str, str]
    body: Optional[Any] = None
    user: Optional[dict] = None

@dataclass
class Response:
    status: int
    body: Any

NextFunction = Callable[[], Awaitable[Optional[Response]]]
Middleware = Callable[[Request, NextFunction], Awaitable[Optional[Response]]]

# Concrete middleware handlers
async def auth_middleware(req: Request, next: NextFunction) -> Optional[Response]:
    print("Auth middleware")
    
    token = req.headers.get("authorization")
    if not token:
        return Response(status=401, body={"error": "Unauthorized"})
    
    req.user = {"id": "123", "role": "user"}
    return await next()

async def logging_middleware(req: Request, next: NextFunction) -> Optional[Response]:
    print(f"{req.method} {req.url}")
    response = await next()
    print(f"Response: {response.status if response else 'None'}")
    return response

async def validation_middleware(req: Request, next: NextFunction) -> Optional[Response]:
    print("Validation middleware")
    
    if req.method == "POST" and not req.body:
        return Response(status=400, body={"error": "Body required"})
    
    return await next()

# Middleware chain executor
class MiddlewareChain:
    def __init__(self):
        self._middlewares: list[Middleware] = []

    def use(self, middleware: Middleware) -> 'MiddlewareChain':
        self._middlewares.append(middleware)
        return self

    async def execute(self, req: Request) -> Response:
        index = 0

        async def next() -> Optional[Response]:
            nonlocal index
            if index >= len(self._middlewares):
                return Response(status=200, body={"success": True})

            middleware = self._middlewares[index]
            index += 1
            return await middleware(req, next)

        response = await next()
        return response or Response(status=500, body={"error": "No response"})

# Usage
chain = (MiddlewareChain()
    .use(logging_middleware)
    .use(auth_middleware)
    .use(validation_middleware))

request = Request(
    url="/api/users",
    method="GET",
    headers={"authorization": "Bearer token123"}
)

response = await chain.execute(request)
print(response)
```

### Classic Handler Chain
```python
class Handler(ABC):
    def __init__(self):
        self._next_handler: Optional[Handler] = None

    def set_next(self, handler: 'Handler') -> 'Handler':
        self._next_handler = handler
        return handler

    async def handle(self, request: str) -> Optional[str]:
        result = await self.process(request)
        
        if result is not None:
            return result

        if self._next_handler:
            return await self._next_handler.handle(request)

        return None

    @abstractmethod
    async def process(self, request: str) -> Optional[str]:
        pass

class AuthHandler(Handler):
    async def process(self, request: str) -> Optional[str]:
        if "auth:" in request:
            return f"AuthHandler: Processed {request}"
        return None

class CacheHandler(Handler):
    async def process(self, request: str) -> Optional[str]:
        if "cache:" in request:
            return f"CacheHandler: Processed {request}"
        return None

class DatabaseHandler(Handler):
    async def process(self, request: str) -> Optional[str]:
        return f"DatabaseHandler: Processed {request}"

# Usage
auth = AuthHandler()
cache = CacheHandler()
db = DatabaseHandler()

auth.set_next(cache).set_next(db)

print(await auth.handle("auth:login"))  # AuthHandler
print(await auth.handle("cache:get"))   # CacheHandler
print(await auth.handle("data:fetch"))  # DatabaseHandler
```

---

## Java

### Classic Handler Chain
```java
// Handler interface
abstract class Handler {
    private Handler nextHandler;

    public Handler setNext(Handler handler) {
        this.nextHandler = handler;
        return handler;
    }

    public String handle(String request) {
        String result = process(request);
        
        if (result != null) {
            return result;
        }

        if (nextHandler != null) {
            return nextHandler.handle(request);
        }

        return null;
    }

    protected abstract String process(String request);
}

// Concrete handlers
class AuthHandler extends Handler {
    @Override
    protected String process(String request) {
        if (request.contains("auth:")) {
            return "AuthHandler: Processed " + request;
        }
        return null;
    }
}

class CacheHandler extends Handler {
    @Override
    protected String process(String request) {
        if (request.contains("cache:")) {
            return "CacheHandler: Processed " + request;
        }
        return null;
    }
}

class DatabaseHandler extends Handler {
    @Override
    protected String process(String request) {
        return "DatabaseHandler: Processed " + request;
    }
}

// Usage
Handler auth = new AuthHandler();
Handler cache = new CacheHandler();
Handler db = new DatabaseHandler();

auth.setNext(cache).setNext(db);

System.out.println(auth.handle("auth:login"));  // AuthHandler
System.out.println(auth.handle("cache:get"));   // CacheHandler
System.out.println(auth.handle("data:fetch"));  // DatabaseHandler
```

---

## C#

### Middleware Chain (ASP.NET Core Style)
```csharp
public record Request(string Url, string Method, Dictionary<string, string> Headers)
{
    public Dictionary<string, object>? User { get; set; }
    public object? Body { get; set; }
}

public record Response(int Status, object Body);

public delegate Task<Response?> NextFunction();
public delegate Task<Response?> Middleware(Request request, NextFunction next);

public class MiddlewareChain
{
    private readonly List<Middleware> _middlewares = new();

    public MiddlewareChain Use(Middleware middleware)
    {
        _middlewares.Add(middleware);
        return this;
    }

    public async Task<Response> ExecuteAsync(Request request)
    {
        var index = 0;

        async Task<Response?> Next()
        {
            if (index >= _middlewares.Count)
            {
                return new Response(200, new { success = true });
            }

            var middleware = _middlewares[index++];
            return await middleware(request, Next);
        }

        var response = await Next();
        return response ?? new Response(500, new { error = "No response" });
    }
}

// Middleware functions
static async Task<Response?> AuthMiddleware(Request req, NextFunction next)
{
    Console.WriteLine("Auth middleware");
    
    if (!req.Headers.ContainsKey("authorization"))
    {
        return new Response(401, new { error = "Unauthorized" });
    }
    
    req.User = new Dictionary<string, object> { ["id"] = "123", ["role"] = "user" };
    return await next();
}

static async Task<Response?> LoggingMiddleware(Request req, NextFunction next)
{
    Console.WriteLine($"{req.Method} {req.Url}");
    var response = await next();
    Console.WriteLine($"Response: {response?.Status}");
    return response;
}

// Usage
var chain = new MiddlewareChain()
    .Use(LoggingMiddleware)
    .Use(AuthMiddleware);

var request = new Request(
    "/api/users",
    "GET",
    new Dictionary<string, string> { ["authorization"] = "Bearer token123" }
);

var response = await chain.ExecuteAsync(request);
Console.WriteLine(response);
```

---

## PHP

### Laravel-Style Middleware Chain
```php
interface Request
{
    public function getUrl(): string;
    public function getMethod(): string;
    public function getHeader(string $name): ?string;
}

class HttpRequest implements Request
{
    public function __construct(
        private string $url,
        private string $method,
        private array $headers = [],
        public mixed $user = null
    ) {}

    public function getUrl(): string { return $this->url; }
    public function getMethod(): string { return $this->method; }
    public function getHeader(string $name): ?string { return $this->headers[$name] ?? null; }
}

class Response
{
    public function __construct(
        public int $status,
        public mixed $body
    ) {}
}

interface Middleware
{
    public function handle(Request $request, callable $next): Response;
}

class AuthMiddleware implements Middleware
{
    public function handle(Request $request, callable $next): Response
    {
        echo "Auth middleware\n";
        
        if (!$request->getHeader('authorization')) {
            return new Response(401, ['error' => 'Unauthorized']);
        }
        
        if ($request instanceof HttpRequest) {
            $request->user = ['id' => '123', 'role' => 'user'];
        }
        
        return $next($request);
    }
}

class LoggingMiddleware implements Middleware
{
    public function handle(Request $request, callable $next): Response
    {
        echo "{$request->getMethod()} {$request->getUrl()}\n";
        $response = $next($request);
        echo "Response: {$response->status}\n";
        return $response;
    }
}

class MiddlewarePipeline
{
    private array $middlewares = [];

    public function pipe(Middleware $middleware): self
    {
        $this->middlewares[] = $middleware;
        return $this;
    }

    public function handle(Request $request): Response
    {
        $next = fn($req) => new Response(200, ['success' => true]);

        foreach (array_reverse($this->middlewares) as $middleware) {
            $next = fn($req) => $middleware->handle($req, $next);
        }

        return $next($request);
    }
}

// Usage
$pipeline = (new MiddlewarePipeline())
    ->pipe(new LoggingMiddleware())
    ->pipe(new AuthMiddleware());

$request = new HttpRequest('/api/users', 'GET', ['authorization' => 'Bearer token123']);
$response = $pipeline->handle($request);
print_r($response);
```

---

## Kotlin

### Middleware Chain
```kotlin
data class Request(
    val url: String,
    val method: String,
    val headers: Map<String, String>,
    var user: Map<String, Any>? = null,
    var body: Any? = null
)

data class Response(val status: Int, val body: Any)

typealias NextFunction = suspend () -> Response?
typealias Middleware = suspend (Request, NextFunction) -> Response?

class MiddlewareChain {
    private val middlewares = mutableListOf<Middleware>()

    fun use(middleware: Middleware): MiddlewareChain {
        middlewares.add(middleware)
        return this
    }

    suspend fun execute(request: Request): Response {
        var index = 0

        suspend fun next(): Response? {
            if (index >= middlewares.size) {
                return Response(200, mapOf("success" to true))
            }

            val middleware = middlewares[index++]
            return middleware(request, ::next)
        }

        return next() ?: Response(500, mapOf("error" to "No response"))
    }
}

// Middleware functions
val authMiddleware: Middleware = { req, next ->
    println("Auth middleware")
    
    if (!req.headers.containsKey("authorization")) {
        Response(401, mapOf("error" to "Unauthorized"))
    } else {
        req.user = mapOf("id" to "123", "role" to "user")
        next()
    }
}

val loggingMiddleware: Middleware = { req, next ->
    println("${req.method} ${req.url}")
    val response = next()
    println("Response: ${response?.status}")
    response
}

// Usage
suspend fun main() {
    val chain = MiddlewareChain()
        .use(loggingMiddleware)
        .use(authMiddleware)

    val request = Request(
        url = "/api/users",
        method = "GET",
        headers = mapOf("authorization" to "Bearer token123")
    )

    val response = chain.execute(request)
    println(response)
}
```

---

## Swift

### Middleware Chain
```swift
struct Request {
    let url: String
    let method: String
    let headers: [String: String]
    var user: [String: Any]?
    var body: Any?
}

struct Response {
    let status: Int
    let body: Any
}

typealias NextFunction = () async -> Response?
typealias Middleware = (Request, @escaping NextFunction) async -> Response?

class MiddlewareChain {
    private var middlewares: [Middleware] = []
    
    func use(_ middleware: @escaping Middleware) -> MiddlewareChain {
        middlewares.append(middleware)
        return self
    }
    
    func execute(request: Request) async -> Response {
        var index = 0
        
        func next() async -> Response? {
            guard index < middlewares.count else {
                return Response(status: 200, body: ["success": true])
            }
            
            let middleware = middlewares[index]
            index += 1
            return await middleware(request, next)
        }
        
        if let response = await next() {
            return response
        }
        return Response(status: 500, body: ["error": "No response"])
    }
}

// Middleware functions
let authMiddleware: Middleware = { req, next in
    print("Auth middleware")
    
    guard req.headers["authorization"] != nil else {
        return Response(status: 401, body: ["error": "Unauthorized"])
    }
    
    var mutableReq = req
    mutableReq.user = ["id": "123", "role": "user"]
    return await next()
}

let loggingMiddleware: Middleware = { req, next in
    print("\(req.method) \(req.url)")
    let response = await next()
    print("Response: \(response?.status ?? 0)")
    return response
}

// Usage
let chain = MiddlewareChain()
    .use(loggingMiddleware)
    .use(authMiddleware)

let request = Request(
    url: "/api/users",
    method: "GET",
    headers: ["authorization": "Bearer token123"]
)

let response = await chain.execute(request: request)
print(response)
```

---

## Dart

### Middleware Chain
```dart
class Request {
  final String url;
  final String method;
  final Map<String, String> headers;
  Map<String, dynamic>? user;
  dynamic body;

  Request({
    required this.url,
    required this.method,
    required this.headers,
    this.user,
    this.body,
  });
}

class Response {
  final int status;
  final dynamic body;

  Response(this.status, this.body);
}

typedef NextFunction = Future<Response?> Function();
typedef Middleware = Future<Response?> Function(Request request, NextFunction next);

class MiddlewareChain {
  final List<Middleware> _middlewares = [];

  MiddlewareChain use(Middleware middleware) {
    _middlewares.add(middleware);
    return this;
  }

  Future<Response> execute(Request request) async {
    var index = 0;

    Future<Response?> next() async {
      if (index >= _middlewares.length) {
        return Response(200, {'success': true});
      }

      final middleware = _middlewares[index++];
      return await middleware(request, next);
    }

    final response = await next();
    return response ?? Response(500, {'error': 'No response'});
  }
}

// Middleware functions
Future<Response?> authMiddleware(Request req, NextFunction next) async {
  print('Auth middleware');
  
  if (!req.headers.containsKey('authorization')) {
    return Response(401, {'error': 'Unauthorized'});
  }
  
  req.user = {'id': '123', 'role': 'user'};
  return await next();
}

Future<Response?> loggingMiddleware(Request req, NextFunction next) async {
  print('${req.method} ${req.url}');
  final response = await next();
  print('Response: ${response?.status}');
  return response;
}

// Usage
void main() async {
  final chain = MiddlewareChain()
    ..use(loggingMiddleware)
    ..use(authMiddleware);

  final request = Request(
    url: '/api/users',
    method: 'GET',
    headers: {'authorization': 'Bearer token123'},
  );

  final response = await chain.execute(request);
  print(response);
}
```
