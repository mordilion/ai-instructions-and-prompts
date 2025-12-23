# AdonisJS Framework Rules

> **Scope**: Full-stack MVC framework for Node.js with TypeScript-first approach
> **Version**: AdonisJS 6.x
> **Precedence**: These rules apply when using AdonisJS. They extend TypeScript code-style and architecture rules.

## CRITICAL REQUIREMENTS

> **ALWAYS**: Use AdonisJS IoC Container for dependency injection
> **ALWAYS**: Use async/await for all asynchronous operations
> **ALWAYS**: Validate requests using AdonisJS Validators
> **NEVER**: Use `require()` - always use ES6 imports
> **NEVER**: Access `process.env` directly - use `env` service

## Project Structure

```
app/
├── controllers/          # HTTP Controllers
├── models/              # Lucid ORM Models
├── services/            # Business logic services
├── validators/          # Request validators
├── middleware/          # HTTP middleware
├── exceptions/          # Custom exceptions
└── events/             # Event listeners
config/                 # Configuration files
database/
├── migrations/         # Database migrations
├── seeders/           # Database seeders
└── factories/         # Model factories
start/
├── kernel.ts          # HTTP kernel
├── routes.ts          # Route definitions
└── events.ts          # Event bindings
tests/                 # Japa tests
```

## Controllers

### Pattern

> **ALWAYS**: Use constructor injection for dependencies
> **ALWAYS**: Return responses using `response` object
> **ALWAYS**: Validate input with validators

```typescript
// ✅ CORRECT
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

### Common AI Mistakes

❌ **WRONG** - Field injection:
```typescript
export default class UsersController {
  @inject()
  private userService: UserService  // ❌ Don't use field injection
}
```

❌ **WRONG** - No validation:
```typescript
async store({ request }: HttpContext) {
  const data = request.body()  // ❌ No validation!
  await User.create(data)
}
```

## Models (Lucid ORM)

### Pattern

> **ALWAYS**: Extend `BaseModel`
> **ALWAYS**: Use `@column` decorator for database columns
> **ALWAYS**: Define relationships using decorators

```typescript
// ✅ CORRECT
import { DateTime } from 'luxon'
import { BaseModel, column, hasMany } from '@adonisjs/lucid/orm'
import type { HasMany } from '@adonisjs/lucid/types/relations'
import Post from './post.js'

export default class User extends BaseModel {
  @column({ isPrimary: true })
  declare id: number

  @column()
  declare email: string

