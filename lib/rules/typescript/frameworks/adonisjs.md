# AdonisJS Framework

> **Scope**: Full-stack MVC framework for Node.js (TypeScript-first)
> **Version**: AdonisJS 6.x
> **Applies to**: TypeScript files using AdonisJS
> **Extends**: typescript/architecture.md, typescript/code-style.md

## CRITICAL REQUIREMENTS

> **ALWAYS**: Use IoC Container with `@inject()`
> **ALWAYS**: Use async/await for async operations
> **ALWAYS**: Validate with VineJS validators
> **ALWAYS**: Use path aliases (`#controllers`, etc.)
> **ALWAYS**: Use Lucid ORM for database
> 
> **NEVER**: Use `require()` (use ES6 imports)
> **NEVER**: Access `process.env` directly (use `env`)
> **NEVER**: Skip validation
> **NEVER**: Put business logic in controllers
> **NEVER**: Use field injection

## Core Patterns

| Component | Pattern |
|-----------|---------|
| **Controller** | `@inject()` + constructor DI + `request.validateUsing()` + service calls |
| **Model** | `extends BaseModel` + `@column()` + `@hasMany()/@belongsTo()` decorators |
| **Validator** | VineJS schemas: `vine.compile(vine.object({ field: vine.string() }))`

| **Service** | `@inject()` + business logic + model/repository calls |
| **Routes** | `router.group()` + `.prefix()` + `.middleware()` + `resource()` |
| **Events** | `extends BaseEvent` + `emitter.on(Event, [Listener])`

## Common AI Mistakes

| Mistake | ❌ Wrong | ✅ Correct |
|---------|---------|-----------|
| **Field Injection** | `@inject() private service` | Constructor injection |
| **No Validation** | `request.body()` | `validateUsing()` |
| **Business Logic** | In controller | In service |
| **process.env** | Direct access | `env` service |

### Anti-Pattern: Field Injection

```typescript
// ❌ WRONG
export default class UsersController {
  @inject()
  private userService: UserService  // Not supported!
}

// ✅ CORRECT
@inject()
export default class UsersController {
  constructor(protected userService: UserService) {}
}
```

## AI Self-Check

- [ ] Using `@inject()` on class?
- [ ] Constructor injection?
- [ ] Validating all input?
- [ ] Business logic in services?
- [ ] Path aliases used?
- [ ] Lucid ORM for database?
- [ ] Events for side effects?
- [ ] Using `env` service?
- [ ] ES6 imports?
- [ ] Async/await for async ops?

## Key Features

| Feature | Purpose |
|---------|---------|
| IoC Container | Dependency injection |
| Lucid ORM | Database ORM |
| VineJS | Validation |
| Events | Decoupled logic |
| Japa | Testing |

## Best Practices

**MUST**: IoC, constructor injection, VineJS, path aliases, Lucid
**SHOULD**: Services, events, middleware, Japa tests
**AVOID**: Field injection, skipping validation, business logic in controllers
