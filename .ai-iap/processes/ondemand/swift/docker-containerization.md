# Swift Docker Containerization - Copy This Prompt

> **Type**: One-time setup process  
> **When to use**: Dockerizing Swift server application (Vapor, Hummingbird)  
> **Instructions**: Copy the complete prompt below and paste into your AI tool

---

## 📋 Complete Self-Contained Prompt

```
========================================
SWIFT DOCKER CONTAINERIZATION
========================================

CONTEXT:
You are creating Docker container for a Swift server application.

CRITICAL REQUIREMENTS:
- ALWAYS use multi-stage builds
- ALWAYS use official Swift images
- NEVER include source files in production image
- Use .dockerignore to exclude build artifacts

========================================
PHASE 1 - CREATE DOCKERFILE
========================================

For Swift (Vapor):

```dockerfile
# Build stage
FROM swift:5.9-focal AS build
WORKDIR /build

# Copy manifests
COPY ./Package.* ./
RUN swift package resolve

# Copy source
COPY . .

# Build for release
RUN swift build -c release --static-swift-stdlib

# Runtime stage
FROM ubuntu:22.04
RUN apt-get update && apt-get install -y \
    ca-certificates \
    libcurl4 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy binary from build
COPY --from=build /build/.build/release/App .

# Create non-root user
RUN useradd -m -u 1000 appuser && chown -R appuser:appuser /app
USER appuser

EXPOSE 8080
ENTRYPOINT ["./App"]
CMD ["serve", "--env", "production", "--hostname", "0.0.0.0", "--port", "8080"]
```

For Hummingbird:

```dockerfile
FROM swift:5.9-focal AS build
WORKDIR /build

COPY ./Package.* ./
RUN swift package resolve

COPY . .
RUN swift build -c release

FROM ubuntu:22.04
RUN apt-get update && apt-get install -y \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=build /build/.build/release/MyApp .

RUN useradd -m -u 1000 appuser && chown -R appuser:appuser /app
USER appuser

EXPOSE 8080
CMD ["./MyApp"]
```

Create .dockerignore:
```
.build/
.swiftpm/
.git/
*.xcodeproj/
*.xcworkspace/
.DS_Store
```

Deliverable: Working Dockerfile

========================================
PHASE 2 - BUILD AND TEST
========================================

Build and test locally:

```bash
# Build
docker build -t my-swift-app:latest .

# Run
docker run -p 8080:8080 my-swift-app:latest

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
  CMD curl -f http://localhost:8080/health || exit 1
```

Use Amazon Linux for AWS deployments:
```dockerfile
FROM swift:5.9-amazonlinux2 AS build
# Runtime
FROM amazonlinux:2
```

Use static linking for smaller image:
```dockerfile
RUN swift build -c release --static-swift-stdlib
```

Deliverable: Optimized production image

========================================
BEST PRACTICES
========================================

- Use multi-stage builds (smaller images)
- Copy Package.swift first (better caching)
- Use non-root user
- Static link Swift stdlib
- Enable health checks
- Use .dockerignore
- Tag images with versions

========================================
EXECUTION
========================================

START: Create Dockerfile (Phase 1)
CONTINUE: Build and test (Phase 2)
OPTIONAL: Optimize (Phase 3)
REMEMBER: Multi-stage builds, static linking
```

---

## Quick Reference

**What you get**: Production-ready Swift Docker container  
**Time**: 1 hour  
**Output**: Dockerfile, .dockerignore
