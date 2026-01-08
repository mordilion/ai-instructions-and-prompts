# Linting & Formatting Setup (.NET)

> **Goal**: Establish automated code linting and formatting in existing .NET projects

## Phase 1: Choose Linting & Formatting Tools

> **ALWAYS**: Use a linter (code quality) + formatter (code style)
> **ALWAYS**: Run linter/formatter in CI/CD pipeline
> **NEVER**: Mix multiple formatters (choose one)
> **NEVER**: Skip pre-commit hooks

### Recommended Tools

| Tool | Type | Use Case | Setup |
|------|------|----------|-------|
| **dotnet format** ⭐ | Formatter | Built-in, free | `dotnet format` |
| **StyleCop Analyzers** ⭐ | Linter | Code style rules | NuGet package |
| **EditorConfig** | Style rules | Cross-IDE config | `.editorconfig` file |
| **ReSharper** | Linter + Formatter | Comprehensive | Commercial IDE extension |

---

## Phase 2: Linter Configuration

### StyleCop Analyzers Setup

```xml
<!-- Directory.Build.props -->
<Project>
  <ItemGroup>
    <PackageReference Include="StyleCop.Analyzers" Version="1.2.0-beta.507">
      <PrivateAssets>all</PrivateAssets>
      <IncludeAssets>runtime; build; native; contentfiles; analyzers</IncludeAssets>
    </PackageReference>
  </ItemGroup>
</Project>
```

**Configuration** (`stylecop.json`):
```json
{
  "$schema": "https://raw.githubusercontent.com/DotNetAnalyzers/StyleCopAnalyzers/master/StyleCop.Analyzers/StyleCop.Analyzers/Settings/stylecop.schema.json",
  "settings": {
    "documentationRules": {
      "companyName": "YourCompany",
      "copyrightText": "Copyright (c) {companyName}. All rights reserved."
    },
    "orderingRules": {
      "usingDirectivesPlacement": "outsideNamespace"
    }
  }
}
```

**Include in .csproj**:
```xml
<ItemGroup>
  <AdditionalFiles Include="stylecop.json" />
</ItemGroup>
```

---

## Phase 3: Formatter Configuration

### dotnet format Setup

```bash
# Install (if not available)
dotnet tool install -g dotnet-format

# Format project
dotnet format

# Check formatting (CI/CD)
dotnet format --verify-no-changes

# Format with specific diagnostics
dotnet format --diagnostics IDE0005
```

### EditorConfig Setup

**Configuration** (`.editorconfig`):
```ini
root = true

[*]
indent_style = space
indent_size = 4
end_of_line = lf
charset = utf-8
trim_trailing_whitespace = true
insert_final_newline = true

[*.cs]
# Organize usings
dotnet_sort_system_directives_first = true
dotnet_separate_import_directive_groups = false

# C# code style
csharp_prefer_braces = true:warning
csharp_prefer_simple_using_statement = true:suggestion
csharp_style_namespace_declarations = file_scoped:warning
csharp_style_prefer_method_group_conversion = true:silent
csharp_style_expression_bodied_methods = false:silent

# Naming conventions
dotnet_naming_rule.interface_should_be_begins_with_i.severity = warning
dotnet_naming_rule.interface_should_be_begins_with_i.symbols = interface
dotnet_naming_rule.interface_should_be_begins_with_i.style = begins_with_i

dotnet_naming_symbols.interface.applicable_kinds = interface
dotnet_naming_style.begins_with_i.required_prefix = I
dotnet_naming_style.begins_with_i.capitalization = pascal_case

# Code analysis
dotnet_diagnostic.CA1031.severity = warning
dotnet_diagnostic.CA1062.severity = warning
dotnet_diagnostic.IDE0005.severity = warning

[*.{json,yml,yaml}]
indent_size = 2
```

---

## Phase 4: IDE Integration & Pre-commit Hooks

### VS Code Setup

**Extensions** (`.vscode/extensions.json`):
```json
{
  "recommendations": [
    "ms-dotnettools.csharp",
    "editorconfig.editorconfig"
  ]
}
```

