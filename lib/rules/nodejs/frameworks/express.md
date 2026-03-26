# Express.js

> **Scope**: Express.js applications (JavaScript or TypeScript)  
> **Applies to**: Express.js projects  
> **Extends**: javascript/architecture.md, nodejs/architecture.md (if exists)

## CRITICAL REQUIREMENTS

> **ALWAYS**: Use async/await (not callbacks)
> **ALWAYS**: Use middleware for cross-cutting concerns
> **ALWAYS**: Error handling middleware (must be last)
> **ALWAYS**: Use Router for modular routes
> **ALWAYS**: Use helmet for security headers
> 
> **NEVER**: Put business logic in routes
> **NEVER**: Use callback hell
> **NEVER**: Skip error handling middleware
> **NEVER**: Synchronous operations in request handlers
> **NEVER**: Expose stack traces to clients

## Project Structure
```
src/
├── routes/           # Route definitions
├── controllers/      # Request handlers
├── services/         # Business logic
├── middleware/       # Auth, validation, error handling
├── models/           # Database models
├── types/            # (TS only) Type definitions
├── app.js|ts         # Express setup
└── server.js|ts      # Entry point
```

## Route → Controller → Service Pattern
```
Route (define endpoints) → Controller (handle request/response) → Service (business logic)
```

## Key Patterns

### App Setup
```javascript
// app.js|ts
import express from 'express';
import helmet from 'helmet';
import cors from 'cors';
import routes from './routes';
import { errorHandler } from './middleware/error';

const app = express();
app.use(helmet());
app.use(cors());
app.use(express.json());
app.use('/api', routes);
app.use(errorHandler);  // Must be last

export default app;
```

### Routes
```javascript
// routes/users.routes.js|ts
import { Router } from 'express';
import { getUsers, createUser } from '../controllers/users.controller';
import { authenticate } from '../middleware/auth';
import { validate } from '../middleware/validate';

const router = Router();
router.get('/', authenticate, getUsers);
router.post('/', authenticate, validate(schema), createUser);
export default router;
```

### Controller (TS version)
```typescript
// controllers/users.controller.ts
import { Request, Response, NextFunction } from 'express';

export const createUser = async (
  req: Request<{}, {}, CreateUserDto>,  // <Params, Query, Body>
  res: Response,
  next: NextFunction
) => {
  try {
    const user = await userService.create(req.body);
    res.status(201).json({ data: user });
  } catch (error) {
    next(error);
  }
};
```

### Error Handling
```javascript
// middleware/error.js|ts
export const errorHandler = (err, req, res, next) => {
  const status = err.status || 500;
  res.status(status).json({
    error: { message: err.message, status }
  });
};
```

### Type Extensions (TS)
```typescript
// types/express.d.ts
declare global {
  namespace Express {
    interface Request {
      user?: { id: string; email: string; role: string };
    }
  }
}
export {};
```

## Best Practices
- **Thin Controllers**: Validate → delegate to service → respond
- **Async Errors**: Always try/catch or use express-async-errors
- **Validation**: Use Zod (TS) or Joi
- **Security**: helmet, cors, rate-limit
- **Logging**: winston or pino (not console.log)

## AI Self-Check

- [ ] Using async/await (not callbacks)?
- [ ] Middleware for cross-cutting concerns?
- [ ] Error handling middleware (last)?
- [ ] Router for modular routes?
- [ ] helmet for security headers?
- [ ] Controllers thin (delegating to services)?
- [ ] Validation middleware (Zod/Joi)?
- [ ] No business logic in routes?
- [ ] No callback hell?
- [ ] No missing error handling?
- [ ] No synchronous operations in handlers?
- [ ] CORS configured with specific origins?

