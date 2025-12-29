# AdonisJS Framework

> **Scope**: Full-stack MVC framework for Node.js (TypeScript-first)
> **Version**: AdonisJS 6.x
> **Applies to**: TypeScript files using AdonisJS
> **Extends**: typescript/architecture.md, typescript/code-style.md

## CRITICAL REQUIREMENTS (AI: Verify ALL before generating code)

> **ALWAYS**: Use IoC Container for dependency injection with `@inject()`
> **ALWAYS**: Use async/await for all asynchronous operations
> **ALWAYS**: Validate requests using VineJS validators
> **ALWAYS**: Use path aliases (`#controllers`, `#models`, etc.)
> **ALWAYS**: Use Lucid ORM for database operations
> 
> **NEVER**: Use `require()` (use ES6 imports)
> **NEVER**: Access `process.env` directly (use `env` service)
> **NEVER**: Skip validation in controllers
> **NEVER**: Put business logic in controllers
> **NEVER**: Use field injection (use constructor injection)

## Pattern Selection

| Pattern | Use When | Keywords |
|---------|----------|----------|
| **IoC Container** | Dependency injection | `@inject()`, constructor params |
| **Lucid ORM** | Database operations | Active Record, relationships |
| **VineJS** | Input validation | Schema-based, type-safe |
| **Events** | Decoupled side effects | `emitter.emit()` |

## Core Patterns

### Controllers (Request Handlers)

```typescript
import { HttpContext } from '@adonisjs/core/http'
import { inject } from '@adonisjs/core'
import UserService from '#services/user_service'
import { createUserValidator } from '#validators/user'

@inject()
export default class UsersController {
  constructor(protected userService: UserService) {}

  async store({ request, response }: HttpContext) {
    const payload = await request.validateUsing(createUserValidator)
    const user = await this.userService.create(payload)
    return response.created(user)
  }

  async index({ response }: HttpContext) {
    const users = await this.userService.getAll()
    return response.ok(users)
  }
}
```

### Models (Lucid ORM)

```typescript
import { DateTime } from 'luxon'
import { BaseModel, column, hasMany } from '@adonisjs/lucid/orm'
import type { HasMany } from '@adonisjs/lucid/types/relations'
import Post from './post.js'

export default class User extends BaseModel {
  @column({ isPrimary: true })
  declare id: number

  @column()
  declare email: string

  @column({ serializeAs: null })
  declare password: string

  @hasMany(() => Post)
  declare posts: HasMany<typeof Post>

  @column.dateTime({ autoCreate: true })
  declare createdAt: DateTime

  @column.dateTime({ autoCreate: true, autoUpdate: true })
  declare updatedAt: DateTime
}
```

### Validators (VineJS)

```typescript
import vine from '@vinejs/vine'

export const createUserValidator = vine.compile(
  vine.object({
    email: vine.string().email().normalizeEmail(),
    password: vine.string().minLength(8).maxLength(32),
    fullName: vine.string().minLength(3).maxLength(100)
  })
)

export const updateUserValidator = vine.compile(
  vine.object({
    email: vine.string().email().normalizeEmail().optional(),
    fullName: vine.string().minLength(3).maxLength(100).optional()
  })
)
```

### Services (Business Logic)

```typescript
import { inject } from '@adonisjs/core'
import User from '#models/user'
import hash from '@adonisjs/core/services/hash'
import emitter from '@adonisjs/core/services/emitter'
import UserRegistered from '#events/user_registered'

@inject()
export default class UserService {
  async create(data: { email: string; password: string; fullName: string }) {
    const hashedPassword = await hash.make(data.password)
    const user = await User.create({ ...data, password: hashedPassword })
    emitter.emit(new UserRegistered(user))
    return user
  }

  async getAll() {
    return User.query().orderBy('createdAt', 'desc')
  }
}
```

## Routes (start/routes.ts)

```typescript
import router from '@adonisjs/core/services/router'
import { middleware } from '#start/kernel'

const UsersController = () => import('#controllers/users_controller')
const AuthController = () => import('#controllers/auth_controller')

// Auth routes (public)
router.group(() => {
  router.post('login', [AuthController, 'login'])
  router.post('register', [AuthController, 'register'])
}).prefix('/api/v1/auth')

// Protected routes
router.group(() => {
  router.resource('users', UsersController).apiOnly()
}).prefix('/api/v1').middleware(middleware.auth())
```

## Events & Listeners

