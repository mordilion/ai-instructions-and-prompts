# Next.js Framework

> **Scope**: Apply these rules when working with Next.js applications (App Router preferred).

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

## 8. Performance
- **Image Optimization**: Use `next/image`.
- **Font Optimization**: Use `next/font`.
- **Static Generation**: Prefer SSG over SSR.
- **Streaming**: Use Suspense for progressive loading.

