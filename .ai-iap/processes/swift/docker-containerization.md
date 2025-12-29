# Docker Containerization Process - Swift (Server-Side)

> **Purpose**: Containerize Swift server applications (Vapor) with Docker

> **Key Points**: Multi-stage build, swift:latest → swift:slim, non-root user

---

## Phase 1: Basic Dockerfile

> **ALWAYS use**: Multi-stage build (swift builder → slim runtime)
> **NEVER**: Use untagged images, run as root, include build tools in runtime

**Dockerfile (Vapor)**:
```dockerfile
FROM swift:5.9 AS build
WORKDIR /app
COPY Package.* ./
RUN swift package resolve
COPY . .
RUN swift build -c release

FROM swift:5.9-slim
WORKDIR /app
RUN useradd -m -u 1001 vapor
COPY --from=build --chown=vapor:vapor /app/.build/release/App ./App
USER vapor
EXPOSE 8080
HEALTHCHECK CMD wget --no-verbose --tries=1 --spider http://localhost:8080/health || exit 1
ENTRYPOINT ["./App", "serve", "--hostname", "0.0.0.0", "--port", "8080"]
```

**.dockerignore**:
```
.build/
.swiftpm/
*.xcodeproj
.git
```

> **Git**: `git commit -m "feat: add Docker containerization"`

---

## Phase 2: Docker Compose

**docker-compose.yml**:
```yaml
services:
  app:
    build: .
    ports:
      - "8080:8080"
    environment:
      - DATABASE_URL=postgresql://user:pass@db:5432/myapp
    depends_on:
      - db

  db:
    image: postgres:15-alpine
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
```

> **Git**: `git commit -m "feat: add docker-compose"`

---

## Phase 3: Production Optimizations

> **ALWAYS**:
> - Use swift:slim for runtime (smaller)
> - Static linking if possible
> - Health checks configured

> **Git**: `git commit -m "feat: optimize Dockerfile"`

---

## Phase 4: CI/CD Integration

**GitHub Actions**: Build on Ubuntu (Swift support), tag, push to registry

> **Git**: `git commit -m "feat: add Docker build to CI/CD"`

---

## AI Self-Check

- [ ] Multi-stage Dockerfile
- [ ] Slim runtime image
- [ ] Non-root user
- [ ] .dockerignore configured
- [ ] docker-compose.yml created
- [ ] Health check added
- [ ] Security scan passes

---

**Process Complete** ✅

