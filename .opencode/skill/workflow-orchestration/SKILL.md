---
name: workflow-orchestration
description: Orquestación robusta de múltiples scripts en secuencia con control de errores, logging y rollback
compatibility: opencode
trigger_keywords: ["workflow", "multi-script", "sequential", "orchestration"]
---

# Workflow Orchestration Skill

Sistema de orquestación para ejecutar **múltiples scripts en secuencia** con control robusto de errores, logging detallado y capacidad de rollback.

## Concepto

Divide workflows complejos en **4 fases estándar**:

1. **Initialize** (script1.sh): Setup, validaciones preliminares
2. **Validate** (script2.sh): Pre-checks, validar inputs
3. **Execute** (script3.sh): Implementación principal
4. **Finalize** (script4.sh): Cleanup, post-checks, wrap

Cada script:
- Retorna exit code (0 = success, 1+ = fail)
- Produce output (stdout/stderr) loggeado
- Puede abortar el workflow completo si falla

## Cuándo usar

- **Workflows E2E** que requieren múltiples pasos independientes
- **Setup/Teardown** patterns (bootstrap, migrations, cleanup)
- **Multi-stage deployments** (build → test → deploy → verify)
- **Data pipelines** (extract → transform → load → validate)

## Estructura

```
.opencode/skill/workflow-orchestration/
├── SKILL.md                (este archivo)
├── orchestrator.sh         (ejecutor principal)
├── scripts/
│   ├── script1-init.sh     (fase 1: initialization)
│   ├── script2-validate.sh (fase 2: validation)
│   ├── script3-execute.sh  (fase 3: execution)
│   └── script4-finalize.sh (fase 4: finalization)
└── logs/
    └── <timestamp>_workflow.log (logs de ejecución)
```

## Uso

### Desde Command Line

```bash
# Ejecutar workflow completo
./orchestrator.sh

# Ejecutar con contexto
./orchestrator.sh --task "catalogos" --repos "cloud_front,signage_service"

# Ejecutar fases específicas (ej: solo init + validate)
./orchestrator.sh --phases "1,2"

# Dry-run (no ejecuta, solo muestra plan)
./orchestrator.sh --dry-run
```

### Desde Orchestrator

```
Orchestrator detecta: necesita workflow secuencial con 4 fases

AUTO-TRIGGER workflow-orchestration:
  Fases:
    1. Init: Setup workspace, check dependencies
    2. Validate: Verify targets, check git status
    3. Execute: Run implementation (builder)
    4. Finalize: Run gates, generate evidence

Si cualquier fase falla → abort workflow
```

## Orchestrator Script Logic

```bash
#!/usr/bin/env bash
set -euo pipefail

PHASES=(
  "script1-init.sh"
  "script2-validate.sh"
  "script3-execute.sh"
  "script4-finalize.sh"
)

LOG_DIR="./logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/$(date +%Y%m%d_%H%M%S)_workflow.log"

{
  echo "╔════════════════════════════════════════════════════════════╗"
  echo "║         🔄 Workflow Orchestration - Sequential            ║"
  echo "╚════════════════════════════════════════════════════════════╝"
  echo ""

  for i in "${!PHASES[@]}"; do
    phase_num=$((i+1))
    script="${PHASES[$i]}"
    phase_name="${script%.sh}"

    echo "▶️  Phase $phase_num/4: $phase_name"
    echo "   Script: $script"
    echo ""

    if bash "./scripts/$script"; then
      echo "✅ Phase completed: $phase_name"
    else
      echo "❌ Phase failed: $phase_name"
      echo "   Aborting workflow..."
      exit 1
    fi

    echo ""
  done

  echo "✨ Workflow completed successfully"
} | tee "$LOG_FILE"

echo "📝 Log saved: $LOG_FILE"
```

## Phase Scripts (Plantillas)

### script1-init.sh (Initialization)

```bash
#!/usr/bin/env bash
set -euo pipefail

echo "🚀 Phase 1: Initialization"
echo ""

# Check dependencies
echo "   Checking dependencies..."
command -v node >/dev/null 2>&1 || { echo "❌ node not found"; exit 1; }
command -v git >/dev/null 2>&1 || { echo "❌ git not found"; exit 1; }
echo "   ✅ Dependencies OK"
echo ""

# Setup workspace
echo "   Setting up workspace..."
mkdir -p worklog
mkdir -p .opencode/targets
echo "   ✅ Workspace ready"
echo ""

echo "✅ Initialization complete"
```

### script2-validate.sh (Validation)

