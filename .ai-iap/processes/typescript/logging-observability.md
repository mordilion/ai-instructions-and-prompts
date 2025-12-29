# Logging & Observability Implementation Process - TypeScript/Node.js

> **Purpose**: Establish production-grade logging, monitoring, and observability for TypeScript/Node.js applications

---

## Prerequisites

> **BEFORE starting**:
> - Working application with basic error handling
> - Git repository
> - Understanding of log levels (debug, info, warn, error)

---

## Phase 1: Structured Logging

### Branch Strategy
```
main → logging/structured
```

### 1.1 Install Logging Library

> **ALWAYS use** (pick one):
> - **Winston** ⭐ (most popular, flexible)
> - **Pino** (fastest, minimal overhead)
> - **Bunyan** (JSON-first)

> **NEVER**:
> - Use console.log/console.error in production
> - Log sensitive data (passwords, tokens, PII)
> - Use synchronous logging (blocks event loop)

**Install Winston**:
```bash
npm install winston
npm install --save-dev @types/winston
```

### 1.2 Configure Structured Logger

> **ALWAYS include**:
> - JSON format for machine parsing
> - Timestamp (ISO 8601)
> - Log level (debug, info, warn, error)
> - Context/metadata (requestId, userId, service name)
> - Separate transports (console, file, external service)

> **NEVER**:
> - Use plain text format in production
> - Mix structured and unstructured logs
> - Log entire objects without sanitization

**Winston Configuration**:
```typescript
// src/utils/logger.ts
import winston from 'winston';

export const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.errors({ stack: true }),
    winston.format.json()
  ),
  defaultMeta: { service: 'my-app' },
  transports: [
    new winston.transports.Console(),
    new winston.transports.File({ filename: 'error.log', level: 'error' }),
    new winston.transports.File({ filename: 'combined.log' })
  ]
});
```

### 1.3 Add Request ID Middleware

> **ALWAYS**:
> - Generate unique ID per request (UUID v4)
> - Attach to request object
> - Include in all logs for that request
> - Use correlation ID from headers (X-Correlation-ID) if available

**Express Middleware**:
```typescript
import { v4 as uuidv4 } from 'uuid';

app.use((req, res, next) => {
  req.id = req.headers['x-correlation-id'] || uuidv4();
  res.setHeader('X-Correlation-ID', req.id);
  logger.info('Incoming request', { 
    requestId: req.id, 
    method: req.method, 
    path: req.path 
  });
  next();
});
```

### 1.4 Commit & Verify

> **Git workflow**:
> ```
> git add src/utils/logger.ts package.json
> git commit -m "feat: add structured logging with Winston"
> git push origin logging/structured
> ```

> **Verify**:
> - Logs output as JSON
> - Timestamp present in each log
> - Request ID tracked across logs
> - No sensitive data in logs

---

## Phase 2: Application Monitoring

### Branch Strategy
```
main → logging/monitoring
```

### 2.1 Add Health Check Endpoint

> **ALWAYS include**:
> - /health or /healthz endpoint
> - Check database connectivity
> - Check external dependencies (Redis, APIs)
> - Return HTTP 200 if healthy, 503 if unhealthy

> **NEVER**:
> - Expose detailed error messages to public
> - Skip timeout on dependency checks
> - Return 200 when critical services are down

**Health Check Example**:
```typescript
app.get('/health', async (req, res) => {
  const checks = {
    database: await checkDatabase(),
    redis: await checkRedis(),
    uptime: process.uptime()
  };
  
  const healthy = Object.values(checks).every(c => c === true || typeof c === 'number');
  res.status(healthy ? 200 : 503).json(checks);
});
```

### 2.2 Add Metrics Collection

> **ALWAYS use** (pick one):
> - **Prometheus** ⭐ (industry standard)
> - **StatsD** (simple, lightweight)
> - **OpenTelemetry** (future-proof)

