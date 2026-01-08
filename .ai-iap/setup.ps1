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
$Script:CustomConfigFile = Join-Path $Script:ProjectRoot ".ai-iap-custom\config.json"
$Script:CustomRulesDir = Join-Path $Script:ProjectRoot ".ai-iap-custom\rules"
$Script:CustomProcessesDir = Join-Path $Script:ProjectRoot ".ai-iap-custom\processes"
$Script:MergedConfigFile = Join-Path $env:TEMP "ai-iap-merged-config-$PID.json"
$Script:WorkingConfig = $Script:ConfigFile

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
        Write-ErrorMessage "Config file not found: $Script:ConfigFile"
        Write-Host ""
        Write-Host "This usually means you're running the script from the wrong directory." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Solution:" -ForegroundColor Cyan
        Write-Host "  1. Navigate to your project root directory" -ForegroundColor White
        Write-Host "  2. Run: cd `"$Script:ProjectRoot`"" -ForegroundColor White
        Write-Host "  3. Then run: .\`".ai-iap\setup.ps1`"" -ForegroundColor White
        Write-Host ""
        exit 1
    }
    
    try {
        $config = Get-Content $Script:ConfigFile -Raw | ConvertFrom-Json
        
        # Merge custom config if exists
        Merge-CustomConfig
        
        # Load from working config (might be merged)
        $config = Get-Content $Script:WorkingConfig -Raw | ConvertFrom-Json
        return $config
    } catch {
        Write-ErrorMessage "Failed to parse config file: $Script:ConfigFile"
        Write-Host ""
        Write-Host "The config.json file exists but contains invalid JSON." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Solution:" -ForegroundColor Cyan
        Write-Host "  1. Validate JSON syntax: jq empty `"$Script:ConfigFile`"" -ForegroundColor White
        Write-Host "  2. Check for common issues:" -ForegroundColor White
        Write-Host "     - Missing or extra commas" -ForegroundColor White
        Write-Host "     - Unmatched brackets/braces" -ForegroundColor White
        Write-Host "     - Missing quotes around strings" -ForegroundColor White
        Write-Host "  3. Or restore from git: git checkout $Script:ConfigFile" -ForegroundColor White
        Write-Host ""
        Write-Host "Error details: $($_.Exception.Message)" -ForegroundColor DarkGray
        Write-Host ""
        exit 1
    }
}

function Merge-CustomConfig {
    # Check if custom config exists
    if (-not (Test-Path $Script:CustomConfigFile)) {
        Write-InfoMessage "No custom config found (optional)"
        return
    }
    
    Write-InfoMessage "Found custom config: .ai-iap-custom\config.json"
    
    # Validate custom config JSON
    try {
        $customConfig = Get-Content $Script:CustomConfigFile -Raw | ConvertFrom-Json
    } catch {
        Write-ErrorMessage "Custom config file contains invalid JSON"
        Write-Host ""
        Write-Host "Please fix .ai-iap-custom\config.json" -ForegroundColor Yellow
        Write-Host ""
        exit 1
    }
    
    # Load core config
    $coreConfig = Get-Content $Script:ConfigFile -Raw | ConvertFrom-Json
    
    # Deep merge function
    function Merge-Objects {
        param($Target, $Source)
        
        foreach ($property in $Source.PSObject.Properties) {
            if ($Target.PSObject.Properties.Name -contains $property.Name) {
                if ($property.Value -is [PSCustomObject] -and $Target.($property.Name) -is [PSCustomObject]) {
                    # Recursively merge objects
                    Merge-Objects -Target $Target.($property.Name) -Source $property.Value
                } else {
                    # Override value
                    $Target.($property.Name) = $property.Value
                }
            } else {
                # Add new property
                $Target | Add-Member -MemberType NoteProperty -Name $property.Name -Value $property.Value -Force
            }
        }
    }
    
    # Merge custom into core
    Merge-Objects -Target $coreConfig -Source $customConfig
    
    # Save merged config to temp file
    $coreConfig | ConvertTo-Json -Depth 100 | Out-File -FilePath $Script:MergedConfigFile -Encoding UTF8
    
    Write-SuccessMessage "Merged custom configuration"
    
    # Update working config to point to merged
    $Script:WorkingConfig = $Script:MergedConfigFile
}

# ============================================================================
# Selection UI
# ============================================================================

function Get-ValidatedSelection {
    param(
        [string]$Prompt,
        [array]$Options,
        [int]$MaxValue,
        [bool]$AllowEmpty = $false,
        [bool]$AllowSkip = $false
    )
    
    while ($true) {
        $userInput = Read-Host $Prompt
        
        $selected = @()
        $isValid = $true
        
        if ($userInput -eq 'a' -or $userInput -eq 'A') {
            $selected = $Options
            break
        } elseif (($userInput -eq 's' -or $userInput -eq 'S') -and $AllowSkip) {
            # Return empty array for skip
            break
        } elseif ([string]::IsNullOrWhiteSpace($userInput)) {
            if ($AllowEmpty -or $AllowSkip) {
                break
            }
            Write-Host ""
            Write-ErrorMessage "No selection made."
            $skipMsg = if ($AllowSkip) { ", 's' to skip," } else { "" }
            Write-Host "Please enter at least one number$skipMsg or 'a' for all." -ForegroundColor Yellow
            Write-Host ""
            continue
        } else {
            $choices = $userInput -split '\s+' | Where-Object { $_ -ne '' }
            foreach ($num in $choices) {
                if ($num -notmatch '^\d+$') {
                    Write-Host ""
                    Write-ErrorMessage "Invalid input: '$num'"
                    $skipMsg = if ($AllowSkip) { ", 's' to skip," } else { "" }
                    Write-Host "Please enter numbers only (e.g., 1 2 3)$skipMsg or 'a' for all." -ForegroundColor Yellow
                    Write-Host ""
                    $isValid = $false
                    break
                }
                
                $idx = [int]$num - 1
                if ($idx -lt 0 -or $idx -ge $MaxValue) {
                    Write-Host ""
                    Write-ErrorMessage "Invalid choice: $num"
                    Write-Host "Please enter a number between 1 and $MaxValue." -ForegroundColor Yellow
                    Write-Host ""
                    $isValid = $false
                    break
                }
                $selected += $Options[$idx]
            }
            
            if ($isValid -and $selected.Count -gt 0) {
                break
            } elseif ($isValid -and ($AllowEmpty -or $AllowSkip)) {
                break
            } elseif ($selected.Count -eq 0 -and $isValid) {
                Write-Host ""
                Write-ErrorMessage "No valid items selected."
                Write-Host "Please enter at least one valid number." -ForegroundColor Yellow
                Write-Host ""
            }
        }
    }
    
    return $selected
}

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
    
    $selectedTools = Get-ValidatedSelection `
        -Prompt "Enter choices (e.g., 1 3 or 'a' for all)" `
        -Options $toolKeys `
        -MaxValue $toolKeys.Count `
        -AllowEmpty $false
    
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
    
    $selectedLanguages = Get-ValidatedSelection `
        -Prompt "Enter choices (e.g., 1 2 4 or 'a' for all)" `
        -Options $langKeys `
        -MaxValue $langKeys.Count `
        -AllowEmpty $false
    
    # Always include languages with alwaysApply: true
    foreach ($alwaysLang in $alwaysApplyLangs) {
        if ($selectedLanguages -notcontains $alwaysLang) {
            $selectedLanguages = @($alwaysLang) + $selectedLanguages
        }
    }
    
    return $selectedLanguages
}

function Select-Documentation {
    param(
        [PSCustomObject]$Config,
        [string[]]$SelectedLanguages
    )
    
    # Check if documentation options exist
    if (-not $Config.languages.general.documentation) {
        return @()
    }
    
    $docKeys = @()
    $docNames = @()
    $docDescs = @()
    $docRecs = @()
    
    foreach ($key in $Config.languages.general.documentation.PSObject.Properties.Name) {
        $docKeys += $key
        $docNames += $Config.languages.general.documentation.$key.name
        $docDescs += $Config.languages.general.documentation.$key.description
        $docRecs += $Config.languages.general.documentation.$key.recommended
    }
    
    if ($docKeys.Count -eq 0) {
        return @()
    }
    
    # Determine project type based on selected languages
    $hasBackend = $false
    $hasFrontendOnly = $false
    
    foreach ($lang in $SelectedLanguages) {
        switch ($lang) {
            "dart" {
                $hasFrontendOnly = $true
            }
            { $_ -in @("typescript", "python", "dotnet", "java", "php", "kotlin", "swift") } {
                $hasBackend = $true
            }
        }
    }
    
    Write-Host ""
    Write-Host "Select documentation standards to include:" -ForegroundColor White
    Write-Host "(Choose based on your project type)" -ForegroundColor DarkGray
    Write-Host ""
    
    for ($i = 0; $i -lt $docKeys.Count; $i++) {
        $suffix = ""
        $key = $docKeys[$i]
        
        # Check if recommended
        if ($docRecs[$i] -eq $true) {
            $suffix = " ⭐"
        }
        
        # Check applicability
        $applicableTo = $Config.languages.general.documentation.$key.applicableTo
        if ($applicableTo -contains "backend" -or $applicableTo -contains "fullstack") {
            $suffix += " (backend/fullstack)" | Write-Host -ForegroundColor DarkGray -NoNewline
            $suffix = ""
        }
        
        Write-Host "  $($i + 1). $($docNames[$i])$suffix"
        Write-Host "      $($docDescs[$i])" -ForegroundColor DarkGray
    }
    Write-Host ""
    Write-Host "  ⭐ = recommended" -ForegroundColor DarkGray
    Write-Host "  a. All documentation"
    Write-Host "  s. Skip (no documentation standards)"
    Write-Host ""
    
    # Provide smart default suggestion
    if ($hasFrontendOnly -and -not $hasBackend) {
        Write-Host "Suggestion for frontend-only project: 1 2 (code + project)" -ForegroundColor DarkGray
    } elseif ($hasBackend) {
        Write-Host "Suggestion for backend/fullstack project: a (all)" -ForegroundColor DarkGray
    }
    
    $input = Read-Host "Enter choices (e.g., 1 2 or 'a' for all, 's' to skip)"
    
    $selectedDocumentation = @()
    
    if ($input -eq "s" -or $input -eq "S") {
        return @()
    } elseif ($input -eq "a" -or $input -eq "A") {
        foreach ($key in $docKeys) {
            $selectedDocumentation += $Config.languages.general.documentation.$key.file
        }
    } else {
        foreach ($num in $input.Split(" ")) {
            $idx = [int]$num - 1
            if ($idx -ge 0 -and $idx -lt $docKeys.Count) {
                $selectedDocumentation += $Config.languages.general.documentation.$($docKeys[$idx]).file
            }
        }
    }
    
    return $selectedDocumentation
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
        
        $langFrameworks = Get-ValidatedSelection `
            -Prompt "Enter choices (e.g., 1 3 5 or 'a' for all, 's' to skip)" `
            -Options $frameworkKeys `
            -MaxValue $frameworkKeys.Count `
            -AllowEmpty $false `
            -AllowSkip $true
        
        if ($langFrameworks.Count -gt 0) {
            $selectedFrameworks[$lang] = $langFrameworks
        }
    }
    
    return $selectedFrameworks
}

