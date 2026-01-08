# Code Coverage Setup (.NET)

> **Goal**: Establish automated code coverage tracking in existing .NET projects

## Phase 1: Choose Code Coverage Tools

> **ALWAYS**: Track line, branch, and function coverage
> **ALWAYS**: Set minimum coverage thresholds
> **NEVER**: Aim for 100% coverage (diminishing returns)
> **NEVER**: Skip uncovered critical paths

### Recommended Tools

| Tool | Type | Use Case | Setup |
|------|------|----------|-------|
| **Coverlet** ⭐ | Coverage tool | Cross-platform, free | `dotnet add package coverlet.msbuild` |
| **ReportGenerator** ⭐ | Report formatter | HTML/Cobertura reports | `dotnet tool install -g dotnet-reportgenerator-globaltool` |
| **dotCover** | Coverage tool | JetBrains | Commercial |
| **Codecov** | Reporting | CI/CD integration | Cloud service |

---

## Phase 2: Coverage Tool Configuration

### Coverlet Setup

```bash
# Install Coverlet
dotnet add package coverlet.msbuild

# Or install as global tool
dotnet tool install --global coverlet.console

# Run tests with coverage
dotnet test /p:CollectCoverage=true

# Generate specific format
dotnet test /p:CollectCoverage=true /p:CoverletOutputFormat=opencover
```

**Configuration** (`.csproj`):
```xml
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>net8.0</TargetFramework>
  </PropertyGroup>
  
  <ItemGroup>
    <PackageReference Include="coverlet.msbuild" Version="6.0.0">
      <IncludeAssets>runtime; build; native; contentfiles; analyzers</IncludeAssets>
      <PrivateAssets>all</PrivateAssets>
    </PackageReference>
  </ItemGroup>
</Project>
```

### ReportGenerator Setup

```bash
# Install
dotnet tool install -g dotnet-reportgenerator-globaltool

# Generate HTML report
reportgenerator \
  -reports:"coverage.opencover.xml" \
  -targetdir:"coveragereport" \
  -reporttypes:Html
```

---

## Phase 3: Coverage Thresholds & Reporting

### Coverlet Thresholds

```bash
# Fail build if below threshold
dotnet test /p:CollectCoverage=true \
  /p:CoverletOutputFormat=opencover \
  /p:Threshold=80 \
  /p:ThresholdType=line,branch \
  /p:ThresholdStat=total
```

**Configuration** (`Directory.Build.props`):
```xml
<Project>
  <PropertyGroup>
    <CollectCoverage>true</CollectCoverage>
    <CoverletOutputFormat>opencover,json</CoverletOutputFormat>
    <CoverletOutput>./coverage/</CoverletOutput>
    <Threshold>80</Threshold>
    <ThresholdType>line,branch</ThresholdType>
    <ThresholdStat>total</ThresholdStat>
    <ExcludeByFile>
      **/*.Designer.cs,
      **/Migrations/**,
      **/obj/**
    </ExcludeByFile>
    <ExcludeByAttribute>
      GeneratedCode,
      Obsolete
    </ExcludeByAttribute>
  </PropertyGroup>
</Project>
```

---

## Phase 4: CI/CD Integration

### GitHub Actions

```yaml
# .github/workflows/test.yml
name: Test & Coverage

on:
  push:
    branches: [main, develop]
  pull_request:

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup .NET
        uses: actions/setup-dotnet@v4
        with:
          global-json-file: 'global.json'
      
      - name: Restore dependencies
        run: dotnet restore
      
      - name: Build
        run: dotnet build --no-restore --configuration Release
      
      - name: Run tests with coverage
        run: |
          dotnet test --no-build --configuration Release \
            /p:CollectCoverage=true \
            /p:CoverletOutputFormat=opencover \
            /p:CoverletOutput=./coverage/
      
      - name: Generate coverage report
        run: |
          dotnet tool install -g dotnet-reportgenerator-globaltool
          reportgenerator -reports:./coverage/coverage.opencover.xml \
            -targetdir:./coveragereport \
            -reporttypes:Html
      
      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v4
        with:
          token: ${{ secrets.CODECOV_TOKEN }}
          files: ./coverage/coverage.opencover.xml
          fail_ci_if_error: true
      
      - name: Archive coverage report
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: coverage-report
          path: coveragereport/
```

