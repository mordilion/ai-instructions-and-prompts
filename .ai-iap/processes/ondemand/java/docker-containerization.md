# Java Docker Containerization - Copy This Prompt

> **Type**: One-time setup process  
> **When to use**: Dockerizing Java application  
> **Instructions**: Copy the complete prompt below and paste into your AI tool

---

## 📋 Complete Self-Contained Prompt

```
========================================
JAVA DOCKER CONTAINERIZATION
========================================

CONTEXT:
You are creating Docker container for a Java application.

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

For Maven:

```dockerfile
# Build stage
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app

COPY pom.xml .
RUN mvn dependency:go-offline

COPY src ./src
RUN mvn clean package -DskipTests

# Runtime stage
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

COPY --from=build /app/target/*.jar app.jar

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
```

For Gradle:

```dockerfile
# Build stage
FROM gradle:8-jdk17 AS build
WORKDIR /app

COPY build.gradle settings.gradle ./
RUN gradle dependencies --no-daemon

COPY src ./src
RUN gradle bootJar --no-daemon

# Runtime stage
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

COPY --from=build /app/build/libs/*.jar app.jar

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
```

Create .dockerignore:
```
target/
build/
.gradle/
.mvn/
.git/
*.log
.idea/
*.iml
.settings/
.classpath
.project
```

Deliverable: Working Dockerfile

========================================
PHASE 2 - BUILD AND TEST
========================================

Build and test locally:

```bash
# Build
docker build -t my-java-app:latest .

# Run
docker run -p 8080:8080 my-java-app:latest

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
  CMD curl -f http://localhost:8080/actuator/health || exit 1
```

Optimize JVM settings:
```dockerfile
ENTRYPOINT ["java", \
  "-XX:+UseContainerSupport", \
  "-XX:MaxRAMPercentage=75.0", \
  "-XX:+UseG1GC", \
  "-jar", "app.jar"]
```

Use JLink for custom JRE (smaller image):
```dockerfile
RUN jlink --add-modules $(jdeps --print-module-deps app.jar) \
  --output /jre --strip-debug --no-man-pages --no-header-files
```

Deliverable: Optimized production image

========================================
BEST PRACTICES
========================================

- Use multi-stage builds (smaller images)
- Copy pom.xml/build.gradle first (better caching)
- Use Eclipse Temurin images
- Add health checks
- Optimize JVM settings for containers
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

**What you get**: Production-ready Java Docker container  
**Time**: 1 hour  
**Output**: Dockerfile, .dockerignore
