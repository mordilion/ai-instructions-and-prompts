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
$Script:CustomFunctionsDir = Join-Path $Script:ProjectRoot ".ai-iap-custom\functions"
$Script:MergedConfigFile = Join-Path $env:TEMP "ai-iap-merged-config-$PID.json"
$Script:WorkingConfig = $Script:ConfigFile
$Script:StateFile = Join-Path $Script:ProjectRoot ".ai-iap-state.json"

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
        Normalize-Config -Config $config
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

function Normalize-Config {
    param([PSCustomObject]$Config)

    # Normalize merged config so custom additions become first-class:
    # - customFiles -> files (append unique)
    # - customFrameworks -> frameworks
    # - customProcesses -> processes
    foreach ($langKey in $Config.languages.PSObject.Properties.Name) {
        $lang = $Config.languages.$langKey

        # Merge customFiles into files
        if ($lang.PSObject.Properties.Name -contains "customFiles") {
            if (-not ($lang.PSObject.Properties.Name -contains "files")) {
                $lang | Add-Member -NotePropertyName "files" -NotePropertyValue @()
            }

            foreach ($f in @($lang.customFiles)) {
                if ($null -ne $f -and ($lang.files -notcontains $f)) {
                    $lang.files += $f
                }
            }
        }

        # Merge customFrameworks into frameworks
        if ($lang.PSObject.Properties.Name -contains "customFrameworks") {
            if (-not ($lang.PSObject.Properties.Name -contains "frameworks")) {
                $lang | Add-Member -NotePropertyName "frameworks" -NotePropertyValue ([PSCustomObject]@{})
            }

            foreach ($fwProp in $lang.customFrameworks.PSObject.Properties) {
                $lang.frameworks | Add-Member -NotePropertyName $fwProp.Name -NotePropertyValue $fwProp.Value -Force
            }
        }

        # Merge customProcesses into processes
        if ($lang.PSObject.Properties.Name -contains "customProcesses") {
            if (-not ($lang.PSObject.Properties.Name -contains "processes")) {
                $lang | Add-Member -NotePropertyName "processes" -NotePropertyValue ([PSCustomObject]@{})
            }

            foreach ($procProp in $lang.customProcesses.PSObject.Properties) {
                $lang.processes | Add-Member -NotePropertyName $procProp.Name -NotePropertyValue $procProp.Value -Force
            }
        }
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
        [bool]$AllowSkip = $false,
        [string]$DefaultInput = "",
        [bool]$AllowClearDefault = $false
    )
    
    while ($true) {
        $userInput = Read-Host $Prompt

        if ($AllowClearDefault -and ($userInput -eq 'c' -or $userInput -eq 'C') -and -not [string]::IsNullOrWhiteSpace($DefaultInput)) {
            $DefaultInput = ""
            Write-Host ""
            Write-InfoMessage "Cleared previous default. Enter a new selection."
            Write-Host ""
            continue
        }

        if ([string]::IsNullOrWhiteSpace($userInput) -and -not [string]::IsNullOrWhiteSpace($DefaultInput)) {
            # Press Enter => keep previous selection (default).
            $userInput = $DefaultInput
        }
        
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
    param(
        [PSCustomObject]$Config,
        [string[]]$DefaultSelected = @()
    )
    
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

    $defaultInput = ""
    if ($DefaultSelected -and $DefaultSelected.Count -gt 0) {
        $idxs = @()
        for ($i = 0; $i -lt $toolKeys.Count; $i++) {
            if ($DefaultSelected -contains $toolKeys[$i]) {
                $idxs += ($i + 1)
            }
        }
        if ($idxs.Count -gt 0) {
            Write-Host ("Previously selected: " + ($DefaultSelected -join ", ")) -ForegroundColor DarkGray
            Write-Host "Press Enter to keep the previous selection, or enter a new list." -ForegroundColor DarkGray
            $defaultInput = ($idxs -join " ")
            Write-Host ""
        }
    }
    
    $selectedTools = Get-ValidatedSelection `
        -Prompt ("Enter choices (e.g., 1 3 or 'a' for all)" + ($(if ($defaultInput) { " [$defaultInput]" } else { "" })) + ":") `
        -Options $toolKeys `
        -MaxValue $toolKeys.Count `
        -AllowEmpty $false `
        -DefaultInput $defaultInput `
        -AllowClearDefault $true
    
    return $selectedTools
}

function Select-Languages {
    param(
        [PSCustomObject]$Config,
        [string[]]$DefaultSelected = @()
    )
    
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
        # Clarify "framework buckets" (e.g., Node.js) that have no base files
        $langKey = $langKeys[$i]
        $fileCount = @($Config.languages.$langKey.files).Count
        $frameworkCount = if ($Config.languages.$langKey.frameworks) { @($Config.languages.$langKey.frameworks.PSObject.Properties).Count } else { 0 }
        if ($fileCount -eq 0 -and $frameworkCount -gt 0) {
            $suffix += " (frameworks only)"
        }
        Write-Host "  $($i + 1). $($languages[$i])$suffix"
    }
    Write-Host "  a. All languages"
    Write-Host ""

    $defaultInput = ""
    if ($DefaultSelected -and $DefaultSelected.Count -gt 0) {
        $idxs = @()
        for ($i = 0; $i -lt $langKeys.Count; $i++) {
            if ($DefaultSelected -contains $langKeys[$i]) {
                $idxs += ($i + 1)
            }
        }
        if ($idxs.Count -gt 0) {
            Write-Host ("Previously selected: " + ($DefaultSelected -join ", ")) -ForegroundColor DarkGray
            Write-Host "Press Enter to keep the previous selection, or enter a new list." -ForegroundColor DarkGray
            $defaultInput = ($idxs -join " ")
            Write-Host ""
        }
    }
    
    $selectedLanguages = Get-ValidatedSelection `
        -Prompt ("Enter choices (e.g., 1 2 4 or 'a' for all)" + ($(if ($defaultInput) { " [$defaultInput]" } else { "" })) + ":") `
        -Options $langKeys `
        -MaxValue $langKeys.Count `
        -AllowEmpty $false `
        -DefaultInput $defaultInput `
        -AllowClearDefault $true
    
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
        [string[]]$SelectedLanguages,
        [string[]]$DefaultSelectedDocumentation = @()
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
            $suffix = " *"
        }
        
        # Check applicability
        $applicableTo = $Config.languages.general.documentation.$key.applicableTo
        if ($applicableTo -contains "backend" -or $applicableTo -contains "fullstack") {
            $suffix += " (backend/fullstack)"
        }
        
        Write-Host "  $($i + 1). $($docNames[$i])$suffix"
        Write-Host "      $($docDescs[$i])" -ForegroundColor DarkGray
    }
    Write-Host ""
    Write-Host "  * = recommended" -ForegroundColor DarkGray
    Write-Host "  a. All documentation"
    Write-Host "  s. Skip (no documentation standards)"
    Write-Host ""
    
    # Provide smart default suggestion
    if ($hasFrontendOnly -and -not $hasBackend) {
        Write-Host "Suggestion for frontend-only project: 1 2 (code + project)" -ForegroundColor DarkGray
    } elseif ($hasBackend) {
        Write-Host "Suggestion for backend/fullstack project: a (all)" -ForegroundColor DarkGray
    }
    
    $defaultInput = ""
    if ($DefaultSelectedDocumentation -and $DefaultSelectedDocumentation.Count -gt 0) {
        # DefaultSelectedDocumentation stores files like "documentation/code"
        $idxs = @()
        for ($i = 0; $i -lt $docKeys.Count; $i++) {
            $file = $Config.languages.general.documentation.$($docKeys[$i]).file
            if ($DefaultSelectedDocumentation -contains $file) {
                $idxs += ($i + 1)
            }
        }
        if ($idxs.Count -gt 0) {
            Write-Host ("Previously selected: " + ($DefaultSelectedDocumentation -join ", ")) -ForegroundColor DarkGray
            Write-Host "Press Enter to keep the previous selection, or enter a new list (use 's' to remove all)." -ForegroundColor DarkGray
            $defaultInput = ($idxs -join " ")
            Write-Host ""
        }
    }

    $prompt = "Enter choices (e.g., 1 2 or 'a' for all, 's' to skip)"
    if ($defaultInput) { $prompt += " [$defaultInput]" }
    $prompt += ":"
    $docInput = Read-Host $prompt

    if ([string]::IsNullOrWhiteSpace($docInput) -and $defaultInput) {
        $docInput = $defaultInput
    }
    
    $selectedDocumentation = @()
    
    if ($docInput -eq "s" -or $docInput -eq "S") {
        return @()
    } elseif ($docInput -eq "a" -or $docInput -eq "A") {
        foreach ($key in $docKeys) {
            $selectedDocumentation += $Config.languages.general.documentation.$key.file
        }
    } else {
        foreach ($num in $docInput.Split(" ")) {
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
        [string[]]$SelectedLanguages,
        [hashtable]$DefaultSelectedFrameworks = @{}
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

        $defaultInput = ""
        if ($DefaultSelectedFrameworks -and $DefaultSelectedFrameworks.ContainsKey($lang)) {
            $prev = @($DefaultSelectedFrameworks[$lang])
            $idxs = @()
            for ($i = 0; $i -lt $frameworkKeys.Count; $i++) {
                if ($prev -contains $frameworkKeys[$i]) {
                    $idxs += ($i + 1)
                }
            }
            if ($idxs.Count -gt 0) {
                Write-Host ("Previously selected: " + ($prev -join ", ")) -ForegroundColor DarkGray
                $defaultInput = ($idxs -join " ")
                Write-Host ""
            }
        }
        
        $langFrameworks = Get-ValidatedSelection `
            -Prompt ("Enter choices (e.g., 1 3 5 or 'a' for all, 's' to skip)" + ($(if ($defaultInput) { " [$defaultInput]" } else { "" })) + ":") `
            -Options $frameworkKeys `
            -MaxValue $frameworkKeys.Count `
            -AllowEmpty $false `
            -AllowSkip $true `
            -DefaultInput $defaultInput
        
        if ($langFrameworks.Count -gt 0) {
            $selectedFrameworks[$lang] = $langFrameworks
        }
    }
    
    return $selectedFrameworks
}

