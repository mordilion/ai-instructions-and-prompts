# Process Classification

## Classification Criteria

**PERMANENT (Loaded into AI):**
- Recurring/ongoing processes used throughout development
- Applied every time a specific task occurs
- Worth keeping in AI context permanently

**ON-DEMAND (Copy as prompts when needed):**
- One-time setup processes
- Iterative/multi-phase implementations
- Used once per project (or very rarely)
- Too verbose to keep loaded permanently

---

## Classification

### PERMANENT PROCESSES (8 files)

**Recurring Development Tasks:**

| Language | Process | Why Permanent |
|----------|---------|---------------|
| All 8 languages | `database-migrations.md` | Create migration every time schema changes |

**Languages with migrations:**
- dart, dotnet, java, kotlin, php, python, swift, typescript

---

### ON-DEMAND PROCESSES (62 files)

**One-Time Setup Processes:**

| Process | Languages | Why On-Demand |
|---------|-----------|---------------|
| `test-implementation.md` | All 8 | Set up testing infrastructure once, iterative phases |
| `ci-cd-github-actions.md` | All 8 | Set up CI/CD pipeline once, multi-phase |
| `code-coverage.md` | All 8 | Configure coverage tools once |
| `docker-containerization.md` | All 8 | Containerize application once |
| `logging-observability.md` | All 8 | Set up logging infrastructure once, multi-phase |
| `linting-formatting.md` | All 8 | Set up linting/formatting tools once |
| `security-scanning.md` | All 8 | Set up security scanning once |
| `api-documentation-openapi.md` | 4 (dotnet, java, kotlin, typescript) | Set up Swagger/OpenAPI once |
| `authentication-jwt-oauth.md` | 4 (dotnet, java, kotlin, typescript) | Implement authentication once, multi-phase |

**Total:** 8 permanent + 62 on-demand = 70 process files

---

## New Directory Structure

```
.ai-iap/processes/
├── permanent/           # Ongoing processes (loaded into AI tools)
│   ├── dart/
│   │   └── database-migrations.md
│   ├── dotnet/
│   │   └── database-migrations.md
│   ├── java/
│   │   └── database-migrations.md
│   ├── kotlin/
│   │   └── database-migrations.md
│   ├── php/
│   │   └── database-migrations.md
│   ├── python/
│   │   └── database-migrations.md
│   ├── swift/
│   │   └── database-migrations.md
│   └── typescript/
│       └── database-migrations.md
│
└── ondemand/           # One-time setup (copy as prompts when needed)
    ├── dart/
    │   ├── test-implementation.md
    │   ├── ci-cd-github-actions.md
    │   ├── code-coverage.md
    │   ├── docker-containerization.md
    │   ├── logging-observability.md
    │   ├── linting-formatting.md
    │   └── security-scanning.md
    ├── dotnet/
    │   ├── test-implementation.md
    │   ├── ci-cd-github-actions.md
    │   ├── code-coverage.md
    │   ├── docker-containerization.md
    │   ├── logging-observability.md
    │   ├── linting-formatting.md
    │   ├── security-scanning.md
    │   ├── api-documentation-openapi.md
    │   └── authentication-jwt-oauth.md
    └── ... (same pattern for other languages)
```
