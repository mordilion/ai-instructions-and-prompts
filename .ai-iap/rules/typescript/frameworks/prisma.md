# Prisma ORM

> **Scope**: Apply these rules when using Prisma for database access in TypeScript projects.

## Overview

Prisma is a next-generation TypeScript-first ORM that provides type-safe database access, automatic migrations, and a powerful query API. It generates a fully-typed client based on your schema.

**Key Capabilities**:
- **Type Safety**: Auto-generated TypeScript types from schema
- **Database Agnostic**: PostgreSQL, MySQL, SQLite, MongoDB
- **Migration System**: Version-controlled schema changes
- **Prisma Studio**: Visual database browser
- **Relation API**: Intuitive nested reads and writes

## Pattern Selection

### Query Strategy
**Use select when**:
- Need specific fields only
- Want to reduce payload size
- Performance matters

**Use include when**:
- Need relations
- Want full entity + related data

**AVOID**:
- Fetching all fields when not needed (use select)
- N+1 queries (use include/nested queries)

### Transaction Strategy
**Use Interactive Transactions ($transaction callback) when**:
- Complex logic with multiple operations
- Need conditional operations
- Operations depend on previous results

**Use Batch Transactions ($transaction array) when**:
- Independent parallel operations
- Want better performance

### Repository Pattern
**MUST**:
- Abstract Prisma behind repositories
- Keep Prisma imports in repository layer only
- Return domain types (NOT Prisma types in services)

## 1. Project Structure
```
prisma/
├── schema.prisma         # Database schema
├── migrations/           # Migration files
└── seed.ts               # Seed data
src/
├── lib/
│   └── prisma.ts         # Prisma client instance
├── repositories/
│   └── user.repository.ts
└── services/
    └── user.service.ts
```

## 2. Schema Design
- **Naming**: PascalCase for models, camelCase for fields.
- **Relations**: Always define both sides.
- **Indexes**: Add for frequently queried fields.

```prisma
// prisma/schema.prisma
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model User {
  id        String   @id @default(cuid())
  email     String   @unique
  name      String?
  password  String
  role      Role     @default(USER)
  posts     Post[]
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  @@index([email])
  @@map("users")
}

model Post {
  id        String   @id @default(cuid())
  title     String
  content   String?
  published Boolean  @default(false)
  author    User     @relation(fields: [authorId], references: [id], onDelete: Cascade)
  authorId  String
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  @@index([authorId])
  @@map("posts")
}

enum Role {
  USER
  ADMIN
}
```

## 3. Client Instance
- **Singleton**: Create one instance and reuse.
- **Logging**: Enable in development.

```typescript
// lib/prisma.ts
import { PrismaClient } from '@prisma/client';

const globalForPrisma = globalThis as unknown as {
  prisma: PrismaClient | undefined;
};

export const prisma =
  globalForPrisma.prisma ??
  new PrismaClient({
    log: process.env.NODE_ENV === 'development' 
      ? ['query', 'error', 'warn'] 
      : ['error'],
  });

if (process.env.NODE_ENV !== 'production') {
  globalForPrisma.prisma = prisma;
}
```

## 4. Queries
- **Select**: Only fetch needed fields.
- **Include**: Fetch relations when needed.
- **Pagination**: Always paginate large results.

```typescript
// ✅ Good - Select specific fields
const users = await prisma.user.findMany({
  select: {
    id: true,
    email: true,
    name: true,
  },
});

// ✅ Good - Include relations
const userWithPosts = await prisma.user.findUnique({
  where: { id },
  include: {
    posts: {
      where: { published: true },
      orderBy: { createdAt: 'desc' },
      take: 10,
    },
  },
});

// ✅ Good - Pagination
const posts = await prisma.post.findMany({
  where: { published: true },
  orderBy: { createdAt: 'desc' },
  skip: (page - 1) * pageSize,
  take: pageSize,
});
```

## 5. Transactions
```typescript
// ✅ Good - Interactive transaction
const result = await prisma.$transaction(async (tx) => {
  const user = await tx.user.create({
    data: { email, name },
  });

  await tx.post.create({
    data: {
      title: 'Welcome',
      authorId: user.id,
    },
  });

  return user;
});

// ✅ Good - Batch transaction
const [users, posts] = await prisma.$transaction([
  prisma.user.findMany(),
  prisma.post.findMany(),
]);
```