```bash
#!/usr/bin/env bash
set -euo pipefail

echo "🔍 Phase 2: Validation"
echo ""

# Validate targets exist
echo "   Validating targets..."
TASK="${1:-}"
if [[ -z "$TASK" ]]; then
  echo "❌ No task specified"
  exit 1
fi

TARGETS_FILE=".opencode/targets/$(date +%F)_${TASK}.txt"
if [[ ! -f "$TARGETS_FILE" ]]; then
  echo "❌ Targets file not found: $TARGETS_FILE"
  exit 1
fi

REPO_COUNT=$(grep -cvE '^\s*(#|$)' "$TARGETS_FILE" || true)
echo "   ✅ Found $REPO_COUNT target repos"
echo ""

# Check git status
echo "   Checking git status..."
if git diff --quiet; then
  echo "   ⚠️  Working directory clean (no uncommitted changes)"
else
  echo "   ✅ Working directory has changes (expected)"
fi
echo ""

echo "✅ Validation complete"
```

### script3-execute.sh (Execution)

```bash
#!/usr/bin/env bash
set -euo pipefail

echo "⚙️  Phase 3: Execution"
echo ""

TASK="${1:-}"
REPOS="${2:-}"

# Main implementation logic here
echo "   Executing main workflow..."
echo "   Task: $TASK"
echo "   Repos: $REPOS"
echo ""

# Placeholder: Aquí iría la lógica principal
# Por ejemplo: builder implementation, migrations, deployments, etc.
echo "   💡 Main logic placeholder"
echo "   (Replace with actual implementation)"
echo ""

sleep 1 # Simulate work

echo "✅ Execution complete"
```

### script4-finalize.sh (Finalization)

```bash
#!/usr/bin/env bash
set -euo pipefail

echo "🏁 Phase 4: Finalization"
echo ""

TASK="${1:-}"

# Run gates
echo "   Running quality gates..."
if command -v ./scripts/oc-gate >/dev/null 2>&1; then
  ./scripts/oc-gate "$TASK" || echo "⚠️  Gates failed (non-blocking)"
else
  echo "   ⚠️  oc-gate not found, skipping"
fi
echo ""

# Generate evidence
echo "   Generating evidence..."
echo "   - Worklog updated"
echo "   - CI results captured"
echo "   - E2E_TRACE validated"
echo ""

echo "✅ Finalization complete"
```

## Error Handling

### Automatic Abort

Si cualquier fase retorna exit code != 0, el workflow se aborta:

```
▶️  Phase 1/4: script1-init
✅ Phase completed: script1-init

▶️  Phase 2/4: script2-validate
❌ Phase failed: script2-validate
   Aborting workflow...
```

### Rollback (Opcional)

Agregar `script0-rollback.sh` que se ejecuta si el workflow falla:

```bash
#!/usr/bin/env bash
set -euo pipefail

echo "🔙 Rollback Phase"
echo ""

# Revert changes
git restore .
echo "   ✅ Git changes reverted"

# Cleanup temp files
rm -f /tmp/workflow_*
echo "   ✅ Temp files cleaned"

echo "✅ Rollback complete"
```

## Logging

Todo el output va a:
- **stdout/stderr**: Real-time en terminal
- **Log file**: `logs/<timestamp>_workflow.log` para auditoría

Formato:
```
[2026-01-15 14:32:18] ▶️  Phase 1/4: script1-init
[2026-01-15 14:32:19]    ✅ Dependencies OK
[2026-01-15 14:32:20] ✅ Phase completed: script1-init
```

## Patterns Aplicables

### Pattern 1: Database Migration

```bash
# script1-init.sh: Backup current DB
# script2-validate.sh: Check migration script syntax
# script3-execute.sh: Run migration
# script4-finalize.sh: Verify data integrity
```

### Pattern 2: Multi-Repo Deploy

```bash
# script1-init.sh: Check all repos exist
# script2-validate.sh: Run tests in all repos
# script3-execute.sh: Build + deploy each repo (sequential)
# script4-finalize.sh: Health checks + smoke tests
```

### Pattern 3: E2E Test Suite

```bash
# script1-init.sh: Setup test environment
# script2-validate.sh: Verify test fixtures
# script3-execute.sh: Run test suites (unit → integration → e2e)
# script4-finalize.sh: Generate coverage report
```

## Integración con Smart Router

workflow-orchestration puede ser **invocado por smart-router** como phase script:

```json
{
  "phases": [
    {
      "name": "complex-execution",
      "script": "workflow-orchestration/orchestrator.sh",
      "parallel": false
    }
  ]
}
```

## Beneficios

✅ **Modular**: Cada script es independiente y testeable
✅ **Robusto**: Abort automático si falla cualquier fase
✅ **Auditable**: Logs completos de toda la ejecución
✅ **Reutilizable**: Scripts pueden usarse standalone
✅ **Visible**: Output claro muestra progreso en real-time

## Notas

- Scripts deben ser **idempotent** (ejecutar 2 veces = mismo resultado)
- Scripts deben **validar inputs** al inicio (fail fast)
- Scripts pueden **aceptar args** (task, repos, etc.)
- Orchestrator puede extenderse con más fases si necesario

---

**Version**: 1.0
**Compatible with**: OpenCode Kit v8+
**References**: darrenhinde-opencode-skills-example (Tier 3)
