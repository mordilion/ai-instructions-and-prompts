# Next.js Framework

> **Scope**: Next.js 13+ (App Router)  
> **Applies to**: TypeScript files in Next.js projects
> **Extends**: typescript/architecture.md, typescript/frameworks/react.md

## CRITICAL REQUIREMENTS

> **ALWAYS**: Use App Router (NOT Pages Router)
> **ALWAYS**: Server Components by default
> **ALWAYS**: Add 'use client' for interactivity
> **ALWAYS**: Use Server Actions for mutations
> **ALWAYS**: Implement loading.tsx and error.tsx
> 
> **NEVER**: Use Pages Router in new projects
> **NEVER**: Fetch data in Client Components
> **NEVER**: Use useEffect for data fetching
> **NEVER**: Forget 'use client' when using hooks
> **NEVER**: Expose secrets in Client Components

## Core Patterns

### Server Component (Default)

```typescript
// app/users/page.tsx
export default async function UsersPage() {
  const users = await fetch('https://api.example.com/users').then(r => r.json())
  
  return (
    <div>
      <h1>Users</h1>
      {users.map(user => <div key={user.id}>{user.name}</div>)}
    </div>
  )
}
```

### Client Component

```typescript
// app/components/Counter.tsx
'use client'  // Required for hooks

import { useState } from 'react'

export default function Counter() {
  const [count, setCount] = useState(0)
  return <button onClick={() => setCount(count + 1)}>Count: {count}</button>
}
```

### Server Action

```typescript
// app/actions.ts
'use server'

export async function createUser(formData: FormData) {
  const name = formData.get('name')
  await db.user.create({ data: { name } })
  revalidatePath('/users')
}

// app/users/page.tsx
export default function CreateUserForm() {
  return (
    <form action={createUser}>
      <input name="name" />
      <button type="submit">Create</button>
    </form>
  )
}
```

### Loading State

```typescript
// app/users/loading.tsx
export default function Loading() {
  return <div>Loading users...</div>
}
```

### Error Boundary

```typescript
// app/users/error.tsx
'use client'

export default function Error({ error, reset }: { error: Error; reset: () => void }) {
  return (
    <div>
      <h2>Error: {error.message}</h2>
      <button onClick={reset}>Try again</button>
    </div>
  )
}
```

### Dynamic Route

```typescript
// app/users/[id]/page.tsx
export default async function UserPage({ params }: { params: { id: string } }) {
  const user = await fetch(`https://api.example.com/users/${params.id}`).then(r => r.json())
  return <div>{user.name}</div>
}
```

### Route Handler

```typescript
// app/api/users/route.ts
import { NextResponse } from 'next/server'

export async function GET() {
  const users = await db.user.findMany()
  return NextResponse.json(users)
}

export async function POST(request: Request) {
  const body = await request.json()
  const user = await db.user.create({ data: body })
  return NextResponse.json(user, { status: 201 })
}
```

## Common AI Mistakes

| Mistake | ❌ Wrong | ✅ Correct |
|---------|---------|-----------|
| **Pages Router** | `pages/users.tsx` | `app/users/page.tsx` |
| **Client Fetch** | useEffect + fetch | Server Component |
| **Missing 'use client'** | useState without directive | Add 'use client' |
| **API Routes** | API route for mutation | Server Action |

## AI Self-Check

- [ ] Using App Router?
- [ ] Server Components default?
- [ ] 'use client' when needed?
- [ ] Server Actions for mutations?
- [ ] loading.tsx implemented?
- [ ] error.tsx implemented?
- [ ] No useEffect for data?
- [ ] No secrets in client?
- [ ] Proper async/await?

## Key Features

| Feature | Purpose |
|---------|---------|
| Server Components | SSR by default |
| Server Actions | Form mutations |
| Route Handlers | API endpoints |
| loading.tsx | Loading states |
| error.tsx | Error boundaries |

## Best Practices

**MUST**: App Router, Server Components, 'use client' for hooks, Server Actions
**SHOULD**: loading.tsx, error.tsx, dynamic imports, static generation
**AVOID**: Pages Router, client-side fetching, useEffect for data, API routes for mutations
