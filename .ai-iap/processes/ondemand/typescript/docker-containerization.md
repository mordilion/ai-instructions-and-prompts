# Docker Containerization Process - TypeScript/Node.js

> **Purpose**: Containerize TypeScript/Node.js applications with Docker for consistent deployments

---

## Prerequisites

> **BEFORE starting**:
> - Working application with package.json
> - Docker installed locally
> - Understanding of Docker basics (images, containers, layers)

---

## Phase 1: Basic Dockerfile

### 1.1 Create Dockerfile

> **ALWAYS use**:
> - Multi-stage builds (builder → runtime)
> - Official Node.js images (node:20-alpine ⭐)
> - Non-root user
> - .dockerignore file

> **NEVER**:
> - Use `latest` tag
> - Run as root user
> - Copy node_modules from host
> - Include .git, .env, test files

**Multi-Stage Dockerfile**:
```dockerfile
# Build stage
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN npm run build

# Runtime stage
FROM node:20-alpine
WORKDIR /app
RUN addgroup -g 1001 -S nodejs && adduser -S nodejs -u 1001
COPY --from=builder --chown=nodejs:nodejs /app/dist ./dist
COPY --from=builder --chown=nodejs:nodejs /app/node_modules ./node_modules
COPY --from=builder --chown=nodejs:nodejs /app/package*.json ./
USER nodejs
EXPOSE 3000
CMD ["node", "dist/index.js"]
```

### 1.2 Create .dockerignore

> **ALWAYS exclude**:
> - node_modules
> - .git
> - .env, .env.*
> - dist, build
> - *.log
> - .vscode, .idea
> - coverage, test results

**.dockerignore**:
```
node_modules
npm-debug.log
.env
.env.*
.git
.gitignore
README.md
dist
coverage
*.test.ts
*.spec.ts
```

### 1.3 Build & Test

> **Build command**:
> ```bash
> docker build -t myapp:latest .
> docker run -p 3000:3000 myapp:latest
> ```

> **Verify**:
> - Image size reasonable (<200MB for Alpine)
> - App starts correctly
> - Health endpoint responds
> - Non-root user (check with `docker exec <container> whoami`)

### 1.4 Verify

> - Image size reasonable (<200MB for Alpine)
> - App starts correctly
> - Health endpoint responds
> - Non-root user

---

## Phase 2: Docker Compose for Local Dev

### 2.1 Docker Compose

```yaml
version: '3.8'
services:
  app:
    build: .
    ports: ["3000:3000"]
    environment:
      - DATABASE_URL=postgres://user:pass@db:5432/myapp
    depends_on: [db, redis]
    volumes: [".:/app", "/app/node_modules"]
  db:
    image: postgres:15-alpine
    environment: { POSTGRES_USER: user, POSTGRES_PASSWORD: pass, POSTGRES_DB: myapp }
    volumes: ["postgres_data:/var/lib/postgresql/data"]
  redis:
    image: redis:7-alpine
volumes: { postgres_data: }
```

**Test**: `docker-compose up -d`, verify all services start and connect

---

## Phase 3: Production Optimizations

### 3.1 Production Optimizations

> **ALWAYS**: Layer caching, multi-stage, health check, security scanning
> **Enhancements**: Add **/*.md, *.log, Dockerfile*, docker-compose* to .dockerignore

```dockerfile
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build && npm ci --only=production

FROM node:20-alpine
WORKDIR /app
RUN addgroup -g 1001 -S nodejs && adduser -S nodejs -u 1001
COPY --from=builder --chown=nodejs:nodejs /app/node_modules ./node_modules
COPY --from=builder --chown=nodejs:nodejs /app/dist ./dist
USER nodejs
EXPOSE 3000
HEALTHCHECK CMD node -e "require('http').get('http://localhost:3000/health',(r)=>process.exit(r.statusCode===200?0:1))"
CMD ["node", "dist/index.js"]
```

**Security**: Run `docker scan myapp:latest` or `trivy image myapp:latest`, fix vulnerabilities

---

## Phase 4: CI/CD Integration

### 4.1 Add Build & Push Workflow

> **ALWAYS**:
> - Build in CI on every push
> - Tag with git SHA + semantic version
> - Push to registry (Docker Hub, GHCR, ECR)
> - Scan for vulnerabilities

**GitHub Actions Example**:
```yaml
- name: Build and push Docker image
  uses: docker/build-push-action@v5
  with:
    context: .
    push: true
    tags: |
      myorg/myapp:${{ github.sha }}
      myorg/myapp:latest
    cache-from: type=gha
    cache-to: type=gha,mode=max
```

### 4.2 Test in CI

> **ALWAYS**:
> - Run health check in CI
> - Test with docker-compose
> - Validate image size limits

---

## Framework-Specific Notes

### Next.js
- Use `next build` with standalone output
- COPY standalone files + public + .next/static
- Smaller image size (~150MB)

### NestJS
- Build with `npm run build`
- Start with `node dist/main`
- Include nest CLI if needed

### Express
- Build TypeScript: `tsc`
- Start: `node dist/index.js`
- Simple, lightweight

---

## Best Practices

### Image Size
- Alpine base: ~50MB
- Node + deps: 100-200MB
- Avoid full Node image (>900MB)

### Security
> **ALWAYS**:
> - Non-root user
> - No secrets in image
> - Scan for vulnerabilities
> - Update base images regularly

### Performance
> **ALWAYS**:
> - Multi-stage builds
> - Layer caching (package.json first)
> - .dockerignore comprehensive
> - Health checks configured

---

## AI Self-Check

- [ ] Dockerfile created with multi-stage build
- [ ] Alpine base image used
- [ ] Non-root user configured
- [ ] .dockerignore comprehensive
- [ ] docker-compose.yml for local dev
- [ ] Health check instruction added
- [ ] Image size optimized (<200MB)
- [ ] Security scan passes
- [ ] CI/CD integration complete
- [ ] Documentation updated

---

## Bug Logging

> **ALWAYS log bugs found during Docker setup**:
> - Create ticket/issue for each bug
> - Tag with `bug`, `docker`, `infrastructure`
> - **NEVER fix production code during Docker setup**

---

**Process Complete** ✅


## Usage - Copy This Complete Prompt

> **Type**: One-time setup process (multi-phase)  
> **When to use**: When containerizing application with Docker

### Complete Implementation Prompt

```
CONTEXT:
You are containerizing this application with Docker.

CRITICAL REQUIREMENTS:
- ALWAYS detect language version from project files
- ALWAYS use multi-stage builds (separate build and runtime)
- ALWAYS use specific version tags (never :latest in production)
- ALWAYS run as non-root user for security
- NEVER include secrets in Docker images

IMPLEMENTATION PHASES:

PHASE 1 - DOCKERFILE:
1. Detect language version
2. Create Dockerfile with multi-stage build:
   - Build stage: Install dependencies, compile
   - Runtime stage: Copy artifacts, minimal runtime
3. Configure non-root user
4. Optimize layer caching

Deliverable: Optimized Dockerfile

PHASE 2 - DOCKER COMPOSE:
1. Create docker-compose.yml for local development
2. Configure services (app, database, cache, etc.)
3. Set up volumes for persistence
4. Configure networking

Deliverable: Local Docker environment

PHASE 3 - CI/CD INTEGRATION:
1. Build Docker image in CI pipeline
2. Tag with version/commit SHA
3. Push to container registry
4. Scan for vulnerabilities

Deliverable: Automated Docker builds

START: Detect language version, create multi-stage Dockerfile.
```
