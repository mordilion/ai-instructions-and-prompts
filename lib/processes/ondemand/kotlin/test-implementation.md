# Kotlin Testing Implementation - Copy This Prompt

> **Type**: One-time setup process  
> **When to use**: Setting up testing infrastructure in a Kotlin project  
> **Instructions**: Copy the complete prompt below and paste into your AI tool

---

## 📋 Complete Self-Contained Prompt

```
========================================
KOTLIN TESTING IMPLEMENTATION
========================================

CONTEXT:
You are implementing comprehensive testing infrastructure for a Kotlin project.

CRITICAL REQUIREMENTS:
- ALWAYS detect Kotlin and Java versions from build.gradle.kts
- ALWAYS match detected versions in Docker/CI/CD
- NEVER fix production code bugs (log in LOGIC_ANOMALIES.md only)
- Use team's Git workflow

========================================
TECH STACK
========================================

Test Framework: JUnit 5 ⭐ (recommended) / Kotest / Spek
Assertions: Kotest matchers ⭐ (recommended) / AssertJ / Strikt
Mocking: MockK ⭐ (recommended) / Mockito-Kotlin / Mockito

========================================
CATCH-UP: READ EXISTING DOCUMENTATION
========================================

BEFORE starting, check for existing documentation:

1. Read PROJECT-MEMORY.md if it exists:
   - Kotlin/Java versions used
   - Build tool (Gradle/Maven)
   - Test framework chosen
   - Key decisions made
   - Lessons learned

2. Read LOGIC-ANOMALIES.md if it exists:
   - Bugs found but not fixed
   - Code smells discovered
   - Areas needing refactoring

3. Read TESTING-SETUP.md if it exists:
   - Current test configuration
   - Classes already tested
   - Mock strategies in use

Use this information to:
- Continue from where previous work stopped
- Maintain consistency with existing decisions
- Avoid re-testing already covered classes
- Build upon existing test infrastructure

If no docs exist: Start fresh and create them.

========================================
PHASE 1 - ANALYSIS
========================================

1. Detect Kotlin and Java versions from build.gradle.kts
2. Document in PROJECT-MEMORY.md
3. Choose test frameworks
4. Report findings

Deliverable: Testing strategy documented

========================================
PHASE 2 - INFRASTRUCTURE (Optional)
========================================

Create Dockerfile.tests:
```dockerfile
FROM gradle:jdk{VERSION}-jammy
WORKDIR /app
COPY build.gradle.kts settings.gradle.kts ./
RUN gradle dependencies
COPY src ./src
RUN gradle test
```

Add to CI/CD:
```yaml
- name: Test
  run: ./gradlew test
```

Deliverable: Tests run in CI/CD

========================================
PHASE 3 - TEST PROJECT SETUP
========================================

1. Add dependencies (build.gradle.kts):
```kotlin
testImplementation("org.jetbrains.kotlin:kotlin-test-junit5")
testImplementation("io.kotest:kotest-assertions-core")
testImplementation("io.mockk:mockk")
```

2. Create structure:
   src/test/kotlin/
   ├── unit/
   ├── integration/
   └── helpers/

3. Create shared utilities (Kotlin-idiomatic)

Deliverable: Test infrastructure ready

========================================
PHASE 4 - WRITE TESTS (Iterative)
========================================

For each component:

1. Write unit tests (Kotlin style):
```kotlin
@Test
fun `should handle success case`() {
    // Given
    val service = MyService()
    
    // When
    val result = service.process("input")
    
    // Then
    result shouldBe "expected"
}
```

2. Mock dependencies (MockK):
```kotlin
@Test
fun `should call repository`() {
    val repository = mockk<Repository>()
    val service = Service(repository)
    
    every { repository.find(1L) } returns data
    
    service.process(1L)
    
    verify { repository.find(1L) }
}
```

3. Use Kotlin features:
   - Data classes for test data
   - Extension functions
   - Scope functions

4. Run tests: ./gradlew test (must pass)
5. If bugs found: Log to LOGIC_ANOMALIES.md
6. Update STATUS-DETAILS.md
7. Propose commit
8. Repeat

Deliverable: All components tested

========================================
DOCUMENTATION
========================================

Create/update these files for team catch-up:

**PROJECT-MEMORY.md** (Universal):
```markdown
# Testing Implementation Memory

## Detected Versions
- Kotlin: {version from build.gradle.kts}
- Java: {version}
- Build Tool: Gradle v{version}

## Framework Choices
- Test Framework: JUnit 5 / Kotest v{version}
- Assertions: Kotest matchers v{version}
- Mocking: MockK v{version}
- Why: {reasons for choices}

## Key Decisions
- Test location: src/test/kotlin
- Mocking strategy: MockK
- Coverage target: 80%+

## Lessons Learned
- {Challenges encountered}
- {Solutions that worked}
\```

**LOGIC-ANOMALIES.md** (Universal):
```markdown
# Logic Anomalies Found

## Bugs Discovered (Not Fixed)
1. **File**: UserService.kt:45
   **Issue**: Description
   **Impact**: Severity
   **Note**: Logged only, not fixed

## Code Smells
- {Areas needing refactoring}

## Missing Tests
- {Classes needing coverage}
\```

**TESTING-SETUP.md** (Process-specific):
```markdown
# Testing Setup Guide

## Quick Start
\```bash
./gradlew test              # Run all tests
./gradlew test --continuous # Watch mode
./gradlew test jacocoTestReport  # With coverage
\```

## Configuration
- Framework: JUnit 5 / Kotest v{version}
- Build Tool: Gradle
- Coverage: JaCoCo / Kover
- Target: 80%+

## Test Structure
- Unit: src/test/kotlin/{package}/*Test.kt
- Integration: src/test/kotlin/{package}/integration/
- Utils: src/test/kotlin/{package}/utils/

## Mocking Strategy
- HTTP: MockK or WireMock
- Database: H2 in-memory or Testcontainers
- Services: MockK

## Components Tested
- [ ] Component A
- [ ] Service B
- [x] Repository C (completed)

## Coverage Status
- Current: {percentage}%
- Target: 80%
- Reports: build/reports/jacoco/test/html/index.html

## Troubleshooting
- **MockK not working**: Verify mockk dependency
- **Coroutines fail**: Use runBlocking or runTest
- **Coverage too low**: Review jacoco report

## Maintenance
- Update dependencies: ./gradlew dependencyUpdates
- Run tests: ./gradlew test
- Generate coverage: ./gradlew jacocoTestReport
\```

========================================
EXECUTION
========================================

START: Read existing docs (CATCH-UP section)
CONTINUE: Execute Phase 1 - detect versions, choose frameworks
CONTINUE: Execute phases 2-4 iteratively
FINISH: Update all documentation files
REMEMBER: Use Kotlin idioms, don't fix bugs, iterate, document for catch-up
```

---

## Quick Reference

**What you get**: Complete test infrastructure with JUnit 5, Kotest, MockK  
**Time**: 4-8 hours depending on project size  
**Output**: Kotlin-idiomatic tests with comprehensive coverage
