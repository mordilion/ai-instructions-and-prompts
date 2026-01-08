# Logging & Observability Implementation Process - PHP

> **Purpose**: Establish production-grade logging, monitoring, and observability

---

## Prerequisites

> **BEFORE starting**:
> - Working PHP application
> - Git repository

---

## Phase 1: Structured Logging

**Branch**: `logging/structured`

### 1.1 Use Monolog

> **ALWAYS use**: **Monolog** ⭐ (PSR-3 compliant)

**Install**:
```bash
composer require monolog/monolog
```

**Configure**:
```php
use Monolog\Logger;
use Monolog\Handler\StreamHandler;
use Monolog\Formatter\JsonFormatter;

$logger = new Logger('app');
$handler = new StreamHandler('php://stdout', Logger::INFO);
$handler->setFormatter(new JsonFormatter());
$logger->pushHandler($handler);
```

**Laravel**: Built-in, uses Monolog

### 1.2 Add Correlation IDs

**Middleware**:
```php
class CorrelationIdMiddleware
{
    public function handle($request, Closure $next)
    {
        $correlationId = $request->header('X-Correlation-ID', Str::uuid());
        $request->attributes->set('correlation_id', $correlationId);
        
        Log::shareContext(['correlation_id' => $correlationId]);
        
        $response = $next($request);
        $response->headers->set('X-Correlation-ID', $correlationId);
        return $response;
    }
}
```

**Verify**: Structured logs (JSON), correlation IDs tracked

---

## Phase 2: Application Monitoring

**Branch**: `logging/monitoring`

### 2.1 Health Checks

**Laravel**:
```bash
composer require spatie/laravel-health
```

**Symfony**: FOSHealthCheckBundle

### 2.2 Metrics

**Install**:
```bash
composer require promphp/prometheus_client_php
```

### 2.3 Error Tracking

> **ALWAYS use**: **Sentry** ⭐ or Bugsnag

**Sentry**:
```bash
composer require sentry/sentry-laravel
```

```php
Sentry\init(['dsn' => env('SENTRY_DSN')]);
```

**Verify**: Health checks, metrics exposed, errors tracked

---

## Phase 3: Distributed Tracing

**Branch**: `logging/tracing`

### 3.1 OpenTelemetry

**Install**:
```bash
composer require open-telemetry/opentelemetry
```

**Verify**: Traces collected

---

## Phase 4: Log Aggregation

**Branch**: `logging/aggregation`

### 4.1 Log Shipping

> **Options**: ELK Stack, Datadog, CloudWatch, Papertrail

**Monolog + Logstash**:
```php
use Monolog\Handler\SocketHandler;

$handler = new SocketHandler('tcp://logstash:5000');
$logger->pushHandler($handler);
```

### 4.2 Alerts

> **Alert on**: Error rate >1%, p99 >2s, Health failures

**Verify**: Logs aggregated, alerts configured

---

## Framework Notes

| Framework | Logger | Health |
|-----------|--------|--------|
| **Laravel** | Monolog (built-in) | spatie/laravel-health |
| **Symfony** | Monolog | FOSHealthCheckBundle |

---

## Best Practices

### What to Log/Not Log
> **ALWAYS**: Structured data, Request/response, Auth events

> **NEVER**: Passwords, API keys, Credit cards, PII

---

## AI Self-Check

- [ ] Monolog configured
- [ ] Structured logging (JSON)
- [ ] Correlation IDs tracked
- [ ] No sensitive data logged
- [ ] Health checks implemented
- [ ] Metrics exposed
- [ ] Error tracking configured
- [ ] Log aggregation configured

---

**Process Complete** ✅

## Usage - Copy This Complete Prompt

> **Type**: One-time setup process (multi-phase)  
> **When to use**: When setting up logging and monitoring infrastructure

### Complete Implementation Prompt

```
CONTEXT:
You are implementing logging and observability infrastructure for this project.

CRITICAL REQUIREMENTS:
- ALWAYS use structured logging (JSON format)
- ALWAYS include correlation IDs for request tracing
- ALWAYS configure log levels per environment
- NEVER log sensitive data (PII, passwords, tokens)
- Use team's Git workflow

IMPLEMENTATION PHASES:

PHASE 1 - STRUCTURED LOGGING:
1. Choose logging library for the language
2. Configure structured logging (JSON output)
3. Set up log levels (DEBUG, INFO, WARN, ERROR)
4. Add correlation ID middleware/decorator

Deliverable: Structured logging configured

PHASE 2 - LOG AGGREGATION:
1. Configure log shipping (Filebeat, Fluentd, etc.)
2. Set up centralized logging (ELK, Loki, CloudWatch)
3. Create log retention policies
4. Set up log search and filtering

Deliverable: Centralized log aggregation

PHASE 3 - MONITORING & ALERTS:
1. Define key metrics to track
2. Set up health check endpoints
3. Configure alerting rules
4. Set up dashboards

Deliverable: Monitoring and alerting active

START: Choose logging library, configure structured logging.
```
