#!/usr/bin/env bash
set -euo pipefail

# Smart Router - Config-driven workflow execution
# Usage: ./router.sh <config-name> <task> <repos>

CONFIG_NAME="${1:-multi-repo-e2e}"
TASK="${2:-}"
REPOS="${3:-}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/config/${CONFIG_NAME}.json"

# Validate inputs
[[ -n "$TASK" ]] || { echo "Usage: ./router.sh <config> <task> <repos>"; exit 1; }
[[ -f "$CONFIG_FILE" ]] || { echo "❌ Config not found: $CONFIG_FILE"; exit 1; }

# Check for jq (JSON parser)
if ! command -v jq >/dev/null 2>&1; then
  echo "⚠️  jq not found. Install: apt-get install jq or brew install jq"
  exit 1
fi

# Parse config
WORKFLOW=$(jq -r '.workflow' "$CONFIG_FILE")
DESCRIPTION=$(jq -r '.description' "$CONFIG_FILE")
PHASE_COUNT=$(jq '.phases | length' "$CONFIG_FILE")

# Header
echo "╔════════════════════════════════════════════════════════════╗"
echo "║         🚀 Smart Router - Multi-Repo Orchestration        ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "📋 Workflow: $WORKFLOW"
echo "📝 Description: $DESCRIPTION"
echo "🎯 Task: $TASK"
echo "🗂️  Repos: $REPOS"
echo "🔢 Phases: $PHASE_COUNT"
echo ""

# Execute phases
for ((i=0; i<PHASE_COUNT; i++)); do
  PHASE_NAME=$(jq -r ".phases[$i].name" "$CONFIG_FILE")
  PHASE_SCRIPT=$(jq -r ".phases[$i].script" "$CONFIG_FILE")
  PHASE_PARALLEL=$(jq -r ".phases[$i].parallel" "$CONFIG_FILE")
  PHASE_DESC=$(jq -r ".phases[$i].description" "$CONFIG_FILE")
  PHASE_TIMEOUT=$(jq -r ".phases[$i].timeout" "$CONFIG_FILE")

  echo "─────────────────────────────────────────────────────────────"
  echo "▶️  Phase $((i+1))/$PHASE_COUNT: $PHASE_NAME"
  echo "   Description: $PHASE_DESC"
  echo "   Script: $PHASE_SCRIPT"
  echo "   Parallel: $PHASE_PARALLEL"
  echo "   Timeout: ${PHASE_TIMEOUT}s"
  echo ""

  PHASE_SCRIPT_PATH="$SCRIPT_DIR/scripts/$PHASE_SCRIPT"

  if [[ ! -f "$PHASE_SCRIPT_PATH" ]]; then
    echo "⚠️  Warning: Phase script not found: $PHASE_SCRIPT_PATH"
    echo "   Skipping phase..."
    continue
  fi

  # Execute phase script
  if bash "$PHASE_SCRIPT_PATH" "$TASK" "$REPOS"; then
    echo "✅ Phase completed: $PHASE_NAME"
  else
    echo "❌ Phase failed: $PHASE_NAME"
    echo "   Aborting workflow..."
    exit 1
  fi

  echo ""
done

# Footer
echo "─────────────────────────────────────────────────────────────"
echo "✨ Workflow completed successfully: $WORKFLOW"
echo "📊 Total phases executed: $PHASE_COUNT"
echo "🎉 Task ready for wrap: $TASK"
echo ""