```typescript
// app/events/user_registered.ts
import { BaseEvent } from '@adonisjs/core/events'
import User from '#models/user'

export default class UserRegistered extends BaseEvent {
  constructor(public user: User) { super() }
}

// app/listeners/send_welcome_email.ts
@inject()
export default class SendWelcomeEmail {
  constructor(protected emailService: EmailService) {}
  
  async handle(event: UserRegistered) {
    await this.emailService.sendWelcome(event.user.email, event.user.fullName)
  }
}

// start/events.ts
import emitter from '@adonisjs/core/services/emitter'
import UserRegistered from '#events/user_registered'
import SendWelcomeEmail from '#listeners/send_welcome_email'

emitter.on(UserRegistered, [SendWelcomeEmail])
```

## Middleware

```typescript
import { HttpContext } from '@adonisjs/core/http'
import { NextFn } from '@adonisjs/core/types/http'

export default class AdminMiddleware {
  async handle({ auth, response }: HttpContext, next: NextFn) {
    const user = auth.user
    
    if (!user || user.role !== 'admin') {
      return response.forbidden({ message: 'Admin access required' })
    }

    await next()
  }
}
```

## Common AI Mistakes (DO NOT MAKE THESE ERRORS)

| Mistake | ❌ Wrong | ✅ Correct | Why Critical |
|---------|---------|-----------|--------------|
| **Field Injection** | `@inject() private service` | Constructor injection | IoC pattern |
| **No Validation** | `request.body()` | `request.validateUsing()` | Security, type safety |
| **Business Logic in Controller** | Logic in controller | Move to service | Separation of concerns |
| **process.env** | Direct access | `env` service | Type safety, validation |
| **require()** | CommonJS | ES6 imports | Module system |

### Anti-Pattern: Field Injection (NOT SUPPORTED)

```typescript
// ❌ WRONG: Field injection (doesn't work)
export default class UsersController {
  @inject()
  private userService: UserService  // ❌ Won't be injected!
}

// ✅ CORRECT: Constructor injection
@inject()
export default class UsersController {
  constructor(protected userService: UserService) {}
}
```

### Anti-Pattern: No Validation (SECURITY RISK)

```typescript
// ❌ WRONG: No validation
async store({ request }: HttpContext) {
  const data = request.body()  // ❌ Unvalidated!
  await User.create(data)
}

// ✅ CORRECT: Validated input
async store({ request, response }: HttpContext) {
  const payload = await request.validateUsing(createUserValidator)
  const user = await this.userService.create(payload)
  return response.created(user)
}
```

## AI Self-Check (Verify BEFORE generating AdonisJS code)

- [ ] Using `@inject()` on class (not fields)?
- [ ] Constructor injection for dependencies?
- [ ] Validating all user input?
- [ ] Business logic in services?
- [ ] Using path aliases (`#controllers`, etc.)?
- [ ] Lucid ORM for database?
- [ ] Events for side effects?
- [ ] Middleware for cross-cutting concerns?
- [ ] Using `env` service (not `process.env`)?
- [ ] ES6 imports (not `require()`)?

## Key Features

| Feature | Purpose | Keywords |
|---------|---------|----------|
| **IoC Container** | Dependency injection | `@inject()` |
| **Lucid ORM** | Database ORM | Active Record, relationships |
| **VineJS** | Validation | Schema-based, type-safe |
| **Events** | Decoupled logic | `emitter.emit()` |
| **Middleware** | Request pipeline | Auth, rate limiting, CORS |
| **Japa** | Testing | Unit, functional tests |

## Testing (Japa)

```typescript
import { test } from '@japa/runner'
import UserFactory from '#database/factories/user_factory'

test.group('Users API', () => {
  test('can create user', async ({ client }) => {
    const response = await client.post('/api/v1/users').json({
      email: 'test@example.com',
      password: 'password123',
      fullName: 'Test User'
    })
    
    response.assertStatus(201)
    response.assertBodyContains({ email: 'test@example.com' })
  })

  test('can list users', async ({ client }) => {
    await UserFactory.createMany(5)
    const response = await client.get('/api/v1/users')
    
    response.assertStatus(200)
    response.assertBodyContains({ data: [] })
  })
})
```

## Best Practices

**MUST**:
- IoC Container with `@inject()`
- Constructor injection
- VineJS validation
- Path aliases
- Lucid ORM

**SHOULD**:
- Services for business logic
- Events for side effects
- Middleware for cross-cutting
- Japa for testing
- env service for configuration

**AVOID**:
- Field injection
- Skipping validation
- Business logic in controllers
- Direct `process.env`
- `require()` syntax
