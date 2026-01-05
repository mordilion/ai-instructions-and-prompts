# API Documentation Process - TypeScript/Node.js (OpenAPI/Swagger)

> **Purpose**: Auto-generate interactive API documentation with OpenAPI/Swagger

> **Tools**: Swagger UI, NestJS Swagger, tsoa, express-openapi

> **Reference**: See general documentation standards for HTTP status codes, error formats, and best practices

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

## Phase 3: Security & Versioning

### 3.1 Document Authentication

> **ALWAYS document**:
> - JWT bearer token format
> - OAuth 2.0 flows (if applicable)
> - API key requirements
> - Refresh token endpoints

**NestJS Security**:
```typescript
@ApiSecurity('bearer')
@ApiBearerAuth()
@Controller('protected')
export class ProtectedController { }
```

**Express.js Security**:
```typescript
/**
 * @openapi
 * components:
 *   securitySchemes:
 *     bearerAuth:
 *       type: http
 *       scheme: bearer
 *       bearerFormat: JWT
 * security:
 *   - bearerAuth: []
 */
```

### 3.2 API Versioning

> **ALWAYS include version in**:
> - URL path (`/api/v1/users`)
> - Or header (`Accept: application/vnd.myapi.v1+json`)

**Document Version Changes**:
```typescript
@ApiOperation({
  summary: 'Get user',
  deprecated: false,
  description: 'v2: Added email field. v1: Only returns id and name'
})
```

### 3.3 Rate Limiting Documentation

> **Document rate limits**:
```typescript
@ApiHeader({
  name: 'X-RateLimit-Limit',
  description: 'Request limit per hour'
})
@ApiHeader({
  name: 'X-RateLimit-Remaining',
  description: 'Remaining requests'
})
```

### 3.4 Consistent Error Response Format

> **Reference**: See general documentation standards for recommended error format

**NestJS Implementation**:
```typescript
export class ErrorResponseDto {
  @ApiProperty()
  error: {
    code: string;
    message: string;
    details?: Array<{ field: string; issue: string }>;
    timestamp: string;
    request_id: string;
  };
}

@ApiResponse({ 
  status: 400, 
  description: 'Validation error',
  type: ErrorResponseDto 
})
```

**Express.js Implementation**:
```typescript
app.use((err, req, res, next) => {
  res.status(err.status || 500).json({
    error: {
      code: err.code || 'INTERNAL_ERROR',
      message: err.message,
      details: err.details || [],
      timestamp: new Date().toISOString(),
      request_id: req.id
    }
  });
});
```

---

## Phase 4: CI/CD Integration

### 4.1 Auto-Generate & Validate

> **ALWAYS**:
> - Generate OpenAPI spec in CI/CD
> - Validate spec (use Spectral, openapi-generator-cli)
> - Export spec as artifact
> - Version control generated spec

**CI/CD Example**:
```yaml
- name: Generate OpenAPI Spec
  run: |
    npm run build
    npm run generate-openapi
    npx @openapitools/openapi-generator-cli validate -i openapi.json
```

### 4.2 Publish Documentation

> **Options**:
> - **Swagger UI**: Self-hosted on `/docs`
> - **ReDoc**: Alternative UI at `/redoc`
> - **Postman**: Import OpenAPI spec
> - **API Portal**: AWS API Gateway, Azure APIM

### 4.3 Generate Client SDKs

> **ALWAYS**: Generate type-safe client SDKs from OpenAPI spec

**Generate TypeScript Client**:
```bash
npx @openapitools/openapi-generator-cli generate \
  -i openapi.json \
  -g typescript-axios \
  -o sdks/typescript-client
```

**Generate Python Client**:
```bash
npx @openapitools/openapi-generator-cli generate \
  -i openapi.json \
  -g python \
  -o sdks/python-client
```

**Usage Example**:
```typescript
import { UsersApi } from './sdks/typescript-client';

const api = new UsersApi();
const user = await api.getUser('123');
```

---

## Best Practices

> **ALWAYS**:
> - Document all endpoints (including internal APIs)
> - Include realistic request/response examples
> - Document all error codes (400, 401, 403, 404, 500)
> - Add descriptions to parameters and schemas
> - Use tags to group related endpoints
> - Keep docs in sync with code (auto-generation preferred)

> **NEVER**:
> - Hardcode sensitive data in examples (use `"<API_KEY>"` placeholders)
> - Skip documenting deprecated endpoints (mark as deprecated)
> - Forget to document query parameters and headers
> - Use vague descriptions ("Gets data")

---

## Troubleshooting

### Issue: Swagger UI not loading
- **Solution**: Check CORS settings, ensure `/docs` route not blocked, verify base URL

### Issue: Endpoints not appearing in docs
- **Solution**: Verify decorators/annotations present, check include/exclude paths, rebuild docs

### Issue: Authentication not working in Try-it-out
- **Solution**: Add `@ApiSecurity` decorator, configure auth in OpenAPI config, check CORS

### Issue: Schemas not showing types
- **Solution**: Use DTO/Schema classes with decorators, enable metadata reflection

---

## AI Self-Check

- [ ] OpenAPI/Swagger configured and accessible
- [ ] NestJS or Express.js setup complete
- [ ] All endpoints annotated with decorators
- [ ] JWT/Bearer authentication configured
- [ ] CI/CD generates and validates OpenAPI spec
- [ ] Client SDKs generated for target languages
- [ ] Swagger UI Try-it-out functionality works
- [ ] Error responses follow consistent format (see general standards)
- [ ] All status codes documented (see general standards)
- [ ] Rate limiting documented (if applicable)

---

**Process Complete** ✅

