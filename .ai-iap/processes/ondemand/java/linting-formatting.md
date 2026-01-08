# Java Linting & Formatting - Copy This Prompt

> **Type**: One-time setup process  
> **When to use**: Setting up linting and code formatting  
> **Instructions**: Copy the complete prompt below and paste into your AI tool

---

## 📋 Complete Self-Contained Prompt

```
========================================
JAVA LINTING & FORMATTING
========================================

CONTEXT:
You are setting up linting and code formatting for a Java project.

CRITICAL REQUIREMENTS:
- ALWAYS use Checkstyle + SpotBugs + Google Java Format
- NEVER ignore warnings without justification
- Use .editorconfig for consistency
- Enforce in CI pipeline

========================================
PHASE 1 - CHECKSTYLE
========================================

Add to pom.xml:
```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-checkstyle-plugin</artifactId>
    <version>3.3.1</version>
    <configuration>
        <configLocation>google_checks.xml</configLocation>
        <consoleOutput>true</consoleOutput>
        <failsOnError>true</failsOnError>
    </configuration>
    <executions>
        <execution>
            <goals>
                <goal>check</goal>
            </goals>
        </execution>
    </executions>
</plugin>
```

Run:
```bash
mvn checkstyle:check
```

Deliverable: Checkstyle configured

========================================
PHASE 2 - GOOGLE JAVA FORMAT
========================================

Add to pom.xml:
```xml
<plugin>
    <groupId>com.spotify.fmt</groupId>
    <artifactId>fmt-maven-plugin</artifactId>
    <version>2.21.1</version>
    <executions>
        <execution>
            <goals>
                <goal>format</goal>
            </goals>
        </execution>
    </executions>
</plugin>
```

Format code:
```bash
mvn fmt:format

# Check without modifying
mvn fmt:check
```

Deliverable: Auto-formatting enabled

========================================
PHASE 3 - SPOTBUGS
========================================

Add to pom.xml:
```xml
<plugin>
    <groupId>com.github.spotbugs</groupId>
    <artifactId>spotbugs-maven-plugin</artifactId>
    <version>4.8.2.0</version>
    <configuration>
        <effort>Max</effort>
        <threshold>Low</threshold>
        <failOnError>true</failOnError>
    </configuration>
    <executions>
        <execution>
            <goals>
                <goal>check</goal>
            </goals>
        </execution>
    </executions>
</plugin>
```

Deliverable: Static analysis enabled

========================================
PHASE 4 - CI INTEGRATION
========================================

Add to .github/workflows/ci.yml:
```yaml
- name: Checkstyle
  run: mvn checkstyle:check

- name: Format check
  run: mvn fmt:check

- name: SpotBugs
  run: mvn spotbugs:check
```

Deliverable: Automated checks in CI

========================================
BEST PRACTICES
========================================

- Use Google Java Format
- Run Checkstyle for style violations
- Use SpotBugs for bug detection
- Create .editorconfig for IDE consistency
- Fail build on violations
- Run checks in CI

========================================
EXECUTION
========================================

START: Add Checkstyle (Phase 1)
CONTINUE: Add Google Java Format (Phase 2)
CONTINUE: Add SpotBugs (Phase 3)
CONTINUE: Add CI checks (Phase 4)
REMEMBER: Fail on violations, enforce in CI
```

---

## Quick Reference

**What you get**: Complete linting and formatting setup  
**Time**: 45 minutes  
**Output**: Checkstyle, Google Java Format, SpotBugs, CI integration