> **Key metrics to track**:
> - Request count (by route, status code)
> - Response time (p50, p95, p99)
> - Error rate
> - Active connections
> - Memory/CPU usage

**Prometheus with prom-client**:
```bash
npm install prom-client
```

```typescript
import promClient from 'prom-client';

const register = new promClient.Register();
promClient.collectDefaultMetrics({ register });

const httpRequestDuration = new promClient.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status_code'],
  registers: [register]
});

app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});
```

### 2.3 Add Error Tracking

> **ALWAYS use** (pick one):
> - **Sentry** ⭐ (comprehensive, easy setup)
> - **Rollbar**
> - **Bugsnag**

> **NEVER**:
> - Catch errors without logging
> - Send PII to error tracking
> - Ignore unhandled promise rejections

**Sentry Setup**:
```bash
npm install @sentry/node @sentry/tracing
```

```typescript
import * as Sentry from '@sentry/node';

Sentry.init({
  dsn: process.env.SENTRY_DSN,
  environment: process.env.NODE_ENV,
  tracesSampleRate: 0.1
});

app.use(Sentry.Handlers.requestHandler());
app.use(Sentry.Handlers.tracingHandler());
// ... routes ...
app.use(Sentry.Handlers.errorHandler());
```

### 2.4 Commit & Verify

> **Git workflow**:
> ```
> git add src/
> git commit -m "feat: add health checks, metrics, and error tracking"
> git push origin logging/monitoring
> ```

> **Verify**:
> - /health endpoint returns correct status
> - /metrics endpoint exposes Prometheus metrics
> - Errors sent to Sentry
> - No performance degradation

---

## Phase 3: Distributed Tracing

### Branch Strategy
```
main → logging/tracing
```

### 3.1 Install Tracing Library

> **ALWAYS use**:
> - **OpenTelemetry** ⭐ (vendor-neutral)
> - **Jaeger** (self-hosted)
> - **Zipkin** (self-hosted)
> - **Datadog APM** (managed service)

**OpenTelemetry Setup**:
```bash
npm install @opentelemetry/api @opentelemetry/sdk-node @opentelemetry/auto-instrumentations-node
```

### 3.2 Configure Distributed Tracing

> **ALWAYS include**:
> - Trace ID propagation across services
> - Span for each major operation (DB query, HTTP call, business logic)
> - Contextual attributes (user ID, tenant ID)
> - Sampling strategy (not 100% in production)

**OpenTelemetry Configuration**:
```typescript
import { NodeSDK } from '@opentelemetry/sdk-node';
import { getNodeAutoInstrumentations } from '@opentelemetry/auto-instrumentations-node';

const sdk = new NodeSDK({
  serviceName: 'my-app',
  traceExporter: /* Jaeger/Zipkin/OTLP exporter */,
  instrumentations: [getNodeAutoInstrumentations()]
});

sdk.start();
```

### 3.3 Add Custom Spans

> **ALWAYS**:
> - Create spans for business-critical operations
> - Add relevant attributes (query, result size, cache hit/miss)
> - Record exceptions in spans
> - End spans in finally blocks

### 3.4 Commit & Verify

> **Git workflow**:
> ```
> git add src/
> git commit -m "feat: add distributed tracing with OpenTelemetry"
> git push origin logging/tracing
> ```

> **Verify**:
> - Traces visible in UI (Jaeger/Zipkin/Datadog)
> - Trace ID propagated across services
> - Spans show correct timing
> - No excessive overhead (<5% CPU)

---

## Phase 4: Log Aggregation & Alerts

### Branch Strategy
```
main → logging/aggregation
```

### 4.1 Configure Log Shipping

> **ALWAYS use** (pick one):
> - **ELK Stack** (Elasticsearch + Logstash + Kibana)
> - **Datadog** ⭐ (managed, expensive)
> - **CloudWatch Logs** (AWS)
> - **Azure Monitor** (Azure)
> - **Google Cloud Logging** (GCP)

