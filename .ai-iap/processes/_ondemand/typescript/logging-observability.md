# Logging & Observability Implementation Process - TypeScript/Node.js

> **Purpose**: Establish production-grade logging, monitoring, and observability

---

## Prerequisites

> **BEFORE starting**:
> - Working application with basic error handling
> - Git repository
> - Understanding of log levels (debug, info, warn, error)

---

## Phase 1: Structured Logging

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
```

### 1.2 Configure Logger & Request ID

> **ALWAYS**: JSON format, timestamp, log level, context (requestId, userId), separate transports
> **NEVER**: Log sensitive data (passwords, tokens, PII), use sync logging

```typescript
import winston from 'winston';
import { v4 as uuidv4 } from 'uuid';

// Logger
export const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || 'info',
  format: winston.format.combine(winston.format.timestamp(), winston.format.json()),
  defaultMeta: { service: 'my-app' },
  transports: [new winston.transports.Console(), new winston.transports.File({ filename: 'error.log', level: 'error' })]
});

// Request ID middleware
app.use((req, res, next) => {
  req.id = req.headers['x-correlation-id'] || uuidv4();
  res.setHeader('X-Correlation-ID', req.id);
  logger.info('Request', { requestId: req.id, method: req.method, path: req.path });
  next();
});
```

**Verify**: Logs as JSON with timestamp and request ID

---

## Phase 2: Application Monitoring

**Branch**: `logging/monitoring`

### 2.1 Health Check Endpoint

> **ALWAYS include**:
> - /health or /healthz endpoint
> - Check database connectivity
> - Check external dependencies (Redis, APIs)
> - Return HTTP 200 if healthy, 503 if unhealthy

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

### 2.2 Metrics (Prometheus)

> **Track**: Request count, response time (p50/p95/p99), error rate, memory/CPU

```typescript
import promClient from 'prom-client';

const register = new promClient.Register();
promClient.collectDefaultMetrics({ register });
const httpDuration = new promClient.Histogram({ name: 'http_request_duration_seconds', labelNames: ['method', 'route', 'status_code'], registers: [register] });

app.get('/metrics', async (req, res) => res.set('Content-Type', register.contentType).end(await register.metrics()));
```

### 2.3 Error Tracking (Sentry)

```typescript
import * as Sentry from '@sentry/node';

Sentry.init({ dsn: process.env.SENTRY_DSN, environment: process.env.NODE_ENV,
  tracesSampleRate: 0.1
});

app.use(Sentry.Handlers.requestHandler());
app.use(Sentry.Handlers.tracingHandler());
// ... routes ...
app.use(Sentry.Handlers.errorHandler());
```

**Verify**: /health endpoint returns correct status, /metrics exposes Prometheus metrics, errors sent to Sentry, no performance degradation

---

## Phase 3: Distributed Tracing

**Branch**: `logging/tracing`

### 3.1 Install Tracing Library

> **ALWAYS use**: **OpenTelemetry** ⭐ (vendor-neutral), Jaeger, Zipkin, or Datadog APM

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

**Verify**: Traces visible in UI (Jaeger/Zipkin/Datadog), trace ID propagated across services, spans show correct timing, overhead <5% CPU

---

## Phase 4: Log Aggregation & Alerts

**Branch**: `logging/aggregation`

### 4.1 Configure Log Shipping

> **ALWAYS use** (pick one):
> - **ELK Stack** (Elasticsearch + Logstash + Kibana)
> - **Datadog** ⭐ (managed, expensive)
> - **CloudWatch Logs** (AWS)
> - **Azure Monitor** (Azure)
> - **Google Cloud Logging** (GCP)

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

> **NEVER**: Alert on every error (use thresholds), create alerts without runbooks, forget to test alert delivery

### 4.3 Add Dashboards

> **ALWAYS include**:
> - Request rate, error rate, duration (RED metrics)
> - CPU, memory, disk usage
> - Database query performance
> - Cache hit rate
> - Business metrics (signups, orders, etc.)

**Verify**: Logs visible in aggregation service, alerts trigger correctly, dashboards show real-time data, runbooks documented

---

## Framework-Specific Notes

| Framework | Logger | Health Checks | Notes |
|-----------|--------|---------------|-------|
| **Express.js** | Winston + morgan | Custom middleware | Use morgan for HTTP logging |
| **NestJS** | Built-in Logger | @nestjs/terminus | Interceptors for request/response logging |
| **Next.js** | Winston | API route | Server-side logging only |
| **Fastify** | Built-in Pino | Hooks | onRequest, onResponse hooks |

---

## Best Practices

### Log Levels
| Level | Use Case | Example |
|-------|----------|---------|
| **DEBUG** | Detailed troubleshooting info | Variable values, function entry/exit |
| **INFO** | General informational messages | Request received, operation completed |
| **WARN** | Warning messages, app can continue | Deprecated API usage, fallback used |
| **ERROR** | Error messages, operation failed | Database connection failed, validation error |

### What to Log
> **ALWAYS log**: Request/response (method, path, status, duration), Errors with stack traces, Authentication events, Business events (payment, order), Performance metrics

> **NEVER log**: Passwords/tokens/API keys, PII without consent (email, phone, SSN), Credit card numbers, Session IDs

### Performance
> **ALWAYS**: Use async logging (non-blocking), Sample high-frequency logs (10% of requests), Rotate log files, Set log retention policy (30-90 days)

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| **Logs not appearing** | Check log level, verify transport configuration, ensure logger initialized before use |
| **High memory usage** | Implement log rotation, reduce log verbosity, check for memory leaks in custom transports |
| **Missing correlation IDs** | Ensure middleware runs before route handlers, check async context propagation |
| **Metrics endpoint slow** | Cache metrics, reduce cardinality, sample high-frequency metrics |

---

## AI Self-Check

- [ ] Structured logging configured (JSON format)
- [ ] Log levels properly used (debug, info, warn, error)
- [ ] Request ID/correlation ID tracked across requests
- [ ] No sensitive data in logs
- [ ] Health check endpoint implemented
- [ ] Metrics endpoint exposed (/metrics)
- [ ] Error tracking configured (Sentry/Rollbar)
- [ ] Distributed tracing enabled (if microservices)
- [ ] Log aggregation configured
- [ ] Alerts created with appropriate thresholds

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
