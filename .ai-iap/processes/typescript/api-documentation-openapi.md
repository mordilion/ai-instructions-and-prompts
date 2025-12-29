# API Documentation Process - TypeScript/Node.js (OpenAPI/Swagger)

> **Purpose**: Auto-generate interactive API documentation with OpenAPI/Swagger

> **Tools**: Swagger UI, NestJS Swagger, tsoa, express-openapi

---

## Phase 1: Setup Swagger

### NestJS (Recommended)

**Install**:
```bash
npm install @nestjs/swagger
```

**Configure** (main.ts):
```typescript
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';

const config = new DocumentBuilder()
  .setTitle('My API')
  .setDescription('API description')
  .setVersion('1.0')
  .addBearerAuth()
  .build();

const document = SwaggerModule.createDocument(app, config);
SwaggerModule.setup('api/docs', app, document);
```

**Annotate Controllers**:
```typescript
@ApiTags('users')
@Controller('users')
export class UsersController {
  @Get(':id')
  @ApiOperation({ summary: 'Get user by ID' })
  @ApiResponse({ status: 200, description: 'User found', type: UserDto })
  @ApiResponse({ status: 404, description: 'User not found' })
  findOne(@Param('id') id: string) { }
}
```

> **Access**: http://localhost:3000/api/docs

---

## Phase 2: Express.js Setup

**Install**:
```bash
npm install swagger-jsdoc swagger-ui-express
npm install --save-dev @types/swagger-jsdoc @types/swagger-ui-express
```

**Configure**:
```typescript
import swaggerJsdoc from 'swagger-jsdoc';
import swaggerUi from 'swagger-ui-express';

const options = {
  definition: {
    openapi: '3.0.0',
    info: { title: 'My API', version: '1.0.0' },
    components: {
      securitySchemes: {
        bearerAuth: { type: 'http', scheme: 'bearer', bearerFormat: 'JWT' }
      }
    }
  },
  apis: ['./src/routes/*.ts']
};

const specs = swaggerJsdoc(options);
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(specs));
```

**Annotate Routes**:
```typescript
/**
 * @openapi
 * /users/{id}:
 *   get:
 *     summary: Get user by ID
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: User found
 */
app.get('/users/:id', getUser);
```

---

## Phase 3: Best Practices

> **ALWAYS**:
> - Document all endpoints
> - Include request/response examples
> - Document authentication
> - Version your API

> **NEVER**:
> - Expose sensitive data in examples
> - Skip error responses
> - Forget to update docs with API changes

---

## AI Self-Check

- [ ] Swagger/OpenAPI configured
- [ ] All endpoints documented
- [ ] Authentication documented
- [ ] Request/response schemas defined
- [ ] Try-it-out works
- [ ] Docs accessible at /api-docs or /api/docs

---

**Process Complete** ✅

