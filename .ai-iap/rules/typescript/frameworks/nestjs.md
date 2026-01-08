# NestJS Framework

> **Scope**: NestJS applications
> **Applies to**: TypeScript files in NestJS projects
> **Extends**: typescript/architecture.md, typescript/code-style.md

## CRITICAL REQUIREMENTS

> **ALWAYS**: Use dependency injection (constructor)
> **ALWAYS**: Use DTOs with class-validator
> **ALWAYS**: Use Guards for auth/authorization
> **ALWAYS**: Use Interceptors for response transformation
> **ALWAYS**: Return exceptions via filters
> 
> **NEVER**: Use `new` for services (breaks DI)
> **NEVER**: Skip DTO validation
> **NEVER**: Put business logic in controllers
> **NEVER**: Use Express middleware for auth
> **NEVER**: Return inconsistent response shapes

## Core Patterns

```typescript
// Controller (Thin)
@Controller('users')
@UseGuards(JwtAuthGuard)
export class UserController {
  constructor(private readonly userService: UserService) {}
  
  @Post()
  create(@Body() dto: CreateUserDto) { return this.userService.create(dto) }
}

// Service (Business Logic)
@Injectable()
export class UserService {
  constructor(@InjectRepository(User) private repo: Repository<User>) {}
  
  async create(dto: CreateUserDto) {
    return this.repo.save(this.repo.create(dto));
  }
}

// DTO with Validation
export class CreateUserDto {
  @IsEmail() email: string
  @IsString() @MinLength(2) name: string
}

// Guard (Auth)
@Injectable()
export class JwtAuthGuard extends AuthGuard('jwt') {
  handleRequest(err: any, user: any) {
    if (err || !user) throw new UnauthorizedException();
    return user;
  }
}

// Interceptor
@Injectable()
export class TransformInterceptor implements NestInterceptor {
  intercept(context: ExecutionContext, next: CallHandler) {
    return next.handle().pipe(map(data => ({ data, timestamp: new Date() })));
  }
}

// Exception Filter
@Catch(HttpException)
export class HttpExceptionFilter implements ExceptionFilter {
  catch(exception: HttpException, host: ArgumentsHost) {
    host.switchToHttp().getResponse().status(exception.getStatus()).json({
      statusCode: exception.getStatus(),
      message: exception.message
    });
  }
}

// Module
@Module({
  imports: [TypeOrmModule.forFeature([User])],
  controllers: [UserController],
  providers: [UserService]
})
export class UserModule {}
```

## Common AI Mistakes

| Mistake | ❌ Wrong | ✅ Correct |
|---------|---------|-----------|
| **Manual Instantiation** | `new UserService()` | Constructor DI |
| **No Validation** | Plain objects | DTOs with class-validator |
| **Logic in Controller** | Business rules in controller | Move to service |
| **Middleware for Auth** | Express middleware | Guards |

### Anti-Pattern: No DI

```typescript
// ❌ WRONG
export class UserController {
  private userService = new UserService()  // Breaks DI!
}

// ✅ CORRECT
export class UserController {
  constructor(private readonly userService: UserService) {}
}
```

## AI Self-Check

- [ ] Constructor injection?
- [ ] DTOs with validation?
- [ ] Guards for auth?
- [ ] Interceptors for responses?
- [ ] Exception filters?
- [ ] Business logic in services?
- [ ] @Injectable() on services?
- [ ] Module imports/exports correct?
- [ ] No manual instantiation?
- [ ] Consistent response shapes?

## Key Decorators

| Decorator | Purpose |
|-----------|---------|
| `@Controller` | Define controller |
| `@Injectable` | Enable DI |
| `@UseGuards` | Apply guards |
| `@UseInterceptors` | Apply interceptors |
| `@Body/@Param/@Query` | Extract request data |

## Best Practices

**MUST**: DI, DTOs, Guards, Interceptors, Exception filters
**SHOULD**: ValidationPipe, TransformInterceptor, proper modules
**AVOID**: Manual instantiation, skipping validation, logic in controllers
