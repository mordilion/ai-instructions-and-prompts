# Next.js Framework

> **Scope**: Apply these rules when working with Next.js 13+ (App Router) applications
> **Applies to**: TypeScript files in Next.js projects
> **Extends**: typescript/architecture.md, typescript/frameworks/react.md
> **Precedence**: Framework rules OVERRIDE React rules for Next.js-specific patterns

## CRITICAL REQUIREMENTS (AI: Verify ALL before generating code)

> **ALWAYS**: Use App Router (NOT Pages Router for new code)
> **ALWAYS**: Use Server Components by default (opt-in to Client Components)
> **ALWAYS**: Add 'use client' directive for client-side interactivity
> **ALWAYS**: Use Server Actions for mutations (NOT API routes)
> **ALWAYS**: Implement loading.tsx and error.tsx for better UX
> 
> **NEVER**: Use Pages Router in new projects (legacy)
> **NEVER**: Fetch data in Client Components (use Server Components)
> **NEVER**: Use useEffect for data fetching (use async Server Components)
> **NEVER**: Forget 'use client' when using hooks (causes errors)
> **NEVER**: Expose secrets in Client Components (use Server Components/Actions)

## Pattern Selection

| Pattern | Use When | Keywords |
|---------|----------|----------|
| Server Components | Default for all components | No 'use client', can be async |
| Client Components | Interactivity, hooks, browser APIs | `'use client'` at top |
| Server Actions | Form submissions, mutations | `'use server'`, async functions |
| Route Handlers | API endpoints | `route.ts`, `GET`, `POST` |
| Parallel Routes | Multiple content areas | `@slot` folders |

## Core Patterns

### Server Component (Default)
```typescript
// app/users/page.tsx
export default async function UsersPage() {
  // ✅ Fetch directly in Server Component
  const users = await fetch('https://api.example.com/users').then(r => r.json())
  
  return (
    <div>
      <h1>Users</h1>
      {users.map(user => (
        <div key={user.id}>{user.name}</div>
      ))}
    </div>
  )
}
```

### Client Component (Opt-in)
```typescript
// app/components/Counter.tsx
'use client'  // ✅ Required for hooks and interactivity

import { useState } from 'react'

export function Counter() {
  const [count, setCount] = useState(0)
  
  return (
    <button onClick={() => setCount(count + 1)}>
      Count: {count}
    </button>
  )
}
```

### Server Actions (Mutations)
```typescript
// app/actions.ts
'use server'

import { revalidatePath } from 'next/cache'

export async function createUser(formData: FormData) {
  const name = formData.get('name') as string
  const email = formData.get('email') as string
  
  await db.user.create({ data: { name, email } })
  
  revalidatePath('/users')  // Revalidate cache
}

// app/users/new/page.tsx
import { createUser } from '../actions'

export default function NewUserPage() {
  return (
    <form action={createUser}>
      <input name="name" required />
      <input name="email" type="email" required />
      <button type="submit">Create</button>
    </form>
  )
}
```

### Route Handler (API Endpoint)
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

### Loading & Error States
```typescript
// app/users/loading.tsx
export default function Loading() {
  return <div>Loading users...</div>
}

// app/users/error.tsx
'use client'

export default function Error({
  error,
  reset,
}: {
  error: Error
  reset: () => void
}) {
  return (
    <div>
      <h2>Error: {error.message}</h2>
      <button onClick={reset}>Try again</button>
    </div>
  )
}
```

## Common AI Mistakes (DO NOT MAKE THESE ERRORS)

| Mistake | ❌ Wrong | ✅ Correct | Why Critical |
|---------|---------|-----------|--------------|
| **Using Pages Router** | `pages/index.tsx` for new projects | `app/page.tsx` (App Router) | Pages Router is legacy |
| **Client Component for Data** | `'use client'` + `useEffect` to fetch | Server Component with async | Extra client JS, slower |
| **Missing 'use client'** | Using hooks without directive | Add `'use client'` at top | Runtime error |
| **API Routes for Mutations** | POST to `/api/users` | Server Actions | More performant, simpler |
| **Exposing Secrets Client-Side** | API keys in Client Component | Server Component/Action | Security vulnerability |

### Anti-Pattern: Pages Router (LEGACY)
```typescript
// ❌ WRONG - Pages Router (legacy)
// pages/users.tsx
export default function Users({ users }) {
  return <div>{users.map(u => u.name)}</div>
}

export async function getServerSideProps() {
  const users = await fetch('...').then(r => r.json())
  return { props: { users } }
}

// ✅ CORRECT - App Router
// app/users/page.tsx
export default async function UsersPage() {
  const users = await fetch('...').then(r => r.json())
  return <div>{users.map(u => u.name)}</div>
}
```

### Anti-Pattern: Client-Side Data Fetching (SLOW)
```typescript
// ❌ WRONG - Fetch in Client Component
'use client'
import { useEffect, useState } from 'react'

export default function Users() {
  const [users, setUsers] = useState([])
  
  useEffect(() => {
    fetch('/api/users')
      .then(r => r.json())
      .then(setUsers)
  }, [])
  
  return <div>{users.map(u => u.name)}</div>
}

// ✅ CORRECT - Fetch in Server Component
export default async function Users() {
  const users = await fetch('...').then(r => r.json())
  return <div>{users.map(u => u.name)}</div>
}
```

## AI Self-Check (Verify BEFORE generating Next.js code)

- [ ] Using App Router? (`app/` directory, NOT `pages/`)
- [ ] Server Components by default? (No 'use client' unless needed)
- [ ] 'use client' for interactivity? (Hooks, event handlers)
- [ ] Server Actions for mutations? (NOT API routes)
- [ ] Async/await in Server Components? (Direct data fetching)
- [ ] loading.tsx and error.tsx implemented?
- [ ] No secrets in Client Components?
- [ ] Using TypeScript for type safety?
- [ ] Metadata exported from pages?
- [ ] Following Next.js file conventions?

## File Structure (App Router)

```
app/
├── layout.tsx          # Root layout (required)
├── page.tsx            # Home page
├── loading.tsx         # Loading UI
├── error.tsx           # Error UI
├── not-found.tsx       # 404 page
├── api/
│   └── users/
│       └── route.ts    # API route handler
├── users/
│   ├── page.tsx        # /users
│   ├── [id]/
│   │   └── page.tsx    # /users/:id
│   └── actions.ts      # Server actions
└── components/
    └── Counter.tsx     # Client component
```

## Data Fetching

| Method | Use Case | Location |
|--------|----------|----------|
| async Server Component | Page data | `app/page.tsx` |
| Server Action | Form mutations | `'use server'` functions |
| Route Handler | External API endpoint | `app/api/*/route.ts` |
| Client fetch | Client-side updates | Client Components |

## Caching & Revalidation

```typescript
// Force no cache
fetch(url, { cache: 'no-store' })

// Revalidate every 60 seconds
fetch(url, { next: { revalidate: 60 } })

// Revalidate path after mutation
import { revalidatePath, revalidateTag } from 'next/cache'
revalidatePath('/users')
revalidateTag('users')
```

## Key Features

- **Server Components**: Default, faster, SEO-friendly
- **Streaming**: Progressive rendering with Suspense
- **Server Actions**: Form handling without API routes
- **Image Optimization**: `next/image` component
- **Font Optimization**: `next/font` module
