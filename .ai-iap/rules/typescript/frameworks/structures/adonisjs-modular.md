# AdonisJS Modular Architecture

> **Scope**: Apply to AdonisJS projects using modular/domain-driven architecture
> **Applies to**: TypeScript files in AdonisJS modular projects
> **Extends**: typescript/architecture.md, typescript/frameworks/adonisjs.md
> **Precedence**: Structure rules OVERRIDE framework rules

## Structure Overview

```
app/
├── modules/
│   ├── user/
│   │   ├── controllers/
│   │   │   └── users_controller.ts
│   │   ├── models/
│   │   │   └── user.ts
│   │   ├── validators/
│   │   │   └── user_validator.ts
│   │   ├── services/
│   │   │   └── user_service.ts
│   │   └── routes.ts
│   ├── post/
│   │   ├── controllers/
│   │   ├── models/
│   │   └── routes.ts
│   └── auth/
│       ├── controllers/
│       ├── middleware/
│       └── routes.ts
├── shared/
│   ├── services/
│   ├── middleware/
│   └── validators/
└── start/
    └── routes.ts (imports module routes)
```

## Module Responsibilities

| Layer | Purpose | Dependencies |
|-------|---------|--------------|
| Controllers | HTTP handling | Services, validators |
| Services | Business logic | Models, shared services |
| Models | Data/ORM | None (Lucid models) |
| Validators | Input validation | VineJS schemas |
| Routes | Module endpoints | Controllers |

## Critical Rules

> **ALWAYS**: Keep modules self-contained (feature-first)
> **ALWAYS**: Use shared/ for cross-module code
> **ALWAYS**: Export module routes from routes.ts
> **ALWAYS**: Use dependency injection for services
> **ALWAYS**: Keep controllers thin (delegate to services)
> 
> **NEVER**: Import from other modules (use shared/)
> **NEVER**: Put business logic in controllers
> **NEVER**: Create circular dependencies between modules
> **NEVER**: Mix unrelated features in one module
> **NEVER**: Skip module route registration

## Implementation Pattern

**Layers**: Routes → Controller (@inject service) → Service → Model  
**Dependencies**: Controllers use services, services use models, routes import into start/routes.ts

## Common Mistakes

| Mistake | ❌ Wrong | ✅ Correct |
|---------|---------|-----------|
| **Cross-module Imports** | Import from `../post/` | Use `shared/` |
| **Monolithic Modules** | One huge module | Split by feature/domain |
| **No Shared Code** | Duplicate utilities | Extract to `shared/` |
| **Wrong Organization** | By layer (all controllers/) | By feature (user/, post/) |

## AI Self-Check

- [ ] Modules organized by feature/domain?
- [ ] Self-contained modules (no cross-imports)?
- [ ] Shared code in shared/ directory?
- [ ] Module routes registered in start/routes.ts?
- [ ] Controllers use dependency injection?
- [ ] Business logic in services?
- [ ] Each module has clear responsibility?
- [ ] No circular dependencies?

## Module Communication

```typescript
// ✅ CORRECT - Via shared services
// app/shared/services/notification_service.ts
export default class NotificationService {
  async send(userId: number, message: string) {
    // Implementation
  }
}

// app/modules/user/services/user_service.ts
import { inject } from '@adonisjs/core'
import NotificationService from '#shared/services/notification_service'

@inject()
export default class UserService {
  constructor(protected notifications: NotificationService) {}
  
  async create(data: any) {
    const user = await User.create(data)
    await this.notifications.send(user.id, 'Welcome!')
    return user
  }
}
```

## Key Principles

- **Feature-First**: Organize by business domain
- **Self-Contained**: Modules are independent
- **Shared Resources**: Common code in shared/
- **Clear Boundaries**: No cross-module dependencies
- **Scalability**: Easy to add/remove modules
