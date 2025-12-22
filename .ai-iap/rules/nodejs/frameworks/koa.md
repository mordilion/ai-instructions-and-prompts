# Koa

> **Scope**: Apply these rules for Koa applications (JavaScript or TypeScript).

## Overview

Koa is a modern Node.js framework from Express creators - smaller, more expressive, with async/await throughout.

## Best Practices

**MUST**:
- Use async/await (NO callbacks)
- Use ctx (context) for request/response
- Understand onion model (middleware order)
- Use try-catch in middleware

**SHOULD**:
- Use @koa/router for routing
- Use koa-bodyparser for JSON
- Place error handler first
- Use ctx.throw for errors

**AVOID**:
- Callback-based code
- Missing error handling
- Business logic in routes

## Project Structure
```
src/
├── routes/
├── controllers/
├── services/
├── middleware/
├── types/            # (TS only)
├── app.js|ts
└── server.js|ts
```

## Key Patterns

### App Setup (Onion Model)
```javascript
// app.js|ts
import Koa from 'koa';
import bodyParser from 'koa-bodyparser';
import cors from '@koa/cors';
import { errorHandler } from './middleware/error';
import router from './routes';

const app = new Koa();

// Middleware order matters (onion model)
app.use(errorHandler);    // Outer layer - catches all errors
app.use(cors());
app.use(bodyParser());
app.use(router.routes());
app.use(router.allowedMethods());

export default app;
```

### Routes
```javascript
// routes/users.routes.js|ts
import Router from '@koa/router';
import * as controller from '../controllers/users.controller';
import { authenticate } from '../middleware/auth';

const router = new Router({ prefix: '/users' });

router.get('/', authenticate, controller.getAll);
router.post('/', authenticate, controller.create);
router.get('/:id', authenticate, controller.getById);

export default router;
```

### Controller
```javascript
// controllers/users.controller.js|ts
export async function create(ctx) {
  const user = await userService.create(ctx.request.body);
  ctx.status = 201;
  ctx.body = { data: user };
}

export async function getById(ctx) {
  const user = await userService.findById(ctx.params.id);
  if (!user) ctx.throw(404, 'User not found');
  ctx.body = { data: user };
}
```

### Middleware
```javascript
// middleware/error.js|ts
export async function errorHandler(ctx, next) {
  try {
    await next();
  } catch (err) {
    ctx.status = err.status || 500;
    ctx.body = { error: { message: err.message, status: ctx.status } };
    ctx.app.emit('error', err, ctx);
  }
}

// middleware/auth.js|ts
export async function authenticate(ctx, next) {
  const token = ctx.headers.authorization?.replace('Bearer ', '');
  if (!token) ctx.throw(401, 'Unauthorized');
  ctx.state.user = await verifyToken(token);
  await next();
}
```

### Typed Context (TS)
```typescript
// types/context.ts
import { Context, DefaultState } from 'koa';

interface AppState extends DefaultState {
  user?: { id: string; email: string };
}

interface AppContext extends Context {
  state: AppState;
}

// Use: Router<AppState, AppContext>
```

## Best Practices
- **ctx.throw**: Use for HTTP errors (caught by error middleware)
- **ctx.state**: Share data between middleware (e.g., user)
- **ctx.request.body**: Access parsed body (via koa-bodyparser)
- **Async/Await**: All middleware must be async functions

