# Prisma ORM

> **Scope**: Apply these rules when using Prisma for database access in TypeScript projects.

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

## 8. Best Practices
- **Soft Deletes**: Add `deletedAt` field if needed.
- **Audit Fields**: Include `createdAt`, `updatedAt`.
- **Type Safety**: Use generated Prisma types.
- **Connection Pooling**: Use PgBouncer or Prisma Accelerate in production.
- **Seeding**: Create `prisma/seed.ts` for test data.

