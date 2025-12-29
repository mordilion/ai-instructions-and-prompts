# Prisma ORM

> **Scope**: Apply these rules when using Prisma for database access in TypeScript projects

## CRITICAL REQUIREMENTS (AI: Verify ALL before generating code)

> **ALWAYS**: Use singleton Prisma Client instance (prevent connection pool exhaustion)
> **ALWAYS**: Use select or include explicitly (avoid fetching unnecessary data)
> **ALWAYS**: Use transactions for multi-step operations (data consistency)
> **ALWAYS**: Abstract Prisma behind repositories (prevent leaking to services)
> **ALWAYS**: Use prepared statements (Prisma does this automatically)
> 
> **NEVER**: Create new PrismaClient() in request handlers (causes memory leaks)
> **NEVER**: Use raw queries without parameterization ($queryRaw requires Prisma.sql)
> **NEVER**: Expose Prisma types in service layer (return domain types)
> **NEVER**: Skip pagination for large datasets (causes performance issues)
> **NEVER**: Forget to handle connection errors

## Pattern Selection

| Pattern | Use When | Keywords |
|---------|----------|----------|
| select | Need specific fields only | `select: { id: true, name: true }` |
| include | Need relations | `include: { posts: true }` |
| Interactive Transaction | Complex multi-step logic | `$transaction(async (tx) => {})` |
| Batch Transaction | Independent parallel operations | `$transaction([op1, op2])` |
| Repository Pattern | Always (required) | Abstract Prisma, return domain types |

## Core Patterns

### Singleton Client Instance (REQUIRED)
```typescript
// lib/prisma.ts
import { PrismaClient } from '@prisma/client';

const globalForPrisma = globalThis as unknown as {
  prisma: PrismaClient | undefined;
};

export const prisma =
  globalForPrisma.prisma ??
  new PrismaClient({
    log: process.env.NODE_ENV === 'development' ? ['query', 'error'] : ['error'],
  });

if (process.env.NODE_ENV !== 'production') globalForPrisma.prisma = prisma;
```

### Schema Design
```prisma
model User {
  id        String   @id @default(cuid())
  email     String   @unique
  name      String?
  posts     Post[]
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  @@index([email])
  @@map("users")
}

model Post {
  id        String   @id @default(cuid())
  title     String
  author    User     @relation(fields: [authorId], references: [id], onDelete: Cascade)
  authorId  String
  
  @@index([authorId])
  @@map("posts")
}
```

### Repository Pattern (REQUIRED)
```typescript
// repositories/user.repository.ts
import { prisma } from '../lib/prisma';
import { Prisma, User } from '@prisma/client';

export class UserRepository {
  async findById(id: string): Promise<User | null> {
    return prisma.user.findUnique({ where: { id } });
  }

  async create(data: Prisma.UserCreateInput): Promise<User> {
    return prisma.user.create({ data });
  }

  async findMany(params: {
    skip?: number;
    take?: number;
    where?: Prisma.UserWhereInput;
  }): Promise<User[]> {
    return prisma.user.findMany(params);
  }
}

export const userRepository = new UserRepository();
```

### Transactions
```typescript
// Interactive transaction (for dependent operations)
const result = await prisma.$transaction(async (tx) => {
  const user = await tx.user.create({ data: { email, name } });
  await tx.post.create({ data: { title: 'Welcome', authorId: user.id } });
  return user;
});

// Batch transaction (for independent operations)
const [users, posts] = await prisma.$transaction([
  prisma.user.findMany(),
  prisma.post.findMany(),
]);
```

## Common AI Mistakes (DO NOT MAKE THESE ERRORS)

| Mistake | ❌ Wrong | ✅ Correct | Why Critical |
|---------|---------|-----------|--------------|
| **Multiple Client Instances** | `new PrismaClient()` in handlers | Singleton client | Connection pool exhaustion, memory leaks |
| **N+1 Queries** | Loop with `findUnique()` | `findMany()` with `include` | Performance degradation |
| **No Pagination** | `findMany()` without `take/skip` | Add pagination params | Memory exhaustion on large datasets |
| **Exposing Prisma Types** | Return `Prisma.User` from service | Return domain DTO | Tight coupling, breaks abstraction |
| **Missing Transactions** | Multiple writes without tx | Wrap in `$transaction()` | Data inconsistency |

### Anti-Pattern: Multiple Client Instances (FORBIDDEN)
```typescript
// ❌ WRONG - Creates new instance per request
export async function getUser(id: string) {
  const prisma = new PrismaClient();  // Memory leak!
  return prisma.user.findUnique({ where: { id } });
}

// ✅ CORRECT - Use singleton
import { prisma } from '../lib/prisma';
export async function getUser(id: string) {
  return prisma.user.findUnique({ where: { id } });
}
```

### Anti-Pattern: N+1 Queries (FORBIDDEN)
```typescript
// ❌ WRONG - N+1 queries
const users = await prisma.user.findMany();
for (const user of users) {
  user.posts = await prisma.post.findMany({ where: { authorId: user.id } });
}

// ✅ CORRECT - Single query with include
const users = await prisma.user.findMany({
  include: { posts: true }
});
```

## AI Self-Check (Verify BEFORE generating Prisma code)

- [ ] Using singleton PrismaClient? (NOT new PrismaClient() in handlers)
- [ ] Using select or include explicitly? (Avoid fetching all fields)
- [ ] Pagination for large datasets? (skip/take parameters)
- [ ] Repository pattern? (Prisma abstracted, not in services)
- [ ] Transactions for multi-step writes? ($transaction)
- [ ] Indexes for frequently queried fields? (@@index in schema)
- [ ] Cascading deletes configured? (onDelete: Cascade)
- [ ] Proper error handling? (try-catch for connection errors)
- [ ] Relations defined both sides? (User.posts, Post.author)
- [ ] Using parameterized queries? (Prisma.sql for raw queries)

## Key Commands

```bash
# Generate Prisma Client after schema changes
npx prisma generate

# Create migration
npx prisma migrate dev --name migration_name

# Apply migrations (production)
npx prisma migrate deploy

# Seed database
npx prisma db seed

# Open Prisma Studio
npx prisma studio
```

## Query Optimization

| Technique | Purpose | Example |
|-----------|---------|---------|
| select | Reduce payload | `select: { id: true, name: true }` |
| include | Eager load relations | `include: { posts: true }` |
| where | Filter results | `where: { published: true }` |
| orderBy | Sort results | `orderBy: { createdAt: 'desc' }` |
| take/skip | Pagination | `take: 10, skip: 20` |

## Key Libraries

- **@prisma/client**: Generated type-safe client
- **prisma**: CLI for migrations and schema management
- **Prisma Studio**: Visual database browser
