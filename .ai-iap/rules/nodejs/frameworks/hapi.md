# Hapi

> **Scope**: Apply these rules for Hapi applications (JavaScript or TypeScript).

## Project Structure
```
src/
├── plugins/          # Auth, database
├── routes/           # Route definitions
├── handlers/         # Request handlers
├── schemas/          # Joi validation schemas
├── services/
├── types/            # (TS only)
└── server.js|ts
```

## Key Patterns

### Server Setup
```javascript
// server.js|ts
import Hapi from '@hapi/hapi';
import { authPlugin } from './plugins/auth';
import { userRoutes } from './routes/users.routes';

export async function init() {
  const server = Hapi.server({
    port: process.env.PORT || 3000,
    routes: {
      cors: true,
      validate: { failAction: async (req, h, err) => { throw err; } }
    }
  });

  await server.register([authPlugin]);
  server.route(userRoutes);
  
  return server;
}
```

### Routes with Joi Validation
```javascript
// routes/users.routes.js|ts
import Joi from 'joi';
import * as handlers from '../handlers/users.handlers';

export const userRoutes = [
  {
    method: 'GET',
    path: '/api/users',
    options: {
      auth: 'jwt',
      handler: handlers.getUsers
    }
  },
  {
    method: 'POST',
    path: '/api/users',
    options: {
      auth: 'jwt',
      handler: handlers.createUser,
      validate: {
        payload: Joi.object({
          email: Joi.string().email().required(),
          name: Joi.string().min(2).required()
        })
      }
    }
  }
];
```

### Handlers
```javascript
// handlers/users.handlers.js|ts
import Boom from '@hapi/boom';

export async function createUser(request, h) {
  const user = await userService.create(request.payload);
  return h.response({ data: user }).code(201);
}

export async function getUser(request, h) {
  const user = await userService.findById(request.params.id);
  if (!user) throw Boom.notFound('User not found');
  return { data: user };
}
```

### Auth Plugin
```javascript
// plugins/auth.js|ts
import Jwt from '@hapi/jwt';

export const authPlugin = {
  name: 'auth',
  register: async (server) => {
    await server.register(Jwt);
    
    server.auth.strategy('jwt', 'jwt', {
      keys: process.env.JWT_SECRET,
      validate: async (artifacts) => ({
        isValid: true,
        credentials: { user: artifacts.decoded.payload }
      })
    });
    
    server.auth.default('jwt');
  }
};
```

### Boom Errors
```javascript
import Boom from '@hapi/boom';

throw Boom.badRequest('Invalid input');      // 400
throw Boom.unauthorized('Invalid token');    // 401
throw Boom.forbidden('Access denied');       // 403
throw Boom.notFound('Not found');            // 404
throw Boom.conflict('Already exists');       // 409
```

## Best Practices
- **Joi Validation**: Always validate params, query, and payload
- **Boom Errors**: Consistent, type-safe HTTP errors
- **Plugin System**: Encapsulate features as plugins
- **request.payload**: Access body (not request.body)

