# Fastify

> **Scope**: Apply these rules for Fastify applications (JavaScript or TypeScript).

## Overview

Fastify is a fast Node.js framework focused on performance and developer experience with built-in schema validation.

## Best Practices

**MUST**:
- Use schema validation for all routes
- Use plugins for modularity
- Use async/await
- Register plugins before routes

**SHOULD**:
- Use JSON Schema for validation
- Use TypeScript for type safety
- Use decorators for DI
- Enable logging

**AVOID**:
- Missing schema validation
- Synchronous operations
- Direct database access in routes

## Project Structure
```
src/
├── plugins/          # Database, auth, etc.
├── routes/           # Route modules
│   └── users/
│       ├── index.js|ts
│       ├── handlers.js|ts
│       └── schemas.js|ts
├── services/
├── types/            # (TS only)
├── app.js|ts
└── server.js|ts
```

## Key Patterns

### App Setup
```javascript
// app.js|ts
import Fastify from 'fastify';
import cors from '@fastify/cors';
import dbPlugin from './plugins/database';
import userRoutes from './routes/users';

export async function buildApp() {
  const fastify = Fastify({ logger: true });
  
  await fastify.register(cors);
  await fastify.register(dbPlugin);
  await fastify.register(userRoutes, { prefix: '/api/users' });
  
  return fastify;
}
```

### Routes with Schema Validation
```javascript
// routes/users/index.js|ts
export default async function userRoutes(fastify) {
  fastify.post('/', {
    schema: {
      body: {
        type: 'object',
        required: ['email', 'name'],
        properties: {
          email: { type: 'string', format: 'email' },
          name: { type: 'string', minLength: 2 }
        }
      }
    },
    handler: createUserHandler
  });
}
```

### TypeBox Schemas (TS)
```typescript
// routes/users/schemas.ts
import { Type, Static } from '@sinclair/typebox';

export const CreateUserSchema = Type.Object({
  email: Type.String({ format: 'email' }),
  name: Type.String({ minLength: 2 })
});

export type CreateUserInput = Static<typeof CreateUserSchema>;
```

### Typed Handler (TS)
```typescript
export async function createUserHandler(
  request: FastifyRequest<{ Body: CreateUserInput }>,
  reply: FastifyReply
) {
  const user = await userService.create(request.body);
  reply.code(201);
  return { data: user };
}
```

### Plugin Pattern
```javascript
// plugins/database.js|ts
import fp from 'fastify-plugin';

async function dbPlugin(fastify, options) {
  const db = await connectDatabase();
  fastify.decorate('db', db);
  fastify.addHook('onClose', () => db.close());
}

export default fp(dbPlugin, { name: 'database' });
```

### Type Augmentation (TS)
```typescript
declare module 'fastify' {
  interface FastifyInstance {
    db: Database;
    authenticate: (req: FastifyRequest, reply: FastifyReply) => Promise<void>;
  }
}
```

## Best Practices
- **JSON Schema**: Always define for validation + serialization
- **TypeBox (TS)**: Runtime validation + type inference
- **Plugins**: Use `fastify-plugin` for shared decorators
- **Encapsulation**: Plugins are scoped by default

