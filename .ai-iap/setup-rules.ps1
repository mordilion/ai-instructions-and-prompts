#Requires -Version 5.1
<#
.SYNOPSIS
    Rules-only setup: languages, frameworks, tools (Cursor, Claude rules, Copilot, etc.).
.DESCRIPTION
    Standalone script. Dot-sources setup-common.ps1 and runs the rules flow.
.EXAMPLE
    .\.ai-iap\setup-rules.ps1
#>

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $scriptDir "setup-common.ps1")

$Script:SetupType = "rules"

Write-Header

try {
    $config = Get-Configuration
} catch {
    Write-ErrorMessage $_.Exception.Message
    exit 1
}

Select-Scope

Set-Location $Script:ProjectRoot
Write-InfoMessage "Project root (source): $Script:ProjectRoot"
Write-InfoMessage "Output root: $Script:OutputRoot (scope: $Script:Scope)"
Write-Host ""

$state = Get-PreviousState
$setupMode = "wizard"
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
$enableProjectLearnings = $false
$enableCommitStandards = $true

if ($setupMode -eq "reuse" -and $state) {
    $selectedTools = @($state.selectedTools)
    $selectedLanguages = @($state.selectedLanguages)
    $selectedDocumentation = if ($state.selectedDocumentation) { @($state.selectedDocumentation) } else { @() }
    $selectedFrameworks = ConvertTo-Hashtable -InputObject $state.selectedFrameworks
    $selectedStructures = ConvertTo-Hashtable -InputObject $state.selectedStructures
    $selectedProcesses = ConvertTo-Hashtable -InputObject $state.selectedProcesses
    if ($null -ne $state.enableProjectLearnings) { $enableProjectLearnings = [bool]$state.enableProjectLearnings }
    if ($null -ne $state.enableCommitStandards) { $enableCommitStandards = [bool]$state.enableCommitStandards }
    New-ProjectLearningsFileIfMissing -EnableProjectLearnings $enableProjectLearnings
} else {
    $defaultTools = @()
    $defaultLangs = @()
    $defaultDocs = @()
    $defaultFrameworks = @{}
    $defaultStructures = @{}
    $defaultProcesses = @{}
    $defaultLearnings = $false
    $defaultCommitStandards = $true
    if ($usePreviousDefaults -and $state) {
        $defaultTools = @($state.selectedTools)
        $defaultLangs = @($state.selectedLanguages)
        $defaultDocs = @($state.selectedDocumentation)
        $defaultFrameworks = ConvertTo-Hashtable -InputObject $state.selectedFrameworks
        $defaultStructures = ConvertTo-Hashtable -InputObject $state.selectedStructures
        $defaultProcesses = ConvertTo-Hashtable -InputObject $state.selectedProcesses
        if ($null -ne $state.enableProjectLearnings) { $defaultLearnings = [bool]$state.enableProjectLearnings }
        if ($null -ne $state.enableCommitStandards) { $defaultCommitStandards = [bool]$state.enableCommitStandards }
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
    $selectedDocumentation = Select-Documentation -Config $config -SelectedLanguages $selectedLanguages -DefaultSelectedDocumentation $defaultDocs
    $enableCommitStandards = Select-CommitStandards -DefaultEnabled $defaultCommitStandards
    $enableProjectLearnings = Select-ProjectLearningsCapture -DefaultEnabled $defaultLearnings
    $selectedFrameworks = Select-Frameworks -Config $config -SelectedLanguages $selectedLanguages -DefaultSelectedFrameworks $defaultFrameworks
    $selectedStructures = Select-Structures -Config $config -SelectedLanguages $selectedLanguages -SelectedFrameworks $selectedFrameworks -DefaultSelectedStructures $defaultStructures
    $selectedProcesses = Select-Processes -Config $config -SelectedLanguages $selectedLanguages -DefaultSelectedProcesses $defaultProcesses
}

Write-Host ""
Write-Host "Configuration Summary:" -ForegroundColor Cyan
Write-Host "  Tools: $($selectedTools -join ', ')"
Write-Host "  Languages: $($selectedLanguages -join ', ')"
if ($selectedDocumentation.Count -gt 0) {
    Write-Host "  Documentation: $($selectedDocumentation -join ', ')"
}
Write-Host "  Project learnings capture: $enableProjectLearnings"
Write-Host "  Commit standards: $enableCommitStandards"
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

foreach ($tool in $selectedTools) {
    New-ToolConfig -Config $config -Tool $tool -SelectedLanguages $selectedLanguages -SelectedDocumentation $selectedDocumentation -SelectedFrameworks $selectedFrameworks -SelectedStructures $selectedStructures -SelectedProcesses $selectedProcesses -EnableProjectLearnings $enableProjectLearnings -EnableCommitStandards $enableCommitStandards
}

$prevAgents = @()
if ($null -ne $state -and $state.selectedCustomAgents) {
    $prevAgents = @($state.selectedCustomAgents)
}
Save-State -SelectedTools $selectedTools -SelectedLanguages $selectedLanguages -SelectedDocumentation $selectedDocumentation -SelectedFrameworks $selectedFrameworks -SelectedStructures $selectedStructures -SelectedProcesses $selectedProcesses -EnableProjectLearnings $enableProjectLearnings -EnableCommitStandards $enableCommitStandards -Scope $Script:Scope -SetupType "rules" -SelectedCustomAgents $prevAgents

Add-ToGitignore

Write-Host ""
Write-SuccessMessage "Setup complete!"
Write-Host ""

if (Test-Path $Script:MergedConfigFile) {
    Remove-Item $Script:MergedConfigFile -Force -ErrorAction SilentlyContinue
}
