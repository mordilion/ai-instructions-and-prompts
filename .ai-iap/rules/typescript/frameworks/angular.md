# Angular Framework

> **Scope**: Apply these rules when working with Angular applications.

## Overview

Angular is a comprehensive TypeScript-based framework for building web applications. It provides a complete solution including routing, forms, HTTP client, and dependency injection out of the box.

**Key Capabilities**:
- **Full Framework**: Everything included (routing, forms, HTTP, testing)
- **TypeScript-First**: Strong typing throughout
- **Dependency Injection**: Built-in IoC container
- **RxJS Integration**: Reactive programming with Observables
- **Standalone Components**: Simplified architecture (Angular 14+)

## Pattern Selection

### Component Strategy
**Use Smart (Container) Components when**:
- Managing state
- Calling services
- Handling business logic
- Composing dumb components

**Use Dumb (Presentational) Components when**:
- Pure display logic
- Reusable UI elements
- Inputs and outputs only
- No service dependencies

### Change Detection
**Use OnPush when** (recommended default):
- Inputs are immutable
- Performance matters
- Want predictable change detection

**Use Default when**:
- Rapid prototyping
- Complex two-way binding scenarios

### State Management
**Use Services + RxJS when**:
- Simple state (< 5 features)
- State local to feature

**Use Signals when** (Angular 16+):
- Simpler reactive state
- Better performance than RxJS
- Want fine-grained reactivity

**Use NgRx when**:
- Complex global state
- Time-travel debugging needed
- Strict Redux pattern desired

## 1. Project Structure
```
src/app/
├── core/               # Singleton services, guards, interceptors
├── shared/             # Reusable components, pipes, directives
├── features/
│   └── users/
│       ├── users.module.ts
│       ├── users-routing.module.ts
│       ├── components/
│       ├── services/
│       └── models/
└── app.module.ts
```

## 2. Components
- **Smart vs Dumb**: Container components (smart) vs presentational (dumb).
- **OnPush**: Use `ChangeDetectionStrategy.OnPush` by default.
- **Standalone**: Prefer standalone components (Angular 14+).

```typescript
// ✅ Good - Standalone component with OnPush
@Component({
  selector: 'app-user-card',
  standalone: true,
  imports: [CommonModule],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `<div>{{ user.name }}</div>`,
})
export class UserCardComponent {
  @Input({ required: true }) user!: User;
  @Output() delete = new EventEmitter<string>();
}
```

## 3. Services
- **Injectable**: Use `providedIn: 'root'` for singletons.
- **Feature Services**: Provide in feature module for scoped instances.
- **HTTP**: Use HttpClient with typed responses.

```typescript
// ✅ Good
@Injectable({ providedIn: 'root' })
export class UserService {
  constructor(private http: HttpClient) {}

  getUsers(): Observable<User[]> {
    return this.http.get<User[]>('/api/users');
  }
}
```

## 4. State Management
- **Services + RxJS**: For simple state.
- **NgRx**: For complex state with Redux pattern.
- **Signals**: For reactive state (Angular 16+).

```typescript
// ✅ Good - Signal-based state
@Injectable({ providedIn: 'root' })
export class UserStore {
  private users = signal<User[]>([]);
  readonly users$ = this.users.asReadonly();
  
  addUser(user: User) {
    this.users.update(users => [...users, user]);
  }
}
```

## 5. RxJS Best Practices
- **Async Pipe**: Let Angular handle subscriptions.
- **takeUntilDestroyed**: Auto-unsubscribe (Angular 16+).
- **Avoid Subscribe**: Prefer async pipe in templates.

```typescript
// ✅ Good
@Component({
  template: `
    @for (user of users$ | async; track user.id) {
      <app-user-card [user]="user" />
    }
  `,
})
export class UserListComponent {
  users$ = this.userService.getUsers();
}

// ❌ Bad - Manual subscription
ngOnInit() {
  this.userService.getUsers().subscribe(users => this.users = users);
}
```

