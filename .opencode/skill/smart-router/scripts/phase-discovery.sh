#!/usr/bin/env bash
set -euo pipefail

# Phase: Discovery (Parallel Repo-Scouts)
TASK="$1"
REPOS="${2:-}"

echo "🔍 Discovery Phase"
echo "   Task: $TASK"
echo "   Repos: $REPOS"
echo ""

if [[ -z "$REPOS" ]]; then
  echo "⚠️  No repos specified. Auto-detecting from targets..."
  # Read from targets file if exists
  TARGETS_FILE=".opencode/targets/$(date +%F)_${TASK}.txt"
  if [[ -f "$TARGETS_FILE" ]]; then
    REPOS=$(grep -vE '^\s*#' "$TARGETS_FILE" | sed '/^\s*$/d' | tr '\n' ',' | sed 's/,$//')
    echo "   Found targets: $REPOS"
  else
    echo "❌ No targets file found: $TARGETS_FILE"
    exit 1
  fi
fi

# Split repos
IFS=',' read -ra REPO_ARRAY <<< "$REPOS"
REPO_COUNT=${#REPO_ARRAY[@]}

echo "📍 Launching $REPO_COUNT repo-scouts (parallel)..."
echo ""

# NOTE: Orchestrator debe ejecutar estos tasks EN UN SOLO MENSAJE
# Este script solo documenta qué debe hacer
for repo in "${REPO_ARRAY[@]}"; do
  repo=$(echo "$repo" | xargs) # trim whitespace
  echo "   🔎 Scout: $repo"
  echo "      → Task: repo-scout"
  echo "      → Prompt: Scout repo \"$repo\" for task \"$TASK\""
  echo ""
done

echo "💡 Orchestrator must launch all ${REPO_COUNT} repo-scouts in ONE message (parallel)"
echo ""
echo "✅ Discovery phase template ready"
