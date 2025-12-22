# NestJS Framework

> **Scope**: Apply these rules when working with NestJS backend applications.

## Overview

NestJS is a progressive Node.js framework for building efficient, scalable server-side applications. It uses TypeScript by default and is heavily inspired by Angular's architecture (modules, dependency injection, decorators).

**Key Capabilities**:
- **Dependency Injection**: Built-in IoC container
- **Modular Architecture**: Organize code into feature modules
- **TypeScript-First**: Full type safety across the stack
- **Decorator-Based**: Controllers, services, guards, interceptors
- **ORM Agnostic**: Works with Prisma, TypeORM, Mongoose

## Pattern Selection

### Controller vs Service Responsibility
**Controllers MUST**:
- Handle HTTP concerns (routing, status codes, headers)
- Validate input using DTOs
- Return Response DTOs (NOT entities)
- Stay thin (delegate to services)

**Services MUST**:
- Contain business logic
- Be ORM/DB agnostic (use repository pattern)
- Return domain objects
- Be testable in isolation

### Module Organization
**Use Feature Modules when**:
- Grouping related functionality (users, orders, products)
- Need encapsulation
- Want lazy loading

**Use Shared Module when**:
- Utilities used across features (logger, config)
- Need singleton services

**Use Core Module when**:
- App-wide services (auth, database)
- Guards, interceptors, filters

## 1. Module Structure
```
src/
├── modules/
│   └── users/
│       ├── users.module.ts
│       ├── users.controller.ts
│       ├── users.service.ts
│       ├── users.repository.ts
│       ├── dto/
│       │   ├── create-user.dto.ts
│       │   └── user-response.dto.ts
│       └── entities/
│           └── user.entity.ts
├── common/              # Shared utilities, decorators, filters
├── config/              # Configuration modules
└── app.module.ts
```

## 2. Controllers
- **Thin Controllers**: Validate input, delegate to services.
- **DTOs**: Use class-validator for input validation.
- **Response DTOs**: Never expose entities directly.

```typescript
// ✅ Good
@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Post()
  async create(@Body() dto: CreateUserDto): Promise<UserResponseDto> {
    return this.usersService.create(dto);
  }
}

// ❌ Bad - Logic in controller
@Post()
async create(@Body() dto: CreateUserDto) {
  const user = await this.prisma.user.create({ data: dto });  // DB in controller
  return user;  // Exposing entity
}
```

## 3. Services
- **Business Logic**: All business rules live here.
- **Repository Pattern**: Services call repositories, not Prisma/TypeORM directly.
- **Single Responsibility**: One service per domain concept.

## 4. Dependency Injection
- **Constructor Injection**: Standard pattern.
- **Providers**: Register in module's `providers` array.
- **Exports**: Export services for use in other modules.

```typescript
@Module({
  imports: [DatabaseModule],
  controllers: [UsersController],
  providers: [UsersService, UsersRepository],
  exports: [UsersService],
})
export class UsersModule {}
```

## 5. DTOs & Validation
- **class-validator**: Decorators for validation.
- **class-transformer**: For transformation (exclude fields, etc.).
- **Separate DTOs**: CreateDto, UpdateDto, ResponseDto.

```typescript
export class CreateUserDto {
  @IsString()
  @MinLength(2)
  name: string;

  @IsEmail()
  email: string;
}
```

## 6. Error Handling
- **Built-in Exceptions**: Use `NotFoundException`, `BadRequestException`, etc.
- **Custom Exceptions**: Extend `HttpException` for domain errors.
- **Exception Filters**: Global filters for consistent error responses.

```typescript
// ✅ Good
if (!user) {
  throw new NotFoundException(`User ${id} not found`);
}

// ❌ Bad
if (!user) {
  return { error: 'not found' };  // Inconsistent error handling
}
```

## 7. Guards & Interceptors
- **Guards**: For authentication/authorization.
- **Interceptors**: For logging, transformation, caching.
- **Pipes**: For validation and transformation.

```typescript
@UseGuards(JwtAuthGuard)
@Controller('users')
export class UsersController { ... }
```

## Best Practices

**MUST**:
- Use constructor injection (NO property injection)
- Return Response DTOs from controllers (NEVER entities)
- Use class-validator for ALL input validation
- Use repository pattern (NO direct Prisma/TypeORM in services)
- Use built-in exception classes (NotFoundException, etc.)

**SHOULD**:
- Use `providedIn: 'root'` for singleton services
- Use guards for authentication/authorization
- Use interceptors for logging/transformation
- Use pipes for validation
- Export services from modules when needed in other modules

**AVOID**:
- Logic in controllers (delegate to services)
- Exposing database entities in API responses
- Generic error messages (be specific)
- Tight coupling to ORM (use repository abstraction)
- Global state (use DI instead)

## Common Patterns

