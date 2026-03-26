# .NET Logging & Observability - Copy This Prompt

> **Type**: One-time setup process  
> **When to use**: Setting up production logging and monitoring  
> **Instructions**: Copy the complete prompt below and paste into your AI tool

---

## 📋 Complete Self-Contained Prompt

```
========================================
.NET LOGGING & OBSERVABILITY
========================================

CONTEXT:
You are implementing production-grade logging and observability for a .NET application.

CRITICAL REQUIREMENTS:
- ALWAYS use ILogger (built-in framework)
- NEVER log sensitive data (PII, tokens, passwords)
- Use structured logging with semantic log levels
- Integrate Application Insights or Serilog

========================================
CATCH-UP: READ EXISTING DOCUMENTATION
========================================

BEFORE starting, check for existing documentation:
1. Read PROJECT-MEMORY.md, LOGIC-ANOMALIES.md, LOGGING-SETUP.md if they exist

Use this to continue from where work stopped. If no docs: Start fresh.

========================================
PHASE 1 - STRUCTURED LOGGING
========================================

Use built-in ILogger with structured logging:

```csharp
public class UserService
{
    private readonly ILogger<UserService> _logger;
    
    public UserService(ILogger<UserService> logger)
    {
        _logger = logger;
    }
    
    public async Task CreateUser(User user)
    {
        _logger.LogInformation("Creating user {UserId} with email {Email}", 
            user.Id, user.Email);
        
        try
        {
            await _repository.CreateAsync(user);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to create user {UserId}", user.Id);
            throw;
        }
    }
}
```

Configure in Program.cs:
```csharp
builder.Logging.ClearProviders();
builder.Logging.AddConsole();
builder.Logging.AddDebug();
```

Deliverable: Structured logging implemented

========================================
PHASE 2 - SERILOG INTEGRATION
========================================

Install Serilog for advanced logging:

```bash
dotnet add package Serilog.AspNetCore
dotnet add package Serilog.Sinks.Console
dotnet add package Serilog.Sinks.File
```

Configure in Program.cs:
```csharp
using Serilog;

Log.Logger = new LoggerConfiguration()
    .MinimumLevel.Information()
    .WriteTo.Console()
    .WriteTo.File("logs/app-.log", rollingInterval: RollingInterval.Day)
    .Enrich.FromLogContext()
    .Enrich.WithMachineName()
    .Enrich.WithThreadId()
    .CreateLogger();

builder.Host.UseSerilog();
```

Add request logging middleware:
```csharp
app.UseSerilogRequestLogging();
```

Deliverable: Serilog logging active

========================================
PHASE 3 - APPLICATION INSIGHTS
========================================

Install Application Insights:

```bash
dotnet add package Microsoft.ApplicationInsights.AspNetCore
```

Configure in appsettings.json:
```json
{
  "ApplicationInsights": {
    "ConnectionString": "YOUR_CONNECTION_STRING"
  }
}
```

Add to Program.cs:
```csharp
builder.Services.AddApplicationInsightsTelemetry();
```

Track custom metrics:
```csharp
private readonly TelemetryClient _telemetry;

public void TrackMetric(string name, double value)
{
    _telemetry.TrackMetric(name, value);
}
```

Deliverable: Application Insights integrated

========================================
PHASE 4 - HEALTH CHECKS
========================================

Add health checks:

```csharp
builder.Services.AddHealthChecks()
    .AddDbContextCheck<AppDbContext>()
    .AddUrlGroup(new Uri("https://api.external.com"), "External API");

app.MapHealthChecks("/health");
```

Deliverable: Health monitoring active

========================================
BEST PRACTICES
========================================

- Use structured logging with ILogger
- Never log sensitive data
- Use appropriate log levels
- Enrich logs with context (request ID, user ID)
- Use Serilog for production
- Integrate Application Insights for Azure
- Add health checks for dependencies
- Review logs regularly

========================================
DOCUMENTATION
========================================

Create/update: PROJECT-MEMORY.md, LOGIC-ANOMALIES.md, LOGGING-SETUP.md

========================================
EXECUTION
========================================

START: Read existing docs (CATCH-UP section)
CONTINUE: Implement ILogger (Phase 1)
CONTINUE: Add Serilog (Phase 2)
CONTINUE: Add Application Insights (Phase 3)
OPTIONAL: Add health checks (Phase 4)
FINISH: Update all documentation files
REMEMBER: Structured logging, no sensitive data, document for catch-up
```

---

## Quick Reference

**What you get**: Production logging with Application Insights and health checks  
**Time**: 2-3 hours  
**Output**: Logger configuration, Serilog setup, Application Insights integration
