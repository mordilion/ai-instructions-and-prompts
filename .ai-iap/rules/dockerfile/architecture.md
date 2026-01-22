# Dockerfile Architecture

> **Scope**: Docker build structure and reproducibility patterns  
> **Extends**: General architecture rules

## CRITICAL REQUIREMENTS

> **ALWAYS**: Multi-stage builds for minimal images
> **ALWAYS**: Pin base images (tag/digest)
> **ALWAYS**: Deterministic build steps
> **ALWAYS**: Run as non-root user
> 
> **NEVER**: Use latest tag
> **NEVER**: Run as root in production
> **NEVER**: Include build tools in final image
> **NEVER**: Bake secrets into layers
> **NEVER**: Skip .dockerignore

## 1. Multi-stage builds
- Multi-stage builds for minimal runtime images
- Separate build and runtime dependencies

## 2. Reproducible builds
- Pin base images to specific tag/digest
- Deterministic build steps

## 3. Runtime design
- Run as non-root user
- Explicit WORKDIR, ENTRYPOINT/CMD

## AI Self-Check

- [ ] Multi-stage builds used?
- [ ] Base images pinned?
- [ ] Build steps deterministic?
- [ ] Running as non-root?
- [ ] No latest tag?
- [ ] No build tools in final image?
- [ ] No secrets in layers?
- [ ] .dockerignore present?
- [ ] Minimal final image?
- [ ] Layer caching optimized?
