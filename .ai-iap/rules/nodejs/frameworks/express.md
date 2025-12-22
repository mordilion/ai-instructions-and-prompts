# Express.js

> **Scope**: Apply these rules for Express.js applications (JavaScript or TypeScript).

## Overview

Express is the most popular Node.js web framework - minimal, flexible, with a large ecosystem.

## Best Practices

**MUST**:
- Use async/await (NO callbacks)
- Use middleware for cross-cutting concerns
- Use error handling middleware (must be last)
- Return responses (res.json, res.send)

**SHOULD**:
- Use Router for modular routes
- Use controllers for request handling
- Use services for business logic
- Use helmet for security headers

**AVOID**:
- Business logic in routes
- Callback hell (use async/await)
- Missing error handling
- Synchronous operations

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

