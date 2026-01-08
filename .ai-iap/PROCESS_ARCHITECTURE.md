# Process Architecture - Permanent vs On-Demand

## Overview

Process files are now split into two categories based on usage patterns:

1. **PERMANENT** - Loaded into AI tools permanently (recurring tasks)
2. **ON-DEMAND** - Used as copy-paste prompts when needed (one-time setups)

---

## Directory Structure

```
.ai-iap/processes/
├── permanent/           # Loaded into AI tools
│   ├── dart/
│   │   └── (none - Dart doesn't have migrations yet)
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
└── ondemand/           # Copy-paste prompts
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
    └── ... (same for other languages)
```

---

## Permanent Processes

### What Qualifies as Permanent?

- ✅ Used repeatedly throughout development lifecycle
- ✅ Applied every time a specific task occurs
- ✅ Short enough to keep loaded (< 200 lines)
- ✅ Needs consistent enforcement

### Current Permanent Processes

| Process | Languages | Use Case |
|---------|-----------|----------|
| `database-migrations.md` | 7 (dotnet, java, kotlin, php, python, swift, typescript) | Create migration every time schema changes |

### How Setup Scripts Handle Permanent Processes

```bash
# Concatenated/loaded into AI tool files
.ai-iap/processes/permanent/dotnet/database-migrations.md 
  → .cursor/rules/processes-dotnet-database-migrations.mdc
  → CLAUDE.md (if selected)
  → .github/copilot-instructions.md (if selected)
```

---

## On-Demand Processes

### What Qualifies as On-Demand?

- ✅ One-time setup (used once per project)
- ✅ Iterative/multi-phase (Phase 1 → 2 → 3 → 4)
- ✅ Verbose (200-300+ lines)
- ✅ User needs flexibility to adapt
- ✅ Would waste token budget if always loaded

### Current On-Demand Processes (62 files)

| Process | Languages | Use Case |
|---------|-----------|----------|
| `test-implementation.md` | All 8 | Set up testing infrastructure (one-time, multi-phase) |
| `ci-cd-github-actions.md` | All 8 | Set up CI/CD pipeline (one-time, multi-phase) |
| `code-coverage.md` | All 8 | Configure coverage tools (one-time) |
| `docker-containerization.md` | All 8 | Containerize application (one-time, multi-phase) |
| `logging-observability.md` | All 8 | Set up logging infrastructure (one-time, multi-phase) |
| `linting-formatting.md` | All 8 | Set up linting/formatting tools (one-time) |
| `security-scanning.md` | All 8 | Set up security scanning (one-time) |
| `api-documentation-openapi.md` | 4 (dotnet, java, kotlin, typescript) | Set up Swagger/OpenAPI (one-time) |
| `authentication-jwt-oauth.md` | 4 (dotnet, java, kotlin, typescript) | Implement auth system (one-time, multi-phase) |

### How Setup Scripts Handle On-Demand Processes

```bash
# NOT loaded into AI tools
# Just copied to project for reference
.ai-iap/processes/ondemand/dotnet/test-implementation.md 
  → Copied to project root or docs/
  → User copies prompt when ready to implement
```

---

## Usage

### For Developers Using This System

**Permanent Processes (Automatic):**
- Loaded automatically during setup
- Available in AI context at all times
- Use naturally during development

**On-Demand Processes (Manual):**
1. Find process file in `.ai-iap/processes/ondemand/{language}/`
2. Open the file and scroll to "Usage" section
3. Copy the complete prompt block
4. Paste into your AI tool
5. AI executes the implementation

---

## Benefits of This Split

### Token Efficiency
- Only 8 permanent files loaded (vs. 70 before)
- Saves ~85% of process-related token budget
- Allows more space for project-specific rules

### User Control
- User decides WHEN to start setup processes
- Can adapt prompts before using them
- No "always-on" processes that aren't needed

### Clarity
- Clear distinction between ongoing vs. one-time tasks
- Setup processes don't clutter AI context
- Easier to understand system architecture

---

## Config.json Structure

Each process in `config.json` now has:

```json
"database-migrations": {
  "name": "Database Migrations",
  "file": "database-migrations",
  "description": "Version-controlled database schema migrations",
  "type": "permanent",
  "loadIntoAI": true
},
"test-implementation": {
  "name": "Testing Implementation",
  "file": "test-implementation",
  "description": "Establish testing in existing projects",
  "type": "ondemand",
  "loadIntoAI": false
}
```

**Fields:**
- `type`: "permanent" or "ondemand"
- `loadIntoAI`: true (load into AI) or false (copy as prompt)

---

## Future Additions

### Adding a New Permanent Process

1. Create file in `.ai-iap/processes/permanent/{language}/`
2. Update `config.json`:
   - Add process definition
   - Set `"type": "permanent"`
   - Set `"loadIntoAI": true`
3. Process will be loaded into AI tools during setup

### Adding a New On-Demand Process

1. Create file in `.ai-iap/processes/ondemand/{language}/`
2. Include comprehensive "Usage" section with complete prompt
3. Update `config.json`:
   - Add process definition
   - Set `"type": "ondemand"`
   - Set `"loadIntoAI": false`
4. Process will be available as copy-paste prompt

---

## Migration Status

- ✅ Files reorganized into permanent/ and ondemand/
- ✅ config.json updated with type information
- ⏳ Setup scripts update (pending)
- ⏳ On-demand prompt rewrite (pending)
- ⏳ Documentation update (pending)
