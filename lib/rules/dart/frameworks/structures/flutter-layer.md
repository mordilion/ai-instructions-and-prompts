# Flutter Layer-First Structure

> **Scope**: Layer-organized structure for Flutter  
> **Applies to**: Flutter projects with layer-first structure  
> **Extends**: dart/frameworks/flutter.md

## CRITICAL REQUIREMENTS

> **ALWAYS**: Presentation → Domain → Data dependency flow
> **ALWAYS**: Models in Data layer (JSON serialization)
> **ALWAYS**: Entities in Domain layer (business logic)
> **ALWAYS**: Screens/Widgets in Presentation layer
> **ALWAYS**: Repository pattern in Data layer
> 
> **NEVER**: Presentation depends on Data directly
> **NEVER**: Domain depends on Presentation or Data
> **NEVER**: Mix UI and business logic
> **NEVER**: Skip repository abstraction
> **NEVER**: Circular dependencies between layers

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

## AI Self-Check

- [ ] Presentation → Domain → Data flow?
- [ ] Models in Data layer (JSON serialization)?
- [ ] Entities in Domain layer (if used)?
- [ ] Screens/Widgets in Presentation layer?
- [ ] Repository pattern in Data layer?
- [ ] State management in Presentation?
- [ ] No Presentation → Data direct dependency?
- [ ] No Domain → Presentation dependency?
- [ ] Clear layer boundaries?
- [ ] Repository abstraction not skipped?

