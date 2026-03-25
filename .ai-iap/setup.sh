#!/usr/bin/env bash
#
# AI Instructions and Prompts Setup - dispatcher
# Delegates to setup-rules.sh (rules) or setup-agents.sh (agents).
# The actual setup logic lives in setup-common.sh, setup-rules.sh, and setup-agents.sh.
#
# Usage: ./.ai-iap/setup.sh              # interactive: choose rules or agents
#        ./.ai-iap/setup.sh --rules-only  # run rules setup
#        ./.ai-iap/setup.sh --agents-only # run agents setup
#        ./.ai-iap/setup-rules.sh         # rules only (direct)
#        ./.ai-iap/setup-agents.sh        # agents only (direct)
#

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Parse CLI
RULES_ONLY=false
AGENTS_ONLY=false
for arg in "$@"; do
    case "$arg" in
        --rules-only)  RULES_ONLY=true ;;
        --agents-only) AGENTS_ONLY=true ;;
    esac
done

if [[ "$RULES_ONLY" == true ]]; then
    exec "$SCRIPT_DIR/setup-rules.sh" "$@"
fi
if [[ "$AGENTS_ONLY" == true ]]; then
    exec "$SCRIPT_DIR/setup-agents.sh" "$@"
fi

# Interactive: ask which setup to run
echo ""
echo "=================================================================="
echo "        AI Instructions and Prompts Setup"
echo "=================================================================="
echo ""
echo "What do you want to set up?"
echo "  1. Rules only  - languages, frameworks, structures, processes for Claude Code"
echo "  2. Agents only - Claude Code agents (you define each: name, description, tech stack)"
echo ""
echo "Tip: run ./.ai-iap/setup-rules.sh or ./.ai-iap/setup-agents.sh to skip this prompt."
echo ""
read -rp "Enter choice (1 or 2) [1]: " choice
choice="${choice:-1}"
case "$choice" in
    2) exec "$SCRIPT_DIR/setup-agents.sh" "$@" ;;
    *) exec "$SCRIPT_DIR/setup-rules.sh" "$@" ;;
esac
