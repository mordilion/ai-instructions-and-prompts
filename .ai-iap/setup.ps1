#Requires -Version 5.1
<#
.SYNOPSIS
    AI Instructions and Prompts Setup Script
    Configures AI coding assistants with standardized instructions

.DESCRIPTION
    This script sets up AI coding assistant configurations for various tools
    including Cursor, Claude CLI, GitHub Copilot, Windsurf, and Aider.

.EXAMPLE
    .\.ai-iap\setup.ps1
#>

# Removed StrictMode and CmdletBinding due to compatibility issues
$ErrorActionPreference = "Stop"

# ============================================================================
# Constants
# ============================================================================

$Script:Version = "1.0.0"
$Script:ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$Script:ProjectRoot = Split-Path -Parent $Script:ScriptDir
$Script:ConfigFile = Join-Path $Script:ScriptDir "config.json"

# ============================================================================
# Utility Functions
# ============================================================================

function Write-Header {
    Write-Host ""
    Write-Host "==================================================================" -ForegroundColor Cyan
    Write-Host "        AI Instructions and Prompts Setup v$Script:Version             " -ForegroundColor Cyan
    Write-Host "==================================================================" -ForegroundColor Cyan
    Write-Host ""
}

function Write-SuccessMessage { 
    Write-Host "[OK] " -ForegroundColor Green -NoNewline
    Write-Host $args[0]
}

function Write-ErrorMessage { 
    Write-Host "[ERROR] " -ForegroundColor Red -NoNewline
    Write-Host $args[0]
}

function Write-WarningMessage { 
    Write-Host "[WARN] " -ForegroundColor Yellow -NoNewline
    Write-Host $args[0]
}

function Write-InfoMessage { 
    Write-Host "[INFO] " -ForegroundColor Blue -NoNewline
    Write-Host $args[0]
}

# ============================================================================
# Configuration Loading
# ============================================================================

function Get-Configuration {
    if (-not (Test-Path $Script:ConfigFile)) {
        throw "Config file not found: $Script:ConfigFile"
    }
    
    $config = Get-Content $Script:ConfigFile -Raw | ConvertFrom-Json
    return $config
}

# ============================================================================
# Selection UI
# ============================================================================

function Select-Tools {
    param([PSCustomObject]$Config)
    
    $tools = @()
    $toolKeys = @()
    
    foreach ($key in $Config.tools.PSObject.Properties.Name) {
        $toolKeys += $key
        $tools += $Config.tools.$key.name
    }
    
    Write-Host "Select AI tools to configure:" -ForegroundColor White
    Write-Host ""
    
    for ($i = 0; $i -lt $tools.Count; $i++) {
        $suffix = ""
        if ($Config.tools.$($toolKeys[$i]).recommended -eq $true) {
            $suffix = " *"
        }
        Write-Host "  $($i + 1). $($tools[$i])$suffix"
    }
    Write-Host ""
    Write-Host "  * = recommended" -ForegroundColor DarkGray
    Write-Host "  a. All tools"
    Write-Host ""
    
    $input = Read-Host "Enter choices (e.g., 1 3 or 'a' for all)"
    
    $selectedTools = @()
    
    if ($input -eq 'a' -or $input -eq 'A') {
        $selectedTools = $toolKeys
    }
    else {
        $choices = $input -split '\s+'
        foreach ($num in $choices) {
            $idx = [int]$num - 1
            if ($idx -ge 0 -and $idx -lt $toolKeys.Count) {
                $selectedTools += $toolKeys[$idx]
            }
        }
    }
    
    return $selectedTools
}

function Select-Languages {
    param([PSCustomObject]$Config)
    
    $languages = @()
    $langKeys = @()
    $alwaysApplyLangs = @()
    
    foreach ($key in $Config.languages.PSObject.Properties.Name) {
        # Track languages with alwaysApply (like "general")
        if ($Config.languages.$key.alwaysApply -eq $true) {
            $alwaysApplyLangs += $key
        }
        $langKeys += $key
        $languages += $Config.languages.$key.name
    }
    
    Write-Host ""
    Write-Host "Select language instructions to include:" -ForegroundColor White
    Write-Host "(General rules are always included automatically)" -ForegroundColor DarkGray
    Write-Host ""
    
    for ($i = 0; $i -lt $languages.Count; $i++) {
        $suffix = ""
        if ($Config.languages.$($langKeys[$i]).alwaysApply -eq $true) {
            $suffix = " (always included)"
        }
        Write-Host "  $($i + 1). $($languages[$i])$suffix"
    }
    Write-Host "  a. All languages"
    Write-Host ""
    
    $input = Read-Host "Enter choices (e.g., 1 2 4 or 'a' for all)"
    
    $selectedLanguages = @()
    
    if ($input -eq 'a' -or $input -eq 'A') {
        $selectedLanguages = $langKeys
    }
    else {
        $choices = $input -split '\s+'
        foreach ($num in $choices) {
            $idx = [int]$num - 1
            if ($idx -ge 0 -and $idx -lt $langKeys.Count) {
                $selectedLanguages += $langKeys[$idx]
            }
        }
    }
    
    # Always include languages with alwaysApply: true
    foreach ($alwaysLang in $alwaysApplyLangs) {
        if ($selectedLanguages -notcontains $alwaysLang) {
            $selectedLanguages = @($alwaysLang) + $selectedLanguages
        }
    }
    
    return $selectedLanguages
}

