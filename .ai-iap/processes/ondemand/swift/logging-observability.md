# Swift Logging & Observability - Copy This Prompt

> **Type**: One-time setup process  
> **When to use**: Setting up production logging and monitoring  
> **Instructions**: Copy the complete prompt below and paste into your AI tool

---

## 📋 Complete Self-Contained Prompt

```
========================================
SWIFT LOGGING & OBSERVABILITY
========================================

CONTEXT:
You are implementing production-grade logging and observability for a Swift application.

CRITICAL REQUIREMENTS:
- ALWAYS use os.Logger (built-in) or swift-log
- NEVER log sensitive data (PII, tokens, passwords)
- Use appropriate log levels
- Integrate crash reporting (Sentry, Crashlytics)

========================================
PHASE 1 - STRUCTURED LOGGING
========================================

For iOS/macOS, use os.Logger:

```swift
import os

let logger = Logger(subsystem: "com.example.app", category: "networking")

// Usage with different levels
logger.debug("Debug message")
logger.info("User logged in: \\(userId)")
logger.notice("Important event")
logger.warning("Warning: low memory")
logger.error("Error: \\(error.localizedDescription)")
logger.fault("Critical error")
```

For server-side Swift, use swift-log:

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/apple/swift-log.git", from: "1.5.3")
]

// Usage
import Logging

let logger = Logger(label: "com.example.app")

logger.info("User created", metadata: [
    "userId": "\\(user.id)",
    "email": "\\(user.email)"
])
```

Deliverable: Structured logging implemented

========================================
PHASE 2 - CRASH REPORTING (iOS)
========================================

Install Firebase Crashlytics:

```ruby
# Podfile
pod 'Firebase/Crashlytics'
```

Initialize in AppDelegate:
```swift
import FirebaseCrashlytics

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, 
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        return true
    }
}
```

Log custom events:
```swift
Crashlytics.crashlytics().log("User action: \\(action)")
Crashlytics.crashlytics().setCustomValue(userId, forKey: "user_id")

// Capture non-fatal errors
do {
    try riskyOperation()
} catch {
    Crashlytics.crashlytics().record(error: error)
}
```

Deliverable: Crash reporting active

========================================
PHASE 3 - PERFORMANCE MONITORING
========================================

Add Firebase Performance:

```ruby
pod 'Firebase/Performance'
```

Track custom traces:
```swift
import FirebasePerformance

let trace = Performance.startTrace(name: "api_call")
trace?.setValue("GET", forAttribute: "method")

// ... perform operation ...

trace?.stop()
```

Track network requests:
```swift
let metric = HTTPMetric(url: url, httpMethod: .get)
metric?.start()

// ... perform request ...

metric?.responseCode = response.statusCode
metric?.stop()
```

Deliverable: Performance monitoring active

========================================
PHASE 4 - ERROR TRACKING (SERVER)
========================================

For Vapor, add Sentry:

```swift
// Package.swift
.package(url: "https://github.com/getsentry/sentry-swift.git", from: "8.0.0")

// Configure
import Sentry

SentrySDK.start { options in
    options.dsn = "YOUR_DSN"
    options.environment = "production"
    options.tracesSampleRate = 0.1
}

// Capture errors
do {
    try riskyOperation()
} catch {
    SentrySDK.capture(error: error)
    throw error
}
```

Deliverable: Error tracking active

========================================
BEST PRACTICES
========================================

- Use os.Logger for Apple platforms
- Use swift-log for server-side
- Never log sensitive data
- Use appropriate log levels
- Integrate Crashlytics for mobile
- Use Firebase Performance for iOS
- Use Sentry for server-side
- Review logs regularly

========================================
EXECUTION
========================================

START: Implement logging (Phase 1)
CONTINUE: Add crash reporting (Phase 2)
CONTINUE: Add performance monitoring (Phase 3)
OPTIONAL: Add error tracking for server (Phase 4)
REMEMBER: No sensitive data, use os.Logger
```

---

## Quick Reference

**What you get**: Production logging with crash reporting and monitoring  
**Time**: 2-3 hours  
**Output**: Logger configuration, Firebase integration, monitoring setup
