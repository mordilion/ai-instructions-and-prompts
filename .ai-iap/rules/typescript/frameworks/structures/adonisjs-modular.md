# AdonisJS Modular/Domain Structure

> **Scope**: Use this structure for large AdonisJS apps organized by domain/module.
> **Precedence**: When loaded, this structure overrides any default folder organization from the base AdonisJS rules.

## Project Structure

```
app/
├── modules/                    # Feature modules
│   ├── user/
│   │   ├── controllers/
│   │   │   └── users_controller.ts
│   │   ├── models/
│   │   │   └── user.ts
│   │   ├── services/
│   │   │   └── user_service.ts
│   │   ├── validators/
│   │   │   └── user_validator.ts
│   │   ├── events/
│   │   │   ├── user_registered.ts
│   │   │   └── user_updated.ts
│   │   ├── listeners/
│   │   │   └── send_welcome_email.ts
│   │   ├── middleware/
│   │   │   └── user_ownership.ts
│   │   └── routes.ts          # Module-specific routes
│   ├── post/
│   │   ├── controllers/
│   │   ├── models/
│   │   ├── services/
│   │   └── routes.ts
│   └── auth/
│       ├── controllers/
│       ├── services/
│       ├── validators/
│       └── routes.ts
├── shared/                     # Cross-module utilities
│   ├── services/
│   │   └── email_service.ts
│   ├── middleware/
│   │   └── rate_limiter.ts
│   └── exceptions/
│       └── business_exception.ts
└── core/                      # Core application logic
    ├── database/
    └── types/
config/                        # Configuration files
database/
├── migrations/
├── seeders/
└── factories/
start/
├── kernel.ts
├── routes.ts                  # Imports all module routes
└── events.ts
tests/
├── unit/
│   ├── user/
│   └── post/
└── functional/
    ├── user/
    └── post/
```

## Module Structure

Each module is self-contained with its own:
- Controllers (HTTP layer)
- Models (Data layer)
- Services (Business logic)
- Validators (Request validation)
- Events & Listeners (Domain events)
- Routes (Module routing)

### Example: User Module

**controllers/users_controller.ts**
```typescript
import { HttpContext } from '@adonisjs/core/http'
import { inject } from '@adonisjs/core'
import UserService from '#modules/user/services/user_service'
import { createUserValidator, updateUserValidator } from '#modules/user/validators/user_validator'

@inject()
export default class UsersController {
  constructor(protected userService: UserService) {}

  async index({ response }: HttpContext) {
    const users = await this.userService.getAll()
    return response.ok(users)
  }

  async store({ request, response }: HttpContext) {
    const payload = await request.validateUsing(createUserValidator)
    const user = await this.userService.create(payload)
    return response.created(user)
  }

  async show({ params, response }: HttpContext) {
    const user = await this.userService.findById(params.id)
    return response.ok(user)
  }

  async update({ params, request, response }: HttpContext) {
    const payload = await request.validateUsing(updateUserValidator)
    const user = await this.userService.update(params.id, payload)
    return response.ok(user)
  }

  async destroy({ params, response }: HttpContext) {
    await this.userService.delete(params.id)
    return response.noContent()
  }
}
```

**services/user_service.ts**
```typescript
import { inject } from '@adonisjs/core'
import User from '#modules/user/models/user'
import hash from '@adonisjs/core/services/hash'
import emitter from '@adonisjs/core/services/emitter'
import UserRegistered from '#modules/user/events/user_registered'

@inject()
export default class UserService {
  async create(data: { email: string; password: string; fullName: string }) {
    const hashedPassword = await hash.make(data.password)
    
    const user = await User.create({
      ...data,
      password: hashedPassword,
    })

    // Emit domain event
    emitter.emit(new UserRegistered(user))

    return user
  }

  async getAll() {
    return User.query().orderBy('createdAt', 'desc')
  }

  async findById(id: number) {
    return User.findOrFail(id)
  }

  async update(id: number, data: Partial<User>) {
    const user = await this.findById(id)
    await user.merge(data).save()
    return user
  }

  async delete(id: number) {
    const user = await this.findById(id)
    await user.delete()
  }
}
```

**routes.ts**
```typescript
import router from '@adonisjs/core/services/router'
import { middleware } from '#start/kernel'

const UsersController = () => import('#modules/user/controllers/users_controller')

export default function userRoutes() {
  router.group(() => {
    router.resource('users', UsersController).apiOnly()
    router.post('users/:id/follow', [UsersController, 'follow'])
  }).prefix('/api/v1').middleware(middleware.auth())
}
```

## Global Routes File

**start/routes.ts**
```typescript
import router from '@adonisjs/core/services/router'

// Import module routes
import userRoutes from '#modules/user/routes'
import postRoutes from '#modules/post/routes'
import authRoutes from '#modules/auth/routes'

// Health check
router.get('/health', () => ({ status: 'ok' }))

// Register module routes
userRoutes()
postRoutes()
authRoutes()
```

## Shared Services

**shared/services/email_service.ts**
```typescript
import { inject } from '@adonisjs/core'
import mail from '@adonisjs/mail/services/main'

@inject()
export default class EmailService {
  async sendWelcome(email: string, name: string) {
    await mail.send((message) => {
      message
        .to(email)
        .subject('Welcome!')
        .htmlView('emails/welcome', { name })
    })
  }

  async sendPasswordReset(email: string, token: string) {
    await mail.send((message) => {
      message
        .to(email)
        .subject('Reset Password')
        .htmlView('emails/reset-password', { token })
    })
  }
}
```

## Rules

- **Self-Contained Modules**: Each module has all its layers
- **Module Routes**: Each module exports its own routes
- **Domain Events**: Use events for cross-module communication
- **Shared Services**: Only truly generic code in shared/
- **No Cross-Module Imports**: Modules communicate via events or shared services
- **Core for Infrastructure**: Database, types, configs in core/

## When to Use

- Large applications (10+ domain entities)
- Multiple developers/teams
- Clear domain boundaries
- Need for module isolation
- Microservices candidates

## Module Communication

### Via Events
```typescript
// In user module
emitter.emit(new UserRegistered(user))

// In notification module
export default class SendWelcomeNotification {
  async handle(event: UserRegistered) {
    // Cross-module communication via events
  }
}
```

### Via Shared Services
```typescript
// In any module
import EmailService from '#app/shared/services/email_service'

@inject()
export default class SomeService {
  constructor(protected emailService: EmailService) {}
  
  async doSomething() {
    await this.emailService.sendWelcome(email, name)
  }
}
```

## Testing

Tests should mirror module structure:

```
tests/
├── unit/
│   ├── user/
│   │   ├── user_service.spec.ts
│   │   └── user_validator.spec.ts
│   └── post/
│       └── post_service.spec.ts
└── functional/
    ├── user/
    │   └── users.spec.ts
    └── post/
        └── posts.spec.ts
```

