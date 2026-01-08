# On-Demand Process Prompt Template

## Purpose

This template shows how to write comprehensive, self-contained prompts for on-demand process files.

**Goal**: Users should be able to copy the prompt and paste it into their AI tool without needing any other context.

---

## Template Structure

### File Header (Keep existing content)

```markdown
# {Process Name} - {Language}

> **Purpose**: {Brief description}

## Critical Requirements
...existing content...

## Tech Stack
...existing content...

## Implementation Phases
...existing content...
```

### Add Comprehensive Usage Section (At the end)

```markdown
## Usage - Copy This Complete Prompt

> **Type**: One-time setup process (iterative, multi-phase)  
> **When to use**: {When to use this process}

### Complete Implementation Prompt

‌```
CONTEXT:
You are implementing {process name} for this project.

CRITICAL REQUIREMENTS:
- {Key requirement 1}
- {Key requirement 2}
- {Key requirement 3}
- Use team's Git workflow (no prescribed branch names or commit patterns)

TECH STACK TO CHOOSE:
{List framework/tool options with recommendations}
- Option 1 ⭐ (recommended) - {why}
- Option 2 - {when to use}
- Option 3 - {when to use}

---

PHASE 1 - {PHASE NAME}:
Objective: {What to achieve}

{Step-by-step instructions}

Deliverable: {What should be completed}

---

PHASE 2 - {PHASE NAME}:
Objective: {What to achieve}

{Step-by-step instructions}

Deliverable: {What should be completed}

---

[Repeat for all phases]

---

DOCUMENTATION (create in process-docs/):
- STATUS-DETAILS.md: {Purpose}
- PROJECT_MEMORY.md: {Purpose}
- LOGIC_ANOMALIES.md: {Purpose (if applicable)}

---

START: Execute Phase 1. {Initial action to take}
‌```
```

---

## Example: Test Implementation

See `.ai-iap/processes/ondemand/dotnet/test-implementation.md` for a complete example.

**Key elements:**
- ✅ Self-contained (all context included)
- ✅ Framework choices with recommendations
- ✅ All phases with detailed steps
- ✅ Clear deliverables for each phase
- ✅ Documentation requirements
- ✅ Starting instruction

---

## Process Type Variations

### Multi-Phase Setup Processes (test-implementation, ci-cd, logging, docker, auth)

Use full template with:
- All phases detailed
- Multiple deliverables
- Iterative implementation approach
- Example: test-implementation.md

### Simple Setup Processes (linting-formatting, security-scanning, code-coverage)

Use simplified template:
- Fewer phases (usually 1-2)
- Single deliverable
- Quick setup approach

---

## Language-Specific Details to Include

### Version Detection
- **Java**: "Scan pom.xml or build.gradle for Java version"
- **.NET**: "Scan .csproj files for TargetFramework"
- **Node.js**: "Check package.json engines or .nvmrc"
- **Python**: "Check pyproject.toml or .python-version"
- **Swift**: "Check Package.swift for Swift tools version"
- **PHP**: "Check composer.json for PHP version"
- **Dart**: "Check pubspec.yaml for Dart SDK"
- **Kotlin**: "Check build.gradle.kts for Kotlin/Java versions"

### Framework Recommendations
- **Java**: JUnit 5 (⭐), TestNG, Spock
- **.NET**: xUnit (⭐), NUnit, MSTest
- **Node.js**: Jest (⭐), Vitest, Moq
- **Python**: pytest (⭐), unittest, nose2
- **Swift**: XCTest (⭐), Quick/Nimble
- **PHP**: PHPUnit (⭐), Codeception, Pest
- **Dart**: flutter_test (⭐), test package
- **Kotlin**: JUnit 5 (⭐), Kotest, Spek

---

## What NOT to Include

❌ **Don't include:**
- Specific branch names (poc/test, feat/ci, etc.)
- Specific commit messages (use "team's format")
- Prescriptive Git workflows (create branch → commit → push)
- "Act as Senior SDET" role assignments
- Assumptions about team structure

✅ **Do include:**
- Objectives (what to achieve)
- Deliverables (what to produce)
- Technical requirements
- Framework choices
- Critical warnings (NEVER fix bugs, etc.)

---

## Files to Update

### Completed (1/62)
- ✅ `.ai-iap/processes/ondemand/dotnet/test-implementation.md`

### Remaining by Process Type

**test-implementation.md (7 remaining):**
- [ ] java/test-implementation.md
- [ ] kotlin/test-implementation.md
- [ ] python/test-implementation.md
- [ ] typescript/test-implementation.md
- [ ] swift/test-implementation.md
- [ ] php/test-implementation.md
- [ ] dart/test-implementation.md

**ci-cd-github-actions.md (8 total):**
- [ ] dart/ci-cd-github-actions.md
- [ ] dotnet/ci-cd-github-actions.md
- [ ] java/ci-cd-github-actions.md
- [ ] kotlin/ci-cd-github-actions.md
- [ ] php/ci-cd-github-actions.md
- [ ] python/ci-cd-github-actions.md
- [ ] swift/ci-cd-github-actions.md
- [ ] typescript/ci-cd-github-actions.md

**Other processes (46 total):**
- [ ] code-coverage.md (8 languages)
- [ ] docker-containerization.md (8 languages)
- [ ] logging-observability.md (8 languages)
- [ ] linting-formatting.md (8 languages)
- [ ] security-scanning.md (8 languages)
- [ ] api-documentation-openapi.md (4 languages: dotnet, java, kotlin, typescript)
- [ ] authentication-jwt-oauth.md (4 languages: dotnet, java, kotlin, typescript)

---

## Batch Update Strategy

**Recommended approach:**

1. **Phase 2a**: Update all test-implementation.md files (7 files)
   - Use dotnet as template, adapt for language specifics

2. **Phase 2b**: Update all ci-cd-github-actions.md files (8 files)
   - Add comprehensive prompt at end
   - Keep existing phase content

3. **Phase 2c**: Update simpler processes (46 files)
   - Use simplified template
   - Less verbose, more direct

4. **Commit after each batch** for review

---

## Testing the Prompts

After updating, verify:
- ✅ Prompt is self-contained (no external dependencies)
- ✅ Includes all critical information
- ✅ Has clear starting instruction
- ✅ Language-specific details are accurate
- ✅ No prescriptive Git workflows
- ✅ Framework recommendations are current

---

## Next Steps

1. Update remaining 61 on-demand files using this template
2. Update setup scripts to handle permanent vs on-demand
3. Update documentation (README, CUSTOMIZATION)
4. Test with actual user workflow
