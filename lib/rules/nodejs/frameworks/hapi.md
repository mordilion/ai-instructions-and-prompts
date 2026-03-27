# Hapi

> **Scope**: Hapi applications (JavaScript or TypeScript)  
> **Applies to**: Hapi projects  
> **Extends**: javascript/architecture.md

## CRITICAL REQUIREMENTS

> **ALWAYS**: Use Joi for validation
> **ALWAYS**: Use plugins for modularity
> **ALWAYS**: Define routes as objects
> **ALWAYS**: Use async handlers
> **ALWAYS**: Validation schemas for all routes
> 
> **NEVER**: Skip validation schemas
> **NEVER**: Put logic in route definitions
> **NEVER**: Synchronous operations in handlers
> **NEVER**: Missing error handlers
> **NEVER**: Expose internal errors

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

```javascript
// Server Setup
const server = Hapi.server({ port: 3000, routes: { cors: true } });
await server.register([authPlugin]);
server.route(userRoutes);

// Routes with Joi Validation
export const userRoutes = [{
  method: 'POST',
  path: '/api/users',
  options: {
    auth: 'jwt',
    handler: handlers.createUser,
    validate: { payload: Joi.object({ email: Joi.string().email().required() }) }
  }
}];

// Handler
export async function createUser(request, h) {
  const user = await userService.create(request.payload);
  if (!user) throw Boom.notFound('User not found');
  return h.response({ data: user }).code(201);
}

// Auth Plugin
export const authPlugin = {
  name: 'auth',
  register: async (server) => {
    await server.register(Jwt);
    server.auth.strategy('jwt', 'jwt', { keys: process.env.JWT_SECRET });
    server.auth.default('jwt');
  }
};
```

## Best Practices
- **Joi Validation**: Always validate params, query, and payload
- **Boom Errors**: Consistent, type-safe HTTP errors
- **Plugin System**: Encapsulate features as plugins
- **request.payload**: Access body (not request.body)

## AI Self-Check

- [ ] Joi validation for all routes?
- [ ] Plugins for modularity?
- [ ] Routes defined as objects?
- [ ] async handlers used?
- [ ] Validation schemas present?
- [ ] @hapi plugins for features?
- [ ] pre/post handlers for middleware?
- [ ] Boom for error responses?
- [ ] No missing validation?
- [ ] No logic in route definitions?
- [ ] No synchronous operations?
- [ ] Server methods for shared logic?

