# Dockerfile Security

> **Scope**: Container security practices  
> **Extends**: General security rules

## CRITICAL REQUIREMENTS

> **ALWAYS**: Run as non-root user
> **ALWAYS**: Official/approved base images
> **ALWAYS**: Verify checksums for downloads
> 
> **NEVER**: Bake secrets in ENV/ARG/layers
> **NEVER**: Execute remote scripts without verification
> **NEVER**: Use latest tag in production

## Best Practices

| Pattern | ❌ Wrong | ✅ Correct |
|---------|---------|-----------|
| **User** | `USER root` (default) | `USER node` or `RUN useradd` |
| **Base Image** | `FROM node:latest` | `FROM node:18.16.0-alpine` or digest |
| **Secrets** | `ENV TOKEN=abc123` | Runtime injection (K8s Secret, Docker Secrets) |
| **Downloads** | `curl | sh` | `curl -o file && sha256sum -c checksums.txt` |

## AI Self-Check

- [ ] Running as non-root?
- [ ] Base image pinned (not latest)?
- [ ] No secrets in ENV/ARG/layers?
- [ ] Downloaded artifacts verified?
- [ ] Official/approved base image?
- [ ] Capabilities dropped at runtime?

