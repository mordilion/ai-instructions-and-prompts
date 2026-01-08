# Config Validation Script
# Checks for consistency, missing properties, and structural issues

$ErrorCount = 0
$WarningCount = 0

function Write-Issue {
    param([string]$Type, [string]$Message)
    if ($Type -eq "ERROR") {
        Write-Host "[ERROR] $Message" -ForegroundColor Red
        $script:ErrorCount++
    } else {
        Write-Host "[WARNING] $Message" -ForegroundColor Yellow
        $script:WarningCount++
    }
}

function Write-Success {
    param([string]$Message)
    Write-Host "[OK] $Message" -ForegroundColor Green
}

Write-Host ""
Write-Host "=== Config Validation ===" -ForegroundColor Cyan
Write-Host ""

# Load config
try {
    $config = Get-Content .ai-iap/config.json -Raw | ConvertFrom-Json
    Write-Success "JSON syntax is valid"
} catch {
    Write-Issue "ERROR" "Failed to parse config.json: $_"
    exit 1
}

# Check version
if ($config.version) {
    Write-Success "Version: $($config.version)"
} else {
    Write-Issue "ERROR" "Missing 'version' property"
}

# Validate Tools
Write-Host ""
Write-Host "--- Tools Validation ---" -ForegroundColor Cyan
$toolCount = 0
foreach ($toolKey in $config.tools.PSObject.Properties.Name) {
    $toolCount++
    $tool = $config.tools.$toolKey
    
    # Check required properties
    if (-not $tool.name) {
        Write-Issue "ERROR" "Tool '$toolKey': Missing 'name' property"
    }
    if ($null -eq $tool.useFrontmatter) {
        Write-Issue "ERROR" "Tool '$toolKey': Missing 'useFrontmatter' property"
    }
    if ($null -eq $tool.fileExtension) {
        Write-Issue "ERROR" "Tool '$toolKey': Missing 'fileExtension' property"
    }
    
    # Check tool type consistency
    # Exception: Claude needs both outputDir (.claude/skills) and outputFile (CLAUDE.md)
    if ($tool.outputDir -and $tool.outputFile -and $toolKey -ne "claude") {
        Write-Issue "ERROR" "Tool '$toolKey': Has both 'outputDir' and 'outputFile' (should have only one)"
    }
    if (-not $tool.outputDir -and -not $tool.outputFile) {
        Write-Issue "ERROR" "Tool '$toolKey': Missing both 'outputDir' and 'outputFile' (needs one)"
    }
    
    # Cursor-specific checks
    if ($toolKey -eq "cursor") {
        if (-not $tool.supportsGlobs) {
            Write-Issue "WARNING" "Tool 'cursor': Should have 'supportsGlobs: true'"
        }
        if (-not $tool.supportsSubfolders) {
            Write-Issue "WARNING" "Tool 'cursor': Should have 'supportsSubfolders: true'"
        }
    }
    
    # Claude-specific checks (unified CLI & Code)
    if ($toolKey -eq "claude") {
        if (-not $tool.skillFilename) {
            Write-Issue "WARNING" "Tool 'claude': Missing 'skillFilename' property (should be 'SKILL.md')"
        }
        if (-not $tool.supportsSubfolders) {
            Write-Issue "WARNING" "Tool 'claude': Should have 'supportsSubfolders: true'"
        }
        if ($tool.supportsGlobs) {
            Write-Issue "WARNING" "Tool 'claude': Should have 'supportsGlobs: false' (uses directory-based skills)"
        }
        if (-not $tool.outputFile) {
            Write-Issue "WARNING" "Tool 'claude': Missing 'outputFile' property (should be 'CLAUDE.md')"
        }
        if (-not $tool.outputDir) {
            Write-Issue "WARNING" "Tool 'claude': Missing 'outputDir' property (should be '.claude/skills')"
        }
    }
}
Write-Success "Validated $toolCount tools"

# Validate Languages
Write-Host ""
Write-Host "--- Languages Validation ---" -ForegroundColor Cyan
$langCount = 0
$requiredLangProps = @("name", "globs", "alwaysApply", "description", "files")