function Select-Frameworks {
    param(
        [PSCustomObject]$Config,
        [string[]]$SelectedLanguages
    )
    
    $selectedFrameworks = @{}
    
    foreach ($lang in $SelectedLanguages) {
        $langConfig = $Config.languages.$lang
        
        # Skip if no frameworks defined for this language
        if (-not $langConfig.frameworks) {
            continue
        }
        
        # Group frameworks by category
        $categories = @{}
        $frameworkKeys = @()
        $index = 0
        
        foreach ($key in $langConfig.frameworks.PSObject.Properties.Name) {
            $fw = $langConfig.frameworks.$key
            $category = if ($fw.category) { $fw.category } else { "Other" }
            
            if (-not $categories.ContainsKey($category)) {
                $categories[$category] = @()
            }
            $categories[$category] += @{
                Key = $key
                Name = $fw.name
                Description = $fw.description
                Index = $index
                Recommended = $fw.recommended -eq $true
            }
            $frameworkKeys += $key
            $index++
        }
        
        if ($frameworkKeys.Count -eq 0) {
            continue
        }
        
        Write-Host ""
        Write-Host "Select frameworks for $($langConfig.name):" -ForegroundColor White
        Write-Host "(You can combine multiple - e.g., Web Framework + ORM)" -ForegroundColor DarkGray
        Write-Host ""
        
        foreach ($category in $categories.Keys | Sort-Object) {
            Write-Host "  [$category]" -ForegroundColor Cyan
            foreach ($fw in $categories[$category]) {
                $suffix = if ($fw.Recommended) { " *" } else { "" }
                Write-Host "    $($fw.Index + 1). $($fw.Name)$suffix - $($fw.Description)"
            }
        }
        Write-Host ""
        Write-Host "  * = recommended" -ForegroundColor DarkGray
        Write-Host "  s. Skip (no frameworks)"
        Write-Host "  a. All frameworks"
        Write-Host ""
        
        $input = Read-Host "Enter choices (e.g., 1 3 5 or 'a' for all, 's' to skip)"
        
        $langFrameworks = @()
        
        if ($input -eq 's' -or $input -eq 'S') {
            # Skip - no frameworks for this language
        }
        elseif ($input -eq 'a' -or $input -eq 'A') {
            $langFrameworks = $frameworkKeys
        }
        else {
            $choices = $input -split '\s+'
            foreach ($num in $choices) {
                $idx = [int]$num - 1
                if ($idx -ge 0 -and $idx -lt $frameworkKeys.Count) {
                    $langFrameworks += $frameworkKeys[$idx]
                }
            }
        }
        
        if ($langFrameworks.Count -gt 0) {
            $selectedFrameworks[$lang] = $langFrameworks
        }
    }
    
    return $selectedFrameworks
}

