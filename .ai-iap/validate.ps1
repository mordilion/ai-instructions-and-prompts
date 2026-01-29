#Requires -Version 5.1
<#
.SYNOPSIS
    Validates AI Instructions & Prompts configuration and files
.DESCRIPTION
    Runs validation tests on config.json, rule files, and setup scripts
.EXAMPLE
    .\.ai-iap\validate.ps1
#>

$ErrorActionPreference = "Stop"

$Script:ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$Script:ConfigFile = Join-Path $Script:ScriptDir "config.json"
$Script:RulesDir = Join-Path $Script:ScriptDir "rules"
$Script:RepoRoot = Split-Path -Parent $Script:ScriptDir

$Script:PassCount = 0
$Script:FailCount = 0

function Test-Result {
    param([string]$Name, [bool]$Passed, [string]$Message = "")
    if ($Passed) {
        Write-Host "[PASS] " -ForegroundColor Green -NoNewline
        Write-Host $Name
        $Script:PassCount++
    } else {
        Write-Host "[FAIL] " -ForegroundColor Red -NoNewline
        Write-Host "$Name - $Message"
        $Script:FailCount++
    }
}

function Get-ReferencedRepoFilePathsFromText {
    param([string]$Text)

    $results = New-Object System.Collections.Generic.List[string]

    # Backticked paths: `path/to/file.ext`
    foreach ($m in [regex]::Matches($Text, '`([^`\\r\\n]+)`')) {
        $results.Add($m.Groups[1].Value)
    }

    # Markdown links: [label](path/to/file.ext)
    foreach ($m in [regex]::Matches($Text, '\[[^\]]+\]\(([^)\r\n]+)\)')) {
        $results.Add($m.Groups[1].Value)
    }

    # Extends lines: Extends: some/path.ext
    foreach ($m in [regex]::Matches($Text, '^\s*>\s*\*\*Extends\*\*:\s*([^\r\n]+)\s*$', [System.Text.RegularExpressions.RegexOptions]::Multiline)) {
        $results.Add($m.Groups[1].Value.Trim())
    }
    foreach ($m in [regex]::Matches($Text, '^\s*Extends:\s*([^\r\n]+)\s*$', [System.Text.RegularExpressions.RegexOptions]::Multiline)) {
        $results.Add($m.Groups[1].Value.Trim())
    }

    $results
}

function Is-ForbiddenRepoFileReference {
    param([string]$PathText)

    if ([string]::IsNullOrWhiteSpace($PathText)) { return $false }

    $p = $PathText.Trim()

    # Ignore URLs and mailto
    if ($p -match "^(https?:)?//" -or $p -match "^mailto:") { return $false }

    # Ignore anchors/fragments in links
    if ($p -match "#") { $p = ($p -split "#", 2)[0].Trim() }
    if ([string]::IsNullOrWhiteSpace($p)) { return $false }

    # Only consider things that look like repo paths (contain a slash) and are dot-prefixed
    # We intentionally do NOT treat single-file names like `package.json` as forbidden.
    $looksLikePath = ($p -match "[\\/]" )
    $isDotPrefixed = ($p -match "^\." )
    if (-not $looksLikePath -or -not $isDotPrefixed) { return $false }

    # If it looks like a file path inside the repo, forbid it (unstable across setups)
    if ($p -match "\.(mdc?|md|json|ya?ml|ps1|sh|txt)$") { return $true }

    # Also forbid explicit .ai-iap folder paths even if extension is missing
    if ($p -match "^\.ai-iap([\\/]|$)") { return $true }

    return $false
}

Write-Host "`n=== AI Instructions & Prompts Validation ===`n" -ForegroundColor Cyan

# Test 1: Config file exists
Test-Result "Config file exists" (Test-Path $Script:ConfigFile)

# Test 2: Config file is valid JSON
try {
    $config = Get-Content $Script:ConfigFile -Raw | ConvertFrom-Json
    Test-Result "Config file is valid JSON" $true
} catch {
    Test-Result "Config file is valid JSON" $false $_.Exception.Message
    exit 1
}

# Test 3: Config has required fields
Test-Result "Config has 'version' field" ($null -ne $config.version)
Test-Result "Config has 'tools' field" ($null -ne $config.tools)
Test-Result "Config has 'languages' field" ($null -ne $config.languages)

# Test 4: All rule files referenced in config exist
$missingFiles = @()
foreach ($langKey in $config.languages.PSObject.Properties.Name) {
    $lang = $config.languages.$langKey
    
    # Handle 'processes' folder (not under rules/)
    if ($langKey -eq "processes") {
        $langDir = Join-Path $Script:ScriptDir $langKey
    } else {
        $langDir = Join-Path $Script:RulesDir $langKey
    }
    
    foreach ($file in $lang.files) {
        $filePath = Join-Path $langDir "$file.md"
        if (-not (Test-Path $filePath)) {
            $missingFiles += "$langKey/$file.md"
        }
    }

    if ($null -ne $lang.optionalRules) {
        foreach ($ruleKey in $lang.optionalRules.PSObject.Properties.Name) {
            $rule = $lang.optionalRules.$ruleKey
            $rulePath = Join-Path $langDir "$($rule.file).md"
            if (-not (Test-Path $rulePath)) {
                $missingFiles += "$langKey/$($rule.file).md"
            }
        }
    }
    
    if ($null -ne $lang.frameworks) {
        foreach ($fwKey in $lang.frameworks.PSObject.Properties.Name) {
            $fw = $lang.frameworks.$fwKey
            $fwPath = Join-Path $langDir "frameworks\$($fw.file).md"
            if (-not (Test-Path $fwPath)) {
                $missingFiles += "$langKey/frameworks/$($fw.file).md"
            }
            
            if ($null -ne $fw.structures) {
                foreach ($structKey in $fw.structures.PSObject.Properties.Name) {
                    $struct = $fw.structures.$structKey
                    $structPath = Join-Path $langDir "frameworks\structures\$($struct.file).md"
                    if (-not (Test-Path $structPath)) {
                        $missingFiles += "$langKey/frameworks/structures/$($struct.file).md"
                    }
                }
            }
        }
    }
}

