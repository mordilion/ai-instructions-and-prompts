# TypeScript Logging & Observability - Copy This Prompt

> **Type**: One-time setup process  
> **When to use**: Setting up production logging and monitoring  
> **Instructions**: Copy the complete prompt below and paste into your AI tool

---

## 📋 Complete Self-Contained Prompt

```
========================================
TYPESCRIPT LOGGING & OBSERVABILITY
========================================

CONTEXT:
You are implementing production-grade logging and observability for a TypeScript/Node.js application.

CRITICAL REQUIREMENTS:
- ALWAYS use winston or pino for logging
- NEVER log sensitive data (PII, tokens, passwords)
- Use structured logging (JSON format)
- Integrate error tracking (Sentry)

========================================
PHASE 1 - STRUCTURED LOGGING
========================================

Install winston:
```bash
npm install winston
```

Configure:
```typescript
import winston from 'winston';

const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.errors({ stack: true }),
    winston.format.json()
  ),
  transports: [
    new winston.transports.Console({
      format: winston.format.combine(
        winston.format.colorize(),
        winston.format.simple()
      )
    }),
    new winston.transports.File({ 
      filename: 'logs/error.log', 
      level: 'error' 
    }),
    new winston.transports.File({ 
      filename: 'logs/combined.log' 
    })
  ]
});

// Usage
logger.info('User created', { userId: user.id });
logger.error('API error', { error: err.message, statusCode: 500 });
```

Or use pino (faster):
```typescript
import pino from 'pino';

const logger = pino({
  level: process.env.LOG_LEVEL || 'info',
  formatters: {
    level: (label) => {
      return { level: label };
    }
  }
});

logger.info({ userId: user.id }, 'User created');
```

Deliverable: Structured logging implemented

========================================
PHASE 2 - REQUEST TRACKING
========================================

Add request ID middleware (Express):

```typescript
import { Request, Response, NextFunction } from 'express';
import { v4 as uuidv4 } from 'uuid';

interface RequestWithId extends Request {
  id: string;
  log: winston.Logger;
}

export const requestIdMiddleware = (
  req: RequestWithId, 
  res: Response, 
  next: NextFunction
) => {
  req.id = uuidv4();
  req.log = logger.child({ requestId: req.id });
  
  res.setHeader('X-Request-Id', req.id);
  
  req.log.info('Request started', {
    method: req.method,
    path: req.path
  });
  
  next();
};

// Usage in routes
app.get('/users', (req: RequestWithId, res) => {
  req.log.info('Fetching users');
  // All logs include requestId
});
```

Deliverable: Request tracking active

========================================
PHASE 3 - ERROR TRACKING
========================================

Install Sentry:

```bash
npm install @sentry/node @sentry/tracing
```

Configure:
```typescript
import * as Sentry from '@sentry/node';
import * as Tracing from '@sentry/tracing';

Sentry.init({
  dsn: process.env.SENTRY_DSN,
  environment: process.env.NODE_ENV,
  tracesSampleRate: 0.1,
  integrations: [
    new Tracing.Integrations.Express({ app })
  ]
});

// Add middleware
app.use(Sentry.Handlers.requestHandler());
app.use(Sentry.Handlers.tracingHandler());

// Add error handler (must be after routes)
app.use(Sentry.Handlers.errorHandler());

// Manual error capture
try {
  await riskyOperation();
} catch (error) {
  Sentry.captureException(error);
  throw error;
}
```

Deliverable: Error tracking active

========================================
PHASE 4 - APPLICATION MONITORING
========================================

Add Prometheus metrics:

```bash
npm install prom-client
```

Configure:
```typescript
import client from 'prom-client';

const collectDefaultMetrics = client.collectDefaultMetrics;
collectDefaultMetrics();

// Custom metrics
const httpRequestDuration = new client.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status_code']
});

const userCreatedCounter = new client.Counter({
  name: 'users_created_total',
  help: 'Total number of users created'
});

// Expose metrics endpoint
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', client.register.contentType);
  res.end(await client.register.metrics());
});

// Usage
userCreatedCounter.inc();
```

Add health check:
```typescript
app.get('/health', async (req, res) => {
  const checks = {
    database: await checkDatabase(),
    redis: await checkRedis()
  };
  
  const status = Object.values(checks).every(Boolean) 
    ? 'healthy' 
    : 'unhealthy';
  
  res.json({ status, checks });
});
```

Deliverable: Monitoring active

========================================
BEST PRACTICES
========================================

- Use winston or pino
- Never log sensitive data
- Use JSON format in production
- Add request ID to all logs
- Integrate Sentry for error tracking
- Expose Prometheus metrics
- Add health checks
- Review logs regularly

========================================
EXECUTION
========================================

START: Implement winston/pino (Phase 1)
CONTINUE: Add request tracking (Phase 2)
CONTINUE: Add Sentry (Phase 3)
OPTIONAL: Add monitoring (Phase 4)
REMEMBER: JSON format, no sensitive data
```

---

## Quick Reference

**What you get**: Production logging with error tracking and metrics  
**Time**: 2-3 hours  
**Output**: Winston/Pino configuration, Sentry integration, Prometheus metrics
