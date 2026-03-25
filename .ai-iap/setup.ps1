#Requires -Version 5.1
<#
.SYNOPSIS
    AI Instructions and Prompts Setup – dispatcher (Windows).
.DESCRIPTION
    Prompts for Rules only or Agents only, then runs setup-rules.ps1 or setup-agents.ps1.
    The actual setup logic lives in setup-common.ps1, setup-rules.ps1, and setup-agents.ps1.
.EXAMPLE
    .\.ai-iap\setup.ps1
.EXAMPLE
    .\.ai-iap\setup.ps1 -RulesOnly
.EXAMPLE
    .\.ai-iap\setup.ps1 -AgentsOnly
#>

param(
    [switch]$RulesOnly,
    [switch]$AgentsOnly
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

if ($RulesOnly) {
    & (Join-Path $ScriptDir "setup-rules.ps1")
    return
}
if ($AgentsOnly) {
    & (Join-Path $ScriptDir "setup-agents.ps1")
    return
}

Write-Host ""
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "        AI Instructions and Prompts Setup" -ForegroundColor Cyan
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "What do you want to set up?" -ForegroundColor White
Write-Host "  1. Rules only  - languages, frameworks, structures, processes for Claude Code" -ForegroundColor White
Write-Host "  2. Agents only - Claude Code agents (you define each: name, description, tech stack)" -ForegroundColor White
Write-Host ""
Write-Host "Tip: run .\.ai-iap\setup-rules.ps1 or .\.ai-iap\setup-agents.ps1 to skip this prompt." -ForegroundColor Gray
Write-Host ""

$choice = Read-Host "Enter choice (1 or 2) [1]"
if ([string]::IsNullOrWhiteSpace($choice)) { $choice = "1" }

if ($choice -eq "2") {
    & (Join-Path $ScriptDir "setup-agents.ps1")
} else {
    & (Join-Path $ScriptDir "setup-rules.ps1")
}
