# Docker Containerization Process - Java

> **Purpose**: Containerize Java applications with Docker for consistent deployments

> **Key Points**: Multi-stage build, Eclipse Temurin/Azul Zulu base images, non-root user, JRE vs JDK

---

## Phase 1: Basic Dockerfile

> **ALWAYS use**: Multi-stage build (Maven/Gradle + JDK → JRE)
> **NEVER**: Use `latest` tag, include full JDK in runtime, run as root

**Dockerfile (Maven)**:
```dockerfile
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline
COPY src ./src
RUN mvn package -DskipTests

FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
RUN addgroup -g 1001 spring && adduser -u 1001 -G spring -s /bin/sh -D spring
COPY --from=build --chown=spring:spring /app/target/*.jar app.jar
USER spring
EXPOSE 8080
HEALTHCHECK CMD wget --no-verbose --tries=1 --spider http://localhost:8080/actuator/health || exit 1
ENTRYPOINT ["java", "-jar", "app.jar"]
```

**.dockerignore**:
```
target/
.mvn/
*.log
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
      - SPRING_PROFILES_ACTIVE=dev
      - SPRING_DATASOURCE_URL=jdbc:postgresql://db:5432/myapp
    depends_on:
      - db

  db:
    image: postgres:15-alpine
    environment:
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
> - Use JRE (not JDK) for runtime
> - Use Alpine for smaller images
> - Add JVM memory flags: `-Xmx512m -Xms256m`
> - Use Jib for layered builds (alternative)

**JVM Flags**:
```dockerfile
ENTRYPOINT ["java", "-Xmx512m", "-Xms256m", "-jar", "app.jar"]
```

> **Git**: `git commit -m "feat: optimize Dockerfile"`

---

## Phase 4: CI/CD Integration

**GitHub Actions**: Build, tag, push to registry

> **Git**: `git commit -m "feat: add Docker build to CI/CD"`

---

## AI Self-Check

- [ ] Multi-stage Dockerfile
- [ ] JRE runtime (not JDK)
- [ ] Non-root user
- [ ] .dockerignore configured
- [ ] docker-compose.yml created
- [ ] Health check added
- [ ] Image size <200MB
- [ ] Security scan passes

---

**Process Complete** ✅

