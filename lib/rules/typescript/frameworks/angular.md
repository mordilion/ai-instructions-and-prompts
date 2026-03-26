# Angular Framework

> **Scope**: Angular 14+ applications  
> **Applies to**: .ts files in Angular projects
> **Extends**: typescript/architecture.md, typescript/code-style.md

## CRITICAL REQUIREMENTS

> **ALWAYS**: Use standalone components (NOT NgModules)
> **ALWAYS**: Inject services via constructor
> **ALWAYS**: Use OnPush change detection
> **ALWAYS**: Use async pipe for observables
> **ALWAYS**: Unsubscribe in ngOnDestroy
> 
> **NEVER**: Use NgModules in new code
> **NEVER**: Subscribe without unsubscribing
> **NEVER**: Mutate inputs directly
> **NEVER**: Use `any` type
> **NEVER**: Put business logic in components

## Core Patterns

### Core Patterns

| Component | Pattern |
|-----------|---------|
| **Standalone** | `@Component({ standalone: true, imports: [...] })` + `@Input/@Output` + `OnPush` |
| **Service** | `@Injectable({ providedIn: 'root' })` + constructor DI + `Observable<T>` |
| **Observable** | `data$ = service.getData()` + `| async` pipe in template |
| **Signals** | `signal(value)` + `computed()` + `.update()/.set()` methods |

### Manual Subscription (with cleanup)

```typescript
export class UsersComponent implements OnDestroy {
  private destroy$ = new Subject<void>()
  
  ngOnInit() {
    this.userService.getAll()
      .pipe(takeUntil(this.destroy$))
      .subscribe(users => this.users = users)
  }
  
  ngOnDestroy() {
    this.destroy$.next()
    this.destroy$.complete()
  }
}
```

## Common AI Mistakes

| Mistake | ❌ Wrong | ✅ Correct |
|---------|---------|-----------|
| **NgModule** | `@NgModule({})` | `standalone: true` |
| **No Unsubscribe** | `subscribe()` without cleanup | `takeUntil()` or async pipe |
| **Default CD** | Default detection | `OnPush` |
| **Manual Subscribe** | Many subscriptions | async pipe |

## AI Self-Check

- [ ] Standalone components?
- [ ] Constructor injection?
- [ ] OnPush change detection?
- [ ] async pipe for observables?
- [ ] Unsubscribe handling?
- [ ] No NgModules?
- [ ] Strong typing (no any)?
- [ ] Business logic in services?
- [ ] Proper lifecycle hooks?

## Key Features

| Feature | Purpose |
|---------|---------|
| Standalone | No NgModules |
| Signals | Reactive state (16+) |
| OnPush | Performance |
| async Pipe | Auto unsubscribe |
| RxJS | Async operations |

## Best Practices

**MUST**: Standalone, OnPush, async pipe, constructor injection, strong typing
**SHOULD**: Signals (16+), RxJS operators, proper unsubscribe, services
**AVOID**: NgModules, manual subscriptions, default CD, any type, component logic
