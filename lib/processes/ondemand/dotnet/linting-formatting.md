# .NET Linting & Formatting - Copy This Prompt

> **Type**: One-time setup process  
> **When to use**: Setting up linting and code formatting  
> **Instructions**: Copy the complete prompt below and paste into your AI tool

---

## 📋 Complete Self-Contained Prompt

```
========================================
.NET LINTING & FORMATTING
========================================

CONTEXT:
You are setting up linting and code formatting for a .NET project.

CRITICAL REQUIREMENTS:
- ALWAYS use dotnet format and analyzers
- NEVER ignore warnings without justification
- Use .editorconfig for consistency
- Enforce in CI pipeline

========================================
CATCH-UP: READ EXISTING DOCUMENTATION
========================================

BEFORE starting, check for existing documentation:
1. Read PROJECT-MEMORY.md, LOGIC-ANOMALIES.md, LINTING-SETUP.md if they exist

Use this to continue from where work stopped. If no docs: Start fresh.

========================================
PHASE 1 - BASIC LINTING
========================================

Enable analyzers in .csproj:
```xml
<PropertyGroup>
  <EnableNETAnalyzers>true</EnableNETAnalyzers>
  <AnalysisLevel>latest</AnalysisLevel>
  <EnforceCodeStyleInBuild>true</EnforceCodeStyleInBuild>
  <TreatWarningsAsErrors>true</TreatWarningsAsErrors>
</PropertyGroup>
```

Add StyleCop for additional rules:
```bash
dotnet add package StyleCop.Analyzers
```

Add to .csproj:
```xml
<ItemGroup>
  <AdditionalFiles Include="stylecop.json" />
</ItemGroup>
```

Create stylecop.json:
```json
{
  "$schema": "https://raw.githubusercontent.com/DotNetAnalyzers/StyleCopAnalyzers/master/StyleCop.Analyzers/StyleCop.Analyzers/Settings/stylecop.schema.json",
  "settings": {
    "documentationRules": {
      "companyName": "YourCompany"
    }
  }
}
```

Deliverable: Linting configured

========================================
PHASE 2 - FORMATTING
========================================

Create .editorconfig:
```ini
root = true

[*]
charset = utf-8
indent_style = space
indent_size = 4
insert_final_newline = true
trim_trailing_whitespace = true

[*.cs]
# Formatting
csharp_new_line_before_open_brace = all
csharp_new_line_before_else = true
csharp_new_line_before_catch = true
csharp_new_line_before_finally = true

# Naming conventions
dotnet_naming_rule.interfaces_should_be_prefixed_with_i.severity = warning
dotnet_naming_rule.interfaces_should_be_prefixed_with_i.symbols = interface
dotnet_naming_rule.interfaces_should_be_prefixed_with_i.style = begins_with_i
```

Format code:
```bash
dotnet format
```

Deliverable: Auto-formatting enabled

========================================
PHASE 3 - CI INTEGRATION
========================================

Add to .github/workflows/ci.yml:
```yaml
- name: Format check
  run: dotnet format --verify-no-changes

- name: Build with warnings as errors
  run: dotnet build /warnaserror
```

Deliverable: Automated checks in CI

========================================
PHASE 4 - IDE INTEGRATION
========================================

VS Code settings.json:
```json
{
  "omnisharp.enableEditorConfigSupport": true,
  "editor.formatOnSave": true,
  "[csharp]": {
    "editor.defaultFormatter": "ms-dotnettools.csharp"
  }
}
```

Deliverable: IDE auto-formatting

========================================
BEST PRACTICES
========================================

- Use .editorconfig for consistency
- Enable analyzers in .csproj
- Treat warnings as errors
- Run dotnet format before commits
- Fail CI on format violations
- Use StyleCop for additional rules

========================================
DOCUMENTATION
========================================

Create/update: PROJECT-MEMORY.md, LOGIC-ANOMALIES.md, LINTING-SETUP.md

========================================
EXECUTION
========================================

START: Read existing docs (CATCH-UP section)
CONTINUE: Enable analyzers (Phase 1)
CONTINUE: Create .editorconfig (Phase 2)
CONTINUE: Add CI checks (Phase 3)
OPTIONAL: Configure IDE (Phase 4)
FINISH: Update all documentation files
REMEMBER: Warnings as errors, enforce in CI, document for catch-up
```

---

## Quick Reference

**What you get**: Complete linting and formatting setup  
**Time**: 30 minutes  
**Output**: .editorconfig, analyzers, CI integration
