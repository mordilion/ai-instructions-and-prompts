# AdonisJS Framework

> **Scope**: Full-stack MVC framework for Node.js (TypeScript-first)
> **Version**: AdonisJS 6.x
> **Applies to**: TypeScript files using AdonisJS
> **Extends**: typescript/architecture.md, typescript/code-style.md

## CRITICAL REQUIREMENTS

> **ALWAYS**: Use IoC Container with `@inject()`
> **ALWAYS**: Use async/await for async operations
> **ALWAYS**: Validate with VineJS validators
> **ALWAYS**: Use path aliases (`#controllers`, etc.)
> **ALWAYS**: Use Lucid ORM for database
> 
> **NEVER**: Use `require()` (use ES6 imports)
> **NEVER**: Access `process.env` directly (use `env`)
> **NEVER**: Skip validation
> **NEVER**: Put business logic in controllers
> **NEVER**: Use field injection

## Core Patterns

### Controller

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
}
```

### Model (Lucid ORM)

```typescript
import { BaseModel, column, hasMany } from '@adonisjs/lucid/orm'

export default class User extends BaseModel {
  @column({ isPrimary: true })
  declare id: number

  @column()
  declare email: string

  @column({ serializeAs: null })
  declare password: string

  @hasMany(() => Post)
  declare posts: HasMany<typeof Post>
}
```

### Validator (VineJS)

```typescript
import vine from '@vinejs/vine'

export const createUserValidator = vine.compile(
  vine.object({
    email: vine.string().email().normalizeEmail(),
    password: vine.string().minLength(8),
    fullName: vine.string().minLength(3)
  })
)
```

### Service

```typescript
import { inject } from '@adonisjs/core'
import User from '#models/user'
import hash from '@adonisjs/core/services/hash'

@inject()
export default class UserService {
  async create(data: { email: string; password: string }) {
    const hashedPassword = await hash.make(data.password)
    return User.create({ ...data, password: hashedPassword })
  }
}
```

### Routes

```typescript
import router from '@adonisjs/core/services/router'
import { middleware } from '#start/kernel'

const UsersController = () => import('#controllers/users_controller')

router.group(() => {
  router.resource('users', UsersController).apiOnly()
}).prefix('/api/v1').middleware(middleware.auth())
```

### Events

```typescript
// app/events/user_registered.ts
import { BaseEvent } from '@adonisjs/core/events'

export default class UserRegistered extends BaseEvent {
  constructor(public user: User) { super() }
}

// start/events.ts
import emitter from '@adonisjs/core/services/emitter'
emitter.on(UserRegistered, [SendWelcomeEmail])
```

## Common AI Mistakes

| Mistake | ❌ Wrong | ✅ Correct |
|---------|---------|-----------|
| **Field Injection** | `@inject() private service` | Constructor injection |
| **No Validation** | `request.body()` | `validateUsing()` |
| **Business Logic** | In controller | In service |
| **process.env** | Direct access | `env` service |

### Anti-Pattern: Field Injection

```typescript
// ❌ WRONG
export default class UsersController {
  @inject()
  private userService: UserService  // Not supported!
}

// ✅ CORRECT
@inject()
export default class UsersController {
  constructor(protected userService: UserService) {}
}
```

## AI Self-Check

- [ ] Using `@inject()` on class?
- [ ] Constructor injection?
- [ ] Validating all input?
- [ ] Business logic in services?
- [ ] Path aliases used?
- [ ] Lucid ORM for database?
- [ ] Events for side effects?
- [ ] Using `env` service?
- [ ] ES6 imports?
- [ ] Async/await for async ops?

## Key Features

| Feature | Purpose |
|---------|---------|
| IoC Container | Dependency injection |
| Lucid ORM | Database ORM |
| VineJS | Validation |
| Events | Decoupled logic |
| Japa | Testing |

## Best Practices

**MUST**: IoC, constructor injection, VineJS, path aliases, Lucid
**SHOULD**: Services, events, middleware, Japa tests
**AVOID**: Field injection, skipping validation, business logic in controllers
