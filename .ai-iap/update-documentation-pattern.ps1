# PowerShell Script to Add Catch-Up Documentation Pattern to All On-Demand Process Files
# Usage: .\update-documentation-pattern.ps1

$ErrorActionPreference = "Stop"

# Process category to setup file mapping
$setupFiles = @{
    "test-implementation" = "TESTING-SETUP.md"
    "ci-cd-github-actions" = "CI-CD-SETUP.md"
    "code-coverage" = "COVERAGE-SETUP.md"
    "docker-containerization" = "DOCKER-SETUP.md"
    "logging-observability" = "LOGGING-SETUP.md"
    "linting-formatting" = "LINTING-SETUP.md"
    "security-scanning" = "SECURITY-SETUP.md"
    "api-documentation-openapi" = "API-DOCS-SETUP.md"
    "authentication-jwt-oauth" = "AUTH-SETUP.md"
}

# CATCH-UP section template (language-agnostic)
function Get-CatchUpSection {
    param([string]$processType, [string]$setupFile)
    
    return @"

========================================
CATCH-UP: READ EXISTING DOCUMENTATION
========================================

BEFORE starting, check for existing documentation:

1. Read PROJECT-MEMORY.md if it exists:
   - Versions detected
   - Tool/framework choices made
   - Key decisions
   - Lessons learned

2. Read LOGIC-ANOMALIES.md if it exists:
   - Bugs/issues found but not fixed
   - Code smells discovered
   - Areas needing attention

3. Read $setupFile if it exists:
   - Current configuration
   - What's already done
   - Strategies in use

Use this information to:
- Continue from where previous work stopped
- Maintain consistency with existing decisions
- Avoid redoing completed work
- Build upon existing setup

If no docs exist: Start fresh and create them.

"@
}

# DOCUMENTATION section template (customized per process type)
function Get-DocumentationSection {
    param([string]$processType, [string]$setupFile, [string]$language)
    
    $processTitle = $processType -replace "-", " " | ForEach-Object { (Get-Culture).TextInfo.ToTitleCase($_) }
    $setupTitle = $setupFile -replace "-SETUP.md", "" -replace "-", "/" | ForEach-Object { (Get-Culture).TextInfo.ToTitleCase($_) }
    
    return @"

========================================
DOCUMENTATION
========================================

Create/update these files for team catch-up:

**PROJECT-MEMORY.md** (Universal):
``````markdown
# $processTitle Memory

## Detected Versions
- {Tool/Language}: {version}
- {Dependencies}: {versions}

## Tool/Framework Choices
- {Choice}: {Tool} v{version}
- Why: {reason}

## Key Decisions
- {Decision 1}
- {Decision 2}

## Lessons Learned
- {Challenge}
- {Solution}
``````

**LOGIC-ANOMALIES.md** (Universal):
``````markdown
# Logic Anomalies Found

## Issues Discovered (Not Fixed)
1. **File**: path/to/file
   **Issue**: Description
   **Impact**: Severity
   **Note**: Logged only, not fixed

## Code Smells
- {Areas needing refactoring}

## Missing Items
- {Components needing attention}
``````

**$setupFile** (Process-specific):
``````markdown
# $setupTitle Setup Guide

## Quick Start
``````bash
{commands to run}
``````

## Configuration
- {Tool}: v{version}
- {Config location}
- {Key settings}

## Status
- [ ] Item A
- [ ] Item B
- [x] Item C (completed)

## Troubleshooting
- **Issue**: Solution

## Maintenance
- {Common maintenance tasks}
``````

"@
}

