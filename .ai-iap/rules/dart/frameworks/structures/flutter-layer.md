# Flutter Layer-First Structure

> **Scope**: Use this structure for Flutter apps organized by technical layer.
> **Precedence**: When loaded, this structure overrides any default folder organization from the base Flutter rules.

## Project Structure
```
lib/
├── config/                     # App configuration
│   ├── routes.dart
│   ├── theme.dart
│   └── constants.dart
├── data/                       # Data layer
│   ├── models/                 # Data models (JSON serialization)
│   │   ├── user_model.dart
│   │   └── product_model.dart
│   ├── repositories/           # Repository implementations
│   │   └── user_repository.dart
│   └── datasources/            # API, local storage
│       ├── api_client.dart
│       └── local_storage.dart
├── domain/                     # Business logic (optional)
│   ├── entities/
│   └── usecases/
├── presentation/               # UI layer
│   ├── screens/                # Full-page widgets
│   │   ├── home_screen.dart
│   │   └── profile_screen.dart
│   ├── widgets/                # Reusable widgets
│   │   ├── custom_button.dart
│   │   └── user_card.dart
│   └── controllers/            # State management
│       └── home_controller.dart
├── utils/                      # Helpers
│   └── validators.dart
└── main.dart
```

## Rules
- **Layer Separation**: Clear boundaries between layers
- **Dependency Direction**: Presentation → Domain → Data
- **Flat Structure**: Avoid deep nesting within layers

## When to Use
- Small to medium applications
- Solo developers or small teams
- Rapid prototyping
- Learning Flutter

