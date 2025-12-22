# Next.js Framework

> **Scope**: Apply these rules when working with Next.js applications (App Router preferred).

## Overview

Next.js is a React metaframework providing server-side rendering, static generation, and API routes. The App Router (introduced in v13) is the recommended approach, offering React Server Components, improved layouts, and better data fetching patterns.

**Key Capabilities**:
- **Server Components**: Default rendering on server (zero JS to client)
- **File-based Routing**: Folder structure defines URL structure
- **Full-Stack**: API routes, server actions, middleware
- **Performance**: Automatic image/font optimization, streaming, caching

## Pattern Selection

### Component Type Selection
**Use Server Component (default) when**:
- Fetching data (DB, API)
- Reading environment variables
- No interactivity needed
- Want to reduce bundle size

**Use Client Component ('use client') when**:
- Using React hooks (useState, useEffect, useContext)
- Browser APIs (localStorage, window)
- Event handlers (onClick, onChange)
- Third-party libraries requiring client-side

**Example**:
```tsx
// ✅ Server Component - Default, best for data fetching
async function UserList() {
  const users = await prisma.user.findMany();  // Direct DB access
  return <ul>{users.map(u => <UserCard key={u.id} user={u} />)}</ul>;
}

// ✅ Client Component - Only when interactivity needed
'use client';
function SearchInput() {
  const [query, setQuery] = useState('');  // Needs useState
  return <input value={query} onChange={(e) => setQuery(e.target.value)} />;
}
```

### Data Fetching Strategy
**Use Server Component async/await when**:
- Initial page data
- SEO-critical content
- Data doesn't change per user

**Use Server Actions when**:
- Form submissions
- Mutations from client components
- Need to revalidate cache

**Use Route Handlers when**:
- Building an API
- Webhooks
- Third-party integrations

### Caching Strategy
**Use Static (default) when**:
- Content doesn't change often (docs, marketing)
- Can regenerate on build

**Use ISR (Incremental Static Regeneration) when**:
- Content changes periodically (blog, products)
- Set `revalidate` time in seconds

**Use Dynamic when**:
- User-specific content (dashboard)
- Real-time data
- Use `export const dynamic = 'force-dynamic'`

## 1. App Router Structure
```
app/
├── (auth)/                 # Route group (no URL impact)
│   ├── login/page.tsx
│   └── register/page.tsx
├── dashboard/
│   ├── page.tsx            # /dashboard
│   ├── layout.tsx          # Shared layout
│   └── [id]/page.tsx       # /dashboard/:id
├── api/
│   └── users/route.ts      # API route
├── layout.tsx              # Root layout
└── page.tsx                # Home page
```

## 2. Server vs Client Components
- **Default to Server**: Components are Server Components by default.
- **'use client'**: Only when needed (interactivity, hooks, browser APIs).
- **Composition**: Server components can wrap client components.

```tsx
// ✅ Good - Server Component (default)
async function UserList() {
  const users = await db.users.findMany();  // Direct DB access
  return <ul>{users.map(u => <li key={u.id}>{u.name}</li>)}</ul>;
}

// ✅ Good - Client Component (when needed)
'use client';
function Counter() {
  const [count, setCount] = useState(0);
  return <button onClick={() => setCount(c => c + 1)}>{count}</button>;
}
```

## 3. Data Fetching
- **Server Components**: Fetch directly with async/await.
- **Route Handlers**: For API endpoints (`app/api/*/route.ts`).
- **Server Actions**: For mutations from client components.

```tsx
// ✅ Good - Server Action
'use server';
export async function createUser(formData: FormData) {
  const user = await db.users.create({ data: { name: formData.get('name') } });
  revalidatePath('/users');
  return user;
}
```

## 4. Caching & Revalidation
- **Static by Default**: Pages are cached at build time.
- **revalidatePath**: Invalidate specific paths.
- **revalidateTag**: Invalidate by cache tag.
- **Dynamic**: Use `export const dynamic = 'force-dynamic'` when needed.

## 5. Routing
- **File-based**: Folder structure = URL structure.
- **Dynamic Routes**: `[param]` for dynamic segments.
- **Catch-all**: `[...slug]` for multiple segments.
- **Parallel Routes**: `@modal` for simultaneous routes.

## 6. Loading & Error States
- **loading.tsx**: Automatic loading UI.
- **error.tsx**: Error boundary per route.
- **not-found.tsx**: 404 handling.

```tsx
// app/users/loading.tsx
export default function Loading() {
  return <Skeleton />;
}
```

## 7. Metadata & SEO
- **Export metadata**: Static metadata per page.
- **generateMetadata**: Dynamic metadata.

```tsx
export const metadata: Metadata = {
  title: 'Users',
  description: 'User management page',
};
```

## Best Practices

