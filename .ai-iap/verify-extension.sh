#!/usr/bin/env bash
# Extension System Verification Script (Bash)
# Tests that extension system is properly implemented

set -euo pipefail
IFS=$'\n\t'

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

PASSED=0
FAILED=0
WARNINGS=0

test_item() {
    local name="$1"
    local condition="$2"
    local warning="${3:-false}"
    
    if [[ "$condition" == "true" ]]; then
        printf '%b\n' "${GREEN}[PASS]${NC} $name"
        PASSED=$((PASSED + 1))
    else
        if [[ "$warning" == "true" ]]; then
            printf '%b\n' "${YELLOW}[WARN]${NC} $name"
            WARNINGS=$((WARNINGS + 1))
        else
            printf '%b\n' "${RED}[FAIL]${NC} $name"
            FAILED=$((FAILED + 1))
        fi
    fi
}

printf '\n'
printf '%b\n' "${CYAN}=====================================${NC}"
printf '%b\n' "${CYAN}  Extension System Verification${NC}"
printf '%b\n' "${CYAN}=====================================${NC}"
printf '\n'

# Test 1: Core config exists
test_item "Core config exists" "$([[ -f .ai-iap/config.json ]] && echo true || echo false)"

# Test 2: Example custom config exists
test_item "Example custom config exists" "$([[ -f .ai-iap-custom/config.example.json ]] && echo true || echo false)"

# Test 3: Example custom config is valid JSON
if [[ -f .ai-iap-custom/config.example.json ]]; then
    if jq empty .ai-iap-custom/config.example.json 2>/dev/null; then
        test_item "Example custom config is valid JSON" "true"
    else
        test_item "Example custom config is valid JSON" "false"
    fi
else
    test_item "Example custom config is valid JSON" "false"
fi

# Test 4: Example custom files exist
test_item "Example custom rule exists" "$([[ -f .ai-iap-custom/rules/typescript/company-standards.example.md ]] && echo true || echo false)"
test_item "Example custom process exists" "$([[ -f .ai-iap-custom/processes/typescript/deploy-internal.example.md ]] && echo true || echo false)"

# Test 5: Documentation exists
test_item "CUSTOMIZATION.md exists" "$([[ -f CUSTOMIZATION.md ]] && echo true || echo false)"
test_item "Custom README.md exists" "$([[ -f .ai-iap-custom/README.md ]] && echo true || echo false)"

# Test 6: Setup scripts have merge functions
if [[ -f .ai-iap/setup.sh ]]; then
    if grep -q "merge_custom_config\|CUSTOM_CONFIG" .ai-iap/setup.sh; then
        test_item "Bash setup script has merge function" "true"
    else
        test_item "Bash setup script has merge function" "false"
    fi
else
    test_item "Bash setup script has merge function" "false"
fi

if [[ -f .ai-iap/setup.ps1 ]]; then
    if grep -q "Merge-CustomConfig\|CustomConfig" .ai-iap/setup.ps1; then
        test_item "PowerShell setup script has merge function" "true"
    else
        test_item "PowerShell setup script has merge function" "false"
    fi
else
    test_item "PowerShell setup script has merge function" "false"
fi

# Test 8: Config structure (example file)
if [[ -f .ai-iap-custom/config.example.json ]]; then
    has_languages=$(jq -r '.languages != null' .ai-iap-custom/config.example.json 2>/dev/null || echo "false")
    has_typescript=$(jq -r '.languages.typescript != null' .ai-iap-custom/config.example.json 2>/dev/null || echo "false")
    has_custom_files=$(jq -r '.languages.typescript.customFiles != null' .ai-iap-custom/config.example.json 2>/dev/null || echo "false")
    has_custom_processes=$(jq -r '.languages.typescript.customProcesses != null' .ai-iap-custom/config.example.json 2>/dev/null || echo "false")
    
    test_item "Example config has 'languages' section" "$has_languages"
    test_item "Example config has 'typescript' section" "$has_typescript"
    test_item "TypeScript has 'customFiles'" "$has_custom_files"
    test_item "TypeScript has 'customProcesses'" "$has_custom_processes"
fi

# Test 9: Merge function syntax (basic check)
if [[ -f .ai-iap/setup.sh ]]; then
    if grep -q "MERGED_CONFIG_FILE" .ai-iap/setup.sh && grep -q "WORKING_CONFIG" .ai-iap/setup.sh; then
        test_item "Bash merge variables defined" "true"
    else
        test_item "Bash merge variables defined" "false"
    fi
fi

# Summary
echo ""
echo -e "${CYAN}=====================================${NC}"
echo -e "${CYAN}  Test Summary${NC}"
echo -e "${CYAN}=====================================${NC}"
echo ""
echo -e "Passed:   ${GREEN}$PASSED${NC}"
echo -e "Failed:   $([[ $FAILED -eq 0 ]] && echo -e ${GREEN} || echo -e ${RED})$FAILED${NC}"
echo -e "Warnings: $([[ $WARNINGS -eq 0 ]] && echo -e ${GREEN} || echo -e ${YELLOW})$WARNINGS${NC}"
echo ""

if [[ $FAILED -eq 0 ]]; then
    echo -e "${GREEN}SUCCESS: Extension system is properly implemented!${NC}"
    echo ""
    exit 0
else
    echo -e "${RED}FAILED: $FAILED test(s) failed${NC}"
    echo ""
    exit 1
fi
