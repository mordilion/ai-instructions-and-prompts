# Express.js Framework

> **Scope**: Apply these rules when working with Express.js backend applications.

## 1. Project Structure
```
src/
├── config/
│   ├── database.ts
│   └── env.ts
├── controllers/
│   └── user.controller.ts
├── middleware/
│   ├── auth.ts
│   ├── error.ts
│   └── validate.ts
├── models/
│   └── user.model.ts
├── routes/
│   ├── index.ts
│   └── user.routes.ts
├── services/
│   └── user.service.ts
├── types/
│   └── express.d.ts
├── utils/
│   └── errors.ts
├── app.ts
└── server.ts
```

## 2. Application Setup
```typescript
// app.ts
import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import routes from './routes';
import { errorHandler, notFoundHandler } from './middleware/error';

const app = express();

// Security middleware
app.use(helmet());
app.use(cors());

// Body parsing
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Routes
app.use('/api', routes);

// Error handling (must be last)
app.use(notFoundHandler);
app.use(errorHandler);

export default app;
```

## 3. Controllers
- **Thin Controllers**: Validate, delegate to service, respond.
- **Async Handlers**: Use wrapper or express-async-errors.
- **Typed Requests**: Extend Express types.

```typescript
// controllers/user.controller.ts
import { Request, Response, NextFunction } from 'express';
import { userService } from '../services/user.service';
import { CreateUserDto } from '../types/user.dto';

export const createUser = async (
  req: Request<{}, {}, CreateUserDto>,
  res: Response,
  next: NextFunction
) => {
  try {
    const user = await userService.create(req.body);
    res.status(201).json(user);
  } catch (error) {
    next(error);
  }
};

export const getUser = async (
  req: Request<{ id: string }>,
  res: Response,
  next: NextFunction
) => {
  try {
    const user = await userService.findById(req.params.id);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }
    res.json(user);
  } catch (error) {
    next(error);
  }
};
```

## 4. Routes
- **Router Modules**: Group related routes.
- **RESTful**: Follow REST conventions.
- **Middleware Chain**: Validate → Auth → Controller.

```typescript
// routes/user.routes.ts
import { Router } from 'express';
import { createUser, getUser, updateUser, deleteUser } from '../controllers/user.controller';
import { authenticate } from '../middleware/auth';
import { validate } from '../middleware/validate';
import { createUserSchema, updateUserSchema } from '../validators/user.validator';

const router = Router();

router.post('/', validate(createUserSchema), createUser);
router.get('/:id', getUser);
router.put('/:id', authenticate, validate(updateUserSchema), updateUser);
router.delete('/:id', authenticate, deleteUser);

export default router;

// routes/index.ts
import { Router } from 'express';
import userRoutes from './user.routes';

const router = Router();
router.use('/users', userRoutes);

export default router;
```

## 5. Middleware
```typescript
// middleware/auth.ts
import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { AppError } from '../utils/errors';

export const authenticate = (req: Request, res: Response, next: NextFunction) => {
  const token = req.headers.authorization?.split(' ')[1];
  
  if (!token) {
    throw new AppError('No token provided', 401);
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET!);
    req.user = decoded as User;
    next();
  } catch {
    throw new AppError('Invalid token', 401);
  }
};

// middleware/validate.ts
import { Request, Response, NextFunction } from 'express';
import { ZodSchema } from 'zod';

export const validate = (schema: ZodSchema) => 
  (req: Request, res: Response, next: NextFunction) => {
    const result = schema.safeParse(req.body);
    if (!result.success) {
      return res.status(400).json({ errors: result.error.flatten() });
    }
    req.body = result.data;
    next();
  };
```

## 6. Error Handling
```typescript
// utils/errors.ts
export class AppError extends Error {
  constructor(
    public message: string,
    public statusCode: number = 500,
    public isOperational = true
  ) {
    super(message);
    Error.captureStackTrace(this, this.constructor);
  }
}

// middleware/error.ts
import { Request, Response, NextFunction } from 'express';
import { AppError } from '../utils/errors';

export const errorHandler = (
  err: Error,
  req: Request,
  res: Response,
  next: NextFunction
) => {
  if (err instanceof AppError) {
    return res.status(err.statusCode).json({
      status: 'error',
      message: err.message,
    });
  }

  console.error(err);
  res.status(500).json({
    status: 'error',
    message: 'Internal server error',
  });
};

export const notFoundHandler = (req: Request, res: Response) => {
  res.status(404).json({ message: 'Route not found' });
};
```

## 7. Type Extensions
```typescript
// types/express.d.ts
declare global {
  namespace Express {
    interface Request {
      user?: {
        id: string;
        email: string;
        role: string;
      };
    }
  }
}

export {};
```

## 8. Best Practices
- **Environment Variables**: Use dotenv + validation (zod).
- **Logging**: Use winston or pino.
- **Rate Limiting**: Use express-rate-limit.
- **Graceful Shutdown**: Handle SIGTERM/SIGINT.

