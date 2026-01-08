# Java Testing Implementation Process

> **Purpose**: Establish comprehensive testing infrastructure for Java projects

## Critical Requirements

> **ALWAYS**: Detect Java version from `pom.xml` or `build.gradle`
> **ALWAYS**: Match detected version in Docker images, pipelines, and test configuration
> **ALWAYS**: Use your team's workflow for branching and commits (adapt as needed)
> **NEVER**: Fix production code bugs found during testing (log only)

## Workflow Adaptation

> **IMPORTANT**: This guide focuses on OBJECTIVES, not specific workflows.  
> **Your team's conventions take precedence** for Git, commits, Docker, CI/CD.

## Tech Stack

**Required**:
- **Test Framework**: JUnit 5 (Jupiter)
- **Assertions**: AssertJ
- **Mocking**: Mockito
- **Spring Testing**: @SpringBootTest, MockMvc (if Spring project)
- **Runtime**: Match detected Java version

**Forbidden**:
- JUnit 4 (migrate if found)
- TestNG (migrate if found)

## Infrastructure Templates

> **ALWAYS**: Replace `{JAVA_VERSION}` with detected version before creating files

**File**: `docker/Dockerfile.tests`
```dockerfile
FROM maven:3.9-eclipse-temurin-{JAVA_VERSION} AS build
WORKDIR /app
COPY pom.xml ./
RUN mvn dependency:go-offline
COPY src ./src
RUN mvn package -DskipTests

FROM build AS test
WORKDIR /app
RUN mkdir -p /test-results /coverage
```

**File**: `docker/docker-compose.tests.yml`
```yaml
services:
  tests:
    build:
      context: ..
      dockerfile: docker/Dockerfile.tests
    command: mvn test -Dmaven.test.failure.ignore=false
    volumes:
      - ../target/surefire-reports:/test-results
      - ../target/site/jacoco:/coverage
```

**CI/CD Integration**:

> **NEVER**: Overwrite existing pipeline. Merge this step only.

**GitHub Actions**:
```yaml
- name: Run Tests
  run: |
    mvn clean test
    mvn jacoco:report
  env:
    JAVA_VERSION: {JAVA_VERSION}
```

**GitLab CI**:
```yaml
test:
  image: maven:3.9-eclipse-temurin-{JAVA_VERSION}
  script:
    - mvn clean test
    - mvn jacoco:report
  artifacts:
    reports:
      junit: target/surefire-reports/TEST-*.xml
    paths:
      - target/site/jacoco/
```

## Implementation Phases

> **For each phase**: Use your team's workflow

### Phase 1: Analysis

**Objective**: Understand project structure and choose test framework

1. Detect Java version from `pom.xml` or `build.gradle`
2. Identify if Spring Boot project
3. Analyze existing test framework (JUnit 4/5, TestNG)

**Deliverable**: Testing strategy documented

### Phase 2: Infrastructure (Optional)

**Objective**: Set up test infrastructure (skip if using cloud CI/CD)

1. Create Docker test files (if using Docker)
2. Add/update CI/CD pipeline test step
3. Configure test reporting

**Deliverable**: Tests can run in CI/CD

### Phase 3: Framework Setup

**Objective**: Install and configure test dependencies

1. Add dependencies: JUnit 5, AssertJ, Mockito
2. Configure Surefire and JaCoCo plugins
3. Migrate from JUnit 4 if needed

**Deliverable**: Test framework ready

### Phase 4: Test Structure

**Objective**: Establish test directory organization

1. Create test structure: `src/test/java/.../unit/`, `integration/`, `helpers/`
2. Create base test classes and utilities: `AbstractUnitTest`, `TestDataBuilder`, `MockDataFactory`

**Deliverable**: Test structure in place

### Phase 5: Test Implementation (Iterative)

**Objective**: Write tests for all components

