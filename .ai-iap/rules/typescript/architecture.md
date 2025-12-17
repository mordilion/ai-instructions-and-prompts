# TypeScript Architecture

> **Scope**: Apply these rules ONLY when working with `.ts` or `.tsx` files. These extend the general architecture guidelines.

## 1. Core Principles
- **Modularity**: Small files (<200 lines). Clear, explicit imports.
- **Unidirectional Flow**: Data flows down, events bubble up.

## 2. Project Structure
- **Feature-First**: Organize by feature/module, NOT by type (controllers/, services/).
- **Shared Code**: Common utilities in `shared/` or `common/` folder.
- **Types**: Colocate types with features, or centralize in `types/` folder.
- **Note**: See structure files for specific folder layouts (React, NestJS, etc.).

## 3. Naming Conventions
- **Interfaces**: NO `I` prefix (e.g., `User`, not `IUser`).
- **Implementations**: Same name as interface or descriptive (e.g., `PrismaUserRepository`).
- **DTOs**: Suffix with `Dto`, `Request`, `Response` (e.g., `UserDto`).

## 4. Design Patterns
- **Container/Presenter**: Separate logic (hooks) from rendering (dumb components).
- **Dependency Injection**: Use constructor injection or DI containers (NestJS, InversifyJS).

## 5. DTOs & Mapping
- NEVER return raw database entities. Always map to DTOs.
- Define shared types in `contracts/` or `shared/` module.

## 6. Anti-Patterns (MUST avoid)
- **Circular Imports**: Use barrel files (`index.ts`) carefully. Check with `madge`.
- **Frontend importing Backend**: NEVER import backend code in frontend.
  - ❌ Bad: `import { UserService } from '../backend/services/user.service';`
  - ✅ Good: `import { UserDto } from '../shared/types/user.dto';`
- **God Components**: Components >200 lines = split into smaller components.
