# Dart/Flutter Docker Containerization - Copy This Prompt

> **Type**: One-time setup process  
> **When to use**: Dockerizing Dart server or Flutter web app  
> **Instructions**: Copy the complete prompt below and paste into your AI tool

---

## 📋 Complete Self-Contained Prompt

```
========================================
DART/FLUTTER DOCKER CONTAINERIZATION
========================================

CONTEXT:
You are creating Docker container for a Dart server application or Flutter web app.

CRITICAL REQUIREMENTS:
- ALWAYS use multi-stage builds
- ALWAYS use official Dart images
- NEVER include source files in production image
- Use .dockerignore to exclude build artifacts

========================================
PHASE 1 - CREATE DOCKERFILE
========================================

For Dart server (e.g., shelf, aqueduct):

```dockerfile
# Build stage
FROM dart:stable AS build

WORKDIR /app
COPY pubspec.* ./
RUN dart pub get

COPY . .
RUN dart compile exe bin/server.dart -o bin/server

# Runtime stage
FROM scratch
COPY --from=build /runtime/ /
COPY --from=build /app/bin/server /app/bin/

EXPOSE 8080
CMD ["/app/bin/server"]
```

For Flutter web:

```dockerfile
FROM cirrusci/flutter:stable AS build

WORKDIR /app
COPY pubspec.* ./
RUN flutter pub get

COPY . .
RUN flutter build web --release

# Runtime stage
FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html
EXPOSE 80
```

Create .dockerignore:
```
.dart_tool/
.packages
build/
.flutter-plugins
.flutter-plugins-dependencies
.git/
coverage/
```

Deliverable: Working Dockerfile

========================================
PHASE 2 - BUILD AND TEST
========================================

Build and test locally:

```bash
# Build
docker build -t my-dart-app:latest .

# Run
docker run -p 8080:8080 my-dart-app:latest

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

Use build arguments for versions:
```dockerfile
ARG DART_VERSION=stable
FROM dart:${DART_VERSION} AS build
```

Deliverable: Optimized production image

========================================
BEST PRACTICES
========================================

- Use multi-stage builds (smaller images)
- Copy pubspec first (better caching)
- Use official Dart images
- Add health checks
- Minimize image size
- Use .dockerignore
- Tag images with versions

========================================
EXECUTION
========================================

START: Create Dockerfile (Phase 1)
CONTINUE: Build and test (Phase 2)
OPTIONAL: Optimize (Phase 3)
REMEMBER: Multi-stage builds, .dockerignore
```

---

## Quick Reference

**What you get**: Production-ready Dart/Flutter Docker container  
**Time**: 1 hour  
**Output**: Dockerfile, .dockerignore
