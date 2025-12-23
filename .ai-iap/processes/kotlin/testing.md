# Kotlin Testing Implementation Process

> **ALWAYS**: Follow phases sequentially. One branch per phase. Atomic commits only.

## Critical Requirements

> **ALWAYS**: Detect Kotlin version from `build.gradle.kts` or `pom.xml`
> **ALWAYS**: Match detected version in Docker images, pipelines, and test configuration
> **ALWAYS**: Create new branch for each phase: `poc/test-establishing/{phase-name}`
> **NEVER**: Combine multiple phases in one commit
> **NEVER**: Fix production code bugs found during testing (log only)

## Tech Stack

**Required**:
- **Test Framework**: JUnit 5 or Kotest (choose based on project preference)
- **Assertions**: AssertJ or Kotest assertions
- **Mocking**: MockK (Kotlin-first mocking)
- **Coroutines Testing**: kotlinx-coroutines-test (if using coroutines)
- **Spring Testing**: @SpringBootTest, MockMvc (if Spring project)
- **Runtime**: Match detected Kotlin & JVM version

**Forbidden**:
- JUnit 4 (migrate if found)
- Mockito (use MockK instead for Kotlin)

## Infrastructure Templates

> **ALWAYS**: Replace `{KOTLIN_VERSION}` and `{JVM_VERSION}` with detected versions

**File**: `docker/Dockerfile.tests`
```dockerfile
FROM gradle:8-jdk{JVM_VERSION} AS build
WORKDIR /app
COPY build.gradle.kts settings.gradle.kts ./
COPY gradle ./gradle
RUN gradle dependencies --no-daemon
COPY src ./src
RUN gradle build -x test --no-daemon

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
    command: gradle test jacocoTestReport --no-daemon
    volumes:
      - ../build/test-results:/test-results
      - ../build/reports/jacoco:/coverage
```

**CI/CD Integration**:

> **NEVER**: Overwrite existing pipeline. Merge this step only.

**GitHub Actions**:
```yaml
- name: Run Tests
  run: |
    ./gradlew test jacocoTestReport
  env:
    JVM_VERSION: {JVM_VERSION}
```

**GitLab CI**:
```yaml
test:
  image: gradle:8-jdk{JVM_VERSION}
  script:
    - gradle test jacocoTestReport
  artifacts:
    reports:
      junit: build/test-results/test/TEST-*.xml
    paths:
      - build/reports/jacoco/
```

## Implementation Phases

### Phase 1: Analysis
**Branch**: `poc/test-establishing/init-analysis`

1. Initialize `process-docs/` (STATUS-DETAILS.md, PROJECT_MEMORY.md, LOGIC_ANOMALIES.md)
2. Detect Kotlin & JVM version from `build.gradle.kts` → Document in PROJECT_MEMORY.md
3. Detect framework (Spring Boot/Ktor/Android/None)
4. Choose test framework (JUnit 5 or Kotest)
5. Propose commit → Wait for user

### Phase 2: Infrastructure
**Branch**: `poc/test-establishing/docker-infra`