## 6. Forms
- **Reactive Forms**: For complex forms with validation.
- **Typed Forms**: Use `FormGroup<T>` for type safety.
- **Template Forms**: Only for simple forms.

```typescript
// ✅ Good - Typed reactive form
form = new FormGroup({
  name: new FormControl('', { nonNullable: true, validators: [Validators.required] }),
  email: new FormControl('', { nonNullable: true, validators: [Validators.email] }),
});
```

## 7. Routing
- **Lazy Loading**: Load feature modules on demand.
- **Guards**: Protect routes with `canActivate`, `canMatch`.
- **Resolvers**: Pre-fetch data before navigation.

```typescript
// ✅ Good - Lazy loading
const routes: Routes = [
  {
    path: 'users',
    loadChildren: () => import('./features/users/users.module').then(m => m.UsersModule),
  },
];
```

## Best Practices

**MUST**:
- Use standalone components (NO NgModules for new features)
- Use `ChangeDetectionStrategy.OnPush` by default
- Use `async` pipe in templates (NO manual subscriptions)
- Use `takeUntilDestroyed()` for manual subscriptions (Angular 16+)
- Use `providedIn: 'root'` for singleton services

**SHOULD**:
- Use Signals for reactive state (Angular 16+)
- Use reactive forms (NOT template-driven for complex forms)
- Use lazy loading for feature modules
- Use trackBy in `@for` loops
- Use typed forms for type safety

**AVOID**:
- Manual subscriptions without unsubscribe
- Default change detection (use OnPush)
- Logic in templates (extract to component/pipe)
- Mutating inputs (use immutable patterns)
- God components (split into smaller components)

## Common Patterns

### Smart vs Dumb Components
```typescript
// ✅ GOOD: Smart component (container)
@Component({
  selector: 'app-user-list-page',
  standalone: true,
  imports: [CommonModule, UserListComponent],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    @if (users$ | async; as users) {
      <app-user-list 
        [users]="users" 
        (delete)="onDelete($event)" 
      />
    }
  `,
})
export class UserListPageComponent {
  users$ = this.userService.getUsers();
  
  constructor(private userService: UserService) {}
  
  onDelete(id: string) {
    this.userService.deleteUser(id).subscribe();
  }
}

