# Java Code Coverage - Copy This Prompt

> **Type**: One-time setup process  
> **When to use**: Setting up code coverage for Java project  
> **Instructions**: Copy the complete prompt below and paste into your AI tool

---

## 📋 Complete Self-Contained Prompt

```
========================================
JAVA CODE COVERAGE - JACOCO
========================================

CONTEXT:
You are implementing code coverage measurement for a Java project using JaCoCo.

CRITICAL REQUIREMENTS:
- ALWAYS use JaCoCo (industry standard)
- NEVER commit coverage reports to Git
- Target 80%+ coverage for critical paths
- Exclude generated code and POJOs

========================================
PHASE 1 - LOCAL COVERAGE
========================================

Add to pom.xml:
```xml
<plugin>
  <groupId>org.jacoco</groupId>
  <artifactId>jacoco-maven-plugin</artifactId>
  <version>0.8.11</version>
  <executions>
    <execution>
      <goals>
        <goal>prepare-agent</goal>
      </goals>
    </execution>
    <execution>
      <id>report</id>
      <phase>test</phase>
      <goals>
        <goal>report</goal>
      </goals>
    </execution>
  </executions>
</plugin>
```

Run tests with coverage:
```bash
mvn clean test
# Report at: target/site/jacoco/index.html
open target/site/jacoco/index.html
```

Update .gitignore:
```
target/site/jacoco/
jacoco.exec
```

Deliverable: Local coverage report

========================================
PHASE 2 - CONFIGURE EXCLUSIONS
========================================

Add to pom.xml jacoco plugin:
```xml
<configuration>
  <excludes>
    <exclude>**/dto/**</exclude>
    <exclude>**/entity/**</exclude>
    <exclude>**/config/**</exclude>
    <exclude>**/*Application.class</exclude>
  </excludes>
</configuration>
```

Use annotations:
```java
@lombok.Generated  // Exclude Lombok code
public class User { }
```

Deliverable: Proper file exclusions

========================================
PHASE 3 - CI INTEGRATION
========================================

Add to .github/workflows/ci.yml:

```yaml
    - name: Test with coverage
      run: mvn test jacoco:report
    
    - name: Upload to Codecov
      uses: codecov/codecov-action@v3
      with:
        files: target/site/jacoco/jacoco.xml
        fail_ci_if_error: true
```

Deliverable: CI coverage reporting

========================================
PHASE 4 - COVERAGE ENFORCEMENT
========================================

Add to pom.xml:
```xml
<execution>
  <id>check</id>
  <goals>
    <goal>check</goal>
  </goals>
  <configuration>
    <rules>
      <rule>
        <element>BUNDLE</element>
        <limits>
          <limit>
            <counter>LINE</counter>
            <value>COVEREDRATIO</value>
            <minimum>0.80</minimum>
          </limit>
        </limits>
      </rule>
    </rules>
  </configuration>
</execution>
```

Run:
```bash
mvn verify  # Fails if below 80%
```

Deliverable: Automated coverage enforcement

========================================
BEST PRACTICES
========================================

- Exclude DTOs, entities, and config classes
- Use JaCoCo for consistent reporting
- Focus on service/business logic
- Test edge cases and exceptions
- Set minimum thresholds (80%+)
- Review coverage in PRs

========================================
EXECUTION
========================================

START: Add JaCoCo plugin (Phase 1)
CONTINUE: Configure exclusions (Phase 2)
CONTINUE: Add CI integration (Phase 3)
OPTIONAL: Add enforcement (Phase 4)
REMEMBER: Exclude generated code, use JaCoCo
```

---

## Quick Reference

**What you get**: Complete code coverage setup with JaCoCo  
**Time**: 1 hour  
**Output**: Coverage reports in CI and locally
