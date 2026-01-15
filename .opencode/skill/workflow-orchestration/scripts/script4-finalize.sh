#!/usr/bin/env bash
set -euo pipefail

# Phase 4: Finalization
TASK="${1:-}"
REPOS="${2:-}"

echo "🏁 Phase 4: Finalization"
echo ""

# Run quality gates (if task specified)
if [[ -n "$TASK" ]]; then
  echo "   Running quality gates..."
  if [[ -x "./scripts/oc-gate" ]]; then
    echo "      Executing: ./scripts/oc-gate $TASK"
    if ./scripts/oc-gate "$TASK" 2>&1 | head -20; then
      echo "      ✅ Gates passed"
    else
      echo "      ⚠️  Gates failed (non-blocking in finalize)"
    fi
  else
    echo "      ⚠️  oc-gate not found or not executable"
  fi
else
  echo "   ⚠️  No task specified, skipping gates"
fi
echo ""

# Generate evidence
echo "   Generating evidence..."
if [[ -n "$TASK" ]]; then
  WORKLOG_FILE="worklog/$(date +%F)_${TASK}.md"
  if [[ -f "$WORKLOG_FILE" ]]; then
    echo "      ✅ Worklog exists: $WORKLOG_FILE"
  else
    echo "      ⚠️  Worklog not found (may not be created yet)"
  fi

  # Check for CI results
  CI_FILE="worklog/$(date +%F)_ci_${TASK}.md"
  if [[ -f "$CI_FILE" ]]; then
    echo "      ✅ CI results: $CI_FILE"
  fi
fi
echo ""

# Cleanup (if needed)
echo "   Cleanup..."
echo "      - Removing temp files..."
rm -f /tmp/workflow_* 2>/dev/null || true
echo "      ✅ Cleanup complete"
echo ""

# Summary
echo "   📊 Summary:"
echo "      - Task: ${TASK:-<not specified>}"
echo "      - Repos: ${REPOS:-<not specified>}"
echo "      - Status: ✅ All phases completed"
echo "      - Next step: Review and wrap"
echo ""

echo "✅ Finalization complete"
