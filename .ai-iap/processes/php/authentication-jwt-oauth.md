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