**Settings** (`.vscode/settings.json`):
```json
{
  "editor.formatOnSave": true,
  "omnisharp.enableEditorConfigSupport": true,
  "omnisharp.enableRoslynAnalyzers": true
}
```

### Pre-commit Hooks (Husky.Net)

```bash
# Install
dotnet tool install Husky

# Initialize
dotnet husky install

# Add pre-commit hook
dotnet husky add pre-commit -c "dotnet format --verify-no-changes"
```

---

## Phase 5: CI/CD Integration

### GitHub Actions

```yaml
# .github/workflows/lint.yml
name: Lint & Format Check

on:
  push:
    branches: [main, develop]
  pull_request:

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup .NET
        uses: actions/setup-dotnet@v4
        with:
          global-json-file: 'global.json'
      
      - name: Restore dependencies
        run: dotnet restore
      
      - name: Run dotnet format
        run: dotnet format --verify-no-changes --verbosity diagnostic
      
      - name: Build (with analyzers)
        run: dotnet build --no-restore --configuration Release /warnaserror
```

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| **dotnet format not found** | Install: `dotnet tool install -g dotnet-format` |
| **StyleCop warnings** | Configure in `.editorconfig` or suppress with `#pragma` |
| **EditorConfig not applied** | Enable in IDE settings, restart IDE |
| **CI fails on warnings** | Use `/warnaserror` in build command |

---

## Best Practices

> **ALWAYS**: Format code before commit (pre-commit hooks)
> **ALWAYS**: Run linter in CI/CD
> **ALWAYS**: Fix all warnings before merge
> **ALWAYS**: Use `.editorconfig` for consistency
> **NEVER**: Disable analyzers without team discussion
> **NEVER**: Commit code with warnings
> **NEVER**: Use `#pragma` without justification

---

## AI Self-Check

- [ ] `dotnet format` configured and working?
- [ ] StyleCop Analyzers installed?
- [ ] `.editorconfig` file present with C# rules?
- [ ] Pre-commit hooks installed (Husky.Net)?
- [ ] VS Code extensions configured?
- [ ] CI/CD runs format check and build with `/warnaserror`?
- [ ] All analyzer warnings fixed?
- [ ] File-scoped namespaces enforced?
- [ ] Team trained on coding standards?
- [ ] `Directory.Build.props` for shared settings?

---

## Tools Comparison

| Tool | Type | Speed | Extensibility | Best For |
|------|------|-------|---------------|----------|
| dotnet format | Formatter | Fast | ⭐ | Code style |
| StyleCop | Linter | Medium | ⭐⭐ | Code quality |
| EditorConfig | Config | N/A | ⭐⭐⭐ | Cross-IDE |
| ReSharper | Both | Medium | ⭐⭐⭐ | Commercial |


## Usage - Copy This Complete Prompt

> **Type**: One-time setup process (simple)  
> **When to use**: When setting up code linting and formatting tools

### Complete Implementation Prompt

```
CONTEXT:
You are configuring code linting and formatting for this project.

CRITICAL REQUIREMENTS:
- ALWAYS configure both linting (quality) and formatting (style)
- ALWAYS integrate with pre-commit hooks
- ALWAYS add to CI/CD pipeline
- ALWAYS use consistent configuration across team

IMPLEMENTATION STEPS:

1. CHOOSE TOOLS:
   Select appropriate linter and formatter for the language (see Tech Stack section)

2. CONFIGURE LINTER:
   Create configuration file (.eslintrc, ruff.toml, etc.)
   Set rules (recommended: start with recommended preset)

3. CONFIGURE FORMATTER:
   Create configuration file (if separate from linter)
   Set style rules (indentation, line length, etc.)

4. INTEGRATE WITH EDITOR:
   Configure IDE/editor plugins
   Enable format-on-save

5. ADD PRE-COMMIT HOOKS:
   Install pre-commit hooks (husky, pre-commit, etc.)
   Configure to run linter and formatter

6. ADD TO CI/CD:
   Add linting step to pipeline
   Fail build on linting errors

DELIVERABLE:
- Linter and formatter configured
- Pre-commit hooks active
- CI/CD integration complete

START: Choose tools and create configuration files.
```
