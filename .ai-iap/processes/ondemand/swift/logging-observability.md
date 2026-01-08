# Logging & Observability Implementation Process - Swift

> **Purpose**: Establish production-grade logging, monitoring, and observability for Swift applications

---

## Prerequisites

> **BEFORE starting**:
> - Working Swift application
> - Git repository

---

## Phase 1: Structured Logging

**Branch**: `logging/structured`

### 1.1 Use os.Logger (iOS/macOS) or SwiftLog (Server)

**iOS/macOS (os.Logger)**:
```swift
import os.log

let logger = Logger(subsystem: "com.myapp", category: "network")

logger.info("Request started: \(requestId)")
logger.error("Error occurred: \(error.localizedDescription)")
```

**Vapor (SwiftLog)**:
```swift
import Logging

let logger = Logger(label: "com.myapp")

logger.info("Server started", metadata: [
    "port": "\(port)",
    "environment": "\(environment)"
])
```

**Verify**: Structured logging configured

---

## Phase 2: Application Monitoring

**Branch**: `logging/monitoring`

### 2.1 Health Checks

**Vapor**:
```swift
app.get("health") { req in
    return HTTPStatus.ok
}
```

### 2.2 Metrics

**Vapor**: Use Prometheus
```swift
// Install: swift-prometheus
```

**iOS**: MetricKit
```swift
import MetricKit

class MetricsManager: NSObject, MXMetricManagerSubscriber {
    override init() {
        super.init()
        MXMetricManager.shared.add(self)
    }
    
    func didReceive(_ payloads: [MXMetricPayload]) {
        // Process metrics
    }
}
```

### 2.3 Error Tracking

> **iOS**: **Sentry** ⭐ or Firebase Crashlytics

**Sentry**:
```swift
import Sentry

SentrySDK.start { options in
    options.dsn = "YOUR_DSN"
    options.environment = "production"
}
```

**Verify**: Health checks (server), metrics collected, errors tracked

---

## Phase 3: Distributed Tracing

**Branch**: `logging/tracing`

### 3.1 OpenTelemetry (Server)

**Vapor**: Use OpenTelemetry

**iOS**: URLSessionTaskMetrics for network tracing

**Verify**: Traces collected

---

## Phase 4: Log Aggregation

**Branch**: `logging/aggregation`

### 4.1 Log Shipping

**iOS/macOS**: OSLog → Console.app or ship to backend/Sentry

**Vapor**: ELK Stack, Datadog, CloudWatch

### 4.2 Alerts

> **Alert on**: Crash rate >0.1%, API error rate >1%

**Verify**: Logs aggregated, alerts configured

---

## Platform Notes

| Platform | Logger | Monitoring |
|----------|--------|------------|
| **iOS/macOS** | os.Logger | MetricKit, Sentry |
| **Vapor** | SwiftLog | Prometheus, OpenTelemetry |

---

## Best Practices

### What to Log/Not Log
> **ALWAYS**: Structured data, Errors, User actions

> **NEVER**: Passwords, Tokens, PII

---

## AI Self-Check

- [ ] Logging configured (os.Logger/SwiftLog)
- [ ] No sensitive data logged
- [ ] Health checks (server)
- [ ] Error tracking (Sentry/Crashlytics)
- [ ] Metrics collected
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