## 6. Repository Pattern
```typescript
// repositories/user.repository.ts
import { prisma } from '../lib/prisma';
import { Prisma, User } from '@prisma/client';

export class UserRepository {
  async findById(id: string): Promise<User | null> {
    return prisma.user.findUnique({ where: { id } });
  }

  async findByEmail(email: string): Promise<User | null> {
    return prisma.user.findUnique({ where: { email } });
  }

  async create(data: Prisma.UserCreateInput): Promise<User> {
    return prisma.user.create({ data });
  }

  async update(id: string, data: Prisma.UserUpdateInput): Promise<User> {
    return prisma.user.update({ where: { id }, data });
  }

  async delete(id: string): Promise<void> {
    await prisma.user.delete({ where: { id } });
  }

  async findMany(params: {
    skip?: number;
    take?: number;
    where?: Prisma.UserWhereInput;
    orderBy?: Prisma.UserOrderByWithRelationInput;
  }): Promise<User[]> {
    return prisma.user.findMany(params);
  }
}

export const userRepository = new UserRepository();
```

## 7. Migrations
```bash
# Create migration from schema changes
npx prisma migrate dev --name add_user_role

# Apply migrations in production
npx prisma migrate deploy

# Reset database (dev only)
npx prisma migrate reset
```

## Best Practices

**MUST**:
- Use repository pattern (NO direct Prisma in services)
- Use select for specific fields (NO fetching all when unnecessary)
- Use transactions for multi-step operations
- Use indexes on frequently queried fields
- Use pagination for large result sets

**SHOULD**:
- Use singleton pattern for Prisma client
- Use generated types (`Prisma.UserCreateInput`, etc.)
- Use soft deletes for data retention
- Include `createdAt` and `updatedAt` timestamps
- Enable query logging in development

**AVOID**:
- N+1 queries (use include/nested queries)
- Missing onDelete cascades (causes orphaned records)
- Direct Prisma usage in controllers/routes
- Fetching entire entities when not needed
- Missing transactions for related operations

## Common Patterns

### Efficient Queries
```typescript
// ✅ GOOD: Select only needed fields
const users = await prisma.user.findMany({
  select: {
    id: true,
    email: true,
    name: true,
    // NO password, internal fields
  },
  where: { role: 'ADMIN' },
  orderBy: { createdAt: 'desc' },
  take: 20,
  skip: (page - 1) * 20  // Pagination
})

// ✅ GOOD: Include relations efficiently
const userWithPosts = await prisma.user.findUnique({
  where: { id },
  include: {
    posts: {
      where: { published: true },  // Filter relations
      orderBy: { createdAt: 'desc' },
      take: 10,  // Limit relations
      select: {  // Select specific fields
        id: true,
        title: true,
        createdAt: true,
      }
    },
    _count: {  // Count only
      select: { posts: true }
    }
  }
})

// ❌ BAD: Fetching everything
const users = await prisma.user.findMany()  // All fields, no pagination

// ❌ BAD: N+1 query
const users = await prisma.user.findMany()
for (const user of users) {
  const posts = await prisma.post.findMany({
    where: { authorId: user.id }  // Separate query for each user!
  })
}
```

### Transaction Patterns
```typescript
// ✅ GOOD: Interactive transaction
const createUserWithPost = async (userData: UserData, postData: PostData) => {
  return prisma.$transaction(async (tx) => {
    // All operations succeed or all fail
    const user = await tx.user.create({
      data: { ...userData }
    })

    const post = await tx.post.create({
      data: {
        ...postData,
        authorId: user.id  // Use result from previous operation
      }
    })

    // Update user stats
    await tx.user.update({
      where: { id: user.id },
      data: { postCount: { increment: 1 } }
    })

    return { user, post }
  })  // Auto-rollback on any error
}

// ✅ GOOD: Batch transaction (independent operations)
const [users, posts, comments] = await prisma.$transaction([
  prisma.user.findMany(),
  prisma.post.findMany(),
  prisma.comment.findMany()
])  // Parallel execution

// ❌ BAD: No transaction (partial state possible)
const user = await prisma.user.create({ data: userData })
const post = await prisma.post.create({ data: postData })  // If this fails, user exists!
```

