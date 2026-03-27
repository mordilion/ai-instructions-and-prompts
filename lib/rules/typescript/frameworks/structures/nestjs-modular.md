# NestJS Modular Structure

> **Scope**: Modular structure for NestJS  
> **Applies to**: NestJS projects with modular structure  
> **Extends**: typescript/frameworks/nestjs.md

## CRITICAL REQUIREMENTS

> **ALWAYS**: Module per feature (user.module.ts)
> **ALWAYS**: Co-locate feature files (controller, service, dto, entities)
> **ALWAYS**: Import dependencies in module
> **ALWAYS**: Export services for other modules
> **ALWAYS**: Features independent
> 
> **NEVER**: Cross-module dependencies (use shared module)
> **NEVER**: Split feature across locations
> **NEVER**: Generic services folder
> **NEVER**: Share state between modules directly
> **NEVER**: Deep folder nesting

## Directory Structure

```
src/user/
├── user.controller.ts
├── user.service.ts
├── user.module.ts
├── dto/
│   ├── create-user.dto.ts
│   └── user.dto.ts
└── entities/
    └── user.entity.ts
```

## Implementation

```typescript
// entities/user.entity.ts
@Entity()
export class User {
  @PrimaryGeneratedColumn()
  id: number;
  
  @Column()
  name: string;
}

// user.service.ts
@Injectable()
export class UserService {
  constructor(
    @InjectRepository(User)
    private repo: Repository<User>,
  ) {}
  
  async findAll(): Promise<User[]> {
    return this.repo.find();
  }
}

// user.controller.ts
@Controller('users')
export class UserController {
  constructor(private service: UserService) {}
  
  @Get()
  findAll() {
    return this.service.findAll();
  }
}

// user.module.ts
@Module({
  imports: [TypeOrmModule.forFeature([User])],
  controllers: [UserController],
  providers: [UserService],
})
export class UserModule {}
```

## When to Use
- Modular NestJS apps
- Feature-based development

## AI Self-Check

- [ ] Module per feature?
- [ ] Feature files co-located?
- [ ] Dependencies imported in module?
- [ ] Services exported for other modules?
- [ ] Features independent?
- [ ] No cross-module dependencies (using shared)?
- [ ] No split features?
- [ ] No generic services folder?
- [ ] Module properly configured?
- [ ] Feature self-contained?
