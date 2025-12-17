# Angular Standalone Components Structure

> **Scope**: Use this structure for Angular 14+ apps with standalone components (no NgModules).
> **Precedence**: When loaded, this structure overrides any default folder organization from the base Angular rules.

## Project Structure
```
src/app/
├── core/                   # App-wide singletons
│   ├── auth.service.ts
│   ├── http.interceptor.ts
│   └── auth.guard.ts
├── shared/                 # Reusable standalone components
│   ├── ui/
│   │   ├── button.component.ts
│   │   └── modal.component.ts
│   └── pipes/
├── features/
│   ├── auth/
│   │   ├── login.component.ts
│   │   ├── register.component.ts
│   │   └── auth.routes.ts
│   ├── users/
│   │   ├── user-list.component.ts
│   │   ├── user-detail.component.ts
│   │   └── users.routes.ts
│   └── dashboard/
├── app.routes.ts
├── app.config.ts
└── app.component.ts
```

## Standalone Component
```typescript
@Component({
  selector: 'app-user-list',
  standalone: true,
  imports: [CommonModule, RouterLink, ButtonComponent],
  template: `...`
})
export class UserListComponent { }
```

## Route-Based Lazy Loading
```typescript
export const routes: Routes = [
  { path: 'users', loadChildren: () => import('./features/users/users.routes').then(m => m.USER_ROUTES) },
];
```

## When to Use
- New Angular 14+ projects
- Simpler mental model (no modules)
- Faster compilation
- Easier tree-shaking

