# Docker Containerization Process - Dart (Server-Side)

> **Purpose**: Containerize Dart server applications with Docker

> **Key Points**: Multi-stage build, dart:stable, AOT compilation, non-root user

---

## Phase 1: Basic Dockerfile

> **ALWAYS use**: Multi-stage build (Dart SDK + build → runtime)
> **NEVER**: Use `latest`, include SDK in runtime, run as root

**Dockerfile**:
```dockerfile
FROM dart:stable AS build
WORKDIR /app
COPY pubspec.* ./
RUN dart pub get
COPY . .
RUN dart compile exe bin/server.dart -o bin/server

FROM scratch
COPY --from=build /runtime/ /
COPY --from=build /app/bin/server /app/bin/
EXPOSE 8080
CMD ["/app/bin/server"]
```

**Or with Alpine (if dynamic linking needed)**:
```dockerfile
FROM dart:stable AS build
WORKDIR /app
COPY pubspec.* ./
RUN dart pub get
COPY . .
RUN dart compile exe bin/server.dart -o bin/server

FROM alpine:latest
RUN apk add --no-cache libstdc++
WORKDIR /app
RUN addgroup -g 1001 dart && adduser -u 1001 -G dart -s /bin/sh -D dart
COPY --from=build --chown=dart:dart /app/bin/server ./server
USER dart
EXPOSE 8080
HEALTHCHECK CMD wget --no-verbose --tries=1 --spider http://localhost:8080/health || exit 1
CMD ["./server"]
```

**.dockerignore**:
```
.dart_tool/
build/
.packages
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
> - Use AOT compilation (`dart compile exe`)
> - Minimal runtime (scratch or alpine)
> - Health checks configured

**Note**: Flutter apps are NOT dockerized (mobile/desktop apps). Only server-side Dart.

> **Git**: `git commit -m "feat: optimize Dockerfile"`

---

## Phase 4: CI/CD Integration

**GitHub Actions**: Build, tag, push to registry

> **Git**: `git commit -m "feat: add Docker build to CI/CD"`

---

## AI Self-Check

- [ ] Multi-stage Dockerfile
- [ ] AOT compiled executable
- [ ] Minimal runtime (scratch/alpine)
- [ ] .dockerignore configured
- [ ] docker-compose.yml created
- [ ] Health check added (if alpine)
- [ ] Image size <50MB
- [ ] Security scan passes

---

**Process Complete** ✅

