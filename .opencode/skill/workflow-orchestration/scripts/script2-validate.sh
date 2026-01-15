#!/usr/bin/env bash
set -euo pipefail

# Phase 2: Validation
TASK="${1:-}"
REPOS="${2:-}"

echo "🔍 Phase 2: Validation"
echo ""

# Validate task input
if [[ -z "$TASK" ]]; then
  echo "   ⚠️  No task specified (validation limited)"
else
  echo "   Task: $TASK"

  # Check if targets file exists
  TARGETS_FILE=".opencode/targets/$(date +%F)_${TASK}.txt"
  if [[ -f "$TARGETS_FILE" ]]; then
    REPO_COUNT=$(grep -cvE '^\s*(#|$)' "$TARGETS_FILE" || echo "0")
    echo "   ✅ Targets file found: $TARGETS_FILE"
    echo "   ✅ Target repos: $REPO_COUNT"

    # Validate repos exist
    echo "   Validating repos exist..."
    while IFS= read -r repo; do
      [[ -z "$repo" || "$repo" =~ ^\s*# ]] && continue
      if [[ -d "$repo" ]]; then
        echo "      ✅ $repo"
      else
        echo "      ❌ $repo (not found)"
        exit 1
      fi
    done < "$TARGETS_FILE"
  else
    echo "   ⚠️  No targets file (ok if not needed)"
  fi
fi
echo ""

# Check git status
echo "   Checking git status..."
if git diff --quiet && git diff --cached --quiet; then
  echo "   ℹ️  Working directory clean (no changes)"
else
  echo "   ✅ Working directory has changes"
  changed_files=$(git diff --name-only | wc -l)
  staged_files=$(git diff --cached --name-only | wc -l)
  echo "      - Changed: $changed_files files"
  echo "      - Staged: $staged_files files"
fi
echo ""

# Validate repos parameter if provided
if [[ -n "$REPOS" ]]; then
  echo "   Repos parameter: $REPOS"
  IFS=',' read -ra REPO_ARRAY <<< "$REPOS"
  echo "   ✅ Parsed ${#REPO_ARRAY[@]} repos"
fi
echo ""

echo "✅ Validation complete"
