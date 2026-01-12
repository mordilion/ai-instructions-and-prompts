# Verification Script for Extension System
# Tests that setup scripts can load and merge custom config

Write-Host "`n=====================================" -ForegroundColor Cyan
Write-Host "  Extension System Verification" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

$results = @{
    passed = 0
    failed = 0
    warnings = 0
}

function Test-Item {
    param($Name, $Condition, [switch]$Warning)
    
    if ($Condition) {
        Write-Host "[PASS] $Name" -ForegroundColor Green
        $script:results.passed++
    } else {
        if ($Warning) {
            Write-Host "[WARN] $Name" -ForegroundColor Yellow
            $script:results.warnings++
        } else {
            Write-Host "[FAIL] $Name" -ForegroundColor Red
            $script:results.failed++
        }
    }
}

# Test 1: Core config exists
Test-Item "Core config exists" (Test-Path ".ai-iap/config.json")

# Test 2: Example config exists (required for git)
$exampleConfig = Test-Path ".ai-iap-custom/config.example.json"
Test-Item "Example config exists" $exampleConfig

# Test 3: Example config is valid JSON
try {
    $customConfig = Get-Content .ai-iap-custom/config.example.json -Raw | ConvertFrom-Json
    Test-Item "Example config is valid JSON" $true
} catch {
    Test-Item "Example config is valid JSON" $false
    Write-Host "  Error: $_" -ForegroundColor DarkRed
}

# Test 4: Example rule file exists
$tsExampleRule = Test-Path ".ai-iap-custom/rules/typescript/company-standards.example.md"
Test-Item "Example rule file exists (company-standards.example.md)" $tsExampleRule

# Test 5: Example process file exists
$tsExampleProc = Test-Path ".ai-iap-custom/processes/typescript/deploy-internal.example.md"
Test-Item "Example process file exists (deploy-internal.example.md)" $tsExampleProc

# Test 6: Documentation exists
Test-Item "CUSTOMIZATION.md exists" (Test-Path "CUSTOMIZATION.md")
Test-Item "Custom README.md exists" (Test-Path ".ai-iap-custom/README.md")

# Test 7: Setup scripts have merge functions
$bashScript = Get-Content .ai-iap/setup.sh -Raw
$psScript = Get-Content .ai-iap/setup.ps1 -Raw

$bashHasMerge = $bashScript -match "merge_custom_config|CUSTOM_CONFIG"
$psHasMerge = $psScript -match "Merge-CustomConfig|CustomConfig"

Test-Item "Bash script has merge function" $bashHasMerge
Test-Item "PowerShell script has merge function" $psHasMerge

# Test 8: Config structure is correct
if ($customConfig) {
    $hasLanguages = $null -ne $customConfig.languages
    $hasTypeScript = $null -ne $customConfig.languages.typescript
    $hasCustomFiles = $null -ne $customConfig.languages.typescript.customFiles
    $hasCustomProcesses = $null -ne $customConfig.languages.typescript.customProcesses
    
    Test-Item "Custom config has 'languages' section" $hasLanguages
    Test-Item "Custom config has 'typescript' section" $hasTypeScript
    Test-Item "TypeScript has 'customFiles'" $hasCustomFiles
    Test-Item "TypeScript has 'customProcesses'" $hasCustomProcesses
}

# Summary
Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  Test Summary" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Passed:   $($results.passed)" -ForegroundColor Green
Write-Host "Failed:   $($results.failed)" -ForegroundColor $(if ($results.failed -eq 0) { "Green" } else { "Red" })
Write-Host "Warnings: $($results.warnings)" -ForegroundColor $(if ($results.warnings -eq 0) { "Green" } else { "Yellow" })
Write-Host ""

if ($results.failed -eq 0) {
    Write-Host "SUCCESS: Extension system is ready!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "  1. Run: .\.ai-iap\setup.ps1" -ForegroundColor White
    Write-Host "  2. Select TypeScript" -ForegroundColor White
    Write-Host "  3. Look for 'Deploy to Internal Platform' in process selection" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host "FAILED: $($results.failed) test(s) failed" -ForegroundColor Red
    Write-Host ""
    exit 1
}
