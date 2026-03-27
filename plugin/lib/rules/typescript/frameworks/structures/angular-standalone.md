# Angular Standalone Components Structure

> **Scope**: Standalone components structure for Angular 14+  
> **Applies to**: Angular projects with standalone components  
> **Extends**: typescript/frameworks/angular.md

## CRITICAL REQUIREMENTS

> **ALWAYS**: standalone: true for all components
> **ALWAYS**: Import dependencies directly in component
> **ALWAYS**: Use provideRouter (not RouterModule)
> **ALWAYS**: Routes in *.routes.ts files
> **ALWAYS**: App config in app.config.ts
> 
> **NEVER**: Use NgModules (use standalone)
> **NEVER**: Missing standalone: true
> **NEVER**: Missing imports array
> **NEVER**: RouterModule (use provideRouter)
> **NEVER**: Shared NgModules (use shared standalone components)

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

## AI Self-Check

- [ ] standalone: true for all components?
- [ ] Dependencies imported directly in components?
- [ ] provideRouter used (not RouterModule)?
- [ ] Routes in *.routes.ts files?
- [ ] App config in app.config.ts?
- [ ] No NgModules?
- [ ] imports array present in components?
- [ ] Core services in core/ folder?
- [ ] Shared components in shared/ folder?
- [ ] Features lazy loaded?

