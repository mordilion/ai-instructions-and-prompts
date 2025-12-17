# NestJS Layered Structure

> **Scope**: Use this structure for smaller NestJS apps organized by technical layer.
> **Precedence**: When loaded, this structure overrides any default folder organization from the base NestJS rules.

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

