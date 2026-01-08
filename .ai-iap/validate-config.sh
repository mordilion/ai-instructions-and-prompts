#!/bin/bash
# Config Validation Script
# Checks for consistency, missing properties, and structural issues

set -e

ERROR_COUNT=0
WARNING_COUNT=0

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
NC='\033[0m' # No Color

write_error() {
    echo -e "${RED}[ERROR]${NC} $1"
    ERROR_COUNT=$((ERROR_COUNT + 1))
}

write_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
    WARNING_COUNT=$((WARNING_COUNT + 1))
}

write_success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

echo ""
echo -e "${CYAN}=== Config Validation ===${NC}"
echo ""

# Load config
if [[ ! -f ".ai-iap/config.json" ]]; then
    write_error "Config file not found: .ai-iap/config.json"
    exit 1
fi

# Validate JSON
if ! jq empty .ai-iap/config.json 2>/dev/null; then
    write_error "Failed to parse config.json"
    exit 1
fi
write_success "JSON syntax is valid"

# Check version
VERSION=$(jq -r '.version // empty' .ai-iap/config.json)
if [[ -n "$VERSION" ]]; then
    write_success "Version: $VERSION"
else
    write_error "Missing 'version' property"
fi

# Validate Tools
echo ""
echo -e "${CYAN}--- Tools Validation ---${NC}"
TOOL_COUNT=$(jq '.tools | length' .ai-iap/config.json)

for tool_key in $(jq -r '.tools | keys[]' .ai-iap/config.json); do
    # Check required properties
    name=$(jq -r ".tools[\"$tool_key\"].name // empty" .ai-iap/config.json)
    if [[ -z "$name" ]]; then
        write_error "Tool '$tool_key': Missing 'name' property"
    fi
    
    use_frontmatter=$(jq -r ".tools[\"$tool_key\"].useFrontmatter" .ai-iap/config.json)
    if [[ "$use_frontmatter" == "null" ]]; then
        write_error "Tool '$tool_key': Missing 'useFrontmatter' property"
    fi
    
    file_extension=$(jq -r ".tools[\"$tool_key\"] | has(\"fileExtension\")" .ai-iap/config.json)
    if [[ "$file_extension" != "true" ]]; then
        write_error "Tool '$tool_key': Missing 'fileExtension' property"
    fi
    
    # Check tool type consistency
    output_dir=$(jq -r ".tools[\"$tool_key\"].outputDir // empty" .ai-iap/config.json)
    output_file=$(jq -r ".tools[\"$tool_key\"].outputFile // empty" .ai-iap/config.json)
    
    if [[ -n "$output_dir" && -n "$output_file" ]]; then
        write_error "Tool '$tool_key': Has both 'outputDir' and 'outputFile' (should have only one)"
    fi
    if [[ -z "$output_dir" && -z "$output_file" ]]; then
        write_error "Tool '$tool_key': Missing both 'outputDir' and 'outputFile' (needs one)"
    fi
    
    # Cursor-specific checks
    if [[ "$tool_key" == "cursor" ]]; then
        supports_globs=$(jq -r ".tools.cursor.supportsGlobs // false" .ai-iap/config.json)
        if [[ "$supports_globs" != "true" ]]; then
            write_warning "Tool 'cursor': Should have 'supportsGlobs: true'"
        fi
        
        supports_subfolders=$(jq -r ".tools.cursor.supportsSubfolders // false" .ai-iap/config.json)
        if [[ "$supports_subfolders" != "true" ]]; then
            write_warning "Tool 'cursor': Should have 'supportsSubfolders: true'"
        fi
    fi
    
    # Claude Code-specific checks
    if [[ "$tool_key" == "claude-code" ]]; then
        skill_filename=$(jq -r ".tools[\"claude-code\"].skillFilename // \"null\"" .ai-iap/config.json)
        if [[ "$skill_filename" == "null" ]]; then
            write_warning "Tool 'claude-code': Missing 'skillFilename' property (should be 'SKILL.md')"
        fi
        
        supports_subfolders=$(jq -r ".tools[\"claude-code\"].supportsSubfolders // false" .ai-iap/config.json)
        if [[ "$supports_subfolders" != "true" ]]; then
            write_warning "Tool 'claude-code': Should have 'supportsSubfolders: true'"
        fi
        
        supports_globs=$(jq -r ".tools[\"claude-code\"].supportsGlobs // false" .ai-iap/config.json)
        if [[ "$supports_globs" == "true" ]]; then
            write_warning "Tool 'claude-code': Should have 'supportsGlobs: false' (uses directory-based skills)"
        fi
    fi