function Select-Processes {
    param(
        [PSCustomObject]$Config,
        [string[]]$SelectedLanguages,
        [hashtable]$DefaultSelectedProcesses = @{}
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
            
            # Add type indicator for permanent vs on-demand
            $typeLabel = if ($proc.loadIntoAI -eq $true) { "[permanent]" } else { "[on-demand]" }
            
            $processes += @{
                Key = $key
                Name = $proc.name
                Description = "$($proc.description) $typeLabel"
                File = $proc.file
                Index = $index
                LoadIntoAI = $proc.loadIntoAI
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
        Write-Host "Process Types:" -ForegroundColor Yellow
        Write-Host "  [permanent] - Loaded into AI permanently (recurring tasks)" -ForegroundColor Cyan
        Write-Host "  [on-demand] - Copy prompt when needed (one-time setups)" -ForegroundColor DarkGray
        Write-Host ""
        
        foreach ($proc in $processes) {
            Write-Host "  $($proc.Index + 1). $($proc.Name) - $($proc.Description)"
        }
        Write-Host ""
        Write-Host "  s. Skip (no processes)"
        Write-Host "  a. All processes"
        Write-Host ""

        $defaultInput = ""
        if ($DefaultSelectedProcesses -and $DefaultSelectedProcesses.ContainsKey($lang)) {
            $prev = @($DefaultSelectedProcesses[$lang])
            $idxs = @()
            for ($i = 0; $i -lt $processKeys.Count; $i++) {
                if ($prev -contains $processKeys[$i]) {
                    $idxs += ($i + 1)
                }
            }
            if ($idxs.Count -gt 0) {
                Write-Host ("Previously selected: " + ($prev -join ", ")) -ForegroundColor DarkGray
                $defaultInput = ($idxs -join " ")
                Write-Host ""
            }
        }
        
        $langProcesses = Get-ValidatedSelection `
            -Prompt ("Enter choices (e.g., 1 2 or 'a' for all, 's' to skip)" + ($(if ($defaultInput) { " [$defaultInput]" } else { "" })) + ":") `
            -Options $processKeys `
            -MaxValue $processKeys.Count `
            -AllowEmpty $false `
            -AllowSkip $true `
            -DefaultInput $defaultInput
        
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
        [hashtable]$SelectedFrameworks,
        [hashtable]$DefaultSelectedStructures = @{}
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

            $defaultChoice = ""
            $structKey = "$lang-$fwKey"
            if ($DefaultSelectedStructures -and $DefaultSelectedStructures.ContainsKey($structKey)) {
                $prevFile = [string]$DefaultSelectedStructures[$structKey]
                for ($i = 0; $i -lt $structures.Count; $i++) {
                    if ($structures[$i].File -eq $prevFile) {
                        $defaultChoice = [string]($i + 1)
                        break
                    }
                }
                if ($defaultChoice) {
                    Write-Host ("Previously selected: " + $prevFile) -ForegroundColor DarkGray
                    Write-Host ""
                }
            }

            $prompt = "Enter choice (1-$($structures.Count) or 's' to skip)"
            if ($defaultChoice) { $prompt += " [$defaultChoice]" }
            $prompt += ":"
            $choice = Read-Host $prompt

            if ([string]::IsNullOrWhiteSpace($choice) -and $defaultChoice) {
                $choice = $defaultChoice
            }
            
            if ($choice -ne 's' -and $choice -ne 'S') {
                $idx = [int]$choice - 1
                if ($idx -ge 0 -and $idx -lt $structureKeys.Count) {
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
    
    $candidates = @()

    if ($IsProcess) {
        # Processes are stored under processes\{ondemand|permanent}\<lang>\<file>.md
        # Custom processes also support legacy layout: .ai-iap-custom/processes/<lang>/<file>.md
        $candidates += (Join-Path $Script:CustomProcessesDir "$Lang\$File.md")
        $candidates += (Join-Path $Script:CustomProcessesDir "ondemand\$Lang\$File.md")
        $candidates += (Join-Path $Script:CustomProcessesDir "permanent\$Lang\$File.md")
        $candidates += (Join-Path $Script:ScriptDir "processes\ondemand\$Lang\$File.md")
        $candidates += (Join-Path $Script:ScriptDir "processes\permanent\$Lang\$File.md")
    }
    elseif ($IsStructure) {
        $candidates += (Join-Path $Script:CustomRulesDir "$Lang\frameworks\structures\$File.md")
        $candidates += (Join-Path $Script:ScriptDir "rules\$Lang\frameworks\structures\$File.md")
    }
    elseif ($IsFramework) {
        $candidates += (Join-Path $Script:CustomRulesDir "$Lang\frameworks\$File.md")
        $candidates += (Join-Path $Script:ScriptDir "rules\$Lang\frameworks\$File.md")
    }
    else {
        $candidates += (Join-Path $Script:CustomRulesDir "$Lang\$File.md")
        $candidates += (Join-Path $Script:ScriptDir "rules\$Lang\$File.md")
    }

    foreach ($path in $candidates) {
        if (Test-Path $path) {
            return Get-Content $path -Raw -Encoding UTF8
        }
    }

    Write-WarningMessage ("File not found: " + ($candidates -join ", "))
    return $null
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
    $alwaysApply = if ($null -ne $langConfig.alwaysApply) { $langConfig.alwaysApply.ToString().ToLower() } else { "false" }
    
    if ($IsFramework) {
        $fw = $langConfig.frameworks.$File
        $description = "$($langConfig.name) - $($fw.name)"
    }
    else {
        $description = "$($langConfig.description) - $File"
    }
    
    $frontmatter = @"
---
aiIapManaged: true
aiIapVersion: $Script:Version
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
        [string[]]$SelectedDocumentation,
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
                
                # Skip on-demand processes (user copies prompt when needed)
                if ($procConfig.loadIntoAI -eq $false) {
                    Write-InfoMessage "Skipped on-demand process: $proc (copy prompt from .ai-iap/processes/ondemand/$lang/$($procConfig.file).md when needed)"
                    continue
                }
                
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

function Get-FrameworkCategory {
    param(
        [string]$Framework,
        [string]$Lang
    )
    
    # Categorize frameworks for .claude/rules/ subdirectories
    switch -Regex ($Framework) {
        "react|vue|angular|next|nuxt|svelte" { return "frontend" }
        "express|nest|fastapi|django|flask|spring|laravel|adonis" { return "backend" }
        "flutter|swiftui|uikit|jetpack" { return "mobile" }
        default { return "general" }
    }
}

function Get-FrameworkPathPatterns {
    param(
        [string]$Framework,
        [string]$Lang
    )
    
    # Generate path patterns for YAML frontmatter based on framework
    switch -Regex ($Framework) {
        "react" { return "**/*.{jsx,tsx}" }
        "vue" { return "**/*.vue`n**/*.{js,ts}" }
        "angular" { return "**/*.{ts,html,scss}" }
        "next" { return "{app,pages,components}/**/*.{jsx,tsx,js,ts}" }
        "nuxt" { return "{pages,components,layouts}/**/*.{vue,js,ts}" }
        "nest" { return "src/**/*.{ts,controller.ts,service.ts,module.ts}" }
        "express" { return "**/*.{js,ts,mjs}" }
        "django" { return "**/*.py" }
        "fastapi" { return "**/*.py" }
        "flask" { return "**/*.py" }
        "spring" { return "**/*.java" }
        "laravel" { return "**/*.php" }
        "flutter" { return "**/*.dart" }
        "swiftui|uikit" { return "**/*.swift" }
        "jetpack" { return "**/*.kt" }
        default { return $null }
    }
}

function Get-ClaudeLanguagePathPatterns {
    param(
        [PSCustomObject]$Config,
        [string]$Lang
    )

    $langConfig = $Config.languages.$Lang
    if ($null -eq $langConfig) { return @() }

    $alwaysApply = $false
    if ($null -ne $langConfig.alwaysApply) { $alwaysApply = [bool]$langConfig.alwaysApply }
    if ($alwaysApply) { return @() }

    $globs = $langConfig.globs
    if ([string]::IsNullOrWhiteSpace($globs) -or $globs -eq "*") { return @() }

    $patterns = @()
    foreach ($g in ($globs -split ",")) {
        $p = $g.Trim()
        if ([string]::IsNullOrWhiteSpace($p)) { continue }
        if ($p.StartsWith("**/") -or $p.Contains("/") -or $p.StartsWith("{")) {
            $patterns += $p
        }
        else {
            $patterns += "**/$p"
        }
    }

    return $patterns
}

function New-ClaudeFrontmatter {
    param(
        [string[]]$Paths
    )

    $lines = @(
        "---"
        "aiIapManaged: true"
    )

    if ($null -ne $Paths -and $Paths.Count -gt 0) {
        $lines += "paths:"
        foreach ($p in $Paths) {
            $pt = $p.Trim()
            if ([string]::IsNullOrWhiteSpace($pt)) { continue }
            $lines += "  - `"$pt`""
        }
    }

    $lines += "---"
    $lines += ""

    return ($lines -join "`n") + "`n"
}

function New-ClaudeConfig {
    param(
        [PSCustomObject]$Config,
        [string[]]$SelectedLanguages,
        [string[]]$SelectedDocumentation,
        [hashtable]$SelectedFrameworks,
        [hashtable]$SelectedStructures,
        [hashtable]$SelectedProcesses
    )
    
    Write-InfoMessage "Generating Claude configuration..."
    
    # Rules-only mode:
    # Put "always-on" content into unconditional rule files under .claude/rules/core/
    # and keep framework/process rules under .claude/rules/*.
    $outputDir = Join-Path $Script:ProjectRoot ".claude\rules"
    $coreDir = Join-Path $outputDir "core"
    
    Write-InfoMessage "Generating Claude modular rules..."
    
    foreach ($lang in $SelectedLanguages) {
        # Core language rules (apply by language globs unless alwaysApply is true)
        $langCoreDir = Join-Path $coreDir $lang
        if (-not (Test-Path $langCoreDir)) { New-Item -ItemType Directory -Path $langCoreDir -Force | Out-Null }

        $langPaths = Get-ClaudeLanguagePathPatterns -Config $Config -Lang $lang
        
        $files = $Config.languages.$lang.files
        foreach ($file in $files) {
            $fileContent = Read-InstructionFile -Lang $lang -File $file
            if ($null -eq $fileContent) { continue }
            
            $outputFile = Join-Path $langCoreDir "$file.md"
            $frontmatter = New-ClaudeFrontmatter -Paths $langPaths
            $genHeader = @"
<!-- Generated by AI Instructions and Prompts Setup -->
<!-- https://github.com/your-repo/ai-instructions-and-prompts -->

"@
            ($frontmatter + $genHeader + $fileContent + "`n") | Out-File -FilePath $outputFile -Encoding UTF8 -NoNewline
            $relativePath = $outputFile.Replace($Script:ProjectRoot, "").TrimStart("\", "/")
            Write-SuccessMessage "Created $relativePath"
        }
        
        # Selected documentation files (unconditional; only for general language)
        if ($lang -eq "general" -and $SelectedDocumentation.Count -gt 0) {
            $docDir = Join-Path $coreDir "documentation"
            if (-not (Test-Path $docDir)) { New-Item -ItemType Directory -Path $docDir -Force | Out-Null }
            
            foreach ($docFile in $SelectedDocumentation) {
                $docContent = Read-InstructionFile -Lang $lang -File $docFile
                if ($null -eq $docContent) { continue }
                
                # $docFile is typically like "documentation/code" - avoid nesting "documentation/" twice.
                $docName = Split-Path -Path $docFile -Leaf
                $outputFile = Join-Path $docDir "$docName.md"
                $frontmatter = New-ClaudeFrontmatter -Paths @()
                $genHeader = @"
<!-- Generated by AI Instructions and Prompts Setup -->
<!-- https://github.com/your-repo/ai-instructions-and-prompts -->

"@
                ($frontmatter + $genHeader + $docContent + "`n") | Out-File -FilePath $outputFile -Encoding UTF8 -NoNewline
                $relativePath = $outputFile.Replace($Script:ProjectRoot, "").TrimStart("\", "/")
                Write-SuccessMessage "Created $relativePath"
            }
        }
        
        # Generate framework files as skills (optional, context-triggered)
        if ($SelectedFrameworks.ContainsKey($lang)) {
            foreach ($fw in $SelectedFrameworks[$lang]) {
                $fwConfig = $Config.languages.$lang.frameworks.$fw
                $content = Read-InstructionFile -Lang $lang -File $fwConfig.file -IsFramework $true
                
                if ($null -eq $content) {
                    continue
                }
                
                # Organize by category: frontend, backend, mobile
                $category = Get-FrameworkCategory -Framework $fw -Lang $lang
                $categoryDir = Join-Path $outputDir $category
                
                if (-not (Test-Path $categoryDir)) {
                    New-Item -ItemType Directory -Path $categoryDir -Force | Out-Null
                }
                
                $outputFile = Join-Path $categoryDir "$fw.md"
                
                # Add YAML frontmatter with path patterns for framework-specific files
                $pathPatterns = Get-FrameworkPathPatterns -Framework $fw -Lang $lang
                $pathList = @()
                if ($pathPatterns) { $pathList = @($pathPatterns -split "`n") }
                $frontmatter = New-ClaudeFrontmatter -Paths $pathList
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
                        $structName = ($structFile -split '/')[-1]
                        $structOutputFile = Join-Path $categoryDir "$fw-$structName.md"
                        
                        # Add path patterns for structure-specific rules
                        $structPatterns = Get-FrameworkPathPatterns -Framework $fw -Lang $lang
                        $structPathList = @()
                        if ($structPatterns) { $structPathList = @($structPatterns -split "`n") }
                        $structFrontmatter = New-ClaudeFrontmatter -Paths $structPathList
                        $structFullContent = $structFrontmatter + $structContent
                        
                        $structFullContent | Out-File -FilePath $structOutputFile -Encoding UTF8 -NoNewline
                        
                        $relativePath = $structOutputFile.Replace($Script:ProjectRoot, "").TrimStart("\", "/")
                        Write-SuccessMessage "Created $relativePath"
                    }
                }
            }
        }
        
        # Generate process files as rules
        if ($SelectedProcesses.ContainsKey($lang)) {
            foreach ($proc in $SelectedProcesses[$lang]) {
                $procConfig = $Config.languages.$lang.processes.$proc
                
                # Skip on-demand processes (user copies prompt when needed)
                if ($procConfig.loadIntoAI -eq $false) {
                    continue
                }
                
                $content = Read-InstructionFile -Lang $lang -File $procConfig.file -IsProcess $true
                
                if ($null -eq $content) {
                    continue
                }
                
                # Put processes in a dedicated subdirectory
                $processesDir = Join-Path $outputDir "processes"
                
                if (-not (Test-Path $processesDir)) {
                    New-Item -ItemType Directory -Path $processesDir -Force | Out-Null
                }
                
                $outputFile = Join-Path $processesDir "$lang-$proc.md"
                
                # Process files apply broadly; still add a marker so setup can safely clean up on reruns.
                $procFrontmatter = New-ClaudeFrontmatter -Paths @()
                ($procFrontmatter + $content) | Out-File -FilePath $outputFile -Encoding UTF8 -NoNewline
                
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
    
    # Generate specific, action-oriented descriptions per Claude's documentation
    # Format: What it covers. Use when [concrete triggers/actions].
    
    if ($Process) {
        $procConfig = $Config.languages.$Lang.processes.$Process
        $procName = $procConfig.name
        
        # Generate process-specific descriptions
        switch -Regex ($Process) {
            "database-migrations" { return "Database schema migration implementation using ORMs and version control. Use when setting up migrations, creating schema changes, or working with database versioning." }
            "test-implementation" { return "Testing framework setup and test writing patterns for $Lang. Use when implementing unit tests, integration tests, or setting up test infrastructure." }
            "ci-cd" { return "CI/CD pipeline configuration with GitHub Actions for $Lang projects. Use when setting up workflows, configuring builds, or implementing deployment automation." }
            "docker" { return "Docker containerization for $Lang applications. Use when creating Dockerfiles, docker-compose configurations, or containerizing applications." }
            "logging" { return "Structured logging and observability implementation. Use when adding logging, setting up monitoring, or implementing error tracking." }
            "security-scanning" { return "Security scanning and vulnerability detection. Use when implementing SAST/DAST, dependency scanning, or security auditing." }
            "auth" { return "Authentication and authorization implementation. Use when adding JWT, OAuth, session management, or RBAC systems." }
            "api-doc" { return "API documentation with OpenAPI/Swagger. Use when documenting REST endpoints, generating API specs, or creating interactive API documentation." }
            default { return "$procName implementation for $Lang. Use when working on $($procName.ToLower()) tasks or setup." }
        }
    }
    elseif ($Structure) {
        $structName = $Structure -replace ".*/", "" -replace "-", " "
        
        # Generate structure-specific descriptions
        switch -Regex ($Structure) {
            "feature" { return "Feature-First architecture pattern for $Framework. Use when organizing code by features, setting up new features, or discussing project structure with feature modules." }
            "layer" { return "Layer-First (N-tier) architecture for $Framework. Use when organizing by technical layers, separating presentation/business/data layers, or implementing layered architecture." }
            "clean" { return "Clean Architecture implementation for $Framework. Use when setting up domain-driven design, organizing by use cases, or implementing clean architecture principles." }
            "mvvm" { return "MVVM (Model-View-ViewModel) pattern for $Framework. Use when creating ViewModels, binding views, or implementing MVVM architecture." }
            "mvi" { return "MVI (Model-View-Intent) pattern for $Framework. Use when implementing unidirectional data flow, handling user intents, or setting up state management." }
            "vertical" { return "Vertical Slice architecture for $Framework. Use when organizing by features as vertical slices, minimizing coupling between features, or implementing vertical architecture." }
            "modular" { return "Modular Monolith architecture for $Framework. Use when creating independent modules, setting up module boundaries, or refactoring to modular structure." }
            default { return "$structName architecture for $Framework. Use when setting up project structure, organizing files, or discussing architecture patterns." }
        }
    }
    elseif ($Framework) {
        $fwConfig = $Config.languages.$Lang.frameworks.$Framework
        $fwName = $fwConfig.name
        
        # Generate framework-specific descriptions
        switch -Regex ($Framework) {
            "react" { return "React framework development. Use when working with React components, hooks, JSX, state management, or React-specific patterns." }
            "vue" { return "Vue.js framework development. Use when working with Vue components, Composition API, Vue directives, or Vue-specific patterns." }
            "angular" { return "Angular framework development. Use when working with Angular components, services, decorators, RxJS, or Angular-specific patterns." }
            "next" { return "Next.js framework for React. Use when working with server-side rendering, API routes, app directory, or Next.js-specific features." }
            "nuxt" { return "Nuxt.js framework for Vue. Use when working with SSR, auto-routing, Nuxt modules, or Nuxt-specific features." }
            "nest" { return "NestJS framework for Node.js. Use when working with NestJS decorators, modules, providers, or building backend APIs with NestJS." }
            "express" { return "Express.js framework for Node.js. Use when building REST APIs, middleware, routing, or Express-based backends." }
            "django" { return "Django web framework for Python. Use when working with Django models, views, ORM, admin, or Django-specific patterns." }
            "fastapi" { return "FastAPI framework for Python. Use when building async APIs, Pydantic models, auto-generated docs, or FastAPI-specific features." }
            "flask" { return "Flask framework for Python. Use when building lightweight APIs, Flask routes, blueprints, or Flask-based applications." }
            "spring" { return "Spring Boot framework for Java. Use when working with Spring beans, annotations, JPA, REST controllers, or Spring-specific patterns." }
            "laravel" { return "Laravel framework for PHP. Use when working with Eloquent ORM, Blade templates, artisan commands, or Laravel-specific features." }
            "flutter" { return "Flutter framework for Dart. Use when creating Flutter widgets, state management, animations, or cross-platform mobile apps." }
            "swiftui" { return "SwiftUI framework for iOS. Use when building declarative UI, SwiftUI views, property wrappers, or iOS/macOS applications." }
            "uikit" { return "UIKit framework for iOS. Use when working with view controllers, UIViews, storyboards, or UIKit-based iOS applications." }
            "jetpack" { return "Jetpack Compose for Android. Use when building declarative UI, composables, state management, or modern Android applications." }
            default { return "$fwName framework for $Lang. Use when working with $fwName-specific features, patterns, or implementation details." }
        }
    }
    else {
        # For general rules and documentation
        $fileName = Split-Path -Leaf $File
        switch -Regex ($fileName) {
            "code-style" { return "$Lang code style, naming conventions, and formatting rules. Use when writing new code, reviewing code, or refactoring $Lang code." }
            "security" { return "$Lang security best practices and OWASP guidelines. Use when implementing authentication, handling sensitive data, validating input, or conducting security reviews." }
            "testing" { return "$Lang testing strategies, test patterns, and assertion guidelines. Use when writing tests, setting up test infrastructure, or reviewing test coverage." }
            "documentation-api" { return "API documentation standards with OpenAPI/Swagger specifications. Use when documenting REST endpoints, generating API schemas, or creating API reference documentation." }
            "documentation-code" { return "Code documentation with comments, docstrings, and inline documentation. Use when adding code comments, writing function documentation, or improving code readability." }
            "documentation-project" { return "Project-level documentation including README, CHANGELOG, and contribution guides. Use when creating project documentation, writing setup instructions, or maintaining project files." }
            default { return "$Lang development standards and best practices. Use when working with $Lang projects or making architectural decisions." }
        }
    }
}

function New-ConcatenatedConfig {
    param(
        [PSCustomObject]$Config,
        [string]$ToolName,
        [string]$OutputFile,
        [string[]]$SelectedLanguages,
        [string[]]$SelectedDocumentation,
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
                
                # Skip on-demand processes (user copies prompt when needed)
                if ($procConfig.loadIntoAI -eq $false) {
                    continue
                }
                
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
        "claude" {
            New-ClaudeConfig -Config $Config -SelectedLanguages $SelectedLanguages -SelectedDocumentation $SelectedDocumentation -SelectedFrameworks $SelectedFrameworks -SelectedStructures $SelectedStructures -SelectedProcesses $SelectedProcesses
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
    Write-InfoMessage "Note: .ai-iap/ and .ai-iap-custom/ are meant to be committed and shared."
    Write-InfoMessage "Note: .ai-iap-state.json is also meant to be committed and shared."
    Write-InfoMessage "This setup script will not modify .gitignore."
}

# ============================================================================
# Previous Run State (rerunnable setup)
# ============================================================================

function Get-PreviousState {
    if (-not (Test-Path $Script:StateFile)) {
        return $null
    }

    try {
        return (Get-Content $Script:StateFile -Raw | ConvertFrom-Json)
    }
    catch {
        Write-WarningMessage "Found state file but it contains invalid JSON: $Script:StateFile"
        return $null
    }
}

function Write-PreviousStateSummary {
    param(
        [PSCustomObject]$State
    )

    Write-Host ""
    Write-Host "Previous setup detected ($([IO.Path]::GetFileName($Script:StateFile)))" -ForegroundColor Cyan
    Write-Host "  Tools: $($State.selectedTools -join ', ')"
    Write-Host "  Languages: $($State.selectedLanguages -join ', ')"
    if ($State.selectedDocumentation -and $State.selectedDocumentation.Count -gt 0) {
        Write-Host "  Documentation: $($State.selectedDocumentation -join ', ')"
    }
    if ($State.selectedFrameworks) {
        $fw = ConvertTo-Hashtable -InputObject $State.selectedFrameworks
        foreach ($lang in $fw.Keys) {
            $vals = @($fw[$lang])
            if ($vals.Count -gt 0) { Write-Host "  Frameworks ($lang): $($vals -join ', ')" }
        }
    }
    if ($State.selectedStructures) {
        $st = ConvertTo-Hashtable -InputObject $State.selectedStructures
        foreach ($k in $st.Keys) {
            if ($st[$k]) { Write-Host "  Structure ($k): $($st[$k])" }
        }
    }
    if ($State.selectedProcesses) {
        $pr = ConvertTo-Hashtable -InputObject $State.selectedProcesses
        foreach ($lang in $pr.Keys) {
            $vals = @($pr[$lang])
            if ($vals.Count -gt 0) { Write-Host "  Processes ($lang): $($vals -join ', ')" }
        }
    }
    Write-Host ""
}

function Save-State {
    param(
        [string[]]$SelectedTools,
        [string[]]$SelectedLanguages,
        [string[]]$SelectedDocumentation,
        [hashtable]$SelectedFrameworks,
        [hashtable]$SelectedStructures,
        [hashtable]$SelectedProcesses
    )

    function Normalize-StringArrayHashtable {
        param([hashtable]$InputTable)

        $out = @{}
        foreach ($k in $InputTable.Keys) {
            $v = $InputTable[$k]

            if ($null -eq $v) {
                $out[$k] = @()
                continue
            }

            # Convert single string to single-item array to keep schema stable.
            if ($v -is [string]) {
                $out[$k] = @($v)
                continue
            }

            # If it's already a collection, keep as array.
            if ($v -is [System.Collections.IEnumerable]) {
                $out[$k] = @($v)
                continue
            }

            $out[$k] = @($v.ToString())
        }
        return $out
    }

    $state = @{
        version = $Script:Version
        selectedTools = $SelectedTools
        selectedLanguages = $SelectedLanguages
        selectedDocumentation = $SelectedDocumentation
        selectedFrameworks = (Normalize-StringArrayHashtable -InputTable $SelectedFrameworks)
        selectedStructures = $SelectedStructures
        selectedProcesses = (Normalize-StringArrayHashtable -InputTable $SelectedProcesses)
    }

    # Write compact JSON to avoid noisy indentation differences across environments/editors.
    try {
        Add-Type -AssemblyName System.Web.Extensions -ErrorAction Stop
        $serializer = New-Object System.Web.Script.Serialization.JavaScriptSerializer
        $serializer.MaxJsonLength = 2147483647
        $json = $serializer.Serialize($state)
        $json | Out-File -FilePath $Script:StateFile -Encoding UTF8
    } catch {
        $state | ConvertTo-Json -Depth 100 | Out-File -FilePath $Script:StateFile -Encoding UTF8
    }
}

function ConvertTo-Hashtable {
    param([object]$InputObject)

    if ($null -eq $InputObject) {
        return @{}
    }

    if ($InputObject -is [hashtable]) {
        return $InputObject
    }

    # Convert PSCustomObject / PSObject to hashtable (shallow)
    $ht = @{}
    if ($InputObject -is [System.Collections.IDictionary]) {
        foreach ($k in $InputObject.Keys) {
            $ht[$k] = $InputObject[$k]
        }
        return $ht
    }

    if ($InputObject -is [PSCustomObject]) {
        foreach ($p in $InputObject.PSObject.Properties) {
            $ht[$p.Name] = $p.Value
        }
        return $ht
    }

    return @{}
}

function Remove-ManagedCursorRules {
    $root = Join-Path $Script:ProjectRoot ".cursor\rules"
    if (-not (Test-Path $root)) {
        return
    }

    Get-ChildItem -Path $root -Recurse -File -Filter "*.mdc" -ErrorAction SilentlyContinue | ForEach-Object {
        try {
            $txt = Get-Content $_.FullName -Raw -ErrorAction Stop
            if ($txt -match "aiIapManaged:\s*true") {
                Remove-Item $_.FullName -Force -ErrorAction SilentlyContinue
            }
        } catch { }
    }

    # Remove empty directories (bottom-up)
    Get-ChildItem -Path $root -Recurse -Directory -ErrorAction SilentlyContinue |
        Sort-Object FullName -Descending |
        Where-Object { @(Get-ChildItem -Path $_.FullName -Force -ErrorAction SilentlyContinue).Count -eq 0 } |
        ForEach-Object { Remove-Item $_.FullName -Force -ErrorAction SilentlyContinue }
}

function Remove-ManagedClaudeRules {
    $root = Join-Path $Script:ProjectRoot ".claude\rules"
    if (-not (Test-Path $root)) {
        return
    }

    Get-ChildItem -Path $root -Recurse -File -Filter "*.md" -ErrorAction SilentlyContinue | ForEach-Object {
        try {
            $txt = Get-Content $_.FullName -Raw -ErrorAction Stop
            if ($txt -match "aiIapManaged:\s*true") {
                Remove-Item $_.FullName -Force -ErrorAction SilentlyContinue
            }
        } catch { }
    }

    # Remove empty directories (bottom-up)
    Get-ChildItem -Path $root -Recurse -Directory -ErrorAction SilentlyContinue |
        Sort-Object FullName -Descending |
        Where-Object { @(Get-ChildItem -Path $_.FullName -Force -ErrorAction SilentlyContinue).Count -eq 0 } |
        ForEach-Object { Remove-Item $_.FullName -Force -ErrorAction SilentlyContinue }
}

function Remove-GeneratedFileIfManaged {
    param([string]$Path)

    if (-not (Test-Path $Path)) {
        return
    }

    try {
        $txt = Get-Content $Path -Raw -ErrorAction Stop
        if ($txt -match "Generated by AI Instructions and Prompts Setup") {
            Remove-Item $Path -Force -ErrorAction SilentlyContinue
        }
    } catch { }
}

function Cleanup-ToolOutputs {
    param([string]$Tool)

    switch ($Tool) {
        "cursor" { Remove-ManagedCursorRules }
        "claude" {
            Remove-ManagedClaudeRules
            Remove-GeneratedFileIfManaged -Path (Join-Path $Script:ProjectRoot "CLAUDE.md")
        }
        "github-copilot" { Remove-GeneratedFileIfManaged -Path (Join-Path $Script:ProjectRoot ".github\copilot-instructions.md") }
        "windsurf" { Remove-GeneratedFileIfManaged -Path (Join-Path $Script:ProjectRoot ".windsurfrules") }
        "aider" { Remove-GeneratedFileIfManaged -Path (Join-Path $Script:ProjectRoot "CONVENTIONS.md") }
        "google-ai-studio" { Remove-GeneratedFileIfManaged -Path (Join-Path $Script:ProjectRoot "GOOGLE_AI_STUDIO.md") }
        "amazon-q" { Remove-GeneratedFileIfManaged -Path (Join-Path $Script:ProjectRoot "AMAZON_Q.md") }
        "tabnine" { Remove-GeneratedFileIfManaged -Path (Join-Path $Script:ProjectRoot "TABNINE.md") }
        "cody" { Remove-GeneratedFileIfManaged -Path (Join-Path $Script:ProjectRoot ".cody\instructions.md") }
        "continue" { Remove-GeneratedFileIfManaged -Path (Join-Path $Script:ProjectRoot ".continue\instructions.md") }
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
    
    # Previous run handling
    $state = Get-PreviousState
    $setupMode = "wizard" # reuse | wizard | cleanup | fresh

    $usePreviousDefaults = $false
    if ($null -ne $state) {
        Write-PreviousStateSummary -State $state

        Write-Host "What would you like to do?" -ForegroundColor White
        Write-Host "  1. Reuse previous selection and regenerate (recommended)" -ForegroundColor White
        Write-Host "  2. Modify selection (run the wizard again)" -ForegroundColor White
        Write-Host "  3. Remove previously generated files (cleanup only)" -ForegroundColor White
        Write-Host "  4. Ignore previous selection (start fresh wizard)" -ForegroundColor White
        Write-Host ""

        $choice = Read-Host "Enter choice (1-4) [1]"
        if ([string]::IsNullOrWhiteSpace($choice)) { $choice = "1" }

        switch ($choice) {
            "1" { $setupMode = "reuse" }
            "2" { $setupMode = "wizard"; $usePreviousDefaults = $true }
            "3" { $setupMode = "cleanup" }
            "4" { $setupMode = "fresh" }
            default { $setupMode = "reuse" }
        }
    }

    if ($setupMode -eq "cleanup") {
        if ($state -and $state.selectedTools) {
            $confirmCleanup = Read-Host "Remove previously generated files for tools: $($state.selectedTools -join ', ')? (Y/n)"
            if ($confirmCleanup -ne "n" -and $confirmCleanup -ne "N") {
                foreach ($t in @($state.selectedTools)) {
                    Cleanup-ToolOutputs -Tool $t
                }
                if (Test-Path $Script:StateFile) {
                    Remove-Item $Script:StateFile -Force -ErrorAction SilentlyContinue
                }
                Write-SuccessMessage "Cleanup complete."
            }
        }
        exit 0
    }

    $selectedTools = @()
    $selectedLanguages = @()
    $selectedDocumentation = @()
    $selectedFrameworks = @{}
    $selectedStructures = @{}
    $selectedProcesses = @{}

    if ($setupMode -eq "reuse" -and $state) {
        $selectedTools = @($state.selectedTools)
        $selectedLanguages = @($state.selectedLanguages)
        $selectedDocumentation = @($state.selectedDocumentation)
        $selectedFrameworks = ConvertTo-Hashtable -InputObject $state.selectedFrameworks
        $selectedStructures = ConvertTo-Hashtable -InputObject $state.selectedStructures
        $selectedProcesses = ConvertTo-Hashtable -InputObject $state.selectedProcesses
    }
    else {
        # Selection (wizard)
        $defaultTools = @()
        $defaultLangs = @()
        $defaultDocs = @()
        $defaultFrameworks = @{}
        $defaultStructures = @{}
        $defaultProcesses = @{}

        if ($usePreviousDefaults -and $state) {
            $defaultTools = @($state.selectedTools)
            $defaultLangs = @($state.selectedLanguages)
            $defaultDocs = @($state.selectedDocumentation)
            $defaultFrameworks = ConvertTo-Hashtable -InputObject $state.selectedFrameworks
            $defaultStructures = ConvertTo-Hashtable -InputObject $state.selectedStructures
            $defaultProcesses = ConvertTo-Hashtable -InputObject $state.selectedProcesses
        }

        $selectedTools = Select-Tools -Config $config -DefaultSelected $defaultTools
    
    if ($selectedTools.Count -eq 0) {
        Write-WarningMessage "No tools selected. Exiting."
        exit 0
    }
    
        $selectedLanguages = Select-Languages -Config $config -DefaultSelected $defaultLangs
    
    if ($selectedLanguages.Count -eq 0) {
        Write-WarningMessage "No languages selected. Exiting."
        exit 0
    }
    
        # Documentation selection
        # Documentation selection (press Enter to keep previous; 's' removes all docs)
        $selectedDocumentation = Select-Documentation -Config $config -SelectedLanguages $selectedLanguages -DefaultSelectedDocumentation $defaultDocs
        
        # Framework selection
        $selectedFrameworks = Select-Frameworks -Config $config -SelectedLanguages $selectedLanguages -DefaultSelectedFrameworks $defaultFrameworks
        
        # Structure selection (for frameworks that have structure options)
        $selectedStructures = Select-Structures -Config $config -SelectedLanguages $selectedLanguages -SelectedFrameworks $selectedFrameworks -DefaultSelectedStructures $defaultStructures
        
        # Process selection
        $selectedProcesses = Select-Processes -Config $config -SelectedLanguages $selectedLanguages -DefaultSelectedProcesses $defaultProcesses
    }
    
    Write-Host ""
    Write-Host "Configuration Summary:"
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
    
    $confirm = Read-Host "Proceed with generation? (Y/n):"
    if ($confirm -eq 'n' -or $confirm -eq 'N') {
        Write-InfoMessage "Aborted."
        exit 0
    }
    
    Write-Host ""

    if ($null -ne $state) {
        $doCleanup = Read-Host "Clean up previously generated files for selected tools before regenerating? (Y/n)"
        if ($doCleanup -ne "n" -and $doCleanup -ne "N") {
            $toolSet = @{}
            foreach ($t in @($state.selectedTools)) { $toolSet[$t] = $true }
            foreach ($t in @($selectedTools)) { $toolSet[$t] = $true }
            foreach ($t in $toolSet.Keys) {
                Cleanup-ToolOutputs -Tool $t
            }
        }
    }
    
    # Generate files
    foreach ($tool in $selectedTools) {
        New-ToolConfig -Config $config -Tool $tool -SelectedLanguages $selectedLanguages -SelectedDocumentation $selectedDocumentation -SelectedFrameworks $selectedFrameworks -SelectedStructures $selectedStructures -SelectedProcesses $selectedProcesses
    }

    Save-State -SelectedTools $selectedTools -SelectedLanguages $selectedLanguages -SelectedDocumentation $selectedDocumentation -SelectedFrameworks $selectedFrameworks -SelectedStructures $selectedStructures -SelectedProcesses $selectedProcesses
    
    # Gitignore prompt
    Add-ToGitignore
    
    Write-Host ""
    Write-SuccessMessage "Setup complete!"
    Write-Host ""
    
    # Cleanup temp merged config
    if (Test-Path $Script:MergedConfigFile) {
        Remove-Item $Script:MergedConfigFile -Force -ErrorAction SilentlyContinue
    }
}

Main
