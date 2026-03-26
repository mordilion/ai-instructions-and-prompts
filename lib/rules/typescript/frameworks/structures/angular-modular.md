# Angular Modular/Feature Structure

> **Scope**: Modular structure for Angular  
> **Applies to**: Angular projects with feature modules  
> **Extends**: typescript/frameworks/angular.md

## CRITICAL REQUIREMENTS

> **ALWAYS**: Core module for singleton services
> **ALWAYS**: Shared module for shared components
> **ALWAYS**: Feature modules lazy loaded
> **ALWAYS**: Feature routing modules
> **ALWAYS**: Features independent
> 
> **NEVER**: Import feature modules in Core/Shared
> **NEVER**: Circular module dependencies
> **NEVER**: Core imported in features (provide at root)
> **NEVER**: Shared services in feature modules
> **NEVER**: Deep folder nesting

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

## AI Self-Check

- [ ] Core module for singleton services?
- [ ] Shared module for shared components?
- [ ] Feature modules lazy loaded?
- [ ] Feature routing modules present?
- [ ] Features independent?
- [ ] No feature modules in Core/Shared?
- [ ] No circular module dependencies?
- [ ] Core provided at root (not imported)?
- [ ] No shared services in features?
- [ ] Lazy loading configured?

