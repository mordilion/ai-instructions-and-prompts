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