foreach ($langKey in $config.languages.PSObject.Properties.Name) {
    $langCount++
    $lang = $config.languages.$langKey
    
    Write-Host ""
    Write-Host "Language: $langKey" -ForegroundColor White
    
    # Check required properties
    foreach ($prop in $requiredLangProps) {
        if ($null -eq $lang.$prop) {
            Write-Issue "ERROR" "Language '$langKey': Missing '$prop' property"
        }
    }
    
    # Check globs format
    if ($lang.globs) {
        if ($lang.globs -is [array]) {
            Write-Issue "ERROR" "Language '$langKey': 'globs' should be a string, not an array"
        }
    }
    
    # Check alwaysApply is boolean
    if ($null -ne $lang.alwaysApply -and $lang.alwaysApply -isnot [bool]) {
        Write-Issue "ERROR" "Language '$langKey': 'alwaysApply' should be boolean (true/false)"
    }
    
    # Check files is array
    if ($lang.files -and $lang.files -isnot [array]) {
        Write-Issue "ERROR" "Language '$langKey': 'files' should be an array"
    }
    
    # Check for obsolete properties
    if ($lang.PSObject.Properties.Name -contains "enabled") {
        Write-Issue "ERROR" "Language '$langKey': Uses obsolete 'enabled' property (use 'alwaysApply' instead)"
    }
    
    # Validate frameworks
    if ($lang.frameworks) {
        $fwCount = 0
        $structCount = 0
        foreach ($fwKey in $lang.frameworks.PSObject.Properties.Name) {
            $fwCount++
            $fw = $lang.frameworks.$fwKey
            
            if (-not $fw.name) {
                Write-Issue "ERROR" "Language '$langKey', Framework '$fwKey': Missing 'name' property"
            }
            if (-not $fw.file) {
                Write-Issue "ERROR" "Language '$langKey', Framework '$fwKey': Missing 'file' property"
            }
            if (-not $fw.category) {
                Write-Issue "WARNING" "Language '$langKey', Framework '$fwKey': Missing 'category' property"
            }
            if (-not $fw.description) {
                Write-Issue "WARNING" "Language '$langKey', Framework '$fwKey': Missing 'description' property"
            }
            
            # Validate structures
            if ($fw.structures) {
                foreach ($structKey in $fw.structures.PSObject.Properties.Name) {
                    $structCount++
                    $struct = $fw.structures.$structKey
                    
                    if (-not $struct.name) {
                        Write-Issue "ERROR" "Language '$langKey', Framework '$fwKey', Structure '$structKey': Missing 'name'"
                    }
                    if (-not $struct.file) {
                        Write-Issue "ERROR" "Language '$langKey', Framework '$fwKey', Structure '$structKey': Missing 'file'"
                    }
                    if (-not $struct.description) {
                        Write-Issue "WARNING" "Language '$langKey', Framework '$fwKey', Structure '$structKey': Missing 'description'"
                    }
                }
            }
        }
        if ($structCount -gt 0) {
            Write-Host "  Frameworks: $fwCount, Structures: $structCount" -ForegroundColor DarkGray
        } else {
            Write-Host "  Frameworks: $fwCount" -ForegroundColor DarkGray
        }
    }
    
    # Validate processes
    if ($lang.processes) {
        $procCount = 0
        foreach ($procKey in $lang.processes.PSObject.Properties.Name) {
            $procCount++
            $proc = $lang.processes.$procKey
            
            if (-not $proc.name) {
                Write-Issue "ERROR" "Language '$langKey', Process '$procKey': Missing 'name' property"
            }
            if (-not $proc.file) {
                Write-Issue "ERROR" "Language '$langKey', Process '$procKey': Missing 'file' property"
            }
            if (-not $proc.description) {
                Write-Issue "WARNING" "Language '$langKey', Process '$procKey': Missing 'description' property"
            }
        }
        Write-Host "  Processes: $procCount" -ForegroundColor DarkGray
    }
    
    # Special validation for 'general' language
    if ($langKey -eq "general") {
        if ($lang.alwaysApply -ne $true) {
            Write-Issue "ERROR" "Language 'general': Should have 'alwaysApply: true'"
        }
        if (-not $lang.documentation) {
            Write-Issue "WARNING" "Language 'general': Missing 'documentation' section"
        }
    } else {
        if ($lang.alwaysApply -eq $true) {
            Write-Issue "WARNING" "Language '$langKey': Has 'alwaysApply: true' (only 'general' should have this)"
        }
    }
}

Write-Success "Validated $langCount languages"

# Summary
Write-Host ""
Write-Host "=== Validation Summary ===" -ForegroundColor Cyan
Write-Host "Tools: $toolCount" -ForegroundColor White
Write-Host "Languages: $langCount" -ForegroundColor White
Write-Host ""

if ($ErrorCount -eq 0 -and $WarningCount -eq 0) {
    Write-Host "SUCCESS: No issues found! Config is perfect." -ForegroundColor Green
    exit 0
} elseif ($ErrorCount -eq 0) {
    Write-Host "SUCCESS: Found $WarningCount warnings (non-critical)" -ForegroundColor Yellow
    exit 0
} else {
    Write-Host "FAILED: Found $ErrorCount errors and $WarningCount warnings" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please fix the errors above before using the config." -ForegroundColor Red
    exit 1
}
