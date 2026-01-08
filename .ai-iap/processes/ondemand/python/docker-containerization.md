# Docker Containerization Process - Python

> **Purpose**: Containerize Python applications with Docker for consistent deployments

> **Key Points**: Multi-stage build, python:3.12-slim, non-root user, pip vs poetry

---

## Phase 1: Basic Dockerfile

> **ALWAYS use**: Multi-stage build, slim or alpine base
> **NEVER**: Use `latest`, copy entire venv from host, run as root

**Dockerfile**:
```dockerfile
FROM python:3.12-slim AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

FROM python:3.12-slim
WORKDIR /app
RUN addgroup --gid 1001 python && adduser --uid 1001 --gid 1001 --disabled-password python
COPY --from=builder --chown=python:python /root/.local /home/python/.local
COPY --chown=python:python . .
USER python
ENV PATH=/home/python/.local/bin:$PATH
EXPOSE 8000
HEALTHCHECK CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')" || exit 1
CMD ["python", "-m", "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

**.dockerignore**:
```
__pycache__/
*.pyc
.venv/
.env
.git
*.log
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
      - "8000:8000"
    environment:
      - DATABASE_URL=postgresql://user:pass@db:5432/myapp
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
> - Use python:3.12-slim (not alpine, C extension issues)
> - Pin dependencies in requirements.txt
> - Use gunicorn/uvicorn workers: `--workers 4`
> - Add health checks

> **Git**: `git commit -m "feat: optimize Dockerfile"`

---

## Phase 4: CI/CD Integration

**GitHub Actions**: Build, tag, push to registry

> **Git**: `git commit -m "feat: add Docker build to CI/CD"`

---

## AI Self-Check

- [ ] Multi-stage Dockerfile
- [ ] Slim base image
- [ ] Non-root user
- [ ] .dockerignore configured
- [ ] docker-compose.yml created
- [ ] Health check added
- [ ] Image size <150MB
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
