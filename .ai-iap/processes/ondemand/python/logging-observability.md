# Logging & Observability Implementation Process - Python

> **Purpose**: Establish production-grade logging, monitoring, and observability

---

## Prerequisites

> **BEFORE starting**:
> - Working Python application
> - Git repository
> - Understanding of log levels

---

## Phase 1: Structured Logging

**Branch**: `logging/structured`

### 1.1 Use structlog

> **ALWAYS use**: **structlog** ⭐ (structured logging) or Python's logging with JSON formatter

**Install**:
```bash
pip install structlog python-json-logger
```

**Configure**:
```python
import structlog

structlog.configure(
    processors=[
        structlog.stdlib.add_log_level,
        structlog.stdlib.add_logger_name,
        structlog.processors.TimeStamper(fmt="iso"),
        structlog.processors.StackInfoRenderer(),
        structlog.processors.format_exc_info,
        structlog.processors.JSONRenderer()
    ],
    wrapper_class=structlog.stdlib.BoundLogger,
    logger_factory=structlog.stdlib.LoggerFactory(),
)

logger = structlog.get_logger()
```

**Usage**:
```python
logger.info("user_created", user_id=user.id, email=user.email)
```

### 1.2 Add Correlation IDs

**Middleware** (Flask/FastAPI):
```python
import uuid
from contextvars import ContextVar

correlation_id: ContextVar[str] = ContextVar("correlation_id", default="")

@app.middleware("http")
async def add_correlation_id(request, call_next):
    cid = request.headers.get("X-Correlation-ID", str(uuid.uuid4()))
    correlation_id.set(cid)
    response = await call_next(request)
    response.headers["X-Correlation-ID"] = cid
    return response
```

**Verify**: Logs structured (JSON), correlation IDs tracked, no sensitive data

---

## Phase 2: Application Monitoring

**Branch**: `logging/monitoring`

### 2.1 Health Checks

**FastAPI**:
```python
@app.get("/health")
async def health():
    return {
        "status": "healthy",
        "database": await check_database(),
        "redis": await check_redis()
    }
```

### 2.2 Metrics with Prometheus

**Install**:
```bash
pip install prometheus-client
```

**Configure**:
```python
from prometheus_client import Counter, Histogram, make_asgi_app

requests_total = Counter('requests_total', 'Total requests', ['method', 'endpoint'])
request_duration = Histogram('request_duration_seconds', 'Request duration')

metrics_app = make_asgi_app()
app.mount("/metrics", metrics_app)
```

### 2.3 Error Tracking

> **ALWAYS use**: **Sentry** ⭐

**Setup**:
```bash
pip install sentry-sdk
```

```python
import sentry_sdk

sentry_sdk.init(
    dsn=os.environ["SENTRY_DSN"],
    environment=os.environ.get("ENV", "development"),
    traces_sample_rate=0.1
)
```

**Verify**: Health endpoint works, metrics exposed, errors tracked

---

## Phase 3: Distributed Tracing

**Branch**: `logging/tracing`

### 3.1 Configure OpenTelemetry

**Install**:
```bash
pip install opentelemetry-api opentelemetry-sdk opentelemetry-instrumentation-fastapi
```

**Configure**:
```python
from opentelemetry import trace
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.exporter.jaeger.thrift import JaegerExporter

trace.set_tracer_provider(TracerProvider())
jaeger_exporter = JaegerExporter(agent_host_name="jaeger", agent_port=6831)
trace.get_tracer_provider().add_span_processor(BatchSpanProcessor(jaeger_exporter))
```

**Verify**: Traces in Jaeger/Zipkin, trace IDs propagated

---

## Phase 4: Log Aggregation & Alerts

**Branch**: `logging/aggregation`

### 4.1 Configure Log Shipping

> **Options**: ELK Stack, Datadog, CloudWatch, Loguru (with external sink)

**Loguru with external sink**:
```bash
pip install loguru
```

```python
from loguru import logger

logger.add(
    "logs/app.log",
    rotation="500 MB",
    retention="10 days",
    format="{time:YYYY-MM-DD HH:mm:ss} | {level} | {message}",
    serialize=True  # JSON format
)
```

### 4.2 Alerts & Dashboards

> **Alert on**: Error rate >1%, p99 latency >2s, Health failures, High memory

> **Dashboards**: RED metrics, Python process metrics, Database performance

**Verify**: Logs aggregated, alerts configured, dashboards created

---

## Framework-Specific Notes

| Framework | Logger | Health | Notes |
|-----------|--------|--------|-------|
| **FastAPI** | structlog | Built-in route | Async-first |
| **Django** | logging | django-health-check | WSGI, sync |
| **Flask** | structlog | Custom route | WSGI, sync |

---

## Best Practices

### Log Levels
- **DEBUG**: Detailed troubleshooting
- **INFO**: General flow
- **WARNING**: Unexpected events
- **ERROR**: Errors/exceptions
- **CRITICAL**: System failures

### What to Log/Not Log
> **ALWAYS log**: Structured data, Request/response, Auth events

> **NEVER log**: Passwords, API keys, Credit cards, PII

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| **Logs not JSON** | Configure JSON formatter or use structlog |
| **Context lost in async** | Use contextvars for correlation IDs |
| **High memory** | Enable log rotation, reduce verbosity |

---

## AI Self-Check

- [ ] Structured logging configured (structlog/JSON)
- [ ] Correlation IDs tracked
- [ ] No sensitive data logged
- [ ] Health checks implemented
- [ ] Metrics exposed (/metrics)
- [ ] Error tracking configured (Sentry)
- [ ] Distributed tracing enabled
- [ ] Log aggregation configured
- [ ] Alerts created

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
