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

### Branch Strategy
```
main → docker/basic
```

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

### 1.4 Commit & Verify

> **Git workflow**:
> ```
> git add Dockerfile .dockerignore
> git commit -m "feat: add Docker containerization"
> git push origin docker/basic
> ```

---

## Phase 2: Docker Compose for Local Dev

### Branch Strategy
```
main → docker/compose
```

### 2.1 Create docker-compose.yml

> **ALWAYS include**:
> - App service
> - Database service (PostgreSQL/MySQL)
> - Redis/Cache service (if needed)
> - Volumes for data persistence
> - Networks for service isolation
> - Environment variables

**docker-compose.yml**:
```yaml
version: '3.8'

services:
  app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=development
      - DATABASE_URL=postgres://user:pass@db:5432/myapp
      - REDIS_URL=redis://redis:6379
    depends_on:
      - db
      - redis
    volumes:
      - .:/app
      - /app/node_modules
    command: npm run dev

  db:
    image: postgres:15-alpine
    environment:
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=pass
      - POSTGRES_DB=myapp
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"

volumes:
  postgres_data:
```

### 2.2 Test Compose

> **Commands**:
> ```bash
> docker-compose up -d
> docker-compose logs -f app
> docker-compose down
> ```

> **Verify**:
> - All services start
> - App connects to database
> - Redis accessible
> - Hot reload works (if dev mode)

### 2.3 Commit & Verify

> **Git workflow**:
> ```
> git add docker-compose.yml
> git commit -m "feat: add docker-compose for local development"
> git push origin docker/compose
> ```

---

## Phase 3: Production Optimizations

### Branch Strategy
```
main → docker/production
```

### 3.1 Optimize Dockerfile

> **ALWAYS include**:
> - Layer caching (COPY package*.json before source)
> - Multi-stage with minimal runtime
> - Health check instruction
> - Proper signal handling (SIGTERM)

**Optimized Dockerfile**:
```dockerfile
FROM node:20-alpine AS deps
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:20-alpine
WORKDIR /app
RUN addgroup -g 1001 -S nodejs && adduser -S nodejs -u 1001
COPY --from=deps --chown=nodejs:nodejs /app/node_modules ./node_modules
COPY --from=builder --chown=nodejs:nodejs /app/dist ./dist
COPY --from=builder --chown=nodejs:nodejs /app/package*.json ./
USER nodejs
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s \  
  CMD node -e "require('http').get('http://localhost:3000/health', (r) => process.exit(r.statusCode === 200 ? 0 : 1))"
CMD ["node", "dist/index.js"]
```

### 3.2 Add .dockerignore Enhancements

> **Add**:
> - **/*.md
> - *.log
> - Dockerfile*
> - docker-compose*

### 3.3 Security Scanning

> **ALWAYS scan images**:
> ```bash
> docker scan myapp:latest
> # Or: trivy image myapp:latest
> ```

> **Fix vulnerabilities**:
> - Update base image
> - Update dependencies
> - Remove unnecessary packages

### 3.4 Commit & Verify

> **Git workflow**:
> ```
> git add Dockerfile .dockerignore
> git commit -m "feat: optimize Dockerfile for production"
> git push origin docker/production
> ```

---

## Phase 4: CI/CD Integration

### Branch Strategy
```
main → docker/ci-cd
```

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

### 4.3 Commit & Verify

> **Git workflow**:
> ```
> git add .github/workflows/docker.yml
> git commit -m "feat: add Docker build to CI/CD"
> git push origin docker/ci-cd
> ```

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

## Final Commit

```bash
git checkout main
git merge docker/ci-cd
git tag -a v1.0.0-docker -m "Docker containerization complete"
git push origin main --tags
```

---

**Process Complete** ✅

