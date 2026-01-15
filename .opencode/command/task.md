---
description: "Iniciar task multi-repo: targets + worklog + snapshot + delegation"
agent: orchestrator
---

# Comando /task

Inicia un task E2E multi-repo con setup completo.

## Workflow

### 1. Inicialización

Ejecutar scripts:
```bash
# Crear worklog
DATE=$(date +%F)
TASK_NAME="<task>"
WORKLOG_FILE="worklog/${DATE}_${TASK_NAME}.md"

# Crear worklog con encabezado
cat > "$WORKLOG_FILE" <<EOF
# Task: ${TASK_NAME}
Date: ${DATE}

## Context
<pendiente: orchestrator debe completar>

## Targets
<pendiente: definir repos>

## Snapshot Before
EOF

# Crear targets file vacío
TARGETS_FILE=".opencode/targets/${DATE}_${TASK_NAME}.txt"
./scripts/oc-targets init "${TASK_NAME}"

# Snapshot before (git status por repo)
./scripts/oc-snapshot "${TASK_NAME}"
```

### 2. Definir Targets

**Preguntar al user**: "¿Cómo definir repos targets?"

Opciones:
1. **Auto-detect** (buscar por keyword)
2. **Manual** (especificar repos)

#### Opción 1: Auto-detect
```bash
# User provee query (ej: "catalogo", "auth", "payment")
./scripts/oc-targets auto "${TASK_NAME}" "<query>"

# Mostrar repos detectados:
# "Found repos: repo1, repo2, repo3"
# "¿Continuar con estos targets?"
```

#### Opción 2: Manual
```bash
# User lista repos (ej: "cloud_front, signage_service")
./scripts/oc-targets set "${TASK_NAME}" repo1 repo2 repo3
```

### 3. Discovery (Parallel Repo-Scouts)

**Si targets existen** (2+ repos):

Lanzar **EN PARALELO** (un mensaje, N tasks) repo-scouts para cada target:
```
Task: repo-scout para <repo1>
Task: repo-scout para <repo2>
Task: repo-scout para <repo3>
...
```

Cada repo-scout devuelve:
- Archivos relevantes al task
- Contratos actuales (DTOs, endpoints, events)
- Patrones existentes (hooks, services, clients)
- E2E flow parcial del repo

### 4. Sintetizar Discovery

Después de scouts:
- Repos realmente afectados (puede ser subset)
- Orden de implementación (dependency tree)
- Contratos que deben validarse cross-repo
- Riesgos/notas (breaking changes, etc.)

### 5. Crear Task Brief

Usar template `.opencode/templates/task-brief.md`:

```md
# Task Brief (Orchestrator → Builder)

## Context
- Qué está roto / no encaja:
- Repos implicados: <lista>
- Pantallas/flows implicados:

## Scope
- En scope:
- Fuera de scope:

## Definition of Done
- [ ] E2E_TRACE completado (UI → svc → integración → UI)
- [ ] Funciona end-to-end (por código)
- [ ] UI encaja con la actual
- [ ] No `any`
- [ ] Lint/format/typecheck/build pasan en repos afectados

## Discovery (Repo-Scouts)
<sintetizar outputs de repo-scouts>

## Orden de Implementación
<back primero, luego proxy, luego fronts>

## Contracts to Validate
<DTOs/endpoints que deben coincidir cross-repo>
```

### 6. Delegar a @builder

```
Task: @builder
Prompt: <Task Brief completo>
```

---

## Flags opcionales

- `/task <nombre>` - forma básica
- `/task <nombre> --auto "<query>"` - auto-detect directo
- `/task <nombre> --repos repo1,repo2` - manual directo

---

## Output esperado

```
✅ Task initialized: <task>
📁 Worklog: worklog/2026-01-15_<task>.md
🎯 Targets: .opencode/targets/2026-01-15_<task>.txt
📸 Snapshot: captured

🔍 Discovery...
   - repo-scout cloud_front: ✅
   - repo-scout signage_service: ✅
   - repo-scout ftp: ✅

🧩 Repos affected: 3
   - signage_service (backend)
   - ftp (proxy)
   - cloud_front (UI)

📋 Dependency order: signage_service → ftp → cloud_front

👷 Delegating to @builder with Task Brief...
```

---

## Notas

- Si solo 1 repo target → skip repo-scouts (no paralelo needed)
- Si ningún target → error "No targets set. Run /task again with --auto or --repos"
- Worklog se va actualizando durante el task (builder agrega E2E_TRACE, scribe agrega wrap)
