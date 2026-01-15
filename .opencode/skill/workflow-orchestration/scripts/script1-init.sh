#!/usr/bin/env bash
set -euo pipefail

# Phase 1: Initialization
TASK="${1:-}"
REPOS="${2:-}"

echo "🚀 Phase 1: Initialization"
echo ""

# Check required dependencies
echo "   Checking dependencies..."
DEPS_OK=true

if ! command -v node >/dev/null 2>&1; then
  echo "   ⚠️  node not found (some checks may fail)"
  DEPS_OK=false
fi

if ! command -v git >/dev/null 2>&1; then
  echo "   ❌ git not found (required)"
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "   ⚠️  jq not found (JSON parsing may fail)"
fi

if [[ "$DEPS_OK" == "true" ]]; then
  echo "   ✅ Core dependencies OK"
fi
echo ""

# Setup workspace directories
echo "   Setting up workspace..."
mkdir -p worklog
mkdir -p .opencode/targets
mkdir -p .opencode/skill/workflow-orchestration/logs
echo "   ✅ Workspace directories ready"
echo ""

# Validate task name
if [[ -n "$TASK" ]]; then
  echo "   Task specified: $TASK"
  # Check if task already has targets
  TARGETS_FILE=".opencode/targets/$(date +%F)_${TASK}.txt"
  if [[ -f "$TARGETS_FILE" ]]; then
    echo "   ✅ Targets file exists: $TARGETS_FILE"
  else
    echo "   ⚠️  Targets file not found (will be created)"
  fi
else
  echo "   ⚠️  No task specified (ok for generic workflows)"
fi
echo ""

# Environment info
echo "   Environment:"
echo "   - PWD: $(pwd)"
echo "   - User: $(whoami)"
echo "   - Date: $(date -Is)"
echo ""

echo "✅ Initialization complete"
