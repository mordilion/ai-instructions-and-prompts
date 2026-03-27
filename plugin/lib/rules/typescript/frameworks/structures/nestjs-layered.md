# NestJS Layered Structure

> **Scope**: Layered structure for NestJS  
> **Applies to**: NestJS projects with layered structure  
> **Extends**: typescript/frameworks/nestjs.md

## CRITICAL REQUIREMENTS

> **ALWAYS**: Controllers in controllers/ folder
> **ALWAYS**: Services in services/ folder
> **ALWAYS**: Entities in entities/ folder
> **ALWAYS**: DTOs in dto/ folder
> **ALWAYS**: Controllers thin (delegate to services)
> 
> **NEVER**: Business logic in controllers
> **NEVER**: Controllers call repositories directly
> **NEVER**: Return entities from controllers
> **NEVER**: Fat controllers
> **NEVER**: Skip DTO validation

## Project Structure
```
src/
├── controllers/            # All HTTP controllers
│   ├── auth.controller.ts
│   ├── users.controller.ts
│   └── orders.controller.ts
├── services/               # Business logic
│   ├── auth.service.ts
│   ├── users.service.ts
│   └── orders.service.ts
├── repositories/           # Data access
│   ├── users.repository.ts
│   └── orders.repository.ts
├── entities/               # Database entities
│   ├── user.entity.ts
│   └── order.entity.ts
├── dto/                    # Data transfer objects
│   ├── create-user.dto.ts
│   └── update-user.dto.ts
├── guards/
├── pipes/
├── filters/
├── config/
├── app.module.ts
└── main.ts
```

## Single App Module
```typescript
@Module({
  imports: [TypeOrmModule.forFeature([User, Order]), ConfigModule],
  controllers: [AuthController, UsersController, OrdersController],
  providers: [AuthService, UsersService, OrdersService, UsersRepository],
})
export class AppModule {}
```

## Rules
- **Flat Structure**: Easy to navigate
- **Layer Dependencies**: Controller → Service → Repository
- **Single Module**: All in AppModule

## When to Use
- Small APIs (< 10 endpoints)
- Prototypes and MVPs
- Learning NestJS

## AI Self-Check

- [ ] Controllers in controllers/ folder?
- [ ] Services in services/ folder?
- [ ] Entities in entities/ folder?
- [ ] DTOs in dto/ folder?
- [ ] Controllers thin?
- [ ] Services handle business logic?
- [ ] DTO validation present?
- [ ] No business logic in controllers?
- [ ] No controllers calling repositories directly?
- [ ] No entities returned from controllers?