function Select-Processes {
    param(
        [PSCustomObject]$Config,
        [string[]]$SelectedLanguages
    )
    
    $selectedProcesses = @{}
    
    foreach ($lang in $SelectedLanguages) {
        $langConfig = $Config.languages.$lang
        
        # Skip if no processes defined for this language
        if (-not $langConfig.processes) {
            continue
        }
        
        $processKeys = @()
        $processes = @()
        $index = 0
        
        foreach ($key in $langConfig.processes.PSObject.Properties.Name) {
            $proc = $langConfig.processes.$key
            $processKeys += $key
            $processes += @{
                Key = $key
                Name = $proc.name
                Description = $proc.description
                File = $proc.file
                Index = $index
            }
            $index++
        }
        
        if ($processes.Count -eq 0) {
            continue
        }
        
        Write-Host ""
        Write-Host "Select processes for $($langConfig.name):" -ForegroundColor White
        Write-Host "(Workflow guides for establishing infrastructure)" -ForegroundColor DarkGray
        Write-Host ""
        
        foreach ($proc in $processes) {
            Write-Host "  $($proc.Index + 1). $($proc.Name) - $($proc.Description)"
        }
        Write-Host ""
        Write-Host "  s. Skip (no processes)"
        Write-Host "  a. All processes"
        Write-Host ""
        
        $langProcesses = Get-ValidatedSelection `
            -Prompt "Enter choices (e.g., 1 2 or 'a' for all, 's' to skip)" `
            -Options $processKeys `
            -MaxValue $processKeys.Count `
            -AllowEmpty $false `
            -AllowSkip $true
        
        if ($langProcesses.Count -gt 0) {
            $selectedProcesses[$lang] = $langProcesses
        }
    }
    
    return $selectedProcesses
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
            
            $choice = Read-Host "Enter choice (1-$($structures.Count) or 's' to skip)"
            
            if ($choice -ne 's' -and $choice -ne 'S') {
                $idx = [int]$choice - 1
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
        [bool]$IsStructure = $false,
        [bool]$IsProcess = $false
    )
    
    if ($IsProcess) {
        $filePath = Join-Path $Script:ScriptDir "processes\$Lang\$File.md"
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
    $alwaysApply = if ($langConfig.alwaysApply -ne $null) { $langConfig.alwaysApply.ToString().ToLower() } else { "false" }
    
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
        [hashtable]$SelectedStructures,
        [hashtable]$SelectedProcesses
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
            
            # Create parent directory if it doesn't exist (for nested files)
            $parentDir = Split-Path -Parent $outputFile
            if (-not (Test-Path $parentDir)) {
                New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
            }
            
            $frontmatter = New-CursorFrontmatter -Config $Config -Lang $lang -File $file
            
            $fullContent = $frontmatter + $content
            $fullContent | Out-File -FilePath $outputFile -Encoding UTF8 -NoNewline
            
            $relativePath = $outputFile.Replace($Script:ProjectRoot, "").TrimStart("\", "/")
            Write-SuccessMessage "Created $relativePath"
        }
        
        # Generate selected documentation files (only for general language)
        if ($lang -eq "general" -and $SelectedDocumentation.Count -gt 0) {
            foreach ($docFile in $SelectedDocumentation) {
                $content = Read-InstructionFile -Lang $lang -File $docFile
                
                if ($null -eq $content) {
                    continue
                }
                
                $outputFile = Join-Path $langDir "$docFile.mdc"
                
                # Create parent directory if it doesn't exist (for nested files)
                $parentDir = Split-Path -Parent $outputFile
                if (-not (Test-Path $parentDir)) {
                    New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
                }
                
                $frontmatter = New-CursorFrontmatter -Config $Config -Lang $lang -File $docFile
                
                $fullContent = $frontmatter + $content
                $fullContent | Out-File -FilePath $outputFile -Encoding UTF8 -NoNewline
                
                $relativePath = $outputFile.Replace($Script:ProjectRoot, "").TrimStart("\", "/")
                Write-SuccessMessage "Created $relativePath"
            }
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
                
                # Create parent directory if it doesn't exist (for nested files)
                $parentDir = Split-Path -Parent $outputFile
                if (-not (Test-Path $parentDir)) {
                    New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
                }
                
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
                        
                        # Create parent directory if it doesn't exist (for nested files)
                        $parentDir = Split-Path -Parent $structOutputFile
                        if (-not (Test-Path $parentDir)) {
                            New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
                        }
                        
                        $structFrontmatter = New-CursorFrontmatter -Config $Config -Lang $lang -File $fw -IsFramework $true
                        
                        $fullStructContent = $structFrontmatter + $structContent
                        $fullStructContent | Out-File -FilePath $structOutputFile -Encoding UTF8 -NoNewline
                        
                        $relativePath = $structOutputFile.Replace($Script:ProjectRoot, "").TrimStart("\", "/")
                        Write-SuccessMessage "Created $relativePath"
                    }
                }
            }
        }
        
        # Generate process files for this language
        if ($SelectedProcesses.ContainsKey($lang)) {
            foreach ($proc in $SelectedProcesses[$lang]) {
                $procConfig = $Config.languages.$lang.processes.$proc
                $content = Read-InstructionFile -Lang $lang -File $procConfig.file -IsProcess $true
                
                if ($null -eq $content) {
                    continue
                }
                
                $outputFile = Join-Path $langDir "$($procConfig.file).mdc"
                
                # Create parent directory if it doesn't exist (for nested files)
                $parentDir = Split-Path -Parent $outputFile
                if (-not (Test-Path $parentDir)) {
                    New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
                }
                
                $frontmatter = New-CursorFrontmatter -Config $Config -Lang $lang -File $proc
                
                $fullContent = $frontmatter + $content
                $fullContent | Out-File -FilePath $outputFile -Encoding UTF8 -NoNewline
                
                $relativePath = $outputFile.Replace($Script:ProjectRoot, "").TrimStart("\", "/")
                Write-SuccessMessage "Created $relativePath"
            }
        }
    }
}

function New-ClaudeCodeConfig {
    param(
        [PSCustomObject]$Config,
        [string[]]$SelectedLanguages,
        [hashtable]$SelectedFrameworks,
        [hashtable]$SelectedStructures,
        [hashtable]$SelectedProcesses
    )
    
    $outputDir = Join-Path $Script:ProjectRoot ".claude\skills"
    
    Write-InfoMessage "Generating Claude Code skills..."
    
    foreach ($lang in $SelectedLanguages) {
        # Generate base language files as skills
        $files = $Config.languages.$lang.files
        
        foreach ($file in $files) {
            $content = Read-InstructionFile -Lang $lang -File $file
            
            if ($null -eq $content) {
                continue
            }
            
            # Create skill folder (e.g., .claude/skills/general-code-style)
            $skillName = if ($lang -eq "general") { $file -replace "/", "-" } else { "$lang-$($file -replace '/', '-')" }
            $skillDir = Join-Path $outputDir $skillName
            
            if (-not (Test-Path $skillDir)) {
                New-Item -ItemType Directory -Path $skillDir -Force | Out-Null
            }
            
            $outputFile = Join-Path $skillDir "SKILL.md"
            
            # Generate skill frontmatter (name and description)
            $description = Get-SkillDescription -Lang $lang -File $file -Config $Config
            $frontmatter = @"
---
name: $skillName
description: $description
---

"@
            
            $fullContent = $frontmatter + $content
            $fullContent | Out-File -FilePath $outputFile -Encoding UTF8 -NoNewline
            
            $relativePath = $outputFile.Replace($Script:ProjectRoot, "").TrimStart("\", "/")
            Write-SuccessMessage "Created $relativePath"
        }
        
        # Generate selected documentation files (only for general language)
        if ($lang -eq "general" -and $SelectedDocumentation.Count -gt 0) {
            foreach ($docFile in $SelectedDocumentation) {
                $content = Read-InstructionFile -Lang $lang -File $docFile
                
                if ($null -eq $content) {
                    continue
                }
                
                $skillName = $docFile -replace "/", "-"
                $skillDir = Join-Path $outputDir $skillName
                
                if (-not (Test-Path $skillDir)) {
                    New-Item -ItemType Directory -Path $skillDir -Force | Out-Null
                }
                
                $outputFile = Join-Path $skillDir "SKILL.md"
                
                $description = Get-SkillDescription -Lang $lang -File $docFile -Config $Config
                $frontmatter = @"
---
name: $skillName
description: $description
---

"@
                
                $fullContent = $frontmatter + $content
                $fullContent | Out-File -FilePath $outputFile -Encoding UTF8 -NoNewline
                
                $relativePath = $outputFile.Replace($Script:ProjectRoot, "").TrimStart("\", "/")
                Write-SuccessMessage "Created $relativePath"
            }
        }
        
        # Generate framework files as skills
        if ($SelectedFrameworks.ContainsKey($lang)) {
            foreach ($fw in $SelectedFrameworks[$lang]) {
                $fwConfig = $Config.languages.$lang.frameworks.$fw
                $content = Read-InstructionFile -Lang $lang -File $fwConfig.file -IsFramework $true
                
                if ($null -eq $content) {
                    continue
                }
                
                $skillName = "$lang-framework-$fw"
                $skillDir = Join-Path $outputDir $skillName
                
                if (-not (Test-Path $skillDir)) {
                    New-Item -ItemType Directory -Path $skillDir -Force | Out-Null
                }
                
                $outputFile = Join-Path $skillDir "SKILL.md"
                
                $description = Get-SkillDescription -Lang $lang -Framework $fw -Config $Config
                $frontmatter = @"
---
name: $skillName
description: $description
---

"@
                
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
                        $structSkillName = "$lang-$fw-$($structFile -replace '/', '-')"
                        $structSkillDir = Join-Path $outputDir $structSkillName
                        
                        if (-not (Test-Path $structSkillDir)) {
                            New-Item -ItemType Directory -Path $structSkillDir -Force | Out-Null
                        }
                        
                        $structOutputFile = Join-Path $structSkillDir "SKILL.md"
                        
                        $structDescription = Get-SkillDescription -Lang $lang -Framework $fw -Structure $structFile -Config $Config
                        $structFrontmatter = @"
---
name: $structSkillName
description: $structDescription
---

"@
                        
                        $structFullContent = $structFrontmatter + $structContent
                        $structFullContent | Out-File -FilePath $structOutputFile -Encoding UTF8 -NoNewline
                        
                        $relativePath = $structOutputFile.Replace($Script:ProjectRoot, "").TrimStart("\", "/")
                        Write-SuccessMessage "Created $relativePath"
                    }
                }
            }
        }
        
        # Generate process files as skills
        if ($SelectedProcesses.ContainsKey($lang)) {
            foreach ($proc in $SelectedProcesses[$lang]) {
                $procConfig = $Config.languages.$lang.processes.$proc
                $content = Read-InstructionFile -Lang $lang -File $procConfig.file -IsProcess $true
                
                if ($null -eq $content) {
                    continue
                }
                
                $skillName = "$lang-process-$proc"
                $skillDir = Join-Path $outputDir $skillName
                
                if (-not (Test-Path $skillDir)) {
                    New-Item -ItemType Directory -Path $skillDir -Force | Out-Null
                }
                
                $outputFile = Join-Path $skillDir "SKILL.md"
                
                $description = Get-SkillDescription -Lang $lang -Process $proc -Config $Config
                $frontmatter = @"
---
name: $skillName
description: $description
---

"@
                
                $fullContent = $frontmatter + $content
                $fullContent | Out-File -FilePath $outputFile -Encoding UTF8 -NoNewline
                
                $relativePath = $outputFile.Replace($Script:ProjectRoot, "").TrimStart("\", "/")
                Write-SuccessMessage "Created $relativePath"
            }
        }
    }
}

function Get-SkillDescription {
    param(
        [string]$Lang,
        [string]$File,
        [string]$Framework,
        [string]$Structure,
        [string]$Process,
        [PSCustomObject]$Config
    )
    
    # Generate appropriate description based on what we're documenting
    if ($Process) {
        $procConfig = $Config.languages.$Lang.processes.$Process
        return "$($procConfig.name) process for $Lang projects. Use when $($procConfig.name.ToLower())."
    }
    elseif ($Structure) {
        return "Project structure guidelines for $Framework with $Structure architecture. Use when setting up or organizing $Lang projects."
    }
    elseif ($Framework) {
        $fwConfig = $Config.languages.$Lang.frameworks.$Framework
        return "$($fwConfig.name) framework standards and best practices for $Lang. Use when working with $($fwConfig.name)."
    }
    else {
        # For general rules and documentation
        $fileName = Split-Path -Leaf $File
        switch -Regex ($fileName) {
            "code-style" { return "Code style and formatting standards for $Lang. Use when writing or reviewing code." }
            "security" { return "Security best practices for $Lang projects. Use when implementing authentication, handling data, or reviewing security." }
            "testing" { return "Testing standards and practices for $Lang. Use when writing or reviewing tests." }
            "documentation-api" { return "API documentation standards using OpenAPI/Swagger. Use when documenting REST APIs or working with API specs." }
            "documentation-code" { return "Code documentation and commenting standards. Use when writing docstrings, comments, or documentation." }
            "documentation-project" { return "Project documentation standards (README, CHANGELOG, etc.). Use when creating or updating project documentation." }
            default { return "$Lang development standards. Use when working with $Lang code." }
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
        [hashtable]$SelectedStructures,
        [hashtable]$SelectedProcesses
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
        
        # Add selected documentation files (only for general language)
        if ($lang -eq "general" -and $SelectedDocumentation.Count -gt 0) {
            foreach ($docFile in $SelectedDocumentation) {
                $docContent = Read-InstructionFile -Lang $lang -File $docFile
                
                if ($null -ne $docContent) {
                    $content += $docContent + "`n`n---`n`n"
                }
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
        
        # Add process files for this language
        if ($SelectedProcesses.ContainsKey($lang)) {
            foreach ($proc in $SelectedProcesses[$lang]) {
                $procConfig = $Config.languages.$lang.processes.$proc
                $fileContent = Read-InstructionFile -Lang $lang -File $procConfig.file -IsProcess $true
                
                if ($null -ne $fileContent) {
                    $content += $fileContent + "`n`n---`n`n"
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
        [string[]]$SelectedDocumentation,
        [hashtable]$SelectedFrameworks,
        [hashtable]$SelectedStructures,
        [hashtable]$SelectedProcesses
    )
    
    switch ($Tool) {
        "cursor" {
            New-CursorConfig -Config $Config -SelectedLanguages $SelectedLanguages -SelectedDocumentation $SelectedDocumentation -SelectedFrameworks $SelectedFrameworks -SelectedStructures $SelectedStructures -SelectedProcesses $SelectedProcesses
        }
        "claude-cli" {
            New-ConcatenatedConfig -Config $Config -ToolName "Claude CLI" -OutputFile "CLAUDE.md" -SelectedLanguages $SelectedLanguages -SelectedDocumentation $SelectedDocumentation -SelectedFrameworks $SelectedFrameworks -SelectedStructures $SelectedStructures -SelectedProcesses $SelectedProcesses
        }
        "claude-code" {
            New-ClaudeCodeConfig -Config $Config -SelectedLanguages $SelectedLanguages -SelectedDocumentation $SelectedDocumentation -SelectedFrameworks $SelectedFrameworks -SelectedStructures $SelectedStructures -SelectedProcesses $SelectedProcesses
        }
        "github-copilot" {
            New-ConcatenatedConfig -Config $Config -ToolName "GitHub Copilot" -OutputFile ".github\copilot-instructions.md" -SelectedLanguages $SelectedLanguages -SelectedDocumentation $SelectedDocumentation -SelectedFrameworks $SelectedFrameworks -SelectedStructures $SelectedStructures -SelectedProcesses $SelectedProcesses
        }
        "windsurf" {
            New-ConcatenatedConfig -Config $Config -ToolName "Windsurf" -OutputFile ".windsurfrules" -SelectedLanguages $SelectedLanguages -SelectedDocumentation $SelectedDocumentation -SelectedFrameworks $SelectedFrameworks -SelectedStructures $SelectedStructures -SelectedProcesses $SelectedProcesses
        }
        "aider" {
            New-ConcatenatedConfig -Config $Config -ToolName "Aider" -OutputFile "CONVENTIONS.md" -SelectedLanguages $SelectedLanguages -SelectedDocumentation $SelectedDocumentation -SelectedFrameworks $SelectedFrameworks -SelectedStructures $SelectedStructures -SelectedProcesses $SelectedProcesses
        }
        "google-ai-studio" {
            New-ConcatenatedConfig -Config $Config -ToolName "Google AI Studio" -OutputFile "GOOGLE_AI_STUDIO.md" -SelectedLanguages $SelectedLanguages -SelectedDocumentation $SelectedDocumentation -SelectedFrameworks $SelectedFrameworks -SelectedStructures $SelectedStructures -SelectedProcesses $SelectedProcesses
        }
        "amazon-q" {
            New-ConcatenatedConfig -Config $Config -ToolName "Amazon Q Developer" -OutputFile "AMAZON_Q.md" -SelectedLanguages $SelectedLanguages -SelectedDocumentation $SelectedDocumentation -SelectedFrameworks $SelectedFrameworks -SelectedStructures $SelectedStructures -SelectedProcesses $SelectedProcesses
        }
        "tabnine" {
            New-ConcatenatedConfig -Config $Config -ToolName "Tabnine" -OutputFile "TABNINE.md" -SelectedLanguages $SelectedLanguages -SelectedDocumentation $SelectedDocumentation -SelectedFrameworks $SelectedFrameworks -SelectedStructures $SelectedStructures -SelectedProcesses $SelectedProcesses
        }
        "cody" {
            New-ConcatenatedConfig -Config $Config -ToolName "Cody (Sourcegraph)" -OutputFile ".cody\instructions.md" -SelectedLanguages $SelectedLanguages -SelectedDocumentation $SelectedDocumentation -SelectedFrameworks $SelectedFrameworks -SelectedStructures $SelectedStructures -SelectedProcesses $SelectedProcesses
        }
        "continue" {
            New-ConcatenatedConfig -Config $Config -ToolName "Continue.dev" -OutputFile ".continue\instructions.md" -SelectedLanguages $SelectedLanguages -SelectedDocumentation $SelectedDocumentation -SelectedFrameworks $SelectedFrameworks -SelectedStructures $SelectedStructures -SelectedProcesses $SelectedProcesses
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
    
    # Documentation selection
    $selectedDocumentation = Select-Documentation -Config $config -SelectedLanguages $selectedLanguages
    
    # Framework selection
    $selectedFrameworks = Select-Frameworks -Config $config -SelectedLanguages $selectedLanguages
    
    # Structure selection (for frameworks that have structure options)
    $selectedStructures = Select-Structures -Config $config -SelectedLanguages $selectedLanguages -SelectedFrameworks $selectedFrameworks
    
    # Process selection
    $selectedProcesses = Select-Processes -Config $config -SelectedLanguages $selectedLanguages
    
    Write-Host ""
    Write-Host "Configuration Summary:" -ForegroundColor White
    Write-Host "  Tools: $($selectedTools -join ', ')"
    Write-Host "  Languages: $($selectedLanguages -join ', ')"
    if ($selectedDocumentation.Count -gt 0) {
        Write-Host "  Documentation: $($selectedDocumentation -join ', ')"
    }
    
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
    if ($selectedProcesses.Count -gt 0) {
        foreach ($lang in $selectedProcesses.Keys) {
            Write-Host "  Processes ($lang): $($selectedProcesses[$lang] -join ', ')"
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
        New-ToolConfig -Config $config -Tool $tool -SelectedLanguages $selectedLanguages -SelectedDocumentation $selectedDocumentation -SelectedFrameworks $selectedFrameworks -SelectedStructures $selectedStructures -SelectedProcesses $selectedProcesses
    }
    
    # Gitignore prompt
    Add-ToGitignore
    
    Write-Host ""
    Write-Host "Setup complete!" -ForegroundColor Green
    Write-Host ""
    
    # Cleanup temp merged config
    if (Test-Path $Script:MergedConfigFile) {
        Remove-Item $Script:MergedConfigFile -Force -ErrorAction SilentlyContinue
    }
}

Main
