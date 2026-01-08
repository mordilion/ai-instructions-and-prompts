# Setup Script Updates Needed

## Overview

The setup scripts (setup.sh and setup.ps1) need to be updated to handle permanent vs on-demand processes differently.

---

## Current Behavior

Currently, all selected processes are generated into AI tool files (e.g., `.cursor/rules/`, `CLAUDE.md`, etc.).

---

## Required Behavior

**Permanent Processes** (`loadIntoAI: true`):
- Generate into AI tool files (as currently done)
- Example: `database-migrations.md`

**On-Demand Processes** (`loadIntoAI: false`):
- Do NOT generate into AI tool files
- Optionally: Copy to project root or docs/ for reference
- User will copy prompts when needed

---

## Changes Required

### 1. Process Selection Function (Both Scripts)

**Location**: 
- PowerShell: Lines 500-560 (`Select-Processes`)
- Bash: Similar function

**Change**: 
Add indicator showing which processes are permanent vs on-demand

```powershell
# Current code (line 520-529)
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

# Updated code - add LoadIntoAI flag
foreach ($key in $langConfig.processes.PSObject.Properties.Name) {
    $proc = $langConfig.processes.$key
    $processKeys += $key
    
    # Add type indicator
    $typeIndicator = if ($proc.loadIntoAI) { "📌" } else { "📋" }
    $typeLabel = if ($proc.loadIntoAI) { "permanent" } else { "on-demand" }
    
    $processes += @{
        Key = $key
        Name = $proc.name
        Description = "$($proc.description) [$typeLabel]"
        File = $proc.file
        Index = $index
        LoadIntoAI = $proc.loadIntoAI
    }
    $index++
}
```

**Also update display** (line 542-544):
```powershell
# Show type indicator in the list
foreach ($proc in $processes) {
    $indicator = if ($proc.LoadIntoAI) { "📌" } else { "📋" }
    Write-Host "  $($proc.Index + 1). $indicator $($proc.Name) - $($proc.Description)"
}
```

---

### 2. Process File Generation (All Tool Functions)

**Locations to Update**:

#### Cursor (Lines ~828-856):
```powershell
# Current code
# Generate process files for this language
if ($SelectedProcesses.ContainsKey($lang)) {
    foreach ($proc in $SelectedProcesses[$lang]) {
        $procConfig = $Config.languages.$lang.processes.$proc
        $content = Read-InstructionFile -Lang $lang -File $procConfig.file -IsProcess $true
        
        if ($null -eq $content) {
            continue
        }
        
        $outputFile = Join-Path $langDir "$($procConfig.file).mdc"
        # ... rest of generation ...
    }
}

# Updated code - check loadIntoAI flag
if ($SelectedProcesses.ContainsKey($lang)) {
    foreach ($proc in $SelectedProcesses[$lang]) {
        $procConfig = $Config.languages.$lang.processes.$proc
        
        # SKIP if on-demand process
        if ($procConfig.loadIntoAI -eq $false) {
            Write-InfoMessage "Skipped on-demand process: $proc (copy prompt from file when needed)"
            continue
        }
        
        # Only generate if loadIntoAI is true
        $content = Read-InstructionFile -Lang $lang -File $procConfig.file -IsProcess $true
        
        if ($null -eq $content) {
            continue
        }
        
        $outputFile = Join-Path $langDir "$($procConfig.file).mdc"
        # ... rest of generation ...
    }
}
```

**Same pattern applies to**:
- Claude generation (~Lines 988-1010)
- GitHub Copilot generation (~Lines 1137-1160)
- All other tool generators

---

### 3. Optional: Copy On-Demand Processes to Project

Add new function after all tool generation:

```powershell
function Copy-OnDemandProcesses {
    param(
        [PSCustomObject]$Config,
        [hashtable]$SelectedProcesses
    )
    
    Write-Host ""
    Write-Host "Copying on-demand process files for reference..." -ForegroundColor Cyan
    Write-Host ""
    
    $ondemandDir = Join-Path $Script:ProjectRoot "process-guides"
    
    foreach ($lang in $SelectedProcesses.Keys) {
        foreach ($proc in $SelectedProcesses[$lang]) {
            $procConfig = $Config.languages.$lang.processes.$proc
            
            # Only copy if it's on-demand
            if ($procConfig.loadIntoAI -eq $false) {
                $sourcePath = Join-Path $Script:ScriptDir "processes\_ondemand\$lang\$($procConfig.file).md"
                
                if (Test-Path $sourcePath) {
                    $langDir = Join-Path $ondemandDir $lang
                    if (-not (Test-Path $langDir)) {
                        New-Item -ItemType Directory -Path $langDir -Force | Out-Null
                    }
                    
                    $destPath = Join-Path $langDir "$($procConfig.file).md"
                    Copy-Item -Path $sourcePath -Destination $destPath -Force
                    
                    Write-SuccessMessage "Copied $lang/$($procConfig.file).md to process-guides/"
                }
            }
        }
    }
    
    Write-Host ""
    Write-Host "On-demand processes copied to ./process-guides/" -ForegroundColor Green
    Write-Host "Copy the 'Usage' section prompt when ready to implement." -ForegroundColor Yellow
    Write-Host ""
}
```

Call this function at the end of main setup flow.

---

### 4. Update Help Text

Add explanation about permanent vs on-demand:

```powershell
Write-Host ""
Write-Host "Process Types:" -ForegroundColor Yellow
Write-Host "  📌 Permanent - Loaded into AI permanently (recurring tasks)"
Write-Host "  📋 On-Demand  - Copy prompt when needed (one-time setups)"
Write-Host ""
```

---

## Summary of Changes

| Location | Change | Impact |
|----------|--------|--------|
| `Select-Processes` | Add LoadIntoAI flag display | User sees which are permanent |
| All tool generators | Check `loadIntoAI` flag | Only permanent processes loaded into AI |
| New function | Copy on-demand to reference dir | User has easy access to prompts |
| Help text | Explain permanent vs on-demand | Better UX |

---

## Testing

After updates:

1. Run setup script
2. Select a mix of permanent and on-demand processes
3. Verify:
   - ✅ Permanent processes appear in AI tool files
   - ✅ On-demand processes do NOT appear in AI tool files
   - ✅ On-demand processes copied to `process-guides/` (if implemented)
   - ✅ User sees clear indication of process types

---

## Files to Update

- [x] `setup.ps1` - PowerShell version
- [ ] `setup.sh` - Bash version (same logic)

---

## Priority

**HIGH** - This is the core functionality change needed for the permanent/on-demand architecture to work properly.

Without these changes, users will get all 69 processes loaded into their AI tools, defeating the purpose of the token efficiency improvement.

---

## Status

- Architecture: ✅ Complete
- Prompts: ✅ Complete (all 69 files)
- Setup Scripts: ⏳ Documented, needs implementation
- Documentation: ⏳ Needs update

---

## Next Steps

1. Implement changes in setup.ps1
2. Implement same changes in setup.sh
3. Test with sample project
4. Update README and CUSTOMIZATION.md
5. Final commit
