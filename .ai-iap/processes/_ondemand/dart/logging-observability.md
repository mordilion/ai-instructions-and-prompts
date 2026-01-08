# Logging & Observability Implementation Process - Dart/Flutter

> **Purpose**: Establish production-grade logging, monitoring, and observability

---

## Prerequisites

> **BEFORE starting**:
> - Working Dart/Flutter application
> - Git repository

---

## Phase 1: Structured Logging

**Branch**: `logging/structured`

### 1.1 Use logger package

**Install**:
```yaml
dependencies:
  logger: ^2.0.0
```

**Configure**:
```dart
import 'package:logger/logger.dart';

final logger = Logger(
  printer: PrettyPrinter(),
  level: Level.info,
);

// Usage
logger.i('User created', userId: user.id);
logger.e('Error occurred', error, stackTrace);
```

**Production**: Use JSONPrinter for structured logs

### 1.2 Firebase Crashlytics (Mobile)

**Install**:
```yaml
dependencies:
  firebase_crashlytics: ^3.4.0
```

**Configure**:
```dart
await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
```

**Verify**: Logs structured, crashes reported

---

## Phase 2: Application Monitoring

**Branch**: `logging/monitoring`

### 2.1 Health Checks (Server)

**Dart server**:
```dart
router.get('/health', (Request request) {
  return Response.ok('{"status": "healthy"}');
});
```

### 2.2 Analytics (Mobile)

**Firebase Analytics**:
```yaml
dependencies:
  firebase_analytics: ^10.7.0
```

```dart
await FirebaseAnalytics.instance.logEvent(
  name: 'user_created',
  parameters: {'user_id': userId},
);
```

### 2.3 Error Tracking

> **Mobile**: Firebase Crashlytics ⭐
> **Server**: Sentry

**Verify**: Health checks (server), analytics tracking (mobile), errors tracked

---

## Phase 3: Performance Monitoring

**Branch**: `logging/performance`

### 3.1 Firebase Performance (Mobile)

**Install**:
```yaml
dependencies:
  firebase_performance: ^0.9.3
```

**Usage**:
```dart
final trace = FirebasePerformance.instance.newTrace('user_creation');
await trace.start();
// ... operation ...
await trace.stop();
```

**Verify**: Performance metrics collected

---

## Phase 4: Log Aggregation

**Branch**: `logging/aggregation`

### 4.1 Mobile Logs

> **Firebase**: Crashlytics + Analytics + Performance Monitor

### 4.2 Server Logs

> **Options**: ELK Stack, Datadog, CloudWatch

### 4.3 Alerts

> **Alert on**: Crash rate >0.1%, Error rate >1%

**Verify**: Logs aggregated, alerts configured

---

## Platform Notes

| Platform | Logger | Monitoring |
|----------|--------|------------|
| **Flutter (Mobile)** | logger + Firebase | Crashlytics, Analytics |
| **Dart (Server)** | logger | Sentry, Prometheus |

---

## Best Practices

### What to Log/Not Log
> **ALWAYS**: Structured data, User actions, Errors

> **NEVER**: Passwords, Tokens, PII

---

## AI Self-Check

- [ ] logger package configured
- [ ] Firebase Crashlytics enabled (mobile)
- [ ] No sensitive data logged
- [ ] Error tracking configured
- [ ] Analytics tracking (mobile)
- [ ] Performance monitoring (mobile)
- [ ] Alerts configured

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
