#!/usr/bin/env bash
set -euo pipefail

# Phase: Integration (Final Coordination)
TASK="$1"
REPOS="${2:-}"

echo "🔗 Integration Phase"
echo "   Task: $TASK"
echo "   Repos: $REPOS"
echo ""

echo "🔍 Final integration checks..."
echo "   → All repos build successfully"
echo "   → Contracts validated cross-repo"
echo "   → E2E flow complete (UI → API → DB → UI)"
echo "   → No breaking changes introduced"
echo ""

echo "💡 Orchestrator should:"
echo "   1. Launch integration-builder if needed (3+ repos with complex dependencies)"
echo "   2. Validate E2E_TRACE completeness"
echo "   3. Run full gate suite (all repos)"
echo "   4. Delegate to @reviewer for final PASS/FAIL"
echo ""

echo "✅ Integration phase template ready"
