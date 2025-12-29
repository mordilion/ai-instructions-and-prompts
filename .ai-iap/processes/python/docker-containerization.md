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

