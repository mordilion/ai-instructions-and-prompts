# TypeScript API Documentation (OpenAPI) - Copy This Prompt

> **Type**: One-time setup process  
> **When to use**: Setting up OpenAPI/Swagger documentation for TypeScript API  
> **Instructions**: Copy the complete prompt below and paste into your AI tool

---

## 📋 Complete Self-Contained Prompt

```
========================================
TYPESCRIPT API DOCUMENTATION - OPENAPI
========================================

CONTEXT:
You are implementing OpenAPI/Swagger documentation for a TypeScript REST API.

CRITICAL REQUIREMENTS:
- ALWAYS use OpenAPI 3.0+ specification
- ALWAYS keep docs in sync with code
- NEVER document internal/private endpoints
- Use code-first approach (generate from code)

========================================
PHASE 1 - BASIC SETUP
========================================

For Express with tsoa:

```bash
npm install --save tsoa swagger-ui-express
npm install --save-dev @types/swagger-ui-express
```

Create tsoa.json:
```json
{
  "entryFile": "src/app.ts",
  "noImplicitAdditionalProperties": "throw-on-extras",
  "controllerPathGlobs": ["src/controllers/**/*.ts"],
  "spec": {
    "outputDirectory": "build",
    "specVersion": 3
  },
  "routes": {
    "routesDir": "build"
  }
}
```

Create controller with annotations:
```typescript
import { Controller, Get, Post, Route, Body, Tags } from 'tsoa';

interface User {
  id: number;
  name: string;
  email: string;
}

@Route("users")
@Tags("Users")
export class UserController extends Controller {
  /**
   * Retrieves all users
   * @summary Get all users
   */
  @Get()
  public async getUsers(): Promise<User[]> {
    // Implementation
  }

  /**
   * Creates a new user
   * @summary Create user
   */
  @Post()
  public async createUser(@Body() user: Omit<User, 'id'>): Promise<User> {
    // Implementation
  }
}
```

Generate OpenAPI spec:
```bash
npx tsoa spec-and-routes
```

Deliverable: OpenAPI spec generated

========================================
PHASE 2 - SWAGGER UI
========================================

Add Swagger UI to Express:

```typescript
import swaggerUi from 'swagger-ui-express';
import swaggerDocument from '../build/swagger.json';

app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerDocument));
```

Alternative: For NestJS:

```bash
npm install @nestjs/swagger
```

Configure in main.ts:
```typescript
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';

const config = new DocumentBuilder()
  .setTitle('API Documentation')
  .setDescription('The API description')
  .setVersion('1.0')
  .addBearerAuth()
  .build();

const document = SwaggerModule.createDocument(app, config);
SwaggerModule.setup('api-docs', app, document);
```

Deliverable: Interactive API documentation at /api-docs

========================================
PHASE 3 - ENHANCE DOCUMENTATION
========================================

Add detailed annotations:

```typescript
import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsEmail, MinLength } from 'class-validator';

export class CreateUserDto {
  @ApiProperty({ 
    description: 'User full name',
    example: 'John Doe',
    minLength: 3,
    maxLength: 100
  })
  @IsString()
  @MinLength(3)
  name: string;

  @ApiProperty({
    description: 'User email address',
    example: 'john@example.com'
  })
  @IsEmail()
  email: string;
}

@ApiTags('Users')
@Controller('users')
export class UserController {
  @Get(':id')
  @ApiOperation({ summary: 'Get user by ID' })
  @ApiParam({ name: 'id', description: 'User ID' })
  @ApiResponse({ 
    status: 200, 
    description: 'User found',
    type: User
  })
  @ApiResponse({ 
    status: 404, 
    description: 'User not found'
  })
  async getUser(@Param('id') id: string): Promise<User> {
    // Implementation
  }
}
```

Deliverable: Enhanced documentation with examples

========================================
PHASE 4 - CI INTEGRATION
========================================

Add to package.json:
```json
{
  "scripts": {
    "docs:generate": "tsoa spec-and-routes",
    "docs:lint": "swagger-cli validate build/swagger.json"
  }
}
```

Add to .github/workflows/ci.yml:
```yaml
    - name: Generate OpenAPI spec
      run: npm run docs:generate
    
    - name: Validate OpenAPI spec
      run: |
        npm install -g @apidevtools/swagger-cli
        swagger-cli validate build/swagger.json
```

Deliverable: Automated doc generation in CI

========================================
BEST PRACTICES
========================================

- Use code-first approach (annotations)
- Keep OpenAPI spec version-controlled
- Validate spec in CI
- Document all public endpoints
- Include examples and descriptions
- Document error responses
- Use semantic versioning
- Host interactive docs (Swagger UI)
- Export spec for client generation

========================================
EXECUTION
========================================

START: Set up tsoa or NestJS Swagger (Phase 1)
CONTINUE: Add Swagger UI (Phase 2)
CONTINUE: Enhance with annotations (Phase 3)
CONTINUE: Add CI validation (Phase 4)
REMEMBER: Code-first, validate in CI, keep in sync
```

---

## Quick Reference

**What you get**: Auto-generated OpenAPI documentation from TypeScript code  
**Time**: 2-3 hours  
**Output**: OpenAPI spec, Swagger UI, validated in CI
