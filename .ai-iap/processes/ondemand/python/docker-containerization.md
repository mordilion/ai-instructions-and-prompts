# Python Docker Containerization - Copy This Prompt

> **Type**: One-time setup process  
> **When to use**: Dockerizing Python application  
> **Instructions**: Copy the complete prompt below and paste into your AI tool

---

## 📋 Complete Self-Contained Prompt

```
========================================
PYTHON DOCKER CONTAINERIZATION
========================================

CONTEXT:
You are creating Docker container for a Python application.

CRITICAL REQUIREMENTS:
- ALWAYS use multi-stage builds
- ALWAYS use official Python images
- NEVER include source files in build stage
- Use .dockerignore to exclude __pycache__

========================================
CATCH-UP: READ EXISTING DOCUMENTATION
========================================

BEFORE starting, check for existing documentation:
1. Read PROJECT-MEMORY.md, LOGIC-ANOMALIES.md, DOCKER-SETUP.md if they exist

Use this to continue from where work stopped. If no docs: Start fresh.

========================================
PHASE 1 - CREATE DOCKERFILE
========================================

For Python with pip:

```dockerfile
# Build stage
FROM python:3.11-slim AS build
WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

# Runtime stage
FROM python:3.11-slim
WORKDIR /app

# Copy dependencies from build
COPY --from=build /root/.local /root/.local
ENV PATH=/root/.local/bin:$PATH

# Copy application
COPY . .

# Create non-root user
RUN useradd -m appuser && chown -R appuser:appuser /app
USER appuser

EXPOSE 8000
CMD ["python", "app.py"]
```

For Flask/Django:

```dockerfile
FROM python:3.11-slim AS build
WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

FROM python:3.11-slim
WORKDIR /app

COPY --from=build /root/.local /root/.local
ENV PATH=/root/.local/bin:$PATH
COPY . .

RUN useradd -m appuser && chown -R appuser:appuser /app
USER appuser

EXPOSE 8000
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "wsgi:app"]
```

Create .dockerignore:
```
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
venv/
env/
.env
.git/
.pytest_cache/
htmlcov/
.coverage
*.log
```

Deliverable: Working Dockerfile

========================================
PHASE 2 - BUILD AND TEST
========================================

Build and test locally:

```bash
# Build
docker build -t my-python-app:latest .

# Run
docker run -p 8000:8000 my-python-app:latest

# Test
curl http://localhost:8000
```

Deliverable: Working container locally

========================================
PHASE 3 - OPTIMIZE
========================================

Add health check:
```dockerfile
HEALTHCHECK --interval=30s --timeout=3s \
  CMD curl -f http://localhost:8000/health || exit 1
```

Use Alpine for smaller image:
```dockerfile
FROM python:3.11-alpine AS build
RUN apk add --no-cache gcc musl-dev linux-headers
```

Use Poetry for dependency management:
```dockerfile
FROM python:3.11-slim AS build
RUN pip install poetry
COPY pyproject.toml poetry.lock ./
RUN poetry export -f requirements.txt > requirements.txt
```

Deliverable: Optimized production image

========================================
BEST PRACTICES
========================================

- Use multi-stage builds (smaller images)
- Copy requirements.txt first (better caching)
- Use non-root user
- Use gunicorn/uvicorn for production
- Enable health checks
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
REMEMBER: Multi-stage builds, non-root user, document for catch-up
```

---

## Quick Reference

**What you get**: Production-ready Python Docker container  
**Time**: 1 hour  
**Output**: Dockerfile, .dockerignore
