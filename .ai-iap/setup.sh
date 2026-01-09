#!/usr/bin/env bash
#
# AI Instructions and Prompts Setup Script
# Configures AI coding assistants with standardized instructions
#
# Usage: ./.ai-iap/setup.sh
#

set -euo pipefail

# ============================================================================
# Constants
# ============================================================================

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
readonly CONFIG_FILE="$SCRIPT_DIR/config.json"
readonly CUSTOM_CONFIG_FILE="$PROJECT_ROOT/.ai-iap-custom/config.json"
readonly CUSTOM_RULES_DIR="$PROJECT_ROOT/.ai-iap-custom/rules"
readonly CUSTOM_PROCESSES_DIR="$PROJECT_ROOT/.ai-iap-custom/processes"
readonly MERGED_CONFIG_FILE="/tmp/ai-iap-merged-config-$$.json"
WORKING_CONFIG="$WORKING_CONFIG"
readonly VERSION="1.0.0"

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly DIM='\033[2m'
readonly NC='\033[0m' # No Color

# ============================================================================
# Utility Functions
# ============================================================================

print_header() {
    echo -e "${CYAN}"
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║         AI Instructions and Prompts Setup v${VERSION}            ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1" >&2; }
print_warning() { echo -e "${YELLOW}!${NC} $1"; }
print_info() { echo -e "${BLUE}→${NC} $1"; }

die() {
    print_error "$1"
    exit 1
}

check_dependencies() {
    local missing=()
    
    if ! command -v jq &> /dev/null; then
        missing+=("jq")
    fi
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        print_error "Missing required dependencies: ${missing[*]}"
        echo ""
        echo "Install with:"
        echo "  macOS:  brew install ${missing[*]}"
        echo "  Ubuntu: sudo apt install ${missing[*]}"
        echo "  Arch:   sudo pacman -S ${missing[*]}"
        exit 1
    fi
}

# ============================================================================
# Input Validation
# ============================================================================

validate_selection() {
    local prompt="$1"
    local max_value="$2"
    local allow_skip="${3:-false}"
    local -n result_ref="$4"
    
    while true; do
        read -rp "$prompt: " input
        
        result_ref=()
        local is_valid=true
        
        # Check for 'all'
        if [[ "$input" == "a" || "$input" == "A" ]]; then
            return 0  # Caller should handle 'all' case
        fi
        
        # Check for 'skip' (if allowed)
        if [[ ("$input" == "s" || "$input" == "S") && "$allow_skip" == "true" ]]; then
            return 0  # Return empty array for skip
        fi
        
        # Check for empty input
        if [[ -z "$input" ]]; then
            echo ""
            print_error "No selection made."
            local skip_msg=""
            [[ "$allow_skip" == "true" ]] && skip_msg=", 's' to skip,"
            echo -e "${YELLOW}Please enter at least one number$skip_msg or 'a' for all.${NC}"
            echo ""
            continue
        fi
        
        # Validate each number
        for num in $input; do
            # Check if it's a number
            if ! [[ "$num" =~ ^[0-9]+$ ]]; then
                echo ""
                print_error "Invalid input: '$num'"
                local skip_msg=""
                [[ "$allow_skip" == "true" ]] && skip_msg=", 's' to skip,"
                echo -e "${YELLOW}Please enter numbers only (e.g., 1 2 3)$skip_msg or 'a' for all.${NC}"
                echo ""
                is_valid=false
                break
            fi
            
            # Check if number is in range
            if [[ $num -lt 1 || $num -gt $max_value ]]; then
                echo ""
                print_error "Invalid choice: $num"
                echo -e "${YELLOW}Please enter a number between 1 and $max_value.${NC}"
                echo ""
                is_valid=false
                break
            fi
            
            result_ref+=("$num")
        done
        
        # Break if valid and has selections
        if [[ "$is_valid" == "true" && ${#result_ref[@]} -gt 0 ]]; then
            return 0
        elif [[ "$is_valid" == "true" && ${#result_ref[@]} -eq 0 ]]; then
            echo ""
            print_error "No valid items selected."
            echo -e "${YELLOW}Please enter at least one valid number.${NC}"
            echo ""
        fi
    done
}

# ============================================================================
# Configuration Loading
# ============================================================================

load_config() {
    if [[ ! -f "$WORKING_CONFIG" ]]; then
        print_error "Config file not found: $WORKING_CONFIG"
        echo ""
        echo -e "${YELLOW}This usually means you're running the script from the wrong directory.${NC}"
        echo ""
        echo -e "${CYAN}Solution:${NC}"
        echo -e "  ${NC}1. Navigate to your project root directory${NC}"
        echo -e "  ${NC}2. Run: cd \"$PROJECT_ROOT\"${NC}"
        echo -e "  ${NC}3. Then run: ./.ai-iap/setup.sh${NC}"
        echo ""
        exit 1
    fi
    
    # Validate JSON
    if ! jq empty "$WORKING_CONFIG" 2>/dev/null; then
        print_error "Failed to parse config file: $WORKING_CONFIG"
        echo ""
        echo -e "${YELLOW}The config.json file exists but contains invalid JSON.${NC}"
        echo ""
        echo -e "${CYAN}Solution:${NC}"
        echo -e "  ${NC}1. Validate JSON syntax: jq empty \"$WORKING_CONFIG\"${NC}"
        echo -e "  ${NC}2. Check for common issues:${NC}"
        echo -e "     ${NC}- Missing or extra commas${NC}"
        echo -e "     ${NC}- Unmatched brackets/braces${NC}"
        echo -e "     ${NC}- Missing quotes around strings${NC}"
        echo -e "  ${NC}3. Or restore from git: git checkout $CONFIG_FILE${NC}"
        echo ""
        exit 1
    fi
    
    # Check for custom config and merge if exists
    merge_custom_config
}

merge_custom_config() {
    # Check if custom config exists
    if [[ ! -f "$CUSTOM_CONFIG_FILE" ]]; then
        print_info "No custom config found (optional)"
        return 0
    fi
    
    print_info "Found custom config: .ai-iap-custom/config.json"
    
    # Validate custom config JSON
    if ! jq empty "$CUSTOM_CONFIG_FILE" 2>/dev/null; then
        print_error "Custom config file contains invalid JSON"
        echo ""
        echo -e "${YELLOW}Please fix .ai-iap-custom/config.json${NC}"
        echo ""
        exit 1
    fi
    
    # Merge custom config into core config
    # For each language in custom config, merge customFiles, customProcesses, customFrameworks
    jq -s '
        def deep_merge(a; b):
            a + b |
            to_entries |
            group_by(.key) |
            map({
                key: .[0].key,
                value: (
                    if (.[0].value | type) == "object" and (.[1].value | type) == "object"
                    then deep_merge(.[0].value; .[1].value)
                    else .[1].value
                    end
                )
            }) |
            from_entries;
        
        deep_merge(.[0]; .[1])
    ' "$CONFIG_FILE" "$CUSTOM_CONFIG_FILE" > "$MERGED_CONFIG_FILE"
    
    print_success "Merged custom configuration"
    
    # Update WORKING_CONFIG to point to merged config
    WORKING_CONFIG="$MERGED_CONFIG_FILE"
}

cleanup() {
    # Clean up temporary merged config file
    if [[ -f "$MERGED_CONFIG_FILE" ]]; then
        rm -f "$MERGED_CONFIG_FILE"
    fi
}

trap cleanup EXIT

get_tools() {
    jq -r '.tools | keys[]' "$WORKING_CONFIG"
}

get_tool_name() {
    jq -r ".tools[\"$1\"].name" "$WORKING_CONFIG"
}

get_languages() {
    jq -r '.languages | keys[]' "$WORKING_CONFIG"
}

get_language_name() {
    jq -r ".languages[\"$1\"].name" "$WORKING_CONFIG"
}

get_language_files() {
    jq -r ".languages[\"$1\"].files[]" "$WORKING_CONFIG"
}

get_language_custom_files() {
    jq -r ".languages[\"$1\"].customFiles[]? // empty" "$WORKING_CONFIG" 2>/dev/null || true
}

get_language_globs() {
    jq -r ".languages[\"$1\"].globs" "$WORKING_CONFIG"
}

get_language_always_apply() {
    jq -r ".languages[\"$1\"].alwaysApply" "$WORKING_CONFIG"
}

get_language_description() {
    jq -r ".languages[\"$1\"].description" "$WORKING_CONFIG"
}

get_language_frameworks() {
    jq -r ".languages[\"$1\"].frameworks // empty | keys[]" "$WORKING_CONFIG" 2>/dev/null || true
}

get_language_custom_frameworks() {
    jq -r ".languages[\"$1\"].customFrameworks // empty | keys[]" "$WORKING_CONFIG" 2>/dev/null || true
}

get_language_processes() {
    jq -r ".languages[\"$1\"].processes // empty | keys[]" "$WORKING_CONFIG" 2>/dev/null || true
}

get_language_custom_processes() {
    jq -r ".languages[\"$1\"].customProcesses // empty | keys[]" "$WORKING_CONFIG" 2>/dev/null || true
}

get_framework_name() {
    jq -r ".languages[\"$1\"].frameworks[\"$2\"].name" "$WORKING_CONFIG"
}

get_custom_framework_name() {
    jq -r ".languages[\"$1\"].customFrameworks[\"$2\"].name" "$WORKING_CONFIG"
}

get_process_name() {
    jq -r ".languages[\"$1\"].processes[\"$2\"].name" "$WORKING_CONFIG"
}

get_process_description() {
    jq -r ".languages[\"$1\"].processes[\"$2\"].description" "$WORKING_CONFIG"
}

get_process_file() {
    jq -r ".languages[\"$1\"].processes[\"$2\"].file" "$WORKING_CONFIG"
}

get_process_load_into_ai() {
    jq -r ".languages[\"$1\"].processes[\"$2\"].loadIntoAI // true" "$WORKING_CONFIG"
}

get_framework_description() {
    jq -r ".languages[\"$1\"].frameworks[\"$2\"].description" "$WORKING_CONFIG"
}

get_framework_file() {
    jq -r ".languages[\"$1\"].frameworks[\"$2\"].file" "$WORKING_CONFIG"
}

get_framework_category() {
    jq -r ".languages[\"$1\"].frameworks[\"$2\"].category // \"Other\"" "$WORKING_CONFIG"
}

get_framework_structures() {
    jq -r ".languages[\"$1\"].frameworks[\"$2\"].structures // empty | keys[]" "$WORKING_CONFIG" 2>/dev/null || true
}

get_structure_name() {
    jq -r ".languages[\"$1\"].frameworks[\"$2\"].structures[\"$3\"].name" "$WORKING_CONFIG"
}

get_structure_description() {
    jq -r ".languages[\"$1\"].frameworks[\"$2\"].structures[\"$3\"].description" "$WORKING_CONFIG"
}

get_structure_file() {
    jq -r ".languages[\"$1\"].frameworks[\"$2\"].structures[\"$3\"].file" "$WORKING_CONFIG"
}

get_documentation_keys() {
    jq -r ".languages.general.documentation // empty | keys[]" "$WORKING_CONFIG" 2>/dev/null || true
}

get_documentation_name() {
    jq -r ".languages.general.documentation[\"$1\"].name" "$WORKING_CONFIG"
}

get_documentation_description() {
    jq -r ".languages.general.documentation[\"$1\"].description" "$WORKING_CONFIG"
}

get_documentation_file() {
    jq -r ".languages.general.documentation[\"$1\"].file" "$WORKING_CONFIG"
}

get_documentation_recommended() {
    jq -r ".languages.general.documentation[\"$1\"].recommended // false" "$WORKING_CONFIG"
}

get_documentation_applicable_to() {
    jq -r ".languages.general.documentation[\"$1\"].applicableTo[]" "$WORKING_CONFIG" 2>/dev/null || echo "all"
}

# ============================================================================
# Selection UI
# ============================================================================

select_tools_simple() {
    local tools=()
    local tool_keys=()
    
    while IFS= read -r key; do
        tool_keys+=("$key")
        tools+=("$(get_tool_name "$key")")
    done < <(get_tools)
    
    echo -e "${BOLD}Select AI tools to configure:${NC}"
    echo ""
    
    for ((i=0; i<${#tool_keys[@]}; i++)); do
        local suffix=""
        local recommended
        recommended=$(jq -r ".tools[\"${tool_keys[$i]}\"].recommended // false" "$WORKING_CONFIG")
        if [[ "$recommended" == "true" ]]; then
            suffix=" *"
        fi
        echo "  $((i+1)). ${tools[$i]}$suffix"
    done
    echo ""
    echo -e "  ${DIM}* = recommended${NC}"
    echo "  a. All tools"
    echo ""
    
    SELECTED_TOOLS=()
    
    while true; do
        read -rp "Enter choices (e.g., 1 3 or 'a' for all): " input
        
        if [[ "$input" == "a" || "$input" == "A" ]]; then
            SELECTED_TOOLS=("${tool_keys[@]}")
            break
        elif [[ -z "$input" ]]; then
            echo ""
            print_error "No tools selected."
            echo -e "${YELLOW}Please enter at least one tool number (e.g., 1) or 'a' for all.${NC}"
            echo ""
            continue
        fi
        
        local is_valid=true
        local temp_tools=()
        
        for num in $input; do
            if ! [[ "$num" =~ ^[0-9]+$ ]]; then
                echo ""
                print_error "Invalid input: '$num'"
                echo -e "${YELLOW}Please enter numbers only (e.g., 1 2 3) or 'a' for all.${NC}"
                echo ""
                is_valid=false
                break
            fi
            
            local idx=$((num - 1))
            if [[ $idx -lt 0 || $idx -ge ${#tool_keys[@]} ]]; then
                echo ""
                print_error "Invalid choice: $num"
                echo -e "${YELLOW}Please enter a number between 1 and ${#tool_keys[@]}.${NC}"
                echo ""
                is_valid=false
                break
            fi
            temp_tools+=("${tool_keys[$idx]}")
        done
        
        if [[ "$is_valid" == "true" && ${#temp_tools[@]} -gt 0 ]]; then
            SELECTED_TOOLS=("${temp_tools[@]}")
            break
        elif [[ "$is_valid" == "true" ]]; then
            echo ""
            print_error "No valid tools selected."
            echo -e "${YELLOW}Please enter at least one valid number.${NC}"
            echo ""
        fi
    done
}

select_languages_simple() {
    local languages=()
    local lang_keys=()
    local always_apply_langs=()
    
    while IFS= read -r key; do
        lang_keys+=("$key")
        languages+=("$(get_language_name "$key")")
        # Track languages with alwaysApply: true
        local always_apply
        always_apply=$(jq -r ".languages[\"$key\"].alwaysApply // false" "$WORKING_CONFIG")
        if [[ "$always_apply" == "true" ]]; then
            always_apply_langs+=("$key")
        fi
    done < <(get_languages)
    
    echo ""
    echo -e "${BOLD}Select language instructions to include:${NC}"
    echo -e "${DIM}(General rules are always included automatically)${NC}"
    echo ""
    
    for ((i=0; i<${#lang_keys[@]}; i++)); do
        local suffix=""
        local always_apply
        always_apply=$(jq -r ".languages[\"${lang_keys[$i]}\"].alwaysApply // false" "$WORKING_CONFIG")
        if [[ "$always_apply" == "true" ]]; then
            suffix=" (always included)"
        fi
        echo "  $((i+1)). ${languages[$i]}$suffix"
    done
    echo "  a. All languages"
    echo ""
    
    read -rp "Enter choices (e.g., 1 2 4 or 'a' for all): " input
    
    SELECTED_LANGUAGES=()
    
    if [[ "$input" == "a" || "$input" == "A" ]]; then
        SELECTED_LANGUAGES=("${lang_keys[@]}")
    else
        for num in $input; do
            local idx=$((num - 1))
            if [[ $idx -ge 0 && $idx -lt ${#lang_keys[@]} ]]; then
                SELECTED_LANGUAGES+=("${lang_keys[$idx]}")
            fi
        done
    fi
    
    # Always include languages with alwaysApply: true
    for always_lang in "${always_apply_langs[@]}"; do
        local found=false
        for sel in "${SELECTED_LANGUAGES[@]}"; do
            if [[ "$sel" == "$always_lang" ]]; then
                found=true
                break
            fi
        done
        if [[ "$found" == "false" ]]; then
            SELECTED_LANGUAGES=("$always_lang" "${SELECTED_LANGUAGES[@]}")
        fi
    done
}

# Array to store selected documentation files
SELECTED_DOCUMENTATION=()

select_documentation() {
    local doc_keys=()
    local doc_names=()
    local doc_descs=()
    local doc_recs=()
    
    while IFS= read -r key; do
        doc_keys+=("$key")
        doc_names+=("$(get_documentation_name "$key")")
        doc_descs+=("$(get_documentation_description "$key")")
        doc_recs+=("$(get_documentation_recommended "$key")")
    done < <(get_documentation_keys)
    
    if [[ ${#doc_keys[@]} -eq 0 ]]; then
        return
    fi
    
    # Determine project type based on selected languages
    local has_backend=false
    local has_frontend_only=false
    
    for lang in "${SELECTED_LANGUAGES[@]}"; do
        case "$lang" in
            dart)
                has_frontend_only=true
                ;;
            typescript|python|dotnet|java|php|kotlin|swift)
                # These could be backend or fullstack
                has_backend=true
                ;;
        esac
    done
    
    echo ""
    echo -e "${BOLD}Select documentation standards to include:${NC}"
    echo -e "${DIM}(Choose based on your project type)${NC}"
    echo ""
    
    for ((i=0; i<${#doc_keys[@]}; i++)); do
        local suffix=""
        local key="${doc_keys[$i]}"
        
        # Check if recommended
        if [[ "${doc_recs[$i]}" == "true" ]]; then
            suffix=" ⭐"
        fi
        
        # Check applicability
        local applicable_to
        applicable_to=$(get_documentation_applicable_to "$key")
        
        # Add applicability hint
        if [[ "$applicable_to" == "backend" ]] || [[ "$applicable_to" == "fullstack" ]]; then
            suffix="$suffix ${DIM}(backend/fullstack)${NC}"
        fi
        
        echo -e "  $((i+1)). ${doc_names[$i]}$suffix"
        echo -e "      ${DIM}${doc_descs[$i]}${NC}"
    done
    echo ""
    echo -e "  ${DIM}⭐ = recommended${NC}"
    echo "  a. All documentation"
    echo "  s. Skip (no documentation standards)"
    echo ""
    
    # Provide smart default suggestion
    if [[ "$has_frontend_only" == "true" && "$has_backend" == "false" ]]; then
        echo -e "${DIM}Suggestion for frontend-only project: 1 2 (code + project)${NC}"
    elif [[ "$has_backend" == "true" ]]; then
        echo -e "${DIM}Suggestion for backend/fullstack project: a (all)${NC}"
    fi
    
    read -rp "Enter choices (e.g., 1 2 or 'a' for all, 's' to skip): " input
    
    SELECTED_DOCUMENTATION=()
    
    if [[ "$input" == "s" || "$input" == "S" ]]; then
        return
    elif [[ "$input" == "a" || "$input" == "A" ]]; then
        for key in "${doc_keys[@]}"; do
            SELECTED_DOCUMENTATION+=("$(get_documentation_file "$key")")
        done
    else
        for num in $input; do
            local idx=$((num - 1))
            if [[ $idx -ge 0 && $idx -lt ${#doc_keys[@]} ]]; then
                SELECTED_DOCUMENTATION+=("$(get_documentation_file "${doc_keys[$idx]}")")
            fi
        done
    fi
}

# Associative array to store selected frameworks per language
declare -A SELECTED_FRAMEWORKS

select_frameworks() {
    SELECTED_FRAMEWORKS=()
    
    for lang in "${SELECTED_LANGUAGES[@]}"; do
        local fw_keys=()
        local fw_names=()
        local fw_descs=()
        local fw_cats=()
        local fw_recs=()
        local lang_name
        lang_name=$(get_language_name "$lang")
        
        # Get frameworks for this language
        while IFS= read -r key; do
            [[ -z "$key" ]] && continue
            fw_keys+=("$key")
            fw_names+=("$(get_framework_name "$lang" "$key")")
            fw_descs+=("$(get_framework_description "$lang" "$key")")
            fw_cats+=("$(get_framework_category "$lang" "$key")")
            fw_recs+=("$(jq -r ".languages[\"$lang\"].frameworks[\"$key\"].recommended // false" "$WORKING_CONFIG")")
        done < <(get_language_frameworks "$lang")
        
        # Skip if no frameworks
        [[ ${#fw_keys[@]} -eq 0 ]] && continue
        
        echo ""
        echo -e "${BOLD}Select frameworks for $lang_name:${NC}"
        echo -e "${DIM}(You can combine multiple - e.g., Web Framework + ORM)${NC}"
        echo ""
        
        # Get unique categories and sort them
        local categories=()
        for cat in "${fw_cats[@]}"; do
            local found=0
            for existing in "${categories[@]}"; do
                [[ "$existing" == "$cat" ]] && found=1 && break
            done
            [[ $found -eq 0 ]] && categories+=("$cat")
        done
        IFS=$'\n' categories=($(sort <<<"${categories[*]}")); unset IFS
        
        # Display frameworks grouped by category
        for cat in "${categories[@]}"; do
            echo -e "  ${CYAN}[$cat]${NC}"
            for ((i=0; i<${#fw_keys[@]}; i++)); do
                if [[ "${fw_cats[$i]}" == "$cat" ]]; then
                    local suffix=""
                    [[ "${fw_recs[$i]}" == "true" ]] && suffix=" *"
                    echo "    $((i+1)). ${fw_names[$i]}$suffix - ${fw_descs[$i]}"
                fi
            done
        done
        echo ""
        echo -e "  ${DIM}* = recommended${NC}"
        echo "  s. Skip (no frameworks)"
        echo "  a. All frameworks"
        echo ""
        
        read -rp "Enter choices (e.g., 1 3 5 or 'a' for all, 's' to skip): " input
        
        local selected_fw=()
        
        if [[ "$input" == "s" || "$input" == "S" ]]; then
            # Skip - no frameworks for this language
            continue
        elif [[ "$input" == "a" || "$input" == "A" ]]; then
            selected_fw=("${fw_keys[@]}")
        else
            for num in $input; do
                local idx=$((num - 1))
                if [[ $idx -ge 0 && $idx -lt ${#fw_keys[@]} ]]; then
                    selected_fw+=("${fw_keys[$idx]}")
                fi
            done
        fi
        
        if [[ ${#selected_fw[@]} -gt 0 ]]; then
            SELECTED_FRAMEWORKS[$lang]="${selected_fw[*]}"
        fi
    done
}

# Associative array to store selected structures
declare -A SELECTED_STRUCTURES

# Associative array to store selected processes
declare -A SELECTED_PROCESSES

select_processes() {
    SELECTED_PROCESSES=()
    
    for lang in "${SELECTED_LANGUAGES[@]}"; do
        local proc_keys=()
        local proc_names=()
        local proc_descs=()
        local proc_files=()
        local lang_name
        lang_name=$(get_language_name "$lang")
        
        # Get processes for this language
        while IFS= read -r key; do
            [[ -z "$key" ]] && continue
            proc_keys+=("$key")
            proc_names+=("$(get_process_name "$lang" "$key")")
            
            # Add type indicator for permanent vs on-demand
            local load_into_ai
            load_into_ai=$(get_process_load_into_ai "$lang" "$key")
            local type_label
            if [[ "$load_into_ai" == "true" ]]; then
                type_label="[permanent]"
            else
                type_label="[on-demand]"
            fi
            
            proc_descs+=("$(get_process_description "$lang" "$key") $type_label")
            proc_files+=("$(get_process_file "$lang" "$key")")
        done < <(get_language_processes "$lang")
        
        # Skip if no processes
        [[ ${#proc_keys[@]} -eq 0 ]] && continue
        
        echo ""
        echo -e "${BOLD}Select processes for $lang_name:${NC}"
        echo -e "${DIM}(Workflow guides for establishing infrastructure)${NC}"
        echo ""
        echo -e "${YELLOW}Process Types:${NC}"
        echo -e "${CYAN}  [permanent] - Loaded into AI permanently (recurring tasks)${NC}"
        echo -e "${DIM}  [on-demand] - Copy prompt when needed (one-time setups)${NC}"
        echo ""
        
        for ((i=0; i<${#proc_keys[@]}; i++)); do
            echo "  $((i+1)). ${proc_names[$i]} - ${proc_descs[$i]}"
        done
        echo ""
        echo "  s. Skip (no processes)"
        echo "  a. All processes"
        echo ""
        
        read -rp "Enter choices (e.g., 1 2 or 'a' for all, 's' to skip): " input
        
        local selected_proc=()
        
        if [[ "$input" == "s" || "$input" == "S" ]]; then
            # Skip - no processes for this language
            continue
        elif [[ "$input" == "a" || "$input" == "A" ]]; then
            selected_proc=("${proc_keys[@]}")
        else
            for num in $input; do
                local idx=$((num - 1))
                if [[ $idx -ge 0 && $idx -lt ${#proc_keys[@]} ]]; then
                    selected_proc+=("${proc_keys[$idx]}")
                fi
            done
        fi
        
        if [[ ${#selected_proc[@]} -gt 0 ]]; then
            SELECTED_PROCESSES[$lang]="${selected_proc[*]}"
        fi
    done
}

select_structures() {
    SELECTED_STRUCTURES=()
    
    for lang in "${SELECTED_LANGUAGES[@]}"; do
        [[ -z "${SELECTED_FRAMEWORKS[$lang]:-}" ]] && continue
        
        for fw in ${SELECTED_FRAMEWORKS[$lang]}; do
            local struct_keys=()
            local struct_names=()
            local struct_descs=()
            local struct_files=()
            local struct_recs=()
            local fw_name
            fw_name=$(get_framework_name "$lang" "$fw")
            
            # Get structures for this framework
            while IFS= read -r key; do
                [[ -z "$key" ]] && continue
                struct_keys+=("$key")
                struct_names+=("$(get_structure_name "$lang" "$fw" "$key")")
                struct_descs+=("$(get_structure_description "$lang" "$fw" "$key")")
                struct_files+=("$(get_structure_file "$lang" "$fw" "$key")")
                struct_recs+=("$(jq -r ".languages[\"$lang\"].frameworks[\"$fw\"].structures[\"$key\"].recommended // false" "$WORKING_CONFIG")")
            done < <(get_framework_structures "$lang" "$fw")
            
            # Skip if no structures
            [[ ${#struct_keys[@]} -eq 0 ]] && continue
            
            echo ""
            echo -e "${BOLD}Select structure for $fw_name:${NC}"
            echo ""
            
            for ((i=0; i<${#struct_keys[@]}; i++)); do
                local suffix=""
                [[ "${struct_recs[$i]}" == "true" ]] && suffix=" *"
                echo "  $((i+1)). ${struct_names[$i]}$suffix - ${struct_descs[$i]}"
            done
            echo ""
            echo -e "  ${DIM}* = recommended${NC}"
            echo "  s. Skip (use default patterns only)"
            echo ""
            
            read -rp "Enter choice (1-${#struct_keys[@]} or 's' to skip): " input
            
            if [[ "$input" != "s" && "$input" != "S" ]]; then
                local idx=$((input - 1))
                if [[ $idx -ge 0 && $idx -lt ${#struct_keys[@]} ]]; then
                    SELECTED_STRUCTURES["$lang-$fw"]="${struct_files[$idx]}"
                fi
            fi
        done
    done
}

# ============================================================================
# File Generation
# ============================================================================

read_instruction_file() {
    local lang="$1"
    local file="$2"
    local is_framework="${3:-false}"
    local is_structure="${4:-false}"
    local is_process="${5:-false}"
    
    if [[ "$is_process" == "true" ]]; then
        local filepath="$SCRIPT_DIR/processes/$lang/$file.md"
    elif [[ "$is_structure" == "true" ]]; then
        local filepath="$SCRIPT_DIR/rules/$lang/frameworks/structures/$file.md"
    elif [[ "$is_framework" == "true" ]]; then
        local filepath="$SCRIPT_DIR/rules/$lang/frameworks/$file.md"
    else
        local filepath="$SCRIPT_DIR/rules/$lang/$file.md"
    fi
    
    if [[ -f "$filepath" ]]; then
        cat "$filepath"
    else
        print_warning "File not found: $filepath"
        return 1
    fi
}

generate_cursor_frontmatter() {
    local lang="$1"
    local file="$2"
    local is_framework="${3:-false}"
    local globs description always_apply
    
    globs=$(get_language_globs "$lang")
    always_apply=$(get_language_always_apply "$lang")
    
    if [[ "$is_framework" == "true" ]]; then
        local fw_name lang_name
        fw_name=$(get_framework_name "$lang" "$file")
        lang_name=$(get_language_name "$lang")
        description="$lang_name - $fw_name"
    else
        description="$(get_language_description "$lang") - $file"
    fi
    
    echo "---"
    echo "alwaysApply: $always_apply"
    echo "description: $description"
    echo "globs: $globs"
    echo "---"
    echo ""
}

generate_cursor() {
    local output_dir="$PROJECT_ROOT/.cursor/rules"
    
    print_info "Generating Cursor rules..."
    
    for lang in "${SELECTED_LANGUAGES[@]}"; do
        local lang_dir="$output_dir/$lang"
        mkdir -p "$lang_dir"
        
        # Generate base language files
        while IFS= read -r file; do
            local output_file="$lang_dir/$file.mdc"
            local content
            
            content=$(read_instruction_file "$lang" "$file") || continue
            
            # Create parent directory if it doesn't exist (for nested files)
            mkdir -p "$(dirname "$output_file")"
            
            {
                generate_cursor_frontmatter "$lang" "$file" "false"
                echo "$content"
            } > "$output_file"
            
            # Show relative path
            local relative_path="${output_file#"$PROJECT_ROOT/"}"
            print_success "Created $relative_path"
        done < <(get_language_files "$lang")
        
        # Generate selected documentation files (only for general language)
        if [[ "$lang" == "general" && ${#SELECTED_DOCUMENTATION[@]} -gt 0 ]]; then
            for doc_file in "${SELECTED_DOCUMENTATION[@]}"; do
                local output_file="$lang_dir/$doc_file.mdc"
                local content
                
                content=$(read_instruction_file "$lang" "$doc_file") || continue
                
                # Create parent directory if it doesn't exist (for nested files)
                mkdir -p "$(dirname "$output_file")"
                
                {
                    generate_cursor_frontmatter "$lang" "$doc_file" "false"
                    echo "$content"
                } > "$output_file"
                
                # Show relative path
                local relative_path="${output_file#"$PROJECT_ROOT/"}"
                print_success "Created $relative_path"
            done
        fi
        
        # Generate framework files for this language
        if [[ -n "${SELECTED_FRAMEWORKS[$lang]:-}" ]]; then
            for fw in ${SELECTED_FRAMEWORKS[$lang]}; do
                local fw_file output_file content
                fw_file=$(get_framework_file "$lang" "$fw")
                output_file="$lang_dir/$fw_file.mdc"
                
                content=$(read_instruction_file "$lang" "$fw_file" "true") || continue
                
                # Create parent directory if it doesn't exist (for nested files)
                mkdir -p "$(dirname "$output_file")"
                
                {
                    generate_cursor_frontmatter "$lang" "$fw" "true"
                    echo "$content"
                } > "$output_file"
                
                local relative_path="${output_file#"$PROJECT_ROOT/"}"
                print_success "Created $relative_path"
                
                # Generate structure file if selected
                local struct_key="$lang-$fw"
                if [[ -n "${SELECTED_STRUCTURES[$struct_key]:-}" ]]; then
                    local struct_file="${SELECTED_STRUCTURES[$struct_key]}"
                    local struct_output="$lang_dir/$struct_file.mdc"
                    local struct_content
                    
                    struct_content=$(read_instruction_file "$lang" "$struct_file" "false" "true") || continue
                    
                    # Create parent directory if it doesn't exist (for nested files)
                    mkdir -p "$(dirname "$struct_output")"
                    
                    {
                        generate_cursor_frontmatter "$lang" "$fw" "true"
                        echo "$struct_content"
                    } > "$struct_output"
                    
                    local relative_path="${struct_output#"$PROJECT_ROOT/"}"
                    print_success "Created $relative_path"
                fi
            done
        fi
        
        # Generate process files for this language
        if [[ -n "${SELECTED_PROCESSES[$lang]:-}" ]]; then
            for proc in ${SELECTED_PROCESSES[$lang]}; do
                local proc_file output_file content load_into_ai
                proc_file=$(get_process_file "$lang" "$proc")
                load_into_ai=$(get_process_load_into_ai "$lang" "$proc")
                
                # Skip on-demand processes (user copies prompt when needed)
                if [[ "$load_into_ai" == "false" ]]; then
                    print_info "Skipped on-demand process: $proc (copy prompt from .ai-iap/processes/ondemand/$lang/$proc_file.md when needed)"
                    continue
                fi
                
                output_file="$lang_dir/$proc_file.mdc"
                
                content=$(read_instruction_file "$lang" "$proc_file" "false" "false" "true") || continue
                
                # Create parent directory if it doesn't exist (for nested files)
                mkdir -p "$(dirname "$output_file")"
                
                {
                    generate_cursor_frontmatter "$lang" "$proc" "false"
                    echo "$content"
                } > "$output_file"
                
                local relative_path="${output_file#"$PROJECT_ROOT/"}"
                print_success "Created $relative_path"
            done
        fi
    done
}

get_skill_description() {
    local lang="$1"
    local file="$2"
    local framework="$3"
    local structure="$4"
    local process="$5"
    
    # Generate specific, action-oriented descriptions per Claude's documentation
    # Format: What it covers. Use when [concrete triggers/actions].
    
    if [[ -n "$process" ]]; then
        local proc_name
        proc_name=$(get_process_name "$lang" "$process")
        
        # Generate process-specific descriptions
        case "$process" in
            *database-migrations*) echo "Database schema migration implementation using ORMs and version control. Use when setting up migrations, creating schema changes, or working with database versioning." ;;
            *test-implementation*) echo "Testing framework setup and test writing patterns for $lang. Use when implementing unit tests, integration tests, or setting up test infrastructure." ;;
            *ci-cd*) echo "CI/CD pipeline configuration with GitHub Actions for $lang projects. Use when setting up workflows, configuring builds, or implementing deployment automation." ;;
            *docker*) echo "Docker containerization for $lang applications. Use when creating Dockerfiles, docker-compose configurations, or containerizing applications." ;;
            *logging*) echo "Structured logging and observability implementation. Use when adding logging, setting up monitoring, or implementing error tracking." ;;
            *security-scanning*) echo "Security scanning and vulnerability detection. Use when implementing SAST/DAST, dependency scanning, or security auditing." ;;
            *auth*) echo "Authentication and authorization implementation. Use when adding JWT, OAuth, session management, or RBAC systems." ;;
            *api-doc*) echo "API documentation with OpenAPI/Swagger. Use when documenting REST endpoints, generating API specs, or creating interactive API documentation." ;;
            *) echo "$proc_name implementation for $lang. Use when working on ${proc_name,,} tasks or setup." ;;
        esac
    elif [[ -n "$structure" ]]; then
        local struct_name
        struct_name=$(basename "$structure" | sed 's/-/ /g')
        
        # Generate structure-specific descriptions
        case "$structure" in
            *feature*) echo "Feature-First architecture pattern for $framework. Use when organizing code by features, setting up new features, or discussing project structure with feature modules." ;;
            *layer*) echo "Layer-First (N-tier) architecture for $framework. Use when organizing by technical layers, separating presentation/business/data layers, or implementing layered architecture." ;;
            *clean*) echo "Clean Architecture implementation for $framework. Use when setting up domain-driven design, organizing by use cases, or implementing clean architecture principles." ;;
            *mvvm*) echo "MVVM (Model-View-ViewModel) pattern for $framework. Use when creating ViewModels, binding views, or implementing MVVM architecture." ;;
            *mvi*) echo "MVI (Model-View-Intent) pattern for $framework. Use when implementing unidirectional data flow, handling user intents, or setting up state management." ;;
            *vertical*) echo "Vertical Slice architecture for $framework. Use when organizing by features as vertical slices, minimizing coupling between features, or implementing vertical architecture." ;;
            *modular*) echo "Modular Monolith architecture for $framework. Use when creating independent modules, setting up module boundaries, or refactoring to modular structure." ;;
            *) echo "$struct_name architecture for $framework. Use when setting up project structure, organizing files, or discussing architecture patterns." ;;
        esac
    elif [[ -n "$framework" ]]; then
        local fw_name
        fw_name=$(get_framework_name "$lang" "$framework")
        
        # Generate framework-specific descriptions
        case "$framework" in
            react) echo "React framework development. Use when working with React components, hooks, JSX, state management, or React-specific patterns." ;;
            vue) echo "Vue.js framework development. Use when working with Vue components, Composition API, Vue directives, or Vue-specific patterns." ;;
            angular) echo "Angular framework development. Use when working with Angular components, services, decorators, RxJS, or Angular-specific patterns." ;;
            next|nextjs) echo "Next.js framework for React. Use when working with server-side rendering, API routes, app directory, or Next.js-specific features." ;;
            nuxt|nuxtjs) echo "Nuxt.js framework for Vue. Use when working with SSR, auto-routing, Nuxt modules, or Nuxt-specific features." ;;
            nest|nestjs) echo "NestJS framework for Node.js. Use when working with NestJS decorators, modules, providers, or building backend APIs with NestJS." ;;
            express|expressjs) echo "Express.js framework for Node.js. Use when building REST APIs, middleware, routing, or Express-based backends." ;;
            django) echo "Django web framework for Python. Use when working with Django models, views, ORM, admin, or Django-specific patterns." ;;
            fastapi) echo "FastAPI framework for Python. Use when building async APIs, Pydantic models, auto-generated docs, or FastAPI-specific features." ;;
            flask) echo "Flask framework for Python. Use when building lightweight APIs, Flask routes, blueprints, or Flask-based applications." ;;
            spring*) echo "Spring Boot framework for Java. Use when working with Spring beans, annotations, JPA, REST controllers, or Spring-specific patterns." ;;
            laravel) echo "Laravel framework for PHP. Use when working with Eloquent ORM, Blade templates, artisan commands, or Laravel-specific features." ;;
            flutter) echo "Flutter framework for Dart. Use when creating Flutter widgets, state management, animations, or cross-platform mobile apps." ;;
            swiftui) echo "SwiftUI framework for iOS. Use when building declarative UI, SwiftUI views, property wrappers, or iOS/macOS applications." ;;
            uikit) echo "UIKit framework for iOS. Use when working with view controllers, UIViews, storyboards, or UIKit-based iOS applications." ;;
            jetpack*) echo "Jetpack Compose for Android. Use when building declarative UI, composables, state management, or modern Android applications." ;;
            *) echo "$fw_name framework for $lang. Use when working with $fw_name-specific features, patterns, or implementation details." ;;
        esac
    else
        # For general rules and documentation
        local filename
        filename=$(basename "$file")
        case "$filename" in
            code-style*) echo "$lang code style, naming conventions, and formatting rules. Use when writing new code, reviewing code, or refactoring $lang code." ;;
            security*) echo "$lang security best practices and OWASP guidelines. Use when implementing authentication, handling sensitive data, validating input, or conducting security reviews." ;;
            testing*) echo "$lang testing strategies, test patterns, and assertion guidelines. Use when writing tests, setting up test infrastructure, or reviewing test coverage." ;;
            documentation-api*) echo "API documentation standards with OpenAPI/Swagger specifications. Use when documenting REST endpoints, generating API schemas, or creating API reference documentation." ;;
            documentation-code*) echo "Code documentation with comments, docstrings, and inline documentation. Use when adding code comments, writing function documentation, or improving code readability." ;;
            documentation-project*) echo "Project-level documentation including README, CHANGELOG, and contribution guides. Use when creating project documentation, writing setup instructions, or maintaining project files." ;;
            *) echo "$lang development standards and best practices. Use when working with $lang projects or making architectural decisions." ;;
        esac
    fi
}

generate_claude() {
    print_info "Generating Claude configuration..."
    
    # Part 1: Generate CLAUDE.md (always-loaded rules)
    local claude_md="$PROJECT_ROOT/CLAUDE.md"
    
    {
        echo "# AI Coding Instructions"
        echo ""
        echo "<!-- Generated by AI Instructions and Prompts Setup -->"
        echo "<!-- https://github.com/your-repo/ai-instructions-and-prompts -->"
        echo ""
    } > "$claude_md"
    
    # Add general language files (always-apply rules)
    for lang in "${SELECTED_LANGUAGES[@]}"; do
        local lang_name
        lang_name=$(get_language_name "$lang")
        
        # Base language files (general rules like code-style, security, testing)
        while IFS= read -r file; do
            local content
            content=$(read_instruction_file "$lang" "$file") || continue
            
            {
                echo ""
                echo "## $lang_name - $file"
                echo ""
                echo "$content"
                echo ""
                echo "---"
                echo ""
            } >> "$claude_md"
        done < <(get_language_files "$lang")
        
        # Add selected documentation files (only for general language)
        if [[ "$lang" == "general" && ${#SELECTED_DOCUMENTATION[@]} -gt 0 ]]; then
            for doc_file in "${SELECTED_DOCUMENTATION[@]}"; do
                local content
                content=$(read_instruction_file "$lang" "$doc_file") || continue
                
                {
                    echo ""
                    echo "## Documentation - $doc_file"
                    echo ""
                    echo "$content"
                    echo ""
                    echo "---"
                    echo ""
                } >> "$claude_md"
            done
        fi
    done
    
    print_success "Created CLAUDE.md"
    
    # Part 2: Generate .claude/skills/ (optional, context-triggered skills)
    local output_dir="$PROJECT_ROOT/.claude/skills"
    
    print_info "Generating Claude Agent Skills..."
    
    for lang in "${SELECTED_LANGUAGES[@]}"; do
        # Generate framework files as skills (optional, context-triggered)
        if [[ -n "${SELECTED_FRAMEWORKS[$lang]:-}" ]]; then
            for fw in ${SELECTED_FRAMEWORKS[$lang]}; do
                local fw_file content
                fw_file=$(get_framework_file "$lang" "$fw")
                content=$(read_instruction_file "$lang" "$fw_file" "true") || continue
                
                local skill_name="$lang-framework-$fw"
                local skill_dir="$output_dir/$skill_name"
                mkdir -p "$skill_dir"
                
                local output_file="$skill_dir/SKILL.md"
                local description
                description=$(get_skill_description "$lang" "" "$fw" "" "")
                
                {
                    echo "---"
                    echo "name: $skill_name"
                    echo "description: $description"
                    echo "---"
                    echo ""
                    echo "$content"
                } > "$output_file"
                
                local relative_path="${output_file#"$PROJECT_ROOT/"}"
                print_success "Created $relative_path"
                
                # Generate structure file if selected
                local struct_key="$lang-$fw"
                if [[ -n "${SELECTED_STRUCTURES[$struct_key]:-}" ]]; then
                    local struct_file="${SELECTED_STRUCTURES[$struct_key]}"
                    local struct_content
                    struct_content=$(read_instruction_file "$lang" "$struct_file" "false" "true") || continue
                    
                    local struct_skill_name="$lang-$fw-${struct_file//\//-}"
                    local struct_skill_dir="$output_dir/$struct_skill_name"
                    mkdir -p "$struct_skill_dir"
                    
                    local struct_output="$struct_skill_dir/SKILL.md"
                    local struct_description
                    struct_description=$(get_skill_description "$lang" "" "$fw" "$struct_file" "")
                    
                    {
                        echo "---"
                        echo "name: $struct_skill_name"
                        echo "description: $struct_description"
                        echo "---"
                        echo ""
                        echo "$struct_content"
                    } > "$struct_output"
                    
                    local relative_path="${struct_output#"$PROJECT_ROOT/"}"
                    print_success "Created $relative_path"
                fi
            done
        fi
        
        # Generate process files as skills
        if [[ -n "${SELECTED_PROCESSES[$lang]:-}" ]]; then
            for proc in ${SELECTED_PROCESSES[$lang]}; do
                local proc_file content load_into_ai
                proc_file=$(get_process_file "$lang" "$proc")
                load_into_ai=$(get_process_load_into_ai "$lang" "$proc")
                
                # Skip on-demand processes (user copies prompt when needed)
                if [[ "$load_into_ai" == "false" ]]; then
                    continue
                fi
                
                content=$(read_instruction_file "$lang" "$proc_file" "false" "false" "true") || continue
                
                local skill_name="$lang-process-$proc"
                local skill_dir="$output_dir/$skill_name"
                mkdir -p "$skill_dir"
                
                local output_file="$skill_dir/SKILL.md"
                local description
                description=$(get_skill_description "$lang" "" "" "" "$proc")
                
                {
                    echo "---"
                    echo "name: $skill_name"
                    echo "description: $description"
                    echo "---"
                    echo ""
                    echo "$content"
                } > "$output_file"
                
                local relative_path="${output_file#"$PROJECT_ROOT/"}"
                print_success "Created $relative_path"
            done
        fi
    done
}

generate_concatenated() {
    local tool="$1"
    local output_file="$2"
    local separator="$3"
    
    print_info "Generating $tool configuration..."
    
    mkdir -p "$(dirname "$PROJECT_ROOT/$output_file")"
    
    {
        echo "# AI Coding Instructions"
        echo ""
        echo "<!-- Generated by AI Instructions and Prompts Setup -->"
        echo "<!-- https://github.com/your-repo/ai-instructions-and-prompts -->"
        echo ""
        
        for lang in "${SELECTED_LANGUAGES[@]}"; do
            local lang_name
            lang_name=$(get_language_name "$lang")
            
            # Base language files
            while IFS= read -r file; do
                local content
                content=$(read_instruction_file "$lang" "$file") || continue
                
                if [[ -n "$separator" ]]; then
                    echo "$separator"
                fi
                
                echo "$content"
                echo ""
                echo "---"
                echo ""
            done < <(get_language_files "$lang")
            
            # Selected documentation files (only for general language)
            if [[ "$lang" == "general" && ${#SELECTED_DOCUMENTATION[@]} -gt 0 ]]; then
                for doc_file in "${SELECTED_DOCUMENTATION[@]}"; do
                    local content
                    content=$(read_instruction_file "$lang" "$doc_file") || continue
                    
                    if [[ -n "$separator" ]]; then
                        echo "$separator"
                    fi
                    
                    echo "$content"
                    echo ""
                    echo "---"
                    echo ""
                done
            fi
            
            # Framework files for this language
            if [[ -n "${SELECTED_FRAMEWORKS[$lang]:-}" ]]; then
                for fw in ${SELECTED_FRAMEWORKS[$lang]}; do
                    local fw_file content
                    fw_file=$(get_framework_file "$lang" "$fw")
                    content=$(read_instruction_file "$lang" "$fw_file" "true") || continue
                    
                    if [[ -n "$separator" ]]; then
                        echo "$separator"
                    fi
                    
                    echo "$content"
                    echo ""
                    echo "---"
                    echo ""
                    
                    # Structure file if selected
                    local struct_key="$lang-$fw"
                    if [[ -n "${SELECTED_STRUCTURES[$struct_key]:-}" ]]; then
                        local struct_file="${SELECTED_STRUCTURES[$struct_key]}"
                        local struct_content
                        struct_content=$(read_instruction_file "$lang" "$struct_file" "false" "true") || continue
                        
                        if [[ -n "$separator" ]]; then
                            echo "$separator"
                        fi
                        
                        echo "$struct_content"
                        echo ""
                        echo "---"
                        echo ""
                    fi
                done
            fi
            
            # Process files for this language
            if [[ -n "${SELECTED_PROCESSES[$lang]:-}" ]]; then
                for proc in ${SELECTED_PROCESSES[$lang]}; do
                    local proc_file content load_into_ai
                    proc_file=$(get_process_file "$lang" "$proc")
                    load_into_ai=$(get_process_load_into_ai "$lang" "$proc")
                    
                    # Skip on-demand processes (user copies prompt when needed)
                    if [[ "$load_into_ai" == "false" ]]; then
                        continue
                    fi
                    
                    content=$(read_instruction_file "$lang" "$proc_file" "false" "false" "true") || continue
                    
                    if [[ -n "$separator" ]]; then
                        echo "$separator"
                    fi
                    
                    echo "$content"
                    echo ""
                    echo "---"
                    echo ""
                done
            fi
        done
    } > "$PROJECT_ROOT/$output_file"
    
    print_success "Created $output_file"
}

generate_tool() {
    local tool="$1"
    
    case "$tool" in
        cursor)
            generate_cursor
            ;;
        claude)
            generate_claude
            ;;
        github-copilot)
            generate_concatenated "GitHub Copilot" ".github/copilot-instructions.md" ""
            ;;
        windsurf)
            generate_concatenated "Windsurf" ".windsurfrules" ""
            ;;
        aider)
            generate_concatenated "Aider" "CONVENTIONS.md" ""
            ;;
        google-ai-studio)
            generate_concatenated "Google AI Studio" "GOOGLE_AI_STUDIO.md" ""
            ;;
        amazon-q)
            generate_concatenated "Amazon Q Developer" "AMAZON_Q.md" ""
            ;;
        tabnine)
            generate_concatenated "Tabnine" "TABNINE.md" ""
            ;;
        cody)
            generate_concatenated "Cody (Sourcegraph)" ".cody/instructions.md" ""
            ;;
        continue)
            generate_concatenated "Continue.dev" ".continue/instructions.md" ""
            ;;
        *)
            print_warning "Unknown tool: $tool"
            ;;
    esac
}

# ============================================================================
# Gitignore Management
# ============================================================================

prompt_gitignore() {
    echo ""
    read -rp "Add .ai-iap/ to .gitignore? (y/N): " add_gitignore
    
    if [[ "$add_gitignore" =~ ^[Yy]$ ]]; then
        local gitignore="$PROJECT_ROOT/.gitignore"
        
        if [[ -f "$gitignore" ]]; then
            if ! grep -q "^\.ai-iap/" "$gitignore"; then
                echo "" >> "$gitignore"
                echo "# AI Instructions source (generated files committed instead)" >> "$gitignore"
                echo ".ai-iap/" >> "$gitignore"
                print_success "Added .ai-iap/ to .gitignore"
            else
                print_info ".ai-iap/ already in .gitignore"
            fi
        else
            echo "# AI Instructions source (generated files committed instead)" > "$gitignore"
            echo ".ai-iap/" >> "$gitignore"
            print_success "Created .gitignore with .ai-iap/"
        fi
    fi
}

# ============================================================================
# Main
# ============================================================================

main() {
    print_header
    check_dependencies
    load_config
    
    cd "$PROJECT_ROOT"
    print_info "Project root: $PROJECT_ROOT"
    echo ""
    
    # Selection
    select_tools_simple
    
    if [[ ${#SELECTED_TOOLS[@]} -eq 0 ]]; then
        print_warning "No tools selected. Exiting."
        exit 0
    fi
    
    select_languages_simple
    
    if [[ ${#SELECTED_LANGUAGES[@]} -eq 0 ]]; then
        print_warning "No languages selected. Exiting."
        exit 0
    fi
    
    # Documentation selection
    select_documentation
    
    # Framework selection
    select_frameworks
    
    # Structure selection (for frameworks that have structure options)
    select_structures
    
    # Process selection
    select_processes
    
    echo ""
    echo -e "${BOLD}Configuration Summary:${NC}"
    echo "  Tools: ${SELECTED_TOOLS[*]}"
    echo "  Languages: ${SELECTED_LANGUAGES[*]}"
    if [[ ${#SELECTED_DOCUMENTATION[@]} -gt 0 ]]; then
        echo "  Documentation: ${SELECTED_DOCUMENTATION[*]}"
    fi
    
    for lang in "${!SELECTED_FRAMEWORKS[@]}"; do
        echo "  Frameworks ($lang): ${SELECTED_FRAMEWORKS[$lang]}"
    done
    for key in "${!SELECTED_STRUCTURES[@]}"; do
        echo "  Structure ($key): ${SELECTED_STRUCTURES[$key]}"
    done
    for lang in "${!SELECTED_PROCESSES[@]}"; do
        echo "  Processes ($lang): ${SELECTED_PROCESSES[$lang]}"
    done
    echo ""
    
    read -rp "Proceed with generation? (Y/n): " confirm
    if [[ "$confirm" =~ ^[Nn]$ ]]; then
        print_info "Aborted."
        exit 0
    fi
    
    echo ""
    
    # Generate files
    for tool in "${SELECTED_TOOLS[@]}"; do
        generate_tool "$tool"
    done
    
    # Gitignore prompt
    prompt_gitignore
    
    echo ""
    echo -e "${GREEN}${BOLD}Setup complete!${NC}"
    echo ""
}

main "$@"
