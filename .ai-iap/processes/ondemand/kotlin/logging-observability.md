# Logging & Observability Implementation Process - Kotlin

> **Purpose**: Establish production-grade logging, monitoring, and observability

---

## Prerequisites

> **BEFORE starting**:
> - Working Kotlin application
> - Git repository

---

## Phase 1: Structured Logging

**Branch**: `logging/structured`

### 1.1 Use SLF4J + Logback

> **Same as Java**: SLF4J facade + Logback implementation

**Dependencies** (Gradle):
```kotlin
implementation("ch.qos.logback:logback-classic")
implementation("net.logstash.logback:logstash-logback-encoder:7.4")
```

**Usage**:
```kotlin
import org.slf4j.LoggerFactory

class UserService {
    private val logger = LoggerFactory.getLogger(UserService::class.java)
    
    fun createUser(email: String) {
        logger.info("Creating user: {}", email)
    }
}
```

### 1.2 Kotlin Logging (Alternative)

**Install**:
```kotlin
implementation("io.github.oshai:kotlin-logging-jvm:5.1.0")
```

**Usage**:
```kotlin
import io.github.oshai.kotlinlogging.KotlinLogging

private val logger = KotlinLogging.logger {}

fun createUser(email: String) {
    logger.info { "Creating user: $email" }
}
```

### 1.3 Add MDC for Correlation IDs

> **Same as Java**: Use SLF4J MDC in filter/interceptor

**Verify**: Structured logs (JSON), correlation IDs tracked

---

## Phase 2: Application Monitoring

**Branch**: `logging/monitoring`

### 2.1 Health Checks

**Spring Boot**: Use Actuator (same as Java)

**Ktor**:
```kotlin
routing {
    get("/health") {
        call.respond(mapOf("status" to "healthy"))
    }
}
```

### 2.2 Metrics

**Spring Boot**: Micrometer (built-in)

**Ktor**: Use Micrometer
```kotlin
install(MicrometerMetrics) {
    registry = PrometheusMeterRegistry(PrometheusConfig.DEFAULT)
}
```

### 2.3 Error Tracking

> **Sentry**: Same setup as Java

**Verify**: Health checks, metrics exposed, errors tracked

---

## Phase 3: Distributed Tracing

**Branch**: `logging/tracing`

### 3.1 OpenTelemetry

> **Spring Boot**: Same as Java

**Ktor**:
```kotlin
install(OpenTelemetry) {
    // Configuration
}
```

**Verify**: Traces visible, trace IDs propagated

---

## Phase 4: Log Aggregation

**Branch**: `logging/aggregation`

### 4.1 Log Shipping

> **Options**: ELK, Datadog, CloudWatch

**Logback configuration**: Same as Java

### 4.2 Alerts & Dashboards

> **Alert on**: Error rate >1%, p99 >2s, Health failures

**Verify**: Logs aggregated, alerts configured

---

## Framework-Specific Notes

| Framework | Logger | Health |
|-----------|--------|--------|
| **Spring Boot** | SLF4J + Logback | Actuator |
| **Ktor** | kotlin-logging | Custom route |
| **Android** | Logcat + Timber | N/A |

---

## Best Practices

### What to Log/Not Log
> **ALWAYS**: Structured data, Request/response, Auth events

> **NEVER**: Passwords, API keys, PII

---

## AI Self-Check

- [ ] SLF4J + Logback or kotlin-logging configured
- [ ] Structured logging (JSON)
- [ ] Correlation IDs (MDC)
- [ ] No sensitive data logged
- [ ] Health checks implemented
- [ ] Metrics exposed
- [ ] Error tracking configured
- [ ] Distributed tracing enabled
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