### Repository Pattern
```typescript
// ✅ GOOD: Repository abstracts Prisma
// repositories/user.repository.ts
import { prisma } from '@/lib/prisma'
import { Prisma, User } from '@prisma/client'

export interface UserRepository {
  findById(id: string): Promise<User | null>
  findByEmail(email: string): Promise<User | null>
  create(data: Prisma.UserCreateInput): Promise<User>
  update(id: string, data: Prisma.UserUpdateInput): Promise<User>
  delete(id: string): Promise<void>
}

class PrismaUserRepository implements UserRepository {
  async findById(id: string): Promise<User | null> {
    return prisma.user.findUnique({
      where: { id },
      select: {
        id: true,
        email: true,
        name: true,
        role: true,
        createdAt: true,
        updatedAt: true,
        // NO password field
      }
    })
  }

  async findByEmail(email: string): Promise<User | null> {
    return prisma.user.findUnique({ where: { email } })
  }

  async create(data: Prisma.UserCreateInput): Promise<User> {
    return prisma.user.create({ data })
  }

  async update(id: string, data: Prisma.UserUpdateInput): Promise<User> {
    return prisma.user.update({ where: { id }, data })
  }

  async delete(id: string): Promise<void> {
    await prisma.user.delete({ where: { id } })
  }
}

export const userRepository: UserRepository = new PrismaUserRepository()

// Service uses repository interface
export class UserService {
  constructor(private repo: UserRepository) {}  // NOT PrismaClient
  
  async getUser(id: string) {
    const user = await this.repo.findById(id)
    if (!user) throw new Error('User not found')
    return user
  }
}

// ❌ BAD: Service depends directly on Prisma
export class UserService {
  constructor(private prisma: PrismaClient) {}  // Tight coupling
  
  async getUser(id: string) {
    return this.prisma.user.findUnique({ where: { id } })  // Hard to test
  }
}
```

### Schema Best Practices
```prisma
// ✅ GOOD: Comprehensive schema
model User {
  id        String   @id @default(cuid())  // Use cuid() or uuid()
  email     String   @unique
  name      String?
  password  String   // Hashed
  role      Role     @default(USER)
  posts     Post[]
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
  deletedAt DateTime?  // Soft delete

  @@index([email])  // Index frequently queried fields
  @@index([deletedAt])  // For soft delete queries
  @@map("users")  // DB table name
}

model Post {
  id        String   @id @default(cuid())
  title     String
  content   String?
  published Boolean  @default(false)
  author    User     @relation(fields: [authorId], references: [id], onDelete: Cascade)  // Cascade delete
  authorId  String
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  @@index([authorId])  // Foreign key index
  @@index([published, createdAt])  // Composite index
  @@map("posts")
}

// ❌ BAD: Missing best practices
model User {
  id    Int    @id @autoincrement()  // Int IDs (sequential, predictable)
  email String
  posts Post[]  // No index, no timestamps, no soft delete
}

model Post {
  id       Int    @id @autoincrement()
  title    String
  author   User   @relation(fields: [authorId], references: [id])  // Missing onDelete
  authorId Int
  // Missing indexes, timestamps
}
```

### Soft Delete
```typescript
// ✅ GOOD: Soft delete implementation
// Prisma middleware
prisma.$use(async (params, next) => {
  // Convert delete to update
  if (params.action === 'delete') {
    params.action = 'update'
    params.args['data'] = { deletedAt: new Date() }
  }
  
  // Filter out deleted records
  if (params.action === 'findUnique' || params.action === 'findFirst') {
    params.args.where['deletedAt'] = null
  }
  
  if (params.action === 'findMany') {
    if (params.args.where) {
      if (params.args.where.deletedAt === undefined) {
        params.args.where['deletedAt'] = null
      }
    } else {
      params.args['where'] = { deletedAt: null }
    }
  }
  
  return next(params)
})

// Usage (transparent soft delete)
await prisma.user.delete({ where: { id } })  // Sets deletedAt
const users = await prisma.user.findMany()  // Excludes deleted
```

## Common Anti-Patterns

**❌ N+1 queries**:
```typescript
// BAD
const users = await prisma.user.findMany()
for (const user of users) {
  user.posts = await prisma.post.findMany({ where: { authorId: user.id } })
}
```

**✅ Use include**:
```typescript
// GOOD
const users = await prisma.user.findMany({
  include: { posts: true }  // Single query
})
```

**❌ Missing cascade deletes**:
```prisma
// BAD
model Post {
  author User @relation(fields: [authorId], references: [id])  // Missing onDelete
}
```

**✅ Define cascade behavior**:
```prisma
// GOOD
model Post {
  author User @relation(fields: [authorId], references: [id], onDelete: Cascade)
}
```

## 8. Best Practices
- **Soft Deletes**: Add `deletedAt` field with middleware
- **Audit Fields**: Include `createdAt`, `updatedAt` on all models
- **Type Safety**: Use generated Prisma types (`Prisma.UserCreateInput`)
- **Connection Pooling**: Use PgBouncer or Prisma Accelerate in production
- **Seeding**: Create `prisma/seed.ts` for test data

