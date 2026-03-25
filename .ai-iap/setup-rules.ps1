#Requires -Version 5.1
<#
.SYNOPSIS
    Rules-only setup: languages, frameworks, structures, processes for Claude Code.
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
    if ($null -ne $state) {
        $confirmCleanup = Read-Host "Remove previously generated files? (Y/n)"
        if ($confirmCleanup -ne "n" -and $confirmCleanup -ne "N") {
            Cleanup-ClaudeOutputs
            if (Test-Path $Script:StateFile) {
                Remove-Item $Script:StateFile -Force -ErrorAction SilentlyContinue
            }
            Write-SuccessMessage "Cleanup complete."
        }
    }
    exit 0
}

$selectedLanguages = @()
$selectedDocumentation = @()
$selectedFrameworks = @{}
$selectedStructures = @{}
$selectedProcesses = @{}
$enableCommitStandards = $true

if ($setupMode -eq "reuse" -and $state) {
    $selectedLanguages = @($state.selectedLanguages)
    $selectedDocumentation = if ($state.selectedDocumentation) { @($state.selectedDocumentation) } else { @() }
    $selectedFrameworks = ConvertTo-Hashtable -InputObject $state.selectedFrameworks
    $selectedStructures = ConvertTo-Hashtable -InputObject $state.selectedStructures
    $selectedProcesses = ConvertTo-Hashtable -InputObject $state.selectedProcesses
    if ($null -ne $state.enableCommitStandards) { $enableCommitStandards = [bool]$state.enableCommitStandards }
} else {
    $defaultLangs = @()
    $defaultDocs = @()
    $defaultFrameworks = @{}
    $defaultStructures = @{}
    $defaultProcesses = @{}
    $defaultCommitStandards = $true
    if ($usePreviousDefaults -and $state) {
        $defaultLangs = @($state.selectedLanguages)
        $defaultDocs = @($state.selectedDocumentation)
        $defaultFrameworks = ConvertTo-Hashtable -InputObject $state.selectedFrameworks
        $defaultStructures = ConvertTo-Hashtable -InputObject $state.selectedStructures
        $defaultProcesses = ConvertTo-Hashtable -InputObject $state.selectedProcesses
        if ($null -ne $state.enableCommitStandards) { $defaultCommitStandards = [bool]$state.enableCommitStandards }
    }

    $selectedLanguages = Select-Languages -Config $config -DefaultSelected $defaultLangs
    if ($selectedLanguages.Count -eq 0) {
        Write-WarningMessage "No languages selected. Exiting."
        exit 0
    }
    $selectedDocumentation = Select-Documentation -Config $config -SelectedLanguages $selectedLanguages -DefaultSelectedDocumentation $defaultDocs
    $enableCommitStandards = Select-CommitStandards -DefaultEnabled $defaultCommitStandards
    $selectedFrameworks = Select-Frameworks -Config $config -SelectedLanguages $selectedLanguages -DefaultSelectedFrameworks $defaultFrameworks
    $selectedStructures = Select-Structures -Config $config -SelectedLanguages $selectedLanguages -SelectedFrameworks $selectedFrameworks -DefaultSelectedStructures $defaultStructures
    $selectedProcesses = Select-Processes -Config $config -SelectedLanguages $selectedLanguages -DefaultSelectedProcesses $defaultProcesses
}

Write-Host ""
Write-Host "Configuration Summary:" -ForegroundColor Cyan
Write-Host "  Languages: $($selectedLanguages -join ', ')"
if ($selectedDocumentation.Count -gt 0) {
    Write-Host "  Documentation: $($selectedDocumentation -join ', ')"
}
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
    $doCleanup = Read-Host "Clean up previously generated files before regenerating? (Y/n)"
    if ($doCleanup -ne "n" -and $doCleanup -ne "N") {
        Cleanup-ClaudeOutputs
    }
}

New-AllConfig -Config $config -SelectedLanguages $selectedLanguages -SelectedDocumentation $selectedDocumentation -SelectedFrameworks $selectedFrameworks -SelectedStructures $selectedStructures -SelectedProcesses $selectedProcesses -EnableCommitStandards $enableCommitStandards

$prevAgents = @()
if ($null -ne $state -and $state.selectedCustomAgents) {
    $prevAgents = @($state.selectedCustomAgents)
}
Save-State -SelectedLanguages $selectedLanguages -SelectedDocumentation $selectedDocumentation -SelectedFrameworks $selectedFrameworks -SelectedStructures $selectedStructures -SelectedProcesses $selectedProcesses -EnableCommitStandards $enableCommitStandards -Scope $Script:Scope -SetupType "rules" -SelectedCustomAgents $prevAgents

Add-ToGitignore

Write-Host ""
Write-SuccessMessage "Setup complete!"
Write-Host ""

if (Test-Path $Script:MergedConfigFile) {
    Remove-Item $Script:MergedConfigFile -Force -ErrorAction SilentlyContinue
}
