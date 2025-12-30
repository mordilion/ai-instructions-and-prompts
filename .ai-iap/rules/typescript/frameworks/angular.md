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

### Standalone Component

```typescript
@Component({
  selector: 'app-user-card',
  standalone: true,
  imports: [CommonModule],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <div class="card">
      <h3>{{ user.name }}</h3>
      <button (click)="onDelete()">Delete</button>
    </div>
  `
})
export class UserCardComponent {
  @Input() user!: User
  @Output() delete = new EventEmitter<number>()
  
  onDelete() {
    this.delete.emit(this.user.id)
  }
}
```

### Service

```typescript
@Injectable({ providedIn: 'root' })
export class UserService {
  private apiUrl = 'https://api.example.com/users'
  
  constructor(private http: HttpClient) {}
  
  getAll(): Observable<User[]> {
    return this.http.get<User[]>(this.apiUrl)
  }
  
  create(user: CreateUserDto): Observable<User> {
    return this.http.post<User>(this.apiUrl, user)
  }
}
```

### Component with Observable

```typescript
@Component({
  selector: 'app-users',
  standalone: true,
  imports: [CommonModule, UserCardComponent],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <div *ngIf="users$ | async as users">
      <app-user-card 
        *ngFor="let user of users" 
        [user]="user"
        (delete)="onDelete($event)"
      />
    </div>
  `
})
export class UsersComponent {
  users$ = this.userService.getAll()
  
  constructor(private userService: UserService) {}
  
  onDelete(id: number) {
    this.userService.delete(id).subscribe()
  }
}
```

### Component with Signals (Angular 16+)

```typescript
@Component({
  selector: 'app-counter',
  standalone: true,
  template: `
    <button (click)="increment()">{{ count() }}</button>
    <p>Double: {{ doubleCount() }}</p>
  `
})
export class CounterComponent {
  count = signal(0)
  doubleCount = computed(() => this.count() * 2)
  
  increment() {
    this.count.update(c => c + 1)
  }
}
```

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
