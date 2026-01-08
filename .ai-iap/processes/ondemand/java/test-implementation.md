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
PHASE 1 - ANALYSIS
========================================

1. Detect Java version from pom.xml or build.gradle
2. Detect if Spring Boot project
3. Document in process-docs/PROJECT_MEMORY.md
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
5. If bugs found: Log to LOGIC_ANOMALIES.md (don't fix)
6. Update STATUS-DETAILS.md
7. Propose commit
8. Repeat for next component

Deliverable: All components tested

========================================
DOCUMENTATION
========================================

Create in process-docs/:

STATUS-DETAILS.md:
```
## Components
- [x] UserService (10 tests, 90% coverage)
- [ ] OrderService (pending)
```

PROJECT_MEMORY.md:
```
Java Version: 17
Spring Boot: Yes
Frameworks: JUnit 5, AssertJ, Mockito
```

LOGIC_ANOMALIES.md:
```
## UserService.findById
Issue: Returns null instead of throwing exception
Location: UserService.java:45
```

========================================
EXECUTION
========================================

START: Execute Phase 1 - detect Java version, choose frameworks, create strategy
CONTINUE: Execute phases 2-4 iteratively
REMEMBER: Use team's workflow, don't fix bugs, iterate component by component
```

---

## Quick Reference

**What you get**: Complete test infrastructure with JUnit 5, AssertJ, Mockito  
**Time**: 4-8 hours depending on project size  
**Output**: Test projects, shared utilities, comprehensive test coverage
