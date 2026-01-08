# Kotlin Testing Implementation Process

> **Purpose**: Establish comprehensive testing infrastructure for Kotlin projects

## Critical Requirements

> **ALWAYS**: Detect Kotlin version from `build.gradle.kts` or `pom.xml`
> **ALWAYS**: Match detected version in Docker images, pipelines, and test configuration
> **ALWAYS**: Use your team's workflow for branching and commits (adapt as needed)
> **NEVER**: Fix production code bugs found during testing (log only)

## Workflow Adaptation

> **IMPORTANT**: This guide focuses on OBJECTIVES, not specific workflows.  
> **Your team's conventions take precedence** for Git, commits, Docker, CI/CD.  
> See [Git Workflow Adaptation Guide](../_templates/git-workflow-adaptation.md)

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

**Docker**: Multi-stage `Dockerfile.tests` (gradle:8-jdk{JVM_VERSION}, cache dependencies, run `gradle build -x test`)  
**docker-compose.tests.yml**: Mount volumes for test-results & coverage, run `gradle test jacocoTestReport`

**CI/CD Integration**: Run `./gradlew test jacocoTestReport`, publish JUnit XML artifacts (build/test-results) and JaCoCo reports  
**NEVER**: Overwrite existing pipeline

## Implementation Phases

> **For each phase**: Use your team's workflow ([see adaptation guide](../_templates/git-workflow-adaptation.md))

### Phase 1: Analysis

**Objective**: Understand project structure and choose test framework

1. Detect Kotlin & JVM version from `build.gradle.kts`
2. Identify framework (Spring Boot/Ktor/Android/None)
3. Choose test framework (JUnit 5 or Kotest)

**Deliverable**: Testing strategy documented

### Phase 2: Infrastructure (Optional)

**Objective**: Set up test infrastructure (skip if using cloud CI/CD)

1. Create Docker test files (if using Docker)
2. Add/update CI/CD pipeline test step
3. Configure test reporting

**Deliverable**: Tests can run in CI/CD

### Phase 3: Framework Setup

**Objective**: Install and configure test dependencies

1. Add dependencies: JUnit 5/Kotest, MockK, Coroutines Test
2. Configure JaCoCo for coverage
3. Set up test task configuration

**Deliverable**: Test framework ready

### Phase 4: Test Structure

**Objective**: Establish test directory organization

1. Create test structure: `src/test/kotlin/.../unit/`, `integration/`, `helpers/`
2. Create base test classes: `AbstractUnitTest.kt`, `TestDataFactory.kt`

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