**MUST**:
- Use Server Components by default (NO unnecessary 'use client')
- Use async/await for data fetching in Server Components
- Return Response DTOs (NEVER expose DB entities directly)
- Use revalidatePath/revalidateTag after mutations
- Use next/image for ALL images (automatic optimization)

**SHOULD**:
- Use App Router (app/) NOT Pages Router (pages/)
- Colocate components with routes (app/dashboard/components/)
- Use loading.tsx and error.tsx for each route
- Use Suspense boundaries for streaming
- Use metadata exports for SEO

**AVOID**:
- Client Components for data fetching (use Server Components)
- Fetching in useEffect (use Server Components or SWR)
- Direct DB access in client components
- Missing revalidation after mutations
- Exposing API keys to client

## Common Patterns

### Server Actions (Forms & Mutations)
```tsx
// ✅ GOOD: Server Action with revalidation
// app/actions/users.ts
'use server';
import { revalidatePath } from 'next/cache';
import { prisma } from '@/lib/db';

export async function createUser(formData: FormData) {
  const name = formData.get('name') as string;
  const email = formData.get('email') as string;
  
  // Validation
  if (!name || !email) {
    return { error: 'Name and email required' };
  }
  
  // Mutation
  const user = await prisma.user.create({
    data: { name, email },
  });
  
  // Revalidate affected pages
  revalidatePath('/users');
  return { success: true, user };
}

// Usage in Client Component
'use client';
export function UserForm() {
  return (
    <form action={createUser}>
      <input name="name" required />
      <input name="email" type="email" required />
      <button type="submit">Create</button>
    </form>
  );
}

// ❌ BAD: Using API route + fetch (unnecessary complexity)
'use client';
export function UserForm() {
  const handleSubmit = async (e) => {
    e.preventDefault();
    await fetch('/api/users', {
      method: 'POST',
      body: JSON.stringify({ name, email }),
    });  // Extra API route, no type safety, manual revalidation
  };
}
```

### Caching & Revalidation
```tsx
// ✅ GOOD: ISR with time-based revalidation
export const revalidate = 3600;  // Revalidate every hour

async function BlogPosts() {
  const posts = await fetch('https://api.blog.com/posts', {
    next: { revalidate: 3600 },  // Cache for 1 hour
  });
  return <PostList posts={posts} />;
}

// ✅ GOOD: Tag-based revalidation
async function fetchPosts() {
  return fetch('https://api.blog.com/posts', {
    next: { tags: ['posts'] },  // Tag for selective revalidation
  });
}

// In server action:
revalidateTag('posts');  // Invalidate all posts

// ❌ BAD: No caching strategy
async function fetchPosts() {
  return fetch('https://api.blog.com/posts');  // No caching config
}
```

### Server + Client Composition
```tsx
// ✅ GOOD: Server Component wraps Client Component
// app/dashboard/page.tsx (Server Component)
async function DashboardPage() {
  const user = await getUser();  // Server-side data fetching
  return (
    <div>
      <Header user={user} />
      <InteractiveDashboard userId={user.id} />  {/* Client Component */}
    </div>
  );
}

// app/dashboard/InteractiveDashboard.tsx
'use client';
export function InteractiveDashboard({ userId }: { userId: string }) {
  const [data, setData] = useState(null);
  // Interactive logic here
}

// ❌ BAD: Making entire page client component
'use client';  // Unnecessary - loses server benefits
async function DashboardPage() {
  const user = await getUser();  // Won't work - can't use async in client
}
```

## Common Anti-Patterns

**❌ Fetching in useEffect (Client Component)**:
```tsx
// BAD
'use client';
function Users() {
  const [users, setUsers] = useState([]);
  useEffect(() => {
    fetch('/api/users').then(r => r.json()).then(setUsers);
  }, []);  // Extra API route, no SSR, slower
}
```

**✅ Use Server Component instead**:
```tsx
// GOOD
async function Users() {
  const users = await prisma.user.findMany();  // Direct DB access, SSR
  return <UserList users={users} />;
}
```

**❌ Missing revalidation after mutations**:
```tsx
// BAD
'use server';
export async function deleteUser(id: string) {
  await prisma.user.delete({ where: { id } });
  // Missing revalidation! Cached pages show stale data
}
```

**✅ Always revalidate affected paths**:
```tsx
// GOOD
'use server';
export async function deleteUser(id: string) {
  await prisma.user.delete({ where: { id } });
  revalidatePath('/users');  // Update cached pages
  revalidatePath(`/users/${id}`);
}
```

## 8. Performance
- **Image Optimization**: Use `next/image` for automatic optimization
- **Font Optimization**: Use `next/font` for self-hosting
- **Static Generation**: Prefer SSG over SSR when possible
- **Streaming**: Use Suspense for progressive loading

