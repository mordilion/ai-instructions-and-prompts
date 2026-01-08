# Logging & Observability Implementation Process - .NET/C#

> **Purpose**: Establish production-grade logging, monitoring, and observability

---

## Prerequisites

> **BEFORE starting**:
> - Working .NET application
> - Git repository
> - Understanding of log levels

---

## Phase 1: Structured Logging

**Branch**: `logging/structured`

### 1.1 Use Built-in ILogger

> **.NET 6+**: ILogger is built-in, structured, and performant

> **ALWAYS use**: `ILogger<T>` via dependency injection

> **NEVER**: Use Console.WriteLine, Debug.WriteLine, or Trace in production

**Configuration** (appsettings.json):
```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  }
}
```

**Usage**:
```csharp
public class UserService
{
    private readonly ILogger<UserService> _logger;
    
    public UserService(ILogger<UserService> logger)
    {
        _logger = logger;
    }
    
    public void CreateUser(string email)
    {
        _logger.LogInformation("Creating user {Email}", email);
    }
}
```

### 1.2 Add Structured Logging Provider

> **ALWAYS use**: **Serilog** ⭐ (most popular) or NLog

**Install Serilog**:
```bash
dotnet add package Serilog.AspNetCore
dotnet add package Serilog.Sinks.Console
dotnet add package Serilog.Sinks.File
```

**Configure** (Program.cs):
```csharp
builder.Host.UseSerilog((context, configuration) =>
    configuration
        .ReadFrom.Configuration(context.Configuration)
        .Enrich.FromLogContext()
        .WriteTo.Console()
        .WriteTo.File("logs/log-.txt", rollingInterval: RollingInterval.Day));
```

### 1.3 Add Correlation ID Middleware

**Install**:
```bash
dotnet add package CorrelationId
```

**Configure**:
```csharp
builder.Services.AddDefaultCorrelationId();
app.UseCorrelationId();
```

**Verify**: Logs structured (JSON), correlation IDs tracked, no sensitive data logged

---

## Phase 2: Application Monitoring

**Branch**: `logging/monitoring`

### 2.1 Health Checks

> **ALWAYS use**: ASP.NET Core built-in health checks

**Configure**:
```csharp
builder.Services.AddHealthChecks()
    .AddDbContextCheck<AppDbContext>()
    .AddRedis(configuration["Redis:ConnectionString"]);

app.MapHealthChecks("/health");
```

### 2.2 Metrics with Prometheus

**Install**:
```bash
dotnet add package prometheus-net.AspNetCore
```

**Configure**:
```csharp
app.UseMetricServer(); // /metrics endpoint
app.UseHttpMetrics();
```

### 2.3 Error Tracking

> **ALWAYS use**: **Sentry** ⭐ or Application Insights

**Sentry Setup**:
```bash
dotnet add package Sentry.AspNetCore
```

```csharp
builder.WebHost.UseSentry(options =>
{
    options.Dsn = builder.Configuration["Sentry:Dsn"];
    options.Environment = builder.Environment.EnvironmentName;
});
```

**Verify**: Health checks work, metrics exposed, errors tracked

---

## Phase 3: Distributed Tracing

**Branch**: `logging/tracing`

### 3.1 Configure OpenTelemetry

**Install**:
```bash
dotnet add package OpenTelemetry.Extensions.Hosting
dotnet add package OpenTelemetry.Instrumentation.AspNetCore
dotnet add package OpenTelemetry.Instrumentation.Http
```

**Configure**:
```csharp
builder.Services.AddOpenTelemetry()
    .WithTracing(builder => builder
        .AddAspNetCoreInstrumentation()
        .AddHttpClientInstrumentation()
        .AddSource("MyApp")
        .AddJaegerExporter());
```

**Verify**: Traces visible in Jaeger/Zipkin, trace IDs propagated

---

## Phase 4: Log Aggregation & Alerts

**Branch**: `logging/aggregation`

### 4.1 Configure Log Shipping

> **Options**:
> - **Application Insights** ⭐ (Azure, comprehensive)
> - **Seq** (self-hosted, .NET-focused)
> - **ELK Stack**
> - **Datadog**

**Application Insights**:
```bash
dotnet add package Microsoft.ApplicationInsights.AspNetCore
```

```csharp
builder.Services.AddApplicationInsightsTelemetry();
```

### 4.2 Create Alerts

> **Alert on**: Error rate >1%, Response time p99 >2s, Health check failures, High CPU/memory (>80%)

### 4.3 Dashboards

> **Include**: RED metrics (Rate, Errors, Duration), Resource usage, Database performance, Cache hit rate

**Verify**: Logs aggregated, alerts configured, dashboards created

---

## Framework-Specific Notes

| Framework | Logger | Health Checks | Notes |
|-----------|--------|---------------|-------|
| **ASP.NET Core Web API** | ILogger + Serilog | Built-in | UseHttpLogging() middleware |
| **Blazor** | ILogger | Custom health endpoint | Client-side logging limited |
| **Worker Services** | ILogger | IHealthCheck | Background service monitoring |
| **.NET MAUI** | ILogger | N/A | Use App Center for mobile analytics |

---

## Best Practices

### Log Levels
| Level | Use Case |
|-------|----------|
| **Trace** | Very detailed, usually disabled |
| **Debug** | Detailed troubleshooting |
| **Information** | General flow of application |
| **Warning** | Unexpected events, degraded functionality |
| **Error** | Errors and exceptions |
| **Critical** | Application/system failures |

### What to Log/Not Log
> **ALWAYS log**: Structured data with `{Parameter}` syntax, Request/response details, Authentication events, Business events

> **NEVER log**: Passwords, API keys, Credit card data, PII without redaction

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| **Logs not appearing** | Check appsettings.json log levels, verify Serilog configuration |
| **High memory usage** | Enable log file rolling, reduce verbosity, check for infinite loops |
| **Missing correlation IDs** | Ensure CorrelationId middleware before MVC middleware |

---

## AI Self-Check

- [ ] ILogger used throughout application
- [ ] Serilog configured with structured logging
- [ ] Correlation IDs tracked
- [ ] No sensitive data in logs
- [ ] Health checks implemented
- [ ] Metrics endpoint exposed
- [ ] Error tracking configured
- [ ] Distributed tracing enabled (if microservices)
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
