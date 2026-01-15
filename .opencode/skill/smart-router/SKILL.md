---
name: Smart Router (Multi-Repo E2E Workflows)
description: Config-driven routing para workflows dinámicos multi-repo. Decide automáticamente qué fases ejecutar según tipo de cambio.
compatibility: opencode
trigger_keywords: ["workflow", "multi-repo", "orchestration", "routing"]
---

# Smart Router Skill

Sistema de routing inteligente que decide automáticamente qué workflow ejecutar según el **tipo de cambio** y **repos afectados**.

## Concepto

En lugar de hardcodear el workflow, el **router lee un config JSON** que especifica:
- Qué fases ejecutar (discovery, contracts, implementation, integration)
- Si ejecutar en paralelo o secuencial
- Qué subagentes invocar por fase

## Cuándo usar

- **Task cross-repo** que puede seguir diferentes paths
- **Diferentes estrategias** según tipo de cambio:
  - Feature nueva: discovery → contracts → implementation → integration
  - Bugfix: implementation directa (skip discovery)
  - Refactor: discovery → implementation → review exhaustivo

## Estructura

```
.opencode/skill/smart-router/
├── SKILL.md                    (este archivo)
├── router.sh                   (router principal - lee config y ejecuta)
├── config/
│   ├── multi-repo-e2e.json     (workflow completo con todas las fases)
│   ├── quick-fix.json          (workflow rápido para bugfixes)
│   └── refactor.json           (workflow con review exhaustivo)
└── scripts/
    ├── phase-discovery.sh      (fase discovery: lanza repo-scouts)
    ├── phase-contracts.sh      (fase contracts: valida cross-repo)
    ├── phase-implementation.sh (fase implementation: builder)
    └── phase-integration.sh    (fase integration: integration-builder)
```

## Uso

### Desde Orchestrator

```
Orchestrator detecta: task afecta 5 repos con dependencias complejas

AUTO-TRIGGER smart-router:
  Config: multi-repo-e2e
  Router ejecuta:
    Phase 1: discovery → lanza 5 repo-scouts EN PARALELO
    Phase 2: contracts → contract-keeper valida DTOs
    Phase 3: implementation → builder con orden: back→proxy→fronts
    Phase 4: integration → integration-builder coordina
```

### Desde Command Line

```bash
# Ejecutar workflow específico
./router.sh multi-repo-e2e catalogos "cloud_front,signage_service,ftp"

# Ejecutar quick-fix
./router.sh quick-fix auth-bug "signage_service"
```

## Configs Disponibles

### 1. multi-repo-e2e.json

**Uso**: Features nuevas cross-repo con dependencias complejas

**Fases**:
1. Discovery (paralelo)
2. Contracts (validación)
3. Implementation (secuencial por dependencias)
4. Integration (coordinación final)

**Ejemplo**: "Add catalogos feature" afectando 5 repos

---

### 2. quick-fix.json

**Uso**: Bugfixes aislados en 1 repo

**Fases**:
1. Implementation directa (skip discovery)
2. Review

**Ejemplo**: "Fix auth token expiration" en signage_service

---

### 3. refactor.json

**Uso**: Refactorings que afectan múltiples archivos

**Fases**:
1. Discovery
2. Implementation (con extra care)
3. Review exhaustivo (adversarial: security + quality + testing)
4. Documentation update

**Ejemplo**: "Refactor API clients to use shared library"

---

## Config Format (JSON)

```json
{
  "workflow": "multi-repo-e2e",
  "description": "Full E2E workflow for cross-repo features",
  "phases": [
    {
      "name": "discovery",
      "script": "phase-discovery.sh",
      "parallel": true,
      "description": "Launch repo-scouts for each target"
    },
    {
      "name": "contracts",
      "script": "phase-contracts.sh",
      "parallel": false,
      "description": "Validate DTOs/endpoints cross-repo"
    },
    {
      "name": "implementation",
      "script": "phase-implementation.sh",
      "parallel": false,
      "description": "Implement with dependency order"
    },
    {
      "name": "integration",
      "script": "phase-integration.sh",
      "parallel": false,
      "description": "Coordinate final integration"
    }
  ],
  "gates": {
    "after_implementation": ["lint", "typecheck", "build"],
    "before_wrap": ["no-any", "e2e-trace"]
  }
}
```

