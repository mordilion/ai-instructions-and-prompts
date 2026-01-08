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

## Usage

**Initial**:
```
Act as Senior SDET. Start Java testing implementation.
Phase 1: Create branch `poc/test-establishing/init-analysis`, detect Java version, analyze project, initialize docs.
```

**Continue**:
```
Act as Senior SDET. Check STATUS-DETAILS.md for next phase/component. Execute and propose commit.
```

