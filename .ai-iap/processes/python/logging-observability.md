# Logging & Observability Implementation Process - Python

> **Purpose**: Establish production-grade logging, monitoring, and observability for Python applications

> **Core Libraries**: structlog/python-json-logger, Prometheus, Sentry, OpenTelemetry

---

## Phase 1: Structured Logging

> **ALWAYS use**: structlog ⭐ or python-json-logger
> **NEVER**: Use print(), log passwords/tokens/PII

**Install**:
```bash
pip install structlog python-json-logger
```

**Configuration**:
```python
import structlog

structlog.configure(
    processors=[
        structlog.stdlib.add_log_level,
        structlog.stdlib.add_logger_name,
        structlog.processors.TimeStamper(fmt="iso"),
        structlog.processors.JSONRenderer()
    ],
    context_class=dict,
    logger_factory=structlog.stdlib.LoggerFactory(),
)

logger = structlog.get_logger()
```

**Correlation ID Middleware** (Flask/FastAPI):
```python
import uuid
from contextvars import ContextVar

request_id_var = ContextVar('request_id', default=None)

@app.middleware("http")
async def add_correlation_id(request, call_next):
    request_id = request.headers.get('X-Correlation-ID') or str(uuid.uuid4())
    request_id_var.set(request_id)
    response = await call_next(request)
    response.headers["X-Correlation-ID"] = request_id
    return response
```

> **Git**: `git commit -m "feat: add structured logging with structlog"`

---

## Phase 2: Application Monitoring

> **ALWAYS include**:
- /health endpoint (database, Redis checks)
- Prometheus metrics with prometheus_client
- Error tracking with Sentry

**Prometheus Setup**:
```bash
pip install prometheus-client
```

```python
from prometheus_client import Counter, Histogram, make_asgi_app

REQUEST_COUNT = Counter('http_requests_total', 'Total requests', ['method', 'endpoint'])
REQUEST_DURATION = Histogram('http_request_duration_seconds', 'Request duration')

# Mount metrics endpoint
app.mount("/metrics", make_asgi_app())
```

**Sentry Setup**:
```bash
pip install sentry-sdk[fastapi]
```

```python
import sentry_sdk
sentry_sdk.init(dsn=os.getenv("SENTRY_DSN"), environment=os.getenv("ENV"))
```

> **Git**: `git commit -m "feat: add health checks, metrics, and error tracking"`

---

## Phase 3: Distributed Tracing

> **ALWAYS use**: OpenTelemetry ⭐

**Install**:
```bash
pip install opentelemetry-api opentelemetry-sdk opentelemetry-instrumentation-fastapi
```

**Configuration**:
```python
from opentelemetry import trace
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor

trace.set_tracer_provider(TracerProvider())
FastAPIInstrumentor.instrument_app(app)
```

> **Git**: `git commit -m "feat: add distributed tracing with OpenTelemetry"`

---

## Phase 4: Log Aggregation & Alerts

> **ALWAYS use**: Datadog, CloudWatch, or ELK Stack

**Python Logging Handler** (Datadog):
```bash
pip install datadog
```

**Alerts**: Error rate >1%, p99 latency >2s, health check failures

> **Git**: `git commit -m "feat: add log aggregation and alerting"`

---

## Framework-Specific Notes

### FastAPI
- Built-in /health with dependencies
- Prometheus middleware
- Sentry ASGI integration

### Django
- django-structlog for structured logging
- django-prometheus for metrics
- Health check views

### Flask
- flask-healthz for health checks
- prometheus_flask_exporter
- Sentry Flask integration

---

## AI Self-Check

- [ ] Structured logging configured (JSON)
- [ ] Correlation ID tracked
- [ ] No sensitive data in logs
- [ ] Health checks implemented
- [ ] Metrics exposed (/metrics)
- [ ] Error tracking enabled
- [ ] Distributed tracing configured
- [ ] Log aggregation setup
- [ ] Alerts created

---

**Process Complete** ✅

