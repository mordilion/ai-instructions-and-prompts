#!/usr/bin/env bash
#
# Setup rules only: languages, frameworks, tools (Cursor, Claude rules, Copilot, etc.).
# Standalone script - sources setup-common.sh and runs the rules flow.
#
# Usage: ./.ai-iap/setup-rules.sh
#

set -euo pipefail
IFS=$'\n\t'

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=setup-common.sh
source "$SCRIPT_DIR/setup-common.sh"

SETUP_TYPE="rules"

# ----------------------------------------------------------------------------
# Rules flow
# ----------------------------------------------------------------------------

print_header
check_dependencies
load_config

select_scope
prompt_previous_run_mode

cd "$PROJECT_ROOT"
print_info "Project root (source): $PROJECT_ROOT"
print_info "Output root: $OUTPUT_ROOT (scope: $SCOPE)"
echo ""

if [[ "${SETUP_MODE:-wizard}" == "cleanup" ]]; then
    if [[ ${#PREVIOUS_SELECTED_TOOLS[@]} -gt 0 ]] || [[ -n "$(jq -r '.selectedCustomAgents[]? // empty' "$STATE_FILE" 2>/dev/null)" ]]; then
        read -rp "Remove previously generated files? (Y/n): " confirm_cleanup
        if [[ ! "$confirm_cleanup" =~ ^[Nn]$ ]]; then
            for t in "${PREVIOUS_SELECTED_TOOLS[@]}"; do
                cleanup_tool_outputs "$t"
            done
            if [[ ${#PREVIOUS_SELECTED_TOOLS[@]} -eq 0 ]]; then
                cleanup_managed_claude_agents
            fi
            rm -f "$STATE_FILE" 2>/dev/null || true
            print_success "Cleanup complete."
        fi
    else
        print_info "No previous setup found in state."
    fi
    exit 0
fi

if [[ "${SETUP_MODE:-wizard}" == "reuse" ]]; then
    SELECTED_TOOLS=("${PREVIOUS_SELECTED_TOOLS[@]}")
    SELECTED_LANGUAGES=("${PREVIOUS_SELECTED_LANGUAGES[@]}")
    SELECTED_DOCUMENTATION=("${PREVIOUS_SELECTED_DOCUMENTATION[@]}")
    ENABLE_COMMIT_STANDARDS="${PREVIOUS_ENABLE_COMMIT_STANDARDS:-true}"
    SELECTED_FRAMEWORKS=()
    SELECTED_STRUCTURES=()
    SELECTED_PROCESSES=()
    for k in "${!PREVIOUS_SELECTED_FRAMEWORKS[@]}"; do SELECTED_FRAMEWORKS["$k"]="${PREVIOUS_SELECTED_FRAMEWORKS[$k]}"; done
    for k in "${!PREVIOUS_SELECTED_STRUCTURES[@]}"; do SELECTED_STRUCTURES["$k"]="${PREVIOUS_SELECTED_STRUCTURES[$k]}"; done
    for k in "${!PREVIOUS_SELECTED_PROCESSES[@]}"; do SELECTED_PROCESSES["$k"]="${PREVIOUS_SELECTED_PROCESSES[$k]}"; done
else
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

    select_documentation
    select_commit_standards
    select_frameworks
    select_structures
    select_processes
fi

echo ""
echo "Configuration Summary (rules):"
echo "  Scope: $SCOPE ($OUTPUT_ROOT)"
echo "  Tools: ${SELECTED_TOOLS[*]}"
echo "  Languages: ${SELECTED_LANGUAGES[*]}"
if [[ ${#SELECTED_DOCUMENTATION[@]} -gt 0 ]]; then
    echo "  Documentation: ${SELECTED_DOCUMENTATION[*]}"
fi
echo "  Commit standards: ${ENABLE_COMMIT_STANDARDS}"
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

if have_previous_state; then
    read -rp "Clean up previously generated files for selected tools before regenerating? (Y/n): " do_cleanup
    if [[ ! "$do_cleanup" =~ ^[Nn]$ ]]; then
        declare -A _cleanup_set
        for t in "${PREVIOUS_SELECTED_TOOLS[@]}"; do _cleanup_set["$t"]=1; done
        for t in "${SELECTED_TOOLS[@]}"; do _cleanup_set["$t"]=1; done
        for t in "${!_cleanup_set[@]}"; do cleanup_tool_outputs "$t"; done
    fi
fi

for tool in "${SELECTED_TOOLS[@]}"; do
    generate_tool "$tool"
done

# Preserve agents state when saving (rules script does not touch agents)
SELECTED_CLAUDE_SUBAGENTS=()
SELECTED_CLAUDE_CUSTOM_DEFINED_AGENTS=("${PREVIOUS_SELECTED_CLAUDE_CUSTOM_DEFINED_AGENTS[@]:-}")
save_state

prompt_gitignore

echo ""
print_success "Setup complete!"
echo ""
