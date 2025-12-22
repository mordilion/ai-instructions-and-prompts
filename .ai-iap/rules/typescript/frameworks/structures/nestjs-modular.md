# NestJS Modular Structure

> Feature-based NestJS structure with separate modules per domain. Best for modular applications with clear bounded contexts.

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