function Select-Structures {
    param(
        [PSCustomObject]$Config,
        [string[]]$SelectedLanguages,
        [hashtable]$SelectedFrameworks
    )
    
    $selectedStructures = @{}
    
    foreach ($lang in $SelectedLanguages) {
        if (-not $SelectedFrameworks.ContainsKey($lang)) {
            continue
        }
        
        $langConfig = $Config.languages.$lang
        
        foreach ($fwKey in $SelectedFrameworks[$lang]) {
            $fw = $langConfig.frameworks.$fwKey
            
            # Skip if no structures defined for this framework
            if (-not $fw.structures) {
                continue
            }
            
            $structures = @()
            $structureKeys = @()
            $index = 0
            
            foreach ($key in $fw.structures.PSObject.Properties.Name) {
                $struct = $fw.structures.$key
                $structureKeys += $key
                $structures += @{
                    Key = $key
                    Name = $struct.name
                    Description = $struct.description
                    File = $struct.file
                    Index = $index
                    Recommended = $struct.recommended -eq $true
                }
                $index++
            }
            
            if ($structures.Count -eq 0) {
                continue
            }
            
            Write-Host ""
            Write-Host "Select structure for $($fw.name):" -ForegroundColor White
            Write-Host ""
            
            foreach ($struct in $structures) {
                $suffix = if ($struct.Recommended) { " *" } else { "" }
                Write-Host "  $($struct.Index + 1). $($struct.Name)$suffix - $($struct.Description)"
            }
            Write-Host ""
            Write-Host "  * = recommended" -ForegroundColor DarkGray
            Write-Host "  s. Skip (use default patterns only)"
            Write-Host ""
            
            $input = Read-Host "Enter choice (1-$($structures.Count) or 's' to skip)"
            
            if ($input -ne 's' -and $input -ne 'S') {
                $idx = [int]$input - 1
                if ($idx -ge 0 -and $idx -lt $structureKeys.Count) {
                    $structKey = "$lang-$fwKey"
                    $selectedStructures[$structKey] = $structures[$idx].File
                }
            }
        }
    }
    
    return $selectedStructures
}

# ============================================================================
# File Generation
# ============================================================================

function Read-InstructionFile {
    param(
        [string]$Lang,
        [string]$File,
        [bool]$IsFramework = $false,
        [bool]$IsStructure = $false
    )
    
    # Processes folder is at root level, others are under rules/
    if ($Lang -eq "processes") {
        $filePath = Join-Path $Script:ScriptDir "processes\$File.md"
    } elseif ($IsStructure) {
        $filePath = Join-Path $Script:ScriptDir "rules\$Lang\frameworks\structures\$File.md"
    } elseif ($IsFramework) {
        $filePath = Join-Path $Script:ScriptDir "rules\$Lang\frameworks\$File.md"
    } else {
        $filePath = Join-Path $Script:ScriptDir "rules\$Lang\$File.md"
    }
    
    if (Test-Path $filePath) {
        return Get-Content $filePath -Raw -Encoding UTF8
    }
    else {
        Write-WarningMessage "File not found: $filePath"
        return $null
    }
}

function New-CursorFrontmatter {
    param(
        [PSCustomObject]$Config,
        [string]$Lang,
        [string]$File,
        [bool]$IsFramework = $false
    )
    
    $langConfig = $Config.languages.$Lang
    $globs = $langConfig.globs
    $alwaysApply = $langConfig.alwaysApply.ToString().ToLower()
    
    if ($IsFramework) {
        $fw = $langConfig.frameworks.$File
        $description = "$($langConfig.name) - $($fw.name)"
    }
    else {
        $description = "$($langConfig.description) - $File"
    }
    
    $frontmatter = @"
---
alwaysApply: $alwaysApply
description: $description
globs: $globs
---

"@
    
    return $frontmatter
}