## Router Logic (router.sh)

```bash
#!/usr/bin/env bash
set -euo pipefail

CONFIG_NAME="${1:-multi-repo-e2e}"
TASK="${2:-}"
REPOS="${3:-}"

CONFIG_FILE="./config/${CONFIG_NAME}.json"
[[ -f "$CONFIG_FILE" ]] || { echo "Config not found: $CONFIG_FILE"; exit 1; }

# Parse JSON (usando jq o node)
WORKFLOW=$(jq -r '.workflow' "$CONFIG_FILE")
PHASES=$(jq -r '.phases[].name' "$CONFIG_FILE")

echo "🚀 Smart Router: $WORKFLOW"
echo "📋 Task: $TASK"
echo "🎯 Repos: $REPOS"
echo ""

# Execute each phase
for phase in $PHASES; do
  SCRIPT=$(jq -r ".phases[] | select(.name==\"$phase\") | .script" "$CONFIG_FILE")
  PARALLEL=$(jq -r ".phases[] | select(.name==\"$phase\") | .parallel" "$CONFIG_FILE")

  echo "▶️  Phase: $phase (parallel=$PARALLEL)"
  ./scripts/"$SCRIPT" "$TASK" "$REPOS"
  echo "✅ Phase completed: $phase"
  echo ""
done

echo "✨ Workflow completed: $WORKFLOW"
```

## Phase Scripts (Ejemplos)

### phase-discovery.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

TASK="$1"
REPOS="$2"

echo "🔍 Discovery phase"
echo "   Task: $TASK"
echo "   Repos: $REPOS"

IFS=',' read -ra REPO_ARRAY <<< "$REPOS"

# Lanzar repo-scouts EN PARALELO
# (Orchestrator debe hacer task calls en un mensaje)
for repo in "${REPO_ARRAY[@]}"; do
  echo "   - Launching repo-scout for $repo"
  # Aquí el orchestrator haría: Task repo-scout con prompt
done

echo "✅ Discovery complete"
```

### phase-contracts.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

TASK="$1"
REPOS="$2"

echo "🧩 Contracts phase"
echo "   Validating DTOs/endpoints cross-repo"

# Orchestrator lanza contract-keeper
echo "   - Launching contract-keeper"
# Task contract-keeper con repos y cambios

echo "✅ Contracts validated"
```

## Beneficios

✅ **Reutilizable**: Un config = un workflow completo
✅ **Flexible**: Cambia config = comportamiento diferente
✅ **Escalable**: Agregar workflow = agregar JSON
✅ **Visible**: Config JSON es human-readable
✅ **Testable**: Cada phase script es independiente

## Patterns Aplicables

### Pattern 1: Feature Flag Workflow
```json
{
  "workflow": "feature-flag-rollout",
  "phases": ["implement-backend", "feature-flag", "gradual-rollout", "monitor"]
}
```

### Pattern 2: Hotfix Workflow
```json
{
  "workflow": "hotfix",
  "phases": ["implement", "emergency-review", "deploy-production"]
}
```

### Pattern 3: Database Migration Workflow
```json
{
  "workflow": "db-migration",
  "phases": ["backup", "migration-script", "rollback-plan", "execute", "verify"]
}
```

## Integración con Orchestrator

El orchestrator puede **auto-seleccionar workflow** según contexto:

```typescript
function selectWorkflow(task: Task): string {
  const repoCount = task.targets.length;
  const hasBreakingChanges = task.description.includes("breaking");
  const isBugfix = task.description.includes("fix") || task.description.includes("bug");

  if (isBugfix && repoCount === 1) {
    return "quick-fix";
  }

  if (repoCount >= 3 && hasBreakingChanges) {
    return "multi-repo-e2e";
  }

  if (task.description.includes("refactor")) {
    return "refactor";
  }

  return "multi-repo-e2e"; // default
}
```

## Notas

- Router es invocado por orchestrator (no user directamente)
- Cada phase script puede fallar → router aborta workflow
- Config JSON debe estar en version control
- Phase scripts pueden usar otros skills (workflow-orchestration, etc.)

---

**Version**: 1.0
**Compatible with**: OpenCode Kit v8+
**References**: darrenhinde-opencode-skills-example (Tier 4)
