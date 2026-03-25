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
        pass_count=$((pass_count + 1))
    else
        echo -e "${RED}[FAIL]${NC} $name - $message"
        fail_count=$((fail_count + 1))
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
has_tool=$(jq 'has("tool")' "$CONFIG_FILE")
has_languages=$(jq 'has("languages")' "$CONFIG_FILE")

test_result "Config has 'version' field" "$has_version"
test_result "Config has 'tool' field" "$has_tool"
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
        # Skip if file is null, empty, or not defined
        if [[ -n "$file" && "$file" != "null" ]]; then
            file_path="$lang_dir/$file.md"
            if [[ ! -f "$file_path" ]]; then
                missing_files+=("$lang_key/$file.md")
            fi
        fi
    done < <(jq -r ".languages[\"$lang_key\"].files[]" "$CONFIG_FILE" 2>/dev/null || echo "")

    # Check optional rule files
    while IFS= read -r opt_key; do
        opt_file=$(jq -r ".languages[\"$lang_key\"].optionalRules[\"$opt_key\"].file" "$CONFIG_FILE")
        if [[ -n "$opt_file" && "$opt_file" != "null" ]]; then
            opt_path="$lang_dir/$opt_file.md"
            if [[ ! -f "$opt_path" ]]; then
                missing_files+=("$lang_key/$opt_file.md")
            fi
        fi
    done < <(jq -r ".languages[\"$lang_key\"].optionalRules // {} | keys[]" "$CONFIG_FILE" 2>/dev/null || echo "")
    
    # Check framework files
    while IFS= read -r fw_key; do
        fw_file=$(jq -r ".languages[\"$lang_key\"].frameworks[\"$fw_key\"].file" "$CONFIG_FILE")
        # Skip if file is null, empty, or not defined
        if [[ -n "$fw_file" && "$fw_file" != "null" ]]; then
            fw_path="$RULES_DIR/$lang_key/frameworks/$fw_file.md"
            if [[ ! -f "$fw_path" ]]; then
                missing_files+=("$lang_key/frameworks/$fw_file.md")
            fi
        fi
        
        # Check structure files
        while IFS= read -r struct_key; do
            struct_file=$(jq -r ".languages[\"$lang_key\"].frameworks[\"$fw_key\"].structures[\"$struct_key\"].file" "$CONFIG_FILE")
            # Skip if file is null, empty, or not defined
            if [[ -n "$struct_file" && "$struct_file" != "null" ]]; then
                struct_path="$RULES_DIR/$lang_key/frameworks/structures/$struct_file.md"
                if [[ ! -f "$struct_path" ]]; then
                    missing_files+=("$lang_key/frameworks/structures/$struct_file.md")
                fi
            fi
        done < <(jq -r ".languages[\"$lang_key\"].frameworks[\"$fw_key\"].structures | keys[]" "$CONFIG_FILE" 2>/dev/null || echo "")
    done < <(jq -r ".languages[\"$lang_key\"].frameworks | keys[]" "$CONFIG_FILE" 2>/dev/null || echo "")
done < <(jq -r '.languages | keys[]' "$CONFIG_FILE")