# Test 4b: Tool preamble files exist (if configured)
$missingPreambles = @()
foreach ($toolKey in $config.tools.PSObject.Properties.Name) {
    $tool = $config.tools.$toolKey
    if ($null -ne $tool.preambleFile -and -not [string]::IsNullOrWhiteSpace($tool.preambleFile)) {
        $preamblePath = Join-Path (Join-Path $Script:RulesDir "general") ("$($tool.preambleFile).md")
        if (-not (Test-Path $preamblePath)) {
            $missingPreambles += "general/$($tool.preambleFile).md (tool: $toolKey)"
        }
    }
}
Test-Result "All tool preamble files exist" ($missingPreambles.Count -eq 0) "Missing: $($missingPreambles -join ', ')"

Test-Result "All rule files exist" ($missingFiles.Count -eq 0) "Missing: $($missingFiles -join ', ')"

# Test 5: All markdown files have valid structure
$invalidMarkdown = @()
Get-ChildItem -Path $Script:RulesDir -Recurse -Filter "*.md" | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    if (-not $content.StartsWith("#")) {
        $invalidMarkdown += $_.Name
    }
}

Test-Result "All markdown files start with header" ($invalidMarkdown.Count -eq 0) "Invalid: $($invalidMarkdown -join ', ')"

# Test 6: Rules/processes must NOT reference repo file paths
$forbiddenRefs = @()
$dirsToScan = @(
    (Join-Path $Script:ScriptDir "rules"),
    (Join-Path $Script:ScriptDir "processes"),
    (Join-Path $Script:RepoRoot ".cursor\rules")
)
foreach ($dir in $dirsToScan) {
    if (-not (Test-Path $dir)) { continue }

    Get-ChildItem -Path $dir -Recurse -Include "*.md","*.mdc" | ForEach-Object {
        $ruleFile = $_.FullName
        $text = Get-Content $ruleFile -Raw

        $refs = Get-ReferencedRepoFilePathsFromText -Text $text | Select-Object -Unique
        foreach ($ref in $refs) {
            if (-not (Is-ForbiddenRepoFileReference -PathText $ref)) { continue }

            $relRule = $ruleFile.Substring($Script:RepoRoot.Length).TrimStart('\','/')
            $forbiddenRefs += "$relRule contains forbidden file reference '$ref'"
        }
    }
}

Test-Result "No repo file-path references in rules/processes" ($forbiddenRefs.Count -eq 0) "Found: $($forbiddenRefs -join '; ')"

# Test 7: No duplicate framework keys
$duplicateKeys = @()
foreach ($langKey in $config.languages.PSObject.Properties.Name) {
    $lang = $config.languages.$langKey
    if ($null -ne $lang.frameworks) {
        $keys = $lang.frameworks.PSObject.Properties.Name
        $uniqueKeys = $keys | Select-Object -Unique
        if ($keys.Count -ne $uniqueKeys.Count) {
            $duplicateKeys += $langKey
        }
    }
}

Test-Result "No duplicate framework keys" ($duplicateKeys.Count -eq 0) "Duplicates in: $($duplicateKeys -join ', ')"

# Test 8: Check for frameworks with unresolved dependencies
$unresolvedDeps = @()
foreach ($langKey in $config.languages.PSObject.Properties.Name) {
    $lang = $config.languages.$langKey
    if ($null -ne $lang.frameworks) {
        foreach ($fwKey in $lang.frameworks.PSObject.Properties.Name) {
            $fw = $lang.frameworks.$fwKey
            if ($null -ne $fw.requires) {
                foreach ($required in $fw.requires) {
                    if ($null -eq $lang.frameworks.$required) {
                        $unresolvedDeps += "$langKey/$fwKey requires '$required' (not found)"
                    }
                }
            }
        }
    }
}

Test-Result "All framework dependencies exist" ($unresolvedDeps.Count -eq 0) "Unresolved: $($unresolvedDeps -join ', ')"

# Summary
Write-Host "`n=== Summary ===" -ForegroundColor Cyan
Write-Host "Passed: $Script:PassCount" -ForegroundColor Green
Write-Host "Failed: $Script:FailCount" -ForegroundColor Red

if ($Script:FailCount -gt 0) {
    exit 1
}

Write-Host "`nAll validation tests passed!`n" -ForegroundColor Green
exit 0

