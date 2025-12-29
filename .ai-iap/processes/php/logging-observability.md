# Logging & Observability Implementation Process - PHP

> **Purpose**: Establish production-grade logging, monitoring, and observability for PHP applications

> **Core Libraries**: Monolog, Prometheus, Sentry, OpenTelemetry

---

## Phase 1: Structured Logging

> **ALWAYS use**: Monolog ⭐
> **NEVER**: Use error_log() or var_dump() in production, log passwords/tokens/PII

**Install**:
```bash
composer require monolog/monolog
```

**Configuration**:
```php
use Monolog\Logger;
use Monolog\Handler\StreamHandler;
use Monolog\Formatter\JsonFormatter;

$logger = new Logger('app');
$handler = new StreamHandler('php://stdout', Logger::INFO);
$handler->setFormatter(new JsonFormatter());
$logger->pushHandler($handler);
```

**Correlation ID Middleware**:
```php
use Ramsey\Uuid\Uuid;

$correlationId = $_SERVER['HTTP_X_CORRELATION_ID'] ?? Uuid::uuid4()->toString();
header("X-Correlation-ID: $correlationId");

$logger->pushProcessor(function ($record) use ($correlationId) {
    $record['extra']['correlation_id'] = $correlationId;
    return $record;
});
```

> **Git**: `git commit -m "feat: add structured logging with Monolog"`

---

## Phase 2: Application Monitoring

> **ALWAYS include**:
- /health endpoint (database, Redis checks)
- Prometheus metrics (promphp/prometheus_client_php)
- Error tracking (Sentry ⭐)

**Health Check**:
```php
Route::get('/health', function () {
    $dbOk = DB::connection()->getPdo() !== null;
    return response()->json(['status' => $dbOk ? 'healthy' : 'unhealthy'], $dbOk ? 200 : 503);
});
```

**Sentry**:
```bash
composer require sentry/sentry-laravel
```

```php
\Sentry\init(['dsn' => env('SENTRY_DSN')]);
```

> **Git**: `git commit -m "feat: add health checks, metrics, and error tracking"`

---

## Phase 3: Distributed Tracing

> **ALWAYS use**: OpenTelemetry ⭐

**Install**:
```bash
composer require open-telemetry/sdk open-telemetry/exporter-otlp
```

> **Git**: `git commit -m "feat: add distributed tracing"`

---

## Phase 4: Log Aggregation & Alerts

> **ALWAYS use**: ELK Stack, Datadog, or CloudWatch

**Monolog Handler**: LogstashHandler or ElasticsearchHandler

**Alerts**: Error rate >1%, p99 latency >2s, health check failures

> **Git**: `git commit -m "feat: add log aggregation and alerting"`

---

## Framework-Specific Notes

### Laravel
- Monolog built-in (config/logging.php)
- Laravel Telescope for local debugging
- Laravel Health package for /health

### Symfony
- Monolog integration (config/packages/monolog.yaml)
- symfony/http-client for external health checks

---

## AI Self-Check

- [ ] Structured logging configured (Monolog, JSON)
- [ ] Correlation ID tracked
- [ ] No sensitive data in logs
- [ ] Health checks implemented
- [ ] Error tracking enabled (Sentry)
- [ ] Log aggregation setup
- [ ] Alerts created

---

**Process Complete** ✅

