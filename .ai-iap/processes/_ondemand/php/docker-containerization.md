# Docker Containerization Process - PHP

> **Purpose**: Containerize PHP applications with Docker (Apache/Nginx + PHP-FPM)

> **Key Points**: Multi-stage build, php:8.3-fpm-alpine, Composer, non-root user

---

## Phase 1: Basic Dockerfile

> **ALWAYS use**: Multi-stage build (Composer install → PHP-FPM runtime)
> **NEVER**: Use `latest`, include Composer in runtime, run as root

**Dockerfile**:
```dockerfile
FROM composer:2 AS composer
WORKDIR /app
COPY composer.json composer.lock ./
RUN composer install --no-dev --optimize-autoloader --no-scripts

FROM php:8.3-fpm-alpine
WORKDIR /var/www/html
RUN apk add --no-cache postgresql-dev && docker-php-ext-install pdo_pgsql
RUN addgroup -g 1001 www && adduser -u 1001 -G www -s /bin/sh -D www
COPY --from=composer --chown=www:www /app/vendor ./vendor
COPY --chown=www:www . .
USER www
EXPOSE 9000
HEALTHCHECK CMD php artisan health:check || exit 1
CMD ["php-fpm"]
```

**.dockerignore**:
```
vendor/
.env
.git
*.log
storage/logs/
```

> **Git**: `git commit -m "feat: add Docker containerization"`

---

## Phase 2: Docker Compose

**docker-compose.yml**:
```yaml
services:
  app:
    build: .
    volumes:
      - .:/var/www/html
    depends_on:
      - db

  webserver:
    image: nginx:alpine
    ports:
      - "8080:80"
    volumes:
      - .:/var/www/html
      - ./nginx.conf:/etc/nginx/conf.d/default.conf
    depends_on:
      - app

  db:
    image: postgres:15-alpine
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
```

> **Git**: `git commit -m "feat: add docker-compose with Nginx"`

---

## Phase 3: Production Optimizations

> **ALWAYS**:
> - Use PHP-FPM + Nginx (not Apache)
> - Optimize Composer autoloader
> - OPcache enabled
> - Cache Laravel config/routes

> **Git**: `git commit -m "feat: optimize Dockerfile"`

---

## Phase 4: CI/CD Integration

**GitHub Actions**: Build, tag, push to registry

> **Git**: `git commit -m "feat: add Docker build to CI/CD"`

---

## AI Self-Check

- [ ] Multi-stage Dockerfile
- [ ] PHP-FPM Alpine image
- [ ] Non-root user
- [ ] .dockerignore configured
- [ ] docker-compose.yml with Nginx
- [ ] Health check added
- [ ] Image size <100MB
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
