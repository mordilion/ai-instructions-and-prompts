# NestJS Framework

> **Scope**: Apply these rules when working with NestJS backend applications.

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

## 8. Database (Prisma/TypeORM)
- **Repository Layer**: Abstract database access.
- **Transactions**: Use `$transaction` (Prisma) or QueryRunner (TypeORM).
- **Migrations**: Version-controlled schema changes.

