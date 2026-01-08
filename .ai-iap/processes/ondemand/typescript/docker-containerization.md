# TypeScript Docker Containerization - Copy This Prompt

> **Type**: One-time setup process  
> **When to use**: Dockerizing TypeScript/Node.js application  
> **Instructions**: Copy the complete prompt below and paste into your AI tool

---

## 📋 Complete Self-Contained Prompt

```
========================================
TYPESCRIPT DOCKER CONTAINERIZATION
========================================

CONTEXT:
You are creating Docker container for a TypeScript/Node.js application.

CRITICAL REQUIREMENTS:
- ALWAYS use multi-stage builds
- ALWAYS use official Node.js images
- NEVER include source files in production image
- Use .dockerignore to exclude node_modules

========================================
PHASE 1 - CREATE DOCKERFILE
========================================

For TypeScript with npm:

```dockerfile
# Build stage
FROM node:20-alpine AS build
WORKDIR /app

# Copy package files
COPY package*.json ./
RUN npm ci

# Copy source and build
COPY . .
RUN npm run build

# Runtime stage
FROM node:20-alpine
WORKDIR /app

# Copy package files and install production deps only
COPY package*.json ./
RUN npm ci --only=production

# Copy built application
COPY --from=build /app/dist ./dist

# Create non-root user
RUN addgroup -g 1001 -S nodejs && adduser -S nodejs -u 1001
USER nodejs

EXPOSE 3000
CMD ["node", "dist/index.js"]
```

For Next.js:

```dockerfile
FROM node:20-alpine AS build
WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build

FROM node:20-alpine
WORKDIR /app

ENV NODE_ENV=production
COPY --from=build /app/next.config.js ./
COPY --from=build /app/public ./public
COPY --from=build /app/.next ./.next
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/package.json ./

RUN addgroup -g 1001 -S nodejs && adduser -S nodejs -u 1001
USER nodejs

EXPOSE 3000
CMD ["npm", "start"]
```

Create .dockerignore:
```
node_modules/
npm-debug.log
.npm/
.git/
.env
.env.local
dist/
build/
coverage/
.next/
.nuxt/
```

Deliverable: Working Dockerfile

========================================
PHASE 2 - BUILD AND TEST
========================================

Build and test locally:

```bash
# Build
docker build -t my-node-app:latest .

# Run
docker run -p 3000:3000 my-node-app:latest

# Test
curl http://localhost:3000
```

Deliverable: Working container locally

========================================
PHASE 3 - OPTIMIZE
========================================

Add health check:
```dockerfile
HEALTHCHECK --interval=30s --timeout=3s \
  CMD node -e "require('http').get('http://localhost:3000/health', (r) => { process.exit(r.statusCode === 200 ? 0 : 1) })"
```

Use pnpm for faster installs:
```dockerfile
FROM node:20-alpine AS build
RUN corepack enable && corepack prepare pnpm@latest --activate
COPY pnpm-lock.yaml ./
RUN pnpm fetch
RUN pnpm install --offline
```

Use distroless for security:
```dockerfile
FROM gcr.io/distroless/nodejs20-debian11
COPY --from=build /app/dist /app/dist
CMD ["/app/dist/index.js"]
```

Deliverable: Optimized production image

========================================
BEST PRACTICES
========================================

- Use multi-stage builds (smaller images)
- Copy package.json first (better caching)
- Use non-root user
- Install only production dependencies
- Use Alpine or distroless images
- Enable health checks
- Use .dockerignore
- Tag images with versions

========================================
EXECUTION
========================================

START: Create Dockerfile (Phase 1)
CONTINUE: Build and test (Phase 2)
OPTIONAL: Optimize (Phase 3)
REMEMBER: Multi-stage builds, production deps only
```

---

## Quick Reference

**What you get**: Production-ready TypeScript Docker container  
**Time**: 1 hour  
**Output**: Dockerfile, .dockerignore
