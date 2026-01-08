# Kotlin Docker Containerization - Copy This Prompt

> **Type**: One-time setup process  
> **When to use**: Dockerizing Kotlin application  
> **Instructions**: Copy the complete prompt below and paste into your AI tool

---

## 📋 Complete Self-Contained Prompt

```
========================================
KOTLIN DOCKER CONTAINERIZATION
========================================

CONTEXT:
You are creating Docker container for a Kotlin application.

CRITICAL REQUIREMENTS:
- ALWAYS use multi-stage builds
- ALWAYS use official OpenJDK/Eclipse Temurin images
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

For Gradle with Kotlin:

```dockerfile
# Build stage
FROM gradle:8-jdk17 AS build
WORKDIR /app

COPY build.gradle.kts settings.gradle.kts ./
COPY gradle ./gradle
RUN gradle dependencies --no-daemon

COPY src ./src
RUN gradle shadowJar --no-daemon

# Runtime stage
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

COPY --from=build /app/build/libs/*-all.jar app.jar

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
```

For Ktor:

```dockerfile
# Build stage
FROM gradle:8-jdk17 AS build
WORKDIR /app

COPY build.gradle.kts settings.gradle.kts ./
RUN gradle dependencies --no-daemon

COPY src ./src
RUN gradle installDist --no-daemon

# Runtime stage
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

COPY --from=build /app/build/install/app .

EXPOSE 8080
ENTRYPOINT ["./bin/app"]
```

Create .dockerignore:
```
build/
.gradle/
.git/
*.log
.idea/
*.iml
.kotlinc/
out/
```

Deliverable: Working Dockerfile

========================================
PHASE 2 - BUILD AND TEST
========================================

Build and test locally:

```bash
# Build
docker build -t my-kotlin-app:latest .

# Run
docker run -p 8080:8080 my-kotlin-app:latest

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

Optimize JVM settings for Kotlin:
```dockerfile
ENTRYPOINT ["java", \
  "-XX:+UseContainerSupport", \
  "-XX:MaxRAMPercentage=75.0", \
  "-XX:+UseG1GC", \
  "-Xms256m", \
  "-Xmx512m", \
  "-jar", "app.jar"]
```

Use GraalVM native image (optional, much smaller):
```dockerfile
FROM ghcr.io/graalvm/graalvm-ce:ol8-java17 AS build
RUN gu install native-image
RUN gradle nativeCompile

FROM alpine:latest
COPY --from=build /app/build/native/nativeCompile/app .
ENTRYPOINT ["./app"]
```

Deliverable: Optimized production image

========================================
BEST PRACTICES
========================================

- Use multi-stage builds (smaller images)
- Copy build files first (better caching)
- Use Eclipse Temurin or GraalVM images
- Add health checks
- Optimize JVM settings for containers
- Consider GraalVM native for startup speed
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
REMEMBER: Multi-stage builds, JVM optimization, document for catch-up
```

---

## Quick Reference

**What you get**: Production-ready Kotlin Docker container  
**Time**: 1 hour  
**Output**: Dockerfile, .dockerignore
