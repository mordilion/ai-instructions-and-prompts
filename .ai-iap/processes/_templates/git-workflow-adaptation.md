# Git Workflow Adaptation Template

> **Purpose**: Reusable guidance for adapting process workflows to your team's Git conventions

---

## Git Workflow Pattern (All Phases)

> **This guide uses example branch names. Adapt to YOUR team's conventions.**

### Example Workflows

**GitHub Flow** (feature branches):
```bash
git checkout -b feature/setup-tests
# or
git checkout -b feat/testing-infrastructure
```

**JIRA/Linear Integration**:
```bash
git checkout -b PROJ-123/test-setup
# or
git checkout -b LIN-456-implement-ci
```

**Trunk-Based Development**:
```bash
# Work directly on main with feature flags
git checkout main
# No feature branches - use feature toggles/flags
```

**GitFlow**:
```bash
git checkout -b feature/testing-phase-1 develop
```

---

## Commit Message Patterns

**Conventional Commits** (recommended):
```bash
git commit -m "test: add unit test infrastructure"
git commit -m "ci: configure github actions pipeline"
git commit -m "docs: update testing documentation"
```

**Your Team's Format**:
- Replace examples with your convention
- Use your commit prefixes (e.g., `[TEST]`, `#123`, `WIP:`)
- Follow your commit message structure

---

##Docker Adaptation

**If your project uses Docker**:
- Follow Docker sections as-is
- Adjust base images to match your organization's registry

**If you DON'T use Docker**:
- Skip `docker/` file creation sections
- Focus on CI/CD pipeline configuration
- Use your platform's native build environment

**Platform alternatives**:
- **Serverless**: Deploy directly (Vercel, Netlify, AWS Lambda)
- **PaaS**: Use platform buildpacks (Heroku, Fly.io, Railway)
- **Container registries**: Use organization's images

---

## CI/CD Platform Adaptation

**GitHub Actions** (examples in this guide):
- Use as-is if on GitHub

**GitLab CI**:
- Replace `.github/workflows/` with `.gitlab-ci.yml`
- Convert YAML syntax (jobs → stages, actions → scripts)

**Azure DevOps**:
- Replace with `azure-pipelines.yml`
- Use Azure Pipelines tasks

**Jenkins**:
- Replace with `Jenkinsfile`
- Use Jenkins pipeline syntax

**CircleCI**:
- Replace with `.circleci/config.yml`
- Convert to CircleCI orbs/commands

---

## Phase Naming Examples

This guide uses phase names like:
- `poc/test-establishing/analysis`
- `ci/basic-pipeline`

**Adapt to your convention**:
- `feature/test-analysis`
- `PROJ-123/ci-setup`
- Work on `main` (trunk-based)
- `test/phase-1-infrastructure`

**The important part**: Follow the phase sequence and objectives, not the exact branch names.

---

## Interactive vs Automated Workflow

**"Propose commit → Wait for user"** sections assume interactive development.

**For automated workflows**:
- Skip "wait for approval" steps
- Combine phases if your team prefers
- Use automated commit messages
- Rely on CI/CD for validation

---

## Key Principle

> **Follow the OBJECTIVES of each phase, not the exact PROCESS**  
> Your team's existing workflows take precedence over these examples
