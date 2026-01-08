# Authentication Setup Process - PHP

> **Purpose**: Implement secure authentication and authorization in PHP applications

> **Core Stack**: password_hash/password_verify, JWT (firebase/php-jwt), OAuth (league/oauth2)

---

## Phase 1: Password Hashing

> **ALWAYS use**: password_hash() with PASSWORD_BCRYPT or PASSWORD_ARGON2ID
> **NEVER**: md5(), sha1(), crypt() without salt

**Password Functions**:
```php
function hashPassword(string $password): string {
    return password_hash($password, PASSWORD_ARGON2ID); // or PASSWORD_BCRYPT
}

function verifyPassword(string $password, string $hash): bool {
    return password_verify($password, $hash);
}
```

> **Git**: `git commit -m "feat: add password hashing"`

---

## Phase 2: JWT Authentication

> **ALWAYS use**: firebase/php-jwt library

**Install** (Composer):
```bash
composer require firebase/php-jwt
```

**JWT Functions**:
```php
use Firebase\JWT\JWT;
use Firebase\JWT\Key;

function generateToken(int $userId): string {
    $secret = $_ENV['JWT_SECRET'];
    $payload = [
        'sub' => $userId,
        'iat' => time(),
        'exp' => time() + 3600 // 1 hour
    ];
    return JWT::encode($payload, $secret, 'HS256');
}

function verifyToken(string $token): object {
    $secret = $_ENV['JWT_SECRET'];
    return JWT::decode($token, new Key($secret, 'HS256'));
}
```

**Middleware** (Laravel):
```php
public function handle(Request $request, Closure $next) {
    $token = $request->bearerToken();
    
    if (!$token) {
        return response()->json(['error' => 'Unauthorized'], 401);
    }
    
    try {
        $payload = verifyToken($token);
        $request->merge(['user_id' => $payload->sub]);
        return $next($request);
    } catch (\Exception $e) {
        return response()->json(['error' => 'Invalid token'], 401);
    }
}
```

> **Git**: `git commit -m "feat: add JWT authentication"`

---

## Phase 3: OAuth 2.0 / Social Login

> **ALWAYS use**: league/oauth2-client or Laravel Socialite

**Install** (Laravel Socialite):
```bash
composer require laravel/socialite
```

**Configure** (config/services.php):
```php
'google' => [
    'client_id' => env('GOOGLE_CLIENT_ID'),
    'client_secret' => env('GOOGLE_CLIENT_SECRET'),
    'redirect' => env('GOOGLE_REDIRECT_URI'),
],
```

**Controller**:
```php
use Laravel\Socialite\Facades\Socialite;

public function redirectToGoogle() {
    return Socialite::driver('google')->redirect();
}

public function handleGoogleCallback() {
    $googleUser = Socialite::driver('google')->user();
    
    $user = User::updateOrCreate([
        'email' => $googleUser->getEmail(),
    ], [
        'name' => $googleUser->getName(),
        'google_id' => $googleUser->getId(),
    ]);
    
    $token = generateToken($user->id);
    return response()->json(['access_token' => $token]);
}
```

> **Git**: `git commit -m "feat: add OAuth 2.0 (Google)"`

---

## Phase 4: Authorization & RBAC

### Laravel

> **ALWAYS use**: Gates and Policies

**Define Gate**:
```php
// App\Providers\AuthServiceProvider
Gate::define('delete-user', function (User $user, User $targetUser) {
    return $user->role === 'admin';
});
```

**Middleware**:
```php
Route::delete('/users/{id}', [UserController::class, 'destroy'])
    ->middleware('can:delete-user');
```

**Policy**:
```php
php artisan make:policy PostPolicy

// PostPolicy
public function update(User $user, Post $post) {
    return $user->id === $post->user_id || $user->role === 'admin';
}
```

### Symfony

> **ALWAYS use**: Security Voters

