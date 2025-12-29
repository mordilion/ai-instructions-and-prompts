# Logging & Observability Implementation Process - Dart/Flutter

> **Purpose**: Establish production-grade logging, monitoring, and observability for Dart/Flutter applications

> **Core Libraries**: logger, Firebase Crashlytics, Sentry, OpenTelemetry (server)

---

## Phase 1: Structured Logging

> **ALWAYS use**: logger package ⭐
> **NEVER**: Use print() in production (strips in release mode), log passwords/tokens/PII

**Install**:
```yaml
dependencies:
  logger: ^2.0.0
```

**Configuration**:
```dart
import 'package:logger/logger.dart';

final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 5,
    lineLength: 120,
    colors: true,
    printEmojis: true,
  ),
);

logger.i('Info message');
logger.e('Error message', error: error, stackTrace: stackTrace);
```

**Production Logger** (JSON format):
```dart
final logger = Logger(
  printer: SimplePrinter(),
  output: FileOutput(file: File('app.log')),
);
```

> **Git**: `git commit -m "feat: add structured logging with logger package"`

---

## Phase 2: Application Monitoring

> **ALWAYS include**:
- Crash reporting (Firebase Crashlytics ⭐ or Sentry)
- Performance monitoring (Firebase Performance)
- Analytics (Firebase Analytics, Mixpanel)

**Firebase Crashlytics**:
```yaml
dependencies:
  firebase_crashlytics: ^3.4.0
```

```dart
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
PlatformDispatcher.instance.onError = (error, stack) {
  FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  return true;
};
```

**Sentry**:
```yaml
dependencies:
  sentry_flutter: ^7.0.0
```

```dart
import 'package:sentry_flutter/sentry_flutter.dart';

await SentryFlutter.init(
  (options) => options.dsn = 'YOUR_DSN',
  appRunner: () => runApp(MyApp()),
);
```

> **Git**: `git commit -m "feat: add crash reporting and monitoring"`

---

## Phase 3: Distributed Tracing

> **ALWAYS use** (server-side Dart): OpenTelemetry

**Mobile**: Network tracing with dio_http_inspector or Firebase Performance

```dart
// Firebase Performance for HTTP tracing
final httpMetric = FirebasePerformance.instance.newHttpMetric(
  url, HttpMethod.Get);
await httpMetric.start();
// ... make request ...
await httpMetric.stop();
```

> **Git**: `git commit -m "feat: add performance tracing"`

---

## Phase 4: Log Aggregation & Alerts

> **ALWAYS use**:
- **Mobile**: Firebase Crashlytics, Sentry (cloud-based)
- **Server**: ELK Stack, Datadog, CloudWatch

**Alerts**: Crash-free rate <99%, ANR rate >0.5%, API error rate >1%

> **Git**: `git commit -m "feat: add log aggregation and alerting"`

---

## Platform-Specific Notes

### Flutter (Mobile)
- logger for debug logging
- Firebase Crashlytics for crash reporting
- Firebase Performance for monitoring
- Firebase Analytics for user analytics

### Dart (Server)
- logger for structured logging
- Prometheus metrics (shelf_prometheus)
- OpenTelemetry for tracing

---

## AI Self-Check

- [ ] Structured logging configured (logger package)
- [ ] No sensitive data in logs
- [ ] Crash reporting enabled (Crashlytics/Sentry)
- [ ] Performance monitoring configured
- [ ] Analytics tracking implemented
- [ ] Log aggregation setup
- [ ] Alerts created (crash rate, ANR rate)

---

**Process Complete** ✅

