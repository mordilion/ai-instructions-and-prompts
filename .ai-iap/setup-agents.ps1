#Requires -Version 5.1
<#
.SYNOPSIS
    Agents-only setup: Claude Code agents (you define each: name, description, tech stack).
.DESCRIPTION
    Runs the Bash-based agents flow when bash is available (Git Bash, WSL).
    Otherwise prompts to use Git Bash or WSL for full agent setup.
.EXAMPLE
    .\.ai-iap\setup-agents.ps1
#>

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $scriptDir "setup-common.ps1")

$bashScript = Join-Path $scriptDir "setup-agents.sh"
$projectRoot = Split-Path -Parent $scriptDir

if (-not (Test-Path $bashScript)) {
    Write-ErrorMessage "Agents setup script not found: $bashScript"
    exit 1
}

function Show-AgentsSetupFallbackMessage {
    Write-Host ""
    Write-Host "Agents setup requires a working Bash (e.g. Git for Windows)." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Options:" -ForegroundColor White
    Write-Host "  1. Install Git for Windows, open Git Bash, then run:" -ForegroundColor White
    Write-Host "     cd ""$projectRoot""" -ForegroundColor Gray
    Write-Host "     bash ./.ai-iap/setup-agents.sh" -ForegroundColor Gray
    Write-Host "  2. If you use WSL, ensure it is installed and run from your project in WSL:" -ForegroundColor White
    Write-Host "     wsl -e bash -c ""cd '$($projectRoot -replace "'", "'\\\\''")' && ./.ai-iap/setup-agents.sh""" -ForegroundColor Gray
    Write-Host ""
    Write-Host "You can also define agents via .ai-iap-custom/claude-agents.json; see CUSTOMIZATION.md." -ForegroundColor Gray
    Write-Host ""
}

$bashExe = $null
foreach ($name in @("bash", "wsl")) {
    $bashExe = Get-Command $name -ErrorAction SilentlyContinue
    if ($bashExe) { break }
}

# Probe: ensure bash actually runs (avoids WSL relay failure dumping errors)
$bashWorks = $false
if ($bashExe) {
    try {
        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName = $bashExe.Name
        $psi.Arguments = '-c "exit 0"'
        $psi.WorkingDirectory = $projectRoot
        $psi.UseShellExecute = $false
        $psi.CreateNoWindow = $true
        $psi.RedirectStandardError = $true
        $psi.RedirectStandardOutput = $true
        $p = [System.Diagnostics.Process]::Start($psi)
        $p.WaitForExit(5000)
        if ($p.ExitCode -eq 0) { $bashWorks = $true }
    } catch { }
}

if (-not $bashWorks) {
    Show-AgentsSetupFallbackMessage
    exit 1
}

Push-Location $projectRoot
try {
    & $bashExe.Name $bashScript @args
    exit $LASTEXITCODE
} finally {
    Pop-Location
}
