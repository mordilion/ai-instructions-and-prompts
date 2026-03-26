# Python Logging & Observability - Copy This Prompt

> **Type**: One-time setup process  
> **When to use**: Setting up production logging and monitoring  
> **Instructions**: Copy the complete prompt below and paste into your AI tool

---

## 📋 Complete Self-Contained Prompt

```
========================================
PYTHON LOGGING & OBSERVABILITY
========================================

CONTEXT:
You are implementing production-grade logging and observability for a Python application.

CRITICAL REQUIREMENTS:
- ALWAYS use structlog or Python logging
- NEVER log sensitive data (PII, tokens, passwords)
- Use structured logging (JSON format)
- Integrate error tracking (Sentry)

========================================
CATCH-UP: READ EXISTING DOCUMENTATION
========================================

BEFORE starting, check for existing documentation:
1. Read PROJECT-MEMORY.md, LOGIC-ANOMALIES.md, LOGGING-SETUP.md if they exist

Use this to continue from where work stopped. If no docs: Start fresh.

========================================
PHASE 1 - STRUCTURED LOGGING
========================================

Install structlog:
```bash
pip install structlog
```

Configure:
```python
import structlog
import logging

structlog.configure(
    processors=[
        structlog.stdlib.filter_by_level,
        structlog.stdlib.add_logger_name,
        structlog.stdlib.add_log_level,
        structlog.stdlib.PositionalArgumentsFormatter(),
        structlog.processors.TimeStamper(fmt="iso"),
        structlog.processors.StackInfoRenderer(),
        structlog.processors.format_exc_info,
        structlog.processors.UnicodeDecoder(),
        structlog.processors.JSONRenderer()
    ],
    wrapper_class=structlog.stdlib.BoundLogger,
    logger_factory=structlog.stdlib.LoggerFactory(),
    cache_logger_on_first_use=True,
)

logger = structlog.get_logger()

# Usage
logger.info("user_created", user_id=user.id)
logger.error("api_error", error=str(e), status_code=500)
```

Deliverable: Structured logging implemented

========================================
PHASE 2 - CONTEXT BINDING
========================================

Add request context:

```python
from flask import Flask, request, g
import uuid

app = Flask(__name__)

@app.before_request
def add_request_id():
    g.request_id = str(uuid.uuid4())
    g.logger = logger.bind(request_id=g.request_id)

@app.route('/users', methods=['POST'])
def create_user():
    g.logger.info("creating_user", data=request.json)
    # All logs in this request include request_id
```

Deliverable: Request tracking active

========================================
PHASE 3 - ERROR TRACKING
========================================

Install Sentry:

```bash
pip install sentry-sdk
```

Configure:
```python
import sentry_sdk
from sentry_sdk.integrations.flask import FlaskIntegration
from sentry_sdk.integrations.logging import LoggingIntegration

sentry_sdk.init(
    dsn="YOUR_DSN",
    integrations=[
        FlaskIntegration(),
        LoggingIntegration(
            level=logging.INFO,
            event_level=logging.ERROR
        ),
    ],
    environment="production",
    traces_sample_rate=0.1,
)

# Errors are automatically captured
# Manual capture:
try:
    risky_operation()
except Exception as e:
    sentry_sdk.capture_exception(e)
    raise
```

Add user context:
```python
sentry_sdk.set_user({"id": user.id, "email": user.email})
```

Deliverable: Error tracking active

========================================
PHASE 4 - APPLICATION MONITORING
========================================

Add Prometheus metrics:

```bash
pip install prometheus-flask-exporter
```

Configure:
```python
from prometheus_flask_exporter import PrometheusMetrics

app = Flask(__name__)
metrics = PrometheusMetrics(app)

# Custom metrics
from prometheus_client import Counter

user_created = Counter('users_created_total', 'Total users created')

@app.route('/users', methods=['POST'])
def create_user():
    user_created.inc()
    # ... create user ...
```

Metrics available at /metrics

Add health check:
```python
@app.route('/health')
def health():
    checks = {
        'database': check_database(),
        'redis': check_redis(),
    }
    status = 'healthy' if all(checks.values()) else 'unhealthy'
    return jsonify({'status': status, 'checks': checks})
```

Deliverable: Monitoring active

========================================
BEST PRACTICES
========================================

- Use structlog for structured logging
- Never log sensitive data
- Use JSON format in production
- Bind context to loggers
- Integrate Sentry for error tracking
- Expose Prometheus metrics
- Add health checks
- Review logs regularly

========================================
DOCUMENTATION
========================================

Create/update: PROJECT-MEMORY.md, LOGIC-ANOMALIES.md, LOGGING-SETUP.md

========================================
EXECUTION
========================================

START: Read existing docs (CATCH-UP section)
CONTINUE: Implement structlog (Phase 1)
CONTINUE: Add context binding (Phase 2)
CONTINUE: Add Sentry (Phase 3)
OPTIONAL: Add monitoring (Phase 4)
FINISH: Update all documentation files
REMEMBER: JSON format, no sensitive data, document for catch-up
```

---

## Quick Reference

**What you get**: Production logging with error tracking and metrics  
**Time**: 2-3 hours  
**Output**: Structlog configuration, Sentry integration, Prometheus metrics
