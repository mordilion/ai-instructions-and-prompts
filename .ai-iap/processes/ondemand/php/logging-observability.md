# PHP Logging & Observability - Copy This Prompt

> **Type**: One-time setup process  
> **When to use**: Setting up production logging and monitoring  
> **Instructions**: Copy the complete prompt below and paste into your AI tool

---

## 📋 Complete Self-Contained Prompt

```
========================================
PHP LOGGING & OBSERVABILITY
========================================

CONTEXT:
You are implementing production-grade logging and observability for a PHP application.

CRITICAL REQUIREMENTS:
- ALWAYS use Monolog (PSR-3 standard)
- NEVER log sensitive data (PII, tokens, passwords)
- Use structured logging with context
- Integrate error tracking (Sentry, Bugsnag)

========================================
PHASE 1 - STRUCTURED LOGGING
========================================

Install Monolog:
```bash
composer require monolog/monolog
```

Configure basic logging:
```php
use Monolog\Logger;
use Monolog\Handler\StreamHandler;
use Monolog\Formatter\JsonFormatter;

$log = new Logger('app');

// Console handler for development
$consoleHandler = new StreamHandler('php://stdout', Logger::DEBUG);

// File handler for production
$fileHandler = new StreamHandler('/var/log/app.log', Logger::INFO);
$fileHandler->setFormatter(new JsonFormatter());

$log->pushHandler($fileHandler);
$log->pushHandler($consoleHandler);

// Usage
$log->info('User created', ['userId' => $user->id]);
$log->error('Database error', [
    'error' => $e->getMessage(),
    'userId' => $user->id
]);
```

Deliverable: Structured logging implemented

========================================
PHASE 2 - CONTEXT PROCESSORS
========================================

Add context to all logs:

```php
use Monolog\Processor\WebProcessor;
use Monolog\Processor\MemoryUsageProcessor;
use Monolog\Processor\ProcessIdProcessor;

$log->pushProcessor(new WebProcessor());
$log->pushProcessor(new MemoryUsageProcessor());
$log->pushProcessor(new ProcessIdProcessor());

// Custom processor for request ID
$log->pushProcessor(function ($record) {
    $record['extra']['requestId'] = $_SERVER['HTTP_X_REQUEST_ID'] ?? uniqid();
    return $record;
});
```

Deliverable: Enriched logging context

========================================
PHASE 3 - ERROR TRACKING
========================================

Install Sentry:

```bash
composer require sentry/sentry
```

Configure:
```php
\Sentry\init([
    'dsn' => 'YOUR_DSN',
    'environment' => 'production',
    'traces_sample_rate' => 0.1,
]);

// Catch and report errors
try {
    riskyOperation();
} catch (\Exception $e) {
    \Sentry\captureException($e);
    throw $e;
}

// Add user context
\Sentry\configureScope(function (\Sentry\State\Scope $scope) use ($user) {
    $scope->setUser([
        'id' => $user->id,
        'email' => $user->email,
    ]);
});
```

Integrate with Monolog:
```php
use Monolog\Handler\SentryHandler;

$sentryHandler = new SentryHandler(
    \Sentry\ClientBuilder::create(['dsn' => 'YOUR_DSN'])->getClient(),
    Logger::ERROR
);
$log->pushHandler($sentryHandler);
```

Deliverable: Error tracking active

========================================
PHASE 4 - APPLICATION MONITORING
========================================

Add basic health endpoint:

```php
// health.php
header('Content-Type: application/json');

$checks = [
    'database' => checkDatabase(),
    'redis' => checkRedis(),
    'disk' => checkDiskSpace(),
];

$status = array_filter($checks) === $checks ? 'healthy' : 'unhealthy';

echo json_encode([
    'status' => $status,
    'checks' => $checks,
    'timestamp' => time()
]);
```

Use Laravel Horizon for queue monitoring:
```bash
composer require laravel/horizon
php artisan horizon:install
```

Deliverable: Health monitoring active

========================================
BEST PRACTICES
========================================

- Use Monolog (PSR-3 standard)
- Never log sensitive data
- Use JSON formatter in production
- Add context processors
- Integrate Sentry for error tracking
- Add health check endpoints
- Monitor queue workers
- Review logs regularly

========================================
EXECUTION
========================================

START: Implement Monolog (Phase 1)
CONTINUE: Add context processors (Phase 2)
CONTINUE: Add Sentry (Phase 3)
OPTIONAL: Add monitoring (Phase 4)
REMEMBER: JSON format, no sensitive data
```

---

## Quick Reference

**What you get**: Production logging with error tracking and monitoring  
**Time**: 2-3 hours  
**Output**: Monolog configuration, Sentry integration, health checks