---

## Phase 5: Coverage Analysis & Improvement

### Identify Uncovered Code

```bash
# Generate HTML report
dotnet test /p:CollectCoverage=true /p:CoverletOutputFormat=opencover
reportgenerator -reports:"coverage.opencover.xml" -targetdir:"coveragereport" -reporttypes:Html

# Open report (Windows)
start coveragereport/index.html
```

### Exclude Code from Coverage

```csharp
// Exclude entire class
[ExcludeFromCodeCoverage]
public class GeneratedCode { }

// Exclude method
[ExcludeFromCodeCoverage]
public void LegacyMethod() { }
```

### Prioritize Critical Paths

**Coverage priorities (high to low)**:
1. Business logic (services, domain)
2. Data validation (DTOs, validators)
3. Error handling
4. API controllers
5. Infrastructure (repositories)

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| **Coverage reports empty** | Check `ExcludeByFile` paths in config |
| **Slow test runs** | Use `dotnet test --no-build` after building |
| **Missing coverage for Razor pages** | Add `/p:Include="[*]YourNamespace.*"` |
| **CI fails on threshold** | Review uncovered code, add tests or adjust threshold |

---

## Best Practices

> **ALWAYS**: Set realistic thresholds (70-85% is good)
> **ALWAYS**: Exclude generated code (Migrations, Designer)
> **ALWAYS**: Review coverage reports before merge
> **ALWAYS**: Track coverage trends over time
> **NEVER**: Aim for 100% (diminishing returns)
> **NEVER**: Write tests just to increase coverage
> **NEVER**: Skip edge cases and error paths

---

## AI Self-Check

- [ ] Coverlet configured for coverage?
- [ ] ReportGenerator installed for HTML reports?
- [ ] Coverage thresholds set (80% line, 75% branch)?
- [ ] CI/CD runs coverage and fails on threshold violation?
- [ ] Coverage reports uploaded to Codecov/Coveralls?
- [ ] Generated code excluded from coverage?
- [ ] HTML reports generated for local review?
- [ ] Team reviews coverage reports?
- [ ] `ExcludeFromCodeCoverage` attribute used appropriately?
- [ ] Uncovered critical code identified and tested?

---

## Coverage Metrics Explained

| Metric | Definition | Target |
|--------|------------|--------|
| **Line Coverage** | % of lines executed | 80-85% |
| **Branch Coverage** | % of if/else branches executed | 75-80% |
| **Method Coverage** | % of methods called | 80-85% |

---

## Tools Comparison

| Tool | Speed | Setup | CI/CD | Best For |
|------|-------|-------|-------|----------|
| Coverlet | Fast | Easy | ✅ | Cross-platform |
| ReportGenerator | N/A | Easy | ✅ | Report formatting |
| dotCover | Medium | Medium | ✅ | JetBrains IDEs |
| Codecov | N/A | Easy | ✅ | Reporting |


## Usage - Copy This Complete Prompt

> **Type**: One-time setup process (simple)  
> **When to use**: When configuring code coverage tracking and reporting

### Complete Implementation Prompt

```
CONTEXT:
You are configuring code coverage tracking for this project.

CRITICAL REQUIREMENTS:
- ALWAYS detect language version from project files
- ALWAYS configure coverage thresholds (recommended: 80% line, 75% branch)
- ALWAYS integrate with CI/CD pipeline
- NEVER lower coverage thresholds without justification

IMPLEMENTATION STEPS:

1. DETECT VERSION:
   Scan project files for language/framework version

2. CHOOSE COVERAGE TOOL:
   Select appropriate tool for the language (see Tech Stack section above)

3. CONFIGURE TOOL:
   Add coverage configuration to project
   Set thresholds (line, branch, function)

4. INTEGRATE WITH CI/CD:
   Add coverage step to pipeline
   Configure to fail build if below thresholds

5. CONFIGURE REPORTING:
   Generate coverage reports (HTML, XML, lcov)
   Optional: Upload to coverage service (Codecov, Coveralls)

DELIVERABLE:
- Coverage tool configured
- Thresholds enforced in CI/CD
- Coverage reports generated

START: Detect language version and configure coverage tool.
```