function New-CursorConfig {
    param(
        [PSCustomObject]$Config,
        [string[]]$SelectedLanguages,
        [hashtable]$SelectedFrameworks,
        [hashtable]$SelectedStructures
    )
    
    $outputDir = Join-Path $Script:ProjectRoot ".cursor\rules"
    
    Write-InfoMessage "Generating Cursor rules..."
    
    foreach ($lang in $SelectedLanguages) {
        $langDir = Join-Path $outputDir $lang
        
        if (-not (Test-Path $langDir)) {
            New-Item -ItemType Directory -Path $langDir -Force | Out-Null
        }
        
        # Generate base language files
        $files = $Config.languages.$lang.files
        
        foreach ($file in $files) {
            $content = Read-InstructionFile -Lang $lang -File $file
            
            if ($null -eq $content) {
                continue
            }
            
            $outputFile = Join-Path $langDir "$file.mdc"
            $frontmatter = New-CursorFrontmatter -Config $Config -Lang $lang -File $file
            
            $fullContent = $frontmatter + $content
            $fullContent | Out-File -FilePath $outputFile -Encoding UTF8 -NoNewline
            
            $relativePath = $outputFile.Replace($Script:ProjectRoot, "").TrimStart("\", "/")
            Write-SuccessMessage "Created $relativePath"
        }
        
        # Generate framework files for this language
        if ($SelectedFrameworks.ContainsKey($lang)) {
            foreach ($fw in $SelectedFrameworks[$lang]) {
                $fwConfig = $Config.languages.$lang.frameworks.$fw
                $content = Read-InstructionFile -Lang $lang -File $fwConfig.file -IsFramework $true
                
                if ($null -eq $content) {
                    continue
                }
                
                $outputFile = Join-Path $langDir "$($fwConfig.file).mdc"
                $frontmatter = New-CursorFrontmatter -Config $Config -Lang $lang -File $fw -IsFramework $true
                
                $fullContent = $frontmatter + $content
                $fullContent | Out-File -FilePath $outputFile -Encoding UTF8 -NoNewline
                
                $relativePath = $outputFile.Replace($Script:ProjectRoot, "").TrimStart("\", "/")
                Write-SuccessMessage "Created $relativePath"
                
                # Generate structure file if selected
                $structKey = "$lang-$fw"
                if ($SelectedStructures.ContainsKey($structKey)) {
                    $structFile = $SelectedStructures[$structKey]
                    $structContent = Read-InstructionFile -Lang $lang -File $structFile -IsStructure $true
                    
                    if ($null -ne $structContent) {
                        $structOutputFile = Join-Path $langDir "$structFile.mdc"
                        $structFrontmatter = New-CursorFrontmatter -Config $Config -Lang $lang -File $fw -IsFramework $true
                        
                        $fullStructContent = $structFrontmatter + $structContent
                        $fullStructContent | Out-File -FilePath $structOutputFile -Encoding UTF8 -NoNewline
                        
                        $relativePath = $structOutputFile.Replace($Script:ProjectRoot, "").TrimStart("\", "/")
                        Write-SuccessMessage "Created $relativePath"
                    }
                }
            }
        }
    }
}

function New-ConcatenatedConfig {
    param(
        [PSCustomObject]$Config,
        [string]$ToolName,
        [string]$OutputFile,
        [string[]]$SelectedLanguages,
        [hashtable]$SelectedFrameworks,
        [hashtable]$SelectedStructures
    )
    
    Write-InfoMessage "Generating $ToolName configuration..."
    
    $fullPath = Join-Path $Script:ProjectRoot $OutputFile
    $parentDir = Split-Path -Parent $fullPath
    
    if (-not (Test-Path $parentDir)) {
        New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
    }
    
    $content = @"
# AI Coding Instructions

<!-- Generated by AI Instructions and Prompts Setup -->
<!-- https://github.com/your-repo/ai-instructions-and-prompts -->

"@
    
    foreach ($lang in $SelectedLanguages) {
        # Add base language files
        $files = $Config.languages.$lang.files
        
        foreach ($file in $files) {
            $fileContent = Read-InstructionFile -Lang $lang -File $file
            
            if ($null -ne $fileContent) {
                $content += $fileContent + "`n`n---`n`n"
            }
        }
        
        # Add framework files for this language
        if ($SelectedFrameworks.ContainsKey($lang)) {
            foreach ($fw in $SelectedFrameworks[$lang]) {
                $fwConfig = $Config.languages.$lang.frameworks.$fw
                $fileContent = Read-InstructionFile -Lang $lang -File $fwConfig.file -IsFramework $true
                
                if ($null -ne $fileContent) {
                    $content += $fileContent + "`n`n---`n`n"
                }
                
                # Add structure file if selected
                $structKey = "$lang-$fw"
                if ($SelectedStructures.ContainsKey($structKey)) {
                    $structFile = $SelectedStructures[$structKey]
                    $structContent = Read-InstructionFile -Lang $lang -File $structFile -IsStructure $true
                    
                    if ($null -ne $structContent) {
                        $content += $structContent + "`n`n---`n`n"
                    }
                }
            }
        }
    }
    
    $content | Out-File -FilePath $fullPath -Encoding UTF8 -NoNewline
    
    Write-SuccessMessage "Created $OutputFile"
}

function New-ToolConfig {
    param(
        [PSCustomObject]$Config,
        [string]$Tool,
        [string[]]$SelectedLanguages,
        [hashtable]$SelectedFrameworks,
        [hashtable]$SelectedStructures
    )
    
    switch ($Tool) {
        "cursor" {
            New-CursorConfig -Config $Config -SelectedLanguages $SelectedLanguages -SelectedFrameworks $SelectedFrameworks -SelectedStructures $SelectedStructures
        }
        "claude-cli" {
            New-ConcatenatedConfig -Config $Config -ToolName "Claude CLI" -OutputFile "CLAUDE.md" -SelectedLanguages $SelectedLanguages -SelectedFrameworks $SelectedFrameworks -SelectedStructures $SelectedStructures
        }
        "github-copilot" {
            New-ConcatenatedConfig -Config $Config -ToolName "GitHub Copilot" -OutputFile ".github\copilot-instructions.md" -SelectedLanguages $SelectedLanguages -SelectedFrameworks $SelectedFrameworks -SelectedStructures $SelectedStructures
        }
        "windsurf" {
            New-ConcatenatedConfig -Config $Config -ToolName "Windsurf" -OutputFile ".windsurfrules" -SelectedLanguages $SelectedLanguages -SelectedFrameworks $SelectedFrameworks -SelectedStructures $SelectedStructures
        }
        "aider" {
            New-ConcatenatedConfig -Config $Config -ToolName "Aider" -OutputFile "CONVENTIONS.md" -SelectedLanguages $SelectedLanguages -SelectedFrameworks $SelectedFrameworks -SelectedStructures $SelectedStructures
        }
        default {
            Write-WarningMessage "Unknown tool: $Tool"
        }
    }
}

# ============================================================================
# Gitignore Management
# ============================================================================

function Add-ToGitignore {
    Write-Host ""
    $response = Read-Host "Add .ai-iap/ to .gitignore? (y/N)"
    
    if ($response -eq 'y' -or $response -eq 'Y') {
        $gitignorePath = Join-Path $Script:ProjectRoot ".gitignore"
        
        if (Test-Path $gitignorePath) {
            $content = Get-Content $gitignorePath -Raw
            
            if ($content -notmatch "^\.ai-iap/") {
                $addition = @"

# AI Instructions source (generated files committed instead)
.ai-iap/
"@
                Add-Content -Path $gitignorePath -Value $addition
                Write-SuccessMessage "Added .ai-iap/ to .gitignore"
            }
            else {
                Write-InfoMessage ".ai-iap/ already in .gitignore"
            }
        }
        else {
            $content = @"
# AI Instructions source (generated files committed instead)
.ai-iap/
"@
            $content | Out-File -FilePath $gitignorePath -Encoding UTF8
            Write-SuccessMessage "Created .gitignore with .ai-iap/"
        }
    }
}

# ============================================================================
# Main
# ============================================================================

function Main {
    Write-Header
    
    try {
        $config = Get-Configuration
    }
    catch {
        Write-ErrorMessage $_.Exception.Message
        exit 1
    }
    
    Set-Location $Script:ProjectRoot
    Write-InfoMessage "Project root: $Script:ProjectRoot"
    Write-Host ""
    
    # Selection
    $selectedTools = Select-Tools -Config $config
    
    if ($selectedTools.Count -eq 0) {
        Write-WarningMessage "No tools selected. Exiting."
        exit 0
    }
    
    $selectedLanguages = Select-Languages -Config $config
    
    if ($selectedLanguages.Count -eq 0) {
        Write-WarningMessage "No languages selected. Exiting."
        exit 0
    }
    
    # Framework selection
    $selectedFrameworks = Select-Frameworks -Config $config -SelectedLanguages $selectedLanguages
    
    # Structure selection (for frameworks that have structure options)
    $selectedStructures = Select-Structures -Config $config -SelectedLanguages $selectedLanguages -SelectedFrameworks $selectedFrameworks
    
    Write-Host ""
    Write-Host "Configuration Summary:" -ForegroundColor White
    Write-Host "  Tools: $($selectedTools -join ', ')"
    Write-Host "  Languages: $($selectedLanguages -join ', ')"
    
    if ($selectedFrameworks.Count -gt 0) {
        foreach ($lang in $selectedFrameworks.Keys) {
            Write-Host "  Frameworks ($lang): $($selectedFrameworks[$lang] -join ', ')"
        }
    }
    if ($selectedStructures.Count -gt 0) {
        foreach ($key in $selectedStructures.Keys) {
            Write-Host "  Structure ($key): $($selectedStructures[$key])"
        }
    }
    Write-Host ""
    
    $confirm = Read-Host "Proceed with generation? (Y/n)"
    if ($confirm -eq 'n' -or $confirm -eq 'N') {
        Write-InfoMessage "Aborted."
        exit 0
    }
    
    Write-Host ""
    
    # Generate files
    foreach ($tool in $selectedTools) {
        New-ToolConfig -Config $config -Tool $tool -SelectedLanguages $selectedLanguages -SelectedFrameworks $selectedFrameworks -SelectedStructures $selectedStructures
    }
    
    # Gitignore prompt
    Add-ToGitignore
    
    Write-Host ""
    Write-Host "Setup complete!" -ForegroundColor Green
    Write-Host ""
}

Main
