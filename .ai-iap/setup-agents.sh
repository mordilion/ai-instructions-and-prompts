#!/usr/bin/env bash
#
# Setup agents only: Claude Code agents (you define each: name, description, tech stack).
# Standalone script - sources setup-common.sh and runs the agents flow.
#
# Usage: ./.ai-iap/setup-agents.sh
#

set -euo pipefail
IFS=$'\n\t'

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=setup-common.sh
source "$SCRIPT_DIR/setup-common.sh"

SETUP_TYPE="agents"

# ----------------------------------------------------------------------------
# Agents flow
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
    if [[ ${#PREVIOUS_SELECTED_CLAUDE_CUSTOM_DEFINED_AGENTS[@]} -gt 0 ]] || [[ -n "$(jq -r '.selectedCustomAgents[]? // empty' "$STATE_FILE" 2>/dev/null)" ]]; then
        read -rp "Remove previously generated agent files? (Y/n): " confirm_cleanup
        if [[ ! "$confirm_cleanup" =~ ^[Nn]$ ]]; then
            cleanup_managed_claude_agents
            rm -f "$STATE_FILE" 2>/dev/null || true
            print_success "Cleanup complete."
        fi
    else
        print_info "No previous agents setup found in state."
    fi
    exit 0
fi

if [[ "${SETUP_MODE:-wizard}" == "reuse" ]]; then
    SELECTED_CLAUDE_CUSTOM_DEFINED_AGENTS=("${PREVIOUS_SELECTED_CLAUDE_CUSTOM_DEFINED_AGENTS[@]:-}")
else
    select_claude_subagents
fi

if [[ ${#SELECTED_CLAUDE_CUSTOM_DEFINED_AGENTS[@]:-0} -eq 0 ]]; then
    print_warning "No agents defined. Exiting."
    exit 0
fi

# For state/cleanup we treat agents as "claude" tool
SELECTED_TOOLS=("claude")

echo ""
echo "Configuration Summary (agents):"
echo "  Scope: $SCOPE ($OUTPUT_ROOT)"
echo "  Agents: ${#SELECTED_CLAUDE_CUSTOM_DEFINED_AGENTS[@]} defined"
echo ""

read -rp "Proceed with generation? (Y/n): " confirm
if [[ "$confirm" =~ ^[Nn]$ ]]; then
    print_info "Aborted."
    exit 0
fi

echo ""

if have_previous_state; then
    read -rp "Clean up previously generated agent files before regenerating? (Y/n): " do_cleanup
    if [[ ! "$do_cleanup" =~ ^[Nn]$ ]]; then
        cleanup_managed_claude_agents
    fi
fi

generate_claude_subagents

# Preserve rules state when saving (agents script does not touch rules)
SELECTED_TOOLS=("${PREVIOUS_SELECTED_TOOLS[@]:-}")
SELECTED_LANGUAGES=("${PREVIOUS_SELECTED_LANGUAGES[@]:-}")
SELECTED_DOCUMENTATION=("${PREVIOUS_SELECTED_DOCUMENTATION[@]:-}")
SELECTED_FRAMEWORKS=()
SELECTED_STRUCTURES=()
SELECTED_PROCESSES=()
ENABLE_COMMIT_STANDARDS="${PREVIOUS_ENABLE_COMMIT_STANDARDS:-true}"
for k in "${!PREVIOUS_SELECTED_FRAMEWORKS[@]}"; do SELECTED_FRAMEWORKS["$k"]="${PREVIOUS_SELECTED_FRAMEWORKS[$k]}"; done
for k in "${!PREVIOUS_SELECTED_STRUCTURES[@]}"; do SELECTED_STRUCTURES["$k"]="${PREVIOUS_SELECTED_STRUCTURES[$k]}"; done
for k in "${!PREVIOUS_SELECTED_PROCESSES[@]}"; do SELECTED_PROCESSES["$k"]="${PREVIOUS_SELECTED_PROCESSES[$k]}"; done
save_state

prompt_gitignore

echo ""
print_success "Setup complete!"
echo ""
