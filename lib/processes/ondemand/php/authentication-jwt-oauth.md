# PHP Authentication (JWT/OAuth) - Copy This Prompt

> **Type**: One-time setup process  
> **When to use**: Implementing authentication for PHP API  
> **Instructions**: Copy the complete prompt below and paste into your AI tool

---

## 📋 Complete Self-Contained Prompt

```
========================================
PHP AUTHENTICATION - JWT/OAUTH
========================================

CONTEXT:
You are implementing JWT and OAuth authentication for a PHP application.

CRITICAL REQUIREMENTS:
- ALWAYS use password_hash() for passwords
- ALWAYS validate JWT tokens on protected routes
- NEVER store passwords in plain text
- NEVER expose JWT secrets

========================================
CATCH-UP: READ EXISTING DOCUMENTATION
========================================

BEFORE starting, check for existing documentation:
1. Read PROJECT-MEMORY.md, LOGIC-ANOMALIES.md, AUTH-SETUP.md if they exist

Use this to continue from where work stopped. If no docs: Start fresh.

========================================
PHASE 1 - JWT AUTHENTICATION
========================================

Install Firebase JWT library:

```bash
composer require firebase/php-jwt
```

Create JWT utility class:
```php
<?php

use Firebase\JWT\JWT;
use Firebase\JWT\Key;

class JwtUtil
{
    private string $secret;
    private string $issuer;
    private int $expiration;

    public function __construct()
    {
        $this->secret = $_ENV['JWT_SECRET'] ?? 'your-secret-key';
        $this->issuer = $_ENV['JWT_ISSUER'] ?? 'your-issuer';
        $this->expiration = 86400; // 24 hours
    }

    public function generateToken(int $userId, string $email): string
    {
        $payload = [
            'iss' => $this->issuer,
            'iat' => time(),
            'exp' => time() + $this->expiration,
            'userId' => $userId,
            'email' => $email
        ];

        return JWT::encode($payload, $this->secret, 'HS256');
    }

    public function validateToken(string $token): ?object
    {
        try {
            return JWT::decode($token, new Key($this->secret, 'HS256'));
        } catch (Exception $e) {
            return null;
        }
    }
}
```

Create auth middleware:
```php
<?php

class AuthMiddleware
{
    private JwtUtil $jwtUtil;

    public function __construct(JwtUtil $jwtUtil)
    {
        $this->jwtUtil = $jwtUtil;
    }

    public function handle($request, Closure $next)
    {
        $authHeader = $request->header('Authorization');
        
        if (!$authHeader || !str_starts_with($authHeader, 'Bearer ')) {
            return response()->json(['error' => 'Unauthorized'], 401);
        }

        $token = substr($authHeader, 7);
        $payload = $this->jwtUtil->validateToken($token);

        if (!$payload) {
            return response()->json(['error' => 'Invalid token'], 401);
        }

        $request->userId = $payload->userId;
        return $next($request);
    }
}
```

Deliverable: JWT utility configured

========================================
PHASE 2 - AUTH ENDPOINTS
========================================

Create auth controller:

```php
<?php

class AuthController
{
    private PDO $db;
    private JwtUtil $jwtUtil;

    public function register(Request $request): Response
    {
        $email = $request->post('email');
        $password = $request->post('password');

        // Validate input
        if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
            return response()->json(['error' => 'Invalid email'], 400);
        }

        // Check if user exists
        $stmt = $this->db->prepare('SELECT id FROM users WHERE email = :email');
        $stmt->execute(['email' => $email]);
        
        if ($stmt->fetch()) {
            return response()->json(['error' => 'User already exists'], 409);
        }

        // Hash password
        $hashedPassword = password_hash($password, PASSWORD_ARGON2ID);

        // Create user
        $stmt = $this->db->prepare('INSERT INTO users (email, password) VALUES (:email, :password)');
        $stmt->execute(['email' => $email, 'password' => $hashedPassword]);
        
