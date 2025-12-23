# AdonisJS MVC/Traditional Structure

> **Scope**: Use this structure for AdonisJS apps organized by technical layer (MVC pattern).
> **Precedence**: When loaded, this structure overrides any default folder organization from the base AdonisJS rules.

## Project Structure

```
app/
├── controllers/               # All HTTP controllers
│   ├── http/
│   │   ├── users_controller.ts
│   │   ├── posts_controller.ts
│   │   └── auth_controller.ts
│   └── api/                  # Optional: API-specific controllers
│       ├── v1/
│       └── v2/
├── models/                   # All Lucid ORM models
│   ├── user.ts
│   ├── post.ts
│   └── comment.ts
├── services/                 # Business logic services
│   ├── user_service.ts
│   ├── post_service.ts
│   └── email_service.ts
├── validators/               # Request validators
│   ├── user_validator.ts
│   ├── post_validator.ts
│   └── auth_validator.ts
├── middleware/               # HTTP middleware
│   ├── auth.ts
│   ├── admin.ts
│   └── rate_limiter.ts
├── exceptions/               # Custom exceptions
│   ├── business_exception.ts
│   └── not_found_exception.ts
├── events/                   # Domain events
│   ├── user_registered.ts
│   └── post_created.ts
├── listeners/                # Event listeners
│   ├── send_welcome_email.ts
│   └── notify_followers.ts
└── utils/                    # Utility functions
    ├── helpers.ts
    └── constants.ts
config/                       # Configuration files
├── app.ts
├── database.ts
├── auth.ts
└── mail.ts
database/
├── migrations/               # Database migrations
│   └── 1234567890_create_users_table.ts
├── seeders/                 # Database seeders
│   └── user_seeder.ts
└── factories/               # Model factories
    └── user_factory.ts
start/
├── kernel.ts                # HTTP kernel - middleware registration
├── routes.ts                # All route definitions
├── events.ts                # Event listener bindings
└── env.ts                   # Environment validation
resources/
└── views/                   # Edge templates (if using SSR)
    └── emails/
        └── welcome.edge
tests/
├── unit/                    # Unit tests
│   ├── services/
│   │   └── user_service.spec.ts
│   └── validators/
│       └── user_validator.spec.ts
└── functional/              # Integration tests
    ├── users.spec.ts
    └── posts.spec.ts
```

## Layer Organization

### Controllers Layer

All controllers in `app/controllers/`:

```typescript
// app/controllers/users_controller.ts
import { HttpContext } from '@adonisjs/core/http'
import { inject } from '@adonisjs/core'
import UserService from '#services/user_service'
import { createUserValidator, updateUserValidator } from '#validators/user_validator'

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

### Models Layer

All models in `app/models/`:

```typescript
// app/models/user.ts
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

### Services Layer

All services in `app/services/`:

```typescript
// app/services/user_service.ts
import { inject } from '@adonisjs/core'
import User from '#models/user'
import hash from '@adonisjs/core/services/hash'
import emitter from '@adonisjs/core/services/emitter'
import UserRegistered from '#events/user_registered'
import EmailService from '#services/email_service'

@inject()
export default class UserService {
  constructor(protected emailService: EmailService) {}

  async create(data: { email: string; password: string; fullName: string }) {
    const hashedPassword = await hash.make(data.password)
    
    const user = await User.create({
      ...data,
      password: hashedPassword,
    })

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

### Validators Layer

All validators in `app/validators/`:

```typescript
// app/validators/user_validator.ts
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

export const loginValidator = vine.compile(
  vine.object({
    email: vine.string().email(),
    password: vine.string(),
  })
)
```

## Routes

All routes in `start/routes.ts`:

```typescript
// start/routes.ts
import router from '@adonisjs/core/services/router'
import { middleware } from '#start/kernel'

// Controllers
const UsersController = () => import('#controllers/users_controller')
const PostsController = () => import('#controllers/posts_controller')
const AuthController = () => import('#controllers/auth_controller')
const CommentsController = () => import('#controllers/comments_controller')

// Health check
router.get('/health', () => ({ status: 'ok' }))

// Auth routes (public)
router.group(() => {
  router.post('login', [AuthController, 'login'])
  router.post('register', [AuthController, 'register'])
  router.post('logout', [AuthController, 'logout']).use(middleware.auth())
}).prefix('/api/v1/auth')

