#!/usr/bin/env bash
set -euo pipefail

# Phase: Implementation (Sequential by Dependencies)
TASK="$1"
REPOS="${2:-}"

echo "🛠️  Implementation Phase"
echo "   Task: $TASK"
echo "   Repos: $REPOS"
echo ""

echo "📋 Recommended dependency order:"
echo "   1. Backend repos (API + DB)"
echo "   2. Middleware/Proxy repos"
echo "   3. Frontend repos (consume APIs)"
echo ""

echo "💡 Orchestrator should:"
echo "   1. Create Task Brief with:"
echo "      - Context (from discovery + supermemory)"
echo "      - Scope (repos affected + DoD)"
echo "      - E2E_TRACE requirement"
echo "      - Dependency order"
echo "   2. Delegate to @builder"
echo "   3. Wait for GATE_REQUEST"
echo "   4. Run gates (lint/typecheck/build)"
echo "   5. Validate no-any"
echo ""

echo "✅ Implementation phase template ready"
