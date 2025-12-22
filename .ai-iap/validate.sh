#!/usr/bin/env bash
#
# Validates AI Instructions & Prompts configuration and files
# Usage: ./.ai-iap/validate.sh
#

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly CONFIG_FILE="$SCRIPT_DIR/config.json"
readonly RULES_DIR="$SCRIPT_DIR/rules"

pass_count=0
fail_count=0

# Colors
readonly GREEN='\033[0;32m'
readonly RED='\033[0;31m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

test_result() {
    local name="$1"
    local passed="$2"
    local message="${3:-}"
    
    if [[ "$passed" == "true" ]]; then
        echo -e "${GREEN}[PASS]${NC} $name"
        ((pass_count++))
    else
        echo -e "${RED}[FAIL]${NC} $name - $message"
        ((fail_count++))
    fi
}

echo -e "\n${CYAN}=== AI Instructions & Prompts Validation ===${NC}\n"

# Test 1: Config file exists
if [[ -f "$CONFIG_FILE" ]]; then
    test_result "Config file exists" "true"
else
    test_result "Config file exists" "false" "File not found: $CONFIG_FILE"
    exit 1
fi

# Test 2: Config file is valid JSON
if ! command -v jq &> /dev/null; then
    test_result "Config file is valid JSON" "false" "jq not installed"
    exit 1
fi

jq_output=$(jq empty "$CONFIG_FILE" 2>&1)
jq_exit_code=$?
if [[ $jq_exit_code -eq 0 ]]; then
    test_result "Config file is valid JSON" "true"
else
    test_result "Config file is valid JSON" "false" "Invalid JSON syntax: $jq_output"
    exit 1
fi

# Test 3: Config has required fields
has_version=$(jq 'has("version")' "$CONFIG_FILE")
has_tools=$(jq 'has("tools")' "$CONFIG_FILE")
has_languages=$(jq 'has("languages")' "$CONFIG_FILE")

test_result "Config has 'version' field" "$has_version"
test_result "Config has 'tools' field" "$has_tools"
test_result "Config has 'languages' field" "$has_languages"

# Test 4: All rule files referenced in config exist
missing_files=()
while IFS= read -r lang_key; do
    # Handle 'processes' folder (not under rules/)
    if [[ "$lang_key" == "processes" ]]; then
        lang_dir="$SCRIPT_DIR/$lang_key"
    else
        lang_dir="$RULES_DIR/$lang_key"
    fi
    
    # Check language base files
    while IFS= read -r file; do
        file_path="$lang_dir/$file.md"
        if [[ ! -f "$file_path" ]]; then
            missing_files+=("$lang_key/$file.md")
        fi
    done < <(jq -r ".languages[\"$lang_key\"].files[]" "$CONFIG_FILE" 2>/dev/null || echo "")
    
    # Check framework files
    while IFS= read -r fw_key; do
        fw_file=$(jq -r ".languages[\"$lang_key\"].frameworks[\"$fw_key\"].file" "$CONFIG_FILE")
        fw_path="$RULES_DIR/$lang_key/frameworks/$fw_file.md"
        if [[ ! -f "$fw_path" ]]; then
            missing_files+=("$lang_key/frameworks/$fw_file.md")
        fi
        
        # Check structure files
        while IFS= read -r struct_key; do
            struct_file=$(jq -r ".languages[\"$lang_key\"].frameworks[\"$fw_key\"].structures[\"$struct_key\"].file" "$CONFIG_FILE")
            struct_path="$RULES_DIR/$lang_key/frameworks/structures/$struct_file.md"
            if [[ ! -f "$struct_path" ]]; then
                missing_files+=("$lang_key/frameworks/structures/$struct_file.md")
            fi
        done < <(jq -r ".languages[\"$lang_key\"].frameworks[\"$fw_key\"].structures | keys[]" "$CONFIG_FILE" 2>/dev/null || echo "")
    done < <(jq -r ".languages[\"$lang_key\"].frameworks | keys[]" "$CONFIG_FILE" 2>/dev/null || echo "")
done < <(jq -r '.languages | keys[]' "$CONFIG_FILE")

if [[ ${#missing_files[@]} -eq 0 ]]; then
    test_result "All rule files exist" "true"
else
    test_result "All rule files exist" "false" "Missing: ${missing_files[*]}"
fi

# Test 5: All markdown files have valid structure
invalid_markdown=()
while IFS= read -r md_file; do
    if [[ ! -s "$md_file" ]]; then
        invalid_markdown+=("$(basename "$md_file")")
    elif ! head -1 "$md_file" | grep -q "^#"; then
        invalid_markdown+=("$(basename "$md_file")")
    fi
done < <(find "$RULES_DIR" -name "*.md" -type f)

if [[ ${#invalid_markdown[@]} -eq 0 ]]; then
    test_result "All markdown files start with header" "true"
else
    test_result "All markdown files start with header" "false" "Invalid: ${invalid_markdown[*]}"
fi

# Test 6: Check for frameworks with unresolved dependencies
unresolved_deps=()
while IFS= read -r lang_key; do
    while IFS= read -r fw_key; do
        while IFS= read -r required; do
            if ! jq -e ".languages[\"$lang_key\"].frameworks[\"$required\"]" "$CONFIG_FILE" > /dev/null 2>&1; then
                unresolved_deps+=("$lang_key/$fw_key requires '$required' (not found)")
            fi
        done < <(jq -r ".languages[\"$lang_key\"].frameworks[\"$fw_key\"].requires[]?" "$CONFIG_FILE" 2>/dev/null)
    done < <(jq -r ".languages[\"$lang_key\"].frameworks | keys[]" "$CONFIG_FILE" 2>/dev/null || echo "")
done < <(jq -r '.languages | keys[]' "$CONFIG_FILE")

if [[ ${#unresolved_deps[@]} -eq 0 ]]; then
    test_result "All framework dependencies exist" "true"
else
    test_result "All framework dependencies exist" "false" "Unresolved: ${unresolved_deps[*]}"
fi

# Summary
echo -e "\n${CYAN}=== Summary ===${NC}"
echo -e "${GREEN}Passed: $pass_count${NC}"
echo -e "${RED}Failed: $fail_count${NC}"

if [[ $fail_count -gt 0 ]]; then
    exit 1
fi

echo -e "\n${GREEN}✓ All validation tests passed!${NC}\n"
exit 0

