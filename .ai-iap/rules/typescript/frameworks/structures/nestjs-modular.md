# NestJS Modular Structure

> **Scope**: Use this structure for NestJS apps with domain-driven modules.
> **Precedence**: When loaded, this structure overrides any default folder organization from the base NestJS rules.

## Project Structure
```
src/
├── common/                 # Shared utilities
│   ├── decorators/
│   ├── filters/
│   ├── guards/
│   ├── interceptors/
│   └── pipes/
├── config/                 # Configuration
│   └── database.config.ts
├── modules/                # Feature modules
│   ├── auth/
│   │   ├── dto/
│   │   ├── entities/
│   │   ├── guards/
│   │   ├── strategies/
│   │   ├── auth.controller.ts
│   │   ├── auth.service.ts
│   │   └── auth.module.ts
│   ├── users/
│   │   ├── dto/
│   │   ├── entities/
│   │   ├── users.controller.ts
│   │   ├── users.service.ts
│   │   ├── users.repository.ts
│   │   └── users.module.ts
│   └── orders/
├── database/               # Database config, migrations
│   └── migrations/
├── app.module.ts
└── main.ts
```

## Module Structure
```typescript
@Module({
  imports: [TypeOrmModule.forFeature([User])],
  controllers: [UsersController],
  providers: [UsersService, UsersRepository],
  exports: [UsersService],  // Only export what other modules need
})
export class UsersModule {}
```

## Rules
- **One Module Per Domain**: auth, users, orders, etc.
- **Module Exports**: Only export services needed by other modules
- **Common Module**: Shared guards, filters, pipes
- **No Circular Dependencies**: Use forwardRef() if unavoidable

## When to Use
- Medium to large APIs
- Domain-driven design
- Microservice preparation