done

write_success "Validated $TOOL_COUNT tools"

# Validate Languages
echo ""
echo -e "${CYAN}--- Languages Validation ---${NC}"
LANG_COUNT=$(jq '.languages | length' .ai-iap/config.json)

for lang_key in $(jq -r '.languages | keys[]' .ai-iap/config.json); do
    echo ""
    echo -e "${WHITE}Language: $lang_key${NC}"
    
    # Check required properties
    name=$(jq -r ".languages[\"$lang_key\"].name" .ai-iap/config.json)
    if [[ "$name" == "null" ]]; then
        write_error "Language '$lang_key': Missing 'name' property"
    fi
    
    globs=$(jq -r ".languages[\"$lang_key\"].globs" .ai-iap/config.json)
    if [[ "$globs" == "null" ]]; then
        write_error "Language '$lang_key': Missing 'globs' property"
    fi
    
    # Check globs is not an array
    globs_type=$(jq -r ".languages[\"$lang_key\"].globs | type" .ai-iap/config.json)
    if [[ "$globs_type" == "array" ]]; then
        write_error "Language '$lang_key': 'globs' should be a string, not an array"
    fi
    
    always_apply=$(jq -r ".languages[\"$lang_key\"].alwaysApply" .ai-iap/config.json)
    if [[ "$always_apply" == "null" ]]; then
        write_error "Language '$lang_key': Missing 'alwaysApply' property"
    fi
    
    # Check alwaysApply is boolean
    always_apply_type=$(jq -r ".languages[\"$lang_key\"].alwaysApply | type" .ai-iap/config.json)
    if [[ "$always_apply_type" != "boolean" && "$always_apply_type" != "null" ]]; then
        write_error "Language '$lang_key': 'alwaysApply' should be boolean (true/false)"
    fi
    
    description=$(jq -r ".languages[\"$lang_key\"].description" .ai-iap/config.json)
    if [[ "$description" == "null" ]]; then
        write_error "Language '$lang_key': Missing 'description' property"
    fi
    
    files=$(jq -r ".languages[\"$lang_key\"].files" .ai-iap/config.json)
    if [[ "$files" == "null" ]]; then
        write_error "Language '$lang_key': Missing 'files' property"
    fi
    
    # Check files is array
    files_type=$(jq -r ".languages[\"$lang_key\"].files | type" .ai-iap/config.json)
    if [[ "$files_type" != "array" && "$files_type" != "null" ]]; then
        write_error "Language '$lang_key': 'files' should be an array"
    fi
    
    # Check for obsolete properties
    enabled=$(jq -r ".languages[\"$lang_key\"].enabled" .ai-iap/config.json)
    if [[ "$enabled" != "null" ]]; then
        write_error "Language '$lang_key': Uses obsolete 'enabled' property (use 'alwaysApply' instead)"
    fi
    
    # Validate frameworks
    fw_count=$(jq -r ".languages[\"$lang_key\"].frameworks // {} | length" .ai-iap/config.json)
    struct_count=0
    
    if [[ "$fw_count" -gt 0 ]]; then
        for fw_key in $(jq -r ".languages[\"$lang_key\"].frameworks // {} | keys[]" .ai-iap/config.json); do
            fw_name=$(jq -r ".languages[\"$lang_key\"].frameworks[\"$fw_key\"].name" .ai-iap/config.json)
            if [[ "$fw_name" == "null" ]]; then
                write_error "Language '$lang_key', Framework '$fw_key': Missing 'name' property"
            fi
            
            fw_file=$(jq -r ".languages[\"$lang_key\"].frameworks[\"$fw_key\"].file" .ai-iap/config.json)
            if [[ "$fw_file" == "null" ]]; then
                write_error "Language '$lang_key', Framework '$fw_key': Missing 'file' property"
            fi
            
            fw_category=$(jq -r ".languages[\"$lang_key\"].frameworks[\"$fw_key\"].category" .ai-iap/config.json)
            if [[ "$fw_category" == "null" ]]; then
                write_warning "Language '$lang_key', Framework '$fw_key': Missing 'category' property"
            fi
            
            fw_description=$(jq -r ".languages[\"$lang_key\"].frameworks[\"$fw_key\"].description" .ai-iap/config.json)
            if [[ "$fw_description" == "null" ]]; then
                write_warning "Language '$lang_key', Framework '$fw_key': Missing 'description' property"
            fi
            
            # Validate structures
            for struct_key in $(jq -r ".languages[\"$lang_key\"].frameworks[\"$fw_key\"].structures // {} | keys[]" .ai-iap/config.json); do
                struct_count=$((struct_count + 1))
                
                struct_name=$(jq -r ".languages[\"$lang_key\"].frameworks[\"$fw_key\"].structures[\"$struct_key\"].name" .ai-iap/config.json)
                if [[ "$struct_name" == "null" ]]; then
                    write_error "Language '$lang_key', Framework '$fw_key', Structure '$struct_key': Missing 'name'"
                fi
                
                struct_file=$(jq -r ".languages[\"$lang_key\"].frameworks[\"$fw_key\"].structures[\"$struct_key\"].file" .ai-iap/config.json)
                if [[ "$struct_file" == "null" ]]; then
                    write_error "Language '$lang_key', Framework '$fw_key', Structure '$struct_key': Missing 'file'"
                fi
                
                struct_description=$(jq -r ".languages[\"$lang_key\"].frameworks[\"$fw_key\"].structures[\"$struct_key\"].description" .ai-iap/config.json)
                if [[ "$struct_description" == "null" ]]; then
                    write_warning "Language '$lang_key', Framework '$fw_key', Structure '$struct_key': Missing 'description'"
                fi
            done
        done
        
        if [[ "$struct_count" -gt 0 ]]; then
            echo -e "  ${GRAY}Frameworks: $fw_count, Structures: $struct_count${NC}"
        else
            echo -e "  ${GRAY}Frameworks: $fw_count${NC}"
        fi
    fi
    
    # Validate processes
    proc_count=$(jq -r ".languages[\"$lang_key\"].processes // {} | length" .ai-iap/config.json)
    
    if [[ "$proc_count" -gt 0 ]]; then
        for proc_key in $(jq -r ".languages[\"$lang_key\"].processes // {} | keys[]" .ai-iap/config.json); do
            proc_name=$(jq -r ".languages[\"$lang_key\"].processes[\"$proc_key\"].name" .ai-iap/config.json)
            if [[ "$proc_name" == "null" ]]; then
                write_error "Language '$lang_key', Process '$proc_key': Missing 'name' property"
            fi
            
            proc_file=$(jq -r ".languages[\"$lang_key\"].processes[\"$proc_key\"].file" .ai-iap/config.json)
            if [[ "$proc_file" == "null" ]]; then
                write_error "Language '$lang_key', Process '$proc_key': Missing 'file' property"
            fi
            
            proc_description=$(jq -r ".languages[\"$lang_key\"].processes[\"$proc_key\"].description" .ai-iap/config.json)
            if [[ "$proc_description" == "null" ]]; then
                write_warning "Language '$lang_key', Process '$proc_key': Missing 'description' property"
            fi
        done
        echo -e "  ${GRAY}Processes: $proc_count${NC}"
    fi
    
    # Special validation for 'general' language
    if [[ "$lang_key" == "general" ]]; then
        if [[ "$always_apply" != "true" ]]; then
            write_error "Language 'general': Should have 'alwaysApply: true'"
        fi
        
        has_documentation=$(jq -r ".languages.general.documentation" .ai-iap/config.json)
        if [[ "$has_documentation" == "null" ]]; then
            write_warning "Language 'general': Missing 'documentation' section"
        fi
    else
        if [[ "$always_apply" == "true" ]]; then
            write_warning "Language '$lang_key': Has 'alwaysApply: true' (only 'general' should have this)"
        fi
    fi
done

write_success "Validated $LANG_COUNT languages"

# Summary
echo ""
echo -e "${CYAN}=== Validation Summary ===${NC}"
echo -e "${WHITE}Tools: $TOOL_COUNT${NC}"
echo -e "${WHITE}Languages: $LANG_COUNT${NC}"
echo ""

if [[ $ERROR_COUNT -eq 0 && $WARNING_COUNT -eq 0 ]]; then
    echo -e "${GREEN}SUCCESS: No issues found! Config is perfect.${NC}"
    exit 0
elif [[ $ERROR_COUNT -eq 0 ]]; then
    echo -e "${YELLOW}SUCCESS: Found $WARNING_COUNT warnings (non-critical)${NC}"
    exit 0
else
    echo -e "${RED}FAILED: Found $ERROR_COUNT errors and $WARNING_COUNT warnings${NC}"
    echo ""
    echo -e "${RED}Please fix the errors above before using the config.${NC}"
    exit 1
fi
