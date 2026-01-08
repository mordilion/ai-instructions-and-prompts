# PHP Docker Containerization - Copy This Prompt

> **Type**: One-time setup process  
> **When to use**: Dockerizing PHP application  
> **Instructions**: Copy the complete prompt below and paste into your AI tool

---

## 📋 Complete Self-Contained Prompt

```
========================================
PHP DOCKER CONTAINERIZATION
========================================

CONTEXT:
You are creating Docker container for a PHP application.

CRITICAL REQUIREMENTS:
- ALWAYS use multi-stage builds
- ALWAYS use official PHP-FPM images
- NEVER include source files in build stage
- Use .dockerignore to exclude vendor

========================================
CATCH-UP: READ EXISTING DOCUMENTATION
========================================

BEFORE starting, check for existing documentation:
1. Read PROJECT-MEMORY.md, LOGIC-ANOMALIES.md, DOCKER-SETUP.md if they exist

Use this to continue from where work stopped. If no docs: Start fresh.

========================================
PHASE 1 - CREATE DOCKERFILE
========================================

For PHP with Composer:

```dockerfile
# Build stage
FROM composer:2 AS build
WORKDIR /app

COPY composer.json composer.lock ./
RUN composer install --no-dev --optimize-autoloader --no-scripts

# Runtime stage
FROM php:8.2-fpm-alpine
WORKDIR /var/www/html

# Install extensions
RUN apk add --no-cache \
    libzip-dev \
    && docker-php-ext-install pdo_mysql zip opcache

# Copy Composer dependencies
COPY --from=build /app/vendor ./vendor

# Copy application
COPY . .

# Set permissions
RUN chown -R www-data:www-data /var/www/html

EXPOSE 9000
CMD ["php-fpm"]
```

For Laravel with Nginx:

```dockerfile
# Build stage
FROM composer:2 AS build
WORKDIR /app
COPY composer.json composer.lock ./
RUN composer install --no-dev --optimize-autoloader

# Runtime stage
FROM php:8.2-fpm-alpine
WORKDIR /var/www/html

RUN apk add --no-cache nginx \
    && docker-php-ext-install pdo_mysql opcache

COPY --from=build /app/vendor ./vendor
COPY . .
COPY nginx.conf /etc/nginx/nginx.conf

RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 storage bootstrap/cache

EXPOSE 80
CMD ["sh", "-c", "php-fpm -D && nginx -g 'daemon off;'"]
```

Create .dockerignore:
```
vendor/
node_modules/
.git/
.env
storage/logs/
*.log
tests/
.phpunit.cache/
```

Deliverable: Working Dockerfile

========================================
PHASE 2 - BUILD AND TEST
========================================

Build and test locally:

```bash
# Build
docker build -t my-php-app:latest .

# Run
docker run -p 8080:80 my-php-app:latest

# Test
curl http://localhost:8080
```

Deliverable: Working container locally

========================================
PHASE 3 - OPTIMIZE
========================================

Add OPcache configuration:
```dockerfile
RUN echo "opcache.enable=1" >> /usr/local/etc/php/conf.d/opcache.ini \
    && echo "opcache.memory_consumption=128" >> /usr/local/etc/php/conf.d/opcache.ini \
    && echo "opcache.max_accelerated_files=10000" >> /usr/local/etc/php/conf.d/opcache.ini
```

Add health check:
```dockerfile
HEALTHCHECK --interval=30s --timeout=3s \
  CMD curl -f http://localhost/health || exit 1
```

Use production PHP settings:
```dockerfile
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
```

Deliverable: Optimized production image

========================================
BEST PRACTICES
========================================

- Use multi-stage builds (smaller images)
- Copy composer.json first (better caching)
- Use PHP-FPM with Nginx
- Enable OPcache in production
- Set proper file permissions
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
REMEMBER: Multi-stage builds, OPcache, permissions, document for catch-up
```

---

## Quick Reference

**What you get**: Production-ready PHP Docker container  
**Time**: 1 hour  
**Output**: Dockerfile, .dockerignore, nginx.conf
