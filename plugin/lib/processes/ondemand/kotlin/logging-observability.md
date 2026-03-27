# Kotlin Logging & Observability - Copy This Prompt

> **Type**: One-time setup process  
> **When to use**: Setting up production logging and monitoring  
> **Instructions**: Copy the complete prompt below and paste into your AI tool

---

## 📋 Complete Self-Contained Prompt

```
========================================
KOTLIN LOGGING & OBSERVABILITY
========================================

CONTEXT:
You are implementing production-grade logging and observability for a Kotlin application.

CRITICAL REQUIREMENTS:
- ALWAYS use kotlin-logging (SLF4J wrapper)
- NEVER log sensitive data (PII, tokens, passwords)
- Use structured logging with MDC
- Integrate monitoring (Micrometer for Ktor/Spring)

========================================
CATCH-UP: READ EXISTING DOCUMENTATION
========================================

BEFORE starting, check for existing documentation:
1. Read PROJECT-MEMORY.md, LOGIC-ANOMALIES.md, LOGGING-SETUP.md if they exist

Use this to continue from where work stopped. If no docs: Start fresh.

========================================
PHASE 1 - STRUCTURED LOGGING
========================================

Add dependencies (Gradle):
```kotlin
dependencies {
    implementation("io.github.microutils:kotlin-logging-jvm:3.0.5")
    implementation("ch.qos.logback:logback-classic:1.4.11")
    implementation("net.logstash.logback:logstash-logback-encoder:7.4")
}
```

Create logback.xml:
```xml
<configuration>
    <appender name="JSON" class="ch.qos.logback.core.ConsoleAppender">
        <encoder class="net.logstash.logback.encoder.LogstashEncoder"/>
    </appender>
    
    <root level="INFO">
        <appender-ref ref="JSON"/>
    </root>
</configuration>
```

Use in code:
```kotlin
import mu.KotlinLogging

private val logger = KotlinLogging.logger {}

class UserService {
    fun createUser(user: User) {
        logger.info { "Creating user ${user.id} with email ${user.email}" }
        
        try {
            repository.save(user)
        } catch (e: Exception) {
            logger.error(e) { "Failed to create user ${user.id}" }
            throw e
        }
    }
}
```

Deliverable: Structured logging implemented

========================================
PHASE 2 - MDC FOR CONTEXT
========================================

Use MDC for request tracking (Ktor):

```kotlin
import io.ktor.server.application.*
import org.slf4j.MDC
import java.util.UUID

fun Application.configureMDC() {
    intercept(ApplicationCallPipeline.Setup) {
        val requestId = UUID.randomUUID().toString()
        MDC.put("requestId", requestId)
        
        try {
            proceed()
        } finally {
            MDC.clear()
        }
    }
}
```

All logs will include requestId automatically.

Deliverable: Request tracking active

========================================
PHASE 3 - KTOR MONITORING
========================================

Add Micrometer for Ktor:

```kotlin
dependencies {
    implementation("io.ktor:ktor-server-metrics-micrometer:$ktor_version")
    implementation("io.micrometer:micrometer-registry-prometheus:1.12.0")
}
```

Configure:
```kotlin
install(MicrometerMetrics) {
    registry = PrometheusMeterRegistry(PrometheusConfig.DEFAULT)
}

routing {
    get("/metrics") {
        call.respond(registry.scrape())
    }
}
```

Deliverable: Metrics exposed

========================================
PHASE 4 - CUSTOM METRICS
========================================

Track custom metrics:

```kotlin
import io.micrometer.core.instrument.MeterRegistry

class UserService(private val registry: MeterRegistry) {
    fun createUser(user: User) {
        registry.counter("users.created").increment()
        
        registry.timer("user.creation.time").record {
            // ... operation ...
        }
    }
}
```

Deliverable: Custom metrics tracked

========================================
BEST PRACTICES
========================================

- Use kotlin-logging (SLF4J wrapper)
- Never log sensitive data
- Use MDC for request context
- Use structured logging (JSON)
- Expose metrics via Micrometer
- Track custom business metrics
- Use lazy logging { }
- Review logs regularly

========================================
DOCUMENTATION
========================================

Create/update: PROJECT-MEMORY.md, LOGIC-ANOMALIES.md, LOGGING-SETUP.md

========================================
EXECUTION
========================================

START: Read existing docs (CATCH-UP section)
CONTINUE: Implement kotlin-logging (Phase 1)
CONTINUE: Add MDC (Phase 2)
CONTINUE: Add Micrometer (Phase 3)
OPTIONAL: Add custom metrics (Phase 4)
FINISH: Update all documentation files
REMEMBER: Lazy logging, no sensitive data, document for catch-up
```

---

## Quick Reference

**What you get**: Production logging with metrics and monitoring  
**Time**: 2-3 hours  
**Output**: Logback configuration, MDC setup, Micrometer integration
