# Docker Containerization Process - Kotlin

> **Purpose**: Containerize Kotlin applications with Docker (same as Java with Kotlin-specific builds)

> **Key Points**: Multi-stage build, Gradle/Maven + JDK → JRE, non-root user

---

## Phase 1: Basic Dockerfile

> **ALWAYS use**: Multi-stage build (Gradle + JDK → JRE)
> **NEVER**: Use `latest`, include full JDK in runtime, run as root

**Dockerfile (Gradle)**:
```dockerfile
FROM gradle:8.5-jdk21 AS build
WORKDIR /app
COPY build.gradle.kts settings.gradle.kts ./
COPY src ./src
RUN gradle shadowJar --no-daemon

FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
RUN addgroup -g 1001 kotlin && adduser -u 1001 -G kotlin -s /bin/sh -D kotlin
COPY --from=build --chown=kotlin:kotlin /app/build/libs/*-all.jar app.jar
USER kotlin
EXPOSE 8080
HEALTHCHECK CMD wget --no-verbose --tries=1 --spider http://localhost:8080/health || exit 1
ENTRYPOINT ["java", "-jar", "app.jar"]
```

**.dockerignore**:
```
build/
.gradle/
*.log
.git
```

> **Git**: `git commit -m "feat: add Docker containerization"`

---

## Phase 2: Docker Compose

**docker-compose.yml** (same structure as Java)

> **Git**: `git commit -m "feat: add docker-compose"`

---

## Phase 3: Production Optimizations

> **ALWAYS**:
> - Use JRE (not JDK) for runtime
> - Alpine for smaller images
> - JVM memory flags
> - Kotlin coroutines dispatcher tuning

> **Git**: `git commit -m "feat: optimize Dockerfile"`

---

## Phase 4: CI/CD Integration

**GitHub Actions**: Build, tag, push to registry

> **Git**: `git commit -m "feat: add Docker build to CI/CD"`

---

## AI Self-Check

- [ ] Multi-stage Dockerfile
- [ ] JRE runtime
- [ ] Non-root user
- [ ] .dockerignore configured
- [ ] docker-compose.yml created
- [ ] Health check added
- [ ] Image size <200MB
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
