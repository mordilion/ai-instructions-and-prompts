# .NET Docker Containerization - Copy This Prompt

> **Type**: One-time setup process  
> **When to use**: Dockerizing .NET application  
> **Instructions**: Copy the complete prompt below and paste into your AI tool

---

## 📋 Complete Self-Contained Prompt

```
========================================
.NET DOCKER CONTAINERIZATION
========================================

CONTEXT:
You are creating Docker container for a .NET application.

CRITICAL REQUIREMENTS:
- ALWAYS use multi-stage builds
- ALWAYS use official Microsoft images
- NEVER include source files in production image
- Use .dockerignore to exclude build artifacts

========================================
CATCH-UP: READ EXISTING DOCUMENTATION
========================================

BEFORE starting, check for existing documentation:
1. Read PROJECT-MEMORY.md, LOGIC-ANOMALIES.md, DOCKER-SETUP.md if they exist

Use this to continue from where work stopped. If no docs: Start fresh.

========================================
PHASE 1 - CREATE DOCKERFILE
========================================

Create Dockerfile:

```dockerfile
# Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

COPY ["MyApp/MyApp.csproj", "MyApp/"]
RUN dotnet restore "MyApp/MyApp.csproj"

COPY . .
WORKDIR "/src/MyApp"
RUN dotnet build "MyApp.csproj" -c Release -o /app/build
RUN dotnet publish "MyApp.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app
COPY --from=build /app/publish .

EXPOSE 80
EXPOSE 443
ENTRYPOINT ["dotnet", "MyApp.dll"]
```

Create .dockerignore:
```
**/.classpath
**/.dockerignore
**/.git
**/.gitignore
**/.project
**/.settings
**/.toolstarget
**/.vs
**/.vscode
**/*.*proj.user
**/*.dbmdl
**/*.jfm
**/bin
**/charts
**/docker-compose*
**/compose*
**/Dockerfile*
**/node_modules
**/npm-debug.log
**/obj
**/secrets.dev.yaml
**/values.dev.yaml
```

Deliverable: Working Dockerfile

========================================
PHASE 2 - BUILD AND TEST
========================================

Build and test locally:

```bash
# Build
docker build -t my-dotnet-app:latest .

# Run
docker run -p 8080:80 my-dotnet-app:latest

# Test
curl http://localhost:8080
```

Deliverable: Working container locally

========================================
PHASE 3 - OPTIMIZE
========================================

Add health check:
```dockerfile
HEALTHCHECK --interval=30s --timeout=3s \
  CMD curl -f http://localhost:80/health || exit 1
```

Use build arguments:
```dockerfile
ARG DOTNET_VERSION=8.0
FROM mcr.microsoft.com/dotnet/sdk:${DOTNET_VERSION} AS build
```

Enable globalization invariant mode (smaller image):
```dockerfile
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=true
```

Deliverable: Optimized production image

========================================
BEST PRACTICES
========================================

- Use multi-stage builds (smaller images)
- Copy .csproj first (better caching)
- Use official Microsoft images
- Add health checks
- Minimize image size
- Use .dockerignore
- Tag images with versions

========================================
DOCUMENTATION
========================================

Create/update: PROJECT-MEMORY.md, LOGIC-ANOMALIES.md, DOCKER-SETUP.md

========================================
EXECUTION
========================================

START: Read existing docs (CATCH-UP section)
CONTINUE: Create Dockerfile (Phase 1)
CONTINUE: Build and test (Phase 2)
OPTIONAL: Optimize (Phase 3)
FINISH: Update all documentation files
REMEMBER: Multi-stage builds, .dockerignore, document for catch-up
```

---

## Quick Reference

**What you get**: Production-ready .NET Docker container  
**Time**: 1 hour  
**Output**: Dockerfile, .dockerignore