if [[ ${#missing_files[@]} -eq 0 ]]; then
    test_result "All rule files exist" "true"
else
    test_result "All rule files exist" "false" "Missing: ${missing_files[*]}"
fi

# Test 4b: Tool outputFileSource file exists (if configured)
source_file=$(jq -r '.tool.outputFileSource // empty' "$CONFIG_FILE")
if [[ -n "$source_file" ]]; then
    source_path="$RULES_DIR/general/$source_file.md"
    if [[ -f "$source_path" ]]; then
        test_result "Tool outputFileSource file exists" "true"
    else
        test_result "Tool outputFileSource file exists" "false" "Missing: general/$source_file.md"
    fi
else
    test_result "Tool outputFileSource file (not configured)" "true"
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

# Test 7: Setup split scripts and common library
test_result "setup-common.sh exists" "$([[ -f "$SCRIPT_DIR/setup-common.sh" ]] && echo true || echo false)"
if [[ -f "$SCRIPT_DIR/setup-rules.sh" ]]; then
    test_result "setup-rules.sh exists" "true"
    if grep -q 'source.*setup-common' "$SCRIPT_DIR/setup-rules.sh"; then
        test_result "setup-rules.sh sources setup-common.sh" "true"
    else
        test_result "setup-rules.sh sources setup-common.sh" "false" "Missing source setup-common"
    fi
else
    test_result "setup-rules.sh exists" "false" "Missing setup-rules.sh"
fi

if [[ -f "$SCRIPT_DIR/setup-agents.sh" ]]; then
    test_result "setup-agents.sh exists" "true"
    if grep -q 'source.*setup-common' "$SCRIPT_DIR/setup-agents.sh"; then
        test_result "setup-agents.sh sources setup-common.sh" "true"
    else
        test_result "setup-agents.sh sources setup-common.sh" "false" "Missing source setup-common"
    fi
else
    test_result "setup-agents.sh exists" "false" "Missing setup-agents.sh"
fi

# Test 8: State file schema (if state file exists in repo, must be valid JSON; may contain scope, setupType, selectedCustomAgents)
STATE_EXAMPLE="$SCRIPT_DIR/../.ai-iap-state.json"
if [[ -f "$STATE_EXAMPLE" ]]; then
    if jq empty "$STATE_EXAMPLE" 2>/dev/null; then
        test_result "State file is valid JSON" "true"
        # Verify expected keys are readable (backwards compat: scope, setupType, selectedCustomAgents optional)
        jq -e '.version and .selectedLanguages != null' "$STATE_EXAMPLE" >/dev/null 2>&1 && test_result "State file has version and selectedLanguages" "true" || test_result "State file has version and selectedLanguages" "false" "Missing required keys"
    else
        test_result "State file is valid JSON" "false" "Invalid JSON in state file"
    fi
else
    test_result "State file (optional, not in repo)" "true"
fi

# Test 9: Claude agents config (claude-subagents.json optional; if present must be valid JSON)
if [[ -f "$SCRIPT_DIR/claude-subagents.json" ]]; then
    if jq empty "$SCRIPT_DIR/claude-subagents.json" 2>/dev/null; then
        test_result "claude-subagents.json is valid JSON" "true"
    else
        test_result "claude-subagents.json is valid JSON" "false" "Invalid JSON"
    fi
else
    test_result "claude-subagents.json (optional) present" "true"
fi

# Test 10: Persona split files exist (for agent setup: one agent, one specialisation)
for f in persona-core persona-specialist-software persona-specialist-seo persona-specialist-ui-ux persona-specialist-testing persona-specialist-devops; do
    if [[ -f "$SCRIPT_DIR/rules/general/${f}.md" ]]; then
        test_result "Persona split: ${f}.md exists" "true"
    else
        test_result "Persona split: ${f}.md exists" "false" "Missing rules/general/${f}.md"
    fi
done

# Test 11: Custom agents example (if present must be valid JSON with agents array)
if [[ -f "$SCRIPT_DIR/examples/claude-agents.example.json" ]]; then
    if jq empty "$SCRIPT_DIR/examples/claude-agents.example.json" 2>/dev/null; then
        test_result "claude-agents.example.json is valid JSON" "true"
        if jq -e '.agents | type == "array"' "$SCRIPT_DIR/examples/claude-agents.example.json" >/dev/null 2>&1; then
            test_result "claude-agents.example.json has agents array" "true"
        else
            test_result "claude-agents.example.json has agents array" "false" "Missing or invalid agents array"
        fi
    else
        test_result "claude-agents.example.json is valid JSON" "false" "Invalid JSON"
    fi
else
    test_result "claude-agents.example.json (optional)" "true"
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

