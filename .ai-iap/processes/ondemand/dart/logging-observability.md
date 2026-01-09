# Dart/Flutter Logging & Observability - Copy This Prompt

> **Type**: One-time setup process  
> **When to use**: Setting up production logging and monitoring  
> **Instructions**: Copy the complete prompt below and paste into your AI tool

---

## 📋 Complete Self-Contained Prompt

```
========================================
DART/FLUTTER LOGGING & OBSERVABILITY
========================================

CONTEXT:
You are implementing production-grade logging and observability for a Dart/Flutter project.

CRITICAL REQUIREMENTS:
- ALWAYS use structured logging (JSON format)
- NEVER log sensitive data (PII, tokens, passwords)
- Use log levels appropriately (debug, info, warn, error)
- Integrate crash reporting for mobile apps

========================================
CATCH-UP: READ EXISTING DOCUMENTATION
========================================

BEFORE starting, check for existing documentation:
1. Read PROJECT-MEMORY.md, LOGIC-ANOMALIES.md, LOGGING-SETUP.md if they exist

Use this to continue from where work stopped. If no docs: Start fresh.

========================================
PHASE 1 - STRUCTURED LOGGING
========================================

Install logger package:
```yaml
dependencies:
  logger: ^2.0.0
```

Configure for production:
```dart
import 'package:logger/logger.dart';

final logger = Logger(
  printer: kReleaseMode ? 
    JsonPrinter() : 
    PrettyPrinter(methodCount: 0),
  level: kReleaseMode ? Level.info : Level.debug,
);

// Usage
logger.i('User action', {'userId': user.id, 'action': 'login'});
logger.e('API error', error, stackTrace);
```

Deliverable: Structured logging implemented

========================================
PHASE 2 - CRASH REPORTING
========================================

For mobile apps, add Firebase Crashlytics:

```yaml
dependencies:
  firebase_crashlytics: ^3.4.0
```

Initialize:
```dart
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  
  runApp(MyApp());
}
```

Record custom logs:
```dart
FirebaseCrashlytics.instance.log('User action: $action');
FirebaseCrashlytics.instance.setCustomKey('userId', userId);
```

Deliverable: Crash reporting active

========================================
PHASE 3 - MONITORING
========================================

Add performance monitoring:
```yaml
dependencies:
  firebase_performance: ^0.9.0
```

Track custom traces:
```dart
final trace = FirebasePerformance.instance.newTrace('api_call');
await trace.start();
try {
  await apiCall();
} finally {
  await trace.stop();
}
```

Track HTTP requests:
```dart
final httpMetric = FirebasePerformance.instance
  .newHttpMetric('https://api.example.com', HttpMethod.Get);
await httpMetric.start();
final response = await http.get(url);
httpMetric.responseCode = response.statusCode;
await httpMetric.stop();
```

Deliverable: Performance monitoring active

========================================
PHASE 4 - LOG AGGREGATION
========================================

For server-side Dart, use Sentry:

```yaml
dependencies:
  sentry: ^7.0.0
```

Initialize:
```dart
import 'package:sentry/sentry.dart';

await Sentry.init((options) {
  options.dsn = 'YOUR_DSN';
  options.environment = 'production';
  options.tracesSampleRate = 0.1;
});

// Capture errors
try {
  await riskyOperation();
} catch (error, stackTrace) {
  await Sentry.captureException(error, stackTrace: stackTrace);
}
```

Deliverable: Centralized error tracking

========================================
BEST PRACTICES
========================================

- Use structured logging (JSON in production)
- Log contextual information (user ID, request ID)
- Never log sensitive data
- Use appropriate log levels
- Enable crash reporting for mobile
- Monitor performance metrics
- Set up alerts for critical errors
- Review logs regularly

========================================
DOCUMENTATION
========================================

Create/update: PROJECT-MEMORY.md, LOGIC-ANOMALIES.md, LOGGING-SETUP.md

========================================
EXECUTION
========================================

START: Read existing docs (CATCH-UP section)
CONTINUE: Implement structured logging (Phase 1)
CONTINUE: Add crash reporting (Phase 2)
CONTINUE: Add monitoring (Phase 3)
OPTIONAL: Add log aggregation (Phase 4)
FINISH: Update all documentation files
REMEMBER: Never log sensitive data, use structured format, document for catch-up
```

---

## Quick Reference

**What you get**: Production logging with crash reporting and monitoring  
**Time**: 2-3 hours  
**Output**: Logger configuration, Firebase integration, monitoring setup