// ✅ GOOD: Dumb component (presentational)
@Component({
  selector: 'app-user-list',
  standalone: true,
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    @for (user of users; track user.id) {
      <div>
        {{ user.name }}
        <button (click)="delete.emit(user.id)">Delete</button>
      </div>
    }
  `,
})
export class UserListComponent {
  @Input({ required: true }) users!: User[];
  @Output() delete = new EventEmitter<string>();
  // No service dependencies, pure display logic
}

// ❌ BAD: Mixed responsibilities
@Component({
  template: `
    @for (user of users; track user.id) {
      <div>{{ user.name }}</div>
    }
  `,
})
export class UserListComponent implements OnInit {
  users: User[] = [];
  
  constructor(private userService: UserService) {}  // Service in dumb component
  
  ngOnInit() {
    this.userService.getUsers().subscribe(u => this.users = u);  // Fetching in dumb component
  }
}
```

### RxJS + Async Pipe
```typescript
// ✅ GOOD: Async pipe handles subscription
@Component({
  template: `
    @if (user$ | async; as user) {
      <div>{{ user.name }}</div>
    } @else {
      <div>Loading...</div>
    }
  `,
})
export class UserProfileComponent {
  user$ = this.route.params.pipe(
    switchMap(params => this.userService.getUser(params['id']))
  );
  
  constructor(
    private route: ActivatedRoute,
    private userService: UserService,
  ) {}
  // No ngOnDestroy needed - async pipe auto-unsubscribes
}

// ❌ BAD: Manual subscription
@Component({
  template: `<div>{{ user?.name }}</div>`,
})
export class UserProfileComponent implements OnInit, OnDestroy {
  user?: User;
  private subscription?: Subscription;
  
  ngOnInit() {
    this.subscription = this.userService.getUser(this.id)
      .subscribe(u => this.user = u);  // Manual subscription
  }
  
  ngOnDestroy() {
    this.subscription?.unsubscribe();  // Easy to forget
  }
}
```

### Signal-Based State
```typescript
// ✅ GOOD: Signals for reactive state (Angular 16+)
@Injectable({ providedIn: 'root' })
export class CartStore {
  // Private writable signal
  private _items = signal<CartItem[]>([]);
  
  // Public readonly signal
  readonly items = this._items.asReadonly();
  
  // Computed signals
  readonly total = computed(() => 
    this._items().reduce((sum, item) => sum + item.price * item.quantity, 0)
  );
  
  readonly itemCount = computed(() => 
    this._items().reduce((sum, item) => sum + item.quantity, 0)
  );
  
  addItem(item: CartItem) {
    this._items.update(items => [...items, item]);  // Immutable update
  }
  
  removeItem(id: string) {
    this._items.update(items => items.filter(i => i.id !== id));
  }
}

// Usage in component
@Component({
  template: `
    <div>Total: {{ cartStore.total() }}</div>
    <div>Items: {{ cartStore.itemCount() }}</div>
  `,
})
export class CartComponent {
  constructor(public cartStore: CartStore) {}
  // Signals auto-update view - no async pipe needed
}

// ❌ BAD: BehaviorSubject for everything
@Injectable({ providedIn: 'root' })
export class CartStore {
  private _items = new BehaviorSubject<CartItem[]>([]);
  items$ = this._items.asObservable();  // More boilerplate
  
  total$ = this.items$.pipe(
    map(items => items.reduce((sum, item) => sum + item.price, 0))
  );  // Complex derived state
}
```

### Reactive Forms with Types
```typescript
// ✅ GOOD: Typed reactive form
@Component({
  template: `
    <form [formGroup]="form" (ngSubmit)="onSubmit()">
      <input formControlName="name" />
      <input formControlName="email" />
      <button type="submit" [disabled]="form.invalid">Submit</button>
    </form>
  `,
})
export class UserFormComponent {
  form = new FormGroup({
    name: new FormControl('', { 
      nonNullable: true, 
      validators: [Validators.required, Validators.minLength(2)] 
    }),
    email: new FormControl('', { 
      nonNullable: true, 
      validators: [Validators.required, Validators.email] 
    }),
  });
  
  onSubmit() {
    if (this.form.valid) {
      const { name, email } = this.form.getRawValue();  // Type-safe
      this.userService.create({ name, email }).subscribe();
    }
  }
}

// ❌ BAD: Untyped form
form = new FormGroup({
  name: new FormControl(),  // No validation, nullable
  email: new FormControl(),
});

onSubmit() {
  const data = this.form.value;  // Type is Partial<...> | null
  this.userService.create(data);  // Type error
}
```

## Common Anti-Patterns

**❌ Missing trackBy in loops**:
```typescript
// BAD - Entire list re-renders on change
<div *ngFor="let item of items">{{ item.name }}</div>
```

**✅ Use trackBy**:
```typescript
// GOOD - Only changed items re-render
@for (item of items; track item.id) {
  <div>{{ item.name }}</div>
}
```

**❌ Forgetting to unsubscribe**:
```typescript
// BAD
ngOnInit() {
  this.userService.getUsers().subscribe(u => this.users = u);  // Memory leak
}
```

**✅ Use async pipe or takeUntilDestroyed**:
```typescript
// GOOD (Option 1: async pipe)
users$ = this.userService.getUsers();

// GOOD (Option 2: takeUntilDestroyed)
ngOnInit() {
  this.userService.getUsers()
    .pipe(takeUntilDestroyed(this.destroyRef))
    .subscribe(u => this.users = u);
}
```

## 8. Performance
- **OnPush**: Reduce change detection cycles
- **TrackBy**: Use in `@for` loops for efficient rendering
- **Lazy Loading**: Split code by feature module
- **Pure Pipes**: For transformations in templates

