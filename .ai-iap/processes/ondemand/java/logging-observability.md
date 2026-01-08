# Logging & Observability Implementation Process - Java

> **Purpose**: Establish production-grade logging, monitoring, and observability

---

## Prerequisites

> **BEFORE starting**:
> - Working Java application
> - Git repository
> - Understanding of log levels

---

## Phase 1: Structured Logging

**Branch**: `logging/structured`

### 1.1 Use SLF4J + Logback

> **ALWAYS use**: **SLF4J** ⭐ (facade) + **Logback** (implementation)

**Dependencies** (Maven):
```xml
<dependency>
    <groupId>ch.qos.logback</groupId>
    <artifactId>logback-classic</artifactId>
</dependency>
<dependency>
    <groupId>net.logstash.logback</groupId>
    <artifactId>logstash-logback-encoder</artifactId>
    <version>7.4</version>
</dependency>
```

**Configuration** (logback-spring.xml):
```xml
<configuration>
    <appender name="CONSOLE" class="ch.qos.logback.core.ConsoleAppender">
        <encoder class="net.logstash.logback.encoder.LogstashEncoder"/>
    </appender>
    <root level="INFO">
        <appender-ref ref="CONSOLE"/>
    </root>
</configuration>
```

**Usage**:
```java
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class UserService {
    private static final Logger logger = LoggerFactory.getLogger(UserService.class);
    
    public void createUser(String email) {
        logger.info("Creating user: {}", email);
    }
}
```

### 1.2 Add MDC for Correlation IDs

**Configure Filter**:
```java
@Component
public class CorrelationIdFilter extends OncePerRequestFilter {
    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain chain) {
        String correlationId = request.getHeader("X-Correlation-ID");
        if (correlationId == null) {
            correlationId = UUID.randomUUID().toString();
        }
        MDC.put("correlationId", correlationId);
        response.setHeader("X-Correlation-ID", correlationId);
        try {
            chain.doFilter(request, response);
        } finally {
            MDC.clear();
        }
    }
}
```

**Verify**: Logs structured (JSON), correlation IDs in every log, no sensitive data

---

## Phase 2: Application Monitoring

**Branch**: `logging/monitoring`

### 2.1 Health Checks

> **Spring Boot**: Use Actuator

**Dependencies**:
```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-actuator</artifactId>
</dependency>
```

**Configuration** (application.properties):
```properties
management.endpoints.web.exposure.include=health,metrics
management.endpoint.health.show-details=always
```

### 2.2 Metrics with Micrometer

> **Spring Boot**: Micrometer built-in, exposes to Prometheus

**Configuration**:
```properties
management.metrics.export.prometheus.enabled=true
```

**Custom Metrics**:
```java
@Autowired
private MeterRegistry meterRegistry;

public void trackUserCreation() {
    meterRegistry.counter("users.created").increment();
}
```

### 2.3 Error Tracking

> **ALWAYS use**: **Sentry** ⭐ or Rollbar

**Sentry Setup**:
```xml
<dependency>
    <groupId>io.sentry</groupId>
    <artifactId>sentry-spring-boot-starter-jakarta</artifactId>
</dependency>
```

```properties
sentry.dsn=${SENTRY_DSN}
sentry.environment=${SPRING_PROFILES_ACTIVE}
```

**Verify**: Health at /actuator/health, metrics at /actuator/metrics, errors tracked

---

## Phase 3: Distributed Tracing

**Branch**: `logging/tracing`

### 3.1 Configure OpenTelemetry or Sleuth

> **Spring Boot 3+**: Use Micrometer Tracing + OpenTelemetry

**Dependencies**:
```xml
<dependency>
    <groupId>io.micrometer</groupId>
    <artifactId>micrometer-tracing-bridge-otel</artifactId>
</dependency>
<dependency>
    <groupId>io.opentelemetry</groupId>
    <artifactId>opentelemetry-exporter-jaeger</artifactId>
</dependency>
```

**Configuration**:
```properties
management.tracing.sampling.probability=0.1
management.otlp.tracing.endpoint=http://jaeger:4318/v1/traces
```

**Verify**: Traces in Jaeger/Zipkin, trace IDs propagated

---

## Phase 4: Log Aggregation & Alerts

**Branch**: `logging/aggregation`

### 4.1 Configure Log Shipping

> **Options**: ELK Stack, Datadog, CloudWatch, Splunk

**Logstash Configuration** (logback-spring.xml):
```xml
<appender name="LOGSTASH" class="net.logstash.logback.appender.LogstashTcpSocketAppender">
    <destination>logstash:5000</destination>
    <encoder class="net.logstash.logback.encoder.LogstashEncoder"/>
</appender>
```

### 4.2 Alerts & Dashboards

> **Alert on**: Error rate >1%, p99 latency >2s, Health failures, High JVM heap (>80%)

> **Dashboards**: RED metrics, JVM metrics (heap, GC), Database query performance

**Verify**: Logs aggregated, alerts configured, dashboards created

---

## Framework-Specific Notes

| Framework | Logger | Health | Notes |
|-----------|--------|--------|-------|
| **Spring Boot** | SLF4J + Logback | Actuator | Auto-configured |
| **Quarkus** | JBoss Logging | SmallRye Health | Reactive, fast startup |
| **Micronaut** | SLF4J | Health endpoint | Compile-time DI |

---

## Best Practices

### Log Levels
- **TRACE**: Very detailed
- **DEBUG**: Troubleshooting
- **INFO**: General flow
- **WARN**: Unexpected events
- **ERROR**: Errors/exceptions

### What to Log/Not Log
> **ALWAYS log**: Structured data `logger.info("User {} created", userId)`, Request/response, Auth events

> **NEVER log**: Passwords, API keys, Credit cards, PII without redaction

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| **Logs not JSON formatted** | Check logstash-logback-encoder dependency |
| **MDC cleared unexpectedly** | Use try-finally, check async boundaries |
| **High memory from logging** | Enable async appenders, reduce verbosity |

---

## AI Self-Check

- [ ] SLF4J + Logback configured
- [ ] Structured logging (JSON)
- [ ] Correlation IDs via MDC
- [ ] No sensitive data logged
- [ ] Health checks (/actuator/health)
- [ ] Metrics exposed (/actuator/metrics)
- [ ] Error tracking configured
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