**For each component**:
1. Understand component behavior
2. Write tests (unit/integration)
3. Ensure tests pass
4. Log bugs found (don't fix production code)

**Continue until**: All critical components tested

## Test Patterns

### Unit Test Pattern
```java
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.DisplayName;
import static org.assertj.core.api.Assertions.*;

@DisplayName("MyService Unit Tests")
class MyServiceTest {
    
    @Test
    @DisplayName("should handle success case")
    void shouldHandleSuccessCase() {
        // Given
        MyService service = new MyService();
        
        // When
        String result = service.doSomething("input");
        
        // Then
        assertThat(result).isEqualTo("expected");
    }
    
    @Test
    @DisplayName("should throw exception for invalid input")
    void shouldThrowExceptionForInvalidInput() {
        // Given
        MyService service = new MyService();
        
        // When/Then
        assertThatThrownBy(() -> service.doSomething(""))
            .isInstanceOf(IllegalArgumentException.class)
            .hasMessage("Input cannot be empty");
    }
}
```

### Mockito Pattern
```java
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import static org.mockito.Mockito.*;
import static org.assertj.core.api.Assertions.*;

@ExtendWith(MockitoExtension.class)
class UserServiceTest {
    
    @Mock
    private UserRepository repository;
    
    @InjectMocks
    private UserService service;
    
    @Test
    void shouldFindUserById() {
        // Given
        User user = new User(1L, "John");
        when(repository.findById(1L)).thenReturn(Optional.of(user));
        
        // When
        User result = service.findById(1L);
        
        // Then
        assertThat(result.getName()).isEqualTo("John");
        verify(repository).findById(1L);
    }
}
```

### Spring Boot Integration Test Pattern
```java
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.web.servlet.MockMvc;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
class UserControllerIntegrationTest {
    
    @Autowired
    private MockMvc mockMvc;
    
    @Test
    void shouldGetUserById() throws Exception {
        mockMvc.perform(get("/api/users/1"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.id").value(1))
            .andExpect(jsonPath("$.name").exists());
    }
}
```

## Documentation (`process-docs/`)

- **STATUS-DETAILS.md**: Component test checklist
- **PROJECT_MEMORY.md**: Detected Java version + Spring detection + lessons learned
- **LOGIC_ANOMALIES.md**: Found bugs (audit only, don't fix)

## Usage - Copy This Complete Prompt

> **Type**: One-time setup process (iterative, multi-phase)  
> **When to use**: When establishing testing infrastructure in a Java project

### Complete Implementation Prompt

```
CONTEXT:
You are implementing comprehensive Java testing infrastructure for this project.

CRITICAL REQUIREMENTS:
- ALWAYS detect Java version from pom.xml or build.gradle
- ALWAYS detect Spring Boot usage (affects test setup)
- ALWAYS match detected version in Docker images, pipelines, and test projects
- NEVER fix production code bugs found during testing (log in LOGIC_ANOMALIES.md only)
- Use team's Git workflow (no prescribed branch names or commit patterns)

TECH STACK TO CHOOSE:
Test Framework (choose one):
- JUnit 5 ⭐ (recommended) - Modern, widely adopted
- TestNG - Advanced features, parallel execution
- Spock - Groovy-based, BDD style

Assertions (choose one):
- AssertJ ⭐ (recommended) - Fluent, readable
- Hamcrest - Matcher-based
- Built-in (JUnit assertions)

Mocking (choose one):
- Mockito ⭐ (recommended) - Most popular, simple
- MockK - Kotlin-friendly (if using Kotlin)
- EasyMock - Older, still used

For Spring Boot projects:
- Use @SpringBootTest for integration tests
- Use @WebMvcTest for controller tests
- Use @DataJpaTest for repository tests

---

PHASE 1 - ANALYSIS:
Objective: Understand project structure and choose test framework

1. Detect Java version from pom.xml or build.gradle
2. Detect if Spring Boot project (check for spring-boot-starter dependencies)
3. Document in process-docs/PROJECT_MEMORY.md
4. Identify existing test framework or choose based on team preference
5. Analyze current test infrastructure (if any)
6. Report findings and proposed framework choices

Deliverable: Testing strategy documented, framework chosen

---

PHASE 2 - INFRASTRUCTURE (Optional - skip if using cloud CI/CD):
Objective: Set up test infrastructure

1. Create Dockerfile.tests with detected Java version
2. Create docker-compose.tests.yml for test execution
3. Add/update CI/CD pipeline test step (merge with existing, don't overwrite)
4. Configure test reporting (JaCoCo for coverage)

Deliverable: Tests can run in CI/CD environment

Infrastructure Templates:
- Dockerfile: FROM eclipse-temurin:{VERSION}-jdk
- Maven: Use maven-surefire-plugin for tests
- Gradle: Use test task with JaCoCo plugin

---

PHASE 3 - TEST PROJECTS:
Objective: Create test project structure

1. Create test source directories:
   - src/test/java (unit tests)
   - src/integration-test/java (integration tests - optional separate)

2. Implement shared test utilities:
   - TestDataBuilder for test data generation
   - BaseIntegrationTest for Spring Boot tests
   - Common test fixtures and helpers

3. Configure test dependencies in pom.xml or build.gradle

Deliverable: Test project structure in place with shared utilities

---

PHASE 4 - TEST IMPLEMENTATION (Iterative):
Objective: Write tests for all components

For each component:
1. Identify component to test (from STATUS-DETAILS.md)
2. Understand component intent and behavior
3. Write unit tests (fast, isolated, mocked dependencies)
4. Write integration tests if applicable (full-stack, real dependencies)
5. For Spring Boot: Use appropriate test slices (@WebMvcTest, @DataJpaTest, etc.)
6. Run tests locally - must pass
7. If bugs found: Log to LOGIC_ANOMALIES.md (DON'T fix production code)
8. Update STATUS-DETAILS.md with completion status
9. Propose commit using team's commit format
10. Wait for user confirmation
11. Repeat for next component

Deliverable: Comprehensive test coverage for all components

---

DOCUMENTATION (create in process-docs/):
- STATUS-DETAILS.md: Component test checklist (track progress)
- PROJECT_MEMORY.md: Detected Java version, Spring Boot status, chosen frameworks, lessons learned
- LOGIC_ANOMALIES.md: Bugs found during testing (audit only, don't fix)

---

START: Execute Phase 1. Analyze project, detect Java version and Spring Boot usage, propose test framework choices.
```

