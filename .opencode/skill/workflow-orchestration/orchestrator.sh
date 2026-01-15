#!/usr/bin/env bash
set -euo pipefail

# Workflow Orchestration - Sequential Multi-Script Executor
# Usage: ./orchestrator.sh [--task <name>] [--repos <list>] [--phases <1,2,3,4>] [--dry-run]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Parse arguments
TASK="${TASK:-}"
REPOS="${REPOS:-}"
PHASES="1,2,3,4" # default: all phases
DRY_RUN=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --task) TASK="$2"; shift 2 ;;
    --repos) REPOS="$2"; shift 2 ;;
    --phases) PHASES="$2"; shift 2 ;;
    --dry-run) DRY_RUN=true; shift ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

# Phase scripts
PHASE_SCRIPTS=(
  "script1-init.sh"
  "script2-validate.sh"
  "script3-execute.sh"
  "script4-finalize.sh"
)

# Logging setup
LOG_DIR="$SCRIPT_DIR/logs"
mkdir -p "$LOG_DIR"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="$LOG_DIR/${TIMESTAMP}_workflow.log"

# Convert phases string to array
IFS=',' read -ra PHASE_NUMS <<< "$PHASES"

# Start logging
{
  echo "╔════════════════════════════════════════════════════════════╗"
  echo "║       🔄 Workflow Orchestration - Sequential Execution    ║"
  echo "╚════════════════════════════════════════════════════════════╝"
  echo ""
  echo "📅 Started: $(date -Is)"
  echo "🎯 Task: ${TASK:-<not specified>}"
  echo "🗂️  Repos: ${REPOS:-<not specified>}"
  echo "🔢 Phases to execute: $PHASES"
  echo "🏃 Dry-run: $DRY_RUN"
  echo ""

  # Dry-run mode
  if [[ "$DRY_RUN" == "true" ]]; then
    echo "🔍 DRY-RUN MODE (no actual execution)"
    echo ""
    for phase_num in "${PHASE_NUMS[@]}"; do
      idx=$((phase_num - 1))
      script="${PHASE_SCRIPTS[$idx]}"
      echo "   Phase $phase_num: $script"
    done
    echo ""
    echo "✨ Dry-run complete (use without --dry-run to execute)"
    exit 0
  fi

  # Execute phases
  for phase_num in "${PHASE_NUMS[@]}"; do
    idx=$((phase_num - 1))
    script="${PHASE_SCRIPTS[$idx]}"
    script_path="$SCRIPT_DIR/scripts/$script"

    echo "─────────────────────────────────────────────────────────────"
    echo "▶️  Phase $phase_num/4: ${script%.sh}"
    echo "   Script: $script"
    echo "   Time: $(date +%H:%M:%S)"
    echo ""

    if [[ ! -f "$script_path" ]]; then
      echo "❌ Script not found: $script_path"
      echo "   Aborting workflow..."
      exit 1
    fi

    # Execute with timeout (10 min default)
    if timeout 600 bash "$script_path" "$TASK" "$REPOS"; then
      echo ""
      echo "✅ Phase completed: ${script%.sh}"
    else
      exit_code=$?
      echo ""
      echo "❌ Phase failed: ${script%.sh} (exit code: $exit_code)"
      echo "   Aborting workflow..."
      exit "$exit_code"
    fi

    echo ""
  done

  echo "─────────────────────────────────────────────────────────────"
  echo "✨ Workflow completed successfully"
  echo "📊 Total phases executed: ${#PHASE_NUMS[@]}"
  echo "⏱️  Ended: $(date -Is)"
  echo ""

} | tee "$LOG_FILE"

echo "📝 Full log saved: $LOG_FILE"