  @column()
  declare fullName: string

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

### Common AI Mistakes

❌ **WRONG** - Not using decorators:
```typescript
export default class User extends BaseModel {
  id: number  // ❌ Missing @column decorator
  email: string  // ❌ Missing @column decorator
}
```

❌ **WRONG** - Exposing sensitive data:
```typescript
@column()
declare password: string  // ❌ Should use serializeAs: null
```

## Validators

### Pattern

> **ALWAYS**: Use VineJS schema validators
> **ALWAYS**: Create separate validator files
> **ALWAYS**: Define explicit rules for all fields

```typescript
// ✅ CORRECT - validators/user.ts
import vine from '@vinejs/vine'

export const createUserValidator = vine.compile(
  vine.object({
    email: vine.string().email().normalizeEmail(),
    password: vine.string().minLength(8).maxLength(32),
    fullName: vine.string().minLength(3).maxLength(100),
  })
)

export const updateUserValidator = vine.compile(
  vine.object({
    email: vine.string().email().normalizeEmail().optional(),
    fullName: vine.string().minLength(3).maxLength(100).optional(),
  })
)
```

### Common AI Mistakes

❌ **WRONG** - Inline validation:
```typescript
async store({ request }: HttpContext) {
  // ❌ Don't validate inline
  const data = await request.validate({
    schema: schema.create({ email: schema.string() })
  })
}
```

## Services

### Pattern

> **ALWAYS**: Use `@inject()` decorator for dependencies
> **ALWAYS**: Keep business logic in services, not controllers
> **ALWAYS**: Return domain objects, not HTTP responses

```typescript
// ✅ CORRECT - services/user_service.ts
import { inject } from '@adonisjs/core'
import User from '#models/user'
import hash from '@adonisjs/core/services/hash'

@inject()
export default class UserService {
  async create(data: { email: string; password: string; fullName: string }) {
    const hashedPassword = await hash.make(data.password)
    
    return User.create({
      ...data,
      password: hashedPassword,
    })
  }

  async getAll() {
    return User.query().orderBy('createdAt', 'desc')
  }

  async findById(id: number) {
    return User.findOrFail(id)
  }

  async update(id: number, data: Partial<User>) {
    const user = await this.findById(id)
    return user.merge(data).save()
  }
}
```

## Routes

### Pattern

> **ALWAYS**: Group related routes
> **ALWAYS**: Use route resource for RESTful routes
> **ALWAYS**: Apply middleware at route level

```typescript
// ✅ CORRECT - start/routes.ts
import router from '@adonisjs/core/services/router'
import { middleware } from '#start/kernel'

const UsersController = () => import('#controllers/users_controller')
const PostsController = () => import('#controllers/posts_controller')

// API routes
router.group(() => {
  // Resource routes
  router.resource('users', UsersController).apiOnly()
  router.resource('posts', PostsController).apiOnly()
  
  // Custom routes
  router.post('users/:id/follow', [UsersController, 'follow'])
}).prefix('/api/v1').middleware(middleware.auth())

// Public routes
router.group(() => {
  router.post('login', [AuthController, 'login'])
  router.post('register', [AuthController, 'register'])
}).prefix('/api/v1')
```

## Middleware

### Pattern

> **ALWAYS**: Extend from base middleware types
> **ALWAYS**: Call `next()` to continue request
> **ALWAYS**: Use `HttpContext` for type safety

```typescript
// ✅ CORRECT - middleware/admin_middleware.ts
import { HttpContext } from '@adonisjs/core/http'
import { NextFn } from '@adonisjs/core/types/http'

export default class AdminMiddleware {
  async handle({ auth, response }: HttpContext, next: NextFn) {
    const user = auth.user
    
    if (!user || user.role !== 'admin') {
      return response.forbidden({ message: 'Access denied' })
    }

    await next()
  }
}
```

## Exception Handling

### Pattern

> **ALWAYS**: Extend `Exception` class for custom exceptions
> **ALWAYS**: Provide `status` and `message`
> **ALWAYS**: Handle exceptions in global exception handler

```typescript
// ✅ CORRECT - exceptions/business_exception.ts
import { Exception } from '@adonisjs/core/exceptions'
import { HttpContext } from '@adonisjs/core/http'

export default class BusinessException extends Exception {
  static status = 422
  static code = 'BUSINESS_ERROR'

  async handle(error: this, ctx: HttpContext) {
    ctx.response.status(error.status).send({
      errors: [{
        message: error.message,
        code: error.code,
      }],
    })
  }
}
```

## Testing (Japa)

### Pattern

> **ALWAYS**: Use Japa test runner
> **ALWAYS**: Use factories for test data
> **ALWAYS**: Clean up after tests

```typescript
// ✅ CORRECT
import { test } from '@japa/runner'
import UserFactory from '#database/factories/user_factory'

test.group('Users API', (group) => {
  group.each.setup(async () => {
    // Setup code
  })

  group.each.teardown(async () => {
    // Cleanup code
  })

  test('can create a user', async ({ client }) => {
    const userData = {
      email: 'test@example.com',
      password: 'password',
      fullName: 'Test User',
    }

    const response = await client.post('/api/v1/users').json(userData)
    
    response.assertStatus(201)
    response.assertBodyContains({
      email: userData.email,
      fullName: userData.fullName,
    })
  })

  test('can list users', async ({ client }) => {
    await UserFactory.createMany(5)
    
    const response = await client.get('/api/v1/users')
    
    response.assertStatus(200)
    response.assertBodyContains([])
  })
})
```

## Configuration

### Pattern

> **ALWAYS**: Use `env` service for environment variables
> **ALWAYS**: Validate env variables in config files
> **NEVER**: Access `process.env` directly

```typescript
// ✅ CORRECT - config/database.ts
import env from '#start/env'
import { defineConfig } from '@adonisjs/lucid'

export default defineConfig({
  connection: env.get('DB_CONNECTION'),
  connections: {
    postgres: {
      client: 'pg',
      connection: {
        host: env.get('DB_HOST'),
        port: env.get('DB_PORT'),
        user: env.get('DB_USER'),
        password: env.get('DB_PASSWORD'),
        database: env.get('DB_DATABASE'),
      },
    },
  },
})
```

## Events

### Pattern

> **ALWAYS**: Define events as classes
> **ALWAYS**: Use event listeners for side effects
> **ALWAYS**: Keep listeners focused on single responsibility

```typescript
// ✅ CORRECT - events/user_registered.ts
import { BaseEvent } from '@adonisjs/core/events'
import User from '#models/user'

export default class UserRegistered extends BaseEvent {
  constructor(public user: User) {
    super()
  }
}

// Listener - listeners/send_welcome_email.ts
import UserRegistered from '#events/user_registered'
import mail from '@adonisjs/mail/services/main'

export default class SendWelcomeEmail {
  async handle(event: UserRegistered) {
    await mail.send((message) => {
      message
        .to(event.user.email)
        .subject('Welcome!')
        .htmlView('emails/welcome', { user: event.user })
    })
  }
}
```

## AI Self-Check

Before generating AdonisJS code, verify:
- [ ] Using constructor injection with `@inject()` decorator?
- [ ] Validating all requests with VineJS validators?
- [ ] Using `@column` decorators on all model properties?
- [ ] Hiding sensitive fields with `serializeAs: null`?
- [ ] Keeping business logic in services, not controllers?
- [ ] Using `env` service instead of `process.env`?
- [ ] Returning appropriate HTTP responses?
- [ ] Using async/await for all async operations?

