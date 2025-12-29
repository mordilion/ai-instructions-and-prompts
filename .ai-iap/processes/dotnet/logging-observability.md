# Logging & Observability Implementation Process - .NET/C#

> **Purpose**: Establish production-grade logging, monitoring, and observability for .NET applications

---

## Prerequisites

> **BEFORE starting**:
> - Working .NET application (6.0+ recommended)
> - Git repository
> - Understanding of log levels (Trace, Debug, Information, Warning, Error, Critical)

---

## Phase 1: Structured Logging

### Branch Strategy
```
main → logging/structured
```

### 1.1 Install Logging Library

> **ALWAYS use** (pick one):
> - **Serilog** ⭐ (most popular, structured logging)
> - **NLog** (flexible configuration)
> - Built-in **ILogger** (minimal, extend with providers)

> **NEVER**:
> - Use Console.WriteLine in production
> - Log sensitive data (passwords, tokens, PII)
> - Use synchronous logging in hot paths

**Install Serilog**:
```bash
dotnet add package Serilog.AspNetCore
dotnet add package Serilog.Sinks.Console
dotnet add package Serilog.Sinks.File
```

### 1.2 Configure Structured Logger

> **ALWAYS include**:
> - JSON format for machine parsing
> - Timestamp (ISO 8601)
> - Log level
> - Context/metadata (CorrelationId, UserId, MachineName)
> - Separate sinks (Console, File, external service)

> **NEVER**:
> - Use plain text format in production
> - Mix structured and unstructured logs
> - Log entire objects without sanitization

**Serilog Configuration**:
```csharp
// Program.cs
using Serilog;

Log.Logger = new LoggerConfiguration()
    .MinimumLevel.Information()
    .Enrich.FromLogContext()
    .Enrich.WithMachineName()
    .Enrich.WithEnvironmentName()
    .WriteTo.Console(new JsonFormatter())
    .WriteTo.File(
        formatter: new JsonFormatter(),
        path: "logs/log-.txt",
        rollingInterval: RollingInterval.Day,
        retainedFileCountLimit: 30)
    .CreateLogger();

builder.Host.UseSerilog();
```

### 1.3 Add Correlation ID Middleware

> **ALWAYS**:
> - Generate unique ID per request (Guid)
> - Attach to HttpContext
> - Include in all logs for that request
> - Use correlation ID from headers (X-Correlation-ID) if available

**Correlation Middleware**:
```csharp
app.Use(async (context, next) =>
{
    var correlationId = context.Request.Headers["X-Correlation-ID"].FirstOrDefault() 
        ?? Guid.NewGuid().ToString();
    
    context.Response.Headers.Add("X-Correlation-ID", correlationId);
    
    using (LogContext.PushProperty("CorrelationId", correlationId))
    {
        await next();
    }
});
```

### 1.4 Commit & Verify

> **Git workflow**:
> ```
> git add Program.cs *.csproj
> git commit -m "feat: add structured logging with Serilog"
> git push origin logging/structured
> ```

> **Verify**:
> - Logs output as JSON
> - Timestamp present in each log
> - Correlation ID tracked across logs
> - No sensitive data in logs

---

## Phase 2: Application Monitoring

### Branch Strategy
```
main → logging/monitoring
```

### 2.1 Add Health Check Endpoint

> **ALWAYS include**:
> - Built-in ASP.NET Core Health Checks
> - Check database connectivity (AddDbContextCheck)
> - Check external dependencies (AddUrlGroup for APIs)
> - Return HTTP 200 if healthy, 503 if unhealthy

> **NEVER**:
> - Expose detailed error messages to public
> - Skip timeout on dependency checks
> - Return 200 when critical services are down

**Health Check Setup**:
```csharp
// Program.cs
builder.Services.AddHealthChecks()
    .AddDbContextCheck<AppDbContext>()
    .AddRedis(Configuration.GetConnectionString("Redis"))
    .AddUrlGroup(new Uri("https://api.example.com/health"), "External API");

app.MapHealthChecks("/health");
```

### 2.2 Add Metrics Collection

> **ALWAYS use**:
> - **Application Insights** ⭐ (Azure, full-featured)
> - **Prometheus** with prometheus-net
> - **OpenTelemetry** (vendor-neutral)

> **Key metrics to track**:
> - Request count (by endpoint, status code)
> - Response time (p50, p95, p99)
> - Error rate
> - Active connections
> - Memory/CPU usage

**Prometheus Setup**:
```bash
dotnet add package prometheus-net.AspNetCore
```

```csharp
using Prometheus;

app.UseMetricServer(); // /metrics endpoint
app.UseHttpMetrics();
```

### 2.3 Add Error Tracking

> **ALWAYS use** (pick one):
> - **Sentry** ⭐ (comprehensive, easy setup)
> - **Application Insights** (Azure ecosystem)
> - **Raygun**

> **NEVER**:
> - Catch exceptions without logging
> - Send PII to error tracking
> - Ignore unhandled exceptions

**Sentry Setup**:
```bash
dotnet add package Sentry.AspNetCore
```

```csharp
// Program.cs
builder.WebHost.UseSentry(options =>
{
    options.Dsn = Configuration["Sentry:Dsn"];
    options.Environment = builder.Environment.EnvironmentName;
    options.TracesSampleRate = 0.1;
});
```

### 2.4 Commit & Verify

> **Git workflow**:
> ```
> git add Program.cs *.csproj
> git commit -m "feat: add health checks, metrics, and error tracking"
> git push origin logging/monitoring
> ```

> **Verify**:
> - /health endpoint returns correct status
> - /metrics endpoint exposes Prometheus metrics
> - Errors sent to Sentry
> - No performance degradation

---