> **NEVER**:
> - Rely only on local file logs
> - Ship logs without rate limiting
> - Forget to rotate log files

**Winston + Datadog**:
```bash
npm install winston-datadog-logs
```

```typescript
import { DatadogTransport } from 'winston-datadog-logs';

logger.add(new DatadogTransport({
  apiKey: process.env.DATADOG_API_KEY,
  service: 'my-app',
  ddsource: 'nodejs',
  ddtags: `env:${process.env.NODE_ENV}`
}));
```

### 4.2 Create Alerts

> **ALWAYS alert on**:
> - Error rate threshold (>1% of requests)
> - Response time p99 >2s
> - Health check failures
> - High memory/CPU usage (>80%)
> - Unhandled exceptions

> **NEVER**:
> - Alert on every error (use thresholds)
> - Create alerts without runbooks
> - Forget to test alert delivery

### 4.3 Add Dashboards

> **ALWAYS include**:
> - Request rate, error rate, duration (RED metrics)
> - CPU, memory, disk usage
> - Database query performance
> - Cache hit rate
> - Business metrics (signups, orders, etc.)

### 4.4 Commit & Verify

> **Git workflow**:
> ```
> git add src/
> git commit -m "feat: add log aggregation and alerting"
> git push origin logging/aggregation
> ```

> **Verify**:
> - Logs visible in aggregation service
> - Alerts trigger correctly
> - Dashboards show real-time data
> - Runbooks documented

---

## Framework-Specific Notes

### Express.js
- Use morgan for HTTP logging
- Middleware: logger, metrics, error handler
- Context: req.id for correlation

### NestJS
- Built-in Logger service
- Interceptors for request/response logging
- Use @nestjs/terminus for health checks

### Next.js
- Server-side logging only
- Use next-logger or winston
- API routes: add logging middleware

### Fastify
- Built-in logging with Pino
- Hooks: onRequest, onResponse
- Decorators for request context

---

## Best Practices

### Log Levels
- **DEBUG**: Detailed info for troubleshooting
- **INFO**: General informational messages
- **WARN**: Warning messages, app can continue
- **ERROR**: Error messages, operation failed
- **FATAL**: Critical errors, app cannot continue

### What to Log
> **ALWAYS log**:
> - Request/response (method, path, status, duration)
> - Errors with stack traces
> - Authentication events (login, logout, failures)
> - Business events (payment, order, signup)
> - Performance metrics

> **NEVER log**:
> - Passwords, tokens, API keys
> - PII without consent (email, phone, SSN)
> - Credit card numbers
> - Session IDs

### Performance
> **ALWAYS**:
> - Use async logging (non-blocking)
> - Sample high-frequency logs (e.g., 10% of requests)
> - Rotate log files to prevent disk filling
> - Set log retention policy (30-90 days)

---

## AI Self-Check

Before completing this process, verify:

- [ ] Structured logging configured (JSON format)
- [ ] Log levels properly used (debug, info, warn, error)
- [ ] Request ID/correlation ID tracked
- [ ] No sensitive data in logs
- [ ] Health check endpoint implemented
- [ ] Metrics endpoint exposed (/metrics)
- [ ] Error tracking configured (Sentry/Rollbar)
- [ ] Distributed tracing enabled (if microservices)
- [ ] Log aggregation configured
- [ ] Alerts created with thresholds
- [ ] Dashboards created for monitoring
- [ ] Runbooks documented for alerts
- [ ] Log rotation configured
- [ ] Performance impact minimal (<5%)

---

## Bug Logging

> **ALWAYS log bugs found during logging setup**:
> - Create ticket/issue for each bug
> - Tag with `bug`, `observability`, `infrastructure`
> - **NEVER fix production code during logging setup**
> - Link bug to logging implementation branch

---

## Final Commit

```bash
git checkout main
git merge logging/aggregation
git tag -a v1.0.0-logging -m "Logging and observability implemented"
git push origin main --tags
```

---

**Process Complete** ✅

