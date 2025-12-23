# Java Testing Implementation Process

> **ALWAYS**: Follow phases sequentially. One branch per phase. Atomic commits only.

## Critical Requirements

> **ALWAYS**: Detect Java version from `pom.xml` or `build.gradle`
> **ALWAYS**: Match detected version in Docker images, pipelines, and test configuration
> **ALWAYS**: Create new branch for each phase: `poc/test-establishing/{phase-name}`
> **NEVER**: Combine multiple phases in one commit
> **NEVER**: Fix production code bugs found during testing (log only)

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

### Phase 1: Analysis
**Branch**: `poc/test-establishing/init-analysis`

1. Initialize `process-docs/` (STATUS-DETAILS.md, PROJECT_MEMORY.md, LOGIC_ANOMALIES.md)
2. Detect Java version from `pom.xml` or `build.gradle` → Document in PROJECT_MEMORY.md
3. Detect if Spring Boot project
4. Analyze existing test framework
5. Propose commit → Wait for user

### Phase 2: Infrastructure
**Branch**: `poc/test-establishing/docker-infra`

1. Create `docker/Dockerfile.tests` with detected version
2. Create `docker/docker-compose.tests.yml`
3. Merge CI/CD pipeline step (don't overwrite)
4. Propose commit → Wait for user

### Phase 3: Framework Setup
**Branch**: `poc/test-establishing/framework-setup`

1. Add dependencies to `pom.xml`:
   ```xml
   <dependencies>
     <dependency>
       <groupId>org.junit.jupiter</groupId>
       <artifactId>junit-jupiter</artifactId>
       <scope>test</scope>
     </dependency>
     <dependency>
       <groupId>org.assertj</groupId>
       <artifactId>assertj-core</artifactId>
       <scope>test</scope>
     </dependency>
     <dependency>
       <groupId>org.mockito</groupId>
       <artifactId>mockito-core</artifactId>
       <scope>test</scope>
     </dependency>
     <dependency>
       <groupId>org.mockito</groupId>
       <artifactId>mockito-junit-jupiter</artifactId>
       <scope>test</scope>
     </dependency>
   </dependencies>
   ```
2. Configure Surefire and JaCoCo plugins
3. If JUnit 4 found → Migrate to JUnit 5
4. Propose commit → Wait for user

### Phase 4: Test Structure
**Branch**: `poc/test-establishing/project-skeleton`

1. Create test directory structure:
   ```
   src/
   ├── main/java/com/company/project/
   └── test/java/com/company/project/
       ├── unit/              # Unit tests
       ├── integration/       # Integration tests
       └── helpers/          # Test utilities
   ```
2. Implement base patterns:
   - `AbstractUnitTest`
   - `AbstractIntegrationTest`
   - `TestDataBuilder`
   - `MockDataFactory`
   - If Spring: `AbstractSpringIntegrationTest`
3. Propose commit → Wait for user

### Phase 5: Test Implementation (Loop)
**Branch**: `poc/test-establishing/test-{component}` (new branch per component)

1. Read next untested component from STATUS-DETAILS.md
2. Understand intent and behavior
3. Write tests following patterns
4. Run tests locally → Must pass
5. If bugs found → Log to LOGIC_ANOMALIES.md (DON'T fix code)
6. Update STATUS-DETAILS.md
7. Propose commit: `feat(test): add tests for {Component}`
8. Wait for user confirmation → Repeat for next component

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

