# Java Testing Implementation - Copy This Prompt

> **Type**: One-time setup process  
> **When to use**: Setting up testing infrastructure in a Java project  
> **Instructions**: Copy the complete prompt below and paste into your AI tool

---

## 📋 Complete Self-Contained Prompt

```
========================================
JAVA TESTING IMPLEMENTATION
========================================

CONTEXT:
You are implementing comprehensive testing infrastructure for a Java project.

CRITICAL REQUIREMENTS:
- ALWAYS detect Java version from pom.xml or build.gradle
- ALWAYS match detected version in Docker/CI/CD
- NEVER fix production code bugs (log in LOGIC_ANOMALIES.md only)
- Use team's Git workflow

========================================
TECH STACK
========================================

Test Framework: JUnit 5 ⭐ (recommended) / TestNG / Spock
Assertions: AssertJ ⭐ (recommended) / Hamcrest / built-in
Mocking: Mockito ⭐ (recommended) / MockK / EasyMock

For Spring Boot:
- @SpringBootTest (integration tests)
- @WebMvcTest (controller tests)
- @DataJpaTest (repository tests)

========================================
CATCH-UP: READ EXISTING DOCUMENTATION
========================================

BEFORE starting, check for existing documentation:

1. Read PROJECT-MEMORY.md if it exists:
   - Java version used
   - Build tool (Maven/Gradle)
   - Test framework chosen (JUnit 5/TestNG)
   - Spring Boot usage
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

1. Detect Java version from pom.xml or build.gradle
2. Detect if Spring Boot project
3. Document in PROJECT-MEMORY.md
4. Choose test frameworks
5. Report findings

Deliverable: Testing strategy documented

========================================
PHASE 2 - INFRASTRUCTURE (Optional)
========================================

Create Dockerfile.tests:
```dockerfile
FROM maven:3.9-eclipse-temurin-{VERSION}
WORKDIR /app
COPY pom.xml ./
RUN mvn dependency:go-offline
COPY src ./src
RUN mvn test
```

Create docker-compose.tests.yml:
```yaml
services:
  tests:
    build: .
    command: mvn test
```

Add to CI/CD:
```yaml
- name: Test
  run: mvn clean test
```

Deliverable: Tests run in CI/CD

========================================
PHASE 3 - TEST PROJECT SETUP
========================================

1. Add dependencies (pom.xml or build.gradle):
   - junit-jupiter
   - assertj-core
   - mockito-core
   - spring-boot-starter-test (if Spring)

2. Create structure:
   src/test/java/
   ├── unit/
   ├── integration/
   └── helpers/

3. Create shared utilities:
   - TestDataBuilder
   - BaseIntegrationTest (Spring)

Deliverable: Test infrastructure ready

========================================
PHASE 4 - WRITE TESTS (Iterative)
========================================

For each component:

1. Write unit tests:
```java
@Test
@DisplayName("should handle success case")
void shouldHandleSuccessCase() {
    // Given
    var service = new MyService();
    
    // When
    var result = service.process("input");
    
    // Then
    assertThat(result).isEqualTo("expected");
}
```

2. Mock dependencies:
```java
@Mock
private Repository repository;

@InjectMocks
private Service service;

@Test
void shouldCallRepository() {
    when(repository.find(1L)).thenReturn(data);
    service.process(1L);
    verify(repository).find(1L);
}
```

3. Write integration tests (Spring):
```java
@SpringBootTest
@AutoConfigureMockMvc
class ControllerTest {
    @Autowired
    private MockMvc mockMvc;
    
    @Test
    void shouldReturnOk() throws Exception {
        mockMvc.perform(get("/api/users"))
            .andExpect(status().isOk());
    }
}
```

4. Run tests: mvn test (must pass)
5. If bugs found: Log to LOGIC-ANOMALIES.md (don't fix)
6. Update TESTING-SETUP.md with progress
7. Propose commit
8. Repeat for next component

Deliverable: All components tested

========================================
DOCUMENTATION
========================================

Create/update these files for team catch-up:

**PROJECT-MEMORY.md** (Universal):
```markdown
# Testing Implementation Memory

## Detected Versions
- Java: {version from pom.xml or build.gradle}
- Build Tool: {Maven or Gradle} v{version}
- Spring Boot: {Yes/No} v{version if yes}

## Framework Choices
- Test Framework: JUnit 5 v{version}
- Assertions: AssertJ v{version}
- Mocking: Mockito v{version}
- Why: {reasons for choices}

## Key Decisions
- Test location: src/test/java
- Mocking strategy: Mockito
- Coverage target: 80%+

## Lessons Learned
- {Challenges encountered}
- {Solutions that worked}
\```

**LOGIC-ANOMALIES.md** (Universal):
```markdown
# Logic Anomalies Found

## Bugs Discovered (Not Fixed)
1. **File**: UserService.java:45
   **Issue**: Returns null instead of throwing exception
   **Impact**: High
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
mvn test              # Maven
gradle test           # Gradle
mvn test -Dtest=UserServiceTest  # Single test
\```

## Configuration
- Framework: JUnit 5 v{version}
- Build Tool: {Maven/Gradle}
- Coverage: JaCoCo
- Target: 80%+

## Test Structure
- Unit: src/test/java/{package}/*Test.java
- Integration: src/test/java/{package}/integration/
- Utils: src/test/java/{package}/utils/

## Mocking Strategy
- HTTP: MockMvc or RestAssured
- Database: H2 in-memory or Testcontainers
- External services: Mockito

## Components Tested
- [ ] Component A
- [ ] Service B
- [x] Controller C (completed)

## Coverage Status
- Current: {percentage}%
- Target: 80%
- Reports: target/site/jacoco/index.html

## Troubleshooting
- **Tests fail**: Check dependencies in pom.xml/build.gradle
- **Mock not working**: Verify @Mock and @InjectMocks
- **Coverage too low**: Review jacoco report

## Maintenance
- Update dependencies: mvn versions:display-dependency-updates
- Run tests: mvn clean test
- Generate coverage: mvn jacoco:report
\```

========================================
EXECUTION
========================================

START: Read existing docs (CATCH-UP section)
CONTINUE: Execute Phase 1 - detect Java version, choose frameworks, create strategy
CONTINUE: Execute phases 2-4 iteratively
FINISH: Update all documentation files
REMEMBER: Use team's workflow, don't fix bugs, iterate, document for catch-up
```

---

## Quick Reference

**What you get**: Complete test infrastructure with JUnit 5, AssertJ, Mockito  
**Time**: 4-8 hours depending on project size  
**Output**: Test projects, shared utilities, comprehensive test coverage