## Phase 3: Distributed Tracing

### Branch Strategy
```
main → logging/tracing
```

### 3.1 Install Tracing Library

> **ALWAYS use**:
> - **Application Insights** ⭐ (Azure, auto-instrumentation)
> - **OpenTelemetry** (vendor-neutral)
> - **Jaeger** (self-hosted)

**Application Insights Setup**:
```bash
dotnet add package Microsoft.ApplicationInsights.AspNetCore
```

```csharp
builder.Services.AddApplicationInsightsTelemetry(Configuration["ApplicationInsights:ConnectionString"]);
```

### 3.2 Configure Distributed Tracing

> **ALWAYS include**:
> - Trace ID propagation across services (W3C Trace Context)
> - Span for each major operation (DB query, HTTP call)
> - Contextual properties (UserId, TenantId)
> - Sampling strategy (not 100% in production)

### 3.3 Add Custom Telemetry

> **ALWAYS**:
> - Create activities for business-critical operations
> - Add relevant tags (query, cache hit/miss)
> - Record exceptions in activities
> - Dispose activities properly

**Custom Activity Example**:
```csharp
using var activity = Activity.Current?.Source.StartActivity("ProcessOrder");
activity?.SetTag("OrderId", orderId);
activity?.SetTag("Amount", amount);
```

### 3.4 Commit & Verify

> **Git workflow**:
> ```
> git add Program.cs
> git commit -m "feat: add distributed tracing with Application Insights"
> git push origin logging/tracing
> ```

> **Verify**:
> - Traces visible in Application Insights
> - Trace ID propagated across services
> - Dependencies tracked automatically
> - No excessive overhead (<5%)

---

## Phase 4: Log Aggregation & Alerts

### Branch Strategy
```
main → logging/aggregation
```

### 4.1 Configure Log Shipping

> **ALWAYS use** (pick one):
> - **Azure Application Insights** ⭐ (managed)
> - **ELK Stack** (self-hosted)
> - **Datadog**
> - **Splunk**

> **NEVER**:
> - Rely only on local file logs
> - Ship logs without rate limiting
> - Forget to configure log retention

**Serilog + Application Insights**:
```bash
dotnet add package Serilog.Sinks.ApplicationInsights
```

```csharp
.WriteTo.ApplicationInsights(
    Configuration["ApplicationInsights:ConnectionString"],
    TelemetryConverter.Traces)
```

### 4.2 Create Alerts

> **ALWAYS alert on**:
> - Exception rate threshold (>10/min)
> - Response time p99 >2s
> - Health check failures
> - High memory/CPU usage (>80%)
> - Failed dependencies

> **NEVER**:
> - Alert on every exception (use thresholds)
> - Create alerts without action items
> - Forget to test alert delivery

### 4.3 Add Dashboards

> **ALWAYS include**:
> - Request rate, error rate, duration (RED metrics)
> - CPU, memory, GC metrics
> - Database query performance
> - Cache hit rate
> - Business metrics

### 4.4 Commit & Verify

> **Git workflow**:
> ```
> git add Program.cs
> git commit -m "feat: add log aggregation and alerting"
> git push origin logging/aggregation
> ```

> **Verify**:
> - Logs visible in Application Insights
> - Alerts trigger correctly
> - Dashboards show real-time data
> - Runbooks documented

---

## Framework-Specific Notes

### ASP.NET Core Web API
- Built-in ILogger with DI
- Middleware: UseSerilogRequestLogging()
- Health checks: AddDbContextCheck, AddUrlGroup

### ASP.NET Core MVC
- Same as Web API
- Log page views, form submissions
- Use IActionFilter for logging

### Minimal APIs
- Configure Serilog in Program.cs
- Use MapHealthChecks
- Add middleware for correlation ID

### Blazor
- Server: same as ASP.NET Core
- WASM: browser console only (or ship to backend)

---

## Best Practices

### Log Levels
- **Trace**: Very detailed, not in production
- **Debug**: Detailed for troubleshooting
- **Information**: General info
- **Warning**: Unexpected but recoverable
- **Error**: Operation failed
- **Critical**: App cannot continue

### What to Log
> **ALWAYS log**:
> - Request/response (method, path, status, duration)
> - Exceptions with stack traces
> - Authentication events
> - Business events
> - Performance metrics

> **NEVER log**:
> - Passwords, tokens, secrets
> - PII without consent
> - Credit card numbers
> - Connection strings

### Performance
> **ALWAYS**:
> - Use async logging (Serilog.Sinks.Async)
> - Set appropriate log levels (Info in prod, Debug in dev)
> - Use log sampling for high-frequency events
> - Configure log file retention

---

## AI Self-Check

Before completing this process, verify:

- [ ] Structured logging configured (Serilog/NLog)
- [ ] Log levels properly used
- [ ] Correlation ID tracked
- [ ] No sensitive data in logs
- [ ] Health check endpoint implemented
- [ ] Metrics endpoint exposed (/metrics)
- [ ] Error tracking configured (Sentry/App Insights)
- [ ] Distributed tracing enabled
- [ ] Log aggregation configured
- [ ] Alerts created with thresholds
- [ ] Dashboards created
- [ ] Runbooks documented
- [ ] Log retention configured
- [ ] Performance impact minimal

---

## Bug Logging

> **ALWAYS log bugs found during logging setup**:
> - Create ticket/issue for each bug
> - Tag with `bug`, `observability`, `infrastructure`
> - **NEVER fix production code during logging setup**
> - Link bug to logging implementation branch

---

## Final Commit

```bash
git checkout main
git merge logging/aggregation
git tag -a v1.0.0-logging -m "Logging and observability implemented"
git push origin main --tags
```

---

**Process Complete** ✅