// Protected API routes
router.group(() => {
  // Users
  router.resource('users', UsersController).apiOnly()
  router.post('users/:id/follow', [UsersController, 'follow'])
  
  // Posts
  router.resource('posts', PostsController).apiOnly()
  router.post('posts/:id/like', [PostsController, 'like'])
  
  // Comments
  router.resource('posts.comments', CommentsController).apiOnly()
}).prefix('/api/v1').middleware(middleware.auth())

// Admin routes
router.group(() => {
  router.get('dashboard', [AdminController, 'dashboard'])
  router.resource('admin/users', AdminUsersController).apiOnly()
}).prefix('/api/v1').middleware([middleware.auth(), middleware.admin()])
```

## Events & Listeners

**Events** in `app/events/`:

```typescript
// app/events/user_registered.ts
import { BaseEvent } from '@adonisjs/core/events'
import User from '#models/user'

export default class UserRegistered extends BaseEvent {
  constructor(public user: User) {
    super()
  }
}
```

**Listeners** in `app/listeners/`:

```typescript
// app/listeners/send_welcome_email.ts
import { inject } from '@adonisjs/core'
import UserRegistered from '#events/user_registered'
import EmailService from '#services/email_service'

@inject()
export default class SendWelcomeEmail {
  constructor(protected emailService: EmailService) {}

  async handle(event: UserRegistered) {
    await this.emailService.sendWelcome(
      event.user.email,
      event.user.fullName
    )
  }
}
```

**Bind in** `start/events.ts`:

```typescript
// start/events.ts
import emitter from '@adonisjs/core/services/emitter'
import UserRegistered from '#events/user_registered'
import SendWelcomeEmail from '#listeners/send_welcome_email'

emitter.on(UserRegistered, [SendWelcomeEmail])
```

## Middleware

All middleware in `app/middleware/`:

```typescript
// app/middleware/admin.ts
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

## Path Aliases

Configure in `tsconfig.json`:

```json
{
  "compilerOptions": {
    "paths": {
      "#controllers/*": ["./app/controllers/*"],
      "#models/*": ["./app/models/*"],
      "#services/*": ["./app/services/*"],
      "#validators/*": ["./app/validators/*"],
      "#middleware/*": ["./app/middleware/*"],
      "#events/*": ["./app/events/*"],
      "#listeners/*": ["./app/listeners/*"],
      "#exceptions/*": ["./app/exceptions/*"],
      "#utils/*": ["./app/utils/*"],
      "#config/*": ["./config/*"],
      "#start/*": ["./start/*"]
    }
  }
}
```

## Rules

- **Layer Separation**: Controllers → Services → Models
- **Single Responsibility**: Each file has one class/export
- **Dependency Injection**: Use constructor injection with `@inject()`
- **Validation**: Always validate in controllers before service calls
- **Business Logic**: Keep in services, not controllers
- **Events**: Use for cross-cutting concerns
- **Path Aliases**: Use `#` imports for clean paths

## When to Use

- Small to medium applications (< 10 domain entities)
- Simple domain logic
- Single team
- Quick prototyping
- Prefer traditional MVC structure
- Clear layer separation

## Testing

Tests mirror the flat structure:

```
tests/
├── unit/
│   ├── services/
│   │   ├── user_service.spec.ts
│   │   └── post_service.spec.ts
│   └── validators/
│       └── user_validator.spec.ts
└── functional/
    ├── users.spec.ts
    ├── posts.spec.ts
    └── auth.spec.ts
```

Example test:

```typescript
// tests/functional/users.spec.ts
import { test } from '@japa/runner'
import UserFactory from '#database/factories/user_factory'

test.group('Users API', () => {
  test('can list users', async ({ client }) => {
    await UserFactory.createMany(5)
    
    const response = await client.get('/api/v1/users')
    
    response.assertStatus(200)
    response.assertBody([])
  })

  test('can create user', async ({ client }) => {
    const userData = {
      email: 'test@example.com',
      password: 'password123',
      fullName: 'Test User',
    }

    const response = await client.post('/api/v1/users').json(userData)
    
    response.assertStatus(201)
    response.assertBodyContains({ email: userData.email })
  })
})
```