# Function to update a single file
function Update-ProcessFile {
    param(
        [string]$filePath,
        [string]$processType
    )
    
    Write-Host "Processing: $filePath" -ForegroundColor Cyan
    
    $content = Get-Content $filePath -Raw -Encoding UTF8
    $setupFile = $setupFiles[$processType]
    $language = Split-Path (Split-Path $filePath -Parent) -Leaf
    
    # Check if already updated (has CATCH-UP section)
    if ($content -match "CATCH-UP: READ EXISTING DOCUMENTATION") {
        Write-Host "  ✓ Already has CATCH-UP section, skipping" -ForegroundColor Green
        return $false
    }
    
    # Find insertion point for CATCH-UP section
    # Insert after TECH STACK or CRITICAL REQUIREMENTS, before PHASE 1
    $catchUpSection = Get-CatchUpSection -processType $processType -setupFile $setupFile
    
    # Pattern 1: After TECH STACK section
    if ($content -match "TECH STACK") {
        $content = $content -replace "(TECH STACK\r?\n========================================\r?\n(?:.*?\r?\n)*?)(========================================\r?\nPHASE 1)", "`$1$catchUpSection`$2"
        Write-Host "  ✓ Added CATCH-UP after TECH STACK" -ForegroundColor Green
    }
    # Pattern 2: After CRITICAL REQUIREMENTS, before PHASE 1
    elseif ($content -match "CRITICAL REQUIREMENTS") {
        $content = $content -replace "(CRITICAL REQUIREMENTS:(?:.*?\r?\n)*?)(========================================\r?\nPHASE 1)", "`$1$catchUpSection`$2"
        Write-Host "  ✓ Added CATCH-UP after CRITICAL REQUIREMENTS" -ForegroundColor Green
    }
    else {
        Write-Host "  ⚠ Could not find insertion point for CATCH-UP" -ForegroundColor Yellow
    }
    
    # Fix file references (underscores to hyphens)
    $content = $content -replace "process-docs/PROJECT_MEMORY\.md", "PROJECT-MEMORY.md"
    $content = $content -replace "PROJECT_MEMORY\.md", "PROJECT-MEMORY.md"
    $content = $content -replace "STATUS-DETAILS\.md", "$setupFile"
    $content = $content -replace "LOGIC_ANOMALIES\.md", "LOGIC-ANOMALIES.md"
    
    # Add or update DOCUMENTATION section
    $docSection = Get-DocumentationSection -processType $processType -setupFile $setupFile -language $language
    
    if ($content -match "DOCUMENTATION") {
        # Update existing DOCUMENTATION section - replace everything between DOCUMENTATION and next section
        $content = $content -replace "(========================================\r?\nDOCUMENTATION\r?\n========================================)(?:.*?\r?\n)*?(========================================\r?\n(?:EXECUTION|BEST PRACTICES))", "`$1$docSection`$2"
        Write-Host "  ✓ Updated DOCUMENTATION section" -ForegroundColor Green
    }
    elseif ($content -match "EXECUTION|BEST PRACTICES") {
        # Add DOCUMENTATION section before EXECUTION or BEST PRACTICES
        $content = $content -replace "(========================================\r?\n(?:EXECUTION|BEST PRACTICES))", "$docSection`$1"
        Write-Host "  ✓ Added DOCUMENTATION section" -ForegroundColor Green
    }
    else {
        Write-Host "  ⚠ Could not find insertion point for DOCUMENTATION" -ForegroundColor Yellow
    }
    
    # Update EXECUTION section to include documentation steps
    if ($content -match "EXECUTION") {
        # Add "Read existing docs" as first step if not present
        if ($content -notmatch "Read existing docs|CATCH-UP section") {
            $content = $content -replace "(EXECUTION\r?\n========================================\r?\n\r?\n)(START:)", "`$1START: Read existing docs (CATCH-UP section)`r`nCONTINUE: "
            Write-Host "  ✓ Updated EXECUTION to include doc reading" -ForegroundColor Green
        }
        
        # Add "document for catch-up" to REMEMBER if not present
        if ($content -notmatch "document for catch-up") {
            $content = $content -replace "(REMEMBER:[^\r\n]*?)(\r?\n```)", "`$1, document for catch-up`$2"
            Write-Host "  ✓ Updated REMEMBER to include documentation" -ForegroundColor Green
        }
        
        # Add "FINISH: Update all documentation files" if not present
        if ($content -notmatch "FINISH:.*documentation") {
            $content = $content -replace "(CONTINUE:[^\r\n]*?)(\r?\nREMEMBER:)", "`$1`r`nFINISH: Update all documentation files`$2"
            Write-Host "  ✓ Added FINISH step for documentation" -ForegroundColor Green
        }
    }
    
    # Write updated content
    Set-Content -Path $filePath -Value $content -Encoding UTF8 -NoNewline
    Write-Host "  ✓ File updated successfully" -ForegroundColor Green
    return $true
}

# Main execution
Write-Host "========================================" -ForegroundColor Magenta
Write-Host "Documentation Pattern Update Script" -ForegroundColor Magenta
Write-Host "========================================" -ForegroundColor Magenta
Write-Host ""

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$baseDir = Join-Path $scriptDir "processes/ondemand"
$totalFiles = 0
$updatedFiles = 0
$skippedFiles = 0

Write-Host "Script directory: $scriptDir" -ForegroundColor Magenta
Write-Host "Base directory: $baseDir" -ForegroundColor Magenta
Write-Host "Base dir exists: $(Test-Path $baseDir)" -ForegroundColor Magenta
Write-Host ""

foreach ($processType in $setupFiles.Keys) {
    Write-Host "`nProcessing category: $processType" -ForegroundColor Yellow
    Write-Host "Setup file: $($setupFiles[$processType])" -ForegroundColor DarkGray
    Write-Host "----------------------------------------" -ForegroundColor DarkGray
    
    $files = Get-ChildItem -Path $baseDir -Recurse -Filter "*$processType.md" -ErrorAction SilentlyContinue
    Write-Host "Found $($files.Count) files for $processType" -ForegroundColor DarkGray
    
    foreach ($file in $files) {
        $totalFiles++
        $updated = Update-ProcessFile -filePath $file.FullName -processType $processType
        if ($updated) {
            $updatedFiles++
        } else {
            $skippedFiles++
        }
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Magenta
Write-Host "Summary" -ForegroundColor Magenta
Write-Host "========================================" -ForegroundColor Magenta
Write-Host "Total files processed: $totalFiles" -ForegroundColor Cyan
Write-Host "Files updated: $updatedFiles" -ForegroundColor Green
Write-Host "Files skipped: $skippedFiles" -ForegroundColor Yellow
Write-Host ""
Write-Host "✓ All files processed!" -ForegroundColor Green
