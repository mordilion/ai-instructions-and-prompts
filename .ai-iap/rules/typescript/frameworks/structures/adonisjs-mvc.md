# AdonisJS MVC/Traditional Structure

> **Scope**: AdonisJS apps organized by technical layer (MVC pattern)
> **Precedence**: Overrides default AdonisJS folder organization
> **Use When**: Small-medium apps (<10 entities), simple domain logic, traditional MVC preference

## CRITICAL REQUIREMENTS

> **ALWAYS**: Organize by technical layer (controllers/, models/, services/)
> **ALWAYS**: Use dependency injection with `@inject()`
> **ALWAYS**: Validate in controllers before service calls
> **ALWAYS**: Keep business logic in services (NOT controllers)
> **ALWAYS**: Use path aliases (`#controllers`, `#models`, etc.)
> 
> **NEVER**: Put business logic in controllers
> **NEVER**: Access models directly from controllers (use services)
> **NEVER**: Skip validation in controllers
> **NEVER**: Use relative imports (use path aliases)

## Project Structure

```
app/
├── controllers/       # HTTP request handlers
├── models/           # Lucid ORM models
├── services/         # Business logic
├── validators/       # VineJS validators
├── middleware/       # HTTP middleware
├── exceptions/       # Custom exceptions
├── events/          # Domain events
├── listeners/       # Event handlers
└── utils/           # Utilities
config/              # Configuration
database/            # Migrations, seeders, factories
start/               # App bootstrap (routes.ts, kernel.ts, events.ts)
tests/
├── unit/            # Service/validator tests
└── functional/      # API integration tests
```

## Layer Organization

```typescript
// Controller → Service → Model
@inject()
export default class UsersController {
  constructor(protected userService: UserService) {}
  
  async store({ request, response }: HttpContext) {
    const payload = await request.validateUsing(createUserValidator);
    return response.created(await this.userService.create(payload));
  }
}

// Service (Business Logic)
@inject()
export default class UserService {
  async create(data) {
    const user = await User.create({ ...data, password: await hash.make(data.password) });
    emitter.emit(new UserRegistered(user));
    return user;
  }
}

// Model
export default class User extends BaseModel {
  @column({ isPrimary: true }) declare id: number
  @column({ serializeAs: null }) declare password: string
  @hasMany(() => Post) declare posts: HasMany<typeof Post>
}

// Routes
router.group(() => {
  router.resource('users', () => import('#controllers/users_controller')).apiOnly();
}).prefix('/api/v1').middleware(middleware.auth());

// Events
export default class UserRegistered extends BaseEvent {
  constructor(public user: User) { super() }
}
emitter.on(UserRegistered, [SendWelcomeEmail]);
```

## Rules

| Rule | Why |
|------|-----|
| **Layer Separation** | Controllers → Services → Models |
| **Single Responsibility** | One class per file |
| **DI via Constructor** | Use `@inject()` decorator |
| **Validate Early** | In controllers, before service calls |
| **Business Logic in Services** | Keep controllers thin |
| **Events for Cross-Cutting** | Decouple side effects |

## When to Use

- ✅ Small to medium apps (<10 entities)
- ✅ Simple domain logic
- ✅ Single team
- ✅ Quick prototyping
- ✅ Traditional MVC preference
- ❌ Complex domain (use Modular structure)

## Testing

```typescript
// tests/functional/users.spec.ts
import { test } from '@japa/runner'

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
})
```

## Key Features

- **Flat Structure**: All controllers in one folder
- **Clear Layers**: Controllers, Services, Models
- **Path Aliases**: Clean imports with `#`
- **IoC Container**: Automatic dependency injection
- **Lucid ORM**: Active Record pattern
- **VineJS**: Schema-based validation
- **Events**: Decoupled side effects
