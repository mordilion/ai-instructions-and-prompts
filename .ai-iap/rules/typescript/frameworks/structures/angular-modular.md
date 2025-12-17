# Angular Modular/Feature Structure

> **Scope**: Use this structure for large Angular applications with feature modules.
> **Precedence**: When loaded, this structure overrides any default folder organization from the base Angular rules.

## Project Structure
```
src/app/
├── core/                   # Singleton services, guards
│   ├── guards/
│   ├── interceptors/
│   ├── services/
│   └── core.module.ts
├── shared/                 # Shared components, pipes, directives
│   ├── components/
│   ├── directives/
│   ├── pipes/
│   └── shared.module.ts
├── features/               # Feature modules (lazy loaded)
│   ├── auth/
│   │   ├── components/
│   │   ├── pages/
│   │   ├── services/
│   │   ├── auth-routing.module.ts
│   │   └── auth.module.ts
│   ├── users/
│   │   ├── components/
│   │   ├── pages/
│   │   ├── services/
│   │   └── users.module.ts
│   └── dashboard/
├── app-routing.module.ts
└── app.module.ts
```

## Rules
- **Core Module**: Import once in AppModule (singleton services)
- **Shared Module**: Import in feature modules (reusable components)
- **Feature Modules**: Lazy loaded, self-contained
- **No Cross-Feature Imports**: Use shared or core services

## Lazy Loading
```typescript
const routes: Routes = [
  { path: 'users', loadChildren: () => import('./features/users/users.module').then(m => m.UsersModule) },
];
```

## When to Use
- Enterprise applications
- Multiple teams working on features
- Performance-critical apps (lazy loading)

