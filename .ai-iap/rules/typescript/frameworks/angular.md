# Angular Framework

> **Scope**: Apply these rules when working with Angular applications.

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

## 8. Performance
- **OnPush**: Reduce change detection cycles.
- **TrackBy**: Use in `@for` loops.
- **Lazy Loading**: Split code by feature.
- **Pure Pipes**: For transformations in templates.