1. Create `docker/Dockerfile.tests` with detected versions
2. Create `docker/docker-compose.tests.yml`
3. Merge CI/CD pipeline step (don't overwrite)
4. Propose commit → Wait for user

### Phase 3: Framework Setup
**Branch**: `poc/test-establishing/framework-setup`

1. Add dependencies to `build.gradle.kts`:
   ```kotlin
   dependencies {
       // JUnit 5 Option
       testImplementation("org.junit.jupiter:junit-jupiter:5.10.1")
       testImplementation("org.assertj:assertj-core:3.24.2")
       
       // Kotest Option (alternative)
       // testImplementation("io.kotest:kotest-runner-junit5:5.8.0")
       // testImplementation("io.kotest:kotest-assertions-core:5.8.0")
       
       // Common
       testImplementation("io.mockk:mockk:1.13.9")
       testImplementation("org.jetbrains.kotlinx:kotlinx-coroutines-test:1.7.3")
   }
   
   tasks.test {
       useJUnitPlatform()
   }
   ```
2. Configure JaCoCo for coverage
3. Propose commit → Wait for user

### Phase 4: Test Structure
**Branch**: `poc/test-establishing/project-skeleton`

1. Create test directory structure:
   ```
   src/
   ├── main/kotlin/com/company/project/
   └── test/kotlin/com/company/project/
       ├── unit/              # Unit tests
       ├── integration/       # Integration tests
       └── helpers/          # Test utilities
   ```
2. Implement base patterns:
   - `AbstractUnitTest.kt`
   - `AbstractIntegrationTest.kt`
   - `TestDataFactory.kt`
   - If Spring: `AbstractSpringTest.kt`
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

### JUnit 5 + AssertJ Pattern
```kotlin
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.DisplayName
import org.assertj.core.api.Assertions.*

@DisplayName("UserService Unit Tests")
class UserServiceTest {
    
    @Test
    fun `should create user successfully`() {
        // Given
        val service = UserService()
        
        // When
        val user = service.createUser("john@example.com", "John Doe")
        
        // Then
        assertThat(user.email).isEqualTo("john@example.com")
        assertThat(user.name).isEqualTo("John Doe")
    }
    
    @Test
    fun `should throw exception for invalid email`() {
        // Given
        val service = UserService()
        
        // When/Then
        assertThatThrownBy { service.createUser("invalid", "John Doe") }
            .isInstanceOf(IllegalArgumentException::class.java)
            .hasMessage("Invalid email")
    }
}
```

### Kotest Pattern (Alternative)
```kotlin
import io.kotest.core.spec.style.StringSpec
import io.kotest.matchers.shouldBe
import io.kotest.assertions.throwables.shouldThrow

class UserServiceTest : StringSpec({
    
    "should create user successfully" {
        // Given
        val service = UserService()
        
        // When
        val user = service.createUser("john@example.com", "John Doe")
        
        // Then
        user.email shouldBe "john@example.com"
        user.name shouldBe "John Doe"
    }
    
    "should throw exception for invalid email" {
        // Given
        val service = UserService()
        
        // When/Then
        shouldThrow<IllegalArgumentException> {
            service.createUser("invalid", "John Doe")
        }.message shouldBe "Invalid email"
    }
})
```

### MockK Pattern
```kotlin
import io.mockk.every
import io.mockk.mockk
import io.mockk.verify
import org.junit.jupiter.api.Test
import org.assertj.core.api.Assertions.*

class UserServiceTest {
    
    @Test
    fun `should find user by id`() {
        // Given
        val repository = mockk<UserRepository>()
        val user = User(1, "John Doe")
        every { repository.findById(1) } returns user
        
        val service = UserService(repository)
        
        // When
        val result = service.findById(1)
        
        // Then
        assertThat(result.name).isEqualTo("John Doe")
        verify { repository.findById(1) }
    }
}
```

### Coroutines Test Pattern
```kotlin
import kotlinx.coroutines.test.runTest
import org.junit.jupiter.api.Test
import org.assertj.core.api.Assertions.*

class AsyncServiceTest {
    
    @Test
    fun `should fetch data asynchronously`() = runTest {
        // Given
        val service = AsyncService()
        
        // When
        val result = service.fetchData("key")
        
        // Then
        assertThat(result).isNotNull
        assertThat(result.status).isEqualTo("success")
    }
}
```

### Spring Boot Integration Test Pattern
```kotlin
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.get
import org.springframework.test.web.servlet.post

@SpringBootTest
@AutoConfigureMockMvc
class UserControllerIntegrationTest {
    
    @Autowired
    private lateinit var mockMvc: MockMvc
    
    @Test
    fun `should get user by id`() {
        mockMvc.get("/api/users/1")
            .andExpect {
                status { isOk() }
                jsonPath("$.id") { value(1) }
                jsonPath("$.name") { exists() }
            }
    }
}
```

## Documentation (`process-docs/`)

- **STATUS-DETAILS.md**: Component test checklist
- **PROJECT_MEMORY.md**: Detected Kotlin/JVM version + framework + test framework choice + lessons learned
- **LOGIC_ANOMALIES.md**: Found bugs (audit only, don't fix)

## Usage

**Initial**:
```
Act as Senior SDET. Start Kotlin testing implementation.
Phase 1: Create branch `poc/test-establishing/init-analysis`, detect versions, choose test framework, initialize docs.
```

**Continue**:
```
Act as Senior SDET. Check STATUS-DETAILS.md for next phase/component. Execute and propose commit.
```

