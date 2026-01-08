# Docker Containerization Process - .NET/C#

> **Purpose**: Containerize .NET applications with Docker for consistent deployments

> **Key Points**: Multi-stage build, mcr.microsoft.com/dotnet base images, non-root user, Alpine variants

---

## Phase 1: Basic Dockerfile

> **ALWAYS use**: Multi-stage build (SDK → ASP.NET runtime)
> **NEVER**: Use `latest` tag, run as root, copy bin/obj from host

**Dockerfile**:
```dockerfile
FROM mcr.microsoft.com/dotnet/sdk:8.0-alpine AS build
WORKDIR /src
COPY ["MyApp.csproj", "./"]
RUN dotnet restore
COPY . .
RUN dotnet publish -c Release -o /app/publish --no-restore

FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine
WORKDIR /app
RUN addgroup -g 1001 dotnet && adduser -u 1001 -G dotnet -s /bin/sh -D dotnet
COPY --from=build --chown=dotnet:dotnet /app/publish .
USER dotnet
EXPOSE 8080
HEALTHCHECK CMD wget --no-verbose --tries=1 --spider http://localhost:8080/health || exit 1
ENTRYPOINT ["dotnet", "MyApp.dll"]
```

**.dockerignore**:
```
bin/
obj/
*.user
*.suo
.vs/
.vscode/
*.log
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
      - ASPNETCORE_ENVIRONMENT=Development
      - ConnectionStrings__DefaultConnection=Host=db;Database=myapp;Username=user;Password=pass
    depends_on:
      - db

  db:
    image: postgres:15-alpine
    environment:
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=pass
      - POSTGRES_DB=myapp
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
```

> **Git**: `git commit -m "feat: add docker-compose"`

---

## Phase 3: Production Optimizations

> **ALWAYS**:
> - Use Alpine images (smaller)
> - Trim self-contained apps with PublishTrimmed
> - Add health checks
> - Scan with `docker scan` or Trivy

**Optimized**: Use `--self-contained false` or `-r linux-musl-x64` for Alpine

> **Git**: `git commit -m "feat: optimize Dockerfile"`

---

## Phase 4: CI/CD Integration

**GitHub Actions**: Build, tag (SHA + semver), push to registry (GHCR, ACR, ECR)

> **Git**: `git commit -m "feat: add Docker build to CI/CD"`

---

## AI Self-Check

- [ ] Multi-stage Dockerfile
- [ ] Alpine base image
- [ ] Non-root user
- [ ] .dockerignore configured
- [ ] docker-compose.yml created
- [ ] Health check added
- [ ] Image size <150MB
- [ ] Security scan passes

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
