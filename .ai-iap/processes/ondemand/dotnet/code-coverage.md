# .NET Code Coverage - Copy This Prompt

> **Type**: One-time setup process  
> **When to use**: Setting up code coverage for .NET project  
> **Instructions**: Copy the complete prompt below and paste into your AI tool

---

## 📋 Complete Self-Contained Prompt

```
========================================
.NET CODE COVERAGE
========================================

CONTEXT:
You are implementing code coverage measurement for a .NET project.

CRITICAL REQUIREMENTS:
- ALWAYS use coverlet for .NET Core/5+
- NEVER commit coverage reports to Git
- Target 80%+ coverage for critical paths
- Use Cobertura format for CI integration

========================================
PHASE 1 - LOCAL COVERAGE
========================================

Install coverlet:
```bash
dotnet add package coverlet.collector
dotnet add package coverlet.msbuild
```

Run tests with coverage:
```bash
dotnet test /p:CollectCoverage=true /p:CoverletOutputFormat=cobertura

# Or with opencover format
dotnet test /p:CollectCoverage=true /p:CoverletOutputFormat=opencover
```

Generate HTML report:
```bash
dotnet tool install -g dotnet-reportgenerator-globaltool
reportgenerator -reports:coverage.cobertura.xml -targetdir:coverage -reporttypes:Html
```

Update .gitignore:
```
coverage/
coverage.*.xml
TestResults/
```

Deliverable: Local coverage report

========================================
PHASE 2 - CONFIGURE EXCLUSIONS
========================================

Add to test .csproj:
```xml
<PropertyGroup>
  <CoverletOutput>./coverage/</CoverletOutput>
  <CollectCoverage>true</CollectCoverage>
  <CoverletOutputFormat>cobertura</CoverletOutputFormat>
  <ExcludeByFile>**/Migrations/*.cs</ExcludeByFile>
  <ExcludeByAttribute>GeneratedCodeAttribute,ExcludeFromCodeCoverageAttribute</ExcludeByAttribute>
</PropertyGroup>
```

Exclude files with attributes:
```csharp
[ExcludeFromCodeCoverage]
public class GeneratedClass { }
```

Deliverable: Proper file exclusions

========================================
PHASE 3 - CI INTEGRATION
========================================

Add to .github/workflows/ci.yml:

```yaml
    - name: Test with coverage
      run: dotnet test --collect:"XPlat Code Coverage" --results-directory ./coverage
    
    - name: Upload to Codecov
      uses: codecov/codecov-action@v3
      with:
        files: ./coverage/**/coverage.cobertura.xml
        fail_ci_if_error: true
```

Deliverable: CI coverage reporting

========================================
PHASE 4 - COVERAGE ENFORCEMENT
========================================

Add to .csproj:
```xml
<PropertyGroup>
  <Threshold>80</Threshold>
  <ThresholdType>line,branch,method</ThresholdType>
  <ThresholdStat>total</ThresholdStat>
</PropertyGroup>
```

Or use Codecov's PR comments for enforcement.

Deliverable: Automated coverage enforcement

========================================
BEST PRACTICES
========================================

- Exclude migrations and generated code
- Use coverlet for .NET Core/5+
- Use Cobertura format for CI
- Focus on business logic coverage
- Test edge cases and exceptions
- Set minimum thresholds (80%+)

========================================
EXECUTION
========================================

START: Run local coverage (Phase 1)
CONTINUE: Configure exclusions (Phase 2)
CONTINUE: Add CI integration (Phase 3)
OPTIONAL: Add enforcement (Phase 4)
REMEMBER: Use coverlet, exclude generated files
```

---

## Quick Reference

**What you get**: Complete code coverage setup with coverlet  
**Time**: 1 hour  
**Output**: Coverage reports in CI and locally
