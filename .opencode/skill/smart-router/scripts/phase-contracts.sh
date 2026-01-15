#!/usr/bin/env bash
set -euo pipefail

# Phase: Contracts Validation (Cross-Repo)
TASK="$1"
REPOS="${2:-}"

echo "🧩 Contracts Phase"
echo "   Task: $TASK"
echo "   Repos: $REPOS"
echo ""

echo "🔍 Validating contracts cross-repo..."
echo "   → DTOs (interfaces/types)"
echo "   → Endpoints (method, path, request/response)"
echo "   → Events (if applicable)"
echo "   → Shared paths (proxy URLs, asset paths)"
echo ""

echo "💡 Orchestrator should:"
echo "   1. Collect discovery outputs from repo-scouts"
echo "   2. Identify contracts to validate (DTOs, endpoints, etc.)"
echo "   3. Launch contract-keeper with:"
echo "      - Repos affected: $REPOS"
echo "      - Contracts list: <from discovery>"
echo "      - Changes made: <from builder if applicable>"
echo ""

echo "✅ Contracts phase template ready"
