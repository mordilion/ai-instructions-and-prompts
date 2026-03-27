# Prisma ORM

> **Scope**: Prisma for database access in TypeScript  
> **Applies to**: TypeScript files using Prisma

## CRITICAL REQUIREMENTS

> **ALWAYS**: Use singleton Prisma Client
> **ALWAYS**: Use select or include explicitly
> **ALWAYS**: Use transactions for multi-step
> **ALWAYS**: Abstract Prisma behind repositories
> **ALWAYS**: Use prepared statements (automatic)
> 
> **NEVER**: Create new PrismaClient() in handlers
> **NEVER**: Use raw queries without parameterization
> **NEVER**: Expose Prisma types in service layer
> **NEVER**: Skip pagination for large datasets
> **NEVER**: Forget connection error handling

## Core Patterns

### Singleton Client

```typescript
// lib/prisma.ts
import { PrismaClient } from '@prisma/client'

const globalForPrisma = globalThis as unknown as {
  prisma: PrismaClient | undefined
}

export const prisma =
  globalForPrisma.prisma ??
  new PrismaClient({
    log: process.env.NODE_ENV === 'development' ? ['query', 'error'] : ['error']
  })

if (process.env.NODE_ENV !== 'production') globalForPrisma.prisma = prisma
```

### CRUD Operations

```typescript
// Create
const user = await prisma.user.create({
  data: { name: 'John', email: 'john@example.com' }
})

// Read with select
const users = await prisma.user.findMany({
  select: { id: true, name: true, email: true }
})

// Read with include (relations)
const userWithPosts = await prisma.user.findUnique({
  where: { id: 1 },
  include: { posts: true }
})

// Update
await prisma.user.update({
  where: { id: 1 },
  data: { name: 'Jane' }
})

// Delete
await prisma.user.delete({ where: { id: 1 } })
```

### Transactions

```typescript
// Interactive transaction
await prisma.$transaction(async (tx) => {
  const user = await tx.user.create({ data: { name: 'John', email: 'john@example.com' } })
  await tx.post.create({ data: { title: 'Hello', authorId: user.id } })
})

// Batch transaction
await prisma.$transaction([
  prisma.user.create({ data: { name: 'John', email: 'john@example.com' } }),
  prisma.user.create({ data: { name: 'Jane', email: 'jane@example.com' } })
])
```

### Repository Pattern

```typescript
export class UserRepository {
  async create(data: CreateUserDto): Promise<User> {
    const prismaUser = await prisma.user.create({ data })
    return this.toDomain(prismaUser)
  }
  
  private toDomain(prismaUser: PrismaUser): User {
    return { id: prismaUser.id, name: prismaUser.name, email: prismaUser.email }
  }
}
```

## Common AI Mistakes

| Mistake | ❌ Wrong | ✅ Correct |
|---------|---------|-----------|
| **New Client** | `new PrismaClient()` in handler | Singleton |
| **No select/include** | Fetch all fields | Explicit fields |
| **Exposed Types** | Return Prisma types | Domain types |
| **No Pagination** | `findMany()` on 1M rows | `skip`/`take` |

## AI Self-Check

- [ ] Singleton Prisma Client?
- [ ] select/include explicit?
- [ ] Transactions for multi-step?
- [ ] Repository pattern?
- [ ] Prepared statements?
- [ ] No new Client in handlers?
- [ ] No exposed Prisma types?
- [ ] Pagination for large sets?
- [ ] Connection error handling?

## Key Features

| Feature | Purpose |
|---------|---------|
| Singleton Client | Prevent leaks |
| select/include | Specific fields |
| $transaction | Multi-step |
| Repository | Abstraction |
| Prisma.sql | Safe raw queries |

## Best Practices

**MUST**: Singleton, select/include, transactions, repository, error handling
**SHOULD**: Pagination, indexes, connection pooling
**AVOID**: New Client per request, exposed types, no pagination