### Repository Pattern
```typescript
// ✅ GOOD: Repository abstracts database
// users.repository.ts
@Injectable()
export class UsersRepository {
  constructor(private prisma: PrismaService) {}

  async findById(id: string): Promise<User | null> {
    return this.prisma.user.findUnique({ where: { id } });
  }

  async create(data: CreateUserData): Promise<User> {
    return this.prisma.user.create({ data });
  }
}

// users.service.ts
@Injectable()
export class UsersService {
  constructor(
    private repo: UsersRepository,  // Depends on abstraction
  ) {}

  async getUser(id: string): Promise<UserResponseDto> {
    const user = await this.repo.findById(id);
    if (!user) {
      throw new NotFoundException(`User ${id} not found`);
    }
    return this.toDto(user);  // Map entity to DTO
  }
}

// ❌ BAD: Service directly uses Prisma
@Injectable()
export class UsersService {
  constructor(private prisma: PrismaService) {}  // Tight coupling

  async getUser(id: string) {
    return this.prisma.user.findUnique({ where: { id } });  // Returns entity
  }
}
```

### DTO Pattern
```typescript
// ✅ GOOD: Separate DTOs for input and output
// create-user.dto.ts
export class CreateUserDto {
  @IsString()
  @MinLength(2)
  @MaxLength(50)
  name: string;

  @IsEmail()
  email: string;

  @IsOptional()
  @IsString()
  bio?: string;
}

// user-response.dto.ts
export class UserResponseDto {
  id: string;
  name: string;
  email: string;
  createdAt: Date;
  // NO password, internal fields, etc.
}

// users.controller.ts
@Controller('users')
export class UsersController {
  @Post()
  async create(@Body() dto: CreateUserDto): Promise<UserResponseDto> {
    return this.usersService.create(dto);  // Type-safe, validated
  }
}

// ❌ BAD: Exposing entity directly
@Post()
async create(@Body() dto: any) {  // No validation
  return this.prisma.user.create({ data: dto });  // Exposes all fields
}
```

### Transaction Pattern
```typescript
// ✅ GOOD: Transaction with rollback
@Injectable()
export class OrdersService {
  constructor(private prisma: PrismaService) {}

  async createOrder(userId: string, items: OrderItem[]) {
    return this.prisma.$transaction(async (tx) => {
      // All or nothing
      const order = await tx.order.create({
        data: { userId, total: calculateTotal(items) },
      });

      await tx.orderItem.createMany({
        data: items.map(item => ({
          orderId: order.id,
          productId: item.productId,
          quantity: item.quantity,
        })),
      });

      // Update inventory
      for (const item of items) {
        await tx.product.update({
          where: { id: item.productId },
          data: { stock: { decrement: item.quantity } },
        });
      }

      return order;
    });  // Auto-rollback on error
  }
}

// ❌ BAD: No transaction (partial state possible)
async createOrder(userId: string, items: OrderItem[]) {
  const order = await this.prisma.order.create(...);
  await this.prisma.orderItem.createMany(...);  // If this fails, order exists!
  await this.prisma.product.update(...);  // Inconsistent state
}
```

### Guard Pattern
```typescript
// ✅ GOOD: Reusable authentication guard
// auth.guard.ts
@Injectable()
export class JwtAuthGuard extends AuthGuard('jwt') {
  handleRequest(err, user, info) {
    if (err || !user) {
      throw new UnauthorizedException('Invalid or expired token');
    }
    return user;
  }
}

// Usage
@Controller('users')
@UseGuards(JwtAuthGuard)  // Applied to all routes
export class UsersController {
  @Get('me')
  getMe(@Request() req) {
    return req.user;  // Populated by guard
  }

  @Public()  // Custom decorator to skip guard
  @Get('public')
  getPublic() {
    return { message: 'Public endpoint' };
  }
}

// ❌ BAD: Manual token validation in each route
@Get('me')
async getMe(@Headers('authorization') auth: string) {
  const token = auth?.replace('Bearer ', '');
  if (!token) throw new UnauthorizedException();
  const user = await this.authService.validateToken(token);  // Repeated
  return user;
}
```

## Common Anti-Patterns

**❌ Property injection (unreliable)**:
```typescript
// BAD
@Injectable()
export class UsersService {
  @Inject(UsersRepository)
  private repo: UsersRepository;  // Can be undefined
}
```

**✅ Use constructor injection**:
```typescript
// GOOD
@Injectable()
export class UsersService {
  constructor(private readonly repo: UsersRepository) {}  // Always available
}
```

**❌ Generic error responses**:
```typescript
// BAD
throw new HttpException('Error', 400);  // Not helpful
```

**✅ Specific exceptions with context**:
```typescript
// GOOD
throw new NotFoundException(`User with ID ${id} not found`);
throw new BadRequestException('Email already exists');
```

## 8. Database (Prisma/TypeORM)
- **Repository Layer**: Abstract database access
- **Transactions**: Use `$transaction` (Prisma) or QueryRunner (TypeORM)
- **Migrations**: Version-controlled schema changes

