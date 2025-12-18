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
    if [[ ! -f "$CONFIG_FILE" ]]; then
        print_error "Config file not found: $CONFIG_FILE"
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
    if ! jq empty "$CONFIG_FILE" 2>/dev/null; then
        print_error "Failed to parse config file: $CONFIG_FILE"
        echo ""
        echo -e "${YELLOW}The config.json file exists but contains invalid JSON.${NC}"
        echo ""
        echo -e "${CYAN}Solution:${NC}"
        echo -e "  ${NC}1. Validate JSON syntax: jq empty \"$CONFIG_FILE\"${NC}"
        echo -e "  ${NC}2. Check for common issues:${NC}"
        echo -e "     ${NC}- Missing or extra commas${NC}"
        echo -e "     ${NC}- Unmatched brackets/braces${NC}"
        echo -e "     ${NC}- Missing quotes around strings${NC}"
        echo -e "  ${NC}3. Or restore from git: git checkout $CONFIG_FILE${NC}"
        echo ""
        exit 1
    fi
}

get_tools() {
    jq -r '.tools | keys[]' "$CONFIG_FILE"
}

get_tool_name() {
    jq -r ".tools[\"$1\"].name" "$CONFIG_FILE"
}

get_languages() {
    jq -r '.languages | keys[]' "$CONFIG_FILE"
}

get_language_name() {
    jq -r ".languages[\"$1\"].name" "$CONFIG_FILE"
}

get_language_files() {
    jq -r ".languages[\"$1\"].files[]" "$CONFIG_FILE"
}

get_language_globs() {
    jq -r ".languages[\"$1\"].globs" "$CONFIG_FILE"
}

get_language_always_apply() {
    jq -r ".languages[\"$1\"].alwaysApply" "$CONFIG_FILE"
}

get_language_description() {
    jq -r ".languages[\"$1\"].description" "$CONFIG_FILE"
}

get_language_frameworks() {
    jq -r ".languages[\"$1\"].frameworks // empty | keys[]" "$CONFIG_FILE" 2>/dev/null || true
}

get_framework_name() {
    jq -r ".languages[\"$1\"].frameworks[\"$2\"].name" "$CONFIG_FILE"
}

get_framework_description() {
    jq -r ".languages[\"$1\"].frameworks[\"$2\"].description" "$CONFIG_FILE"
}

get_framework_file() {
    jq -r ".languages[\"$1\"].frameworks[\"$2\"].file" "$CONFIG_FILE"
}

get_framework_category() {
    jq -r ".languages[\"$1\"].frameworks[\"$2\"].category // \"Other\"" "$CONFIG_FILE"
}

get_framework_structures() {
    jq -r ".languages[\"$1\"].frameworks[\"$2\"].structures // empty | keys[]" "$CONFIG_FILE" 2>/dev/null || true
}

get_structure_name() {
    jq -r ".languages[\"$1\"].frameworks[\"$2\"].structures[\"$3\"].name" "$CONFIG_FILE"
}

get_structure_description() {
    jq -r ".languages[\"$1\"].frameworks[\"$2\"].structures[\"$3\"].description" "$CONFIG_FILE"
}

get_structure_file() {
    jq -r ".languages[\"$1\"].frameworks[\"$2\"].structures[\"$3\"].file" "$CONFIG_FILE"
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
        recommended=$(jq -r ".tools[\"${tool_keys[$i]}\"].recommended // false" "$CONFIG_FILE")
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
        always_apply=$(jq -r ".languages[\"$key\"].alwaysApply // false" "$CONFIG_FILE")
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
        always_apply=$(jq -r ".languages[\"${lang_keys[$i]}\"].alwaysApply // false" "$CONFIG_FILE")
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
            fw_recs+=("$(jq -r ".languages[\"$lang\"].frameworks[\"$key\"].recommended // false" "$CONFIG_FILE")")
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
                struct_recs+=("$(jq -r ".languages[\"$lang\"].frameworks[\"$fw\"].structures[\"$key\"].recommended // false" "$CONFIG_FILE")")
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
    
    # Processes folder is at root level, others are under rules/
    if [[ "$lang" == "processes" ]]; then
        local filepath="$SCRIPT_DIR/processes/$file.md"
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
            
            {
                generate_cursor_frontmatter "$lang" "$file" "false"
                echo "$content"
            } > "$output_file"
            
            # Show relative path
            local relative_path="${output_file#"$PROJECT_ROOT/"}"
            print_success "Created $relative_path"
        done < <(get_language_files "$lang")
        
        # Generate framework files for this language
        if [[ -n "${SELECTED_FRAMEWORKS[$lang]:-}" ]]; then
            for fw in ${SELECTED_FRAMEWORKS[$lang]}; do
                local fw_file output_file content
                fw_file=$(get_framework_file "$lang" "$fw")
                output_file="$lang_dir/$fw_file.mdc"
                
                content=$(read_instruction_file "$lang" "$fw_file" "true") || continue
                
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
                    
                    {
                        generate_cursor_frontmatter "$lang" "$fw" "true"
                        echo "$struct_content"
                    } > "$struct_output"
                    
                    local relative_path="${struct_output#"$PROJECT_ROOT/"}"
                    print_success "Created $relative_path"
                fi
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
        claude-cli)
            generate_concatenated "Claude CLI" "CLAUDE.md" ""
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
    
    # Framework selection
    select_frameworks
    
    # Structure selection (for frameworks that have structure options)
    select_structures
    
    echo ""
    echo -e "${BOLD}Configuration Summary:${NC}"
    echo "  Tools: ${SELECTED_TOOLS[*]}"
    echo "  Languages: ${SELECTED_LANGUAGES[*]}"
    
    for lang in "${!SELECTED_FRAMEWORKS[@]}"; do
        echo "  Frameworks ($lang): ${SELECTED_FRAMEWORKS[$lang]}"
    done
    for key in "${!SELECTED_STRUCTURES[@]}"; do
        echo "  Structure ($key): ${SELECTED_STRUCTURES[$key]}"
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