        $userId = $this->db->lastInsertId();

        // Generate token
        $token = $this->jwtUtil->generateToken((int)$userId, $email);

        return response()->json(['token' => $token], 201);
    }

    public function login(Request $request): Response
    {
        $email = $request->post('email');
        $password = $request->post('password');

        // Find user
        $stmt = $this->db->prepare('SELECT id, email, password FROM users WHERE email = :email');
        $stmt->execute(['email' => $email]);
        $user = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$user || !password_verify($password, $user['password'])) {
            return response()->json(['error' => 'Invalid credentials'], 401);
        }

        // Generate token
        $token = $this->jwtUtil->generateToken($user['id'], $user['email']);

        return response()->json(['token' => $token]);
    }

    public function me(Request $request): Response
    {
        $userId = $request->userId; // Set by middleware

        $stmt = $this->db->prepare('SELECT id, email FROM users WHERE id = :id');
        $stmt->execute(['id' => $userId]);
        $user = $stmt->fetch(PDO::FETCH_ASSOC);

        return response()->json($user);
    }
}
```

Deliverable: Auth endpoints working

========================================
PHASE 3 - LARAVEL IMPLEMENTATION
========================================

For Laravel, use built-in features:

Install Laravel Sanctum:
```bash
composer require laravel/sanctum
php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider"
php artisan migrate
```

Configure in config/sanctum.php and use:
```php
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens;
}

// In AuthController
public function login(Request $request)
{
    if (!Auth::attempt($request->only('email', 'password'))) {
        return response()->json(['error' => 'Invalid credentials'], 401);
    }

    $user = Auth::user();
    $token = $user->createToken('auth_token')->plainTextToken;

    return response()->json(['token' => $token]);
}

// Protected routes
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/me', [AuthController::class, 'me']);
});
```

Deliverable: Laravel auth working

========================================
PHASE 4 - OAUTH 2.0 (OPTIONAL)
========================================

For Laravel with Socialite:

```bash
composer require laravel/socialite
```

Configure in config/services.php:
```php
'google' => [
    'client_id' => env('GOOGLE_CLIENT_ID'),
    'client_secret' => env('GOOGLE_CLIENT_SECRET'),
    'redirect' => 'http://localhost/auth/google/callback',
],
```

Create routes:
```php
Route::get('/auth/google', function () {
    return Socialite::driver('google')->redirect();
});

Route::get('/auth/google/callback', function () {
    $googleUser = Socialite::driver('google')->user();
    
    $user = User::updateOrCreate([
        'email' => $googleUser->email,
    ], [
        'name' => $googleUser->name,
        'google_id' => $googleUser->id,
    ]);
    
    $token = $user->createToken('auth_token')->plainTextToken;
    
    return response()->json(['token' => $token]);
});
```

Deliverable: OAuth configured

========================================
BEST PRACTICES
========================================

- Use password_hash() with ARGON2ID or BCRYPT
- Store JWT secrets in environment variables
- Use PDO prepared statements
- Set reasonable token expiry
- Implement refresh tokens
- Add rate limiting
- Use HTTPS only
- Validate input thoroughly
- Use Laravel Sanctum for Laravel projects

========================================
DOCUMENTATION
========================================

Create/update: PROJECT-MEMORY.md, LOGIC-ANOMALIES.md, AUTH-SETUP.md

========================================
EXECUTION
========================================

START: Read existing docs (CATCH-UP section)
CONTINUE: Configure JWT (Phase 1)
CONTINUE: Create auth endpoints (Phase 2)
ALTERNATIVE: Use Laravel (Phase 3)
OPTIONAL: Add OAuth (Phase 4)
FINISH: Update all documentation files
REMEMBER: password_hash, PDO prepared statements, document for catch-up
```

---

## Quick Reference

**What you get**: Complete JWT/OAuth authentication for PHP  
**Time**: 3-4 hours  
**Output**: Auth service, protected routes, OAuth
