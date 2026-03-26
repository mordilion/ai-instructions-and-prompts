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

| Pattern | Example |
|---------|---------|
| **Server Component** | `export default async function Page() { const data = await fetch(...); return <div>...</div> }` |
| **Client Component** | `'use client'; const [state, setState] = useState()` |
| **Server Action** | `'use server'; export async function action(formData: FormData) { ... }` |
| **Loading State** | `// loading.tsx: export default function Loading() { return ... }` |
| **Error Boundary** | `// error.tsx: 'use client'; export default function Error({ error, reset }) { ... }` |
| **Dynamic Route** | `// [id]/page.tsx: export default async function Page({ params }) { ... }` |
| **Route Handler** | `// api/route.ts: export async function GET() { return NextResponse.json(...) }` |

## Common AI Mistakes

| Mistake | ❌ Wrong | ✅ Correct |
|---------|---------|-----------|
| **Pages Router** | `pages/users.tsx` | `app/users/page.tsx` |
| **Client Fetch** | useEffect + fetch | Server Component |
| **Missing 'use client'** | useState without directive | Add 'use client' |
| **API Routes** | API route for mutation | Server Action |

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

## AI Self-Check

- [ ] Using App Router (not Pages Router)?
- [ ] Server Components by default?
- [ ] 'use client' for client-only features?
- [ ] Server Actions for mutations?
- [ ] loading.tsx for loading states?
- [ ] error.tsx for error boundaries?
- [ ] Dynamic imports for code splitting?
- [ ] Static generation where possible?
- [ ] No useEffect for data fetching?
- [ ] No API routes for mutations (using Server Actions)?
- [ ] Metadata API for SEO?
- [ ] Route Handlers for API endpoints?
