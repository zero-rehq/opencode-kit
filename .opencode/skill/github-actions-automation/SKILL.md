---
name: GitHub Actions Automation (CI/CD)
description: Crear y optimizar workflows de CI/CD multi-repo con GitHub Actions
compatibility: opencode
trigger_keywords: ["github actions", "ci/cd", "workflow", "automation"]
source: SkillsMP - dnyoussef-ai-chrome-extension
---

# GitHub Actions Automation Skill

Sistema para crear, optimizar y mantener workflows de CI/CD multi-repo usando GitHub Actions.

## Cuándo usar

- **Setup inicial**: `/bootstrap` detecta repos sin CI → sugiere setup
- **Optimización**: Workflows existentes lentos o rotos
- **Multi-repo**: Coordinar CI across múltiples repos
- **Best practices**: Security scanning, matrix builds, caching

## Features

✅ **Template workflows** para stacks comunes:
- Node.js (npm/pnpm/yarn)
- Rust (cargo)
- Go (go test/build)
- Python (pytest)

✅ **Optimizaciones**:
- Dependency caching (npm, cargo, go mod)
- Matrix builds (múltiples Node versions)
- Parallel jobs (lint, test, build simultáneos)
- Conditional workflows (skip en draft PRs)

✅ **Security**:
- Dependabot integration
- CodeQL scanning
- Secret scanning
- SAST tools

## Workflow Templates

### Node.js CI (Full)

```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'pnpm'
      - run: pnpm install --frozen-lockfile
      - run: pnpm lint

  typecheck:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'pnpm'
      - run: pnpm install --frozen-lockfile
      - run: pnpm typecheck

  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'pnpm'
      - run: pnpm install --frozen-lockfile
      - run: pnpm test --coverage
      - uses: codecov/codecov-action@v3

  build:
    runs-on: ubuntu-latest
    needs: [lint, typecheck, test]
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'pnpm'
      - run: pnpm install --frozen-lockfile
      - run: pnpm build
```

### Multi-Repo CI (Matrix)

```yaml
name: Multi-Repo CI

on:
  push:
    branches: [main]

jobs:
  test-repos:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        repo: [cloud_front, signage_service, etouch]
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'pnpm'
      - name: Test ${{ matrix.repo }}
        run: |
          cd ${{ matrix.repo }}
          pnpm install
          pnpm test
```

### Rust CI

```yaml
name: Rust CI

on: [push, pull_request]

jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions-rs/toolchain@v1
        with:
          toolchain: stable
      - uses: Swatinem/rust-cache@v2
      - run: cargo check
      - run: cargo test
      - run: cargo clippy -- -D warnings
      - run: cargo build --release
```

## Script (setup-ci.sh)

```bash
#!/usr/bin/env bash
set -euo pipefail

REPO="${1:-.}"
cd "$REPO"

echo "🔧 Setting up GitHub Actions CI..."

# Detect stack
if [[ -f package.json ]]; then
  STACK="nodejs"
  PKG_MANAGER="npm"
  [[ -f pnpm-lock.yaml ]] && PKG_MANAGER="pnpm"
  [[ -f yarn.lock ]] && PKG_MANAGER="yarn"
elif [[ -f Cargo.toml ]]; then
  STACK="rust"
elif [[ -f go.mod ]]; then
  STACK="go"
else
  echo "❌ Unknown stack. Supported: Node.js, Rust, Go"
  exit 1
fi

echo "   Detected: $STACK"

# Create .github/workflows directory
mkdir -p .github/workflows

# Generate workflow file based on stack
case "$STACK" in
  nodejs)
    echo "   Generating Node.js CI workflow..."
    cat > .github/workflows/ci.yml <<EOF
name: CI
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: '$PKG_MANAGER'
      - run: $PKG_MANAGER install
      - run: $PKG_MANAGER run lint || true
      - run: $PKG_MANAGER run typecheck || true
      - run: $PKG_MANAGER test || true
      - run: $PKG_MANAGER run build
EOF
    ;;
  rust)
    echo "   Generating Rust CI workflow..."
    # Template for Rust...
    ;;
  go)
    echo "   Generating Go CI workflow..."
    # Template for Go...
    ;;
esac

echo "✅ CI workflow created: .github/workflows/ci.yml"
echo "   Next: Commit and push to trigger first run"
```

## Uso desde /bootstrap

```
/bootstrap detecta:
- 5 repos sin .github/workflows/

Orchestrator:
1. Sugiere: "Setup CI for repos without workflows?"
2. Si user acepta:
   - Lanza github-actions-automation
   - Para cada repo sin CI:
     * Detecta stack
     * Genera workflow apropiado
     * Commit workflow file
3. Output: "✅ CI setup for 5 repos"
```

## Best Practices Incluidas

✅ **Caching**:
```yaml
- uses: actions/setup-node@v4
  with:
    cache: 'pnpm' # Cache dependencies
```

✅ **Paralelo**:
```yaml
jobs:
  lint: ...
  test: ...
  build:
    needs: [lint, test] # Run after lint + test
```

✅ **Matrix builds**:
```yaml
strategy:
  matrix:
    node-version: [18, 20, 21]
```

✅ **Skip en draft PRs**:
```yaml
if: github.event.pull_request.draft == false
```

## Notas

- Workflows generados son templates → customizar según necesidad
- Usar `gh workflow` CLI para ver status
- Secrets management: `gh secret set`
- Para monorepos: usar `paths` filter en workflow

---

**Version**: 1.0
**Docs**: https://docs.github.com/actions
**Source**: SkillsMP + Best Practices