**Voter**:
```php
class PostVoter extends Voter {
    protected function supports(string $attribute, mixed $subject): bool {
        return in_array($attribute, ['POST_EDIT', 'POST_DELETE'])
            && $subject instanceof Post;
    }
    
    protected function voteOnAttribute(string $attribute, mixed $subject, TokenInterface $token): bool {
        $user = $token->getUser();
        
        if ($attribute === 'POST_DELETE') {
            return $user->getRole() === 'ROLE_ADMIN';
        }
        
        return $user->getId() === $subject->getUserId();
    }
}
```

> **Git**: `git commit -m "feat: add role-based authorization"`

---

## Phase 5: Security Hardening

> **ALWAYS implement**:
> - Rate limiting (Laravel: throttle middleware, Symfony: rate limiter)
> - CORS configuration
> - HTTPS enforcement
> - CSRF protection (if using sessions)

**Rate Limiting** (Laravel):
```php
Route::post('/login', [AuthController::class, 'login'])
    ->middleware('throttle:5,15'); // 5 attempts per 15 minutes
```

**CORS** (Laravel):
```bash
php artisan config:publish cors
```

**Security Headers** (middleware):
```php
public function handle(Request $request, Closure $next) {
    $response = $next($request);
    
    $response->headers->set('X-Content-Type-Options', 'nosniff');
    $response->headers->set('X-Frame-Options', 'DENY');
    $response->headers->set('X-XSS-Protection', '1; mode=block');
    
    return $response;
}
```

> **Git**: `git commit -m "feat: add authentication security hardening"`

---

## Framework-Specific Notes

### Laravel
- Built-in authentication scaffolding (Breeze, Jetstream)
- Laravel Sanctum for API tokens
- Laravel Passport for full OAuth 2.0 server

### Symfony
- Security component for authentication
- Voters for authorization
- LexikJWTAuthenticationBundle for JWT

---

## AI Self-Check

- [ ] Passwords hashed with password_hash()
- [ ] JWT configured with secret
- [ ] Access tokens expire in ≤1h
- [ ] OAuth configured (if needed)
- [ ] Authorization (Gates/Policies) implemented
- [ ] Rate limiting enabled
- [ ] HTTPS enforced
- [ ] Security headers configured

---

**Process Complete** ✅


## Usage - Copy This Complete Prompt

> **Type**: One-time setup process (multi-phase)  
> **When to use**: When implementing authentication system with JWT and OAuth

### Complete Implementation Prompt

```
CONTEXT:
You are implementing authentication system with JWT and OAuth for this project.

CRITICAL REQUIREMENTS:
- ALWAYS use strong JWT secret (min 256 bits, from environment variable)
- ALWAYS set appropriate token expiration (15-60 minutes for access, days for refresh)
- ALWAYS validate tokens on protected endpoints
- ALWAYS hash passwords with bcrypt/Argon2
- NEVER store passwords in plain text
- NEVER commit secrets to version control
- Use team's Git workflow

IMPLEMENTATION PHASES:

PHASE 1 - JWT AUTHENTICATION:
1. Install JWT library
2. Configure JWT secret (from environment variable)
3. Implement token generation (login endpoint)
4. Implement token validation middleware
5. Set up token expiration and refresh mechanism

Deliverable: JWT authentication working

PHASE 2 - USER MANAGEMENT:
1. Create User model/entity
2. Implement password hashing
3. Create registration endpoint
4. Create login endpoint
5. Implement password reset flow

Deliverable: User management complete

PHASE 3 - OAUTH INTEGRATION (Optional):
1. Choose OAuth providers (Google, GitHub, etc.)
2. Register application with providers
3. Implement OAuth callback handling
4. Link OAuth accounts with local users

Deliverable: OAuth authentication working

PHASE 4 - ROLE-BASED ACCESS CONTROL:
1. Define user roles
2. Implement role checking middleware
3. Protect endpoints by role
4. Add role management endpoints

Deliverable: RBAC implemented

SECURITY BEST PRACTICES:
- Use HTTPS only in production
- Implement rate limiting
- Add account lockout after failed attempts
- Log authentication events
- Use secure cookie flags (httpOnly, secure, sameSite)

START: Execute Phase 1. Install JWT library and configure token generation.
```
