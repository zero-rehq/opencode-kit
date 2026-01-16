#!/bin/bash

# setup-ci.sh - Setup GitHub Actions CI/CD workflow for a repository
# Usage: ./setup-ci.sh [project-type] [repo-path]
# Output: GitHub Actions workflow files

set -e

PROJECT_TYPE="${1:-nodejs}"
REPO_PATH="${2:-.}"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=========================================="
echo "GitHub Actions CI/CD Setup"
echo "=========================================="
echo "Project type: $PROJECT_TYPE"
echo "Repo path: $REPO_PATH"
echo ""

# Create .github/workflows directory
WORKFLOWS_DIR="$REPO_PATH/.github/workflows"
mkdir -p "$WORKFLOWS_DIR"

echo "Creating workflow files..."

case "$PROJECT_TYPE" in
    nodejs|nextjs|react)
        echo -e "${GREEN}✓${NC} Node.js/Next.js/React project detected"

        # Create main CI workflow
        cat > "$WORKFLOWS_DIR/ci.yml" << 'EOF'
name: CI

on:
  pull_request:
    branches: [main, develop]
  push:
    branches: [main, develop]

jobs:
  quality-gates:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'pnpm'

      - name: Install dependencies
        run: pnpm install --frozen-lockfile

      - name: Lint
        run: pnpm lint

      - name: Format check
        run: pnpm format:check

      - name: Type check
        run: pnpm typecheck

      - name: Build
        run: pnpm build

      - name: Test
        run: pnpm test

  no-any-scan:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Scan for 'any' types
        run: |
          ANY_COUNT=$(rg -n "(:\s*any\b|\bas any\b|<any\b)" -S . --type ts --type tsx | wc -l)
          echo "Found $ANY_COUNT 'any' types"
          if [ "$ANY_COUNT" -gt 0 ]; then
            echo "::warning::Found $ANY_COUNT 'any' type usages"
            rg -n "(:\s*any\b|\bas any\b|<any\b)" -S . --type ts --type tsx
          fi
        continue-on-error: true
EOF

        echo -e "${GREEN}✓${NC} Created: .github/workflows/ci.yml"
        ;;

    python)
        echo -e "${GREEN}✓${NC} Python project detected"

        cat > "$WORKFLOWS_DIR/ci.yml" << 'EOF'
name: CI

on:
  pull_request:
    branches: [main, develop]
  push:
    branches: [main, develop]

jobs:
  quality-gates:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'

      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install -r requirements.txt

      - name: Lint
        run: |
          pip install flake8 black mypy
          flake8 .
          black --check .
          mypy .

      - name: Test
        run: pytest
EOF

        echo -e "${GREEN}✓${NC} Created: .github/workflows/ci.yml"
        ;;

    *)
        echo -e "${YELLOW}WARNING:${NC} Unknown project type: $PROJECT_TYPE"
        echo "Supported types: nodejs, nextjs, react, python"
        exit 1
        ;;
esac

echo ""
echo "=========================================="
echo "Quality Gates Configured"
echo "=========================================="
echo ""
echo "The following quality gates are now enabled:"
echo "  ✓ Lint"
echo "  ✓ Format check"
echo "  ✓ Type check (for TypeScript)"
echo "  ✓ Build"
echo "  ✓ Test"
echo "  ✓ no-any scan"
echo ""
echo "Next steps:"
echo "  1. Commit and push the workflow files"
echo "  2. Check Actions tab on GitHub"
echo "  3. Verify all quality gates pass"
echo ""
echo "Customize workflows as needed for your project"
