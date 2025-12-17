# Flutter Feature-First Structure

> **Scope**: Use this structure for Flutter apps organized by feature/module.
> **Precedence**: When loaded, this structure overrides any default folder organization from the base Flutter rules.

## Project Structure
```
lib/
├── app/                        # App-level setup
│   ├── app.dart                # MaterialApp/CupertinoApp
│   ├── routes.dart             # Route definitions
│   └── theme.dart
├── features/                   # Feature modules
│   ├── auth/
│   │   ├── data/
│   │   │   ├── repositories/
│   │   │   └── datasources/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   └── usecases/
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   ├── widgets/
│   │   │   └── bloc/           # or providers/controllers
│   │   └── auth.dart           # Barrel export
│   ├── home/
│   └── settings/
├── core/                       # Shared utilities
│   ├── constants/
│   ├── errors/
│   ├── network/
│   └── utils/
├── shared/                     # Shared widgets
│   └── widgets/
└── main.dart
```

## Rules
- **Feature Isolation**: Each feature has its own data, domain, presentation
- **Barrel Exports**: Export public API via feature's main file
- **No Cross-Feature Imports**: Use core/shared for common code
- **Feature Independence**: Features can be extracted into packages

## Import Pattern
```dart
// ✅ Good - Import from feature barrel
import 'package:app/features/auth/auth.dart';

// ❌ Bad - Deep import into feature
import 'package:app/features/auth/presentation/screens/login_screen.dart';
```

## When to Use
- Medium to large applications
- Multiple developers/teams
- Features that may become separate packages

