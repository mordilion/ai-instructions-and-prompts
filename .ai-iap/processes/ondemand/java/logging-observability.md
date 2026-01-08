# Java Logging & Observability - Copy This Prompt

> **Type**: One-time setup process  
> **When to use**: Setting up production logging and monitoring  
> **Instructions**: Copy the complete prompt below and paste into your AI tool

---

## 📋 Complete Self-Contained Prompt

```
========================================
JAVA LOGGING & OBSERVABILITY
========================================

CONTEXT:
You are implementing production-grade logging and observability for a Java application.

CRITICAL REQUIREMENTS:
- ALWAYS use SLF4J with Logback
- NEVER log sensitive data (PII, tokens, passwords)
- Use structured logging with MDC
- Integrate monitoring (Micrometer, Spring Boot Actuator)

========================================
PHASE 1 - STRUCTURED LOGGING
========================================

Add dependencies (Maven):
```xml
<dependency>
    <groupId>org.slf4j</groupId>
    <artifactId>slf4j-api</artifactId>
</dependency>
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

Create logback-spring.xml:
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
```java
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class UserService {
    private static final Logger log = LoggerFactory.getLogger(UserService.class);
    
    public void createUser(User user) {
        log.info("Creating user {} with email {}", user.getId(), user.getEmail());
        
        try {
            repository.save(user);
        } catch (Exception e) {
            log.error("Failed to create user {}", user.getId(), e);
            throw e;
        }
    }
}
```

Deliverable: Structured logging implemented

========================================
PHASE 2 - MDC FOR CONTEXT
========================================

Use MDC for request tracking:

```java
import org.slf4j.MDC;

@Component
public class RequestFilter implements Filter {
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) {
        String requestId = UUID.randomUUID().toString();
        MDC.put("requestId", requestId);
        
        try {
            chain.doFilter(request, response);
        } finally {
            MDC.clear();
        }
    }
}
```

All logs will include requestId automatically.

Deliverable: Request tracking active

========================================
PHASE 3 - SPRING BOOT ACTUATOR
========================================

Add dependency:
```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-actuator</artifactId>
</dependency>
<dependency>
    <groupId>io.micrometer</groupId>
    <artifactId>micrometer-registry-prometheus</artifactId>
</dependency>
```

Configure in application.yml:
```yaml
management:
  endpoints:
    web:
      exposure:
        include: health,metrics,prometheus
  metrics:
    export:
      prometheus:
        enabled: true
```

Access metrics at /actuator/prometheus

Deliverable: Metrics exposed

========================================
PHASE 4 - CUSTOM METRICS
========================================

Track custom metrics:

```java
import io.micrometer.core.instrument.MeterRegistry;

@Service
public class UserService {
    private final MeterRegistry registry;
    
    public void createUser(User user) {
        registry.counter("users.created").increment();
        
        Timer.Sample sample = Timer.start(registry);
        // ... operation ...
        sample.stop(registry.timer("user.creation.time"));
    }
}
```

Deliverable: Custom metrics tracked

========================================
BEST PRACTICES
========================================

- Use SLF4J + Logback
- Never log sensitive data
- Use MDC for request context
- Use structured logging (JSON)
- Expose metrics via Actuator
- Track custom business metrics
- Set up health checks
- Review logs regularly

========================================
EXECUTION
========================================

START: Implement SLF4J + Logback (Phase 1)
CONTINUE: Add MDC (Phase 2)
CONTINUE: Add Actuator (Phase 3)
OPTIONAL: Add custom metrics (Phase 4)
REMEMBER: Structured logging, no sensitive data
```

---

## Quick Reference

**What you get**: Production logging with metrics and health checks  
**Time**: 2-3 hours  
**Output**: Logback configuration, MDC setup, Actuator integration
